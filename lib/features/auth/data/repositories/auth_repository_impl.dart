import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/auth/domain/models/phone_verification_data.dart';
import 'package:elajtech/core/services/fcm_service.dart';
import 'package:elajtech/core/services/token_refresh_service.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Authentication Repository implementation for the AndroCare360 system.
///
/// This repository implements the [AuthRepository] interface and handles all
/// authentication operations including user registration, login, logout, and
/// profile management. It integrates Firebase Authentication with Firestore
/// for complete user management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'users' (from AppConstants.collections.users)
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - FCM tokens are updated on login and registration
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final authRepository = getIt<AuthRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(AuthFailure): Operation failed with specific error message
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - AuthFailure: Authentication errors (invalid credentials, weak password, etc.)
/// - Network errors are caught and returned as AuthFailure with Arabic message
///
/// **Token Management:**
/// - FCM tokens are automatically updated on login and registration
/// - Token refresh is attempted before update operations
/// - Permission-denied errors trigger automatic token refresh and retry
///
/// **Usage Example:**
/// ```dart
/// final result = await authRepository.signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => navigateToHome(user),
/// );
/// ```
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an AuthRepositoryImpl instance with injected dependencies.
  ///
  /// Parameters:
  /// - [_firebaseAuth]: Firebase Authentication instance
  /// - [_firestore]: Firestore instance configured with databaseId: 'elajtech'
  /// - [_tokenRefreshService]: Service for refreshing authentication tokens
  /// - [_fcmService]: FCM Service for managing push notification tokens
  AuthRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
    this._tokenRefreshService,
    this._fcmService,
  );

  /// Firebase Authentication instance for auth operations
  final FirebaseAuth _firebaseAuth;

  /// Firestore instance configured for 'elajtech' database
  final FirebaseFirestore _firestore;

  /// Service for managing token refresh operations
  final TokenRefreshService _tokenRefreshService;

  /// FCM Service for managing push notification tokens
  final FCMService _fcmService;

  /// Temporary holder for pending patient sign-up data between
  /// [startSignUpWithEmailAndPhone] (Step 1) and
  /// [confirmSignUpAndCreateProfile] (Step 2).
  /// Cleared automatically after Step 2 completes (success or failure).
  _PendingSignUpData? _pendingSignUpData;

  /// Stream of authentication state changes.
  ///
  /// Emits the current Firebase User when authentication state changes
  /// (login, logout, token refresh). Returns null when no user is logged in.
  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumber({
    required String phoneNumber,
  }) async {
    final completer = Completer<Either<Failure, PhoneVerificationData>>();

    try {
      if (kDebugMode) {
        debugPrint(
          '📲 [AuthRepositoryImpl] Starting verification for: $phoneNumber',
        );
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            debugPrint(
              '✅ [AuthRepositoryImpl] Phone verification completed automatically',
            );
          }
          try {
            await _firebaseAuth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(
                const Right(
                  PhoneVerificationData(
                    verificationId: '',
                    isAutoVerified: true,
                  ),
                ),
              );
            }
          } on FirebaseAuthException catch (e) {
            if (kDebugMode) {
              debugPrint('❌ [AuthRepositoryImpl] Auto sign-in failed: $e');
            }
            if (!completer.isCompleted) {
              completer.complete(Left(AuthFailure(_mapFirebaseAuthError(e))));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(Left(AuthFailure(e.toString())));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            debugPrint(
              '❌ [AuthRepositoryImpl] Phone verification failed: ${e.code}',
            );
          }
          if (!completer.isCompleted) {
            completer.complete(Left(AuthFailure(_mapFirebaseAuthError(e))));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            debugPrint('📨 [AuthRepositoryImpl] Code sent: $verificationId');
          }
          if (!completer.isCompleted) {
            completer.complete(
              Right(
                PhoneVerificationData(
                  verificationId: verificationId,
                  resendToken: resendToken,
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            debugPrint(
              '⏳ [AuthRepositoryImpl] Code auto retrieval timeout: $verificationId',
            );
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AuthRepositoryImpl] Error in verifyPhoneNumber: $e');
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AuthRepositoryImpl] Unexpected error in verifyPhoneNumber: $e',
        );
      }
      return Left(AuthFailure(e.toString()));
    }

    return completer.future;
  }

  @override
  Future<Either<Failure, UserModel>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔑 [AuthRepositoryImpl] Signing in with SMS code');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure(AppStrings.auth_phone_invalid_number));
      }

      // Check Firestore (Rule: Must use databaseId: 'elajtech')
      final doc = await _firestore
          .collection(AppConstants.collections.users)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthRepositoryImpl] No Firestore doc for uid=${firebaseUser.uid}',
          );
        }
        await _firebaseAuth.signOut();
        return const Left(AuthFailure(AppStrings.auth_phone_user_not_found));
      }

      final user = UserModel.fromJson(doc.data()!);

      // Update FCM Token
      try {
        final fcmToken = await _fcmService.getToken();
        if (fcmToken != null) {
          await _firestore
              .collection(AppConstants.collections.users)
              .doc(user.id)
              .update({
                'fcmToken': fcmToken,
                'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
              });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [AuthRepositoryImpl] Failed to update FCM token during phone login: $e',
          );
        }
      }

      return Right(user);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AuthRepositoryImpl] Error in signInWithPhoneNumber: $e');
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AuthRepositoryImpl] Unexpected error in signInWithPhoneNumber: $e',
        );
      }
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Registers a new user account with email and password.
  ///
  /// This method creates a new Firebase Authentication account, stores user
  /// profile data in Firestore, and retrieves an FCM token for push notifications.
  /// It includes phone number uniqueness validation (when provided).
  ///
  /// Parameters:
  /// - [email]: User's email address (required)
  /// - [password]: User's password (required, must meet Firebase requirements)
  /// - [fullName]: User's full name (required)
  /// - [userType]: User role - patient or doctor (required)
  /// - [phoneNumber]: Phone number (optional, checked for uniqueness)
  /// - [licenseNumber]: Medical license number (optional, for doctors)
  /// - [specializations]: List of medical specializations (optional, for doctors)
  /// - [clinicName]: Clinic name (optional, for doctors)
  /// - [clinicAddress]: Clinic address (optional, for doctors)
  /// - [consultationTypes]: Types of consultations offered (optional, for doctors)
  /// - [username]: Display username (optional)
  ///
  /// Returns:
  /// - Right(UserModel): Successfully created user with profile data
  /// - Left(AuthFailure): Registration failed with error message
  ///
  /// Possible Failures:
  /// - 'رقم الهاتف مستخدم بالفعل': Phone number already exists
  /// - 'كلمة المرور ضعيفة جداً': Password too weak
  /// - 'البريد الإلكتروني مستخدم بالفعل': Email already in use
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signUp(
  ///   email: 'doctor@example.com',
  ///   password: 'SecurePass123!',
  ///   fullName: 'Dr. Ahmed Ali',
  ///   userType: UserType.doctor,
  ///   phoneNumber: '+966500000001',
  ///   licenseNumber: 'MED-12345',
  ///   specializations: ['Nutrition'],
  /// );
  /// ```
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
    try {
      // Check phone number uniqueness first
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        try {
          final phoneQuery = await _firestore
              .collection(AppConstants.collections.users)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();
          if (phoneQuery.docs.isNotEmpty) {
            return const Left(AuthFailure('رقم الهاتف مستخدم بالفعل'));
          }
        } on FirebaseException catch (e) {
          // If permission is denied, we skip the uniqueness check here
          // and let the account creation proceed or fail on .set() later.
          // This happens when rules don't allowed listing users before auth.
          print('⚠️ Phone uniqueness check skipped: ${e.code}');
        } on SocketException catch (e) {
          print('⚠️ Phone uniqueness check failed (network): ${e.message}');
        } on Exception catch (e) {
          print('⚠️ Phone uniqueness check failed: $e');
        }
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return const Left(
          AuthFailure('فشل إنشاء الحساب، يرجى المحاولة مرة أخرى'),
        );
      }

      await user.updateDisplayName(fullName);
      final fcmToken = await _fcmService.getToken();

      final newUser = UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        userType: userType,
        phoneNumber: phoneNumber,
        username: username,
        licenseNumber: licenseNumber,
        specializations: specializations,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        consultationTypes: consultationTypes,
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      await _firestore
          .collection(AppConstants.collections.users)
          .doc(newUser.id)
          .set(newUser.toJson());

      return Right(newUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Authenticates a user with email and password.
  ///
  /// This method signs in an existing user, retrieves their profile data from
  /// Firestore, and updates their FCM token for push notifications.
  ///
  /// Parameters:
  /// - [email]: User's email address (required)
  /// - [password]: User's password (required)
  ///
  /// Returns:
  /// - Right(UserModel): Successfully authenticated user with profile data
  /// - Left(AuthFailure): Login failed with error message
  ///
  /// Possible Failures:
  /// - 'لا يوجد مستخدم بهذا البريد الإلكتروني': User not found
  /// - 'كلمة المرور غير صحيحة': Wrong password
  /// - 'بيانات المستخدم غير موجودة': User data not found in Firestore
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
  @override
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return const Left(AuthFailure('فشل تسجيل الدخول'));
      }

      final doc = await _firestore
          .collection(AppConstants.collections.users)
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ AuthRepositoryImpl.signIn: No Firestore doc for uid=${user.uid}',
          );
        }
        return const Left(AuthFailure('بيانات المستخدم غير موجودة'));
      }

      // Always inject the Firestore document ID so UserModel.fromJson never
      // fails on a null 'id' field (e.g. for admin docs created manually).
      final data = <String, dynamic>{
        ...doc.data()!,
        'id': user.uid,
      };

      if (kDebugMode) {
        debugPrint(
          '📄 AuthRepositoryImpl.signIn: Firestore doc loaded'
          ' | id=${user.uid}'
          ' | userType=${data['userType']}'
          ' | isActive=${data['isActive']}'
          ' | createdAt=${data['createdAt']}',
        );
      }

      UserModel userModel;
      try {
        userModel = UserModel.fromJson(data);
      } catch (e, st) {
        debugPrint(
          '❌ AuthRepositoryImpl.signIn: UserModel.fromJson failed: $e',
        );
        debugPrint('   $st');
        return Left(
          AuthFailure('تعذّر تحميل بيانات الحساب: $e'),
        );
      }

      final fcmToken = await _fcmService.getToken();

      // Update FCM Token on login
      if (fcmToken != null) {
        await _firestore
            .collection(AppConstants.collections.users)
            .doc(user.uid)
            .update({'fcmToken': fcmToken});
      }

      if (kDebugMode) {
        debugPrint(
          '✅ AuthRepositoryImpl.signIn: UserModel parsed OK'
          ' | userType=${userModel.userType.name}',
        );
      }

      return Right(userModel.copyWith(fcmToken: fcmToken));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Signs out the currently authenticated user.
  ///
  /// This method logs out the user from Firebase Authentication. It does not
  /// clear local data or FCM tokens - those should be handled separately.
  ///
  /// Returns:
  /// - Right(Unit): Successfully signed out
  /// - Left(AuthFailure): Sign out failed
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signOut();
  /// result.fold(
  ///   (failure) => showError('فشل تسجيل الخروج'),
  ///   (_) => navigateToLogin(),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(unit);
    } on Exception catch (_) {
      return const Left(AuthFailure('فشل تسجيل الخروج'));
    }
  }

  /// Retrieves the currently authenticated user's profile data.
  ///
  /// This method fetches the complete user profile from Firestore for the
  /// currently logged-in Firebase Authentication user.
  ///
  /// Returns:
  /// - Right(UserModel): Current user's profile data
  /// - Left(AuthFailure): No user logged in or data retrieval failed
  ///
  /// Possible Failures:
  /// - 'لم يتم العثور على مستخدم مسجل الدخول': No authenticated user
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.getCurrentUser();
  /// result.fold(
  ///   (failure) => showLoginScreen(),
  ///   (user) => displayProfile(user),
  /// );
  /// ```
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection(AppConstants.collections.users)
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          // Always inject the Firestore document ID — admin docs created
          // manually may not store 'id' as a field.
          final data = <String, dynamic>{...doc.data()!, 'id': user.uid};
          if (kDebugMode) {
            debugPrint(
              '📄 AuthRepositoryImpl.getCurrentUser: doc loaded'
              ' | userType=${data['userType']} | isActive=${data['isActive']}',
            );
          }
          UserModel userModel;
          try {
            userModel = UserModel.fromJson(data);
          } catch (e, st) {
            if (kDebugMode) {
              debugPrint('❌ AuthRepositoryImpl.getCurrentUser: UserModel.fromJson failed: $e');
              debugPrint('   $st');
            }
            return Left(AuthFailure('تعذّر تحميل بيانات الحساب: $e'));
          }
          return Right(userModel);
        }
      }
      return const Left(AuthFailure('لم يتم العثور على مستخدم مسجل الدخول'));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Sends a password reset email to the specified email address.
  ///
  /// This method triggers Firebase Authentication to send a password reset
  /// email to the user. The user can then follow the link to reset their password.
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to (required)
  ///
  /// Returns:
  /// - Right(Unit): Reset email sent successfully
  /// - Left(AuthFailure): Failed to send reset email
  ///
  /// Possible Failures:
  /// - 'لا يوجد مستخدم بهذا البريد الإلكتروني': Email not found
  /// - 'البريد الإلكتروني غير صالح': Invalid email format
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.resetPassword('user@example.com');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('تم إرسال رابط إعادة تعيين كلمة المرور'),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Deletes the currently authenticated user's account.
  ///
  /// This method permanently deletes the user's account from both Firebase
  /// Authentication and Firestore. This operation cannot be undone.
  ///
  /// **IMPORTANT**: If the user's authentication token is too old, this operation
  /// will fail with 'requires-recent-login'. The user must re-authenticate first.
  ///
  /// Returns:
  /// - Right(Unit): Account deleted successfully
  /// - Left(AuthFailure): Deletion failed
  ///
  /// Possible Failures:
  /// - 'requires-recent-login': User must re-authenticate before deletion
  /// - 'No user logged in': No authenticated user
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.deleteAccount();
  /// result.fold(
  ///   (failure) {
  ///     if (failure.message == 'requires-recent-login') {
  ///       // Prompt user to re-authenticate
  ///       showReAuthDialog();
  ///     } else {
  ///       showError(failure.message);
  ///     }
  ///   },
  ///   (_) => navigateToWelcomeScreen(),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user logged in'));
      }

      // Delete from Firestore
      await _firestore
          .collection(AppConstants.collections.users)
          .doc(user.uid)
          .delete();

      // Delete from Firebase Auth
      await user.delete();

      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return const Left(AuthFailure('requires-recent-login'));
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Updates the user's profile data in Firestore.
  ///
  /// This method updates user profile information with automatic token refresh
  /// and retry logic for permission-denied errors. It ensures the userType field
  /// is present and validates data before updating.
  ///
  /// **Token Refresh Strategy:**
  /// 1. Refreshes authentication token before update
  /// 2. If permission-denied error occurs, refreshes token and retries once
  /// 3. Provides detailed error messages for troubleshooting
  ///
  /// Parameters:
  /// - [user]: UserModel with updated profile data (required)
  ///
  /// Returns:
  /// - Right(Unit): Profile updated successfully
  /// - Left(AuthFailure): Update failed with detailed error message
  ///
  /// Possible Failures:
  /// - 'خطأ: حقل userType مفقود من البيانات': userType field missing
  /// - 'لا تملك الصلاحية اللازمة...': Permission denied (with retry attempted)
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  ///
  /// **Debug Logging:**
  /// All update operations are logged with:
  /// - User ID
  /// - Fields being updated
  /// - Token refresh status
  /// - Permission errors and retry attempts
  ///
  /// Example:
  /// ```dart
  /// final updatedUser = currentUser.copyWith(
  ///   fullName: 'New Name',
  ///   phoneNumber: '+966500000001',
  /// );
  /// final result = await authRepository.updateUser(updatedUser);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('تم تحديث الملف الشخصي'),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> updateUser(UserModel user) async {
    try {
      // ✅ التأكد من أن userType موجود في البيانات
      final jsonData = user.toJson();

      if (!jsonData.containsKey('userType')) {
        debugPrint(
          '❌ AuthRepositoryImpl: userType field missing from user data',
        );
        return const Left(
          AuthFailure('خطأ: حقل userType مفقود من البيانات'),
        );
      }

      debugPrint(
        '📤 AuthRepositoryImpl: Updating user with userType: ${jsonData['userType']}',
      );
      debugPrint('📤 AuthRepositoryImpl: User ID: ${user.id}');
      debugPrint(
        '📤 AuthRepositoryImpl: Fields being updated: ${jsonData.keys.join(', ')}',
      );

      // ✅ تحديث Token قبل عملية التحديث للتأكد من أن الـ Claims محدثة
      final tokenRefreshed = await _tokenRefreshService.forceRefreshToken();

      if (!tokenRefreshed) {
        debugPrint(
          '⚠️ AuthRepositoryImpl: Failed to refresh token before update',
        );
        // لا نوقف العملية، لكن نُسجل التحذير
      } else {
        debugPrint(
          '✅ AuthRepositoryImpl: Token refreshed successfully before update',
        );
      }

      await _firestore
          .collection(AppConstants.collections.users)
          .doc(user.id)
          .update(jsonData);

      debugPrint('✅ AuthRepositoryImpl: User updated successfully');
      return const Right(unit);
    } on FirebaseException catch (e) {
      debugPrint(
        '❌ AuthRepositoryImpl: Firestore error: ${e.code} - ${e.message}',
      );

      // ✅ محاولة تحديث Token عند مواجهة خطأ permission-denied
      if (e.code == 'permission-denied') {
        debugPrint(
          '⚠️ AuthRepositoryImpl: Permission denied, attempting token refresh...',
        );

        // محاولة تحديث Token وإعادة المحاولة
        final refreshed = await _tokenRefreshService.forceRefreshToken();

        if (refreshed) {
          debugPrint(
            '✅ AuthRepositoryImpl: Token refreshed, retrying update...',
          );

          // محاولة إعادة العملية بعد تحديث Token
          try {
            await _firestore
                .collection(AppConstants.collections.users)
                .doc(user.id)
                .update(user.toJson());

            debugPrint(
              '✅ AuthRepositoryImpl: Update succeeded after token refresh',
            );
            return const Right(unit);
          } on FirebaseException catch (retryError) {
            debugPrint(
              '❌ AuthRepositoryImpl: Retry failed: ${retryError.code}',
            );
            return const Left(
              AuthFailure(
                'لا تملك الصلاحية اللازمة لتحديث هذه البيانات. '
                'يرجى التأكد من أنك تحديث حقول مسموحة لدورك (طبيب/مريض). '
                'إذا استمرت المشكلة، حاول تسجيل الخروج والدخول مرة أخرى.',
              ),
            );
          } on Exception catch (retryError) {
            debugPrint('❌ AuthRepositoryImpl: Retry failed: $retryError');
            return const Left(
              AuthFailure(
                'لا تملك الصلاحية اللازمة لتحديث هذه البيانات. '
                'يرجى التأكد من أنك تحديث حقول مسموحة لدورك (طبيب/مريض). '
                'إذا استمرت المشكلة، حاول تسجيل الخروج والدخول مرة أخرى.',
              ),
            );
          }
        }

        // إذا فشل تحديث Token أو إعادة المحاولة
        return const Left(
          AuthFailure(
            'لا تملك الصلاحية اللازمة لتحديث هذه البيانات. '
            'يرجى التأكد من أنك تحديث حقول مسموحة لدورك (طبيب/مريض). '
            'إذا استمرت المشكلة، حاول تسجيل الخروج والدخول مرة أخرى.',
          ),
        );
      }

      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      debugPrint('❌ AuthRepositoryImpl: Network error');
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      debugPrint('❌ AuthRepositoryImpl: Exception: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  /// بدء عملية التحقق من رقم الهاتف بهدف ربطه بالحساب الحالي.
  /// Starts phone verification solely for the purpose of linking it to the
  /// currently signed-in email/password account.
  ///
  /// Internally identical to [verifyPhoneNumber], but kept as a separate method
  /// to make the intent explicit and avoid coupling the sign-in and linking flows.
  ///
  /// Returns:
  /// - Right(PhoneVerificationData): OTP sent or auto-verified
  /// - Left(AuthFailure): Initiation failed
  @override
  Future<Either<Failure, PhoneVerificationData>> verifyPhoneNumberForLinking({
    required String phoneNumber,
  }) async {
    // Identical internal implementation to verifyPhoneNumber(); kept separate
    // so callers can distinguish the intent (linking vs. standalone sign-in).
    return verifyPhoneNumber(phoneNumber: phoneNumber);
  }

  /// ربط بيانات اعتماد الهاتف (OTP) بالمستخدم المسجّل حالياً بالبريد الإلكتروني.
  /// Links a phone OTP credential to the currently signed-in user so that
  /// both Email/Password and Phone can authenticate the same Firebase uid.
  ///
  /// Flow:
  ///   1. Guard: ensure a Firebase user is currently signed in.
  ///   2. Build a [PhoneAuthCredential] from [verificationId] + [smsCode].
  ///   3. Call [User.linkWithCredential] — the uid does NOT change.
  ///   4. Update `phoneNumber` in Firestore `users/{uid}`.
  ///   5. Return Right(UserModel) with up-to-date phone number.
  ///
  /// Error codes handled:
  ///   - `credential-already-in-use`: phone linked to a different account
  ///   - `provider-already-linked`: phone already linked to this account
  ///   - `invalid-verification-code`: wrong OTP
  ///   - Network errors
  @override
  Future<Either<Failure, UserModel>> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure('لا يوجد مستخدم مسجّل الدخول. يرجى تسجيل الدخول أولاً.'),
        );
      }

      if (kDebugMode) {
        debugPrint(
          '🔗 [AuthRepositoryImpl] Linking phone to uid=${currentUser.uid}',
        );
      }

      // 1. Build credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // 2. Link — uid stays the same
      final userCredential = await currentUser.linkWithCredential(credential);
      final linkedUser = userCredential.user ?? currentUser;

      if (kDebugMode) {
        debugPrint(
          '✅ [AuthRepositoryImpl] Phone linked to uid=${linkedUser.uid}',
        );
      }

      // 3. Update phoneNumber in Firestore users/{uid}
      final phoneNumber = linkedUser.phoneNumber;
      if (phoneNumber != null) {
        if (kDebugMode) {
          debugPrint(
            '📝 [AuthRepositoryImpl] Updating Firestore phoneNumber | uid=${linkedUser.uid} | phone=$phoneNumber',
          );
        }
        await _firestore
            .collection(AppConstants.collections.users)
            .doc(linkedUser.uid)
            .update({'phoneNumber': phoneNumber});
      }

      // 4. Fetch updated Firestore doc and return as UserModel
      final doc = await _firestore
          .collection(AppConstants.collections.users)
          .doc(linkedUser.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthRepositoryImpl] linkPhoneToCurrentUser: No Firestore doc after linking for uid=${linkedUser.uid}',
          );
        }
        return const Left(
          AuthFailure('تم الربط ولكن تعذّر تحميل بيانات المستخدم.'),
        );
      }

      final data = <String, dynamic>{...doc.data()!, 'id': linkedUser.uid};
      final userModel = UserModel.fromJson(data);

      if (kDebugMode) {
        debugPrint(
          '✅ [AuthRepositoryImpl] linkPhoneToCurrentUser completed | uid=${linkedUser.uid} | phone=${userModel.phoneNumber}',
        );
      }

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AuthRepositoryImpl] linkPhoneToCurrentUser FirebaseAuthException: ${e.code}',
        );
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AuthRepositoryImpl] linkPhoneToCurrentUser FirebaseException: ${e.code}',
        );
      }
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Patient Sign-Up (Email + Phone linking at account creation)
  // ---------------------------------------------------------------------------

  /// ⚠️ Patient sign-up only — Step 1.
  ///
  /// 1. Checks phone uniqueness in Firestore.
  /// 2. Creates a Firebase email/password account (`createUserWithEmailAndPassword`).
  /// 3. Stores pending sign-up data in [_pendingSignUpData] for Step 2.
  /// 4. Sends an OTP to [phoneNumber] via [verifyPhoneNumber].
  /// 5. Returns the `verificationId` — Firestore is NOT written at this stage.
  @override
  Future<Either<Failure, String>> startSignUpWithEmailAndPhone({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? username,
  }) async {
    try {
      // 1. Phone uniqueness check
      if (phoneNumber.isNotEmpty) {
        try {
          final phoneQuery = await _firestore
              .collection(AppConstants.collections.users)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();
          if (phoneQuery.docs.isNotEmpty) {
            return const Left(AuthFailure('رقم الهاتف مستخدم بالفعل'));
          }
        } on FirebaseException {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [SignUp] Phone uniqueness check skipped (Firebase error)',
            );
          }
        } on SocketException {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [SignUp] Phone uniqueness check failed (Network error)',
            );
          }
        }
      }

      // 2. Create email/password Firebase account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Left(
          AuthFailure('فشل إنشاء الحساب، يرجى المحاولة مرة أخرى'),
        );
      }

      await firebaseUser.updateDisplayName(fullName);

      // 3. Store pending data so Step 2 can write the Firestore document
      _pendingSignUpData = _PendingSignUpData(
        uid: firebaseUser.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        username: username,
      );

      // 4. Send OTP (reuses verifyPhoneNumber internally)
      final otpResult = await verifyPhoneNumberForLinking(
        phoneNumber: phoneNumber,
      );

      return otpResult.fold(
        (failure) async {
          // OTP sending failed — roll back the just-created email account
          try {
            await firebaseUser.delete();
          } catch (deleteErr) {
            if (kDebugMode) {
              debugPrint(
                r'⚠️ [SignUp] Rollback failed (delete user): $deleteErr',
              );
            }
          }
          _pendingSignUpData = null;
          return Left(failure);
        },
        (verificationData) => Right(verificationData.verificationId),
      );
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// ⚠️ Patient sign-up only — Step 2.
  ///
  /// 1. Reads [_pendingSignUpData] (set by [startSignUpWithEmailAndPhone]).
  /// 2. Builds a PhoneAuthCredential and calls `currentUser.linkWithCredential`.
  /// 3. On success: writes `users/{uid}` to Firestore with `userType = patient`.
  /// 4. On any failure: deletes the Firebase user (rollback) and returns Left.
  @override
  Future<Either<Failure, UserModel>> confirmSignUpAndCreateProfile({
    required String verificationId,
    required String smsCode,
  }) async {
    final pending = _pendingSignUpData;
    final currentUser = _firebaseAuth.currentUser;

    if (pending == null || currentUser == null) {
      return const Left(
        AuthFailure('انتهت جلسة التسجيل، يرجى المحاولة مرة أخرى'),
      );
    }

    try {
      // 2. Link phone credential to the existing email/password user
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await currentUser.linkWithCredential(credential);

      // 3. Write Firestore users/{uid} document — only after successful linking
      final fcmToken = await _fcmService.getToken();
      final newUser = UserModel(
        id: pending.uid,
        email: pending.email,
        fullName: pending.fullName,
        userType: UserType.patient,
        phoneNumber: pending.phoneNumber,
        username: pending.username,
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      if (kDebugMode) {
        debugPrint(
          r'[SignUp] Writing Firestore doc — uid: ${pending.uid}, '
          r'phone: ${pending.phoneNumber}',
        );
      }

      await _firestore
          .collection(AppConstants.collections.users)
          .doc(pending.uid)
          .set(newUser.toJson());

      _pendingSignUpData = null;
      return Right(newUser);
    } on FirebaseAuthException catch (e) {
      // Rollback: delete the orphaned Firebase user
      await _rollbackSignUp(currentUser);
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on FirebaseException catch (e) {
      // Rollback on Firestore write failure
      await _rollbackSignUp(currentUser);
      return Left(AuthFailure(_mapFirestoreError(e)));
    } on SocketException {
      await _rollbackSignUp(currentUser);
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      await _rollbackSignUp(currentUser);
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Deletes [user] from Firebase Auth to roll back a partial patient sign-up.
  Future<void> _rollbackSignUp(User user) async {
    _pendingSignUpData = null;
    try {
      await user.delete();
      if (kDebugMode) {
        debugPrint(r'♻️ [SignUp] Firebase user rolled back: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(r'⚠️ [SignUp] Rollback (delete user) failed: $e');
      }
    }
  }

  /// Changes the current user's password using Firebase Authentication.
  ///
  /// This method updates the active user's password directly in Firebase Auth.
  /// It requires the user to have signed in recently; if the session is too old,
  /// Firebase will return a `requires-recent-login` error and the UI should
  /// prompt re-authentication.
  ///
  /// Parameters:
  /// - [newPassword]: New password (must be ≥ 6 characters)
  ///
  /// Returns:
  /// - Right(Unit): Password updated successfully
  /// - Left(AuthFailure): Update failed with an Arabic error message
  ///
  /// Possible Failures:
  /// - 'يجب تسجيل الدخول مرة أخرى لتغيير كلمة المرور': Session expired
  /// - 'كلمة المرور ضعيفة جداً': Password too weak
  /// - 'لا يوجد اتصال بالإنترنت': No network connection
  @override
  Future<Either<Failure, Unit>> changePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('لا يوجد مستخدم مسجل الدخول'));
      }

      if (kDebugMode) {
        debugPrint('🔑 AuthRepositoryImpl: Changing password for ${user.uid}');
      }

      await user.updatePassword(newPassword);

      if (kDebugMode) {
        debugPrint('✅ AuthRepositoryImpl: Password changed successfully');
      }

      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ AuthRepositoryImpl: changePassword error: ${e.code}',
        );
      }
      if (e.code == 'requires-recent-login') {
        return const Left(
          AuthFailure(
            'يجب تسجيل الدخول مرة أخرى لتغيير كلمة المرور. '
            'يُرجى الخروج والدخول مجدداً.',
          ),
        );
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on SocketException {
      return const Left(AuthFailure('لا يوجد اتصال بالإنترنت'));
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  /// Maps Firestore error codes to user-friendly Arabic error messages.

  ///
  /// This helper method translates technical Firestore error codes into
  /// clear, actionable Arabic messages for end users.
  ///
  /// Parameters:
  /// - [e]: FirebaseException with error code
  ///
  /// Returns localized Arabic error message based on error code.
  ///
  /// Supported Error Codes:
  /// - permission-denied: Permission errors
  /// - not-found: Document not found
  /// - already-exists: Document already exists
  /// - invalid-argument: Invalid data
  /// - unauthenticated: Not logged in
  /// - unavailable: Service unavailable
  /// - And more...
  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'لا تملك الصلاحية اللازمة لتحديث هذه البيانات. يرجى التأكد من أنك تحديث حقول مسموحة لدورك.';
      case 'not-found':
        return 'المستخدم غير موجود.';
      case 'already-exists':
        return 'المستخدم موجود بالفعل.';
      case 'invalid-argument':
        return 'بيانات غير صالحة.';
      case 'failed-precondition':
        return 'فشلت العملية بسبب شرط غير مُستوفى.';
      case 'aborted':
        return 'تم إلغاء العملية.';
      case 'out-of-range':
        return 'القيمة خارج النطاق المسموح.';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً.';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً. يرجى المحاولة مرة أخرى لاحقاً.';
      case 'deadline-exceeded':
        return 'انتهت مهلة العملية. يرجى المحاولة مرة أخرى.';
      case 'resource-exhausted':
        return 'تم تجاوز حد الموارد.';
      case 'cancelled':
        return 'تم إلغاء العملية.';
      case 'data-loss':
        return 'تم فقدان البيانات غير المتوقعة.';
      case 'unknown':
        return 'حدث خطأ غير معروف.';
      default:
        return 'حدث خطأ أثناء تحديث البيانات: ${e.message}';
    }
  }

  /// Maps Firebase Authentication error codes to user-friendly Arabic messages.
  ///
  /// This helper method translates Firebase Auth error codes into clear,
  /// actionable Arabic messages for end users.
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل.';
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'invalid-phone-number':
        return AppStrings.auth_phone_invalid_number;
      case 'too-many-requests':
        return AppStrings.auth_otp_too_many_requests;
      case 'session-expired':
        return AppStrings.auth_otp_session_expired;
      case 'invalid-verification-code':
        return AppStrings.auth_otp_invalid_code;
      // ── Linking-specific codes ──────────────────────────────────────────
      case 'credential-already-in-use':
        return 'رقم الهاتف مرتبط بحساب آخر. يرجى التواصل مع الإدارة.';
      case 'provider-already-linked':
        return 'رقم الهاتف مرتبط بهذا الحساب بالفعل.';
      case 'account-exists-with-different-credential':
        return 'هذا الرقم مستخدم مع طريقة دخول مختلفة.';
      default:
        return e.message ?? 'حدث خطأ ما في عملية المصادقة.';
    }
  }
}

/// Private data holder for the patient sign-up two-step flow.
///
/// Stored temporarily between [AuthRepositoryImpl.startSignUpWithEmailAndPhone]
/// (Step 1) and [AuthRepositoryImpl.confirmSignUpAndCreateProfile] (Step 2).
/// Cleared automatically after Step 2 completes (success or failure).
class _PendingSignUpData {
  _PendingSignUpData({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.username,
  });

  /// Firebase UID from `createUserWithEmailAndPassword`
  final String uid;

  /// Patient's email address
  final String email;

  /// Patient's full display name
  final String fullName;

  /// Patient's phone number in E.164 format
  final String phoneNumber;

  /// Optional username
  final String? username;
}
