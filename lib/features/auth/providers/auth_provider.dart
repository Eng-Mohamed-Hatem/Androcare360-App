import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/services/background_service.dart';
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart';
import 'package:elajtech/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:elajtech/features/register/presentation/screens/sign_up_otp_screen.dart'
    show SignUpOtpScreen;
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Check if Firebase is available on current platform
bool get _isFirebaseAvailable {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return false;
  }
}

/// Auth State - حالة المصادقة
class AuthState {
  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.verificationId,
    this.resendToken,
    this.isPhoneLoading = false,
    this.phoneAuthErrorMessage,
    // ── Linking-specific fields ───────────────────────────────────────────
    this.isLinking = false,
    this.linkingVerificationId,
    this.linkingError,
    this.linkingSuccess = false,
    // ── Patient Sign-Up fields ────────────────────────────────────────────
    this.signUpLoading = false,
    this.signUpVerificationId,
    this.signUpError,
  });
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? verificationId;
  final int? resendToken;
  final bool isPhoneLoading;
  final String? phoneAuthErrorMessage;

  /// حالة ربط الهاتف: هل عملية الربط جارية؟
  final bool isLinking;

  /// معرّف التحقق المستخدم في تدفق الربط (منفصل عن تدفق تسجيل الدخول).
  final String? linkingVerificationId;

  /// رسالة خطأ الربط (عربية).
  final String? linkingError;

  /// هل نجحت عملية الربط؟ (تُعيَّن true لحظة النجاح، ثم تُمسح).
  final bool linkingSuccess;

  // ── Patient Sign-Up State ────────────────────────────────────────────────

  /// هل جارٍ تنفيذ خطوة من خطوات تسجيل المريض الجديد؟
  final bool signUpLoading;

  /// معرّف التحقق من المرحلة الأولى للتسجيل (يُمرَّر لشاشة OTP).
  final String? signUpVerificationId;

  /// رسالة خطأ التسجيل (عربية). تُمسح عند بدء محاولة جديدة.
  final String? signUpError;
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isAuthenticated,
    String? verificationId,
    int? resendToken,
    bool? isPhoneLoading,
    String? phoneAuthErrorMessage,
    bool clearPhoneError = false,
    // ── Linking ────────────────────────────────────────────────────────────
    bool? isLinking,
    String? linkingVerificationId,
    bool clearLinkingVerificationId = false,
    String? linkingError,
    bool clearLinkingError = false,
    bool? linkingSuccess,
    // ── Patient Sign-Up ────────────────────────────────────────────────────
    bool? signUpLoading,
    String? signUpVerificationId,
    bool clearSignUpVerificationId = false,
    String? signUpError,
    bool clearSignUpError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isPhoneLoading: isPhoneLoading ?? this.isPhoneLoading,
      phoneAuthErrorMessage: clearPhoneError
          ? null
          : (phoneAuthErrorMessage ?? this.phoneAuthErrorMessage),
      isLinking: isLinking ?? this.isLinking,
      linkingVerificationId: clearLinkingVerificationId
          ? null
          : (linkingVerificationId ?? this.linkingVerificationId),
      linkingError: clearLinkingError
          ? null
          : (linkingError ?? this.linkingError),
      linkingSuccess: linkingSuccess ?? this.linkingSuccess,
      signUpLoading: signUpLoading ?? this.signUpLoading,
      signUpVerificationId: clearSignUpVerificationId
          ? null
          : (signUpVerificationId ?? this.signUpVerificationId),
      signUpError: clearSignUpError ? null : (signUpError ?? this.signUpError),
    );
  }
}

