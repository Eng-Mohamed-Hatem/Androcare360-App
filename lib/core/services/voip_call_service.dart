import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VoIPCallService {
  VoIPCallService(this._callMonitoring);

  /// Call monitoring service for logging
  final CallMonitoringService _callMonitoring;

  /// UUID generator for unique call IDs
  final Uuid _uuid = const Uuid();

  /// Stream controller for call events
  final StreamController<VoIPCallEvent> _callEventController =
      StreamController<VoIPCallEvent>.broadcast();

  /// Stream for listening to call events
  Stream<VoIPCallEvent> get callEventStream => _callEventController.stream;

  /// Current active call ID
  String? _currentCallId;
  String? get currentCallId => _currentCallId;

  /// Pending call data (for use when answering)
  PendingCallData? _pendingCallData;
  PendingCallData? get pendingCallData => _pendingCallData;

  /// Initialize VoIP Call Service
  ///
  /// Sets up CallKit/ConnectionService integration and checks for active calls
  /// from cold start scenarios (app opened from call notification).
  ///
  /// This method should be called once during app initialization.
  ///
  /// Throws:
  /// - [VoIPException] if initialization fails
  /// - [NetworkException] if network connection unavailable
  ///
  /// Example:
  /// ```dart
  /// await VoIPCallService().initialize();
  /// ```
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        debugPrint('📞 [VoIPCallService] Initializing VoIP Call Service...');
      }

      // Listen to CallKit events
      FlutterCallkitIncoming.onEvent.listen(_handleCallKitEvent);

      // ✅ Cold Start: فحص المكالمات النشطة عند بدء التطبيق
      await _checkActiveCallsOnStartup();

      if (kDebugMode) {
        debugPrint(
          '✅ [VoIPCallService] VoIP Call Service initialized successfully',
        );
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error during initialization: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw VoIPException(
        'Firebase Functions error during VoIP initialization: ${e.message}',
        originalError: e,
      );
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error during initialization: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw NetworkException(
        'Network error during VoIP initialization: No internet connection',
        originalError: e,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Unexpected error during initialization: $e',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw VoIPException(
        'Unexpected error during VoIP initialization',
        originalError: e,
      );
    }
  }

  /// Check for active calls on cold start
  ///
  /// When the app is opened from a call notification (cold start),
  /// this method retrieves the pending call data including Agora credentials.
  ///
  /// This ensures call data is available even if the app was terminated
  /// when the call notification arrived.
  Future<void> _checkActiveCallsOnStartup() async {
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();

      if (kDebugMode) {
        debugPrint(
          '📞 [VoIPCallService] Active calls on startup: $activeCalls',
        );
      }

      // ✅ تحويل آمن للقائمة والتحقق من الفراغ
      if (activeCalls == null || (activeCalls as List).isEmpty) return;

      // أخذ آخر مكالمة نشطة (تم التحقق من عدم الفراغ أعلاه)
      final lastCall = activeCalls.last as Map<dynamic, dynamic>?;
      if (lastCall == null) return;

      if (kDebugMode) {
        debugPrint('📞 [VoIPCallService] Last active call: $lastCall');
      }

      final extra = lastCall['extra'] as Map<dynamic, dynamic>?;
      final agoraToken = extra?['agoraToken'] as String?;
      final appointmentId = extra?['appointmentId'] as String? ?? '';

      if (agoraToken != null && agoraToken.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '📞 [VoIPCallService] Found pending call with Agora token',
          );
        }

        _pendingCallData = PendingCallData(
          callId: lastCall['id'] as String? ?? _uuid.v4(),
          appointmentId: appointmentId,
          callerName: lastCall['nameCaller'] as String? ?? 'طبيب',
          agoraToken: extra?['agoraToken'] as String?,
          agoraChannelName: extra?['agoraChannelName'] as String?,
          agoraUid: extra?['agoraUid'] as int?,
        );

        if (kDebugMode) {
          debugPrint(
            '✅ [VoIPCallService] Restored pending call data for cold start',
          );
        }
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error checking active calls: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow initialization to continue
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error checking active calls: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow initialization to continue
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Unexpected error checking active calls: $e',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow initialization to continue
    }
  }

  /// Handle CallKit events
  ///
  /// Processes all CallKit/ConnectionService events including:
  /// - Call accepted
  /// - Call declined
  /// - Call ended
  /// - Call timeout (missed call)
  ///
  /// Events are broadcast through [callEventStream] for UI consumption.
  void _handleCallKitEvent(CallEvent? event) {
    if (event == null) return;

    debugPrint('📞 CallKit Event: ${event.event}');

    switch (event.event) {
      case Event.actionCallAccept:
        // المستخدم أجاب على المكالمة
        _onCallAccepted(event);
      case Event.actionCallDecline:
        // المستخدم رفض المكالمة
        _onCallDeclined(event);
      case Event.actionCallEnded:
        // انتهت المكالمة
        _onCallEnded(event);
      case Event.actionCallTimeout:
        // انتهت مهلة المكالمة
        _onCallTimeout(event);
      case Event.actionCallStart:
        // بدأت المكالمة
        debugPrint('📞 Call started');
      default:
        debugPrint('📞 Unhandled event: ${event.event}');
    }
  }

  /// Show incoming call UI
  ///
  /// Displays a native incoming call screen using CallKit (iOS) or
  /// ConnectionService (Android). The call UI appears even when the app
  /// is in background or terminated.
  ///
  /// Parameters:
  /// - [callerName]: Name of the caller (required)
  /// - [callerAvatar]: Avatar URL of the caller (required)
  /// - [appointmentId]: Appointment ID for tracking (required)
  /// - [agoraToken]: Agora token for joining channel (optional)
  /// - [agoraChannelName]: Agora channel name (optional)
  /// - [agoraUid]: Agora user ID (optional)
  /// - [callerNumber]: Phone number or description (optional)
  ///
  /// Throws:
  /// - [VoIPException] if call UI display fails
  /// - [NetworkException] if network connection unavailable
  ///
  /// Example:
  /// ```dart
  /// await VoIPCallService().showIncomingCall(
  ///   callerName: 'Dr. Ahmed',
  ///   callerAvatar: 'https://example.com/avatar.jpg',
  ///   appointmentId: 'appt_123',
  ///   agoraToken: 'generated_token',
  ///   agoraChannelName: 'appointment_123',
  ///   agoraUid: 12345,
  /// );
  /// ```
  Future<void> showIncomingCall({
    required String callerName,
    required String callerAvatar,
    required String appointmentId,
    String? agoraToken,
    String? agoraChannelName,
    int? agoraUid,
    String? callerNumber,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📞 [VoIPCallService] Showing incoming call from: $callerName',
        );
        debugPrint('📞 [VoIPCallService] Appointment ID: $appointmentId');
      }

      // Generate unique call ID
      final callId = _uuid.v4();
      _currentCallId = callId;

      // Store pending call data for when user answers
      _pendingCallData = PendingCallData(
        callId: callId,
        appointmentId: appointmentId,
        callerName: callerName,
        agoraToken: agoraToken,
        agoraChannelName: agoraChannelName,
        agoraUid: agoraUid,
      );

      // Configure call parameters
      final params = CallKitParams(
        id: callId,
        nameCaller: callerName,
        appName: 'AndroCare360',
        avatar: callerAvatar,
        handle: callerNumber ?? 'استشارة طبية',
        type: 1, // Video call
        textAccept: 'رد',
        textDecline: 'رفض',
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: false,
          subtitle: 'مكالمة فائتة',
          callbackText: 'معاودة الاتصال',
        ),
        duration: 60000, // 60 seconds ring timeout
        extra: <String, dynamic>{
          'appointmentId': appointmentId,
          'agoraToken': agoraToken,
          'agoraChannelName': agoraChannelName,
          'agoraUid': agoraUid,
        },
        headers: <String, dynamic>{},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          isShowFullLockedScreen: true, // ✅ ظهور فوق شاشة القفل
          isCustomSmallExNotification: true, // ✅ إشعار مصغر مخصص
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: '',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: 'مكالمات واردة',
          missedCallNotificationChannelName: 'مكالمات فائتة',
          isShowCallID: false,
        ),
        ios: const IOSParams(
          iconName: 'AppIcon',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: false,
          supportsHolding: false,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );

      // Show incoming call UI
      await FlutterCallkitIncoming.showCallkitIncoming(params);

      // ✅ NEW: Log call display to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        debugPrint(
          '📱 Displaying incoming call UI for appointment: $appointmentId',
        );

        // Intentionally not awaited - logging happens in background
        unawaited(
          _callMonitoring.logCallSuccess(
            appointmentId: appointmentId,
            userId: userId,
            channelName: 'voip_call_display',
            metadata: {
              'eventType': 'voip_call_displayed',
              'callerName': callerName,
              'callId': callId,
            },
          ),
        );
      }

      // Emit event
      _callEventController.add(
        VoIPCallEvent(
          type: VoIPCallEventType.incoming,
          callId: callId,
          callerName: callerName,
        ),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [VoIPCallService] Incoming call UI displayed successfully',
        );
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error showing incoming call: ${e.code} - ${e.message}',
        );
        debugPrint(
          '❌ [VoIPCallService] Caller: $callerName, Appointment: $appointmentId',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw VoIPException(
        'Failed to show incoming call notification: ${e.message}',
        originalError: e,
      );
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error showing incoming call: ${e.message}',
        );
        debugPrint(
          '❌ [VoIPCallService] Caller: $callerName, Appointment: $appointmentId',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw NetworkException(
        'Network error showing incoming call: No internet connection',
        originalError: e,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Unexpected error showing incoming call: $e',
        );
        debugPrint(
          '❌ [VoIPCallService] Caller: $callerName, Appointment: $appointmentId',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      throw VoIPException(
        'Unexpected error showing incoming call',
        originalError: e,
      );
    }
  }

  /// Handle call accepted event
  ///
  /// Called when user accepts an incoming call.
  /// Supports cold start by reading call data from event body if needed.
  ///
  /// Emits [VoIPCallEventType.accepted] event with call data.
  void _onCallAccepted(CallEvent event) {
    debugPrint('✅ Call accepted');
    debugPrint('📦 Event body: ${event.body}');

    final callId = event.body['id'] as String?;
    if (callId == null) {
      debugPrint('❌ No call ID in event');
      return;
    }

    // ✅ محاولة الحصول على بيانات المكالمة
    var callData = _pendingCallData;

    // ✅ Cold Start: إذا كانت البيانات فارغة، نقرأ من extra في الحدث
    if (callData == null || callData.agoraChannelName == null) {
      debugPrint(
        '⚠️ _pendingCallData is null/empty, reading from event.body["extra"]',
      );

      final extra = event.body['extra'] as Map<dynamic, dynamic>?;
      debugPrint('📦 Extra data from event: $extra');

      if (extra != null) {
        final agoraToken = extra['agoraToken'] as String?;
        final agoraChannelName = extra['agoraChannelName'] as String?;
        final agoraUid = extra['agoraUid'] as int?;
        final appointmentId = extra['appointmentId'] as String? ?? '';

        debugPrint('🔗 Agora token from extra: $agoraToken');

        if (agoraToken != null && agoraChannelName != null) {
          callData = PendingCallData(
            callId: callId,
            appointmentId: appointmentId,
            callerName: event.body['nameCaller'] as String? ?? 'طبيب',
            agoraToken: agoraToken,
            agoraChannelName: agoraChannelName,
            agoraUid: agoraUid,
          );
          _pendingCallData = callData;
        }
      }
    }

    // ✅ NEW: Log call accepted by user
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final appointmentId = callData?.appointmentId;
    if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
      debugPrint('✅ Call accepted by user');

      // Intentionally not awaited - logging happens in background
      unawaited(
        _callMonitoring.logCallSuccess(
          appointmentId: appointmentId,
          userId: userId,
          channelName: 'voip_call_accepted',
          metadata: {
            'eventType': 'voip_call_accepted',
            'callId': callId,
          },
        ),
      );
    }

    // Emit event
    _callEventController.add(
      VoIPCallEvent(
        type: VoIPCallEventType.accepted,
        callId: callId,
        data: callData,
      ),
    );

    // Navigate to Agora call screen (navigation will be handled by caller)
    debugPrint('✅ Call accepted, ready to join Agora channel');
  }

  /// Handle call declined event
  ///
  /// Called when user declines an incoming call.
  /// Notifies server of declined call via Cloud Functions.
  ///
  /// Emits [VoIPCallEventType.declined] event.
  void _onCallDeclined(CallEvent event) {
    debugPrint('❌ Call declined');

    final callId = event.body['id'] as String?;
    if (callId == null) return;

    // ✅ NEW: Log call declined by user
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final appointmentId = _pendingCallData?.appointmentId;
    if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
      debugPrint('❌ Call declined by user');

      // Intentionally not awaited - logging happens in background
      unawaited(
        _callMonitoring.logCallSuccess(
          appointmentId: appointmentId,
          userId: userId,
          channelName: 'voip_call_declined',
          metadata: {
            'eventType': 'voip_call_declined',
            'callId': callId,
          },
        ),
      );
    }

    // ✅ إخطار السيرفر برفض المكالمة
    if (appointmentId != null) {
      // Intentionally not awaited - server notification happens in background
      unawaited(_notifyServerCallDeclined(appointmentId));
    }

    // Clear pending data
    _pendingCallData = null;
    _currentCallId = null;

    // Emit event
    _callEventController.add(
      VoIPCallEvent(
        type: VoIPCallEventType.declined,
        callId: callId,
      ),
    );
  }

  /// Handle call ended event
  ///
  /// Called when an active call ends.
  /// Cleans up call state and emits [VoIPCallEventType.ended] event.
  void _onCallEnded(CallEvent event) {
    debugPrint('📴 Call ended');

    final callId = event.body['id'] as String?;

    // ملاحظة: الخروج من الاجتماع يتم عبر تطبيق Zoom نفسه

    // Clear pending data
    _pendingCallData = null;
    _currentCallId = null;

    // Emit event
    _callEventController.add(
      VoIPCallEvent(
        type: VoIPCallEventType.ended,
        callId: callId ?? '',
      ),
    );
  }

  /// Handle call timeout event
  ///
  /// Called when user doesn't answer the call within timeout period.
  /// Notifies server of missed call via Cloud Functions.
  ///
  /// Emits [VoIPCallEventType.missed] event.
  void _onCallTimeout(CallEvent event) {
    debugPrint('⏰ Call timeout - missed call');

    final callId = event.body['id'] as String?;

    // ✅ إخطار السيرفر بالمكالمة الفائتة
    final appointmentId = _pendingCallData?.appointmentId;
    if (appointmentId != null) {
      // Intentionally not awaited - server notification happens in background
      unawaited(_notifyServerMissedCall(appointmentId));
    }

    // Clear pending data
    _pendingCallData = null;
    _currentCallId = null;

    // Emit event
    _callEventController.add(
      VoIPCallEvent(
        type: VoIPCallEventType.missed,
        callId: callId ?? '',
      ),
    );
  }

  /// Notify server of missed call
  ///
  /// Calls Firebase Cloud Function to log missed call event.
  /// Uses europe-west1 region as per project requirements.
  ///
  /// Errors are logged but not thrown as this is a background notification.
  Future<void> _notifyServerMissedCall(String appointmentId) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📤 [VoIPCallService] Notifying server of missed call: $appointmentId',
        );
      }

      await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('handleMissedCall')
          .call<void>(<String, dynamic>{'appointmentId': appointmentId});

      if (kDebugMode) {
        debugPrint(
          '✅ [VoIPCallService] Server notified of missed call successfully',
        );
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error notifying missed call: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error notifying missed call: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Unexpected error notifying missed call: $e',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    }
  }

  /// Notify server of declined call
  ///
  /// Calls Firebase Cloud Function to log declined call event.
  /// Uses europe-west1 region as per project requirements.
  ///
  /// Errors are logged but not thrown as this is a background notification.
  Future<void> _notifyServerCallDeclined(String appointmentId) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📤 [VoIPCallService] Notifying server of declined call: $appointmentId',
        );
      }

      await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('handleCallDeclined')
          .call<void>(<String, dynamic>{'appointmentId': appointmentId});

      if (kDebugMode) {
        debugPrint(
          '✅ [VoIPCallService] Server notified of declined call successfully',
        );
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error notifying declined call: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error notifying declined call: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Unexpected error notifying declined call: $e',
        );
        debugPrint('❌ [VoIPCallService] Appointment ID: $appointmentId');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - this is a background notification
    }
  }

  /// Clean up calls and notifications after call ends
  ///
  /// Ends all active CallKit calls and clears local state.
  /// Returns the appointment ID of the active call if one existed.
  ///
  /// This method should be called when returning to the app after a call
  /// to ensure CallKit notifications are properly dismissed.
  ///
  /// Returns: Appointment ID of the active call, or null if none
  ///
  /// Example:
  /// ```dart
  /// final appointmentId = await VoIPCallService().cleanupAfterCall();
  /// if (appointmentId != null) {
  ///   // Navigate to appointment details
  /// }
  /// ```
  Future<String?> cleanupAfterCall() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🧹 [VoIPCallService] Cleaning up VoIP calls and notifications...',
        );
      }

      // الحصول على معرف الموعد قبل مسح البيانات
      final appointmentId = _pendingCallData?.appointmentId;

      // إنهاء جميع المكالمات في CallKit لإزالة الإشعار
      await FlutterCallkitIncoming.endAllCalls();

      // مسح البيانات المحلية
      _pendingCallData = null;
      _currentCallId = null;

      if (kDebugMode) {
        debugPrint(
          '✅ [VoIPCallService] VoIP cleanup complete. Returning appointmentId: $appointmentId',
        );
      }
      return appointmentId;
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error during cleanup: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      return null;
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error during cleanup: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      return null;
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [VoIPCallService] Unexpected error during cleanup: $e');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// End the current active call
  ///
  /// Ends the current call in CallKit/ConnectionService and clears state.
  /// Errors are logged but not thrown to allow cleanup to continue.
  ///
  /// Example:
  /// ```dart
  /// await VoIPCallService().endCall();
  /// ```
  Future<void> endCall() async {
    try {
      if (_currentCallId != null) {
        await FlutterCallkitIncoming.endCall(_currentCallId!);
      }

      // ملاحظة: الخروج من الاجتماع يتم عبر تطبيق Zoom نفسه

      // Clear state
      _pendingCallData = null;
      _currentCallId = null;

      if (kDebugMode) {
        debugPrint('✅ [VoIPCallService] Call ended successfully');
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error ending call: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error ending call: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [VoIPCallService] Unexpected error ending call: $e');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    }
  }

  /// End all active calls
  ///
  /// Ends all calls in CallKit/ConnectionService and clears state.
  /// Errors are logged but not thrown to allow cleanup to continue.
  ///
  /// Example:
  /// ```dart
  /// await VoIPCallService().endAllCalls();
  /// ```
  Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      // ملاحظة: الخروج من الاجتماع يتم عبر تطبيق Zoom نفسه

      _pendingCallData = null;
      _currentCallId = null;

      if (kDebugMode) {
        debugPrint('✅ [VoIPCallService] All calls ended successfully');
      }
    } on FirebaseFunctionsException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Firebase Functions Error ending all calls: ${e.code} - ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [VoIPCallService] Network Error ending all calls: ${e.message}',
        );
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [VoIPCallService] Unexpected error ending all calls: $e');
        debugPrint('❌ [VoIPCallService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    }
  }

  /// Dispose of service resources
  ///
  /// Closes the call event stream controller.
  /// Should be called when the service is no longer needed.
  void dispose() {
    // Intentionally not awaited - cleanup happens in background
    unawaited(_callEventController.close());
  }
}

