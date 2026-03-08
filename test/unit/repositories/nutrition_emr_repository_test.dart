/// Unit tests for NutritionEMRRepository
///
/// Tests nutrition EMR repository operations including:
/// - EMR creation with valid data
/// - EMR retrieval by patient ID
/// - EMR updates
/// - Error handling for Firestore failures
/// - Lock mechanism
///
/// Target: 80%+ coverage

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/nutrition/data/models/nutrition_emr_model.dart';
import 'package:elajtech/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/emr_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late NutritionEMRRepositoryImpl repository;
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

    repository = NutritionEMRRepositoryImpl(mockFirestore);

    // Setup default Firestore collection mock
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
    when(mockFirestore.databaseId).thenReturn('elajtech');
  });

  group('NutritionEMRRepository - Save EMR', () {
    test('should save new EMR successfully', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalNutritionEMR();

      // Mock getEMRByAppointmentId to return null (new EMR)
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockDocumentReference.set(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );

      verify(mockDocumentReference.set(any, any)).called(1);
    });

    test('should update existing EMR successfully', () async {
      // Arrange
      final existingEmr = EMRFixtures.createMinimalNutritionEMR();
      final updatedEmr = existingEmr.copyWith(
        weightValue: 72,
      );

      // Mock getEMRByAppointmentId to return existing EMR
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.exists).thenReturn(true);
      when(
        mockDoc.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(existingEmr));

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      when(mockDocumentReference.set(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(updatedEmr);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );

      verify(mockDocumentReference.set(any, any)).called(1);
    });

    test('should return failure when appointment ID is empty', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalNutritionEMR().copyWith(
        appointmentId: '',
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
    });

    test('should return failure when EMR is locked', () async {
      // Arrange
      final lockedEmr = EMRFixtures.createLockedNutritionEMR();

      // Act
      final result = await repository.saveEMR(lockedEmr);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalNutritionEMR();

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(
        mockDocumentReference.set(any, any),
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
  });

  group('NutritionEMRRepository - Get EMR By Appointment ID', () {
    const testAppointmentId = 'apt_test_001';

    test('should return EMR when found', () async {
      // Arrange
      final emr = EMRFixtures.createCompleteNutritionEMR();

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.exists).thenReturn(true);
      when(mockDoc.data()).thenReturn(NutritionEMRModel.entityToFirestore(emr));

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
  });

  group('NutritionEMRRepository - Get EMRs By Patient ID', () {
    const testPatientId = 'patient_test_001';

    test('should return list of EMRs for patient', () async {
      // Arrange
      final emrs = EMRFixtures.createMultipleNutritionEMRs(
        patientId: testPatientId,
      );

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final emr in emrs) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(
          mockDoc.data(),
        ).thenReturn(NutritionEMRModel.entityToFirestore(emr));
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
      final result = await repository.getEMRsByPatientId(testPatientId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (emrList) {
          expect(emrList.length, emrs.length);
          expect(emrList.first.patientId, testPatientId);
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
      final result = await repository.getEMRsByPatientId(testPatientId);

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
      final result = await repository.getEMRsByPatientId(testPatientId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return EMRs'),
      );
    });
  });

  group('NutritionEMRRepository - Lock EMR', () {
    const testEmrId = 'nutrition_emr_001';

    test('should lock EMR successfully', () async {
      // Arrange
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.lockEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );

      verify(mockDocumentReference.update(any)).called(1);
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(
        mockDocumentReference.update(any),
      ).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.lockEMR(testEmrId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('NutritionEMRRepository - Is Appointment Expired', () {
    const testAppointmentId = 'apt_test_001';

    test('should return true when EMR is locked', () async {
      // Arrange
      final lockedEmr = EMRFixtures.createLockedNutritionEMR();

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.exists).thenReturn(true);
      when(
        mockDoc.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(lockedEmr));

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.isAppointmentExpired(testAppointmentId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (isExpired) {
          expect(isExpired, true);
        },
      );
    });

    test('should return false when EMR not found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.isAppointmentExpired(testAppointmentId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (isExpired) {
          expect(isExpired, false);
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
      final result = await repository.isAppointmentExpired(testAppointmentId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return result'),
      );
    });
  });

  group('NutritionEMRRepository - Watch EMR (Stream)', () {
    const testEmrId = 'nutrition_emr_001';

    test('should return stream that emits EMR updates', () async {
      // Arrange
      final emr = EMRFixtures.createCompleteNutritionEMR();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockDocSnapshot.exists).thenReturn(true);
      when(
        mockDocSnapshot.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(emr));
      when(
        mockDocumentReference.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      await result.fold(
        (failure) => fail('Should not return failure'),
        (stream) async {
          await expectLater(
            stream,
            emits(
              predicate<dynamic>((entity) {
                return entity.id == emr.id && entity.patientId == emr.patientId;
              }),
            ),
          );
        },
      );

      verify(mockDocumentReference.snapshots()).called(1);
    });

    test('should emit multiple updates from stream', () async {
      // Arrange
      final emr1 = EMRFixtures.createCompleteNutritionEMR();
      final emr2 = emr1.copyWith(weightValue: 80);

      final mockDocSnapshot1 = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockDocSnapshot2 = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockDocSnapshot1.exists).thenReturn(true);
      when(
        mockDocSnapshot1.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(emr1));

      when(mockDocSnapshot2.exists).thenReturn(true);
      when(
        mockDocSnapshot2.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(emr2));

      when(mockDocumentReference.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockDocSnapshot1, mockDocSnapshot2]),
      );

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      await result.fold(
        (failure) => fail('Should not return failure'),
        (stream) async {
          await expectLater(
            stream,
            emitsInOrder([
              predicate<dynamic>((entity) => entity.weightValue == 75),
              predicate<dynamic>((entity) => entity.weightValue == 80),
            ]),
          );
        },
      );
    });

    test('should handle stream error when EMR not found', () async {
      // Arrange
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocSnapshot.data()).thenReturn(null);
      when(
        mockDocumentReference.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      await result.fold(
        (failure) => fail('Should not return failure'),
        (stream) async {
          await expectLater(
            stream,
            emitsError(isA<Exception>()),
          );
        },
      );
    });

    test('should handle stream error when data is null', () async {
      // Arrange
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(null);
      when(
        mockDocumentReference.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      await result.fold(
        (failure) => fail('Should not return failure'),
        (stream) async {
          await expectLater(
            stream,
            emitsError(isA<Exception>()),
          );
        },
      );
    });

    test('should return failure on FirebaseException', () async {
      // Arrange
      when(mockDocumentReference.snapshots()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return stream'),
      );
    });

    test('should return failure on generic exception', () async {
      // Arrange
      when(
        mockDocumentReference.snapshots(),
      ).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return stream'),
      );
    });

    test('should preserve EMR data integrity through stream', () async {
      // Arrange
      final emr = EMRFixtures.createCompleteNutritionEMR();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockDocSnapshot.exists).thenReturn(true);
      when(
        mockDocSnapshot.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(emr));
      when(
        mockDocumentReference.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));

      // Act
      final result = await repository.watchEMR(testEmrId);

      // Assert
      expect(result.isRight(), true);
      await result.fold(
        (failure) => fail('Should not return failure'),
        (stream) async {
          await expectLater(
            stream,
            emits(
              predicate<dynamic>((entity) {
                return entity.id == emr.id &&
                    entity.patientId == emr.patientId &&
                    entity.nutritionistId == emr.nutritionistId &&
                    entity.appointmentId == emr.appointmentId &&
                    entity.weightValue == emr.weightValue;
              }),
            ),
          );
        },
      );
    });
  });

  group('NutritionEMRRepository - Additional Edge Cases', () {
    test('saveEMR should handle FirebaseException correctly', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalNutritionEMR();

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockDocumentReference.set(any, any)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
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
    });

    test('getEMRByAppointmentId should handle FirebaseException', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Service unavailable',
        ),
      );

      // Act
      final result = await repository.getEMRByAppointmentId('apt_test_001');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return EMR'),
      );
    });

    test('getEMRsByPatientId should handle FirebaseException', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'deadline-exceeded',
          message: 'Deadline exceeded',
        ),
      );

      // Act
      final result = await repository.getEMRsByPatientId('patient_test_001');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return EMRs'),
      );
    });

    test('lockEMR should handle FirebaseException', () async {
      // Arrange
      when(mockDocumentReference.update(any)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Document not found',
        ),
      );

      // Act
      final result = await repository.lockEMR('nutrition_emr_001');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('getEMRsByPatientId should filter out invalid documents', () async {
      // Arrange
      final validEmr = EMRFixtures.createCompleteNutritionEMR();

      final mockValidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(
        mockValidDoc.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(validEmr));

      final mockInvalidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockInvalidDoc.id).thenReturn('invalid_doc_id');
      when(mockInvalidDoc.data()).thenThrow(Exception('Invalid data'));

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.orderBy(any, descending: anyNamed('descending')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockValidDoc, mockInvalidDoc]);

      // Act
      final result = await repository.getEMRsByPatientId('patient_test_001');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (emrs) {
          // Should only contain the valid EMR, invalid one filtered out
          expect(emrs.length, 1);
          expect(emrs.first.id, validEmr.id);
        },
      );
    });

    test('saveEMR should verify audit log is updated', () async {
      // Arrange
      final emr = EMRFixtures.createMinimalNutritionEMR();

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockDocumentReference.set(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(emr);

      // Assert
      expect(result.isRight(), true);
      verify(
        mockDocumentReference.set(
          argThat(
            predicate<Map<String, dynamic>>((data) {
              // Verify audit log exists and has entries
              return data.containsKey('auditLog') &&
                  (data['auditLog'] as List).isNotEmpty;
            }),
          ),
          any,
        ),
      ).called(1);
    });

    test('saveEMR should increment edit count on update', () async {
      // Arrange
      final existingEmr = EMRFixtures.createMinimalNutritionEMR();
      final updatedEmr = existingEmr.copyWith(weightValue: 72);

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.exists).thenReturn(true);
      when(
        mockDoc.data(),
      ).thenReturn(NutritionEMRModel.entityToFirestore(existingEmr));

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      when(mockDocumentReference.set(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.saveEMR(updatedEmr);

      // Assert
      expect(result.isRight(), true);
      verify(
        mockDocumentReference.set(
          argThat(
            predicate<Map<String, dynamic>>((data) {
              // Verify edit count is incremented
              return data.containsKey('editCount') && data['editCount'] == 1;
            }),
          ),
          any,
        ),
      ).called(1);
    });
  });
}
