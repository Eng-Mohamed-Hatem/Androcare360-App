/// Mock AuthRepository for testing
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/domain/models/phone_verification_data.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

/// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.currentUser});

  final UserModel? currentUser;

  @override
  Stream<firebase.User?> get authStateChanges => Stream.value(null);

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('No user logged in'));
  }

  @override
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('Invalid credentials'));
  }

  @override
  Future<Either<Failure, UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
    String? licenseNumber,
    List<String>? specializations,
    String? clinicName,
    String? clinicAddress,
    List<String>? consultationTypes,
    String? username,
  }) async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('Sign up failed'));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateUser(UserModel user) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    return const Right(unit);
  }

  /// Mock implementation of changePassword — always succeeds.
  @override
  Future<Either<Failure, Unit>> changePassword(String newPassword) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumber({
    required String phoneNumber,
  }) async {
    return const Right(
      PhoneVerificationData(
        verificationId: 'mock_verification_id',
      ),
    );
  }

  @override
  Future<Either<Failure, UserModel>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('Invalid verification code'));
  }

  /// Mock: verifyPhoneNumberForLinking — always returns a fake verificationId.
  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumberForLinking({
    required String phoneNumber,
  }) async {
    return const Right(
      PhoneVerificationData(
        verificationId: 'mock_linking_verification_id',
      ),
    );
  }

  /// Mock: linkPhoneToCurrentUser — succeeds when currentUser is set.
  @override
  Future<Either<Failure, UserModel>> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  }) async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('Linking failed: no current user'));
  }

  /// Mock: startSignUpWithEmailAndPhone (patient sign-up Step 1).
  /// Always returns a fake verificationId for tests.
  @override
  Future<Either<Failure, String>> startSignUpWithEmailAndPhone({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? username,
  }) async {
    return const Right('mock_signup_verification_id');
  }

  /// Mock: confirmSignUpAndCreateProfile (patient sign-up Step 2).
  /// Succeeds when currentUser is set, otherwise returns a failure.
  @override
  Future<Either<Failure, UserModel>> confirmSignUpAndCreateProfile({
    required String verificationId,
    required String smsCode,
  }) async {
    if (currentUser != null) {
      return Right(currentUser!);
    }
    return const Left(ServerFailure('Sign-up confirmation failed: no user'));
  }
}
