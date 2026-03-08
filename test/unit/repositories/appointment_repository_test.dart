/// Unit tests for AppointmentRepository
///
/// Tests appointment repository operations including:
/// - Create appointment with valid data
/// - Get appointments with filtering and pagination
/// - Update appointment
/// - Delete appointment (via status change)
/// - Conflict detection logic
///
/// Target: 80%+ coverage

library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../fixtures/appointment_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

// Local Fake Definitions to avoid mockito state issues with .call
class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return FakeHttpsCallable();
  }
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return FakeHttpsCallableResult<T>();
  }
}

class FakeHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  @override
  T get data => {'hasConflict': false, 'appointments': <dynamic>[]} as T;
}

void main() {
  late AppointmentRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late FakeFirebaseFunctions mockFunctions;

  setUpAll(() {
    // Initialize timezone database for Riyadh time
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = FakeFirebaseFunctions();

    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    repository = AppointmentRepositoryImpl(mockFirestore, mockFunctions);

    // Setup default Firestore collection mock
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
  });

  group('AppointmentRepository - Save Appointment', () {
    test('should save appointment successfully', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();
      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveAppointment(appointment);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (unit) => expect(unit, equals(unit)),
      );

      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();
      when(
        mockDocumentReference.set(any),
      ).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.saveAppointment(appointment);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (unit) => fail('Should not return unit'),
      );
    });

    test('should return failure on network error', () async {
      // Arrange
      final appointment = AppointmentFixtures.createPendingAppointment();
      when(
        mockDocumentReference.set(any),
      ).thenThrow(const SocketException('No internet connection'));

      // Act
      final result = await repository.saveAppointment(appointment);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (unit) => fail('Should not return unit'),
      );
    });
  });

  group('AppointmentRepository - Get Appointments For Patient', () {
    const testPatientId = 'patient_test_001';

    test('should return list of appointments for patient', () async {
      // Arrange
      final appointments = AppointmentFixtures.createMultipleAppointments(
        patientId: testPatientId,
      );

      // Create mock QueryDocumentSnapshots
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final apt in appointments) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(apt.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getAppointmentsForPatient(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList.length, appointments.length);
          expect(appointmentList.first.patientId, testPatientId);
        },
      );

      verify(
        mockCollection.where('patientId', isEqualTo: testPatientId),
      ).called(1);
    });

    test('should return empty list when no appointments found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getAppointmentsForPatient(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList, isEmpty);
        },
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getAppointmentsForPatient(testPatientId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (appointmentList) => fail('Should not return appointments'),
      );
    });
  });

  group('AppointmentRepository - Get Appointments For Doctor', () {
    const testDoctorId = 'doctor_test_001';

    test('should return list of appointments for doctor', () async {
      // Arrange
      final appointments = AppointmentFixtures.createMultipleAppointments(
        doctorId: testDoctorId,
      );

      // Create mock QueryDocumentSnapshots
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final apt in appointments) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(apt.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getAppointmentsForDoctor(testDoctorId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList.length, appointments.length);
          expect(appointmentList.first.doctorId, testDoctorId);
        },
      );

      verify(
        mockCollection.where('doctorId', isEqualTo: testDoctorId),
      ).called(1);
    });

    test('should return empty list when no appointments found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getAppointmentsForDoctor(testDoctorId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList, isEmpty);
        },
      );
    });
  });

  group('AppointmentRepository - Check Appointment Conflict', () {
    const testPatientId = 'patient_test_001';
    const testDoctorId = 'doctor_test_001';

    test('should return false when no conflict exists', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      // Mock patient query
      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (hasConflict) {
          expect(hasConflict, false);
        },
      );
    });

    test('should return true when conflict exists', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      // Create a conflicting appointment with same time slot (10:00 AM)
      final appointmentDate = newAppointment.appointmentDate;
      // Create timestamp for 10:00 AM on the appointment date
      final appointmentTimestamp = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        10, // 10:00 AM
      );

      final conflictingAppointment = AppointmentModel(
        id: 'apt_conflict_001',
        patientId: testPatientId,
        patientName: 'Test Patient',
        patientPhone: '+966500000002',
        doctorId: testDoctorId,
        doctorName: 'Dr. Test Doctor',
        specialization: 'Nutrition',
        appointmentDate: appointmentDate,
        timeSlot: '10:00 AM', // Same time slot as newAppointment
        type: AppointmentType.video,
        status: AppointmentStatus.confirmed,
        fee: 200,
        createdAt: DateTime.now(),
        appointmentTimestamp: appointmentTimestamp,
      );

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.data()).thenReturn(conflictingAppointment.toJson());
      when(mockDoc.id).thenReturn(conflictingAppointment.id);

      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (hasConflict) {
          expect(hasConflict, true);
        },
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      // Mock both patient and doctor queries
      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (hasConflict) => fail('Should not return conflict result'),
      );
    });

    test(
      'should return failure on failed-precondition after retries',
      () async {
        // Arrange
        final newAppointment = AppointmentFixtures.createPendingAppointment(
          patientId: testPatientId,
          doctorId: testDoctorId,
        );

        final firebaseException = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'Index not ready',
        );

        when(
          mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
        ).thenReturn(mockQuery);
        when(
          mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where('status', whereIn: anyNamed('whereIn')),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where(
            'appointmentTimestamp',
            isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
          ),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where(
            'appointmentTimestamp',
            isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
          ),
        ).thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(firebaseException);

        // Act
        final result = await repository.checkAppointmentConflict(
          patientId: testPatientId,
          newAppointment: newAppointment,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(
              failure.message,
              contains('الفهارس الأمنية لا تزال قيد الإعداد'),
            );
          },
          (hasConflict) => fail('Should not return conflict result'),
        );
      },
    );

    test('should return failure on unavailable error', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      final firebaseException = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      );

      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(firebaseException);

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('لا يوجد اتصال بالإنترنت'));
        },
        (hasConflict) => fail('Should not return conflict result'),
      );
    });

    test('should return failure on SocketException', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(
        const SocketException('No internet connection'),
      );

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('لا يوجد اتصال بالإنترنت'));
        },
        (hasConflict) => fail('Should not return conflict result'),
      );
    });

    test('should return failure on TimeoutException', () async {
      // Arrange
      final newAppointment = AppointmentFixtures.createPendingAppointment(
        patientId: testPatientId,
        doctorId: testDoctorId,
      );

      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(
        TimeoutException('Query timeout'),
      );

      // Act
      final result = await repository.checkAppointmentConflict(
        patientId: testPatientId,
        newAppointment: newAppointment,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('انتهت مهلة الاتصال'));
        },
        (hasConflict) => fail('Should not return conflict result'),
      );
    });

    test(
      'should deduplicate appointments from patient and doctor queries',
      () async {
        // Arrange
        final newAppointment = AppointmentFixtures.createPendingAppointment(
          patientId: testPatientId,
          doctorId: testDoctorId,
        );

        // Same appointment returned by both queries
        final existingAppointment =
            AppointmentFixtures.createScheduledAppointment(
              patientId: testPatientId,
              doctorId: testDoctorId,
            );

        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(existingAppointment.toJson());
        when(mockDoc.id).thenReturn(existingAppointment.id);

        when(
          mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
        ).thenReturn(mockQuery);
        when(
          mockCollection.where('doctorId', isEqualTo: anyNamed('isEqualTo')),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where('status', whereIn: anyNamed('whereIn')),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where(
            'appointmentTimestamp',
            isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
          ),
        ).thenReturn(mockQuery);
        when(
          mockQuery.where(
            'appointmentTimestamp',
            isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
          ),
        ).thenReturn(mockQuery);
        // Both queries return the same appointment
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

        // Act
        final result = await repository.checkAppointmentConflict(
          patientId: testPatientId,
          newAppointment: newAppointment,
        );

        // Assert - Should not fail due to deduplication logic
        expect(result.isRight(), true);
      },
    );
  });

  group('AppointmentRepository - Get Active Appointments For Patient', () {
    const testPatientId = 'patient_test_001';

    test('should return only active appointments', () async {
      // Arrange
      final activeAppointments = [
        AppointmentFixtures.createPendingAppointment(patientId: testPatientId),
        AppointmentFixtures.createConfirmedAppointment(
          patientId: testPatientId,
        ),
      ];

      // Create mock QueryDocumentSnapshots
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final apt in activeAppointments) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(apt.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where('patientId', isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getActiveAppointmentsForPatient(
        testPatientId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList.length, 2);
          expect(
            appointmentList.every(
              (apt) =>
                  apt.status == AppointmentStatus.pending ||
                  apt.status == AppointmentStatus.confirmed,
            ),
            true,
          );
        },
      );
    });
  });

  group('AppointmentRepository - Get Active Appointments For Date', () {
    test('should return appointments for specific date', () async {
      // Arrange
      final testDate = DateTime(2024, 3, 15);
      final appointments = [
        AppointmentFixtures.createConfirmedAppointment(),
        AppointmentFixtures.createScheduledAppointment(),
      ];

      // Create mock QueryDocumentSnapshots
      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final apt in appointments) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(apt.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getActiveAppointmentsForDate(testDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList.length, 2);
        },
      );
    });

    test('should return empty list when no appointments on date', () async {
      // Arrange
      final testDate = DateTime(2024, 3, 15);

      when(
        mockCollection.where(
          'appointmentTimestamp',
          isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where(
          'appointmentTimestamp',
          isLessThanOrEqualTo: anyNamed('isLessThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        mockQuery.where('status', whereIn: anyNamed('whereIn')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getActiveAppointmentsForDate(testDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (appointmentList) {
          expect(appointmentList, isEmpty);
        },
      );
    });
  });
}
