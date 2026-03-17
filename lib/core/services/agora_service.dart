import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';

/// Agora Service - خدمة إدارة Agora RTC Engine
///
/// المسؤوليات:
/// - تهيئة Agora RTC Engine
/// - الانضمام/المغادرة من قنوات Agora
/// - التحكم في الصوت والفيديو (كتم، تبديل الكاميرا)
/// - إدارة أحداث المستخدمين البعيدين
///
/// **Dependency Injection:**
/// This service uses constructor injection for better testability.
/// Dependencies can be provided or will default to production instances.
///
/// Example usage:
/// ```dart
/// // Production usage (uses default instances)
/// final service = AgoraService();
///
/// // Test usage (inject mocks)
/// final service = AgoraService(
///   callMonitoringService: mockCallMonitoring,
/// );
/// ```
class AgoraService {
  /// Constructor with optional dependency injection
  ///
  /// Parameters:
  /// - [callMonitoringService]: Call monitoring service (defaults to CallMonitoringService())
  AgoraService({
    CallMonitoringService? callMonitoringService,
  }) : _callMonitoringServiceInstance = callMonitoringService;

  /// Agora RTC Engine instance
  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  /// Current channel name
  String? _currentChannel;
  String? get currentChannel => _currentChannel;

  /// Local user ID
  int? _localUid;
  int? get localUid => _localUid;

  /// Remote users in the channel
  final Set<int> _remoteUsers = {};
  Set<int> get remoteUsers => Set.unmodifiable(_remoteUsers);

  /// Stream controller for engine events
  final StreamController<AgoraEvent> _eventController =
      StreamController<AgoraEvent>.broadcast();
  Stream<AgoraEvent> get eventStream => _eventController.stream;

  /// Local audio muted
  bool _isLocalAudioMuted = false;
  bool get isLocalAudioMuted => _isLocalAudioMuted;

  /// Local video muted
  bool _isLocalVideoMuted = false;
  bool get isLocalVideoMuted => _isLocalVideoMuted;

  /// Call monitoring service (injected or lazy-loaded)
  final CallMonitoringService? _callMonitoringServiceInstance;
  late final CallMonitoringService _callMonitoringService =
      _callMonitoringServiceInstance ?? getIt<CallMonitoringService>();

  /// Current appointment ID (for monitoring)
  String? _currentAppointmentId;

  /// Current user ID (for monitoring)
  String? _currentUserId;

  /// Initialize Agora RTC Engine
  ///
  /// Initializes the Agora RTC Engine with the provided App ID and configures
  /// video/audio settings. This method must be called before joining any channel.
  ///
  /// The initialization process includes:
  /// - Requesting camera and microphone permissions
  /// - Creating and configuring RTC engine
  /// - Enabling video and audio
  /// - Setting video encoder configuration (640x480, 15fps)
  /// - Registering event handlers
  ///
  /// Parameters:
  /// - [appId]: Agora App ID from Agora Console (required)
  ///
  /// Throws:
  /// - [AgoraException] if initialization fails
  /// - [PlatformException] if platform-specific error occurs
  ///
  /// Example:
  /// ```dart
  /// await agoraService.initialize('your_agora_app_id');
  /// ```
  Future<void> initialize(String appId) async {
    try {
      if (kDebugMode) {
        debugPrint('📹 [AgoraService] Initializing Agora RTC Engine...');
        debugPrint('📹 [AgoraService] App ID: ${appId.substring(0, 8)}...');
      }

      // Request permissions first
      await _requestPermissions();

      // Create engine
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      // Set video configuration
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      // Register event handlers
      _registerEventHandlers();

      if (kDebugMode) {
        debugPrint(
          '✅ [AgoraService] Agora RTC Engine initialized successfully',
        );
      }
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error during initialization: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      throw AgoraException(
        'Failed to initialize Agora RTC Engine: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error during initialization: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      throw AgoraException(
        'Platform error during Agora initialization: ${e.message ?? "Unknown platform error"}',
        code: e.code,
        originalError: e,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Unexpected error during initialization: $e',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      throw AgoraException(
        'Unexpected error during Agora initialization',
        originalError: e,
      );
    }
  }

