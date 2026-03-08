import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockTokenRefreshService mockTokenRefreshService;
  late MockFCMService mockFCMService;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockTokenRefreshService = MockTokenRefreshService();
    mockFCMService = MockFCMService();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();

    repository = AuthRepositoryImpl(
      mockFirebaseAuth,
      mockFirestore,
      mockTokenRefreshService,
      mockFCMService,
    );

    // Default Firestore mocks
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
  });

  group('AuthRepository - startSignUpWithEmailAndPhone', () {
    const testEmail = 'patient@test.com';
    const testPassword = 'password123';
    const testFullName = 'Patient Name';
    const testPhone = '+201111111111';
    const testVerificationId = 'v123';

    setUp(() {
      // Setup successful phone uniqueness check (no docs found)
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
    });

    test('should return verificationId on happy path', () async {
      // Arrange
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('u123');
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});

      // Mock verifyPhoneNumber codeSent callback
      when(
        mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: testPhone,
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          forceResendingToken: anyNamed('forceResendingToken'),
        ),
      ).thenAnswer((Invocation inv) async {
        final codeSent = inv.namedArguments[#codeSent] as PhoneCodeSent;
        codeSent(testVerificationId, 123);
      });

      // Act
      final result = await repository.startSignUpWithEmailAndPhone(
        email: testEmail,
        password: testPassword,
        fullName: testFullName,
        phoneNumber: testPhone,
      );

      // Assert
      expect(result, const Right<Failure, String>(testVerificationId));
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
      verify(mockUser.updateDisplayName(testFullName)).called(1);
    });

    test('should return Left if phone number is already in use', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(
        mockCollection.where('phoneNumber', isEqualTo: testPhone),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      // Act
      final result = await repository.startSignUpWithEmailAndPhone(
        email: testEmail,
        password: testPassword,
        fullName: testFullName,
        phoneNumber: testPhone,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('مستخدم بالفعل')),
        (_) => fail('Should have failed'),
      );
      verifyNever(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    test('should roll back (delete user) if verifyPhoneNumber fails', () async {
      // Arrange
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('u123');
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});
      when(mockUser.delete()).thenAnswer((_) async => {});

      // Mock verifyPhoneNumber failure via verificationFailed
      when(
        mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: testPhone,
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          forceResendingToken: anyNamed('forceResendingToken'),
        ),
      ).thenAnswer((Invocation inv) async {
        final failed =
            inv.namedArguments[#verificationFailed] as PhoneVerificationFailed;
        failed(FirebaseAuthException(code: 'too-many-requests'));
      });

      // Act
      final result = await repository.startSignUpWithEmailAndPhone(
        email: testEmail,
        password: testPassword,
        fullName: testFullName,
        phoneNumber: testPhone,
      );

      // Assert
      expect(result.isLeft(), true);
      verify(mockUser.delete()).called(1);
    });
  });

  group('AuthRepository - confirmSignUpAndCreateProfile', () {
    const testVerificationId = 'v123';
    const testSmsCode = '123456';
    const testEmail = 'patient@test.com';
    const testPassword = 'password123';
    const testFullName = 'Patient Name';
    const testPhone = '+201111111111';

    setUp(() async {
      // 1. Setup Step 1 to populate _pendingSignUpData
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      when(
        mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('u123');
      when(mockUser.email).thenReturn(testEmail);
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});

      when(
        mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: testPhone,
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          forceResendingToken: anyNamed('forceResendingToken'),
        ),
      ).thenAnswer((Invocation inv) async {
        final codeSent = inv.namedArguments[#codeSent] as PhoneCodeSent;
        codeSent(testVerificationId, 123);
      });

      await repository.startSignUpWithEmailAndPhone(
        email: testEmail,
        password: testPassword,
        fullName: testFullName,
        phoneNumber: testPhone,
      );
    });

    test('should link phone and create Firestore doc on success', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        mockUser.linkWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockFCMService.getToken()).thenAnswer((_) async => 'fcm_123');
      when(mockDocumentReference.set(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.confirmSignUpAndCreateProfile(
        verificationId: testVerificationId,
        smsCode: testSmsCode,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should succeed'),
        (user) {
          expect(user.email, testEmail);
          expect(user.userType, UserType.patient);
          expect(user.phoneNumber, testPhone);
        },
      );
      verify(mockUser.linkWithCredential(any)).called(1);
      verify(mockDocumentReference.set(any)).called(1);
    });

    test('should roll back if linkWithCredential fails', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.linkWithCredential(any)).thenThrow(
        FirebaseAuthException(code: 'invalid-verification-code'),
      );
      when(mockUser.delete()).thenAnswer((_) async => {});

      // Act
      final result = await repository.confirmSignUpAndCreateProfile(
        verificationId: testVerificationId,
        smsCode: testSmsCode,
      );

      // Assert
      expect(result.isLeft(), true);
      verify(mockUser.delete()).called(1);
    });

    test('should roll back if Firestore write fails', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(
        mockUser.linkWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockFCMService.getToken()).thenAnswer((_) async => 'fcm_123');
      when(mockDocumentReference.set(any)).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );
      when(mockUser.delete()).thenAnswer((_) async => {});

      // Act
      final result = await repository.confirmSignUpAndCreateProfile(
        verificationId: testVerificationId,
        smsCode: testSmsCode,
      );

      // Assert
      expect(result.isLeft(), true);
      verify(mockUser.delete()).called(1);
    });
  });
}
