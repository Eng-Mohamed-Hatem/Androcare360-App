import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/integration_test_config.dart';

void main() {
  const runAgoraHappyPathIntegration = bool.fromEnvironment(
    'RUN_AGORA_HAPPY_PATH_INTEGRATION_TESTS',
  );

  if (!runAgoraHappyPathIntegration) {
    group('Agora Call Happy Path Integration Test', () {
      test(
        'skipped unless RUN_AGORA_HAPPY_PATH_INTEGRATION_TESTS=true',
        () {},
        skip:
            'Requires device/emulator, Firebase emulators, and callable function integration setup',
      );
    });
    return;
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Agora Call Happy Path Integration Test', () {
    late FirebaseFirestore firestore;
    late FirebaseFunctions functions;

    late String doctorUid;
    late String patientUid;
    late String appointmentId;

    setUpAll(() async {
      await IntegrationTestConfig.connectToEmulators();
      final running = await IntegrationTestConfig.verifyEmulatorsRunning();
      if (!running) {
        throw StateError(
          'Firebase Emulators not running. Start them with: firebase emulators:start',
        );
      }

      firestore = IntegrationTestConfig.getFirestore();
      functions = IntegrationTestConfig.getFunctions();
    });

    setUp(() async {
      await IntegrationTestConfig.clearFirestoreData();
      await IntegrationTestConfig.signOutAllUsers();

      doctorUid = 'doctor-happy-${DateTime.now().millisecondsSinceEpoch}';
      patientUid = 'patient-happy-${DateTime.now().millisecondsSinceEpoch}';

      await IntegrationTestConfig.createTestDocument(
        collection: 'users',
        documentId: doctorUid,
        data: {
          'id': doctorUid,
          'fullName': 'Dr Happy Path',
          'email': 'doctor-happy@test.com',
          'userType': 'doctor',
          'fcmToken': 'doctor_fcm_happy_path',
        },
      );
      await IntegrationTestConfig.createTestDocument(
        collection: 'users',
        documentId: patientUid,
        data: {
          'id': patientUid,
          'fullName': 'Patient Happy Path',
          'email': 'patient-happy@test.com',
          'userType': 'patient',
          'fcmToken': 'patient_fcm_happy_path',
        },
      );

      appointmentId = 'apt_happy_path_${DateTime.now().millisecondsSinceEpoch}';
      await IntegrationTestConfig.createTestDocument(
        collection: 'appointments',
        documentId: appointmentId,
        data: {
          'id': appointmentId,
          'doctorId': doctorUid,
          'patientId': patientUid,
          'doctorName': 'Dr Happy Path',
          'patientName': 'Patient Happy Path',
          'patientPhone': '+201000000000',
          'specialization': 'Nutrition',
          'type': 'video',
          'timeSlot': '10:00 AM',
          'fee': 200,
          'appointmentDate': Timestamp.fromDate(DateTime.utc(2026, 4)),
          'createdAt': Timestamp.fromDate(DateTime.utc(2026, 3, 31)),
          'status': 'scheduled',
        },
      );
    });

    tearDownAll(() async {
      await IntegrationTestConfig.cleanup();
    });

    testWidgets('doctor start to patient join to doctor confirm completed', (
      tester,
    ) async {
      final startResult = await functions
          .httpsCallable('startAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
          });

      expect(startResult.data['success'], isTrue);

      var appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      var appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'calling');
      expect(appointmentData?['callSessionId'], isNotNull);
      expect(appointmentData?['callStartedAt'], isNotNull);

      final inProgressResult = await functions
          .httpsCallable('markCallInProgressForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
          });

      expect(inProgressResult.data['success'], isTrue);

      appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'in_progress');

      final endResult = await functions
          .httpsCallable('endAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
          });

      expect(endResult.data['success'], isTrue);

      appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'ended_pending_confirmation');
      expect(appointmentData?['confirmationDeadlineAt'], isNotNull);
      expect(appointmentData?['callEndedAt'], isNotNull);

      final confirmResult = await functions
          .httpsCallable('confirmAppointmentCompletionForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
            'completed': true,
          });

      expect(confirmResult.data['success'], isTrue);
      expect(confirmResult.data['status'], 'completed');

      appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'completed');
      expect(appointmentData?['completedAt'], isNotNull);
    });

    testWidgets(
      'auto-transition marks ended pending confirmation as not completed after deadline',
      (tester) async {
        await firestore.collection('appointments').doc(appointmentId).update({
          'status': 'ended_pending_confirmation',
          'callEndedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 25)),
          ),
          'confirmationDeadlineAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 1)),
          ),
        });

        final runSchedulerResult = await functions
            .httpsCallable('runAutoCompleteExpiredConfirmationsForTest')
            .call<Map<String, dynamic>>({
              'now': DateTime.now().toIso8601String(),
            });

        expect(runSchedulerResult.data['processed'], greaterThanOrEqualTo(1));

        final appointmentDoc = await firestore
            .collection('appointments')
            .doc(appointmentId)
            .get();
        final appointmentData = appointmentDoc.data();

        expect(appointmentData?['status'], 'not_completed');
        expect(appointmentData?['notCompletedAt'], isNotNull);
      },
    );

    testWidgets(
      'declined call can be retried and completeAppointment path still works',
      (
        tester,
      ) async {
        final firstStart = await functions
            .httpsCallable('startAgoraCallForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
              'doctorId': doctorUid,
            });
        expect(firstStart.data['success'], isTrue);

        final declined = await functions
            .httpsCallable('handleCallDeclinedForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
              'patientId': patientUid,
            });
        expect(declined.data['success'], isTrue);

        var appointmentDoc = await firestore
            .collection('appointments')
            .doc(appointmentId)
            .get();
        var appointmentData = appointmentDoc.data();
        expect(appointmentData?['status'], 'declined');

        final retryStart = await functions
            .httpsCallable('startAgoraCallForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
              'doctorId': doctorUid,
            });
        expect(retryStart.data['success'], isTrue);

        await functions
            .httpsCallable('markCallInProgressForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
            });
        await functions
            .httpsCallable('endAgoraCallForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
            });

        final legacyComplete = await functions
            .httpsCallable('completeAppointmentForTest')
            .call<Map<String, dynamic>>({
              'appointmentId': appointmentId,
              'doctorId': doctorUid,
            });

        expect(legacyComplete.data['success'], isTrue);
        expect(legacyComplete.data['status'], 'completed');

        appointmentDoc = await firestore
            .collection('appointments')
            .doc(appointmentId)
            .get();
        appointmentData = appointmentDoc.data();
        expect(appointmentData?['status'], 'completed');
      },
    );

    testWidgets('doctor can cancel a ringing call back to scheduled', (
      tester,
    ) async {
      final startResult = await functions
          .httpsCallable('startAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
          });
      expect(startResult.data['success'], isTrue);

      final cancelResult = await functions
          .httpsCallable('cancelCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
          });
      expect(cancelResult.data['success'], isTrue);
      expect(cancelResult.data['status'], 'scheduled');

      final appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'scheduled');
      expect(appointmentData?['callSessionId'], isNull);
      expect(appointmentData?['callStatus'], isNull);
    });

    testWidgets('doctor can explicitly mark session as not completed', (
      tester,
    ) async {
      final startResult = await functions
          .httpsCallable('startAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
          });
      expect(startResult.data['success'], isTrue);

      await functions
          .httpsCallable('markCallInProgressForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
          });
      await functions
          .httpsCallable('endAgoraCallForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
          });

      final confirmNoResult = await functions
          .httpsCallable('confirmAppointmentCompletionForTest')
          .call<Map<String, dynamic>>({
            'appointmentId': appointmentId,
            'doctorId': doctorUid,
            'completed': false,
          });

      expect(confirmNoResult.data['success'], isTrue);
      expect(confirmNoResult.data['status'], 'not_completed');

      final appointmentDoc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final appointmentData = appointmentDoc.data();
      expect(appointmentData?['status'], 'not_completed');
      expect(appointmentData?['notCompletedAt'], isNotNull);
    });
  });
}