  /// Request required permissions for camera and microphone
  ///
  /// Requests both camera and microphone permissions required for video calls.
  /// This is called automatically during initialization.
  ///
  /// Throws `PermissionException` if permissions are denied.
  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  /// Register Agora RTC Engine event handlers
  ///
  /// Sets up callbacks for all Agora events including:
  /// - Join/leave channel events
  /// - Remote user join/leave events
  /// - Connection state changes
  /// - Local audio/video state changes
  /// - Error events
  ///
  /// All events are broadcast through `eventStream` for UI consumption.
  /// Critical errors are logged to CallMonitoringService for debugging.
  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        // عند الانضمام للقناة بنجاح
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('✅ Joined channel: ${connection.channelId}');
          _localUid = connection.localUid;
          _eventController.add(
            AgoraEvent(
              type: AgoraEventType.joinedChannel,
              channelId: connection.channelId,
              uid: connection.localUid,
            ),
          );
        },

        // عند انضمام مستخدم بعيد
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('👤 Remote user joined: $remoteUid');
          _remoteUsers.add(remoteUid);
          _eventController.add(
            AgoraEvent(
              type: AgoraEventType.userJoined,
              channelId: connection.channelId,
              uid: remoteUid,
            ),
          );
        },

        // عند مغادرة مستخدم بعيد
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('👤 Remote user left: $remoteUid (reason: $reason)');
              _remoteUsers.remove(remoteUid);
              _eventController.add(
                AgoraEvent(
                  type: AgoraEventType.userLeft,
                  channelId: connection.channelId,
                  uid: remoteUid,
                ),
              );
            },

        // عند حدوث خطأ
        onError: (ErrorCodeType err, String msg) {
          debugPrint('❌ Agora error: $err - $msg');
          _eventController.add(
            AgoraEvent(
              type: AgoraEventType.error,
              error: msg,
            ),
          );
        },

        // عند مغادرة القناة
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('📴 Left channel: ${connection.channelId}');
          _currentChannel = null;
          _localUid = null;
          _remoteUsers.clear();
          _eventController.add(
            AgoraEvent(
              type: AgoraEventType.leftChannel,
              channelId: connection.channelId,
            ),
          );
        },

        // عند تغيير حالة الاتصال
        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
            ) async {
              debugPrint('🔌 Connection state: $state (reason: $reason)');
              _eventController.add(
                AgoraEvent(
                  type: AgoraEventType.connectionStateChanged,
                  connectionState: state,
                ),
              );

              // تسجيل فشل الاتصال إذا حدث
              if ((state == ConnectionStateType.connectionStateFailed ||
                      state ==
                          ConnectionStateType.connectionStateDisconnected) &&
                  _currentAppointmentId != null &&
                  _currentUserId != null) {
                await _callMonitoringService.logConnectionFailure(
                  appointmentId: _currentAppointmentId!,
                  userId: _currentUserId!,
                  reason: 'Connection state: $state, Reason: $reason',
                  metadata: {
                    'connectionState': state.toString(),
                    'connectionReason': reason.toString(),
                  },
                );
              }
            },

        // عند تغيير حالة الفيديو المحلي
        onLocalVideoStateChanged:
            (
              VideoSourceType source,
              LocalVideoStreamState state,
              LocalVideoStreamReason reason,
            ) async {
              debugPrint('📹 Local video state: $state (reason: $reason)');

              // تسجيل أخطاء الكاميرا
              if (state == LocalVideoStreamState.localVideoStreamStateFailed &&
                  _currentAppointmentId != null &&
                  _currentUserId != null) {
                await _callMonitoringService.logMediaDeviceError(
                  appointmentId: _currentAppointmentId!,
                  userId: _currentUserId!,
                  deviceType: 'camera',
                  errorMessage: 'Camera failed: $reason',
                );
              }
            },

        // عند تغيير حالة الصوت المحلي
        onLocalAudioStateChanged:
            (
              RtcConnection connection,
              LocalAudioStreamState state,
              LocalAudioStreamReason reason,
            ) async {
              debugPrint('🎤 Local audio state: $state (reason: $reason)');

              // تسجيل أخطاء الميكروفون
              if (state == LocalAudioStreamState.localAudioStreamStateFailed &&
                  _currentAppointmentId != null &&
                  _currentUserId != null) {
                await _callMonitoringService.logMediaDeviceError(
                  appointmentId: _currentAppointmentId!,
                  userId: _currentUserId!,
                  deviceType: 'microphone',
                  errorMessage: 'Microphone failed: $reason',
                );
              }
            },
      ),
    );
  }

  /// Join an Agora channel for video call
  ///
  /// Joins the specified Agora channel with the provided token and user ID.
  /// This method also logs the call attempt and success/failure to CallMonitoringService.
  ///
  /// Parameters:
  /// - [token]: Agora token generated server-side (required for security)
  /// - [channelName]: Channel name (e.g., 'appointment_123')
  /// - [uid]: User ID (0 for auto-generation by Agora)
  /// - [appointmentId]: Appointment ID for call monitoring (optional)
  /// - [userId]: User ID for call monitoring (optional)
  ///
  /// Throws:
  /// - [AgoraException] if engine not initialized or join fails
  /// - [NetworkException] if network connection unavailable
  ///
  /// Example:
  /// ```dart
  /// await agoraService.joinChannel(
  ///   token: 'generated_token',
  ///   channelName: 'appointment_123',
  ///   uid: 0,
  ///   appointmentId: 'appt_123',
  ///   userId: 'user_456',
  /// );
  /// ```
  Future<void> joinChannel({
    required String token,
    required String channelName,
    int uid = 0,
    String? appointmentId,
    String? userId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📹 [AgoraService] Joining Agora channel: $channelName');
        debugPrint('📹 [AgoraService] User ID: $userId');
        debugPrint('📹 [AgoraService] Appointment ID: $appointmentId');
        debugPrint('📹 [AgoraService] UID: $uid');
      }

      if (_engine == null) {
        throw const AgoraException('Agora engine not initialized');
      }

      // حفظ معلومات المراقبة
      _currentChannel = channelName;
      _currentAppointmentId = appointmentId;
      _currentUserId = userId;

      // تسجيل محاولة الانضمام
      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallAttempt(
          appointmentId: appointmentId,
          userId: userId,
        );
      }

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      // تسجيل نجاح الانضمام
      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallSuccess(
          appointmentId: appointmentId,
          userId: userId,
          channelName: channelName,
          metadata: {'uid': uid},
        );
      }

      if (kDebugMode) {
        debugPrint('✅ [AgoraService] Join channel request sent successfully');
      }
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error joining channel: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Channel: $channelName, User: $userId');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }

      // تسجيل خطأ الانضمام
      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallError(
          appointmentId: appointmentId,
          userId: userId,
          errorType: 'agora_join_channel_failed',
          errorMessage: 'Agora Error ${e.code}: ${e.message}',
          stackTrace: stackTrace.toString(),
        );
      }

      throw AgoraException(
        'Failed to join Agora channel: ${e.message}',
        code: e.code.toString(),
        originalError: e,
      );
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error joining channel: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Channel: $channelName, User: $userId');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }

      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallError(
          appointmentId: appointmentId,
          userId: userId,
          errorType: 'platform_join_channel_failed',
          errorMessage: e.message ?? 'Unknown platform error',
          stackTrace: stackTrace.toString(),
        );
      }

      throw AgoraException(
        'Platform error joining channel: ${e.message ?? "Unknown platform error"}',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Network Error joining channel: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Channel: $channelName, User: $userId');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }

      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallError(
          appointmentId: appointmentId,
          userId: userId,
          errorType: 'network_join_channel_failed',
          errorMessage: 'Network error: ${e.message}',
          stackTrace: stackTrace.toString(),
        );
      }

      throw NetworkException(
        'Network error joining channel: No internet connection',
        originalError: e,
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error joining channel: $e');
        debugPrint('❌ [AgoraService] Channel: $channelName, User: $userId');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }

      if (appointmentId != null && userId != null) {
        await _callMonitoringService.logCallError(
          appointmentId: appointmentId,
          userId: userId,
          errorType: 'unexpected_join_channel_error',
          errorMessage: e.toString(),
          stackTrace: stackTrace.toString(),
        );
      }

      throw AgoraException(
        'Unexpected error joining channel',
        originalError: e,
      );
    }
  }

  /// Leave the current Agora channel
  ///
  /// Leaves the current channel and cleans up all local state including:
  /// - Current channel name
  /// - Local user ID
  /// - Remote users list
  /// - Audio/video mute states
  ///
  /// This method logs the call end event to CallMonitoringService.
  /// Errors during leave are logged but not thrown to allow cleanup to continue.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.leaveChannel();
  /// ```
  Future<void> leaveChannel() async {
    try {
      if (_engine == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [AgoraService] Engine not initialized');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('📴 [AgoraService] Leaving channel: $_currentChannel');
        debugPrint('📴 [AgoraService] User ID: $_currentUserId');
      }

      // تسجيل إنهاء المكالمة
      if (_currentAppointmentId != null && _currentUserId != null) {
        await _callMonitoringService.logCallEnded(
          appointmentId: _currentAppointmentId!,
          userId: _currentUserId!,
        );
      }

      await _engine!.leaveChannel();

      _currentChannel = null;
      _localUid = null;
      _remoteUsers.clear();
      _isLocalAudioMuted = false;
      _isLocalVideoMuted = false;
      _currentAppointmentId = null;
      _currentUserId = null;

      if (kDebugMode) {
        debugPrint('✅ [AgoraService] Left channel successfully');
      }
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error leaving channel: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error leaving channel: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error leaving channel: $e');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow cleanup to continue
    }
  }

  /// Toggle local microphone mute state
  ///
  /// Toggles the local audio stream between muted and unmuted states.
  /// The new state is broadcast through [eventStream] as [AgoraEventType.localAudioMuteChanged].
  ///
  /// Errors are logged but not thrown to allow user retry.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.toggleMicrophone();
  /// print('Microphone muted: ${agoraService.isLocalAudioMuted}');
  /// ```
  Future<void> toggleMicrophone() async {
    try {
      if (_engine == null) return;

      _isLocalAudioMuted = !_isLocalAudioMuted;
      await _engine!.muteLocalAudioStream(_isLocalAudioMuted);

      if (kDebugMode) {
        debugPrint(
          '🎤 [AgoraService] Microphone ${_isLocalAudioMuted ? 'muted' : 'unmuted'}',
        );
      }

      _eventController.add(
        AgoraEvent(
          type: AgoraEventType.localAudioMuteChanged,
          isMuted: _isLocalAudioMuted,
        ),
      );
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error toggling microphone: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error toggling microphone: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error toggling microphone: $e');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    }
  }

  /// Toggle local camera mute state
  ///
  /// Toggles the local video stream between muted and unmuted states.
  /// The new state is broadcast through [eventStream] as [AgoraEventType.localVideoMuteChanged].
  ///
  /// Errors are logged but not thrown to allow user retry.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.toggleCamera();
  /// print('Camera muted: ${agoraService.isLocalVideoMuted}');
  /// ```
  Future<void> toggleCamera() async {
    try {
      if (_engine == null) return;

      _isLocalVideoMuted = !_isLocalVideoMuted;
      await _engine!.muteLocalVideoStream(_isLocalVideoMuted);

      if (kDebugMode) {
        debugPrint(
          '📹 [AgoraService] Camera ${_isLocalVideoMuted ? 'muted' : 'unmuted'}',
        );
      }

      _eventController.add(
        AgoraEvent(
          type: AgoraEventType.localVideoMuteChanged,
          isMuted: _isLocalVideoMuted,
        ),
      );
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error toggling camera: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error toggling camera: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error toggling camera: $e');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    }
  }

  /// Switch between front and rear camera
  ///
  /// Switches the active camera between front-facing and rear-facing cameras.
  /// The switch event is broadcast through [eventStream] as [AgoraEventType.cameraSwitched].
  ///
  /// Errors are logged but not thrown to allow user retry.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.switchCamera();
  /// ```
  Future<void> switchCamera() async {
    try {
      if (_engine == null) return;

      await _engine!.switchCamera();

      if (kDebugMode) {
        debugPrint('🔄 [AgoraService] Camera switched');
      }

      _eventController.add(
        AgoraEvent(type: AgoraEventType.cameraSwitched),
      );
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error switching camera: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error switching camera: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error switching camera: $e');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    }
  }

  /// Enable or disable speakerphone
  ///
  /// Controls whether audio output is routed to the device's speakerphone or earpiece.
  ///
  /// Parameters:
  /// - [enabled]: true to enable speakerphone, false to use earpiece
  ///
  /// Errors are logged but not thrown to allow user retry.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.setEnableSpeakerphone(enabled: true);
  /// ```
  Future<void> setEnableSpeakerphone({required bool enabled}) async {
    try {
      if (_engine == null) return;

      await _engine!.setEnableSpeakerphone(enabled);

      if (kDebugMode) {
        debugPrint(
          '🔊 [AgoraService] Speakerphone ${enabled ? 'enabled' : 'disabled'}',
        );
      }
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error setting speakerphone: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error setting speakerphone: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Unexpected error setting speakerphone: $e',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow user to retry
    }
  }

  /// Dispose of Agora service resources
  ///
  /// Cleans up all Agora resources including:
  /// - Leaving current channel
  /// - Releasing RTC engine
  /// - Closing event stream
  ///
  /// This method should be called when the service is no longer needed.
  /// Errors during disposal are logged but not thrown to allow cleanup to complete.
  ///
  /// Example:
  /// ```dart
  /// await agoraService.dispose();
  /// ```
  Future<void> dispose() async {
    try {
      if (kDebugMode) {
        debugPrint('🧹 [AgoraService] Disposing Agora service...');
      }

      await leaveChannel();
      await _engine?.release();
      _engine = null;

      await _eventController.close();

      if (kDebugMode) {
        debugPrint('✅ [AgoraService] Agora service disposed successfully');
      }
    } on AgoraRtcException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Agora RTC Error during disposal: ${e.message} (code: ${e.code})',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow disposal to complete
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [AgoraService] Platform Error during disposal: ${e.message}',
        );
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow disposal to complete
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AgoraService] Unexpected error during disposal: $e');
        debugPrint('❌ [AgoraService] Stack trace: $stackTrace');
      }
      // Don't throw - allow disposal to complete
    }
  }
}

