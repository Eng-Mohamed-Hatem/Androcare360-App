import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart'; // 👈 أضف هذا السطر يدوياً

/// خدمة تحديث رمز المصادقة - Token Refresh Service
///
/// Force Refresh User Token Service for Firebase Authentication
///
/// تدير هذه الخدمة تحديث رموز المصادقة (ID Tokens) في Firebase Auth بشكل إجباري
/// لضمان أن Custom Claims محدثة على الأجهزة الحقيقية قبل العمليات الحساسة.
///
/// This service manages forced refresh of Firebase Auth ID tokens to ensure
/// custom claims are up-to-date on real devices before sensitive operations.
///
/// **Key Features:**
/// - Force refresh Firebase Auth ID tokens
/// - Validate token freshness before operations
/// - Retrieve fresh tokens with automatic refresh
/// - Check user authentication status
/// - Get current user ID safely
///
/// **Use Cases:**
/// - Before saving medical records (EMR, prescriptions, lab requests)
/// - Before performing role-based operations (doctor-only actions)
/// - After user role changes or permission updates
/// - When custom claims need to be refreshed from server
///
/// **Why Token Refresh is Critical:**
/// Firebase Auth tokens are cached locally and may contain stale custom claims.
/// When a user's role or permissions change on the server, the local token
/// must be force-refreshed to reflect these changes. This is especially
/// important for:
/// - Role-based access control (RBAC)
/// - Permission validation before sensitive operations
/// - Ensuring security rules have latest user claims
///
/// **Integration Points:**
/// - Used in EMR repositories before saving medical records
/// - Used in auth flows after role changes
/// - Used in permission-sensitive operations
///
/// **Dependency Injection:**
/// This service is registered as a lazy singleton using @lazySingleton.
/// It is automatically injected via GetIt when needed.
///
/// ```dart
/// // Injection setup (handled by injectable)
/// @lazySingleton
/// class TokenRefreshService {
///   TokenRefreshService(this._firebaseAuth);
///   final FirebaseAuth _firebaseAuth;
/// }
/// ```
///
/// **Usage Example:**
/// ```dart
/// // Inject the service
/// final tokenRefreshService = getIt<TokenRefreshService>();
///
/// // Before saving EMR record
/// final refreshed = await tokenRefreshService.forceRefreshToken();
/// if (refreshed) {
///   // Token is fresh, proceed with save
///   await emrRepository.saveRecord(record);
/// } else {
///   // Token refresh failed, handle error
///   return Left(AuthFailure('Failed to refresh authentication'));
/// }
///
/// // Get fresh token for API calls
/// final token = await tokenRefreshService.getFreshToken();
/// if (token != null) {
///   // Use token in API request
///   final response = await apiClient.post('/save', token: token);
/// }
///
/// // Validate token before operation
/// final isValid = await tokenRefreshService.validateAndRefreshTokenIfNeeded();
/// if (isValid) {
///   // Proceed with operation
/// }
/// ```
///
/// **Error Handling:**
/// All methods return boolean or nullable values to indicate success/failure.
/// Errors are logged using debugPrint for debugging purposes.
///
/// **Performance Considerations:**
/// - Token refresh requires network call to Firebase servers
/// - Use validateAndRefreshTokenIfNeeded() to avoid unnecessary refreshes
/// - Cache results when appropriate to minimize network calls
///
/// **Security Notes:**
/// - Never expose ID tokens in logs or error messages
/// - Always validate token freshness before sensitive operations
/// - Use HTTPS for all token-related network calls
@lazySingleton
class TokenRefreshService {
  TokenRefreshService(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  /// تحديث User Token بشكل إجباري
  /// Force refresh user's ID token
  ///
  /// هذه الدالة تُستخدم لتحديث Token بشكل إجباري قبل العمليات الحساسة
  /// مثل حفظ البيانات الطبية (EMR، وصفات، إلخ)
  ///
  /// Returns true إذا تم التحديث بنجاح، false في حالة الفشل
  Future<bool> forceRefreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('⚠️ TokenRefreshService: No user logged in');
        return false;
      }

      // تحديث Token بشكل إجباري
      // المعلمة true تُجبر Firebase على تحديث Token من السيرفر
      await user.getIdToken(true); // true = force refresh

      debugPrint('✅ TokenRefreshService: User token refreshed successfully');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ TokenRefreshService: Failed to refresh token: $e');
      return false;
    }
  }

  /// الحصول على Token جديد مع التحقق من الصلاحية
  /// Get a fresh token with validation
  ///
  /// هذه الدالة تُحاول الحصول على Token جديد مع التحقق من صلاحيتة
  /// إذا فشلت، تقوم بتحديثه بشكل إجباري
  ///
  /// Returns Token إذا كان صالحاً، null في حالة الفشل
  Future<String?> getFreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('⚠️ TokenRefreshService: No user logged in');
        return null;
      }

      // تحديث Token بشكل إجباري
      final token = await user.getIdToken(true);

      if (token != null && token.isNotEmpty) {
        debugPrint(
          '✅ TokenRefreshService: Fresh token obtained (length: ${token.length})',
        );
        return token;
      }

      debugPrint('⚠️ TokenRefreshService: Token is empty');
      return null;
    } on Exception catch (e) {
      debugPrint('❌ TokenRefreshService: Failed to get fresh token: $e');
      return null;
    }
  }

  /// التحقق من صلاحية Token وتحديثه إذا لزم الأمر
  /// Validate token and refresh if needed
  ///
  /// هذه الدالة تُحاول الحصول على Token بدون تحديث إجباري أولاً
  /// إذا كان Token صالحاً، تُرجعه مباشرة
  /// إذا لم يكن صالحاً، تقوم بتحديثه بشكل إجباري
  ///
  /// Returns true إذا كان Token صالحاً أو تم تحديثه بنجاح
  Future<bool> validateAndRefreshTokenIfNeeded() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('⚠️ TokenRefreshService: No user logged in');
        return false;
      }

      // محاولة الحصول على Token بدون تحديث إجباري
      final token = await user.getIdToken();

      // إذا نجح، Token صالح
      if (token != null && token.isNotEmpty) {
        debugPrint(
          '✅ TokenRefreshService: Token is valid (length: ${token.length})',
        );
        return true;
      }

      // إذا فشل، قم بتحديثه بشكل إجباري
      debugPrint('⚠️ TokenRefreshService: Token invalid, refreshing...');
      return await forceRefreshToken();
    } on Exception catch (e) {
      debugPrint('❌ TokenRefreshService: Failed to validate token: $e');
      // محاولة التحديث بشكل إجباري كحل أخير
      return forceRefreshToken();
    }
  }

  /// الحصول على UID للمستخدم الحالي
  /// Get current user UID
  ///
  /// Returns UID إذا كان المستخدم مسجل الدخول، null في حالة الفشل
  String? getCurrentUserId() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('⚠️ TokenRefreshService: No user logged in');
      return null;
    }
    return user.uid;
  }

  /// التحقق من أن المستخدم مسجل الدخول
  /// Check if user is logged in
  ///
  /// Returns true إذا كان المستخدم مسجل الدخول
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}
