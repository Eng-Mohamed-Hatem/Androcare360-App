/// Notification Type Enum - أنواع الإشعارات
///
/// Centralized enum to handle different types of FCM notifications.
/// Used for deep linking and consistent payload handling.
enum NotificationType {
  /// Incoming VoIP call
  incomingCall('incoming_call'),

  /// New appointment booked (Doctor notification)
  appointmentBookedDoctor('appointment_booked_doctor'),

  /// 30-minute reminder for doctor
  appointmentReminderDoctor('appointment_reminder_doctor'),

  /// 30-minute reminder for patient
  appointmentReminderPatient('appointment_reminder_patient'),

  /// Chat message notification
  chatMessage('chat_message'),

  /// Unknown type fallback
  unknown('unknown')
  ;

  const NotificationType(this.value);

  final String value;

  /// Parse string value to NotificationType enum
  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.unknown;
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.unknown,
    );
  }
}
