import 'dart:async';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/services/voip_call_service.dart';
import 'package:flutter/material.dart';

/// Incoming Call Screen - شاشة المكالمة الواردة
///
/// تعرض واجهة مستخدم على غرار واتساب للمكالمات الواردة
///
/// المميزات:
/// - عرض اسم المتصل وصورته
/// - أزرار الرد والرفض
/// - رسوم متحركة للموجات
/// - عداد الوقت
///
/// ملاحظة:
/// - هذه الشاشة تُستخدم كـ fallback عندما لا يعمل CallKit الأصلي
/// - عادة يعالج CallKit/ConnectionService العرض تلقائياً
class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({
    required this.callerName,
    required this.appointmentId,
    this.callerAvatar,
    this.onAnswer,
    this.onDecline,
    super.key,
  });

  /// اسم المتصل (الطبيب)
  final String callerName;

  /// معرف الموعد
  final String appointmentId;

  /// رابط صورة المتصل (اختياري)
  final String? callerAvatar;

  /// Callback عند الرد على المكالمة
  final VoidCallback? onAnswer;

  /// Callback عند رفض المكالمة
  final VoidCallback? onDecline;

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isAnswering = false;
  bool _isDeclining = false;

  @override
  void initState() {
    super.initState();

    // تهيئة رسوم متحركة للنبض
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Intentionally not awaited - animation starts in background
    unawaited(_pulseController.repeat(reverse: true));

    _pulseAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // تهيئة رسوم متحركة للموجات
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    // Intentionally not awaited - animation starts in background
    unawaited(_waveController.repeat());

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// الرد على المكالمة
  Future<void> _answerCall() async {
    if (_isAnswering) return;

    setState(() => _isAnswering = true);

    widget.onAnswer?.call();

    // لا نغلق الشاشة هنا - VoIPCallService سيتعامل مع التنقل
  }

  /// رفض المكالمة
  Future<void> _declineCall() async {
    if (_isDeclining) return;

    setState(() => _isDeclining = true);

    widget.onDecline?.call();

    // إنهاء المكالمة عبر VoIPCallService
    await getIt<VoIPCallService>().endCall();

    // إغلاق الشاشة
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1B2838),
    body: SafeArea(
      child: Column(
        children: [
          const Spacer(),

          // معلومات المتصل
          Column(
            children: [
              // اسم نوع المكالمة
              Text(
                'استشارة فيديو واردة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // صورة المتصل مع أنيميشن النبض
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // موجات متحركة خلف الصورة
                    ...List.generate(3, _buildWaveRing),

                    // صورة المتصل
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child:
                          widget.callerAvatar != null &&
                              widget.callerAvatar!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                widget.callerAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildDefaultAvatar(),
                              ),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // اسم المتصل
              Text(
                widget.callerName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // وصف المكالمة
              Text(
                'يتصل بك الآن...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const Spacer(flex: 2),

          // أزرار الرد والرفض
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر الرفض
                _buildCallButton(
                  icon: Icons.call_end,
                  color: AppColors.error,
                  label: 'رفض',
                  onTap: () => unawaited(_declineCall()),
                  isLoading: _isDeclining,
                ),

                // زر الرد
                _buildCallButton(
                  icon: Icons.videocam,
                  color: AppColors.success,
                  label: 'رد',
                  onTap: () => unawaited(_answerCall()),
                  isLoading: _isAnswering,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    ),
  );

  /// بناء حلقة موجة متحركة
  Widget _buildWaveRing(int index) => AnimatedBuilder(
    animation: _waveAnimation,
    builder: (context, child) {
      final delay = index * 0.3;
      final progress = (_waveAnimation.value + delay) % 1.0;
      final opacity = (1.0 - progress) * 0.3;
      final scale = 1.0 + (progress * 0.5);

      return Transform.scale(
        scale: scale,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: opacity),
              width: 2,
            ),
          ),
        ),
      );
    },
  );

  /// بناء صورة افتراضية
  Widget _buildDefaultAvatar() => const Center(
    child: Icon(
      Icons.person,
      size: 60,
      color: Colors.white,
    ),
  );

  /// بناء زر المكالمة
  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    ],
  );
}
