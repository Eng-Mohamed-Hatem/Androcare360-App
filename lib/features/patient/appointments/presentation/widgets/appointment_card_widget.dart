import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/call_monitoring_service.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/reschedule_appointment_sheet.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Appointment Card Widget — بطاقة الموعد
///
/// Displays a single appointment with status-aware action areas:
/// - "Waiting for Call" non-interactive label when outside the 10-minute join window
/// - "Join Meeting" button when inside the join window or a live session is active
/// - "Reschedule" button for pending/confirmed appointments more than 2 hours away
/// - "View Medical Record" icon for completed appointments
class AppointmentCardWidget extends ConsumerStatefulWidget {
  const AppointmentCardWidget({
    required this.appointment,
    this.onJoinMeeting,
    this.onConfirmationRequiredTap,
    this.onRescheduled,
    this.onMedicalRecordTap,
    this.isJoining = false,
    this.isDoctorView = false,
    super.key,
  });

  final AppointmentModel appointment;
  final Future<void> Function()? onJoinMeeting;
  final Future<void> Function()? onConfirmationRequiredTap;

  /// Called after a successful reschedule with the new DateTime.
  final void Function(DateTime newDateTime)? onRescheduled;

  /// Called when the patient taps the "View Medical Record" icon on a completed card.
  final void Function()? onMedicalRecordTap;

  final bool isJoining;
  final bool isDoctorView;

  static const Map<AppointmentStatus, String> patientStatusLabels = {
    AppointmentStatus.scheduled: 'مجدول',
    AppointmentStatus.calling: 'الطبيب يتصل',
    AppointmentStatus.inProgress: 'في الاجتماع',
    AppointmentStatus.missed: 'مكالمة فائتة',
    AppointmentStatus.declined: 'تم رفض المكالمة',
    AppointmentStatus.endedPendingConfirmation: 'في انتظار التأكيد',
    AppointmentStatus.completed: 'مكتمل',
    AppointmentStatus.notCompleted: 'الجلسة غير مكتملة',
  };

  @override
  ConsumerState<AppointmentCardWidget> createState() =>
      _AppointmentCardWidgetState();
}

class _AppointmentCardWidgetState extends ConsumerState<AppointmentCardWidget> {
  // ─── Computed Booleans ──────────────────────────────────────────────────────

  /// True when the current time is within 10 minutes before the appointment's
  /// scheduled start (and the status is confirmed).
  bool get _isInJoinWindow {
    if (widget.appointment.status != AppointmentStatus.confirmed) return false;
    final fullDt = widget.appointment.fullDateTime;
    return DateTime.now().isAfter(
      fullDt.subtract(const Duration(minutes: 10)),
    );
  }

  /// True when the appointment has fresh Agora credentials from doctor's call.
  bool get _hasAgoraCredentials {
    final token = widget.appointment.agoraToken;
    final channel = widget.appointment.agoraChannelName;
    return token != null &&
        token.isNotEmpty &&
        channel != null &&
        channel.isNotEmpty;
  }

  /// True when the "Join Meeting" button should be shown.
  bool get _canJoinMeeting {
    final hasLiveCallWindow =
        widget.appointment.callStartedAt != null &&
        widget.appointment.status != AppointmentStatus.completed;

    return widget.appointment.status == AppointmentStatus.calling ||
        widget.appointment.status == AppointmentStatus.inProgress ||
        (widget.appointment.status == AppointmentStatus.missed &&
            widget.appointment.callSessionActive) ||
        hasLiveCallWindow ||
        _isInJoinWindow ||
        _hasAgoraCredentials;
  }

  bool get _isUpcomingAppointment =>
      widget.appointment.fullDateTime.isAfter(DateTime.now()) &&
      widget.appointment.status != AppointmentStatus.cancelled;

  bool get _hasValidMeetingLink {
    final link = widget.appointment.meetingLink;
    return link != null &&
        link.isNotEmpty &&
        link != 'pending' &&
        (link.startsWith('http://') || link.startsWith('https://'));
  }

  bool get _showMeetingUnavailable =>
      widget.appointment.type == AppointmentType.video &&
      _isUpcomingAppointment &&
      !_canJoinMeeting &&
      !_hasValidMeetingLink;