/// Agora event types
///
/// Defines all possible event types that can be emitted by [AgoraService].
/// These events are broadcast through [AgoraService.eventStream] for UI consumption.
enum AgoraEventType {
  /// Successfully joined a channel
  joinedChannel,

  /// Successfully left a channel
  leftChannel,

  /// A remote user joined the channel
  userJoined,

  /// A remote user left the channel
  userLeft,

  /// Local audio mute state changed
  localAudioMuteChanged,

  /// Local video mute state changed
  localVideoMuteChanged,

  /// Camera was switched (front/rear)
  cameraSwitched,

  /// Connection state changed
  connectionStateChanged,

  /// An error occurred
  error,
}

/// Agora event data
///
/// Contains event-specific data for Agora events.
/// Different event types use different fields:
/// - `joinedChannel`/`leftChannel`: uses `channelId` and `uid`
/// - `userJoined`/`userLeft`: uses `channelId` and `uid`
/// - `localAudioMuteChanged`/`localVideoMuteChanged`: uses `isMuted`
/// - `connectionStateChanged`: uses `connectionState`
/// - `error`: uses `error`
class AgoraEvent {
  /// Creates an Agora event
  ///
  /// Parameters:
  /// - [type]: Event type (required)
  /// - [channelId]: Channel ID for channel-related events
  /// - [uid]: User ID for user-related events
  /// - [isMuted]: Mute state for mute-related events
  /// - [connectionState]: Connection state for connection events
  /// - [error]: Error message for error events
  AgoraEvent({
    required this.type,
    this.channelId,
    this.uid,
    this.isMuted,
    this.connectionState,
    this.error,
  });

  /// Event type
  final AgoraEventType type;

  /// Channel ID (for channel-related events)
  final String? channelId;

  /// User ID (for user-related events)
  final int? uid;

  /// Mute state (for mute-related events)
  final bool? isMuted;

  /// Connection state (for connection events)
  final ConnectionStateType? connectionState;

  /// Error message (for error events)
  final String? error;
}
