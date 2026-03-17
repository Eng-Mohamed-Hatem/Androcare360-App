import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/models/call_log_model.dart';
import 'package:elajtech/core/models/device_info_model.dart';
import 'package:elajtech/core/services/device_info_service.dart';

/// Call Monitoring Service - Call Event Logging and Tracking
///
/// Manages comprehensive logging of all call-related events to Firestore for:
/// - Debugging and troubleshooting call issues
/// - Analytics and quality monitoring
/// - Compliance and audit trails
///
/// **Key Features:**
/// - Logs all call lifecycle events (attempt, start, end, errors)
/// - Captures device information for debugging
/// - Handles offline scenarios with error recovery
/// - Integrates with DeviceInfoService for hardware details
///
/// **Firestore Integration:**
/// - Collection: 'call_logs'
/// - Uses elajtech database (databaseId: 'elajtech')
/// - Automatic timestamp and UUID generation
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package.
/// Access via GetIt:
/// ```dart
/// final service = getIt<CallMonitoringService>();
/// ```
///
/// Example usage:
/// ```dart
/// // Production usage (via DI)
/// final service = getIt<CallMonitoringService>();
///
/// // Test usage (inject mocks)
/// final service = CallMonitoringService(
///   firestore: mockFirestore,
///   deviceInfoService: mockDeviceInfo,
/// );
///
/// // Log call attempt
/// await service.logCallAttempt(
///   appointmentId: 'appt_123',
///   userId: 'user_456',
/// );
///
/// // Log call error
/// await service.logCallError(
///   appointmentId: 'appt_123',
///   userId: 'user_456',
///   errorType: 'token_generation_failed',
///   errorMessage: 'Invalid Agora token',
/// );
/// ```
@LazySingleton()
class CallMonitoringService {
  /// Constructor with dependency injection
  ///
  /// Parameters:
  /// - `firestore`: Firestore instance (injected via GetIt)
  CallMonitoringService(
    this._firestore,
  ) : _uuid = const Uuid();

  /// Firestore instance (injected via GetIt)
  final FirebaseFirestore _firestore;

  /// Device info service (lazy-loaded or injected for testing)
  @visibleForTesting
  DeviceInfoService deviceInfoService = DeviceInfoService();

  /// UUID generator
  final Uuid _uuid;

  /// Firestore collection name for call logs
  static const String _collectionName = 'call_logs';

