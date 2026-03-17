// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:elajtech/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:elajtech/shared/models/notification_model.dart';

/// Background task callback dispatcher.
/// معالج المهام الخلفية.
///
/// This function runs in a separate isolate and is invoked by WorkManager
/// to execute background tasks. It operates independently of the main app
/// and has its own Firebase and service initialization.
///
/// **Execution Context:**
/// - Runs in a separate Dart isolate
/// - Has no access to main app state or services
/// - Must initialize Firebase and services independently
/// - Runs even when app is completely closed
///
/// **Task Flow:**
/// 1. WorkManager invokes this function every 15 minutes
/// 2. Firebase is initialized with DefaultFirebaseOptions
/// 3. NotificationService is initialized for local notifications
/// 4. User ID is retrieved from SharedPreferences
/// 5. Notifications are fetched from Firestore (elajtech database)
/// 6. Notifications from last 15 minutes are filtered
/// 7. Local notifications are displayed for unread items
/// 8. Returns true on success, false on failure
///
/// **Parameters:**
/// - `task`: Task identifier (e.g., 'checkNotifications')
/// - `inputData`: Optional data passed to the task (not used currently)
///
/// **Returns:**
/// - `true`: Task completed successfully
/// - `false`: Task failed (WorkManager will retry)
///
/// **Error Handling:**
/// - All exceptions are caught and logged
/// - Returns false on error to trigger WorkManager retry
/// - Logs errors with debugPrint for debugging
///
/// **Database Access:**
/// Uses Firestore with specific database ID:
/// ```dart
/// FirebaseFirestore.instanceFor(
///   app: Firebase.app(),
///   databaseId: 'elajtech',
/// )
/// ```
///
/// **Notification Filtering:**
/// - Fetches all notifications for the user
/// - Filters notifications created in last 15 minutes
/// - Only displays unread notifications
/// - Uses notification ID hash as local notification ID
///
/// **Example Execution:**
/// ```dart
/// // WorkManager calls this function automatically
/// // Task: 'checkNotifications'
/// // 1. Initialize Firebase
/// // 2. Get user ID from SharedPreferences
/// // 3. Fetch notifications from Firestore
/// // 4. Display unread notifications from last 15 minutes
/// // 5. Return true
/// ```
///
/// **Important Notes:**
/// - Must be a top-level function (not a class method)
/// - Must have @pragma('vm:entry-point') annotation
/// - Cannot access main app state or services
/// - Must initialize all dependencies independently
/// - Runs with limited execution time (varies by platform)
///
/// **Platform Limitations:**
/// - Android: ~10 minutes execution time limit
/// - iOS: ~30 seconds execution time limit
/// - Both: May be terminated by OS if taking too long
///
/// See `BackgroundService.registerPeriodicTask` for task registration.
/// See `NotificationService` for notification display.
/// See `NotificationRepositoryImpl` for notification data access.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('Native called background task: $task');
      }

      // Initialize Firebase (Required)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Notification Service
      await NotificationService().init();

      // Get User ID from SharedPrefs
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        return Future.value(true);
      }

      // Check for recent notifications (last 15 mins)
      // Firestore Service migrated to Repository
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'elajtech',
      );
      final notificationRepo = NotificationRepositoryImpl(firestore);

      final result = await notificationRepo.getNotificationsForUser(userId);
      final notifications = result.fold(
        (l) => <NotificationModel>[],
        (r) => r,
      );
      final lastCheck = DateTime.now().subtract(const Duration(minutes: 15));

      for (final note in notifications) {
        if (note.createdAt.isAfter(lastCheck) && !note.isRead) {
          await NotificationService().showNotification(
            id: note.id.hashCode,
            title: note.title,
            body: note.body,
          );
        }
      }

      return Future.value(true);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error in background task: $e');
      }
      return Future.value(false);
    }
  });
}

