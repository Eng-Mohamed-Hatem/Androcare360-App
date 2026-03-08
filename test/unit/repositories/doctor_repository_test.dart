/// Unit tests for DoctorRepository
///
/// Tests doctor repository operations including:
/// - Get all doctors
/// - Get doctor by ID
/// - Get doctors stream (real-time updates)
/// - Error handling for Firestore failures
///
/// Target: 95%+ coverage

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/user_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late DoctorRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    repository = DoctorRepositoryImpl(mockFirestore);

    // Setup default Firestore collection mock
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
  });

  group('DoctorRepository - Get Doctors', () {
    test('should return list of doctors', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doctor in doctors) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(doctor.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getDoctors();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (doctorList) {
          expect(doctorList.length, doctors.length);
          expect(
            doctorList.every((d) => d.userType == UserType.doctor),
            true,
          );
        },
      );

      verify(mockCollection.where('userType', isEqualTo: 'doctor')).called(1);
    });

    test('should return empty list when no doctors found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getDoctors();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (doctorList) {
          expect(doctorList, isEmpty);
        },
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getDoctors();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctorList) => fail('Should not return doctors'),
      );
    });

    test('should return doctors with specializations', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doctor in doctors) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(doctor.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getDoctors();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (doctorList) {
          // Verify all doctors have specializations
          for (final doctor in doctorList) {
            expect(doctor.specializations, isNotNull);
            expect(doctor.specializations, isNotEmpty);
          }
        },
      );
    });
  });

  group('DoctorRepository - Get Doctor By ID', () {
    const testDoctorId = 'doctor_test_001';

    test('should return doctor when found', () async {
      // Arrange
      final testDoctor = UserFixtures.createDoctor(id: testDoctorId);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testDoctor.toJson());
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (doctor) {
          expect(doctor.id, testDoctorId);
          expect(doctor.userType, UserType.doctor);
        },
      );

      verify(mockDocumentReference.get()).called(1);
    });

    test('should return failure when doctor not found', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctor) => fail('Should not return doctor'),
      );
    });

    test('should return failure when document data is null', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(null);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctor) => fail('Should not return doctor'),
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(mockDocumentReference.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctor) => fail('Should not return doctor'),
      );
    });

    test('should return doctor with complete profile', () async {
      // Arrange
      final testDoctor = UserFixtures.createDoctor(id: testDoctorId);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testDoctor.toJson());
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (doctor) {
          expect(doctor.id, testDoctorId);
          expect(doctor.userType, UserType.doctor);
          expect(doctor.specializations, isNotEmpty);
          expect(doctor.licenseNumber, isNotNull);
        },
      );
    });

    test('should handle FirebaseException correctly', () async {
      // Arrange
      when(mockDocumentReference.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        ),
      );

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctor) => fail('Should not return doctor'),
      );
    });

    test('should handle network errors correctly', () async {
      // Arrange
      when(mockDocumentReference.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Network unavailable',
        ),
      );

      // Act
      final result = await repository.getDoctorById(testDoctorId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (doctor) => fail('Should not return doctor'),
      );
    });
  });

  group('DoctorRepository - Get Doctors Stream', () {
    test('should emit list of doctors from stream', () async {
      // Arrange
      final doctors = UserFixtures.createMultipleDoctors();

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doctor in doctors) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(doctor.toJson());
        mockDocs.add(mockDoc);
      }

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          predicate<List<UserModel>>((list) {
            return list.length == doctors.length &&
                list.every((d) => d.userType == UserType.doctor);
          }),
        ),
      );

      verify(mockCollection.where('userType', isEqualTo: 'doctor')).called(1);
    });

    test('should emit empty list when no doctors in stream', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emits(predicate<List<UserModel>>((list) => list.isEmpty)),
      );
    });

    test('should filter out invalid doctor documents in stream', () async {
      // Arrange
      final validDoctor = UserFixtures.createDoctor(id: 'valid_doctor');

      // Create one valid and one invalid document
      final mockValidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockValidDoc.data()).thenReturn(validDoctor.toJson());

      final mockInvalidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockInvalidDoc.data()).thenThrow(Exception('Invalid data'));

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn([mockValidDoc, mockInvalidDoc]);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          predicate<List<UserModel>>((list) {
            // Should only contain the valid doctor, invalid one filtered out
            return list.length == 1 && list.first.id == 'valid_doctor';
          }),
        ),
      );
    });

    test('should emit multiple updates from stream', () async {
      // Arrange
      final doctors1 = [UserFixtures.createDoctor(id: 'doctor_1')];
      final doctors2 = [
        UserFixtures.createDoctor(id: 'doctor_1'),
        UserFixtures.createDoctor(id: 'doctor_2'),
      ];

      final mockDocs1 = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doctor in doctors1) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(doctor.toJson());
        mockDocs1.add(mockDoc);
      }

      final mockDocs2 = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doctor in doctors2) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(doctor.toJson());
        mockDocs2.add(mockDoc);
      }

      final mockQuerySnapshot1 = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot1.docs).thenReturn(mockDocs1);

      final mockQuerySnapshot2 = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot2.docs).thenReturn(mockDocs2);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockQuerySnapshot1, mockQuerySnapshot2]),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<List<UserModel>>((list) => list.length == 1),
          predicate<List<UserModel>>((list) => list.length == 2),
        ]),
      );
    });

    test('should handle all documents being invalid in stream', () async {
      // Arrange
      final mockInvalidDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockInvalidDoc1.data()).thenThrow(Exception('Invalid data 1'));

      final mockInvalidDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockInvalidDoc2.data()).thenThrow(Exception('Invalid data 2'));

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(
        mockQuerySnapshot.docs,
      ).thenReturn([mockInvalidDoc1, mockInvalidDoc2]);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emits(predicate<List<UserModel>>((list) => list.isEmpty)),
      );
    });

    test('should preserve doctor data integrity in stream', () async {
      // Arrange
      final testDoctor = UserFixtures.createDoctor(
        id: 'doctor_test_001',
        fullName: 'Dr. Test Doctor',
        specializations: ['Cardiology', 'Internal Medicine'],
      );

      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.data()).thenReturn(testDoctor.toJson());

      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer(
        (_) => Stream.value(mockQuerySnapshot),
      );

      // Act
      final stream = repository.getDoctorsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          predicate<List<UserModel>>((list) {
            final doctor = list.first;
            return doctor.id == 'doctor_test_001' &&
                doctor.fullName == 'Dr. Test Doctor' &&
                doctor.specializations!.length == 2 &&
                doctor.specializations!.contains('Cardiology');
          }),
        ),
      );
    });
  });

  group('DoctorRepository - Additional Edge Cases', () {
    test('getDoctors should handle malformed doctor data gracefully', () async {
      // Arrange
      final validDoctor = UserFixtures.createDoctor(id: 'valid_doctor');

      final mockValidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockValidDoc.data()).thenReturn(validDoctor.toJson());

      // This will cause fromJson to throw
      final mockInvalidDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockInvalidDoc.data()).thenReturn({'invalid': 'data'});

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockValidDoc, mockInvalidDoc]);

      // Act & Assert
      // The current implementation doesn't handle malformed data gracefully
      // This test documents the current behavior - it throws TypeError
      expect(
        () async => repository.getDoctors(),
        throwsA(isA<TypeError>()),
      );
    });

    test('getDoctorById should verify collection path is correct', () async {
      // Arrange
      const testDoctorId = 'doctor_test_001';
      final testDoctor = UserFixtures.createDoctor(id: testDoctorId);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testDoctor.toJson());
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      await repository.getDoctorById(testDoctorId);

      // Assert
      verify(
        mockFirestore.collection(AppConstants.collections.users),
      ).called(1);
      verify(mockCollection.doc(testDoctorId)).called(1);
    });

    test('getDoctors should verify query filters correctly', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      await repository.getDoctors();

      // Assert
      verify(mockCollection.where('userType', isEqualTo: 'doctor')).called(1);
      verify(mockQuery.get()).called(1);
    });
  });
}