  /// Log call attempt event
  ///
  /// Records when a user attempts to start a call. This is the first event
  /// in the call lifecycle and helps track call initiation success rates.
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (doctor or patient) (required)
  /// - [deviceInfo]: Device information (optional - auto-collected if not provided)
  ///
  /// Errors are logged but not thrown to avoid disrupting the call flow.
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logCallAttempt(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  /// );
  /// ```
  Future<void> logCallAttempt({
    required String appointmentId,
    required String userId,
    DeviceInfoModel? deviceInfo,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📝 [CallMonitoringService] Logging call attempt: $appointmentId',
        );
        debugPrint('📝 [CallMonitoringService] User ID: $userId');
      }

      // جمع معلومات الجهاز إذا لم تكن محددة
      final device = deviceInfo ?? await deviceInfoService.getDeviceInfo();

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.callAttempt,
        timestamp: DateTime.now(),
        deviceInfo: device,
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Call attempt logged successfully',
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging call attempt: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // لا نرمي exception حتى لا نعطل الـ flow الأساسي
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging call attempt: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // لا نرمي exception حتى لا نعطل الـ flow الأساسي
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging call attempt: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // لا نرمي exception حتى لا نعطل الـ flow الأساسي
    }
  }

  /// Log successful call start
  ///
  /// Records when a call successfully starts after joining the Agora channel.
  /// Includes channel name and optional metadata for debugging.
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (required)
  /// - [channelName]: Agora channel name (required)
  /// - [metadata]: Additional data like UID, connection details (optional)
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logCallSuccess(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   channelName: 'appointment_123',
  ///   metadata: {'uid': 12345},
  /// );
  /// ```
  Future<void> logCallSuccess({
    required String appointmentId,
    required String userId,
    required String channelName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Logging call success: $appointmentId',
        );
        debugPrint(
          '✅ [CallMonitoringService] User ID: $userId, Channel: $channelName',
        );
      }

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.callStarted,
        timestamp: DateTime.now(),
        metadata: {
          'channelName': channelName,
          ...?metadata,
        },
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Call success logged successfully',
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging call success: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging call success: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging call success: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    }
  }

  /// Log call error
  ///
  /// Records any error that occurs during call lifecycle including:
  /// - Token generation failures
  /// - Agora SDK errors
  /// - Permission denials
  /// - Network errors
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (required)
  /// - [errorType]: Error type code (e.g., 'token_generation_failed') (required)
  /// - [errorMessage]: Human-readable error message (required)
  /// - [stackTrace]: Stack trace for debugging (optional)
  /// - [deviceInfo]: Device information (optional - auto-collected if not provided)
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logCallError(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   errorType: 'agora_join_failed',
  ///   errorMessage: 'Invalid token',
  ///   stackTrace: stackTrace.toString(),
  /// );
  /// ```
  Future<void> logCallError({
    required String appointmentId,
    required String userId,
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    DeviceInfoModel? deviceInfo,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Logging call error: $errorType - $errorMessage',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
      }

      // جمع معلومات الجهاز
      final device = deviceInfo ?? await deviceInfoService.getDeviceInfo();

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.callError,
        timestamp: DateTime.now(),
        errorCode: errorType,
        errorMessage: errorMessage,
        stackTrace: stackTrace,
        deviceInfo: device,
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint('✅ [CallMonitoringService] Call error logged successfully');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging call error: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging call error: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging call error: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    }
  }

  /// Log connection failure
  ///
  /// Records unexpected connection drops or network issues during an active call.
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (required)
  /// - [reason]: Failure reason (e.g., 'connection_lost', 'network_timeout') (required)
  /// - [deviceInfo]: Device information (optional - auto-collected if not provided)
  /// - [metadata]: Additional connection state data (optional)
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logConnectionFailure(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   reason: 'Connection state: failed',
  ///   metadata: {'connectionState': 'FAILED'},
  /// );
  /// ```
  Future<void> logConnectionFailure({
    required String appointmentId,
    required String userId,
    required String reason,
    DeviceInfoModel? deviceInfo,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📡 [CallMonitoringService] Logging connection failure: $reason',
        );
        debugPrint(
          '📡 [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
      }

      // جمع معلومات الجهاز
      final device = deviceInfo ?? await deviceInfoService.getDeviceInfo();

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.connectionFailure,
        timestamp: DateTime.now(),
        errorCode: 'connection_failure',
        errorMessage: reason,
        deviceInfo: device,
        metadata: metadata,
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Connection failure logged successfully',
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging connection failure: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging connection failure: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging connection failure: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    }
  }

  /// Log media device error
  ///
  /// Records errors with camera or microphone during a call.
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (required)
  /// - [deviceType]: Device type ('camera' or 'microphone') (required)
  /// - [errorMessage]: Error description (required)
  /// - [deviceInfo]: Device information (optional - auto-collected if not provided)
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logMediaDeviceError(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   deviceType: 'camera',
  ///   errorMessage: 'Camera failed: permission denied',
  /// );
  /// ```
  Future<void> logMediaDeviceError({
    required String appointmentId,
    required String userId,
    required String deviceType,
    required String errorMessage,
    DeviceInfoModel? deviceInfo,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🎥 [CallMonitoringService] Logging media device error: $deviceType - $errorMessage',
        );
        debugPrint(
          '🎥 [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
      }

      // جمع معلومات الجهاز
      final device = deviceInfo ?? await deviceInfoService.getDeviceInfo();

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.mediaDeviceError,
        timestamp: DateTime.now(),
        errorCode: '${deviceType}_error',
        errorMessage: errorMessage,
        deviceInfo: device,
        metadata: {
          'deviceType': deviceType,
        },
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Media device error logged successfully',
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging media device error: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging media device error: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging media device error: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    }
  }

  /// Log call ended event
  ///
  /// Records when a call ends normally. Includes optional call duration.
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  /// - [userId]: User identifier (required)
  /// - [duration]: Call duration in seconds (optional)
  /// - [metadata]: Additional data like end reason (optional)
  ///
  /// Example:
  /// ```dart
  /// await callMonitoring.logCallEnded(
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  ///   duration: 1800, // 30 minutes
  /// );
  /// ```
  Future<void> logCallEnded({
    required String appointmentId,
    required String userId,
    int? duration,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📴 [CallMonitoringService] Logging call ended: $appointmentId',
        );
        debugPrint(
          '📴 [CallMonitoringService] User ID: $userId, Duration: $duration seconds',
        );
      }

      final log = CallLogModel(
        id: _uuid.v4(),
        appointmentId: appointmentId,
        userId: userId,
        eventType: CallLogEventType.callEnded,
        timestamp: DateTime.now(),
        metadata: {
          'durationSeconds': ?duration,
          ...?metadata,
        },
      );

      await _saveLog(log);

      if (kDebugMode) {
        debugPrint('✅ [CallMonitoringService] Call ended logged successfully');
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error logging call ended: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error logging call ended: ${e.message}',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error logging call ended: $e',
        );
        debugPrint(
          '❌ [CallMonitoringService] Appointment: $appointmentId, User: $userId',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
    }
  }

  /// Save log to Firestore
  ///
  /// Internal method to persist call log to Firestore 'call_logs' collection.
  ///
  /// Throws:
  /// - [FirestoreException] if Firestore write fails
  /// - [NetworkException] if network connection unavailable
  Future<void> _saveLog(CallLogModel log) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(log.id)
          .set(log.toJson());

      if (kDebugMode) {
        debugPrint(
          '✅ [CallMonitoringService] Log saved to Firestore: ${log.id}',
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error saving log: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Log ID: ${log.id}');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // في حالة الخطأ، يمكن تنفيذ retry logic أو حفظ محلي
      throw FirestoreException(
        'Failed to save call log to Firestore: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error saving log: ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Log ID: ${log.id}');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // في حالة الخطأ، يمكن تنفيذ retry logic أو حفظ محلي
      throw NetworkException(
        'Network error saving call log: No internet connection',
        originalError: e,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [CallMonitoringService] Unexpected error saving log: $e');
        debugPrint('❌ [CallMonitoringService] Log ID: ${log.id}');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      // في حالة الخطأ، يمكن تنفيذ retry logic أو حفظ محلي
      throw FirestoreException(
        'Unexpected error saving call log',
        originalError: e,
      );
    }
  }

  /// Get logs for a specific appointment
  ///
  /// Retrieves all call logs associated with an appointment, ordered by timestamp (newest first).
  ///
  /// Parameters:
  /// - [appointmentId]: Appointment identifier (required)
  ///
  /// Returns: List of call logs, or empty list if error occurs
  ///
  /// Example:
  /// ```dart
  /// final logs = await callMonitoring.getLogsForAppointment('appt_123');
  /// for (final log in logs) {
  ///   print('${log.eventType}: ${log.timestamp}');
  /// }
  /// ```
  Future<List<CallLogModel>> getLogsForAppointment(
    String appointmentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CallLogModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error fetching appointment logs: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Appointment ID: $appointmentId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error fetching appointment logs: ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Appointment ID: $appointmentId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error fetching appointment logs: $e',
        );
        debugPrint('❌ [CallMonitoringService] Appointment ID: $appointmentId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get logs for a specific user
  ///
  /// Retrieves call logs for a user (doctor or patient), ordered by timestamp (newest first).
  ///
  /// Parameters:
  /// - [userId]: User identifier (required)
  /// - [limit]: Maximum number of logs to retrieve (default: 50)
  ///
  /// Returns: List of call logs, or empty list if error occurs
  ///
  /// Example:
  /// ```dart
  /// final logs = await callMonitoring.getLogsForUser('user_456', limit: 100);
  /// ```
  Future<List<CallLogModel>> getLogsForUser(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CallLogModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error fetching user logs: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] User ID: $userId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error fetching user logs: ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] User ID: $userId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error fetching user logs: $e',
        );
        debugPrint('❌ [CallMonitoringService] User ID: $userId');
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get error logs only
  ///
  /// Retrieves logs for errors, connection failures, and media device errors.
  /// Useful for debugging and monitoring call quality issues.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of logs to retrieve (default: 100)
  ///
  /// Returns: List of error logs, or empty list if error occurs
  ///
  /// Example:
  /// ```dart
  /// final errorLogs = await callMonitoring.getErrorLogs(limit: 50);
  /// for (final log in errorLogs) {
  ///   print('Error: ${log.errorCode} - ${log.errorMessage}');
  /// }
  /// ```
  Future<List<CallLogModel>> getErrorLogs({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where(
            'eventType',
            whereIn: [
              CallLogEventType.callError.value,
              CallLogEventType.connectionFailure.value,
              CallLogEventType.mediaDeviceError.value,
            ],
          )
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CallLogModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Firestore Error fetching error logs: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Network Error fetching error logs: ${e.message}',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [CallMonitoringService] Unexpected error fetching error logs: $e',
        );
        debugPrint('❌ [CallMonitoringService] Stack trace: $stackTrace');
      }
      return [];
    }
  }
}