/// Pending call data
///
/// Contains call information needed to join an Agora channel when user accepts a call.
/// This data is stored when an incoming call is received and used when the call is accepted.
///
/// Supports cold start scenarios where the app is opened from a call notification.
class PendingCallData {
  /// Creates pending call data
  ///
  /// Parameters:
  /// - [callId]: Unique call identifier (required)
  /// - [appointmentId]: Appointment ID for tracking (required)
  /// - [callerName]: Name of the caller (required)
  /// - [agoraToken]: Agora token for joining channel (optional)
  /// - [agoraChannelName]: Agora channel name (optional)
  /// - [agoraUid]: Agora user ID (optional)
  PendingCallData({
    required this.callId,
    required this.appointmentId,
    required this.callerName,
    this.agoraToken,
    this.agoraChannelName,
    this.agoraUid,
  });

  /// Unique call identifier
  final String callId;

  /// Appointment ID for tracking
  final String appointmentId;

  /// Name of the caller
  final String callerName;

  /// Agora token for joining channel
  final String? agoraToken;

  /// Agora channel name
  final String? agoraChannelName;

  /// Agora user ID
  final int? agoraUid;
}

/// VoIP call event types
///
/// Defines all possible call event types that can be emitted by [VoIPCallService].
/// These events are broadcast through [VoIPCallService.callEventStream].
enum VoIPCallEventType {
  /// Incoming call received
  incoming,

  /// Call was accepted by user
  accepted,

  /// Call was declined by user
  declined,

  /// Call ended
  ended,

  /// Call was missed (timeout)
  missed,
}

/// VoIP call event data
///
/// Contains event-specific data for VoIP call events.
/// Different event types use different fields:
/// - [VoIPCallEventType.incoming]: uses [callId] and [callerName]
/// - [VoIPCallEventType.accepted]: uses [callId] and [data] (with Agora credentials)
/// - [VoIPCallEventType.declined]/[VoIPCallEventType.ended]/[VoIPCallEventType.missed]: uses [callId]
class VoIPCallEvent {
  /// Creates a VoIP call event
  ///
  /// Parameters:
  /// - [type]: Event type (required)
  /// - [callId]: Unique call identifier (required)
  /// - [callerName]: Name of the caller (optional)
  /// - [data]: Pending call data with Agora credentials (optional)
  VoIPCallEvent({
    required this.type,
    required this.callId,
    this.callerName,
    this.data,
  });

  /// Event type
  final VoIPCallEventType type;

  /// Unique call identifier
  final String callId;

  /// Name of the caller (for incoming events)
  final String? callerName;

  /// Pending call data with Agora credentials (for accepted events)
  final PendingCallData? data;
}
