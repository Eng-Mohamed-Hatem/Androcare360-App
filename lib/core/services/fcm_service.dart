// This file is initialized via DI and startup wiring in `main.dart`, which
// triggers false positives for `unreachable_from_main` on public members.
// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:elajtech/core/constants/notification_type.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Background Message Handler - معالج الرسائل في الخلفية
///
/// Top-level function that handles FCM messages when the app is in the background
/// or completely terminated. This handler is invoked by the Firebase Messaging
/// plugin and must be a top-level function (not a class method).
///
/// دالة على مستوى أعلى تتعامل مع رسائل FCM عندما يكون التطبيق في الخلفية
/// أو مغلقاً تماماً. يتم استدعاء هذا المعالج بواسطة إضافة Firebase Messaging
/// ويجب أن يكون دالة على مستوى أعلى (وليس طريقة في فئة).
///
/// **Important Requirements:**
/// - Must be a top-level function (not inside a class)
/// - Must be annotated with @pragma('vm:entry-point')
/// - Must initialize Firebase before accessing any Firebase services
/// - Runs in a separate isolate from the main app
///
/// **Handles:**
/// - Incoming VoIP call notifications
/// - Displays incoming call UI via VoIPCallService
/// - Extracts Agora call parameters from message data
///
/// Parameters:
/// - [message]: The FCM remote message received in background
///
/// **Message Data Structure for Calls:**
/// ```dart
/// {
///   'type': 'incoming_call',
///   'callerName': 'Dr. Ahmed',
///   'callerAvatar': 'https://...',
///   'appointmentId': 'appt123',
///   'agoraToken': 'token...',
///   'agoraChannelName': 'channel123',
///   'agoraUid': '12345'
/// }
/// ```
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📨 Background message received: ${message.messageId}');
  debugPrint('📨 Message data: ${message.data}');

  // التحقق من نوع الرسالة - هل هي مكالمة واردة؟
  final messageType = message.data['type'] as String?;

  // ✅ NEW: Log FCM notification receipt
  debugPrint('📱 FCM notification received: type=$messageType');

  if (messageType == 'incoming_call') {
    debugPrint('📞 Incoming call detected in background!');

    // استخراج بيانات المكالمة
    final callerName = message.data['callerName'] as String? ?? 'طبيب';
    final callerAvatar = message.data['callerAvatar'] as String? ?? '';
    final appointmentId = message.data['appointmentId'] as String? ?? '';

    // ✅ Log incoming call notification received
    debugPrint(
      '📱 Incoming call notification received for appointment: $appointmentId',
    );

    // ✅ NEW: Log notification receipt to Firestore
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && appointmentId.isNotEmpty) {
        final firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'elajtech',
        );

        await firestore.collection('call_logs').add({
          'appointmentId': appointmentId,
          'userId': userId,
          'eventType': 'fcm_notification_received',
          'timestamp': FieldValue.serverTimestamp(),
          'metadata': {
            'messageType': messageType,
            'callerName': callerName,
            'receivedInBackground': true,
          },
        });

        debugPrint('✅ FCM notification receipt logged to Firestore');
      }
    } on Exception catch (e) {
      debugPrint('❌ Error logging FCM notification receipt: $e');
    }

    // بيانات Agora للمكالمة
    final agoraToken = message.data['agoraToken'] as String?;
    final agoraChannelName = message.data['agoraChannelName'] as String?;
    final agoraUid = message.data['agoraUid'] != null
        ? int.tryParse(message.data['agoraUid'].toString())
        : null;

    // عرض شاشة المكالمة الواردة
    await getIt<VoIPCallService>().showIncomingCall(
      callerName: callerName,
      callerAvatar: callerAvatar,
      appointmentId: appointmentId,
      agoraToken: agoraToken,
      agoraChannelName: agoraChannelName,
      agoraUid: agoraUid,
    );
  }
}

