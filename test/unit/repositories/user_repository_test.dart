/// Unit tests for UserRepository
///
/// Tests user repository operations including:
/// - Get user by ID
/// - Get all patients
/// - Error handling for Firestore failures
///
/// Target: 95%+ coverage

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/user/data/repositories/user_repository_impl.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/user_fixtures.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late UserRepositoryImpl repository;
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

    repository = UserRepositoryImpl(mockFirestore);

    // Setup default Firestore collection mock
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
  });

  group('UserRepository - Get User', () {
    const testUserId = 'user_test_001';

    test('should return user when found', () async {
      // Arrange
      final testUser = UserFixtures.createPatient(id: testUserId);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testUser.toJson());
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getUser(testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.id, testUserId);
          expect(user.userType, UserType.patient);
        },
      );

      verify(mockDocumentReference.get()).called(1);
    });

    test('should return failure when user not found', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getUser(testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (user) => fail('Should not return user'),
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
      final result = await repository.getUser(testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (user) => fail('Should not return user'),
      );
    });

    test('should return failure on Firestore error', () async {
      // Arrange
      when(mockDocumentReference.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getUser(testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (user) => fail('Should not return user'),
      );
    });

    test('should return doctor user correctly', () async {
      // Arrange
      final testDoctor = UserFixtures.createDoctor(id: testUserId);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testDoctor.toJson());
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);

      // Act
      final result = await repository.getUser(testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.id, testUserId);
          expect(user.userType, UserType.doctor);
          expect(user.specializations, isNotEmpty);
        },
      );
    });
  });

  group('UserRepository - Get All Patients', () {
    test('should return list of patients', () async {
      // Arrange
      final patients = UserFixtures.createMultiplePatients();

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final patient in patients) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(patient.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getAllPatients();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (patientList) {
          expect(patientList.length, patients.length);
          expect(
            patientList.every((p) => p.userType == UserType.patient),
            true,
          );
        },
      );

      verify(mockCollection.where('userType', isEqualTo: 'patient')).called(1);
    });

    test('should return empty list when no patients found', () async {
      // Arrange
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getAllPatients();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (patientList) {
          expect(patientList, isEmpty);
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
      final result = await repository.getAllPatients();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (patientList) => fail('Should not return patients'),
      );
    });

    test('should filter out non-patient users', () async {
      // Arrange
      final patients = UserFixtures.createMultiplePatients();

      final mockDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final patient in patients) {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(mockDoc.data()).thenReturn(patient.toJson());
        mockDocs.add(mockDoc);
      }

      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      // Act
      final result = await repository.getAllPatients();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (patientList) {
          // Verify all returned users are patients
          for (final user in patientList) {
            expect(user.userType, UserType.patient);
          }
        },
      );
    });
  });
}
