import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/config/agora_config.dart';
import 'package:elajtech/features/patient/consultation/presentation/providers/consultation_call_providers.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/agora_service.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/core/services/video_consultation_service.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة مكالمة الفيديو باستخدام Agora
///
/// المسؤوليات:
/// - عرض فيديو المستخدم المحلي والبعيد
/// - التحكم في الصوت والفيديو (كتم، تبديل الكاميرا)
/// - إنهاء المكالمة
class AgoraVideoCallScreen extends ConsumerStatefulWidget {
  AgoraVideoCallScreen({
    required this.appointment,
    this.firebaseAuth, // ✅ Optional for testing
    super.key,
  }) : assert(
         appointment.agoraToken != null &&
             appointment.agoraChannelName != null &&
             appointment.agoraUid != null,
         'Agora data (token, channelName, uid) must not be null',
       );

  final AppointmentModel appointment;
  final FirebaseAuth? firebaseAuth; // ✅ Inject for testing

  @override
  ConsumerState<AgoraVideoCallScreen> createState() =>
      _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends ConsumerState<AgoraVideoCallScreen> {
  static const Duration _doctorAnswerTimeout = Duration(seconds: 60);

  late final AgoraService _agoraService;

  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  int? _remoteUid;
  String _connectionStatus = 'جاري الاتصال...';
  bool _didReachInProgress = false;
  bool _isEndingCall = false;

  // ✅ NEW: Role detection fields
  late final bool _isDoctor;
  late final String _otherPartyName;

  StreamSubscription<AgoraEvent>? _agoraEventSub;

  // ✅ NEW: Timeout handling fields
  Timer? _timeoutTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Reconnection grace period for network-dropped remote users
  Timer? _reconnectionTimer;
  static const Duration _reconnectionGrace = Duration(seconds: 15);

  void _showCallMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // ✅ NEW: Determine user role
    // Use injected auth for testing or default to FirebaseAuth.instance
    final auth = widget.firebaseAuth ?? FirebaseAuth.instance;
    final currentUserId = auth.currentUser?.uid;
    _isDoctor = currentUserId == widget.appointment.doctorId;
    _otherPartyName = _isDoctor
        ? widget.appointment.patientName
        : widget.appointment.doctorName;

    // Initialize AgoraService with dependency injection
    _agoraService = AgoraService();
    // Intentionally not awaited - initialization happens in background
    unawaited(_initializeAgora());

    // ✅ NEW: Start timeout timer if user is doctor
    if (_isDoctor) {
      _startTimeoutTimer();
    }
  }

  /// تهيئة Agora والانضمام للقناة
  Future<void> _initializeAgora() async {
    try {
      // Initialize Agora
      await _agoraService.initialize(AgoraConfig.appId);

      // Listen to events — subscription stored for cancellation in dispose()
      _agoraEventSub = _agoraService.eventStream.listen(_handleAgoraEvent);

      // Get Agora data with null safety
      final token = widget.appointment.agoraToken;
      final channelName = widget.appointment.agoraChannelName;
      final uid = widget.appointment.agoraUid;

      // Validate data before joining
      if (token == null || channelName == null || uid == null) {
        throw Exception(
          'بيانات Agora غير مكتملة. Token: ${token != null}, Channel: ${channelName != null}, UID: ${uid != null}',
        );
      }

      // Join channel with validated data
      await _agoraService.joinChannel(
        token: token,
        channelName: channelName,
        uid: uid,
      );
    } on Exception catch (e) {
      debugPrint('❌ Error initializing Agora: $e');
      ref.read(consultationCallControllerProvider.notifier).markJoinFailed();
      if (mounted) {
        _showCallMessage('Unable to connect to the call. Please try again.');
        Navigator.pop(context);
      }
    }
  }

