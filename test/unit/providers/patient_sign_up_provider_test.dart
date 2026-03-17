import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/user_fixtures.dart';
import 'patient_sign_up_provider_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  final getIt = GetIt.instance;

  setUp(() async {
    mockAuthRepository = MockAuthRepository();

    // Register mock in GetIt
    if (getIt.isRegistered<AuthRepository>()) {
      await getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(mockAuthRepository);
  });

  tearDown(() async {
    if (getIt.isRegistered<AuthRepository>()) {
      await getIt.unregister<AuthRepository>();
    }
  });

  group('AuthProvider - Patient Sign Up Flow', () {
    const testEmail = 'patient@test.com';
    const testPassword = 'password123';
    const testFullName = 'Patient Name';
    const testPhone = '+966512345678';
    const testVerificationId = 'v123';

    test(
      'startSignUpWithEmailAndPhone should update state on success',
      () async {
        // Arrange
        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.startSignUpWithEmailAndPhone(
            email: testEmail,
            password: testPassword,
            fullName: testFullName,
            phoneNumber: testPhone,
          ),
        ).thenAnswer((_) async => const Right(testVerificationId));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act
        await container
            .read(authProvider.notifier)
            .startSignUpWithEmailAndPhone(
              email: testEmail,
              password: testPassword,
              fullName: testFullName,
              phoneNumber: testPhone,
            );

        // Assert
        final state = container.read(authProvider);
        expect(state.signUpVerificationId, testVerificationId);
        expect(state.signUpLoading, false);
        expect(state.signUpError, isNull);
      },
    );

    test('startSignUpWithEmailAndPhone should handle failure', () async {
      // Arrange
      const errorMessage = 'Email already in use';
      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.startSignUpWithEmailAndPhone(
          email: testEmail,
          password: testPassword,
          fullName: testFullName,
          phoneNumber: testPhone,
        ),
      ).thenAnswer((_) async => const Left(AuthFailure(errorMessage)));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .startSignUpWithEmailAndPhone(
            email: testEmail,
            password: testPassword,
            fullName: testFullName,
            phoneNumber: testPhone,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.signUpVerificationId, isNull);
      expect(state.signUpLoading, false);
      expect(state.signUpError, errorMessage);
    });

    test('confirmSignUpOtp should update state on success', () async {
      // Arrange
      const smsCode = '123456';
      final user = UserFixtures.createPatient(email: testEmail);

      // Initial state with verificationId
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            (ref) => AuthNotifier(mockAuthRepository)
              ..state = AuthState(
                signUpVerificationId: testVerificationId,
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.confirmSignUpAndCreateProfile(
          verificationId: testVerificationId,
          smsCode: smsCode,
        ),
      ).thenAnswer((_) async => Right(user));

      // Act
      await container
          .read(authProvider.notifier)
          .confirmSignUpOtp(smsCode: smsCode);

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, user);
      expect(state.signUpLoading, false);
      expect(state.signUpError, isNull);
    });

    test('confirmSignUpOtp should handle failure', () async {
      // Arrange
      const smsCode = 'wrong';
      const errorMessage = 'كود التحقق غير صحيح';

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            (ref) => AuthNotifier(mockAuthRepository)
              ..state = AuthState(
                signUpVerificationId: testVerificationId,
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.confirmSignUpAndCreateProfile(
          verificationId: testVerificationId,
          smsCode: smsCode,
        ),
      ).thenAnswer((_) async => const Left(AuthFailure(errorMessage)));

      // Act
      await container
          .read(authProvider.notifier)
          .confirmSignUpOtp(smsCode: smsCode);

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.signUpLoading, false);
      expect(state.signUpError, errorMessage);
    });
  });
}
