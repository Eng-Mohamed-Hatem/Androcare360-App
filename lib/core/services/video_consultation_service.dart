import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'package:elajtech/core/errors/exceptions.dart';

/// Video Consultation Service - خدمة الاستشارات المرئية
/// Video consultation management service for the elajtech telemedicine platform.
///
/// **Responsibilities / المسؤوليات:**
/// - Initiating video calls from doctor's side / بدء مكالمة الفيديو من جانب الطبيب
/// - Calling Cloud Function to create Agora token / استدعاء Cloud Function لإنشاء Agora token
/// - Sending VoIP notification to patient / إرسال VoIP notification للمريض
/// - Returning Agora credentials for doctor to join / إرجاع بيانات Agora للطبيب للانضمام
/// - Managing consultation session state / إدارة حالة جلسة الاستشارة
/// - Integrating with Agora RTC engine for real-time video streaming / التكامل مع محرك Agora RTC للبث المباشر
///
/// **Security / الأمان:**
/// - No sensitive data stored in the app / لا يتم تخزين أي بيانات سرية في التطبيق
/// - Agora tokens generated server-side only (short-lived) / يتم توليد Agora token من الخادم فقط (قصير الأمد)
/// - Lazy initialization of Firebase Functions instance / التهيئة الكسولة لنسخة Firebase Functions
///
/// **Singleton Pattern:**
/// ```dart
/// class VideoConsultationService {
///   factory VideoConsultationService() => _instance;
///   VideoConsultationService._internal();
///   static final VideoConsultationService _instance = VideoConsultationService._internal();
/// }
/// ```
///
/// **Usage Example:**
/// ```dart
/// final service = VideoConsultationService();
///
/// // Start a video consultation
/// final result = await service.startVideoCall(
///   appointmentId: 'apt_123',
///   doctorId: 'doc_456',
/// );
///
/// if (result.success) {
///   // Join Agora channel with returned credentials
///   await agoraEngine.joinChannel(
///     token: result.agoraToken!,
///     channelId: result.agoraChannelName!,
///     uid: result.agoraUid!,
///   );
/// } else {
///   print('Error: ${result.error}');
/// }
/// ```
///
/// **Cloud Functions Integration:**
/// - Region: 'europe-west1'
/// - Function: 'startAgoraCall'
/// - Returns: Agora channel credentials and token
///
/// **Integration Points:**
/// - Works with AgoraService for video streaming
/// - Triggers VoIP notifications via Cloud Functions
/// - Updates appointment status in Firestore
/// - Logs call events via CallMonitoringService
///
/// @see AgoraService for video engine integration
/// @see CallMonitoringService for event logging
/// @see StartCallResult for return value structure
class VideoConsultationService {
  factory VideoConsultationService() => _instance;
  VideoConsultationService._internal();
  static final VideoConsultationService _instance =
      VideoConsultationService._internal();

  /// Lazy-initialized FirebaseFunctions instance
  /// تأخير التهيئة لضمان أن Firebase App جاهز قبل استخدام الدوال السحابية
  FirebaseFunctions? _functionsInstance;

