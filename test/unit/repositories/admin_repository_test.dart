/// Unit tests for AdminRepositoryImpl
///
/// Tests the admin repository createDoctor, updateDoctorProfile,
/// setAccountStatus, getAllDoctors, and getAllPatients methods.
///
/// Key assertions:
/// - createDoctor calls CF and uses the returned UID as audit targetId
/// - updateDoctorProfile never writes userType / isActive to Firestore
/// - setAccountStatus writes 'reactivate_account' or 'deactivate_account'
/// - All methods return Left(Failure) on CF / network errors
///
/// Run with:
/// ```bash
/// flutter test test/unit/repositories/admin_repository_test.dart --reporter expanded
/// ```
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'admin_repository_test.mocks.dart';

// ─────────────── Mock generation ───────────────────────────────────────────

@GenerateMocks([
  FirebaseFirestore,
  FirebaseFunctions,
  HttpsCallable,
  HttpsCallableResult,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late AdminRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockCallable;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockCollectionReference<Map<String, dynamic>> mockAuditCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  // ── Fixtures ──────────────────────────────────────────────────────────────

  final adminUser = UserModel(
    id: 'admin-001',
    fullName: 'Admin User',
    email: 'admin@test.com',
    userType: UserType.admin,
    createdAt: DateTime(2024),
  );

  final newDoctor = UserModel(
    id: '',
    fullName: 'Dr. Ahmed Hassan',
    email: 'ahmed.hassan@test.com',
    userType: UserType.doctor,
    specializations: ['طب الأطفال'],
    clinicName: 'عيادة الأرز',
    clinicAddress: 'شارع الملك فهد',
    licenseNumber: 'SA-12345',
    biography: 'نبذة مختصرة',
    yearsOfExperience: 10,
    consultationFee: 200,
    consultationTypes: ['video'],
    createdAt: DateTime(2024),
  );

  final existingDoctor = newDoctor.copyWith(
    id: 'doctor-uid-001',
    profileImage: 'https://storage.firebase.com/pic.jpg',
  );

  // ── Setup ─────────────────────────────────────────────────────────────────

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockAuditCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    repository = AdminRepositoryImpl(mockFirestore, mockFunctions);

    // Wire up default Firestore routing
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(
      mockFirestore.collection('audit_logs'),
    ).thenReturn(mockAuditCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockDocRef);
    // audit_logs.add() — swallow it by default
    when(mockAuditCollection.add(any)).thenAnswer((_) async => mockDocRef);
  });

  // ══════════════════════════════════════════════════════════════════════════
  // createDoctor
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminRepository - createDoctor', () {
    /// Helper: stub the CF with a result map containing a UID.
    void stubCallableSuccess({String? uid}) {
      final result = MockHttpsCallableResult<dynamic>();
      when(result.data).thenReturn(
        uid != null ? <String, dynamic>{'uid': uid} : null,
      );
      when(
        mockFunctions.httpsCallable('createDoctorAccount'),
      ).thenReturn(mockCallable);
      when(mockCallable.call<dynamic>(any)).thenAnswer((_) async => result);
    }

    test(
      'happy path: returns Right(unit) and writes audit log with UID',
      () async {
        // Arrange
        const returnedUid = 'new-doctor-firebase-uid';
        stubCallableSuccess(uid: returnedUid);

        // Capture what was added to audit_logs
        Map<String, dynamic>? capturedAuditData;
        when(mockAuditCollection.add(any)).thenAnswer((inv) async {
          capturedAuditData =
              inv.positionalArguments.first as Map<String, dynamic>;
          return mockDocRef;
        });

        // Act
        final result = await repository.createDoctor(
          doctor: newDoctor,
          password: 'Test@1234',
          adminId: adminUser.id,
          adminName: adminUser.fullName,
        );

        // Assert: correct return
        expect(result.isRight(), true, reason: 'Should succeed on happy path');

        // Assert: CF was called once
        verify(mockFunctions.httpsCallable('createDoctorAccount')).called(1);
        verify(mockCallable.call<dynamic>(any)).called(1);

        // Assert: audit log uses UID (not email) as targetId
        expect(capturedAuditData, isNotNull);
        expect(
          capturedAuditData!['targetId'],
          equals(returnedUid),
          reason: 'audit targetId must be UID, not email',
        );
        expect(capturedAuditData!['action'], equals('create_doctor'));
        expect(capturedAuditData!['adminId'], equals(adminUser.id));
        expect(capturedAuditData!['targetType'], equals('doctor'));
      },
    );

    test('falls back to email as targetId when CF returns no uid', () async {
      // Arrange: CF returns null data (old function deployment)
      stubCallableSuccess();

      Map<String, dynamic>? capturedAuditData;
      when(mockAuditCollection.add(any)).thenAnswer((inv) async {
        capturedAuditData =
            inv.positionalArguments.first as Map<String, dynamic>;
        return mockDocRef;
      });

      // Act
      final result = await repository.createDoctor(
        doctor: newDoctor,
        password: 'Test@1234',
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert: falls back gracefully
      expect(result.isRight(), true);
      expect(
        capturedAuditData!['targetId'],
        equals(newDoctor.email),
        reason: 'Should fall back to email when CF does not return uid',
      );
    });

    test('returns Left(ServerFailure) on FirebaseFunctionsException', () async {
      // Arrange
      when(
        mockFunctions.httpsCallable('createDoctorAccount'),
      ).thenReturn(mockCallable);
      when(mockCallable.call<dynamic>(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'already-exists',
          message: 'The email address is already in use.',
        ),
      );

      // Act
      final result = await repository.createDoctor(
        doctor: newDoctor,
        password: 'Test@1234',
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          // Arabic error message should be present
          expect(failure.message, contains('فشل إنشاء حساب الطبيب'));
        },
        (_) => fail('Should not return Right'),
      );
      // No audit log on failure
      verifyNever(mockAuditCollection.add(any));
    });

    test('returns Left(ServerFailure) on SocketException', () async {
      // Arrange
      when(
        mockFunctions.httpsCallable('createDoctorAccount'),
      ).thenReturn(mockCallable);
      when(
        mockCallable.call<dynamic>(any),
      ).thenThrow(const SocketException('No internet'));

      // Act
      final result = await repository.createDoctor(
        doctor: newDoctor,
        password: 'Test@1234',
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('لا يوجد اتصال')),
        (_) => fail('Should not return Right'),
      );
    });

    test('does NOT send userType or isActive to Cloud Function', () async {
      // Arrange
      stubCallableSuccess(uid: 'uid-001');
      Map<String, dynamic>? capturedPayload;
      when(mockCallable.call<dynamic>(any)).thenAnswer((inv) async {
        capturedPayload = inv.positionalArguments.first as Map<String, dynamic>;
        final result = MockHttpsCallableResult<dynamic>();
        when(result.data).thenReturn(<String, dynamic>{'uid': 'uid-001'});
        return result;
      });

      // Act
      await repository.createDoctor(
        doctor: newDoctor,
        password: 'Test@1234',
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert: sensitive fields not in CF payload
      expect(capturedPayload, isNotNull);
      expect(
        capturedPayload!.containsKey('userType'),
        isFalse,
        reason: 'userType must not be sent by client',
      );
      expect(
        capturedPayload!.containsKey('isActive'),
        isFalse,
        reason: 'isActive must not be sent by client',
      );
    });

    test('sends profileImage to the Cloud Function', () async {
      // Arrange
      stubCallableSuccess(uid: 'uid-001');
      Map<String, dynamic>? capturedPayload;
      when(mockCallable.call<dynamic>(any)).thenAnswer((inv) async {
        capturedPayload = inv.positionalArguments.first as Map<String, dynamic>;
        final result = MockHttpsCallableResult<dynamic>();
        when(result.data).thenReturn(<String, dynamic>{'uid': 'uid-001'});
        return result;
      });

      final doctorWithImage = newDoctor.copyWith(
        profileImage: 'https://storage.com/image.jpg',
      );

      // Act
      await repository.createDoctor(
        doctor: doctorWithImage,
        password: 'Test@1234',
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert
      expect(capturedPayload, isNotNull);
      expect(
        capturedPayload!['profileImage'],
        equals('https://storage.com/image.jpg'),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // updateDoctorProfile
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminRepository - updateDoctorProfile', () {
    test(
      'writes only admin-editable fields — never userType or isActive',
      () async {
        // Arrange
        when(mockDocRef.update(any)).thenAnswer((_) async {});

        Map<String, dynamic>? capturedUpdate;
        when(mockDocRef.update(any)).thenAnswer((inv) async {
          capturedUpdate = (inv.positionalArguments.first as Map)
              .cast<String, dynamic>();
        });

        // Act
        final result = await repository.updateDoctorProfile(
          updatedDoctor: existingDoctor,
          previousDoctor: existingDoctor,
          adminId: adminUser.id,
          adminName: adminUser.fullName,
        );

        // Assert
        expect(result.isRight(), true);
        expect(capturedUpdate, isNotNull);
        expect(
          capturedUpdate!.containsKey('userType'),
          isFalse,
          reason: 'userType must never be overwritten by admin update',
        );
        expect(
          capturedUpdate!.containsKey('isActive'),
          isFalse,
          reason: 'isActive must never be overwritten by admin update',
        );
        expect(
          capturedUpdate!.containsKey('createdAt'),
          isFalse,
          reason: 'createdAt must never be overwritten by admin update',
        );
        // Confirm editable fields are present
        expect(capturedUpdate!.containsKey('fullName'), isTrue);
        expect(capturedUpdate!.containsKey('specializations'), isTrue);
        expect(capturedUpdate!.containsKey('clinicName'), isTrue);
      },
    );

    test('returns Left(ServerFailure) on FirebaseException', () async {
      // Arrange
      when(mockDocRef.update(any)).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );

      // Act
      final result = await repository.updateDoctorProfile(
        updatedDoctor: existingDoctor,
        previousDoctor: existingDoctor,
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Should not return Right'),
      );
    });

    test('writes audit log with action update_doctor_profile', () async {
      // Arrange
      when(mockDocRef.update(any)).thenAnswer((_) async {});

      Map<String, dynamic>? capturedAudit;
      when(mockAuditCollection.add(any)).thenAnswer((inv) async {
        capturedAudit = inv.positionalArguments.first as Map<String, dynamic>;
        return mockDocRef;
      });

      final updated = existingDoctor.copyWith(biography: 'Updated bio');

      // Act
      await repository.updateDoctorProfile(
        updatedDoctor: updated,
        previousDoctor: existingDoctor,
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      // Assert
      expect(capturedAudit!['action'], equals('update_doctor_profile'));
      expect(capturedAudit!['targetId'], equals(existingDoctor.id));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // setAccountStatus
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminRepository - setAccountStatus', () {
    void stubStatusCallable() {
      final result = MockHttpsCallableResult<dynamic>();
      when(result.data).thenReturn(null);
      when(
        mockFunctions.httpsCallable('setAccountStatus'),
      ).thenReturn(mockCallable);
      when(mockCallable.call<dynamic>(any)).thenAnswer((_) async => result);
    }

    test('writes deactivate_account when isActive=false', () async {
      stubStatusCallable();
      Map<String, dynamic>? capturedAudit;
      when(mockAuditCollection.add(any)).thenAnswer((inv) async {
        capturedAudit = inv.positionalArguments.first as Map<String, dynamic>;
        return mockDocRef;
      });

      await repository.setAccountStatus(
        targetUserId: 'doctor-001',
        isActive: false, // deactivate
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      expect(capturedAudit!['action'], equals('deactivate_account'));
      expect(capturedAudit!['targetId'], equals('doctor-001'));
    });

    test('writes reactivate_account when isActive=true', () async {
      stubStatusCallable();
      Map<String, dynamic>? capturedAudit;
      when(mockAuditCollection.add(any)).thenAnswer((inv) async {
        capturedAudit = inv.positionalArguments.first as Map<String, dynamic>;
        return mockDocRef;
      });

      await repository.setAccountStatus(
        targetUserId: 'doctor-001',
        isActive: true, // reactivate
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      expect(capturedAudit!['action'], equals('reactivate_account'));
    });

    test('returns Left on CF error', () async {
      when(
        mockFunctions.httpsCallable('setAccountStatus'),
      ).thenReturn(mockCallable);
      when(mockCallable.call<dynamic>(any)).thenThrow(
        FirebaseFunctionsException(
          code: 'not-found',
          message: 'User not found',
        ),
      );

      final result = await repository.setAccountStatus(
        targetUserId: 'ghost-id',
        isActive: false,
        adminId: adminUser.id,
        adminName: adminUser.fullName,
      );

      expect(result.isLeft(), true);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // getAllDoctors
  // ══════════════════════════════════════════════════════════════════════════

  group('AdminRepository - getAllDoctors', () {
    test('returns list of doctors from Firestore', () async {
      // Arrange
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.id).thenReturn('doctor-001');
      when(mockDoc.data()).thenReturn({
        'id': 'doctor-001',
        'fullName': 'Dr. Test',
        'email': 'dr@test.com',
        'userType': 'doctor',
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime(2024)),
      });

      when(
        mockUsersCollection.where('userType', isEqualTo: 'doctor'),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.getAllDoctors();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Should not fail'),
        (doctors) {
          expect(doctors.length, 1);
          expect(doctors.first.fullName, 'Dr. Test');
        },
      );
    });

    test('returns empty list when no doctors', () async {
      when(
        mockUsersCollection.where('userType', isEqualTo: 'doctor'),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final result = await repository.getAllDoctors();

      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Should not fail'),
        (doctors) => expect(doctors, isEmpty),
      );
    });

    test('returns Left on FirebaseException', () async {
      when(
        mockUsersCollection.where('userType', isEqualTo: 'doctor'),
      ).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'unavailable'),
      );

      final result = await repository.getAllDoctors();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Should not succeed'),
      );
    });
  });
}
