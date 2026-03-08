import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Data Cleanup Service - خدمة تنظيف البيانات
///
/// Provides batch deletion operations for cleaning up test data and managing
/// data lifecycle in the elajtech application. Supports selective or complete
/// data cleanup with proper error handling and logging.
///
/// توفر عمليات حذف دفعي لتنظيف بيانات الاختبار وإدارة دورة حياة البيانات
/// في تطبيق elajtech. تدعم التنظيف الانتقائي أو الكامل مع معالجة الأخطاء
/// والتسجيل المناسب.
///
/// **Key Features:**
/// - Batch deletion for improved performance
/// - Selective cleanup by data type (doctors, appointments, medical records)
/// - Complete data cleanup with partial failure handling
/// - Debug logging for all operations
/// - Proper Firestore database ID usage (elajtech)
///
/// **Cleanup Operations:**
/// - Delete all registered doctors
/// - Delete all appointments
/// - Delete all medical records (prescriptions, lab/radiology/device requests, EMR, notifications)
/// - Complete cleanup with error aggregation
///
/// **Use Cases:**
/// - Development and testing data cleanup
/// - User account deletion (partial cleanup)
/// - Database maintenance and reset
///
/// **Important Notes:**
/// - All operations use batch writes for efficiency
/// - Partial failures are logged but don't stop other cleanups
/// - Requires appropriate Firestore permissions
/// - Uses elajtech database ID (not default Firestore)
///
/// **Dependency Injection:**
/// This service uses static methods and does not require dependency injection.
/// All methods can be called directly via `DataCleanupService.methodName()`.
///
/// Example usage:
/// ```dart
/// // Delete all appointments
/// try {
///   await DataCleanupService.deleteAppointments();
///   print('Appointments cleaned up successfully');
/// } catch (e) {
///   print('Failed to delete appointments: $e');
/// }
///
/// // Complete cleanup (for testing)
/// try {
///   await DataCleanupService.cleanupAllData();
///   print('All test data cleaned up');
/// } catch (e) {
///   print('Cleanup had partial failures: $e');
/// }
/// ```
class DataCleanupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'elajtech',
  );

  /// Delete a batch of documents from a query snapshot - حذف دفعة من المستندات
  ///
  /// Internal helper method that performs batch deletion of all documents in a
  /// query snapshot. Uses Firestore batch writes for efficient deletion.
  ///
  /// طريقة مساعدة داخلية تقوم بحذف دفعي لجميع المستندات في لقطة استعلام.
  /// تستخدم عمليات الكتابة الدفعية في Firestore للحذف الفعال.
  ///
  /// **Batch Write Limits:**
  /// - Maximum 500 operations per batch
  /// - For larger datasets, consider implementing pagination
  ///
  /// Parameters:
  /// - [querySnapshot]: The query snapshot containing documents to delete (required)
  ///   لقطة الاستعلام التي تحتوي على المستندات المراد حذفها (مطلوب)
  ///
  /// Throws:
  /// - [FirebaseException] if batch commit fails
  ///
  /// **Performance Note:** Batch writes are atomic and more efficient than
  /// individual deletes.
  static Future<void> _deleteQueryBatch(QuerySnapshot querySnapshot) async {
    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Delete all registered doctors - حذف جميع الأطباء المسجلين
  ///
  /// Deletes all user documents with userType='doctor' from the users collection.
  /// This operation is typically used for testing or development data cleanup.
  ///
  /// يحذف جميع مستندات المستخدمين التي تحتوي على userType='doctor' من مجموعة المستخدمين.
  /// تُستخدم هذه العملية عادةً لتنظيف بيانات الاختبار أو التطوير.
  ///
  /// **Operation Details:**
  /// - Queries users collection where userType == 'doctor'
  /// - Uses batch deletion for efficiency
  /// - Logs count of doctors deleted
  /// - Safe to call when no doctors exist
  ///
  /// **Important:** This does NOT delete:
  /// - Doctor's appointments (use deleteAppointments)
  /// - Doctor's medical records (use deleteMedicalRecords)
  /// - Doctor's profile images in Storage
  ///
  /// Throws:
  /// - [Exception] if Firestore query or batch delete fails
  /// - May fail due to insufficient permissions
  ///
  /// **Debug Logging:**
  /// - Logs fetch operation start
  /// - Logs count of doctors found
  /// - Logs deletion success or failure
  ///
  /// Example:
  /// ```dart
  /// // Delete all test doctors
  /// try {
  ///   await DataCleanupService.deleteDoctors();
  ///   print('Test doctors cleaned up');
  /// } catch (e) {
  ///   if (e.toString().contains('permission')) {
  ///     print('Insufficient permissions to delete doctors');
  ///   } else {
  ///     print('Error: $e');
  ///   }
  /// }
  /// ```
  static Future<void> deleteDoctors() async {
    try {
      debugPrint('Fetching doctors to delete...');
      final doctors = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'doctor')
          .get();

      if (doctors.docs.isEmpty) {
        debugPrint('No doctors found to delete.');
        return;
      }

      debugPrint('Deleting ${doctors.docs.length} doctors...');
      await _deleteQueryBatch(doctors);
      debugPrint('Doctors deleted successfully.');
    } on Exception catch (e) {
      debugPrint('Error deleting doctors: $e');
      // Continue throwing to notify UI, but allow other cleanups if this assumes permission issues
      rethrow;
    }
  }

  /// Delete all appointments - حذف جميع المواعيد
  ///
  /// Deletes all documents from the appointments collection. This operation
  /// removes all appointment records regardless of status or date.
  ///
  /// يحذف جميع المستندات من مجموعة المواعيد. تزيل هذه العملية جميع سجلات
  /// المواعيد بغض النظر عن الحالة أو التاريخ.
  ///
  /// **Operation Details:**
  /// - Fetches all documents from appointments collection
  /// - Uses batch deletion for efficiency
  /// - Logs count of appointments deleted
  /// - Safe to call when no appointments exist
  ///
  /// **Use Cases:**
  /// - Testing data cleanup
  /// - Development environment reset
  /// - User account deletion (delete user's appointments only)
  ///
  /// Throws:
  /// - [Exception] if Firestore query or batch delete fails
  ///
  /// **Debug Logging:**
  /// - Logs fetch operation start
  /// - Logs count of appointments found
  /// - Logs deletion success or failure
  ///
  /// Example:
  /// ```dart
  /// // Clean up all test appointments
  /// try {
  ///   await DataCleanupService.deleteAppointments();
  ///   print('All appointments deleted');
  /// } catch (e) {
  ///   print('Failed to delete appointments: $e');
  /// }
  /// ```
  static Future<void> deleteAppointments() async {
    try {
      debugPrint('Fetching appointments to delete...');
      final appointments = await _firestore.collection('appointments').get();

      if (appointments.docs.isEmpty) {
        debugPrint('No appointments found to delete.');
        return;
      }

      debugPrint('Deleting ${appointments.docs.length} appointments...');
      await _deleteQueryBatch(appointments);
      debugPrint('Appointments deleted successfully.');
    } on Exception catch (e) {
      debugPrint('Error deleting appointments: $e');
      rethrow;
    }
  }

  /// Delete all medical records - حذف جميع السجلات الطبية
  ///
  /// Deletes all documents from multiple medical record collections including
  /// prescriptions, lab requests, radiology requests, device requests, EMR records,
  /// and notifications. Processes each collection sequentially.
  ///
  /// يحذف جميع المستندات من مجموعات السجلات الطبية المتعددة بما في ذلك
  /// الوصفات الطبية، طلبات المختبر، طلبات الأشعة، طلبات الأجهزة، سجلات EMR،
  /// والإشعارات. يعالج كل مجموعة بشكل تسلسلي.
  ///
  /// **Collections Cleaned:**
  /// 1. prescriptions - الوصفات الطبية
  /// 2. lab_requests - طلبات المختبر
  /// 3. radiology_requests - طلبات الأشعة
  /// 4. device_requests - طلبات الأجهزة
  /// 5. emr_records - سجلات EMR
  /// 6. notifications - الإشعارات
  ///
  /// **Operation Details:**
  /// - Processes each collection sequentially
  /// - Uses batch deletion for each collection
  /// - Logs progress for each collection
  /// - Skips empty collections without error
  ///
  /// **Performance Note:** This operation may take time for large datasets
  /// as it processes 6 different collections.
  ///
  /// Throws:
  /// - [Exception] if any collection query or batch delete fails
  ///
  /// **Debug Logging:**
  /// - Logs each collection being processed
  /// - Logs document count for each collection
  /// - Logs overall success or failure
  ///
  /// Example:
  /// ```dart
  /// // Clean up all medical records
  /// try {
  ///   await DataCleanupService.deleteMedicalRecords();
  ///   print('All medical records cleaned up');
  /// } catch (e) {
  ///   print('Failed to delete medical records: $e');
  /// }
  /// ```
  static Future<void> deleteMedicalRecords() async {
    try {
      final collections = [
        'prescriptions',
        'lab_requests',
        'radiology_requests',
        'device_requests',
        'emr_records',
        'notifications', // Added notifications as well
      ];

      for (final collection in collections) {
        debugPrint('Fetching $collection to delete...');
        final docs = await _firestore.collection(collection).get();

        if (docs.docs.isNotEmpty) {
          debugPrint(
            'Deleting ${docs.docs.length} documents from $collection...',
          );
          await _deleteQueryBatch(docs);
        }
      }
      debugPrint('Medical records deleted successfully.');
    } on Exception catch (e) {
      debugPrint('Error deleting medical records: $e');
      rethrow;
    }
  }

  /// Delete all data with partial failure handling - حذف جميع البيانات مع معالجة الفشل الجزئي
  ///
  /// Performs a complete cleanup of all data types (appointments, medical records,
  /// doctors) with graceful error handling. If one operation fails, others continue
  /// to execute. All failures are aggregated and reported at the end.
  ///
  /// يقوم بتنظيف كامل لجميع أنواع البيانات (المواعيد، السجلات الطبية، الأطباء)
  /// مع معالجة الأخطاء بشكل سلس. إذا فشلت عملية واحدة، تستمر العمليات الأخرى
  /// في التنفيذ. يتم تجميع جميع الأخطاء والإبلاغ عنها في النهاية.
  ///
  /// **Execution Order:**
  /// 1. Delete appointments
  /// 2. Delete medical records (6 collections)
  /// 3. Delete doctors
  ///
  /// **Error Handling Strategy:**
  /// - Each operation is wrapped in try-catch
  /// - Failures are logged but don't stop subsequent operations
  /// - All errors are aggregated into a single exception at the end
  /// - Useful when permissions vary by collection
  ///
  /// **Use Cases:**
  /// - Complete testing environment reset
  /// - Development data cleanup
  /// - Preparing for fresh data import
  ///
  /// **Important:** This is a destructive operation that cannot be undone.
  /// Use with caution and only in development/testing environments.
  ///
  /// Throws:
  /// - [Exception] with aggregated error messages if any operation fails
  /// - Exception message format: "Cleanup partial failures: {error1}, {error2}, ..."
  ///
  /// **Debug Logging:**
  /// - Logs start of full cleanup
  /// - Logs each operation's success or failure
  /// - Logs completion or partial failures
  ///
  /// Example:
  /// ```dart
  /// // Complete cleanup for testing
  /// try {
  ///   await DataCleanupService.cleanupAllData();
  ///   print('✅ All test data cleaned up successfully');
  /// } catch (e) {
  ///   // Check if partial failures occurred
  ///   if (e.toString().contains('partial failures')) {
  ///     print('⚠️ Some operations failed: $e');
  ///     // Some data was cleaned, some wasn't
  ///   } else {
  ///     print('❌ Cleanup failed: $e');
  ///   }
  /// }
  ///
  /// // Example with permission issues
  /// // If user can delete appointments but not doctors:
  /// // - Appointments: deleted ✅
  /// // - Medical records: deleted ✅
  /// // - Doctors: failed ❌
  /// // Exception thrown with: "Cleanup partial failures: Doctors: permission-denied"
  /// ```
  static Future<void> cleanupAllData() async {
    debugPrint('Starting full data cleanup...');
    // We try/catch each block so one failure doesn't stop the rest
    // e.g. if I can't delete doctors (permission), I might still be able to delete my appointments

    final errors = <String>[];

    try {
      await deleteAppointments();
    } on Exception catch (e) {
      errors.add('Appointments: $e');
    }

    try {
      await deleteMedicalRecords();
    } on Exception catch (e) {
      errors.add('Records: $e');
    }

    try {
      await deleteDoctors();
    } on Exception catch (e) {
      errors.add('Doctors: $e');
    }

    if (errors.isNotEmpty) {
      throw Exception('Cleanup partial failures: ${errors.join(", ")}');
    }

    debugPrint('Full data cleanup completed.');
  }
}