  /// Getter for FirebaseFunctions instance with lazy initialization
  /// يتم إنشاء النسخة فقط عند أول استخدام فعلي
  FirebaseFunctions get _functions {
    _functionsInstance ??= FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    );
    return _functionsInstance!;
  }

  /// Starts a video call consultation session.
  /// يبدأ جلسة استشارة مرئية.
  ///
  /// This method initiates a video consultation by:
  /// 1. Validating input parameters (appointmentId, doctorId)
  /// 2. Calling Cloud Function 'startAgoraCall' in europe-west1 region
  /// 3. Generating Agora channel credentials and token
  /// 4. Sending VoIP notification to patient
  /// 5. Returning Agora credentials for doctor to join
  ///
  /// **Parameters:**
  /// - [appointmentId]: Unique identifier for the appointment (required, non-empty) / معرف الموعد
  /// - [doctorId]: Doctor's user ID initiating the call (required, non-empty) / معرف الطبيب
  ///
  /// **Returns:**
  /// A [StartCallResult] containing:
  /// - `success`: Whether the call was started successfully
  /// - `agoraChannelName`: Agora channel ID to join
  /// - `agoraToken`: Short-lived authentication token
  /// - `agoraUid`: Unique user ID for Agora session
  /// - `message`: Success message
  /// - `error`: Error message if failed
  ///
  /// **Throws:**
  /// - [FirebaseFunctionsException] if Cloud Function call fails
  /// - [SocketException] if network connection fails
  /// - [Exception] for unexpected errors
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final result = await videoConsultationService.startVideoCall(
  ///     appointmentId: 'apt_20240212_001',
  ///     doctorId: 'doc_123',
  ///   );
  ///
  ///   if (result.success) {
  ///     print('Channel: ${result.agoraChannelName}');
  ///     print('Token: ${result.agoraToken}');
  ///     // Proceed to join Agora channel
  ///   } else {
  ///     showError(result.error ?? 'Failed to start call');
  ///   }
  /// } catch (e) {
  ///   print('Unexpected error: $e');
  /// }
  /// ```
  ///
  /// **Validation Rules:**
  /// - appointmentId must not be empty
  /// - doctorId must not be empty
  /// - Returns error result if validation fails
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
  /// - Network errors: Returns user-friendly Arabic message
  /// - Function errors: Returns error from Cloud Function
  /// - Validation errors: Returns specific validation message
  /// - All errors are logged with debugPrint in debug mode
  Future<StartCallResult> startVideoCall({
    required String appointmentId,
    required String doctorId,
  }) async {
    try {
      // ✅ Validate parameters before calling Cloud Function
      if (appointmentId.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ [VideoConsultationService] appointmentId is empty');
        }
        return StartCallResult(
          success: false,
          error: 'معرف الموعد مطلوب',
        );
      }

      if (doctorId.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ [VideoConsultationService] doctorId is empty');
        }
        return StartCallResult(
          success: false,
          error: 'معرف الطبيب مطلوب',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '📞 [VideoConsultationService] Starting video call for appointment: $appointmentId',
        );
        debugPrint('👨‍⚕️ [VideoConsultationService] Doctor ID: $doctorId');
        debugPrint('🌍 [VideoConsultationService] Region: europe-west1');
      }

      final callable = _functions.httpsCallable('startAgoraCall');

      final result = await callable.call<Map<String, dynamic>?>({
        'appointmentId': appointmentId,
        'doctorId': doctorId,
      });

      final data = result.data;
      if (data == null) {
        throw const FirestoreException('لم يتم استلام بيانات من الخادم');
      }

      if (kDebugMode) {
        debugPrint(
          '✅ [VideoConsultationService] Agora call started successfully',
        );
        debugPrint(
          '📎 [VideoConsultationService] Channel: ${data['agoraChannelName']}',
        );
      }

      return StartCallResult(
        success: true,
        agoraChannelName: data['agoraChannelName'] as String?,
        agoraToken: data['agoraToken'] as String?,
        agoraUid: data['agoraUid'] as int?,
        message: data['message'] as String? ?? 'تم بدء الاتصال بنجاح',
      );
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VideoConsultationService] Firebase Functions Error: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [VideoConsultationService] Appointment: $appointmentId, Doctor: $doctorId',
        );
        debugPrint('❌ [VideoConsultationService] Stack trace: $stackTrace');
      }
      return StartCallResult(
        success: false,
        error: e.message ?? 'حدث خطأ أثناء بدء المكالمة',
      );
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [VideoConsultationService] Network Error: ${e.message}');
        debugPrint(
          '❌ [VideoConsultationService] Appointment: $appointmentId, Doctor: $doctorId',
        );
        debugPrint('❌ [VideoConsultationService] Stack trace: $stackTrace');
      }
      return StartCallResult(
        success: false,
        error: 'خطأ في الاتصال بالشبكة: تحقق من اتصالك بالإنترنت',
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VideoConsultationService] Unexpected error starting video call: $e',
        );
        debugPrint(
          '❌ [VideoConsultationService] Appointment: $appointmentId, Doctor: $doctorId',
        );
        debugPrint('❌ [VideoConsultationService] Stack trace: $stackTrace');
      }
      return StartCallResult(
        success: false,
        error: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
}

/// Result object returned from video call initiation.
/// نتيجة بدء المكالمة المرئية.
///
/// Contains all necessary information for the doctor to join the Agora video channel,
/// including authentication credentials and channel details.
///
/// **Success Case:**
/// ```dart
/// StartCallResult(
///   success: true,
///   agoraChannelName: 'channel_apt_123',
///   agoraToken: 'eyJhbGc...',
///   agoraUid: 12345,
///   message: 'تم بدء الاتصال بنجاح',
/// )
/// ```
///
/// **Failure Case:**
/// ```dart
/// StartCallResult(
///   success: false,
///   error: 'حدث خطأ أثناء بدء المكالمة',
/// )
/// ```
class StartCallResult {
  /// Creates a new StartCallResult instance.
  /// ينشئ نسخة جديدة من نتيجة بدء المكالمة.
  ///
  /// **Parameters:**
  /// - [success]: Whether the call was started successfully
  /// - [agoraChannelName]: Agora channel ID (required for success case)
  /// - [agoraToken]: Authentication token (required for success case)
  /// - [agoraUid]: User ID for Agora session (required for success case)
  /// - [message]: Success message (optional)
  /// - [error]: Error message (required for failure case)
  StartCallResult({
    required this.success,
    this.agoraChannelName,
    this.agoraToken,
    this.agoraUid,
    this.message,
    this.error,
  });

  /// Whether the video call was started successfully.
  /// هل تم بدء المكالمة بنجاح.
  final bool success;

  /// Agora channel name/ID to join.
  /// معرف قناة Agora للانضمام / معرف الاجتماع.
  ///
  /// This is the unique identifier for the video consultation session.
  /// Required when [success] is true.
  final String? agoraChannelName;

  /// Agora authentication token.
  /// رمز المصادقة لـ Agora.
  ///
  /// Short-lived token generated server-side for security.
  /// Required when [success] is true.
  final String? agoraToken;

  /// Agora user ID (UID) for this session.
  /// معرف المستخدم في جلسة Agora.
  ///
  /// Unique identifier for the doctor in this video session.
  /// Required when [success] is true.
  final int? agoraUid;

  /// Success or failure message in Arabic.
  /// رسالة نجاح/فشل بالعربية.
  ///
  /// Optional message providing additional context about the operation.
  final String? message;

  /// Error message in Arabic.
  /// رسالة الخطأ بالعربية.
  ///
  /// Required when [success] is false. Provides user-friendly error description.
  final String? error;
}
