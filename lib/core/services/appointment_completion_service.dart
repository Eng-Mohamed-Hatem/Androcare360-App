import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:elajtech/core/errors/exceptions.dart';

/// Appointment Completion Service - خدمة إكمال المواعيد
/// Appointment completion and finalization service for the elajtech platform.
///
/// **Responsibilities / المسؤوليات:**
/// - Manually completing appointments from doctor's side / إكمال الموعد يدوياً من جانب الطبيب
/// - Calling Cloud Function to update appointment status to 'completed' / استدعاء Cloud Function لتحديث حالة الموعد إلى 'completed'
/// - Validating doctor permissions before completion / التحقق من صلاحيات الطبيب
/// - Triggering post-completion workflows (notifications, billing) / تفعيل سير العمل بعد الإكمال
/// - Ensuring data consistency across related collections / ضمان اتساق البيانات
///
/// **Singleton Pattern:**
/// ```dart
/// class AppointmentCompletionService {
///   factory AppointmentCompletionService() => _instance;
///   AppointmentCompletionService._internal();
///   static final AppointmentCompletionService _instance = AppointmentCompletionService._internal();
/// }
/// ```
///
/// **Usage Example:**
/// ```dart
/// final service = AppointmentCompletionService();
///
/// // Complete an appointment manually
/// final result = await service.completeAppointment(
///   appointmentId: 'apt_123',
///   doctorId: 'doc_456',
/// );
///
/// if (result.success) {
///   showSuccess(result.message ?? 'تم إكمال الموعد بنجاح');
/// } else {
///   showError(result.error ?? 'فشل إكمال الموعد');
/// }
/// ```
///
/// **Business Rules:**
/// - Only doctors can complete their own appointments
/// - Appointments can only be completed if status is 'active' or 'in_progress'
/// - Completed appointments cannot be modified (immutable)
/// - Completion triggers automatic notifications to patient
/// - Completion timestamp is recorded for billing and analytics
///
/// **Cloud Functions Integration:**
/// - Region: 'europe-west1'
/// - Function: 'completeAppointment'
/// - Validates doctor permissions server-side
/// - Updates Firestore atomically
///
/// **Database Structure:**
/// - Collection: `appointments/{appointmentId}`
/// - Fields updated: `status`, `completedAt`, `lastModified`
/// - Database ID: 'elajtech'
///
/// **Integration Points:**
/// - Works with NotificationService for completion alerts
/// - Updates billing records via BillingService
/// - Logs completion events via CallMonitoringService
///
/// @see VideoConsultationService for consultation management
/// @see NotificationService for completion notifications
/// @see CompletionResult for return value structure
class AppointmentCompletionService {
  factory AppointmentCompletionService() => _instance;
  AppointmentCompletionService._internal();
  static final AppointmentCompletionService _instance =
      AppointmentCompletionService._internal();

  /// Lazy-initialized FirebaseFunctions instance
  FirebaseFunctions? _functionsInstance;

