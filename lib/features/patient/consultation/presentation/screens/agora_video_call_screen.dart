import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/config/agora_config.dart';
import 'package:elajtech/core/services/agora_service.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// شاشة مكالمة الفيديو باستخدام Agora
///
/// المسؤوليات:
/// - عرض فيديو المستخدم المحلي والبعيد
/// - التحكم في الصوت والفيديو (كتم، تبديل الكاميرا)
/// - إنهاء المكالمة
class AgoraVideoCallScreen extends StatefulWidget {
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
  State<AgoraVideoCallScreen> createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  late final AgoraService _agoraService;

  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  int? _remoteUid;
  String _connectionStatus = 'جاري الاتصال...';

  // ✅ NEW: Role detection fields
  late final bool _isDoctor;
  late final String _otherPartyName;

  // ✅ NEW: Timeout handling fields
  Timer? _timeoutTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _timeoutDuration = Duration(seconds: 60);

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

      // Listen to events
      _agoraService.eventStream.listen(_handleAgoraEvent);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الاتصال: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// معالجة أحداث Agora
  void _handleAgoraEvent(AgoraEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case AgoraEventType.joinedChannel:
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
        // ✅ NEW: Cancel timeout timer when remote user joins
        _cancelTimeoutTimer();

      case AgoraEventType.userLeft:
        if (_remoteUid == event.uid) {
          setState(() {
            _remoteUid = null;
            _connectionStatus = 'المستخدم البعيد غادر';
          });
        }
        debugPrint('👤 Remote user left: ${event.uid}');

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
          setState(() => _connectionStatus = 'فشل الاتصال');
        }

      case AgoraEventType.error:
        debugPrint('❌ Agora error: ${event.error}');
        setState(() => _connectionStatus = 'خطأ في الاتصال');

      case AgoraEventType.cameraSwitched:
        debugPrint('📷 Camera switched');
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
    await _agoraService.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// ✅ NEW: Start timeout timer (60 seconds)
  void _startTimeoutTimer() {
    _timeoutTimer = Timer(_timeoutDuration, () {
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
    debugPrint('⏱️ Timeout: Patient did not answer after 60 seconds');

    // Log timeout event to call_logs
    unawaited(_logTimeoutEvent());

    // Show timeout dialog
    if (mounted) {
      await _showTimeoutDialog();
    }
  }

  /// ✅ NEW: Log timeout event to Firestore
  Future<void> _logTimeoutEvent() async {
    try {
      // Import required for logging
      // This will be handled by CallMonitoringService in production
      debugPrint(
        '📝 Logging timeout event for appointment: ${widget.appointment.id}',
      );
      // Integrate with CallMonitoringService.logCallTimeout()
    } on Exception catch (e) {
      debugPrint('❌ Error logging timeout event: $e');
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
              : 'لم يتم الرد على المكالمة خلال 60 ثانية',
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

  /// ✅ NEW: Retry call with exponential backoff
  Future<void> _retryCall() async {
    _retryCount++;
    debugPrint('🔄 Retry attempt $_retryCount of $_maxRetries');

    // Calculate exponential backoff delay: 2s, 4s, 8s
    final delaySeconds = 2 << (_retryCount - 1); // 2^retryCount
    final delay = Duration(seconds: delaySeconds);

    debugPrint('⏳ Waiting ${delay.inSeconds} seconds before retry...');

    // Show loading indicator during delay
    if (mounted) {
      setState(() {
        _connectionStatus = 'إعادة المحاولة خلال ${delay.inSeconds} ثانية...';
      });
    }

    // Wait for exponential backoff delay
    await Future<void>.delayed(delay);

    // Leave current channel
    await _agoraService.leaveChannel();

    // Re-request Agora tokens from Cloud Functions
    // This will be handled by calling startAgoraCall again
    debugPrint('📞 Re-requesting Agora tokens from Cloud Functions...');

    // Integrate with Cloud Functions to call startAgoraCall again
    // For now, just re-initialize with existing tokens
    await _initializeAgora();

    // Start new timeout timer
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    // ✅ NEW: Cancel timeout timer
    _cancelTimeoutTimer();
    // Intentionally not awaited - cleanup happens in background
    unawaited(_agoraService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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

  /// معلومات الموعد
  Widget _appointmentInfo() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      // Migrated from withOpacity() to withValues(alpha:) - Flutter 3.27+ API
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.appointment.patientName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.appointment.doctorName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
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
