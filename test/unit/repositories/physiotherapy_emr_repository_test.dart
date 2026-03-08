/// Unit tests for PhysiotherapyEMRRepository
///
/// Tests physiotherapy EMR repository operations including:
/// - EMR creation with valid data
/// - EMR retrieval by appointment ID
/// - EMR retrieval by patient ID
/// - Error handling for Firestore failures
/// - Data validation
///
/// Target: 80%+ coverage

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart';
import 'package:elajtech/shared/models/physiotherapy_emr_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/emr_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late PhysiotherapyEMRRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    repository = PhysiotherapyEMRRepositoryImpl(mockFirestore);

    // Setup default Firestore collection mock
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
    when(mockFirestore.databaseId).thenReturn('elajtech');
  });

  group('PhysiotherapyEMRRepository - Save EMR', () {
    test('should save new EMR successfully', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );

      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should save complete EMR with all fields', () async {
      // Arrange
      final emr = EMRFixtures.createCompletePhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );

      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should return failure when appointment ID is empty', () async {
      // Arrange
      final emr = PhysiotherapyEMRModel(
        id: 'physio_emr_invalid',
        patientId: 'patient_test_001',
        doctorId: 'doctor_test_001',
        doctorName: 'Dr. Test',
        appointmentId: '', // Empty appointment ID
        createdAt: DateTime.now(),
        patientBasics: {},
        history: {},
        physicalExamination: {},
        assessment: {},
        plan: {},
        primaryDiagnosis: null,
        managementPlan: null,
      );

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(mockDocumentReference.set(any));
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      when(
        mockDocumentReference.set(any),
      ).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure on FirebaseException', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      final firebaseException = firebase_core.FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Permission denied',
      );

      when(mockDocumentReference.set(any)).thenThrow(firebaseException);

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, contains('Firebase error'));
          expect(failure.message, contains('permission-denied'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should validate data structure before saving', () async {
      // Arrange
      final emr = EMRFixtures.createCompletePhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);

      // Verify the data structure is correct
      final captured = verify(mockDocumentReference.set(captureAny)).captured;
      expect(captured.length, 1);

      final savedData = captured[0] as Map<String, dynamic>;
      expect(savedData['id'], emr.id);
      expect(savedData['patientId'], emr.patientId);
      expect(savedData['doctorId'], emr.doctorId);
      expect(savedData['appointmentId'], emr.appointmentId);
      expect(savedData['patientBasics'], isA<Map<String, dynamic>>());
      expect(savedData['history'], isA<Map<String, dynamic>>());
      expect(savedData['physicalExamination'], isA<Map<String, dynamic>>());
      expect(savedData['assessment'], isA<Map<String, dynamic>>());
      expect(savedData['plan'], isA<Map<String, dynamic>>());
    });
  });

  group('PhysiotherapyEMRRepository - Get EMR By Appointment ID', () {
    const testAppointmentId = 'apt_test_001';

    test('should return EMR when found', () async {
      // Arrange
      final emr = EMRFixtures.createCompletePhysiotherapyEMR();

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.data()).thenReturn(emr.toJson());

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.getEMRByAppointmentId(testAppointmentId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (retrievedEmr) {
          expect(retrievedEmr, isNotNull);
          expect(retrievedEmr!.appointmentId, testAppointmentId);
          expect(retrievedEmr.id, emr.id);
          expect(retrievedEmr.patientId, emr.patientId);
        },
      );
    });

    test('should return null when EMR not found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getEMRByAppointmentId(testAppointmentId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (retrievedEmr) {
          expect(retrievedEmr, isNull);
        },
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getEMRByAppointmentId(testAppointmentId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return EMR'),
      );
    });

    test('should return failure on FirebaseException', () async {
      // Arrange
      final firebaseException = firebase_core.FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      );

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(firebaseException);

      // Act
      final result = await repository.getEMRByAppointmentId(testAppointmentId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, contains('Firebase error'));
          expect(failure.message, contains('unavailable'));
        },
        (_) => fail('Should not return EMR'),
      );
    });

    test('should correctly parse complex EMR data', () async {
      // Arrange
      final emr = EMRFixtures.createCompletePhysiotherapyEMR();

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.data()).thenReturn(emr.toJson());

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.getEMRByAppointmentId(testAppointmentId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (retrievedEmr) {
          expect(retrievedEmr, isNotNull);
          expect(retrievedEmr!.patientBasics, isNotEmpty);
          expect(retrievedEmr.history, isNotEmpty);
          expect(retrievedEmr.physicalExamination, isNotEmpty);
          expect(retrievedEmr.assessment, isNotEmpty);
          expect(retrievedEmr.plan, isNotEmpty);
          expect(retrievedEmr.primaryDiagnosis, isNotNull);
          expect(retrievedEmr.managementPlan, isNotNull);
        },
      );
    });
  });

  group('PhysiotherapyEMRRepository - Get EMRs By Patient ID', () {
    const testPatientId = 'patient_test_001';

    test('should return list of EMRs for patient', () async {
      // Arrange
      final emrs = EMRFixtures.createMultiplePhysiotherapyEMRs(
        patientId: testPatientId,
      );

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final emr in emrs) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(emr.toJson());
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
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (emrList) {
          expect(emrList.length, emrs.length);
          expect(emrList.first.patientId, testPatientId);
          expect(emrList[1].patientId, testPatientId);
          expect(emrList[2].patientId, testPatientId);
        },
      );
    });

    test('should return empty list when no EMRs found', () async {
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
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (emrList) {
          expect(emrList, isEmpty);
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
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return EMRs'),
      );
    });

    test('should return failure on FirebaseException', () async {
      // Arrange
      final firebaseException = firebase_core.FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Permission denied',
      );

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(firebaseException);

      // Act
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, contains('Firebase error'));
          expect(failure.message, contains('permission-denied'));
        },
        (_) => fail('Should not return EMRs'),
      );
    });

    test('should return EMRs ordered by creation date descending', () async {
      // Arrange
      final emrs = EMRFixtures.createMultiplePhysiotherapyEMRs(
        patientId: testPatientId,
      );

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final emr in emrs) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(emr.toJson());
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
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isRight(), true);

      // Verify orderBy was called with correct parameters
      verify(
        mockQuery.orderBy('createdAt', descending: true),
      ).called(1);
    });

    test('should handle mixed EMR types (minimal and complete)', () async {
      // Arrange
      final emrs = [
        EMRFixtures.createMinimalPhysiotherapyEMR(
          patientId: testPatientId,
        ),
        EMRFixtures.createCompletePhysiotherapyEMR(
          patientId: testPatientId,
        ),
      ];

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final emr in emrs) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(emr.toJson());
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
      final result = await repository.getEMRByPatientId(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (emrList) {
          expect(emrList.length, 2);
          // First EMR is minimal
          expect(emrList[0].history, isEmpty);
          expect(emrList[0].primaryDiagnosis, isNull);
          // Second EMR is complete
          expect(emrList[1].history, isNotEmpty);
          expect(emrList[1].primaryDiagnosis, isNotNull);
        },
      );
    });
  });

  group('PhysiotherapyEMRRepository - Data Validation', () {
    test('should validate required fields are present', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);

      final captured = verify(mockDocumentReference.set(captureAny)).captured;
      final savedData = captured[0] as Map<String, dynamic>;

      // Verify all required fields are present
      expect(savedData.containsKey('id'), true);
      expect(savedData.containsKey('patientId'), true);
      expect(savedData.containsKey('doctorId'), true);
      expect(savedData.containsKey('doctorName'), true);
      expect(savedData.containsKey('appointmentId'), true);
      expect(savedData.containsKey('createdAt'), true);
      expect(savedData.containsKey('specialization'), true);
    });

    test('should validate section maps are properly structured', () async {
      // Arrange
      final emr = EMRFixtures.createCompletePhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);

      final captured = verify(mockDocumentReference.set(captureAny)).captured;
      final savedData = captured[0] as Map<String, dynamic>;

      // Verify section maps are present and properly structured
      expect(savedData['patientBasics'], isA<Map<String, dynamic>>());
      expect(savedData['history'], isA<Map<String, dynamic>>());
      expect(savedData['physicalExamination'], isA<Map<String, dynamic>>());
      expect(savedData['assessment'], isA<Map<String, dynamic>>());
      expect(savedData['plan'], isA<Map<String, dynamic>>());

      // Verify map values are lists of strings
      final patientBasics = savedData['patientBasics'] as Map<String, dynamic>;
      for (final value in patientBasics.values) {
        expect(value, isA<List<dynamic>>());
      }
    });

    test('should handle empty section maps correctly', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);

      final captured = verify(mockDocumentReference.set(captureAny)).captured;
      final savedData = captured[0] as Map<String, dynamic>;

      // Verify empty maps are saved correctly
      expect(savedData['history'], isA<Map<dynamic, dynamic>>());
      expect((savedData['history'] as Map<dynamic, dynamic>).isEmpty, true);
      expect(savedData['physicalExamination'], isA<Map<dynamic, dynamic>>());
      expect(
        (savedData['physicalExamination'] as Map<dynamic, dynamic>).isEmpty,
        true,
      );
    });

    test('should handle null optional fields correctly', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalPhysiotherapyEMR();

      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);

      final captured = verify(mockDocumentReference.set(captureAny)).captured;
      final savedData = captured[0] as Map<String, dynamic>;

      // Verify null optional fields are handled
      expect(savedData['primaryDiagnosis'], isNull);
      expect(savedData['managementPlan'], isNull);
    });
  });
}
