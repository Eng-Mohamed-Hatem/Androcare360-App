import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:elajtech/features/auth/domain/models/phone_verification_data.dart';

/// Auth Repository Interface
abstract class AuthRepository {
  /// بدء عملية التحقق من رقم الهاتف.
  /// Starts the phone number verification process.
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumber({
    required String phoneNumber,
  });

  /// تسجيل الدخول باستخدام بيانات اعتماد الهاتف (معرّف التحقق ورمز SMS).
  /// Signs in using phone credentials (verification ID and SMS code).
  Future<Either<Failure, UserModel>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  /// Sign Up with Email and Password
  Future<Either<Failure, UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
    String? licenseNumber,
    List<String>? specializations,
    String? clinicType,
    String? clinicName,
    String? clinicAddress,
    List<String>? consultationTypes,
    String? username,
  });

  /// Sign In with Email and Password
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  });

  /// Sign Out
  Future<Either<Failure, Unit>> signOut();

  /// Get Current User (from local/remote)
  Future<Either<Failure, UserModel>> getCurrentUser();

  /// Reset Password
  Future<Either<Failure, Unit>> resetPassword(String email);

  /// Delete Account
  Future<Either<Failure, Unit>> deleteAccount();

  /// Update User Data
  Future<Either<Failure, Unit>> updateUser(UserModel user);

  /// Change the current user's password (requires recent sign-in).
  ///
  /// Used by doctors to update their own password. The caller must ensure
  /// the user has signed in recently (Firebase re-authentication may be needed).
  ///
  /// [newPassword] must be at least 6 characters.
  Future<Either<Failure, Unit>> changePassword(String newPassword);

  /// بدء عملية التحقق من رقم الهاتف لربطه بالحساب الحالي (إيميل).
  /// Starts phone verification intended for linking to the currently signed-in
  /// email/password user — distinct from the standalone sign-in flow.
  ///
  /// Returns:
  /// - Right(PhoneVerificationData): OTP sent / auto-verified
  /// - Left(AuthFailure): Verification initiation failed
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumberForLinking({
    required String phoneNumber,
  });

  /// ربط بيانات اعتماد الهاتف (OTP) بالمستخدم الحالي المسجّل بالبريد الإلكتروني.
  /// Links a phone OTP credential to the currently signed-in email/password user.
  ///
  /// Calls Firebase Auth's [firebase.User.linkWithCredential] so the phone provider is
  /// added to the existing account **without changing the uid**.
  ///
  /// Parameters:
  /// - [verificationId]: From [verifyPhoneNumberForLinking]
  /// - [smsCode]: 6-digit OTP entered by the user
  ///
  /// Returns:
  /// - Right(UserModel): Linked successfully — same uid, phone stored in Firestore
  /// - Left(AuthFailure): Linking failed (already in use, wrong code, etc.)
  Future<Either<Failure, UserModel>> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  });

  /// ⚠️ Patient sign-up only — Step 1.
  ///
  /// Creates an email/password Firebase account, then immediately sends an
  /// OTP to [phoneNumber] so the phone provider can be linked in Step 2.
  ///
  /// No Firestore document is created at this stage.
  ///
  /// Parameters:
  /// - [email], [password]: New patient credentials
  /// - [fullName]: Display name stored in Firebase Auth and Firestore
  /// - [phoneNumber]: E.164 format (e.g. +201234567890)
  /// - [username]: Optional username
  ///
  /// Returns:
  /// - Right(String): verificationId to pass to [confirmSignUpAndCreateProfile]
  /// - Left(AuthFailure): Account creation or OTP sending failed
  Future<Either<Failure, String>> startSignUpWithEmailAndPhone({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? username,
  });

  /// ⚠️ Patient sign-up only — Step 2.
  ///
  /// Links the phone credential (from [verificationId] + [smsCode]) to the
  /// email/password Firebase user created in [startSignUpWithEmailAndPhone],
  /// then writes the Firestore `users/{uid}` document.
  ///
  /// **Rollback:** on any failure the newly created Firebase user is deleted so
  /// no orphaned account remains. The patient can retry registration.
  ///
  /// Parameters:
  /// - [verificationId]: Returned by [startSignUpWithEmailAndPhone]
  /// - [smsCode]: 6-digit OTP entered by the patient
  ///
  /// Returns:
  /// - Right(UserModel): Registration complete — uid, email and phone linked
  /// - Left(AuthFailure): Link or Firestore write failed (Firebase user rolled back)
  Future<Either<Failure, UserModel>> confirmSignUpAndCreateProfile({
    required String verificationId,
    required String smsCode,
  });

  /// Stream of Auth State Changes
  Stream<firebase.User?> get authStateChanges;
}
