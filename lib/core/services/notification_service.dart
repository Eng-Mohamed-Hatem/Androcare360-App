import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification Service - Local Notification Management
///
/// Manages local notifications using flutter_local_notifications package.
/// Handles both immediate and scheduled notifications with platform-specific configurations.
///
/// **Key Features:**
/// - Immediate notification display
/// - Scheduled notifications with timezone support
/// - High-priority incoming call notifications
/// - Android notification channels configuration
/// - iOS notification permissions handling
///
/// **Platform Support:**
/// - Android: Uses notification channels with configurable importance levels
/// - iOS: Uses Darwin notification settings with permission requests
///
/// **Timezone Configuration:**
/// - Default timezone: Asia/Riyadh
/// - Supports scheduled notifications with exact timing
///
/// **Dependency Injection:**
/// This service uses the Singleton pattern for global access.
///
/// Example usage:
/// ```dart
/// // Initialize service at app startup
/// await NotificationService().init();
///
/// // Show immediate notification
/// await NotificationService().showNotification(
///   id: 1,
///   title: 'Appointment Reminder',
///   body: 'Your appointment is in 30 minutes',
/// );
///
/// // Schedule notification
/// await NotificationService().scheduleNotification(
///   id: 2,
///   title: 'Upcoming Appointment',
///   body: 'Appointment with Dr. Ahmed tomorrow',
///   scheduledDate: DateTime.now().add(Duration(hours: 24)),
/// );
/// ```
class NotificationService {
  /// Singleton instance
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  /// Flutter local notifications plugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  ///
  /// Sets up notification channels, timezone configuration, and permissions.
  /// This method must be called once during app initialization.
  ///
  /// Initialization includes:
  /// - Timezone setup (Asia/Riyadh)
  /// - Android notification channels creation
  /// - iOS notification settings configuration
  /// - Permission requests for both platforms
  /// - High-priority incoming call channel setup
  ///
  /// Example:
  /// ```dart
  /// await NotificationService().init();
  /// ```
  Future<void> init() async {
    // Initialize Timezone
    tz.initializeTimeZones();
    // Force Riyadh Timezone
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    } on Exception catch (_) {
      // Fallback
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    }

    // Android Settings
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS Settings
    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();

    // ✅ إنشاء قناة المكالمات الواردة عالية الأولوية
    await _createIncomingCallChannel();
  }

  /// Create incoming call notification channel
  ///
  /// Creates a high-priority Android notification channel for incoming calls.
  /// This channel ensures maximum visibility with lights, sound, and vibration.
  ///
  /// Channel configuration:
  /// - ID: 'incoming_calls'
  /// - Importance: Maximum
  /// - Lights: Enabled
  ///
  /// This method is called automatically during initialization.
  Future<void> _createIncomingCallChannel() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      const channel = AndroidNotificationChannel(
        'incoming_calls', // يجب أن يتطابق مع channelId في السيرفر
        'مكالمات واردة',
        description: 'إشعارات المكالمات الفيديو الواردة',
        importance: Importance.max,
        enableLights: true,
      );

      await androidImplementation.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions
  ///
  /// Requests notification permissions from the user on both Android and iOS.
  /// On Android, requests notification permission (Android 13+).
  ///
  /// This method is called automatically during initialization.
  Future<void> _requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      // Note: Exact alarms permission removed as it requires manual user action
      // Notifications will still work but may be slightly less precise
    }
  }

  /// Show immediate notification
  ///
  /// Displays a notification immediately with high priority.
  ///
  /// Parameters:
  /// - [id]: Unique notification identifier (required)
  /// - [title]: Notification title (required)
  /// - [body]: Notification body text (required)
  ///
  /// The notification uses the 'main_channel' with maximum importance
  /// to ensure visibility to the user.
  ///
  /// Example:
  /// ```dart
  /// await NotificationService().showNotification(
  ///   id: 1,
  ///   title: 'New Message',
  ///   body: 'You have a new message from Dr. Ahmed',
  /// );
  /// ```
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Schedule notification for future delivery
  ///
  /// Schedules a notification to be displayed at a specific date and time.
  /// Uses timezone-aware scheduling to ensure accurate delivery.
  ///
  /// Parameters:
  /// - [id]: Unique notification identifier (required)
  /// - [title]: Notification title (required)
  /// - [body]: Notification body text (required)
  /// - [scheduledDate]: Date and time to display notification (required)
  ///
  /// The notification will be delivered even if the app is closed, using
  /// Android's exact alarm scheduling with "allow while idle" mode.
  ///
  /// If the scheduled date is in the past, the notification is not scheduled.
  ///
  /// Example:
  /// ```dart
  /// await NotificationService().scheduleNotification(
  ///   id: 2,
  ///   title: 'Appointment Reminder',
  ///   body: 'Your appointment is in 1 hour',
  ///   scheduledDate: DateTime.now().add(Duration(hours: 1)),
  /// );
  /// ```
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Reminders',
          channelDescription: 'Appointment reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel a specific notification
  ///
  /// Cancels a scheduled or displayed notification by its ID.
  ///
  /// Parameters:
  /// - [id]: Notification identifier to cancel (required)
  ///
  /// Example:
  /// ```dart
  /// await NotificationService().cancelNotification(1);
  /// ```
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  ///
  /// Cancels all scheduled and displayed notifications.
  ///
  /// Example:
  /// ```dart
  /// await NotificationService().cancelAll();
  /// ```
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
