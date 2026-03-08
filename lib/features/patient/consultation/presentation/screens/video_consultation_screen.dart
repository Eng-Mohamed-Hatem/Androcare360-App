import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/doctor_model.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Video Consultation Screen - شاشة استشارة الفيديو
///
/// تستخدم Agora SDK للمكالمات المرئية داخل التطبيق
/// رابط الاجتماع يأتي من appointment.meetingLink
class VideoConsultationScreen extends ConsumerStatefulWidget {
  const VideoConsultationScreen({
    required this.appointment,
    required this.doctor,
    super.key,
  });

  final AppointmentModel appointment;
  final DoctorModel doctor;

  @override
  ConsumerState<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState
    extends ConsumerState<VideoConsultationScreen> {
  bool _isConnecting = false;
  bool _isInCall = false;

  @override
  void initState() {
    super.initState();
    // ملاحظة: نستخدم الآن Agora SDK للمكالمات المدمجة
    // يتم تحديث _isInCall عند الانضمام للاجتماع
  }

  /// الانضمام للاجتماع
  Future<void> _joinMeeting() async {
    setState(() => _isConnecting = true);

    try {
      // التحقق من مزود الاجتماع
      final provider = widget.appointment.meetingProvider;
      if (provider == 'agora') {
        // استخدام Agora SDK
        await _joinAgoraCall();
      } else {
        // التوافق العكسي مع Jitsi Meet
        await _joinLegacyMeeting();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  /// الانضمام عبر Agora Video Call
  Future<void> _joinAgoraCall() async {
    try {
      // الانتقال لشاشة Agora
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AgoraVideoCallScreen(
            appointment: widget.appointment,
          ),
        ),
      );
      // بعد العودة من شاشة المكالمة، نفترض أن المكالمة انتهت
      if (mounted) {
        setState(() => _isInCall = false);
      }
    } on Exception catch (e) {
      debugPrint('❌ Error navigating to Agora call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء الانتقال لمكالمة الفيديو'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// الانضمام عبر الرابط القديم (Jitsi Meet)
  Future<void> _joinLegacyMeeting() async {
    final meetingLink = widget.appointment.meetingLink;

    if (meetingLink == null || meetingLink.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الاجتماع غير جاهز بعد، يرجى الانتظار...'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    final meetUrl = Uri.parse(meetingLink);

    if (await canLaunchUrl(meetUrl)) {
      await launchUrl(meetUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح رابط الاجتماع'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// مغادرة الاجتماع
  Future<void> _leaveMeeting() async {
    // يتم التحكم في المكالمة داخل AgoraVideoCallScreen
    // هنا نقوم فقط بتحديث حالة الواجهة
    if (mounted) {
      setState(() => _isInCall = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('استشارة فيديو'),
      actions: _isInCall
          ? [
              // ملاحظة: التحكم يتم عبر تطبيق Zoom الخارجي
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'يمكنك التحكم في الكاميرا والميكروفون من داخل شاشة المكالمة',
                      ),
                    ),
                  );
                },
                tooltip: 'معلومات',
              ),
            ]
          : null,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Doctor Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isInCall
                    ? [
                        AppColors.success,
                        AppColors.success.withValues(alpha: 0.7),
                      ]
                    : [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Doctor Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Doctor Name
                Text(
                  widget.doctor.fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Specialization
                Text(
                  widget.doctor.specializationsFormatted,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                // حالة المكالمة
                if (_isInCall) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                        const Text(
                          'متصل الآن',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Appointment Details
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'تاريخ الموعد',
            value:
                '${widget.appointment.appointmentDate.day}/${widget.appointment.appointmentDate.month}/${widget.appointment.appointmentDate.year}',
          ),
          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.access_time,
            title: 'وقت الموعد',
            value: widget.appointment.timeSlot,
          ),
          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.videocam,
            title: 'نوع الاستشارة',
            value: widget.appointment.meetingProvider == 'agora'
                ? 'استشارة فيديو (Agora)'
                : 'استشارة فيديو',
          ),

          const SizedBox(height: 32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تعليمات الاستشارة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _InstructionItem('تأكد من اتصال إنترنت جيد'),
                const _InstructionItem('استخدم سماعات للحصول على صوت أفضل'),
                const _InstructionItem('اختر مكان هادئ للاستشارة'),
                const _InstructionItem('جهز أي تقارير طبية سابقة'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
          if (_isInCall)
            // زر إنهاء المكالمة
            CustomButton(
              text: 'إنهاء الاستشارة',
              onPressed: _leaveMeeting,
              backgroundColor: AppColors.error,
              icon: Icons.call_end,
              height: 56,
            )
          else
            // زر الانضمام للمكالمة
            CustomButton(
              text: _isConnecting ? 'جاري الاتصال...' : 'الانضمام للاستشارة',
              onPressed: _isConnecting ? () {} : _joinMeeting,
              isLoading: _isConnecting,
              icon: Icons.videocam,
              height: 56,
            ),

          const SizedBox(height: 16),

          // Cancel Button
          if (!_isInCall)
            CustomButton(
              text: 'إلغاء الموعد',
              onPressed: () {
                Navigator.pop(context);
              },
              isOutlined: true,
              height: 56,
            ),

          const SizedBox(height: 24),

          // Note
          Text(
            widget.appointment.meetingProvider == 'agora'
                ? 'ملاحظة: الاستشارة تتم عبر تقنية Agora Video SDK داخل التطبيق'
                : 'ملاحظة: سيتم فتح الاجتماع في متصفح خارجي',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

/// Info Card Widget
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Instruction Item Widget
class _InstructionItem extends StatelessWidget {
  const _InstructionItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.info, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.info),
          ),
        ),
      ],
    ),
  );
}
