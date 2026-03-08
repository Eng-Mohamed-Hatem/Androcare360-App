import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/config/agora_config.dart';
import 'package:elajtech/core/services/agora_service.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
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
    super.key,
  }) : assert(
         appointment.agoraToken != null &&
             appointment.agoraChannelName != null &&
             appointment.agoraUid != null,
         'Agora data (token, channelName, uid) must not be null',
       );

  final AppointmentModel appointment;

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

  @override
  void initState() {
    super.initState();
    // Initialize AgoraService with dependency injection
    _agoraService = AgoraService();
    // Intentionally not awaited - initialization happens in background
    unawaited(_initializeAgora());
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

      default:
        break;
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

  @override
  void dispose() {
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
                  color: Colors.white.withOpacity(0.1),
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

              // Main message
              const Text(
                'جاري الاتصال بالطبيب...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Sub message
              const Text(
                'يرجى الانتظار، سيتم الاتصال بك قريباً',
                style: TextStyle(
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
                  color: Colors.white.withOpacity(0.1),
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
      color: Colors.black.withOpacity(0.5),
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
          color: backgroundColor ?? Colors.white.withOpacity(0.2),
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