/// FCM Service - خدمة Firebase Cloud Messaging
///
/// Manages Firebase Cloud Messaging for push notifications and incoming call alerts
/// in the elajtech application. Handles message reception in foreground, background,
/// and terminated states with special support for VoIP call notifications.
///
/// تدير Firebase Cloud Messaging للإشعارات الفورية وتنبيهات المكالمات الواردة
/// في تطبيق elajtech. تتعامل مع استقبال الرسائل في المقدمة والخلفية والحالة
/// المغلقة مع دعم خاص لإشعارات مكالمات VoIP.
///
/// **Key Features:**
/// - Push notification permission management
/// - Foreground message handling with local notifications
/// - Background message handling via top-level handler
/// - VoIP incoming call detection and display
/// - FCM token management and Firestore persistence
/// - Topic subscription for group notifications
/// - Message opened app handling for deep linking
///
/// **Message Types Supported:**
/// - `incoming_call`: VoIP call notifications with Agora parameters
/// - `chat_message`: Chat message notifications
/// - `appointment_reminder`: Appointment reminder notifications
/// - Generic notifications with title and body
///
/// **Integration Points:**
/// - Initialized in main.dart during app startup
/// - Used in auth_repository_impl.dart for FCM token management
/// - Integrates with VoIPCallService for incoming call UI
/// - Integrates with NotificationService for local notifications
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package.
/// FirebaseFirestore instance is injected via constructor to ensure
/// correct database targeting (elajtech database).
///
/// **CRITICAL DATABASE RULES:**
/// - Must use injected FirebaseFirestore instance (configured for elajtech database)
/// - Never use FirebaseFirestore.instance directly
/// - All FCM token updates target the elajtech database
///
/// **Important:** Must call `initialize()` once during app startup before any
/// push notifications can be received.
///
/// Example usage:
/// ```dart
/// // In main.dart (via dependency injection)
/// final fcmService = getIt<FCMService>();
/// await fcmService.initialize();
///
/// // Get FCM token for user registration
/// final token = await fcmService.getToken();
///
/// // Subscribe to topic
/// await fcmService.subscribeToTopic('doctors');
///
/// // Listen to incoming calls
/// fcmService.incomingCallStream.listen((callData) {
///   print('Incoming call from: ${callData.callerName}');
/// });
/// ```
@LazySingleton()
class FCMService {
  /// Constructor with dependency injection
  ///
  /// Accepts FirebaseFirestore instance configured for elajtech database.
  /// This ensures all FCM token updates target the correct database.
  FCMService(
    this._firestore,
    this._auth,
    this._callMonitoring,
    this._voipCallService,
  );

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CallMonitoringService _callMonitoring;
  final VoIPCallService _voipCallService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Stream controller for incoming call events
  final StreamController<IncomingCallData> _incomingCallController =
      StreamController<IncomingCallData>.broadcast();

  /// Stream for listening to incoming calls
  Stream<IncomingCallData> get incomingCallStream =>
      _incomingCallController.stream;

  /// تهيئة خدمة FCM
  ///
  /// Initializes Firebase Cloud Messaging service with the following steps:
  /// 1. Requests notification permissions (including critical alerts for calls)
  /// 2. Registers background message handler
  /// 3. Sets up foreground message listener
  /// 4. Configures message opened app handler
  /// 5. Checks for initial message (app opened from notification)
  /// 6. Retrieves and saves FCM token to Firestore
  /// 7. Sets up token refresh listener
  ///
  /// Called from main.dart during app initialization.
  /// Required for receiving push notifications and incoming call alerts.
  Future<void> initialize() async {
    // 1. طلب صلاحيات الإشعارات
    final settings = await _messaging.requestPermission(
      criticalAlert: true, // مهم للمكالمات
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
      return;
    }

    // 2. تسجيل معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. معالج المقدمة (التطبيق مفتوح)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. معالج فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 5. التحقق من وجود رسالة أولية (التطبيق فُتح من إشعار)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📨 App opened from terminated state via notification');
      _handleMessageOpenedApp(initialMessage);
    }