  /// معالجة أحداث Agora
  void _handleAgoraEvent(AgoraEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case AgoraEventType.joinedChannel:
        ref
            .read(consultationCallControllerProvider.notifier)
            .markJoinSucceeded();
        setState(() {
          _isJoined = true;
          _connectionStatus = 'متصل';
        });
        debugPrint('✅ Joined channel successfully');

      case AgoraEventType.userJoined:
        setState(() {
          _remoteUid = event.uid;
          _connectionStatus = 'المستخدم البعيد انضم';
        });
        debugPrint('👤 Remote user joined: ${event.uid}');
        // Cancel timeout timer when remote user joins
        _cancelTimeoutTimer();
        // Cancel reconnection timer if doctor rejoined after a network drop
        _reconnectionTimer?.cancel();
        _reconnectionTimer = null;
        if (!_didReachInProgress) {
          _didReachInProgress = true;
          unawaited(_markCallInProgress());
        }

      case AgoraEventType.userLeft:
        if (_remoteUid == event.uid) {
          setState(() {
            _remoteUid = null;
            _connectionStatus = (event.isDropped ?? false)
                ? 'جارٍ إعادة الاتصال...'
                : 'المستخدم البعيد غادر';
          });
          if (!_isDoctor && mounted) {
            if (event.isDropped ?? false) {
              // Network drop — give the doctor a grace period to reconnect
              _showCallMessage('Connection lost. Waiting for doctor to reconnect…');
              _reconnectionTimer?.cancel();
              _reconnectionTimer = Timer(_reconnectionGrace, () {
                if (mounted) {
                  _showCallMessage('The call has ended.');
                  Navigator.pop(context);
                }
              });
            } else {
              // Intentional leave — end immediately
              _showCallMessage('The call has ended.');
              Navigator.pop(context);
            }
          }
        }
        debugPrint('👤 Remote user left: ${event.uid} (dropped: ${event.isDropped})');

      case AgoraEventType.leftChannel:
        debugPrint('📴 Left channel');

      case AgoraEventType.localAudioMuteChanged:
        setState(() => _isMuted = event.isMuted ?? false);

      case AgoraEventType.localVideoMuteChanged:
        setState(() => _isVideoOff = event.isMuted ?? false);

      case AgoraEventType.connectionStateChanged:
        debugPrint('🔌 Connection state: ${event.connectionState}');
        if (event.connectionState ==
            ConnectionStateType.connectionStateFailed) {
          ref
              .read(consultationCallControllerProvider.notifier)
              .markJoinFailed();
          setState(() => _connectionStatus = 'فشل الاتصال');
          _showCallMessage('Unable to connect to the call. Please try again.');
        }

      case AgoraEventType.error:
        debugPrint('❌ Agora error: ${event.error}');
        ref.read(consultationCallControllerProvider.notifier).markJoinFailed();
        setState(() => _connectionStatus = 'خطأ في الاتصال');
        _showCallMessage('Unable to connect to the call. Please try again.');

      case AgoraEventType.cameraSwitched:
        debugPrint('📷 Camera switched');

      case AgoraEventType.tokenExpired:
        // التوكن انتهت صلاحيته أثناء المكالمة — أظهر رسالة للمستخدم
        debugPrint('⚠️ Agora token expired mid-call');
        _showCallMessage('انتهت صلاحية الجلسة. سيتم إعادة الاتصال...');
    }
  }

  /// تبديل كتم الصوت
  Future<void> _toggleMute() async {
    await _agoraService.toggleMicrophone();
  }

  /// تبديل الفيديو
  Future<void> _toggleVideo() async {
    await _agoraService.toggleCamera();
  }

  /// تبديل الكاميرا
  Future<void> _switchCamera() async {
    await _agoraService.switchCamera();
  }

  /// إنهاء المكالمة
  Future<void> _endCall() async {
    if (_isEndingCall) return;
    _isEndingCall = true;
    var shouldShowError = false;
    String? errorMessage;

    try {
      ref.read(consultationCallControllerProvider.notifier).markCallEnded();
      await VideoConsultationService().endVideoCall(
        appointmentId: widget.appointment.id,
      );
    } on Exception catch (e) {
      debugPrint('❌ Error ending call: $e');
      shouldShowError = true;
      errorMessage = 'تعذر إنهاء المكالمة: $e';
    } finally {
      try {
        await _agoraService.leaveChannel();
      } on Exception catch (e) {
        debugPrint('❌ Error leaving Agora channel: $e');
      }

      // Dismiss CallKit/ConnectionService notification from notification bar
      if (getIt.isRegistered<VoIPCallService>()) {
        try {
          await getIt<VoIPCallService>().endAllCalls();
        } on Exception catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [AgoraVideoCallScreen] Error dismissing CallKit notification: $e',
            );
          }
        }
      }

      if (mounted && shouldShowError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'تعذر إنهاء المكالمة'),
            backgroundColor: AppColors.error,
          ),
        );
      }

      if (mounted) {
        Navigator.pop<Map<String, dynamic>>(context, {
          'showCompletionDialog': _isDoctor && _didReachInProgress,
          'appointmentId': widget.appointment.id,
          'doctorId': widget.appointment.doctorId,
        });
      }

      _isEndingCall = false;
    }
  }

  Future<void> _markCallInProgress() async {
    try {
      await VideoConsultationService().markCallInProgress(
        appointmentId: widget.appointment.id,
      );
    } on Exception catch (e) {
      debugPrint('❌ Error marking call in progress: $e');
    }
  }

  /// Start doctor-side unanswered timeout timer.
  void _startTimeoutTimer() {
    _timeoutTimer = Timer(_doctorAnswerTimeout, () {
      if (_remoteUid == null && mounted) {
        unawaited(_onTimeout());
      }
    });
  }

  /// ✅ NEW: Cancel timeout timer
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// ✅ NEW: Handle timeout event
  Future<void> _onTimeout() async {
    debugPrint(
      '⏱️ Timeout: Patient did not answer after ${_doctorAnswerTimeout.inSeconds} seconds',
    );
    ref.read(consultationCallControllerProvider.notifier).markJoinFailed();

    // Log timeout event to call_logs
    unawaited(_logTimeoutEvent());

    // Show timeout dialog
    if (mounted) {
      await _showTimeoutDialog();
    }
  }

  /// Log call timeout to Firestore via CallMonitoringService.
  ///
  /// Uses [CallMonitoringService.logStructuredEvent] with eventType
  /// `'call_timeout'` so timeout incidents are queryable in `call_logs`.
  Future<void> _logTimeoutEvent() async {
    try {
      if (!getIt.isRegistered<CallMonitoringService>()) return;
      final auth = widget.firebaseAuth ?? FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      await getIt<CallMonitoringService>().logStructuredEvent(
        appointmentId: widget.appointment.id,
        userId: userId,
        eventType: 'call_timeout',
        metadata: {
          'timeoutSeconds': _doctorAnswerTimeout.inSeconds,
          'retryCount': _retryCount,
          'channelName': widget.appointment.agoraChannelName,
        },
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [AgoraVideoCallScreen] call_timeout logged for appointment=${widget.appointment.id}',
        );
      }
    } on Exception catch (e) {
      debugPrint('❌ [AgoraVideoCallScreen] Error logging timeout event: $e');
    }
  }

  /// ✅ NEW: Show timeout dialog with retry and cancel options
  Future<void> _showTimeoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'لم يرد المريض على المكالمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          _retryCount >= _maxRetries
              ? 'تم الوصول للحد الأقصى من المحاولات ($_maxRetries)'
              : 'لم يتم الرد على المكالمة خلال ${_doctorAnswerTimeout.inSeconds} ثانية',
          textAlign: TextAlign.center,
        ),
        actions: [
          if (_retryCount < _maxRetries)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(_retryCall());
              },
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 16),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(_endCall());
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 16,
                color: _retryCount >= _maxRetries
                    ? AppColors.primary
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Retry call with exponential backoff and fresh token from Cloud Functions.
  ///
  /// On each retry:
  /// 1. Applies exponential backoff delay (2s → 4s → 8s).
  /// 2. Leaves the current Agora channel cleanly.
  /// 3. Calls [VideoConsultationService.startVideoCall] to get a fresh channel
  ///    name and token from the server — avoids reusing a stale/expired token.
  /// 4. Rejoins the new channel and restarts the answer-timeout timer.
  Future<void> _retryCall() async {
    _retryCount++;
    debugPrint('🔄 Retry attempt $_retryCount of $_maxRetries');

    // ── Exponential backoff: 2 s, 4 s, 8 s ───────────────────────────────
    final delaySeconds = 2 << (_retryCount - 1); // 2^retryCount
    final delay = Duration(seconds: delaySeconds);
    debugPrint('⏳ Waiting ${delay.inSeconds} seconds before retry...');

    if (mounted) {
      setState(() {
        _connectionStatus = 'إعادة المحاولة خلال ${delay.inSeconds} ثانية...';
      });
    }
    await Future<void>.delayed(delay);

    // ── Leave the current (stale) channel ────────────────────────────────
    await _agoraService.leaveChannel();

    // ── Request fresh token + channel from Cloud Function ─────────────────
    debugPrint(
      '📞 [_retryCall] Requesting fresh Agora credentials from Cloud Functions...',
    );

    if (mounted) {
      setState(() => _connectionStatus = 'جاري إعادة الاتصال...');
    }

    try {
      final result = await VideoConsultationService().startVideoCall(
        appointmentId: widget.appointment.id,
        doctorId: widget.appointment.doctorId,
      );

      if (!result.success ||
          result.agoraToken == null ||
          result.agoraChannelName == null ||
          result.agoraUid == null) {
        throw Exception(
          'startVideoCall retry failed: ${result.error ?? "empty credentials"}',
        );
      }

      debugPrint(
        '✅ [_retryCall] Fresh credentials received'
        ' | channel=${result.agoraChannelName}'
        ' | uid=${result.agoraUid}',
      );

      // ── Join new channel with fresh credentials ────────────────────────
      await _agoraService.joinChannel(
        token: result.agoraToken!,
        channelName: result.agoraChannelName!,
        uid: result.agoraUid!,
        appointmentId: widget.appointment.id,
        userId: widget.appointment.doctorId,
      );

      // ── Restart answer-timeout timer ───────────────────────────────────
      _startTimeoutTimer();
    } on Exception catch (e) {
      debugPrint('❌ [_retryCall] Failed to get fresh credentials: $e');
      ref.read(consultationCallControllerProvider.notifier).markJoinFailed();
      if (mounted) {
        _showCallMessage('تعذرت إعادة الاتصال. يرجى المحاولة لاحقاً.');
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    unawaited(_agoraEventSub?.cancel() ?? Future<void>.value());
    // Cancel timeout and reconnection timers
    _cancelTimeoutTimer();
    _reconnectionTimer?.cancel();
    // Intentionally not awaited - cleanup happens in background
    unawaited(_agoraService.dispose());
    // Dismiss native VoIP notification even if _endCall() was not reached
    // (e.g. OS back gesture, exception path, or screen pop without end button)
    if (getIt.isRegistered<VoIPCallService>()) {
      unawaited(getIt<VoIPCallService>().endAllCalls());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          _remoteVideo(),

          // Local video (small preview)
          Positioned(
            top: 40,
            right: 16,
            child: _localVideoPreview(),
          ),

          // Connection status
          Positioned(
            top: 40,
            left: 16,
            child: _connectionStatusWidget(),
          ),

          // Controls at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _controlButtons(),
          ),

          // Appointment info
          Positioned(
            top: 100,
            left: 16,
            right: 100,
            child: _appointmentInfo(),
          ),
        ],
      ),
    );
  }

  /// فيديو المستخدم البعيد (ملء الشاشة)
  Widget _remoteVideo() {
    if (_remoteUid == null) {
      // ✅ Waiting Room UI - غرفة انتظار احترافية
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading indicator
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // Migrated from withOpacity() to withValues(alpha:) - Flutter 3.27+ API
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Main message - conditional based on user role
              Text(
                _isDoctor
                    ? 'جاري الاتصال بالمريض...'
                    : 'جاري الاتصال بالطبيب...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Sub message - conditional based on user role
              Text(
                _isDoctor
                    ? 'في انتظار رد $_otherPartyName...'
                    : 'يرجى الانتظار، سيتم الاتصال بك قريباً',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Connection status
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Migrated from withOpacity() to withValues(alpha:) - Flutter 3.27+ API
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _connectionStatus,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Safe check for engine
    final engine = _agoraService.engine;
    if (engine == null) {
      return const Center(
        child: Text(
          'جاري تهيئة المحرك...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(
          channelId: widget.appointment.agoraChannelName ?? '',
        ),
      ),
    );
  }

  /// معاينة الفيديو المحلي (صغيرة)
  Widget _localVideoPreview() {
    final engine = _agoraService.engine;

    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _isVideoOff || engine == null
            ? const Center(
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white,
                  size: 40,
                ),
              )
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
    );
  }

  /// حالة الاتصال
  Widget _connectionStatusWidget() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _isJoined ? AppColors.success : AppColors.warning,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _connectionStatus,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  /// معلومات الموعد — يعرض الطرف الآخر في المكالمة بحسب دور المستخدم.
  ///
  /// الطبيب يرى: "المريض: [اسم المريض]"
  /// المريض يرى: "الطبيب: [اسم الطبيب]"
  Widget _appointmentInfo() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isDoctor ? 'المريض' : 'الطبيب',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _otherPartyName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.appointment.specialization,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  /// أزرار التحكم
  Widget _controlButtons() => Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute button
        _controlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'إلغاء الكتم' : 'كتم',
          color: _isMuted ? AppColors.error : Colors.white,
          onPressed: () => unawaited(_toggleMute()),
        ),

        // Video button
        _controlButton(
          icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
          label: _isVideoOff ? 'تشغيل الفيديو' : 'إيقاف الفيديو',
          color: _isVideoOff ? AppColors.error : Colors.white,
          onPressed: () => unawaited(_toggleVideo()),
        ),

        // Switch camera button
        _controlButton(
          icon: Icons.flip_camera_ios,
          label: 'تبديل الكاميرا',
          color: Colors.white,
          onPressed: () => unawaited(_switchCamera()),
        ),

        // End call button
        _controlButton(
          icon: Icons.call_end,
          label: 'إنهاء',
          color: AppColors.error,
          backgroundColor: Colors.white,
          onPressed: () => unawaited(_endCall()),
        ),
      ],
    ),
  );

  /// زر تحكم واحد
  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          // Migrated from withOpacity() to withValues(alpha:) - Flutter 3.27+ API
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
          iconSize: 28,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    ],
  );
}
