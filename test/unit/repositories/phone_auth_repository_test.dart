import 'package:elajtech/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';
import '../../fixtures/user_fixtures.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockTokenRefreshService mockTokenRefreshService;
  late MockFCMService mockFCMService;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockTokenRefreshService = MockTokenRefreshService();
    mockFCMService = MockFCMService();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockUser = MockUser();

    repository = AuthRepositoryImpl(
      mockFirebaseAuth,
      mockFirestore,
      mockTokenRefreshService,
      mockFCMService,
    );

    // Setup default Firestore mocks
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
  });

  group('AuthRepository - verifyPhoneNumber', () {
    const testPhoneNumber = '+201111111111';

    test('should initiate phone verification via Firebase Auth', () async {
      // Arrange
      const testVerificationId = 'v123';
      const testResendToken = 123;

      when(
        mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: anyNamed('phoneNumber'),
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          forceResendingToken: anyNamed('forceResendingToken'),
        ),
      ).thenAnswer((Invocation invocation) async {
        final codeSent = invocation.namedArguments[#codeSent] as PhoneCodeSent;
        codeSent(testVerificationId, testResendToken);
      });

      // Act
      final result = await repository.verifyPhoneNumber(
        phoneNumber: testPhoneNumber,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: testPhoneNumber,
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
          forceResendingToken: anyNamed('forceResendingToken'),
        ),
      ).called(1);
    });
  });

  group('AuthRepository - signInWithPhoneNumber', () {
    const testVerificationId = 'v123';
    const testSmsCode = '123456';
    const testUserId = 'u123';

    test('should return UserModel on successful sign in', () async {
      // Arrange
      final testUser = UserFixtures.createPatient(id: testUserId);
      final mockCredential = MockUserCredential();

      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testUser.toJson());
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
      when(mockFCMService.getToken()).thenAnswer((_) async => 'fcm_token');

      // Act
      final result = await repository.signInWithPhoneNumber(
        verificationId: testVerificationId,
        smsCode: testSmsCode,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should succeed'),
        (r) => expect(r.id, testUserId),
      );
    });

    test(
      'should return AuthFailure when user document does not exist',
      () async {
        // Arrange
        final mockCredential = MockUserCredential();

        when(
          mockFirebaseAuth.signInWithCredential(any),
        ).thenAnswer((_) async => mockCredential);
        when(mockCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(testUserId);

        when(
          mockDocumentReference.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // Act
        final result = await repository.signInWithPhoneNumber(
          verificationId: testVerificationId,
          smsCode: testSmsCode,
        );

        // Assert
        expect(result.isLeft(), true);
        verify(mockFirebaseAuth.signOut()).called(1);
      },
    );

    test('should map Firebase Auth errors to localized Arabic', () async {
      // Arrange
      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenThrow(FirebaseAuthException(code: 'invalid-verification-code'));

      // Act
      final result = await repository.signInWithPhoneNumber(
        verificationId: testVerificationId,
        smsCode: 'wrong',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, contains('غير صحيح')), // "كود التحقق غير صحيح"
        (r) => fail('Should fail'),
      );
    });
  });
}