    // 6. ✅ NEW: Get and save FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('✅ FCM Token received: ${token.substring(0, 20)}...');
      await _saveFCMToken(token);
    } else {
      debugPrint('❌ FCM Token is null');
    }

    // 7. ✅ NEW: Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed');
      _saveFCMToken(newToken).ignore();
    });

    debugPrint('✅ FCM Service initialized with VoIP support');
  }

  /// ✅ NEW: Save FCM token to Firestore
  ///
  /// Saves the FCM token to the user's document in the users collection.
  /// Uses the injected FirebaseFirestore instance configured for elajtech database.
  ///
  /// Requirements: 3.2, 3.3, 3.6, 3.9
  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ Cannot save FCM token: User not signed in');
        return;
      }

      // ✅ Use injected Firestore instance (configured for elajtech database)
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token saved to Firestore for user: $userId');
    } on Exception catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// معالجة الرسائل في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message received!');
    debugPrint('📨 Message data: ${message.data}');

    final messageType = message.data['type'] as String?;

    // ✅ NEW: Log FCM notification receipt
    debugPrint('📱 FCM notification received: type=$messageType');

    // معالجة المكالمات الواردة
    if (messageType == 'incoming_call') {
      debugPrint('📞 Incoming call detected in foreground!');

      // Extract appointmentId for logging
      final appointmentId = message.data['appointmentId'] as String? ?? '';
      debugPrint(
        '📱 Incoming call notification received for appointment: $appointmentId',
      );

      // ✅ NEW: Log notification receipt to Firestore
      final userId = _auth.currentUser?.uid;
      if (userId != null && appointmentId.isNotEmpty) {
        // Intentionally not awaited - logging happens in background
        unawaited(
          _callMonitoring.logCallSuccess(
            appointmentId: appointmentId,
            userId: userId,
            channelName: 'fcm_notification',
            metadata: {
              'eventType': 'fcm_notification_received',
              'messageType': messageType,
              'receivedInForeground': true,
            },
          ),
        );
      }

      // Intentionally not awaited - call handling happens in background
      unawaited(_handleIncomingCall(message));
      return;
    }

    // معالجة الإشعارات العادية
    if (message.notification != null) {
      debugPrint(
        '📨 Notification: ${message.notification?.title}',
      );

      // عرض إشعار محلي
      unawaited(
        NotificationService().showNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'إشعار جديد',
          body: message.notification?.body ?? '',
        ),
      );
    }
  }

  /// معالجة المكالمة الواردة
  Future<void> _handleIncomingCall(RemoteMessage message) async {
    final callerName = message.data['callerName'] as String? ?? 'طبيب';
    final callerAvatar = message.data['callerAvatar'] as String? ?? '';
    final appointmentId = message.data['appointmentId'] as String? ?? '';

    // بيانات Agora للمكالمة
    final agoraToken = message.data['agoraToken'] as String?;
    final agoraChannelName = message.data['agoraChannelName'] as String?;
    final agoraUid = message.data['agoraUid'] != null
        ? int.tryParse(message.data['agoraUid'].toString())
        : null;

    debugPrint('📞 Showing incoming call from: $callerName');
    debugPrint('📞 Agora channel: $agoraChannelName');

    // عرض شاشة المكالمة الواردة
    await _voipCallService.showIncomingCall(
      callerName: callerName,
      callerAvatar: callerAvatar,
      appointmentId: appointmentId,
      agoraToken: agoraToken,
      agoraChannelName: agoraChannelName,
      agoraUid: agoraUid,
    );

    // إرسال الحدث للمستمعين
    _incomingCallController.add(
      IncomingCallData(
        callerName: callerName,
        appointmentId: appointmentId,
        agoraChannelName: agoraChannelName,
      ),
    );
  }

  /// معالجة فتح التطبيق من الإشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📨 App opened from notification');
    debugPrint('📨 Message data: ${message.data}');

    final type = NotificationType.fromString(message.data['type'] as String?);

    if (type == NotificationType.incomingCall) {
      // المستخدم ضغط على إشعار المكالمة
      debugPrint('📞 User tapped on call notification');
      // Intentionally not awaited - call handling happens in background
      unawaited(_handleIncomingCall(message));
    } else if (type == NotificationType.chatMessage) {
      // المستخدم ضغط على إشعار رسالة
      final chatId = message.data['chatId'] as String?;
      debugPrint('💬 User tapped on chat notification: $chatId');
      // يمكن إضافة منطق التنقل هنا
    } else if (type == NotificationType.appointmentBookedDoctor ||
        type == NotificationType.appointmentReminderDoctor ||
        type == NotificationType.appointmentReminderPatient) {
      // المستخدم ضغط على تذكير موعد أو إشعار حجز
      final appointmentId = message.data['appointmentId'] as String?;
      debugPrint(
        '📅 User tapped on appointment notification ($type): $appointmentId',
      );

      if (appointmentId != null && appointmentId.isNotEmpty) {
        // التنقل لتفاصيل الموعد
        _navigateToAppointmentDetails(appointmentId);
      }
    }
  }

  /// التنقل لتفاصيل الموعد
  void _navigateToAppointmentDetails(String appointmentId) {
    final navigatorKey = getIt<GlobalKey<NavigatorState>>();
    if (navigatorKey.currentState != null) {
      debugPrint('🚀 Deep linking to appointment: $appointmentId');
      // TODO(elajtech): Implement navigation to AppointmentDetailsScreen.
      // For now, we'll just log it. In a real scenario, you'd push the route.
      // Example: navigatorKey.currentState!.pushNamed('/appointment_details', arguments: appointmentId);
    } else {
      debugPrint('⚠️ Navigator state is null, cannot perform deep linking');
    }
  }

  /// الحصول على FCM Token
  ///
  /// Retrieves the Firebase Cloud Messaging token for this device.
  /// This token is used to send push notifications to the specific device.
  ///
  /// Called from:
  /// - auth_repository_impl.dart during user signup
  /// - auth_repository_impl.dart during user login (to update token)
  ///
  /// Returns the FCM token string, or null if unavailable.
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('📱 FCM Token: $token');
    return token;
  }

  /// الاشتراك في موضوع معين
  ///
  /// Subscribes this device to a specific FCM topic for targeted notifications.
  /// Topics allow sending notifications to groups of devices.
  ///
  /// Example topics: 'doctors', 'patients', 'appointments'
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('📢 Subscribed to topic: $topic');
  }

  /// إلغاء الاشتراك من موضوع
  ///
  /// Unsubscribes this device from a specific FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('📢 Unsubscribed from topic: $topic');
  }

  /// التخلص من الموارد
  ///
  /// Disposes of resources used by FCMService.
  /// Closes the incoming call stream controller.
  void dispose() {
    // Intentionally not awaited - cleanup happens in background
    unawaited(_incomingCallController.close());
  }
}

/// بيانات المكالمة الواردة
///
/// Data class containing information about an incoming call.
/// Used by FCMService to notify listeners about incoming calls.
///
/// Properties:
/// - callerName: Name of the person calling
/// - appointmentId: ID of the appointment associated with the call
/// - agoraChannelName: Agora channel name for the video call
class IncomingCallData {
  IncomingCallData({
    required this.callerName,
    required this.appointmentId,
    this.agoraChannelName,
  });

  final String callerName;
  final String appointmentId;
  final String? agoraChannelName;
}
