/// Unit tests for AppointmentRepository.watchAppointmentsForPatient()
///
/// Verifies real-time stream behaviour added to fix the "Join Meeting button
/// doesn't activate" bug (branch: 009-fix-incoming-call).
///
/// Tests:
/// - Stream emits initial list of appointments
/// - Stream emits updated list when a document changes to status:'calling'
/// - AppointmentModel fields (agoraToken, agoraChannelName, callStartedAt) present
/// - Empty stream when no appointments exist
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_lib;

import '../../fixtures/appointment_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

// Minimal Fake for FirebaseFunctions (not under test here)
class _FakeFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      _FakeCallable();
}

class _FakeCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async =>
      _FakeResult<T>();
}

class _FakeResult<T> extends Fake implements HttpsCallableResult<T> {
  @override
  T get data => {'hasConflict': false, 'appointments': <dynamic>[]} as T;
}

void main() {
  late AppointmentRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUpAll(() {
    tz.initializeTimeZones();
    tz_lib.setLocalLocation(tz_lib.getLocation('Asia/Riyadh'));
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    repository = AppointmentRepositoryImpl(mockFirestore, _FakeFunctions());

    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(
      mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
    ).thenReturn(mockQuery);
    when(
      mockQuery.orderBy(any, descending: anyNamed('descending')),
    ).thenReturn(mockQuery);
  });

  group('watchAppointmentsForPatient', () {
    const testPatientId = 'patient_stream_001';

    /// Builds a mock QueryDocumentSnapshot from an [AppointmentModel].
    MockQueryDocumentSnapshot<Map<String, dynamic>> buildDoc(
      AppointmentModel apt,
    ) {
      final doc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final json = apt.toJson();
      when(doc.data()).thenReturn({...json, 'id': apt.id});
      when(doc.id).thenReturn(apt.id);
      return doc;
    }

    /// Builds a MockQuerySnapshot containing [docs].
    MockQuerySnapshot<Map<String, dynamic>> buildSnapshot(
      List<MockQueryDocumentSnapshot<Map<String, dynamic>>> docs,
    ) {
      final snapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(snapshot.docs).thenReturn(docs);
      return snapshot;
    }

    test(
      'watchAppointmentsForPatient_withPendingAppointment_emitsInitialList',
      () async {
        // Arrange
        final apt = AppointmentFixtures.createPendingAppointment(
          patientId: testPatientId,
        );
        final doc = buildDoc(apt);
        final snapshot = buildSnapshot([doc]);

        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

        // Act
        final stream = repository.watchAppointmentsForPatient(testPatientId);
        controller.add(snapshot);

        // Assert
        final emitted = await stream.first;
        expect(emitted.length, equals(1));
        expect(emitted.first.id, equals(apt.id));
        expect(emitted.first.patientId, equals(testPatientId));

        await controller.close();
      },
    );

    test(
      'watchAppointmentsForPatient_whenStatusChangesToCalling_emitsUpdatedList',
      () async {
        // Arrange — initial state: confirmed
        final confirmed = AppointmentFixtures.createConfirmedAppointment(
          id: 'apt_call_001',
          patientId: testPatientId,
        );

        // Updated state: doctor started the call
        final calling = confirmed.copyWith(
          status: AppointmentStatus.calling,
          agoraToken: 'token_abc123',
          agoraChannelName: 'appointment_apt_call_001_1234567890',
          callStartedAt: DateTime(2026, 4, 1, 10),
        );

        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

        final stream = repository.watchAppointmentsForPatient(testPatientId);

        // Act — emit initial then updated snapshot
        controller
          ..add(buildSnapshot([buildDoc(confirmed)]))
          ..add(buildSnapshot([buildDoc(calling)]));

        // Assert — collect first two emissions
        final emissions = await stream.take(2).toList();

        expect(emissions[0].first.status, equals(AppointmentStatus.confirmed));
        expect(emissions[1].first.status, equals(AppointmentStatus.calling));
        expect(emissions[1].first.agoraToken, equals('token_abc123'));
        expect(
          emissions[1].first.agoraChannelName,
          equals('appointment_apt_call_001_1234567890'),
        );
        expect(
          emissions[1].first.callStartedAt,
          equals(DateTime(2026, 4, 1, 10)),
        );

        await controller.close();
      },
    );

    test(
      'watchAppointmentsForPatient_withAgoraCredentials_agoraFieldsPresent',
      () async {
        // Arrange — appointment with full Agora credentials set
        final apt = AppointmentFixtures.createConfirmedAppointment(
          id: 'apt_agora_001',
          patientId: testPatientId,
          channelName: 'appointment_apt_agora_001_999',
          agoraToken: 'agora_token_xyz',
        ).copyWith(status: AppointmentStatus.calling);

        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

        final stream = repository.watchAppointmentsForPatient(testPatientId);
        controller.add(buildSnapshot([buildDoc(apt)]));

        // Assert
        final emitted = await stream.first;
        expect(emitted.first.agoraToken, isNotEmpty);
        expect(emitted.first.agoraChannelName, isNotEmpty);

        await controller.close();
      },
    );

    test(
      'watchAppointmentsForPatient_withNoAppointments_emitsEmptyList',
      () async {
        // Arrange
        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

        final stream = repository.watchAppointmentsForPatient(testPatientId);
        controller.add(buildSnapshot([]));

        // Assert
        final emitted = await stream.first;
        expect(emitted, isEmpty);

        await controller.close();
      },
    );

    test(
      'watchAppointmentsForPatient_usesDocIdAsFallback_whenIdFieldEmpty',
      () async {
        // Arrange — simulate Firestore doc where 'id' field is missing
        final apt = AppointmentFixtures.createPendingAppointment(
          id: 'doc_level_id',
          patientId: testPatientId,
        );

        final doc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final jsonWithoutId = apt.toJson()..remove('id');
        when(doc.data()).thenReturn(jsonWithoutId);
        when(doc.id).thenReturn('doc_level_id');

        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

        final stream = repository.watchAppointmentsForPatient(testPatientId);
        controller.add(buildSnapshot([doc]));

        // Assert — id should fall back to doc.id
        final emitted = await stream.first;
        expect(emitted.first.id, equals('doc_level_id'));

        await controller.close();
      },
    );

    test(
      'watchAppointmentsForPatient_queriesCorrectCollection_andFiltersOnPatientId',
      () {
        // Arrange — use an empty stream to avoid controller lifecycle issues
        when(mockQuery.snapshots()).thenAnswer((_) => const Stream.empty());

        // Act — calling the method executes the Firestore chain synchronously
        repository.watchAppointmentsForPatient(testPatientId);

        // Assert — Firestore calls made synchronously during method execution
        verify(mockFirestore.collection('appointments')).called(1);
        verify(
          mockCollection.where('patientId', isEqualTo: testPatientId),
        ).called(1);
        verify(
          mockQuery.orderBy('appointmentDate', descending: true),
        ).called(1);
      },
    );
  });
}
