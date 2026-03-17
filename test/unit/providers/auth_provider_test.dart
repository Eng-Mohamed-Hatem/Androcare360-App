/// Unit tests for AuthProvider (Core Authentication Only)
///
/// Tests cover:
/// - Auth state initialization
/// - Login flow (success/failure)
/// - Registration flow
/// - Error handling (wrong password, network error, user not found)
/// - State transitions (authenticated ↔ unauthenticated)
/// - User type validation
///
/// EXPLICITLY SKIPPED (Platform-Dependent):
/// - Biometric authentication
/// - Secure storage operations
/// - Background service initialization
///
/// Target: Core auth state management only (~15 tests)

library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/auth/domain/models/phone_verification_data.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixtures/user_fixtures.dart';
import 'auth_provider_test.mocks.dart';

@GenerateMocks([
  AuthRepository,
])
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

  group('AuthProvider - State Initialization', () {
    test('should initialize with unauthenticated state', () {
      // Arrange
      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final state = container.read(authProvider);

      // Assert
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.isLoading, false);
    });
  });

  group('AuthProvider - Login Flow', () {
    test('should login successfully with valid credentials', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'password123';
      final user = UserFixtures.createPatient(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => Right(user));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, equals(user));
      expect(state.isLoading, false);
      expect(state.error, isNull);

      verify(
        mockAuthRepository.signIn(email: email, password: password),
      ).called(1);
    });

    test('should handle wrong password error', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'wrongpassword';
      const errorMessage = 'Wrong password';

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(errorMessage)),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.error, errorMessage);
    });

    test('should handle network error during login', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'password123';
      const errorMessage = 'No internet connection';

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(errorMessage)),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.error, errorMessage);
    });

    test('should handle user not found error', () async {
      // Arrange
      const email = 'nonexistent@test.com';
      const password = 'password123';
      const errorMessage = 'User not found';

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(errorMessage)),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.error, errorMessage);
    });

    test('should set loading state during login', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'password123';
      final user = UserFixtures.createPatient(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return Right(user);
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      final loginFuture = container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert loading state
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(authProvider).isLoading, true);

      // Wait for completion
      await loginFuture;
      expect(container.read(authProvider).isLoading, false);
    });
  });

  group('AuthProvider - Registration Flow', () {
    test('should register new user successfully', () async {
      // Arrange
      const email = 'newuser@test.com';
      const password = 'password123';
      const fullName = 'New User';
      final user = UserFixtures.createPatient(
        email: email,
        fullName: fullName,
      );

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          userType: UserType.patient,
          phoneNumber: anyNamed('phoneNumber'),
          licenseNumber: anyNamed('licenseNumber'),
          specializations: anyNamed('specializations'),
          clinicName: anyNamed('clinicName'),
          clinicAddress: anyNamed('clinicAddress'),
          consultationTypes: anyNamed('consultationTypes'),
          username: anyNamed('username'),
        ),
      ).thenAnswer((_) async => Right(user));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
            fullName: fullName,
            isRegistration: true,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, equals(user));
      expect(state.error, isNull);
    });

    test('should handle registration failure', () async {
      // Arrange
      const email = 'existing@test.com';
      const password = 'password123';
      const fullName = 'Existing User';
      const errorMessage = 'Email already in use';

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          userType: UserType.patient,
          phoneNumber: anyNamed('phoneNumber'),
          licenseNumber: anyNamed('licenseNumber'),
          specializations: anyNamed('specializations'),
          clinicName: anyNamed('clinicName'),
          clinicAddress: anyNamed('clinicAddress'),
          consultationTypes: anyNamed('consultationTypes'),
          username: anyNamed('username'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
            fullName: fullName,
            isRegistration: true,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.error, errorMessage);
    });
  });

  group('AuthProvider - User Type Validation', () {
    test('should reject login when user type mismatch', () async {
      // Arrange
      const email = 'doctor@test.com';
      const password = 'password123';
      final doctorUser = UserFixtures.createDoctor(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => Right(doctorUser));
      when(
        mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(unit));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act - Try to login as patient with doctor credentials
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.error, isNotNull);
      expect(state.error, contains('بيانات الدخول غير صحيحة'));

      verify(mockAuthRepository.signOut()).called(1);
    });

    test('should allow login when user type matches', () async {
      // Arrange
      const email = 'doctor@test.com';
      const password = 'password123';
      final doctorUser = UserFixtures.createDoctor(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => Right(doctorUser));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act - Login as doctor with doctor credentials
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
            userType: UserType.doctor, // Correct type
          );

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, equals(doctorUser));
      expect(state.error, isNull);
    });
  });

  group('AuthProvider - State Transitions', () {
    test('should transition from unauthenticated to authenticated', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'password123';
      final user = UserFixtures.createPatient(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => Right(user));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Assert initial state
      expect(container.read(authProvider).isAuthenticated, false);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert final state
      expect(container.read(authProvider).isAuthenticated, true);
    });

    test('should remain unauthenticated on login failure', () async {
      // Arrange
      const email = 'patient@test.com';
      const password = 'wrongpassword';

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Wrong password')),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Assert initial state
      expect(container.read(authProvider).isAuthenticated, false);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            password,
          );

      // Assert final state
      expect(container.read(authProvider).isAuthenticated, false);
    });
  });

  group('AuthProvider - Error Clearing', () {
    test('should clear previous error on new login attempt', () async {
      // Arrange
      const email = 'patient@test.com';
      const wrongPassword = 'wrongpassword';
      const correctPassword = 'password123';
      final user = UserFixtures.createPatient(email: email);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: wrongPassword),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Wrong password')),
      );
      when(
        mockAuthRepository.signIn(email: email, password: correctPassword),
      ).thenAnswer((_) async => Right(user));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act - First attempt with wrong password
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            wrongPassword,
          );

      // Assert error exists
      expect(container.read(authProvider).error, isNotNull);

      // Act - Second attempt with correct password
      await container
          .read(authProvider.notifier)
          .loginWithEmail(
            email,
            correctPassword,
          );

      // Assert error cleared
      expect(container.read(authProvider).error, isNull);
      expect(container.read(authProvider).isAuthenticated, true);
    });
  });

  // ── Admin Login Flow ──────────────────────────────────────────────────────
  group('AuthProvider - Admin Login Flow', () {
    test(
      'admin login succeeds regardless of which userType tab was used',
      () async {
        // Arrange: admin logs in via the "Patient" button (default userType)
        const email = 'admin@test.com';
        const password = 'adminpass';
        final adminUser = UserFixtures.createAdmin(email: email);

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(adminUser));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act — default userType is patient; admin must still pass through
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, password);

        // Assert
        final state = container.read(authProvider);
        expect(
          state.isAuthenticated,
          true,
          reason: 'Admin must be authenticated',
        );
        expect(state.user?.userType, UserType.admin);
        expect(state.error, isNull);
        expect(state.isLoading, false);

        // signOut must NOT be called — admin bypasses the type-mismatch guard
        verifyNever(mockAuthRepository.signOut());
      },
    );

    test(
      'admin login is blocked when isActive is false',
      () async {
        // Arrange
        const email = 'admin@test.com';
        const password = 'adminpass';
        final inactiveAdmin = UserFixtures.createAdmin(
          email: email,
          isActive: false,
        );

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(inactiveAdmin));
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(unit));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, password);

        // Assert
        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.user, isNull);
        expect(state.error, contains('معطّل'));
        expect(state.isLoading, false);

        verify(mockAuthRepository.signOut()).called(1);
      },
    );

    test(
      'invalid admin credentials never set isAuthenticated to true',
      () async {
        // Arrange
        const email = 'admin@test.com';
        const password = 'wrongpassword';

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('كلمة المرور غير صحيحة')),
        );

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, password);

        // Assert — must never authenticate
        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.isLoading, false);
        expect(state.error, isNotNull);
      },
    );

    test(
      'admin login succeeds even when AuthState previously had an error',
      () async {
        // Regression test: ensures copyWith(clearError: true) on success
        // wipes any stale error from a previous failed attempt.
        const email = 'admin@test.com';
        const wrongPassword = 'wrong';
        const correctPassword = 'adminpass';
        final adminUser = UserFixtures.createAdmin(email: email);

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: wrongPassword),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('كلمة المرور غير صحيحة')),
        );
        when(
          mockAuthRepository.signIn(email: email, password: correctPassword),
        ).thenAnswer((_) async => Right(adminUser));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // First attempt — fails, leaves error in state
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, wrongPassword);
        expect(container.read(authProvider).error, isNotNull);

        // Second attempt — succeeds, error must be cleared
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, correctPassword);

        final state = container.read(authProvider);
        expect(state.isAuthenticated, true);
        expect(state.user?.userType, UserType.admin);
        expect(
          state.error,
          isNull,
          reason: 'Stale error must be cleared on success',
        );
      },
    );
  });

  // ── Phone Login Flow ──────────────────────────────────────────────────────
  group('AuthProvider - Phone Login Flow', () {
    test('startPhoneVerification should trigger repository call', () async {
      // Arrange
      const phoneNumber = '+201111111111';
      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.verifyPhoneNumber(phoneNumber: phoneNumber),
      ).thenAnswer(
        (_) async => const Right(
          PhoneVerificationData(
            verificationId: 'v123',
            resendToken: 123,
          ),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .startPhoneVerification(phoneNumber);

      // Assert
      final state = container.read(authProvider);
      expect(state.verificationId, 'v123');
      expect(state.resendToken, 123);
      expect(state.isPhoneLoading, false);
      expect(state.phoneAuthErrorMessage, isNull);

      verify(
        mockAuthRepository.verifyPhoneNumber(phoneNumber: phoneNumber),
      ).called(1);
    });

    test('startPhoneVerification should handle failure', () async {
      // Arrange
      const phoneNumber = '+201111111111';
      const errorMessage = 'Too many requests';
      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.verifyPhoneNumber(phoneNumber: phoneNumber),
      ).thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .startPhoneVerification(phoneNumber);

      // Assert
      final state = container.read(authProvider);
      expect(state.verificationId, isNull);
      expect(state.phoneAuthErrorMessage, errorMessage);
      expect(state.isPhoneLoading, false);
    });
  });

  group('AuthProvider - OTP Verification', () {
    test('verifyOtp should login successfully', () async {
      // Arrange
      const verificationId = 'v123';
      const smsCode = '123456';
      final patientUser = UserFixtures.createPatient(id: 'u123');

      // Setup initial state with verificationId
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            (ref) => AuthNotifier(mockAuthRepository)
              ..state = AuthState(
                verificationId: verificationId,
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signInWithPhoneNumber(
          verificationId: verificationId,
          smsCode: smsCode,
        ),
      ).thenAnswer((_) async => Right(patientUser));

      // Act
      await container
          .read(authProvider.notifier)
          .verifyOtp(smsCode, UserType.patient);

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, patientUser);
    });

    test('verifyOtp should handle failure', () async {
      // Arrange
      const verificationId = 'v123';
      const smsCode = 'wrong';
      const errorMessage = 'كود خاطئ';

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(
            (ref) => AuthNotifier(mockAuthRepository)
              ..state = AuthState(
                verificationId: verificationId,
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signInWithPhoneNumber(
          verificationId: verificationId,
          smsCode: smsCode,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(errorMessage)));

      // Act
      await container
          .read(authProvider.notifier)
          .verifyOtp(smsCode, UserType.patient);

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.phoneAuthErrorMessage, errorMessage);
    });
  });

  group('AuthProvider - Account Status and Role Validation', () {
    test(
      'should fail doctor login and sign out if doctor is not approved',
      () async {
        const email = 'pending-doctor@test.com';
        const password = 'password123';
        final pendingDoctor = UserFixtures.createDoctor(
          email: email,
          isApproved: false,
          isActive: false,
        );

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(pendingDoctor));
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(unit));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .loginWithEmail(
              email,
              password,
              userType: UserType.doctor,
            );

        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.user, isNull);
        expect(state.error, contains('pending admin approval'));
        verify(mockAuthRepository.signOut()).called(1);
      },
    );

    test(
      'should fail login and sign out if user is inactive (isActive: false)',
      () async {
        // Arrange
        const email = 'inactive@test.com';
        const password = 'password123';
        final inactiveUser = UserFixtures.createPatient(
          email: email,
          isActive: false,
        );

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(inactiveUser));
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(unit));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, password);

        // Assert
        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.user, isNull);
        expect(state.error, contains('معطّل'));

        // Verify signOut was called to clean up the Firebase Auth session
        verify(mockAuthRepository.signOut()).called(1);
      },
    );

    test(
      'should fail doctor login with disabled account message when approved but inactive',
      () async {
        const email = 'inactive-doctor@test.com';
        const password = 'password123';
        final inactiveDoctor = UserFixtures.createDoctor(
          email: email,
          isActive: false,
        );

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(inactiveDoctor));
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(unit));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .loginWithEmail(
              email,
              password,
              userType: UserType.doctor,
            );

        final state = container.read(authProvider);
        expect(state.isAuthenticated, false);
        expect(state.user, isNull);
        expect(state.error, 'Account disabled, please contact support.');
        verify(mockAuthRepository.signOut()).called(1);
      },
    );

    test('should allow login for active users (isActive: true)', () async {
      // Arrange
      const email = 'active@test.com';
      const password = 'password123';
      final activeUser = UserFixtures.createPatient(
        email: email,
      );

      when(
        mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(ServerFailure('No user')));
      when(
        mockAuthRepository.signIn(email: email, password: password),
      ).thenAnswer((_) async => Right(activeUser));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      await container
          .read(authProvider.notifier)
          .loginWithEmail(email, password);

      // Assert
      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, equals(activeUser));
      expect(state.error, isNull);
    });

    test(
      'should handle missing isActive field by defaulting to true (legacy users)',
      () async {
        // Arrange
        const email = 'legacy@test.com';
        const password = 'password123';
        // Manual JSON without isActive field
        final legacyUser = UserModel.fromJson({
          'id': 'legacy_001',
          'email': email,
          'fullName': 'Legacy User',
          'userType': 'patient',
          'createdAt': DateTime.now().toIso8601String(),
          // 'isActive' is missing
        });

        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('No user')));
        when(
          mockAuthRepository.signIn(email: email, password: password),
        ).thenAnswer((_) async => Right(legacyUser));

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act
        await container
            .read(authProvider.notifier)
            .loginWithEmail(email, password);

        // Assert
        final state = container.read(authProvider);
        expect(state.isAuthenticated, true);
        expect(state.user?.isActive, true); // Default value should be true
      },
    );
  });
}
