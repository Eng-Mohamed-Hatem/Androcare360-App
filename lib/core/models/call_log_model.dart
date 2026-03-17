import 'package:elajtech/core/models/device_info_model.dart';
import 'package:flutter/foundation.dart';

/// Defines the type of call event being logged.
///
/// These event types are used by the CallMonitoringService to track
/// the lifecycle of video calls and identify technical issues.
///
/// **Event Types:**
/// - `callAttempt`: User attempts to start a call
/// - `callStarted`: Call successfully established
/// - `callEnded`: Call terminated normally
/// - `callError`: General call error occurred
/// - `connectionFailure`: Network connection lost unexpectedly
/// - `mediaDeviceError`: Camera or microphone error
enum CallLogEventType {
  /// محاولة بدء المكالمة
  callAttempt('call_attempt'),

  /// بدء المكالمة بنجاح
  callStarted('call_started'),

  /// إنهاء المكالمة
  callEnded('call_ended'),

  /// خطأ في المكالمة
  callError('call_error'),

  /// فشل الاتصال (انقطاع مفاجئ)
  connectionFailure('connection_failure'),

  /// خطأ في أجهزة الوسائط (كاميرا/ميكروفون)
  mediaDeviceError('media_device_error')
  ;

  const CallLogEventType(this.value);

  /// String value of the event type for Firestore storage
  final String value;

  /// Converts a string value to CallLogEventType enum.
  ///
  /// Parameters:
  /// - [value]: String representation of the event type
  ///
  /// Returns the matching CallLogEventType or callError as fallback.
  static CallLogEventType fromString(String value) {
    return CallLogEventType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CallLogEventType.callError,
    );
  }
}

/// Represents a call event log entry in the AndroCare360 system.
///
/// This model is used by CallMonitoringService to log all call events,
/// errors, and technical issues to Firestore for debugging and quality
/// improvement purposes.
///
/// **Firestore Collection:** `call_logs`
///
/// **Logging Protocol:**
/// All video call events must be logged using this model to facilitate
/// real-time debugging and technical issue tracking. Each log entry
/// includes device information and optional error details.
///
/// **Usage Example:**
/// ```dart
/// final callLog = CallLogModel(
///   id: 'log_123',
///   appointmentId: 'apt_456',
///   userId: 'user_789',
///   eventType: CallLogEventType.callStarted,
///   timestamp: DateTime.now(),
///   deviceInfo: deviceInfo,
///   metadata: {'channelName': 'appointment_456'},
/// );
/// ```
@immutable
class CallLogModel {
  /// Creates a CallLogModel instance.
  ///
  /// All call events should be logged with complete context including
  /// appointment ID, user ID, event type, and device information.
  const CallLogModel({
    required this.id,
    required this.appointmentId,
    required this.userId,
    required this.eventType,
    required this.timestamp,
    this.errorCode,
    this.errorMessage,
    this.stackTrace,
    this.deviceInfo,
    this.metadata,
  });

  /// Creates a CallLogModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// a CallLogModel instance with proper type conversions.
  ///
  /// Parameters:
  /// - [json]: Map containing call log data
  ///
  /// Returns a fully initialized CallLogModel instance.
  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      userId: json['userId'] as String,
      eventType: CallLogEventType.fromString(json['eventType'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      stackTrace: json['stackTrace'] as String?,
      deviceInfo: json['deviceInfo'] != null
          ? DeviceInfoModel.fromJson(json['deviceInfo'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Unique identifier for this log entry
  final String id;

  /// ID of the appointment associated with this call
  final String appointmentId;

  /// ID of the user (doctor or patient) who triggered this event
  final String userId;

  /// Type of call event being logged
  final CallLogEventType eventType;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Error code if this is an error event (optional)
  final String? errorCode;

  /// Human-readable error message (optional)
  final String? errorMessage;

  /// Stack trace for debugging errors (optional)
  final String? stackTrace;

  /// Device information for technical troubleshooting (optional)
  final DeviceInfoModel? deviceInfo;

  /// Additional metadata for context (optional)
  ///
  /// Can include channel names, connection details, or custom data:
  /// ```dart
  /// {
  ///   'channelName': 'appointment_123',
  ///   'agoraUid': 12345,
  ///   'duration': 1800,
  /// }
  /// ```
  final Map<String, dynamic>? metadata;

  /// Converts this CallLogModel to JSON format for Firestore storage.
  ///
  /// Returns a `Map<String, dynamic>` containing all log data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'userId': userId,
      'eventType': eventType.value,
      'timestamp': timestamp.toIso8601String(),
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'deviceInfo': deviceInfo?.toJson(),
      'metadata': metadata,
    };
  }

  /// Creates a copy of this CallLogModel with the specified fields replaced.
  ///
  /// Useful for updating log entries with additional information.
  ///
  /// Returns a new CallLogModel instance with updated fields.
  CallLogModel copyWith({
    String? id,
    String? appointmentId,
    String? userId,
    CallLogEventType? eventType,
    DateTime? timestamp,
    String? errorCode,
    String? errorMessage,
    String? stackTrace,
    DeviceInfoModel? deviceInfo,
    Map<String, dynamic>? metadata,
  }) {
    return CallLogModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'CallLogModel(id: $id, appointmentId: $appointmentId, '
        'userId: $userId, eventType: ${eventType.value}, '
        'timestamp: $timestamp, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CallLogModel &&
        other.id == id &&
        other.appointmentId == appointmentId &&
        other.userId == userId &&
        other.eventType == eventType &&
        other.timestamp == timestamp &&
        other.errorCode == errorCode &&
        other.errorMessage == errorMessage &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      appointmentId,
      userId,
      eventType,
      timestamp,
      errorCode,
      errorMessage,
      stackTrace,
    );
  }
}