  /// True when the join action area (button + badge) should be visible.
  ///
  /// Shows the join button only when the meeting is actually actionable or
  /// very close in time — avoids showing a disabled button on every future
  /// video appointment (which would confuse the patient).
  ///
  /// Conditions to show:
  /// 1. Doctor has initiated the call (Agora credentials on appointment), OR
  /// 2. A valid external meeting link exists, OR
  /// 3. The appointment is within the 10-minute join window, OR
  /// 4. The appointment is live (calling / inProgress / missed+active).
  bool get _showJoinActionForUpcomingVideo {
    if (widget.appointment.type != AppointmentType.video) return false;
    if (!_isUpcomingAppointment) return false;
    // Show only when there is something actionable or imminent.
    return _hasAgoraCredentials ||
        _hasValidMeetingLink ||
        _isInJoinWindow ||
        (widget.appointment.callStartedAt != null &&
            widget.appointment.status != AppointmentStatus.completed) ||
        widget.appointment.status == AppointmentStatus.calling ||
        widget.appointment.status == AppointmentStatus.inProgress ||
        (widget.appointment.status == AppointmentStatus.missed &&
            widget.appointment.callSessionActive);
  }

  bool get _isJoinActionEnabled => _canJoinMeeting || _hasValidMeetingLink;

  String get _meetingUnavailableMessage {
    if (widget.appointment.status == AppointmentStatus.pending) {
      return 'في انتظار تأكيد الطبيب للموعد';
    }
    if (widget.appointment.status == AppointmentStatus.confirmed) {
      return 'سيتم تفعيل رابط الاجتماع قبل موعدك';
    }
    return 'رابط الاجتماع غير متاح بعد';
  }

  /// True when the non-interactive "Waiting for Call" label should be shown.
  bool get showWaitingForCall {
    return (widget.appointment.status == AppointmentStatus.pending ||
            widget.appointment.status == AppointmentStatus.confirmed) &&
        !_canJoinMeeting &&
        !_hasAgoraCredentials;
  }

  /// True when the "Reschedule" button should be shown.
  ///
  /// Hidden if:
  /// - status is not pending/confirmed/scheduled
  /// - appointment is in the past
  /// - appointment is less than 2 hours away
  bool get _canReschedule {
    if (widget.appointment.status != AppointmentStatus.pending &&
        widget.appointment.status != AppointmentStatus.confirmed &&
        widget.appointment.status != AppointmentStatus.scheduled) {
      return false;
    }
    return widget.appointment.fullDateTime.isAfter(
      DateTime.now().add(const Duration(hours: 2)),
    );
  }

  /// True when the "View Medical Record" icon should be shown.
  bool get showMedicalRecordIcon =>
      widget.appointment.status == AppointmentStatus.completed;

  // ─── Methods ────────────────────────────────────────────────────────────────

