import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/services/video_consultation_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class VoIPCallService {
  VoIPCallService(this._callMonitoring, this._firestore);

  static const Duration _answerFlowGuardDuration = Duration(seconds: 40);

  /// Call monitoring service for logging
  final CallMonitoringService _callMonitoring;

  /// Firestore instance for persisting VoIP push token
  final FirebaseFirestore _firestore;

  /// UUID generator for unique call IDs
  final Uuid _uuid = const Uuid();

  /// Stream controller for call events
  final StreamController<VoIPCallEvent> _callEventController =
      StreamController<VoIPCallEvent>.broadcast();

  /// Stream for listening to call events
  Stream<VoIPCallEvent> get callEventStream => _callEventController.stream;

  /// Subscription to CallKit/ConnectionService events.
  /// Stored to enable idempotent initialize() and proper disposal.
  StreamSubscription<CallEvent?>? _callKitSubscription;

  /// Current active call ID
  String? _currentCallId;
  String? get currentCallId => _currentCallId;

  /// Pending call data (for use when answering)
  PendingCallData? _pendingCallData;
  PendingCallData? get pendingCallData => _pendingCallData;

  String? _lastAcceptedCallId;

  bool _isAnswerAccepted = false;
  bool _isJoinInProgress = false;
  DateTime? _cleanupBlockedUntil;

  /// True while the native CallKit/ConnectionService ring screen is visible
  /// and the patient has not yet accepted or declined.
  /// Used to guard `cleanupAfterCall()` from dismissing a ringing call.
  bool _isIncomingCallRinging = false;

  /// True once the patient has successfully joined the Agora channel
  /// and the call is actively in progress.
  /// Set by [markJoinSucceeded], cleared by [markCallEnded].
  /// Guards `cleanupAfterCall()` from running while the user is mid-call.
  bool _isCallActive = false;

  /// True when the Agora channel has been successfully joined
  /// and the call is actively in progress.
  @visibleForTesting
  bool get isCallActive => _isCallActive;

  bool get isCleanupBlocked {
    if (!_isAnswerAccepted && !_isJoinInProgress) {
      return false;
    }

    final blockedUntil = _cleanupBlockedUntil;
    if (blockedUntil == null) {
      return _isAnswerAccepted || _isJoinInProgress;
    }

    return DateTime.now().isBefore(blockedUntil);
  }

  @visibleForTesting
  int? parseAgoraUid(dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    }

    if (rawValue is String) {
      return int.tryParse(rawValue);
    }

    return null;
  }

  Future<PendingCallData?> refreshPendingCallData() async {
    await _checkActiveCallsOnStartup();
    return _pendingCallData;
  }

  Future<bool> hasActiveCalls() async {
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      return activeCalls != null && (activeCalls as List).isNotEmpty;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [VoIPCallService] hasActiveCalls() failed: $e');
      }
      return false;
    }
  }

  Future<void> _endNativeCallsSafely({
    required String debugContext,
    String? fallbackCallId,
  }) async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [VoIPCallService] $debugContext endAllCalls failed: $error',
        );
      }

      final callId =
          fallbackCallId ?? _currentCallId ?? _pendingCallData?.callId;
      if (callId == null || callId.isEmpty) {
        return;
      }

      try {
        await FlutterCallkitIncoming.endCall(callId);
      } on Object catch (fallbackError) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [VoIPCallService] $debugContext endCall fallback also failed: $fallbackError',
          );
        }
      }
    }
  }

  void markAnswerAccepted() {
    _isAnswerAccepted = true;
    _isJoinInProgress = true;
    _cleanupBlockedUntil = DateTime.now().add(_answerFlowGuardDuration);
  }

  void markJoinStarted() {
    _isAnswerAccepted = true;
    _isJoinInProgress = true;
    _cleanupBlockedUntil ??= DateTime.now().add(_answerFlowGuardDuration);
    _logJoinEvent('join_started', null);
  }

  void markJoinSucceeded() {
    _logJoinEvent('join_success', null);
    _clearAnswerFlowBlock();
    _isCallActive = true;
  }

  void markJoinFailed() {
    _logJoinEvent('join_failure', 'agora_join_failed');
    _clearAnswerFlowBlock();
  }

  void _logJoinEvent(String eventType, String? errorCode) {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final appointmentId = _pendingCallData?.appointmentId;
      if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
        unawaited(
          _callMonitoring.logStructuredEvent(
            appointmentId: appointmentId,
            userId: userId,
            eventType: eventType,
            errorCode: errorCode,
            metadata: {'channelName': _pendingCallData?.agoraChannelName},
          ),
        );
      }
    } on Exception {
      // Firebase not initialized in test environment — skip logging
    }
  }

  void markCallEnded() {
    _isCallActive = false;
    _clearAnswerFlowBlock();
  }

  void _clearAnswerFlowBlock() {
    _isAnswerAccepted = false;
    _isJoinInProgress = false;
    _cleanupBlockedUntil = null;
    _lastAcceptedCallId = null;
  }

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

      // Listen to CallKit events — guard against double-initialization
      _callKitSubscription ??= FlutterCallkitIncoming.onEvent.listen(
        _handleCallKitEvent,
      );

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
        debugPrint(
          '📞 [VoIPCallService] Last active call id: ${lastCall['id']}',
        );
      }

      final extra = lastCall['extra'] as Map<dynamic, dynamic>?;
      // agoraToken is intentionally not stored in extra (security) —
      // cold-start calls restore call metadata only; token will be null.
      final appointmentId = extra?['appointmentId'] as String? ?? '';
      final channelName =
          extra?['channelName'] as String? ??
          extra?['agoraChannelName'] as String?;
      final agoraUid = parseAgoraUid(extra?['agoraUid']);

      if (appointmentId.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '📞 [VoIPCallService] Found pending call for appointment: $appointmentId',
          );
        }

        _pendingCallData = PendingCallData(
          callId: lastCall['id'] as String? ?? _uuid.v4(),
          appointmentId: appointmentId,
          callerName: lastCall['nameCaller'] as String? ?? 'طبيب',
          // agoraToken intentionally omitted — not stored in extra for security
          agoraChannelName: channelName,
          agoraUid: agoraUid,
        );

        if (kDebugMode) {
          debugPrint(
            '✅ [VoIPCallService] Restored pending call metadata for cold start',
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
      case Event.actionDidUpdateDevicePushTokenVoip:
        final body = event.body as Map<dynamic, dynamic>?;
        final voipToken = body?['deviceTokenVoIP'] as String?;
        if (voipToken != null && voipToken.isNotEmpty) {
          unawaited(_saveVoipToken(voipToken));
        }
      case Event.actionCallIncoming:
        // Native layer confirmed the ring screen is displayed — no Dart action needed.
        if (kDebugMode) {
          debugPrint(
            '📞 [VoIPCallService] Incoming call UI confirmed by native layer',
          );
        }
      case Event.actionCallConnected:
      case Event.actionCallCallback:
      case Event.actionCallToggleHold:
      case Event.actionCallToggleMute:
      case Event.actionCallToggleDmtf:
      case Event.actionCallToggleGroup:
      case Event.actionCallToggleAudioSession:
      case Event.actionCallCustom:
        if (kDebugMode) debugPrint('📞 Unhandled event: ${event.event}');
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

      // Clear any stale calls from previous sessions before showing new ring UI
      await _endNativeCallsSafely(
        debugContext: 'showIncomingCall pre-clear',
        fallbackCallId: _currentCallId,
      );
      if (kDebugMode) {
        debugPrint(
          '🧹 [VoIPCallService] Cleared stale calls before new incoming call',
        );
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
      _clearAnswerFlowBlock();
      _isIncomingCallRinging = true;

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
          'channelName': agoraChannelName,
          // agoraToken intentionally omitted — stored in _pendingCallData only
          'agoraChannelName': agoraChannelName,
          'agoraUid': agoraUid,
          'callerName': callerName,
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

      // Log incoming_call_received for background/terminated paths
      // (foreground path is logged by FCMService before showIncomingCall is called)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && appointmentId.isNotEmpty) {
        // Intentionally not awaited - logging happens in background
        unawaited(
          _callMonitoring.logStructuredEvent(
            appointmentId: appointmentId,
            userId: userId,
            eventType: 'incoming_call_received',
            metadata: {
              'appState': 'background_or_terminated',
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

    final body = Map<String, dynamic>.from(event.body as Map<dynamic, dynamic>);
    final callId = body['id'] as String?;
    if (callId == null) {
      debugPrint('❌ No call ID in event');
      return;
    }

    if (_lastAcceptedCallId == callId) {
      debugPrint(
        '⚠️ [VoIPCallService] Duplicate actionCallAccept ignored for callId=$callId',
      );
      return;
    }
    _lastAcceptedCallId = callId;

    // ✅ محاولة الحصول على بيانات المكالمة
    var callData = _pendingCallData;

    // ✅ Cold Start: إذا كانت البيانات فارغة، نقرأ من extra في الحدث
    if (callData == null || callData.agoraChannelName == null) {
      debugPrint(
        '⚠️ _pendingCallData is null/empty, reading from event.body["extra"]',
      );

      final extraRaw = body['extra'];
      final extra = extraRaw is Map<dynamic, dynamic>
          ? Map<String, dynamic>.from(extraRaw)
          : null;
      debugPrint('📦 Extra data from event: $extra');

      if (extra != null) {
        final agoraToken = extra['agoraToken'] as String?;
        final agoraChannelName =
            extra['channelName'] as String? ??
            extra['agoraChannelName'] as String?;
        final agoraUid = parseAgoraUid(extra['agoraUid']);
        final appointmentId = extra['appointmentId'] as String? ?? '';
        final callerName =
            extra['callerName'] as String? ??
            body['nameCaller'] as String? ??
            'طبيب';

        debugPrint('🔗 Agora token from extra: ${agoraToken != null}');

        // Restore callData even when agoraToken is null (security: token is
        // intentionally excluded from extra). patientJoinCall() will fetch a
        // fresh token from the server in the join flow.
        if (agoraChannelName != null) {
          callData = PendingCallData(
            callId: callId,
            appointmentId: appointmentId,
            callerName: callerName,
            agoraToken: agoraToken,
            agoraChannelName: agoraChannelName,
            agoraUid: agoraUid,
            acceptedFromCallKit: true,
          );
          _pendingCallData = callData;
        }
      }
    }

    _isIncomingCallRinging = false;
    markAnswerAccepted();

    if (callData != null && !callData.acceptedFromCallKit) {
      callData = PendingCallData(
        callId: callData.callId,
        appointmentId: callData.appointmentId,
        callerName: callData.callerName,
        agoraToken: callData.agoraToken,
        agoraChannelName: callData.agoraChannelName,
        agoraUid: callData.agoraUid,
        acceptedFromCallKit: true,
      );
      _pendingCallData = callData;
    }

    debugPrint(
      '📞 [VoIPCallService] answer accepted'
      ' | callId=$callId'
      ' | appointmentId=${callData?.appointmentId}'
      ' | channelName=${callData?.agoraChannelName}'
      ' | hasToken=${callData?.agoraToken != null}'
      ' | hasUid=${callData?.agoraUid != null}',
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final appointmentId = callData?.appointmentId;
    if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
      // Notify server immediately so the join grace period clock starts.
      // This prevents the doctor from ending the call before the patient joins.
      unawaited(
        VideoConsultationService()
            .notifyPatientAnswered(appointmentId: appointmentId)
            .catchError((Object error, StackTrace stackTrace) {
              debugPrint(
                '❌ [VoIPCallService] notifyPatientAnswered from accept handler failed'
                ' | appointmentId=$appointmentId | error=$error',
              );
            }),
      );
      debugPrint(
        '📞 [VoIPCallService] notifyPatientAnswered dispatched from accept handler'
        ' | appointmentId=$appointmentId'
        ' | userId=$userId',
      );

      // Log answer_accepted — canonical event
      unawaited(
        _callMonitoring.logStructuredEvent(
          appointmentId: appointmentId,
          userId: userId,
          eventType: 'answer_accepted',
          metadata: {
            'callId': callId,
            'restoredFromColdStart': _pendingCallData == null
                ? 'true'
                : 'false',
          },
        ),
      );

      // Log active_call_restored if credentials came from cold-start extra
      if (_pendingCallData?.callId == callId &&
          callData?.agoraChannelName != null) {
        unawaited(
          _callMonitoring.logStructuredEvent(
            appointmentId: appointmentId,
            userId: userId,
            eventType: 'active_call_restored',
            metadata: {
              'callId': callId,
              'channelName': callData!.agoraChannelName,
            },
          ),
        );
      }
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
    _isIncomingCallRinging = false;
    _isCallActive = false;
    debugPrint('❌ Call declined');

    final body = Map<String, dynamic>.from(event.body as Map<dynamic, dynamic>);
    final callId = body['id'] as String?;
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
    _clearAnswerFlowBlock();
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
    _isIncomingCallRinging = false;
    _isCallActive = false;
    debugPrint('📴 Call ended');

    final body = Map<String, dynamic>.from(event.body as Map<dynamic, dynamic>);
    final callId = body['id'] as String?;

    // Log callended — canonical event
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final appointmentId = _pendingCallData?.appointmentId;
    if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
      unawaited(
        _callMonitoring.logStructuredEvent(
          appointmentId: appointmentId,
          userId: userId,
          eventType: 'callended',
          metadata: {
            'callId': callId ?? '',
            'endedBy': 'local_callkit_event',
          },
        ),
      );
    }

    // Clear pending data
    _clearAnswerFlowBlock();
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
    _isIncomingCallRinging = false;
    _isCallActive = false;
    debugPrint('⏰ Call timeout - missed call');

    final body = Map<String, dynamic>.from(event.body as Map<dynamic, dynamic>);
    final callId = body['id'] as String?;

    // ✅ إخطار السيرفر بالمكالمة الفائتة
    final appointmentId = _pendingCallData?.appointmentId;
    if (appointmentId != null) {
      // Intentionally not awaited - server notification happens in background
      unawaited(_notifyServerMissedCall(appointmentId));
    }

    // Clear pending data
    _clearAnswerFlowBlock();
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
    // Guard: Cloud Function requires authentication. On cold start the patient's
    // app may fire the decline event before Firebase Auth restores the session.
    if (FirebaseAuth.instance.currentUser == null) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [VoIPCallService] _notifyServerCallDeclined skipped: not authenticated'
          ' | appointmentId=$appointmentId',
        );
      }
      return;
    }
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
  /// After calling this, callers should also invoke
  /// `FCMService.resetCallDeduplication()` so that a doctor retry call to the
  /// same appointment is not silently dropped by the duplicate-push guard.
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
      if (_isIncomingCallRinging) {
        if (kDebugMode) {
          debugPrint(
            '⏳ [VoIPCallService] Skipping cleanup: incoming call is still ringing.',
          );
        }
        return null;
      }

      if (_isCallActive) {
        if (kDebugMode) {
          debugPrint(
            '⏳ [VoIPCallService] Skipping cleanup: Agora call is currently active.',
          );
        }
        return null;
      }

      if (isCleanupBlocked) {
        if (kDebugMode) {
          debugPrint(
            '⏳ [VoIPCallService] Skipping cleanup because answer/join flow is still active.',
          );
        }
        return null;
      }

      // NEW: Check native layer — background isolate may have shown a ring via
      // bgVoipService without the main singleton knowing (_isIncomingCallRinging
      // was set on bgVoipService's instance, not ours).
      try {
        final nativeCalls = await FlutterCallkitIncoming.activeCalls();
        if (nativeCalls != null && (nativeCalls as List).isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
              '⏳ [VoIPCallService] Skipping cleanup: native layer has active call(s).',
            );
          }
          // Sync _pendingCallData if main singleton missed showIncomingCall()
          if (_pendingCallData == null) await _checkActiveCallsOnStartup();
          _isIncomingCallRinging = true; // keep guards consistent
          return null;
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [VoIPCallService] activeCalls() check failed: $e');
        }
      }

      if (kDebugMode) {
        debugPrint(
          '🧹 [VoIPCallService] Cleaning up VoIP calls and notifications...',
        );
      }

      // الحصول على معرف الموعد قبل مسح البيانات
      final appointmentId = _pendingCallData?.appointmentId;

      // Log cleanup_triggered — canonical event
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && appointmentId != null && appointmentId.isNotEmpty) {
        unawaited(
          _callMonitoring.logStructuredEvent(
            appointmentId: appointmentId,
            userId: userId,
            eventType: 'cleanup_triggered',
            metadata: {'reason': 'lifecycle_resumed'},
          ),
        );
      }

      // إنهاء جميع المكالمات في CallKit لإزالة الإشعار
      await _endNativeCallsSafely(
        debugContext: 'cleanupAfterCall',
        fallbackCallId: _currentCallId,
      );

      // مسح البيانات المحلية
      _clearAnswerFlowBlock();
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
      await _endNativeCallsSafely(
        debugContext: 'endCall',
        fallbackCallId: _currentCallId,
      );

      // ملاحظة: الخروج من الاجتماع يتم عبر تطبيق Zoom نفسه

      // Clear state
      _clearAnswerFlowBlock();
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
      await _endNativeCallsSafely(
        debugContext: 'endAllCalls',
        fallbackCallId: _currentCallId,
      );
      // ملاحظة: الخروج من الاجتماع يتم عبر تطبيق Zoom نفسه

      _clearAnswerFlowBlock();
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
  /// Closes the call event stream controller and cancels CallKit subscription.
  /// Should be called when the service is no longer needed.
  void dispose() {
    unawaited(_callKitSubscription?.cancel());
    _callKitSubscription = null;
    // Intentionally not awaited - cleanup happens in background
    unawaited(_callEventController.close());
  }

  /// Persists the iOS VoIP push token to Firestore so Cloud Functions can
  /// deliver direct APNs VoIP pushes to the patient's device.
  Future<void> _saveVoipToken(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      await _firestore.collection('users').doc(userId).set(
        {
          'voipToken': token,
          'voipTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) {
        debugPrint('[VoIPCallService] VoIP token saved for $userId');
      }
    } on Exception catch (e) {
      debugPrint('[VoIPCallService] Failed to save VoIP token: $e');
    }
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
    this.acceptedFromCallKit = false,
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

  /// Indicates the patient accepted from native CallKit/ConnectionService.
  final bool acceptedFromCallKit;
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