/// Auth Provider - مزود المصادقة
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(AuthState()) {
    // Check if user is already logged in (only on supported platforms)
    if (_isFirebaseAvailable) {
      unawaited(_checkCurrentUser());
    }
  }
  final AuthRepository _authRepository;

  /// Check if user is already logged in
  Future<void> _checkCurrentUser() async {
    if (!_isFirebaseAvailable) return;

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (Failure failure) =>
          debugPrint('Error checking current user: ${failure.message}'),
      (UserModel user) =>
          state = state.copyWith(user: user, isAuthenticated: true),
    );
  }

  /// Login with Email and Password
  Future<void> loginWithEmail(
    String email,
    String password, {
    String? fullName,
    String? phoneNumber,
    UserType userType = UserType.patient,
    String? licenseNumber,
    List<String>? specializations,
    String? clinicName,
    String? clinicAddress,
    List<String>? consultationTypes,
    String? username,
    bool isRegistration = false,
  }) async {
    state = state.copyWith(isLoading: true);

    if (isRegistration) {
      // Registration flow
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName ?? email.split('@').first,
        userType: userType,
        phoneNumber: phoneNumber,
        licenseNumber: licenseNumber,
        specializations: specializations,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        consultationTypes: consultationTypes,
        username: username,
      );

      await result.fold(
        (Failure failure) async {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            isAuthenticated: false,
          );
        },
        (UserModel user) async {
          // Initialize Background Service (Mobile only)
          if (!kIsWeb) {
            try {
              await BackgroundService.init();
              await BackgroundService.registerPeriodicTask();
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Background service initialization skipped: $e');
              }
            }
          }

          // Save credentials for biometric login (non-fatal)
          try {
            await _saveCredentials(email, password);
          } catch (credError) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ [AuthProvider] _saveCredentials failed during registration: $credError',
              );
            }
          }

          state = state.copyWith(
            user: user,
            isLoading: false,
            isAuthenticated: true,
            clearError: true,
          );
        },
      );
    } else {
      // Login flow
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      await result.fold(
        (Failure failure) async {
          if (kDebugMode) {
            debugPrint('❌ [AuthProvider] Login failed: ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            isAuthenticated: false,
          );
        },
        (UserModel user) async {
          try {
            // Save credentials for biometric login
            try {
              await _saveCredentials(email, password);
            } catch (credError) {
              if (kDebugMode) {
                debugPrint(
                  '⚠️ [AuthProvider] _saveCredentials failed: $credError',
                );
              }
            }

            await _handleLoginSuccess(user, userType);
          } catch (e, st) {
            debugPrint('❌ [AuthProvider] Unexpected error in login flow: $e');
            debugPrint('   $st');
            state = state.copyWith(
              isLoading: false,
              error: 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.',
              isAuthenticated: false,
            );
          }
        },
      );
    }
  }

  /// بدء عملية التحقق من رقم الهاتف
  Future<void> startPhoneVerification(String phoneNumber) async {
    state = state.copyWith(isPhoneLoading: true, clearPhoneError: true);
    if (kDebugMode) {
      debugPrint(
        '📲 [AuthProvider] Starting phone verification for: $phoneNumber',
      );
    }

    final result = await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] Phone verification failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          isPhoneLoading: false,
          phoneAuthErrorMessage: failure.message,
        );
      },
      (data) {
        if (kDebugMode) {
          debugPrint(
            '📨 [AuthProvider] Code sent or auto-verified. ID: ${data.verificationId}',
          );
        }
        state = state.copyWith(
          isPhoneLoading: false,
          verificationId: data.verificationId,
          resendToken: data.resendToken,
        );

        if (data.isAutoVerified) {
          if (kDebugMode) {
            debugPrint('✅ [AuthProvider] Auto-verified, checking current user');
          }
          _checkCurrentUser();
        }
      },
    );
  }

  /// التحقق من رمز SMS
  Future<void> verifyOtp(String smsCode, UserType requestedType) async {
    // If verificationId is missing (e.g. app restart), we can't proceed
    if (state.verificationId == null) {
      state = state.copyWith(
        phoneAuthErrorMessage: 'انتهت صلاحية الجلسة، يرجى بدء العملية من جديد.',
      );
      return;
    }

    state = state.copyWith(isPhoneLoading: true, clearPhoneError: true);

    final result = await _authRepository.signInWithPhoneNumber(
      verificationId: state.verificationId!,
      smsCode: smsCode,
    );

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] OTP verification failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          isPhoneLoading: false,
          phoneAuthErrorMessage: failure.message,
        );
      },
      (user) async {
        if (kDebugMode) {
          debugPrint('✅ [AuthProvider] OTP verified successfully');
        }
        await _handleLoginSuccess(user, requestedType);
      },
    );
  }

  /// معالجة نجاح تسجيل الدخول (فحص الحساب والنوع والخدمات)
  Future<void> _handleLoginSuccess(
    UserModel user,
    UserType requestedType,
  ) async {
    // 1. فحص نشاط الحساب
    if (!user.isActive) {
      if (kDebugMode) {
        debugPrint('🚫 [AuthProvider] Account inactive');
      }
      await _authRepository.signOut();
      state = state.copyWith(
        isLoading: false,
        isPhoneLoading: false,
        error: 'الحساب معطّل، برجاء التواصل مع الدعم.',
        isAuthenticated: false,
      );
      return;
    }

    // 2. فحص نوع الحساب (إلا إذا كان مسؤولاً)
    if (user.userType != UserType.admin && user.userType != requestedType) {
      if (kDebugMode) {
        debugPrint('🚫 [AuthProvider] User type mismatch');
      }
      await _authRepository.signOut();
      String label(UserType t) => switch (t) {
        UserType.doctor => 'طبيب',
        UserType.patient => 'مريض',
        UserType.admin => 'مسؤول',
      };
      final actualType = label(user.userType);
      final requestedTypeLabel = label(requestedType);
      state = state.copyWith(
        isLoading: false,
        isPhoneLoading: false,
        error:
            'بيانات الدخول غير صحيحة. هذا الحساب مسجل كـ $actualType، يرجى استخدام خيار تسجيل دخول $requestedTypeLabel.',
        isAuthenticated: false,
      );
      return;
    }

    // 3. تهيئة الخدمات الخلفية (للجوال فقط)
    if (!kIsWeb) {
      try {
        await BackgroundService.init();
        await BackgroundService.registerPeriodicTask();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [AuthProvider] Background service init failed: $e');
        }
      }
    }

    // 4. تحديث الحالة النهائية
    state = state.copyWith(
      user: user,
      isLoading: false,
      isPhoneLoading: false,
      isAuthenticated: true,
      clearError: true,
      clearPhoneError: true,
    );
  }

  // ── Phone Linking Methods ───────────────────────────────────────────────

  /// بدء عملية ربط رقم الهاتف بالحساب الحالي.
  ///
  /// يُرسل رمز OTP إلى [phoneNumber] ويخزّن [linkingVerificationId] في الحالة.
  /// يجب استدعاء [confirmPhoneLinking] لاحقاً بعد إدخال المستخدم للرمز.
  ///
  /// لا يؤثر هذا الأسلوب على حقول تسجيل الدخول العادية (verificationId, etc.).
  Future<void> startPhoneLinking({required String phoneNumber}) async {
    state = state.copyWith(
      isLinking: true,
      clearLinkingError: true,
      linkingSuccess: false,
    );

    if (kDebugMode) {
      debugPrint(
        '🔗 [AuthProvider] startPhoneLinking: phone=$phoneNumber',
      );
    }

    final result = await _authRepository.verifyPhoneNumberForLinking(
      phoneNumber: phoneNumber,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] startPhoneLinking failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          isLinking: false,
          linkingError: failure.message,
        );
      },
      (data) {
        if (kDebugMode) {
          debugPrint(
            '✅ [AuthProvider] OTP sent for linking. verificationId=${data.verificationId}',
          );
        }
        state = state.copyWith(
          isLinking: false,
          linkingVerificationId: data.verificationId,
          clearLinkingError: true,
        );
      },
    );
  }

  /// تأكيد ربط الهاتف باستخدام رمز OTP.
  ///
  /// يستدعي [AuthRepository.linkPhoneToCurrentUser] ليربط المزوّد الهاتفي بالـ uid الحالي
  /// دون تغيير الـ uid أو وثيقة Firestore الأساسية.
  ///
  /// عند النجاح: يُحدَّث [state.user] برقم الهاتف الجديد وتُعيَّن [linkingSuccess]=true.
  /// عند الفشل: تُعيَّن [linkingError] برسالة عربية واضحة.
  Future<void> confirmPhoneLinking({required String smsCode}) async {
    final verificationId = state.linkingVerificationId;
    if (verificationId == null) {
      state = state.copyWith(
        linkingError: 'انتهت صلاحية الجلسة، يرجى إعادة إرسال رمز التحقق.',
      );
      return;
    }

    state = state.copyWith(isLinking: true, clearLinkingError: true);

    if (kDebugMode) {
      debugPrint('🔗 [AuthProvider] confirmPhoneLinking: verifying OTP...');
    }

    final result = await _authRepository.linkPhoneToCurrentUser(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] confirmPhoneLinking failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          isLinking: false,
          linkingError: failure.message,
          linkingSuccess: false,
        );
      },
      (updatedUser) async {
        if (kDebugMode) {
          debugPrint(
            '✅ [AuthProvider] Phone linked! uid=${updatedUser.id} phone=${updatedUser.phoneNumber}',
          );
        }
        // Update the in-memory user and signal success
        state = state.copyWith(
          isLinking: false,
          clearLinkingError: true,
          clearLinkingVerificationId: true,
          linkingSuccess: true,
          user: updatedUser,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Patient Sign-Up (Step 1 + Step 2)
  // ---------------------------------------------------------------------------

  /// ⚠️ Patient sign-up only — Step 1.
  ///
  /// Creates a Firebase email/password account and sends an OTP to [phoneNumber].
  /// On success, [state.signUpVerificationId] is set and the caller should navigate
  /// to [SignUpOtpScreen].  No Firestore document is written at this stage.
  Future<void> startSignUpWithEmailAndPhone({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? username,
  }) async {
    state = state.copyWith(
      signUpLoading: true,
      clearSignUpError: true,
      clearSignUpVerificationId: true,
    );

    final result = await _authRepository.startSignUpWithEmailAndPhone(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      username: username,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] startSignUpWithEmailAndPhone failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          signUpLoading: false,
          signUpError: failure.message,
        );
      },
      (verificationId) {
        if (kDebugMode) {
          debugPrint(
            '✅ [AuthProvider] Email account created + OTP sent. verificationId=$verificationId',
          );
        }
        state = state.copyWith(
          signUpLoading: false,
          signUpVerificationId: verificationId,
          clearSignUpError: true,
        );
      },
    );
  }

  /// ⚠️ Patient sign-up only — Step 2.
  ///
  /// Confirms the OTP, links the phone to the email/password account, then
  /// creates the Firestore `users/{uid}` document.
  /// On success: [state.isAuthenticated] = true and [state.user] is populated.
  /// On failure: [state.signUpError] is set with an Arabic message.
  Future<void> confirmSignUpOtp({required String smsCode}) async {
    final verificationId = state.signUpVerificationId;
    if (verificationId == null) {
      state = state.copyWith(
        signUpError: 'انتهت جلسة التسجيل، يرجى المحاولة مرة أخرى',
      );
      return;
    }

    state = state.copyWith(signUpLoading: true, clearSignUpError: true);

    final result = await _authRepository.confirmSignUpAndCreateProfile(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint(
            '❌ [AuthProvider] confirmSignUpOtp failed: ${failure.message}',
          );
        }
        state = state.copyWith(
          signUpLoading: false,
          signUpError: failure.message,
        );
      },
      (newUser) async {
        if (kDebugMode) {
          debugPrint(
            '✅ [AuthProvider] Patient sign-up complete! uid=${newUser.id} phone=${newUser.phoneNumber}',
          );
        }
        // Initialize background service
        if (!kIsWeb) {
          try {
            await BackgroundService.init();
            await BackgroundService.registerPeriodicTask();
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Background service init skipped: $e');
            }
          }
        }
        state = state.copyWith(
          signUpLoading: false,
          clearSignUpError: true,
          clearSignUpVerificationId: true,
          user: newUser,
          isAuthenticated: true,
          isLoading: false,
        );
      },
    );
  }

  /// Login with Biometric
  Future<void> loginWithBiometric() async {
    state = state.copyWith(isLoading: true);

    try {
      final auth = LocalAuthentication();

      // Check if device supports biometrics
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        state = state.copyWith(
          isLoading: false,
          error: 'الجهاز لا يدعم المصادقة البيومترية',
        );
        return;
      }

      // Check if Biometric is enabled in settings
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'تم تعطيل الدخول بالبصمة من الإعدادات',
        );
        return;
      }

      final currentUserResult = await _authRepository.getCurrentUser();

      // If user is logged in, just verify biometric
      if (currentUserResult.isRight()) {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'يرجى تأكيد الهوية لتسجيل الدخول',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (!didAuthenticate) {
          state = state.copyWith(
            isLoading: false,
            error: 'فشلت عملية التحقق من البصمة',
          );
          return;
        }
        currentUserResult.fold(
          (Failure failure) {},
          (UserModel user) => state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          ),
        );
        return;
      }

      // If not logged in, fetch credentials
      final credentials = await _getCredentials();
      if (credentials == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'يرجى تسجيل الدخول بكلمة المرور لمرة واحدة لتفعيل هذه الميزة',
        );
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'يرجى تأكيد الهوية لتسجيل الدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!didAuthenticate) {
        state = state.copyWith(
          isLoading: false,
          error: 'فشلت عملية التحقق من البصمة',
        );
        return;
      }

      // Auto-login with stored credentials
      final result = await _authRepository.signIn(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      result.fold(
        (Failure failure) => state = state.copyWith(
          isLoading: false,
          error: 'فشل تسجيل الدخول التلقائي: ${failure.message}',
        ),
        (UserModel user) => state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ في المصادقة: $e',
      );
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.resetPassword(email);
    result.fold(
      (Failure failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (Unit unit) => state = state.copyWith(isLoading: false),
    );
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.signOut();
    // Do NOT clear credentials here, otherwise biometric login won't work!
    state = AuthState();
  }

  /// Clear Error
  void clearError() {
    state = state.copyWith();
  }

  /// Update Working Hours
  Future<void> updateWorkingHours(
    Map<String, List<String>> workingHours,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(isLoading: true);

    final updatedUser = currentUser.copyWith(workingHours: workingHours);
    final result = await _authRepository.updateUser(updatedUser);

    result.fold(
      (Failure failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (Unit unit) =>
          state = state.copyWith(user: updatedUser, isLoading: false),
    );
  }

  /// Check if Biometric is Enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  /// Set Biometric Enabled
  Future<void> setBiometricEnabled({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    if (!enabled) {
      // Only clear credentials if user explicitly disables the feature
      await _clearCredentials();
    }
  }

  /// Secure Storage Instance
  final _storage = const FlutterSecureStorage();

  /// Save Credentials Securely
  Future<void> _saveCredentials(String email, String password) async {
    try {
      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_password', value: password);
    } on Exception catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  /// Get Saved Credentials
  Future<Map<String, String>?> _getCredentials() async {
    try {
      final email = await _storage.read(key: 'user_email');
      final password = await _storage.read(key: 'user_password');
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    } on Exception catch (e) {
      debugPrint('Error reading credentials: $e');
    }
    return null;
  }

  /// Clear Credentials
  Future<void> _clearCredentials() async {
    try {
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_password');
    } on Exception catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  /// Delete Account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.deleteAccount();

    await result.fold(
      (Failure failure) {
        if (failure.message == 'requires-recent-login') {
          state = state.copyWith(
            isLoading: false,
            error: 'لحذف الحساب، يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى',
          );
        } else {
          state = state.copyWith(isLoading: false, error: failure.message);
        }
      },
      (Unit unit) async {
        await _clearCredentials();
        await setBiometricEnabled(enabled: false);
        await _authRepository.signOut(); // Ensure signed out
        state = AuthState();
      },
    );
  }

  /// Update User Data
  Future<void> updateUserData(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.updateUser(updatedUser);
    result.fold(
      (Failure failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (Unit unit) =>
          state = state.copyWith(user: updatedUser, isLoading: false),
    );
  }
}

/// Auth Provider Instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(GetIt.I<AuthRepository>());
});

/// Provider to get registered doctors from Firestore (real-time)
final AutoDisposeStreamProvider<List<UserModel>> registeredDoctorsProvider =
    StreamProvider.autoDispose<List<UserModel>>((
      ref,
    ) {
      return GetIt.I<DoctorRepository>().getDoctorsStream();
    });

/// Provider to get registered doctors (one-time fetch)
final AutoDisposeFutureProvider<List<UserModel>> registeredDoctorsListProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
      final result = await GetIt.I<DoctorRepository>().getDoctors();
      return result.fold((failure) => [], (doctors) => doctors);
    });