/// Background Service - خدمة المهام الخلفية
/// Background task management service for the elajtech platform.
///
/// This service manages background tasks using WorkManager for periodic operations
/// that need to run even when the app is closed or in the background.
///
/// **Primary Responsibilities / المسؤوليات الأساسية:**
/// - Initialize WorkManager with callback dispatcher / تهيئة WorkManager مع callback dispatcher
/// - Register periodic tasks for notification checking / تسجيل المهام الدورية للتحقق من الإشعارات
/// - Check for new notifications every 15 minutes / التحقق من الإشعارات الجديدة كل 15 دقيقة
/// - Display local notifications for unread messages / عرض الإشعارات المحلية للرسائل غير المقروءة
/// - Run tasks independently of app lifecycle / تشغيل المهام بشكل مستقل عن دورة حياة التطبيق
///
/// **Static Service Pattern:**
/// All methods are static and can be called directly without instantiation:
/// ```dart
/// await BackgroundService.init();
/// await BackgroundService.registerPeriodicTask();
/// ```
///
/// **Background Task Flow:**
/// 1. App initializes BackgroundService in main.dart (mobile only)
/// 2. User logs in successfully
/// 3. registerPeriodicTask() is called from auth_provider.dart
/// 4. WorkManager schedules periodic execution every 15 minutes
/// 5. callbackDispatcher() runs in background isolate
/// 6. Firebase is initialized in background context
/// 7. User notifications are fetched from Firestore
/// 8. Unread notifications from last 15 minutes are displayed
///
/// **Integration Points:**
/// - Initialized in main.dart during app startup (mobile only, skipped on web)
/// - Registered in auth_provider.dart after successful login
/// - Uses NotificationService for displaying notifications
/// - Uses NotificationRepositoryImpl for fetching notifications
/// - Uses SharedPreferences for storing user ID
///
/// **Platform Support:**
/// - ✅ Android: Uses WorkManager with native AlarmManager
/// - ✅ iOS: Uses WorkManager with Background Fetch
/// - ❌ Web: Not supported (skipped with !kIsWeb check)
///
/// **Usage Example:**
/// ```dart
/// // In main.dart (mobile only)
/// if (!kIsWeb) {
///   await BackgroundService.init();
/// }
///
/// // In auth_provider.dart after login
/// if (!kIsWeb) {
///   await BackgroundService.registerPeriodicTask();
/// }
/// ```
///
/// **Background Callback:**
/// The [callbackDispatcher] function runs in a separate isolate and:
/// - Initializes Firebase with DefaultFirebaseOptions
/// - Initializes NotificationService
/// - Retrieves current user ID from SharedPreferences
/// - Fetches notifications from Firestore (elajtech database)
/// - Filters notifications from last 15 minutes
/// - Displays local notifications for unread items
///
/// **Database Access:**
/// Uses Firestore with specific database ID:
/// ```dart
/// FirebaseFirestore.instanceFor(
///   app: Firebase.app(),
///   databaseId: 'elajtech',
/// )
/// ```
///
/// **Constraints:**
/// - Requires network connectivity to fetch notifications
/// - Minimum interval: 15 minutes (WorkManager limitation)
/// - Runs only when device is not in battery saver mode
///
/// **Error Handling:**
/// - All errors are caught and logged with debugPrint
/// - Returns false on failure to allow WorkManager retry
/// - Returns true on success to mark task as completed
///
/// @see NotificationService for notification display
/// @see NotificationRepositoryImpl for notification data access
/// @see callbackDispatcher for background task implementation
// ignore: unreachable_from_main
class BackgroundService {
  /// Initializes WorkManager with the callback dispatcher.
  /// تهيئة WorkManager مع callback dispatcher.
  ///
  /// This method must be called before registering any background tasks.
  /// It configures WorkManager to use [callbackDispatcher] for executing
  /// background tasks in a separate isolate.
  ///
  /// **When to Call:**
  /// - Called once during app startup in main.dart (mobile only)
  /// - Must be called before [registerPeriodicTask]
  ///
  /// **Returns:**
  /// A Future that completes when WorkManager is initialized.
  ///
  /// **Throws:**
  /// - [Exception] if WorkManager initialization fails
  ///
  /// **Example:**
  /// ```dart
  /// // In main.dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   if (!kIsWeb) {
  ///     await BackgroundService.init();
  ///   }
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Platform Behavior:**
  /// - Android: Initializes WorkManager with AlarmManager
  /// - iOS: Initializes WorkManager with Background Fetch
  /// - Web: Should not be called (check !kIsWeb before calling)
  ///
  /// **Important Notes:**
  /// - Only needs to be called once per app launch
  /// - Safe to call multiple times (WorkManager handles re-initialization)
  /// - Does not start any tasks; use [registerPeriodicTask] to schedule tasks
  // ignore: unreachable_from_main
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Registers a periodic task to check for new notifications.
  /// تسجيل مهمة دورية للتحقق من الإشعارات الجديدة.
  ///
  /// This method schedules a background task that runs every 15 minutes to:
  /// 1. Check for new notifications in Firestore
  /// 2. Filter notifications from the last 15 minutes
  /// 3. Display local notifications for unread items
  ///
  /// **When to Call:**
  /// - Called after successful user login in auth_provider.dart
  /// - Should be called after [init] has been called
  ///
  /// **Task Configuration:**
  /// - Task ID: 'periodic-notification-check'
  /// - Task Name: 'checkNotifications'
  /// - Frequency: Every 15 minutes (minimum allowed by WorkManager)
  /// - Constraint: Requires network connectivity
  ///
  /// **Returns:**
  /// A Future that completes when the task is registered.
  ///
  /// **Throws:**
  /// - [Exception] if task registration fails
  ///
  /// **Example:**
  /// ```dart
  /// // In auth_provider.dart after login
  /// Future<void> login(String email, String password) async {
  ///   // ... login logic ...
  ///
  ///   if (!kIsWeb) {
  ///     await BackgroundService.registerPeriodicTask();
  ///   }
  /// }
  /// ```
  ///
  /// **Platform Behavior:**
  /// - Android: Uses AlarmManager for scheduling
  /// - iOS: Uses Background Fetch API
  /// - Web: Not supported
  ///
  /// **Important Notes:**
  /// - Task runs even when app is closed or in background
  /// - Requires network connectivity to fetch notifications
  /// - Minimum interval is 15 minutes (WorkManager limitation)
  /// - Task is automatically rescheduled after each execution
  /// - Safe to call multiple times (WorkManager handles duplicate registration)
  ///
  /// **Battery Optimization:**
  /// - Task may be delayed or skipped if device is in battery saver mode
  /// - Android: May require disabling battery optimization for the app
  /// - iOS: Execution depends on Background Fetch availability
  ///
  /// **Cancellation:**
  /// To cancel the periodic task:
  /// ```dart
  /// await Workmanager().cancelByUniqueName('periodic-notification-check');
  /// ```
  // ignore: unreachable_from_main
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      'periodic-notification-check',
      'checkNotifications',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
