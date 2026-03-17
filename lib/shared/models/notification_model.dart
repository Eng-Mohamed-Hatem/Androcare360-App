/// Represents a notification in the AndroCare360 system.
///
/// This model stores notification data including title, body, type, read status,
/// and optional metadata. Notifications are used to inform users about appointments,
/// consultations, prescriptions, and other important events.
///
/// **Firestore Collection:** `notifications`
///
/// **Notification Types:**
/// - `appointment`: Appointment-related notifications
/// - `consultation`: Video consultation notifications
/// - `prescription`: Prescription-related notifications
/// - `reminder`: Reminder notifications
/// - `general`: General system notifications
///
/// **Usage Example:**
/// ```dart
/// final notification = NotificationModel(
///   userId: 'user_123',
///   id: 'notif_456',
///   title: 'موعد قادم',
///   body: 'لديك موعد مع د. أحمد محمد غداً الساعة 10:00 صباحاً',
///   type: NotificationType.appointment,
///   createdAt: DateTime.now(),
///   isRead: false,
///   data: {'appointmentId': 'apt_789'},
/// );
/// ```
class NotificationModel {
  NotificationModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  /// Creates a NotificationModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// a NotificationModel instance. It handles type conversions and provides
  /// default values for optional fields.
  ///
  /// Parameters:
  /// - [json]: Map containing notification data
  ///
  /// Returns a fully initialized NotificationModel instance.
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        userId: json['userId'] as String? ?? '',
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.${json['type']}',
          orElse: () => NotificationType.general,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
        data: json['data'] as Map<String, dynamic>?,
      );

  /// ID of the user who should receive this notification
  final String userId;

  /// Unique identifier for this notification
  final String id;

  /// Notification title (displayed prominently)
  final String title;

  /// Notification body text (detailed message)
  final String body;

  /// Type of notification (determines icon and behavior)
  final NotificationType type;

  /// Timestamp when the notification was created
  final DateTime createdAt;

  /// Indicates whether the user has read this notification
  final bool isRead;

  /// Optional metadata for additional context
  ///
  /// Can contain related IDs or custom data:
  /// ```dart
  /// {
  ///   'appointmentId': 'apt_123',
  ///   'doctorId': 'doctor_456',
  ///   'action': 'view_appointment',
  /// }
  /// ```
  final Map<String, dynamic>? data;

  /// Converts this NotificationModel to JSON format for Firestore storage.
  ///
  /// Returns a `Map<String, dynamic>` containing all notification data.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'data': data,
  };

  /// Creates a copy of this NotificationModel with the specified fields replaced.
  ///
  /// This method is primarily used to mark notifications as read.
  ///
  /// Parameters:
  /// - [isRead]: New read status (optional)
  ///
  /// Returns a new NotificationModel instance with updated fields.
  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    userId: userId,
    id: id,
    title: title,
    body: body,
    type: type,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    data: data,
  );
}

/// Defines the type of notification.
///
/// **Values:**
/// - `appointment`: Appointment booking, confirmation, or cancellation
/// - `consultation`: Video consultation start or reminder
/// - `prescription`: New prescription or medication reminder
/// - `reminder`: General reminder for appointments or tasks
/// - `general`: General system notifications
enum NotificationType {
  /// Appointment-related notification
  appointment, // موعد
  /// Consultation-related notification
  consultation, // استشارة
  /// Prescription-related notification
  prescription, // وصفة طبية
  /// Reminder notification
  reminder, // تذكير
  /// General notification
  general, // عام
}

/// Provides mock notification data for testing and development.
///
/// This class generates sample notifications for use in UI development
/// and testing scenarios without requiring actual Firestore data.
class MockNotifications {
  /// Returns a list of mock notifications.
  ///
  /// Returns a list of NotificationModel instances with sample data.
  static List<NotificationModel> getNotifications() => [
    NotificationModel(
      userId: 'current_user',
      id: '1',
      title: 'موعد قادم',
      body: 'لديك موعد مع د. أحمد محمد غداً الساعة 10:00 صباحاً',
      type: NotificationType.appointment,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      userId: 'current_user',
      id: '2',
      title: 'وصفة طبية جديدة',
      body: 'تم إضافة وصفة طبية جديدة من د. سارة علي',
      type: NotificationType.prescription,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      userId: 'current_user',
      id: '3',
      title: 'تذكير بالموعد',
      body: 'موعدك مع د. خالد عبدالله بعد ساعة واحدة',
      type: NotificationType.reminder,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      userId: 'current_user',
      id: '4',
      title: 'استشارة فيديو',
      body: 'استشارتك مع د. أحمد محمد ستبدأ خلال 30 دقيقة',
      type: NotificationType.consultation,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];
}