  /// Getter for FirebaseFunctions instance with lazy initialization
  FirebaseFunctions get _functions {
    _functionsInstance ??= FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    );
    return _functionsInstance!;
  }

  /// Completes an appointment manually from doctor's side.
  /// يُكمل موعداً يدوياً من جانب الطبيب.
  ///
  /// This method finalizes an appointment by:
  /// 1. Validating input parameters (appointmentId, doctorId)
  /// 2. Calling Cloud Function 'completeAppointment' in europe-west1 region
  /// 3. Verifying doctor has permission to complete this appointment
  /// 4. Updating appointment status to 'completed' in Firestore
  /// 5. Triggering post-completion workflows (notifications, billing)
  ///
  /// **Parameters:**
  /// - [appointmentId]: Unique identifier for the appointment to complete (required) / معرف الموعد
  /// - [doctorId]: Doctor's user ID requesting completion (required for authorization) / معرف الطبيب
  ///
  /// **Returns:**
  /// A [CompletionResult] containing:
  /// - `success`: Whether the appointment was completed successfully
  /// - `message`: Success message in Arabic
  /// - `error`: Error message if failed
  ///
  /// **Throws:**
  /// - [FirebaseFunctionsException] if Cloud Function call fails
  /// - [FirestoreException] if Firestore update fails
  /// - [NetworkException] if network connection fails
  /// - [Exception] for unexpected errors
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final result = await appointmentCompletionService.completeAppointment(
  ///     appointmentId: 'apt_20240212_001',
  ///     doctorId: 'doc_123',
  ///   );
  ///
  ///   if (result.success) {
  ///     print('Success: ${result.message}');
  ///     navigateToCompletedAppointments();
  ///   } else {
  ///     showError(result.error ?? 'فشل إكمال الموعد');
  ///   }
  /// } catch (e) {
  ///   print('Unexpected error: $e');
  /// }
  /// ```
  ///
  /// **Authorization:**
  /// - Cloud Function validates doctor has permission
  /// - Only the assigned doctor can complete the appointment
  /// - Returns error if doctor ID doesn't match appointment
  ///
  /// **Cloud Function Payload:**
  /// ```json
  /// {
  ///   "appointmentId": "apt_123",
  ///   "doctorId": "doc_456"
  /// }
  /// ```
  ///
  /// **Error Handling:**
  /// - Network errors: Returns NetworkException with Arabic message
  /// - Firestore errors: Returns FirestoreException with details
  /// - Function errors: Returns error from Cloud Function
  /// - All errors are logged with debugPrint
  ///
  /// **Side Effects:**
  /// - Sends completion notification to patient
  /// - Triggers billing calculation
  /// - Updates doctor's appointment statistics
  /// - Records completion timestamp
  Future<CompletionResult> completeAppointment({
    required String appointmentId,
    required String doctorId,
  }) async {
    try {
      debugPrint('✅ Completing appointment: $appointmentId');

      final callable = _functions.httpsCallable('completeAppointment');

      final result = await callable.call<Map<String, dynamic>?>({
        'appointmentId': appointmentId,
        'doctorId': doctorId,
      });

      final data = result.data;
      if (data == null) {
        throw Exception('لم يتم استلام بيانات من الخادم');
      }

      debugPrint('✅ Appointment completed successfully');

      return CompletionResult(
        success: true,
        message: data['message'] as String? ?? 'تم إكمال الموعد بنجاح',
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Firebase Functions Error: ${e.code} - ${e.message}');
      return CompletionResult(
        success: false,
        error: e.message ?? 'حدث خطأ أثناء إكمال الموعد',
      );
    } on FirestoreException catch (e) {
      debugPrint('❌ Firestore Error: ${e.message}');
      return CompletionResult(
        success: false,
        error: e.message,
      );
    } on NetworkException catch (e) {
      debugPrint('❌ Network Error: ${e.message}');
      return CompletionResult(
        success: false,
        error: e.message,
      );
    } on Exception catch (e) {
      debugPrint('❌ Error completing appointment: $e');
      return CompletionResult(
        success: false,
        error: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
}

/// Result object returned from appointment completion operation.
/// نتيجة عملية إكمال الموعد.
///
/// Contains success/failure status and relevant messages.
///
/// **Success Case:**
/// ```dart
/// CompletionResult(
///   success: true,
///   message: 'تم إكمال الموعد بنجاح',
/// )
/// ```
///
/// **Failure Case:**
/// ```dart
/// CompletionResult(
///   success: false,
///   error: 'حدث خطأ أثناء إكمال الموعد',
/// )
/// ```
class CompletionResult {
  /// Creates a new CompletionResult instance.
  /// ينشئ نسخة جديدة من نتيجة إكمال الموعد.
  ///
  /// **Parameters:**
  /// - [success]: Whether the appointment was completed successfully
  /// - [message]: Success message (optional, for success case)
  /// - [error]: Error message (required for failure case)
  CompletionResult({
    required this.success,
    this.message,
    this.error,
  });

  /// Whether the appointment was completed successfully.
  /// هل تم إكمال الموعد بنجاح.
  final bool success;

  /// Success message in Arabic.
  /// رسالة النجاح بالعربية / رسالة نجاح.
  ///
  /// Optional message providing confirmation of successful completion.
  final String? message;

  /// Error message in Arabic.
  /// رسالة الخطأ بالعربية / رسالة الخطأ.
  ///
  /// Required when [success] is false. Provides user-friendly error description.
  final String? error;
}
