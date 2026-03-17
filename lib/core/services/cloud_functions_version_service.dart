import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Cloud Functions Version Verification Service
/// خدمة التحقق من إصدار Cloud Functions
///
/// This service verifies that the deployed Cloud Functions include the database
/// configuration fix and are targeting the correct 'elajtech' database.
/// تتحقق هذه الخدمة من أن Cloud Functions المنشورة تتضمن إصلاح تكوين قاعدة البيانات
/// وتستهدف قاعدة البيانات الصحيحة 'elajtech'.
///
/// **CRITICAL DATABASE RULES:**
/// - Cloud Functions must use `databaseId: 'elajtech'`
/// - This service verifies the deployed version includes the fix
/// - Logs warnings if configuration is incorrect
///
/// **Usage Example:**
/// ```dart
/// final versionService = getIt<CloudFunctionsVersionService>();
/// await versionService.verifyCloudFunctionsVersion();
/// ```
@lazySingleton
class CloudFunctionsVersionService {
  CloudFunctionsVersionService(this._functions);

  /// Firebase Functions instance configured for europe-west1 region
  /// نسخة Firebase Functions مكونة لمنطقة europe-west1
  final FirebaseFunctions _functions;

  /// Verify Cloud Functions version and database configuration
  /// التحقق من إصدار Cloud Functions وتكوين قاعدة البيانات
  ///
  /// Calls the `getFunctionsVersion` endpoint to retrieve:
  /// - Functions version number
  /// - Deployment timestamp
  /// - Database ID being used
  /// - Whether database config fix is present
  ///
  /// Logs all information to debug console and warns if configuration is incorrect.
  ///
  /// Returns:
  /// - Map with version information if successful
  /// - null if verification fails
  ///
  /// Example:
  /// ```dart
  /// final versionInfo = await service.verifyCloudFunctionsVersion();
  /// if (versionInfo != null) {
  ///   print('Functions Version: ${versionInfo['version']}');
  ///   print('Database ID: ${versionInfo['databaseId']}');
  /// }
  /// ```
  Future<Map<String, dynamic>?> verifyCloudFunctionsVersion() async {
    try {
      if (kDebugMode) {
        debugPrint('\n☁️ ===== Cloud Functions Version Verification =====');
      }

      // Call getFunctionsVersion endpoint
      final result = await _functions
          .httpsCallable('getFunctionsVersion')
          .call<Map<String, dynamic>>()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Version check timed out after 10 seconds');
            },
          );

      final data = result.data;

      // Log version information
      if (kDebugMode) {
        debugPrint('☁️ Cloud Functions Version: ${data['version']}');
        debugPrint('☁️ Deployed At: ${data['deployedAt']}');
        debugPrint('☁️ Database ID: ${data['databaseId']}');
        debugPrint(
          '☁️ Database Config Fix Present: ${data['hasDatabaseConfigFix']}',
        );
        debugPrint('☁️ Timestamp: ${data['timestamp']}');
      }

      // Verify database configuration
      final databaseId = data['databaseId'] as String?;
      final hasDatabaseConfigFix = data['hasDatabaseConfigFix'] as bool?;

      if (databaseId != 'elajtech') {
        debugPrint(
          '❌ WARNING: Cloud Functions not using elajtech database!',
        );
        debugPrint('❌ Current database: $databaseId');
        debugPrint('❌ Expected database: elajtech');
        debugPrint(
          '❌ This may cause "Appointment Not Found" errors!',
        );
      } else {
        if (kDebugMode) {
          debugPrint('✅ Cloud Functions correctly configured for elajtech');
        }
      }

      if (hasDatabaseConfigFix != true) {
        debugPrint(
          '⚠️ WARNING: Database config fix not present in deployed version!',
        );
        debugPrint(
          '⚠️ This may cause database query issues!',
        );
      } else {
        if (kDebugMode) {
          debugPrint('✅ Database config fix is present');
        }
      }

      if (kDebugMode) {
        debugPrint('☁️ ===== Version Verification Complete =====\n');
      }

      return data;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Error verifying Cloud Functions version: ${e.code}');
      debugPrint('❌ Message: ${e.message}');

      if (e.code == 'not-found') {
        debugPrint(
          '❌ getFunctionsVersion endpoint not found!',
        );
        debugPrint(
          '❌ This may indicate an old deployment without the fix.',
        );
      }

      return null;
    } on Exception catch (e) {
      debugPrint('❌ Unexpected error verifying Cloud Functions version: $e');
      return null;
    }
  }

  /// Get version information without logging (for programmatic use)
  /// الحصول على معلومات الإصدار بدون تسجيل (للاستخدام البرمجي)
  ///
  /// Returns version information map or null if call fails.
  /// Useful when you need to check version programmatically without debug logs.
  ///
  /// Example:
  /// ```dart
  /// final versionInfo = await service.getVersionInfo();
  /// if (versionInfo != null && versionInfo['databaseId'] != 'elajtech') {
  ///   showError('Database configuration error');
  /// }
  /// ```
  Future<Map<String, dynamic>?> getVersionInfo() async {
    try {
      final result = await _functions
          .httpsCallable('getFunctionsVersion')
          .call<Map<String, dynamic>>()
          .timeout(const Duration(seconds: 10));

      return result.data;
    } on Exception {
      return null;
    }
  }

  /// Check if database configuration is correct
  /// التحقق من صحة تكوين قاعدة البيانات
  ///
  /// Returns:
  /// - true if databaseId is 'elajtech' and fix is present
  /// - false otherwise
  ///
  /// Example:
  /// ```dart
  /// final isConfigured = await service.isDatabaseConfigured();
  /// if (!isConfigured) {
  ///   showWarning('Database configuration issue detected');
  /// }
  /// ```
  Future<bool> isDatabaseConfigured() async {
    final versionInfo = await getVersionInfo();
    if (versionInfo == null) return false;

    final databaseId = versionInfo['databaseId'] as String?;
    final hasFix = versionInfo['hasDatabaseConfigFix'] as bool?;

    return databaseId == 'elajtech' && (hasFix ?? false);
  }
}