  /// Calls onJoinMeeting and handles FAILED_PRECONDITION / NOT_FOUND /
  /// DEADLINE_EXCEEDED with specific SnackBars. Logs outcome analytics.
  ///
  /// Guard includes _hasAgoraCredentials so the button works when the doctor
  /// has initiated a call (token written to appointment) but no meetingLink exists.
  Future<void> _joinMeeting() async {
    final onJoin = widget.onJoinMeeting;
    // Nothing to do if no callback, no meeting link, and no Agora credentials.
    if (onJoin == null && !_hasValidMeetingLink && !_hasAgoraCredentials) {
      return;
    }

    try {
      if (onJoin != null && _canJoinMeeting) {
        await onJoin();
      } else if (_hasValidMeetingLink) {
        final url = Uri.parse(widget.appointment.meetingLink!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('تعذر فتح رابط الاجتماع');
        }
      }

      // Success — session was active
      unawaited(
        getIt<CallMonitoringService>().logJoinMeetingTap(
          appointmentId: widget.appointment.id,
          userId: widget.appointment.patientId,
          outcome: 'navigated',
        ),
      );
    } on AgoraException catch (e) {
      if (!mounted) return;
      if (e.code == 'FAILED_PRECONDITION') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يبدأ الطبيب المكالمة بعد — يرجى الانتظار'),
          ),
        );
        unawaited(
          getIt<CallMonitoringService>().logJoinMeetingTap(
            appointmentId: widget.appointment.id,
            userId: widget.appointment.patientId,
            outcome: 'session_not_started',
          ),
        );
      } else if (e.code == 'NOT_FOUND' || e.code == 'DEADLINE_EXCEEDED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الاجتماع لم يعد متاحاً')),
        );
        unawaited(
          getIt<CallMonitoringService>().logJoinMeetingTap(
            appointmentId: widget.appointment.id,
            userId: widget.appointment.patientId,
            outcome: 'session_expired',
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> _openRescheduleSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RescheduleAppointmentSheet(
        appointment: widget.appointment,
        onRescheduled: (newDateTime) {
          widget.onRescheduled?.call(newDateTime);
        },
      ),
    );
  }

  // ─── UI Helpers ─────────────────────────────────────────────────────────────

  String _statusLabel() {
    final exactPatientLabel =
        AppointmentCardWidget.patientStatusLabels[widget.appointment.status];
    if (exactPatientLabel != null) return exactPatientLabel;

    switch (widget.appointment.status) {
      case AppointmentStatus.pending:
        return 'قيد الانتظار';
      case AppointmentStatus.confirmed:
        return 'مؤكد';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.scheduled:
      case AppointmentStatus.calling:
      case AppointmentStatus.inProgress:
      case AppointmentStatus.missed:
      case AppointmentStatus.declined:
      case AppointmentStatus.endedPendingConfirmation:
      case AppointmentStatus.completed:
      case AppointmentStatus.notCompleted:
        return AppointmentCardWidget.patientStatusLabels[widget
            .appointment
            .status]!;
    }
  }

  Color _statusColor() {
    switch (widget.appointment.status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.scheduled:
        return Colors.purple;
      case AppointmentStatus.calling:
        return AppColors.primary;
      case AppointmentStatus.inProgress:
        return Colors.teal;
      case AppointmentStatus.missed:
        return Colors.deepOrange;
      case AppointmentStatus.declined:
        return Colors.redAccent;
      case AppointmentStatus.endedPendingConfirmation:
        return Colors.amber.shade700;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.notCompleted:
        return Colors.brown;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    assert(
      AppointmentCardWidget.patientStatusLabels.length == 8,
      'Patient status label map must include the 8 FR-036 labels.',
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: doctor name + status badge ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.appointment.doctorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showMedicalRecordIcon) ...[
                  Tooltip(
                    message: 'عرض السجل الطبي',
                    child: InkWell(
                      onTap: widget.onMedicalRecordTap,
                      borderRadius: BorderRadius.circular(24),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.article_outlined,
                          semanticLabel: 'عرض السجل الطبي',
                        ),
                      ),
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(widget.appointment.specialization),
            const SizedBox(height: 4),
            Text(
              '${widget.appointment.timeSlot} • '
              '${widget.appointment.appointmentDate.day}/'
              '${widget.appointment.appointmentDate.month}/'
              '${widget.appointment.appointmentDate.year}',
            ),

            // ── Doctor confirmation chip (doctor view only) ─────────────────
            if (widget.isDoctorView &&
                widget.appointment.status ==
                    AppointmentStatus.endedPendingConfirmation) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: widget.onConfirmationRequiredTap == null
                    ? null
                    : () => widget.onConfirmationRequiredTap!.call(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Confirmation Required',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            // ── Call action area ─────────────────────────────────────────────
            if (showWaitingForCall) ...[
              const SizedBox(height: 12),
              Semantics(
                label: 'في انتظار المكالمة',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'في انتظار المكالمة',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_showJoinActionForUpcomingVideo) ...[
              const SizedBox(height: 16),
              // ── Live indicator badge ────────────────────────────────────
              if (_isJoinActionEnabled)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated pulse dot
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _canJoinMeeting
                                ? 'الاجتماع جاهز الآن'
                                : 'رابط الاجتماع متاح',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              // ── Join button ─────────────────────────────────────────────
              Semantics(
                button: true,
                label: 'انضم للاجتماع',
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.isJoining || !_isJoinActionEnabled
                        ? null
                        : _joinMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isJoinActionEnabled
                          ? AppColors.success
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      elevation: _isJoinActionEnabled ? 2 : 0,
                      shadowColor: AppColors.success.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: widget.isJoining
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'جاري الانضمام...',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_rounded, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                !_isJoinActionEnabled
                                    ? 'الانضمام غير متاح بعد'
                                    : (_canJoinMeeting
                                          ? 'انضم للاجتماع'
                                          : 'فتح رابط الاجتماع'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],

            if (_showMeetingUnavailable) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_off, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_meetingUnavailableMessage)),
                  ],
                ),
              ),
            ],

            // ── Reschedule button ────────────────────────────────────────────
            if (_canReschedule) ...[
              const SizedBox(height: 10),
              Semantics(
                button: true,
                label: 'تأجيل الموعد',
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _openRescheduleSheet,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تأجيل الموعد',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // ── View medical record button (completed appointments) ──────────
            if (showMedicalRecordIcon && widget.onMedicalRecordTap != null) ...[
              const SizedBox(height: 10),
              Semantics(
                button: true,
                label: 'عرض السجل الطبي',
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: widget.onMedicalRecordTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(
                        color: AppColors.success.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'عرض السجل الطبي',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
