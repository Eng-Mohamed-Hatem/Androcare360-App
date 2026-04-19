import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/appointment_completion_service.dart';
import 'package:elajtech/core/services/video_consultation_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/medical_records/presentation/screens/patient_medical_record_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';

/// Doctor Appointments Screen - شاشة مواعيد الطبيب
class DoctorAppointmentsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  ConsumerState<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends ConsumerState<DoctorAppointmentsScreen> {
  bool _isPromptVisible = false;
  String? _lastPromptedAppointmentId;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final allAppointments = ref.watch(appointmentsProvider);

    // Filter appointments for this doctor
    final myAppointments = allAppointments.where((apt) {
      return apt.doctorId == user?.id;
    }).toList();

    // 1. Upcoming Appointments (pending, confirmed, scheduled) - ASC
    final upcomingAppointments = myAppointments.where((apt) {
      return apt.status == AppointmentStatus.pending ||
          apt.status == AppointmentStatus.confirmed ||
          apt.status == AppointmentStatus.scheduled ||
          apt.status == AppointmentStatus.declined ||
          apt.status == AppointmentStatus.calling ||
          apt.status == AppointmentStatus.inProgress ||
          apt.status == AppointmentStatus.endedPendingConfirmation;
    }).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    // 2. Past Appointments (completed, cancelled, missed) - DESC
    final pastAppointments = myAppointments.where((apt) {
      return apt.status == AppointmentStatus.completed ||
          apt.status == AppointmentStatus.notCompleted ||
          apt.status == AppointmentStatus.cancelled ||
          apt.status == AppointmentStatus.missed;
    }).toList()..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    final pendingConfirmationAppointment = upcomingAppointments
        .cast<AppointmentModel?>()
        .firstWhere(
          (appointment) =>
              appointment?.status == AppointmentStatus.endedPendingConfirmation,
          orElse: () => null,
        );

    if (pendingConfirmationAppointment == null) {
      _lastPromptedAppointmentId = null;
    } else if (!_isPromptVisible &&
        _lastPromptedAppointmentId != pendingConfirmationAppointment.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        _isPromptVisible = true;
        _lastPromptedAppointmentId = pendingConfirmationAppointment.id;
        await _showAppointmentCompletionDialog(
          context,
          ref,
          pendingConfirmationAppointment,
        );
        _isPromptVisible = false;
      });
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مواعيدي'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'القادمة'),
              Tab(text: 'السابقة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AppointmentsList(
              appointments: upcomingAppointments,
              emptyMessage: 'لا توجد مواعيد قادمة',
            ),
            _AppointmentsList(
              appointments: pastAppointments,
              emptyMessage: 'لا توجد مواعيد سابقة',
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({
    required this.appointments,
    required this.emptyMessage,
  });
  final List<AppointmentModel> appointments;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isPast =
            appointment.status == AppointmentStatus.completed ||
            appointment.status == AppointmentStatus.notCompleted ||
            appointment.status == AppointmentStatus.cancelled ||
            appointment.status == AppointmentStatus.missed;

        return _AppointmentCard(appointment: appointment, isPast: isPast);
      },
    );
  }
}

Future<void> _showAppointmentCompletionDialog(
  BuildContext context,
  WidgetRef ref,
  AppointmentModel appointment,
) async {
  AppointmentStatus? statusFromResult(String? status) {
    switch (status) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'not_completed':
        return AppointmentStatus.notCompleted;
      case 'ended_pending_confirmation':
        return AppointmentStatus.endedPendingConfirmation;
      default:
        return null;
    }
  }

  final doctorId = ref.read(authProvider).user?.id;
  if (doctorId == null) {
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تأكيد نتيجة الجلسة'),
      content: const Text('هل اكتملت الجلسة الطبية مع المريض؟'),
      actions: [
        OutlinedButton(
          onPressed: () async {
            final result = await AppointmentCompletionService()
                .confirmCompletion(
                  appointmentId: appointment.id,
                  doctorId: doctorId,
                  completed: false,
                );

            if (!context.mounted) return;

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message ?? result.error ?? 'تم تحديث حالة الموعد',
                ),
                backgroundColor: result.success
                    ? AppColors.primary
                    : AppColors.error,
              ),
            );

            if (result.success) {
              final nextStatus =
                  statusFromResult(result.status) ??
                  AppointmentStatus.notCompleted;
              ref
                  .read(appointmentsProvider.notifier)
                  .updateAppointment(
                    appointment.copyWith(
                      status: nextStatus,
                    ),
                  );
            }
          },
          child: const Text('لا، غير مكتملة'),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await AppointmentCompletionService()
                .confirmCompletion(
                  appointmentId: appointment.id,
                  doctorId: doctorId,
                  completed: true,
                );

            if (!context.mounted) return;

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message ?? result.error ?? 'تم تحديث حالة الموعد',
                ),
                backgroundColor: result.success
                    ? AppColors.success
                    : AppColors.error,
              ),
            );

            if (result.success) {
              final nextStatus =
                  statusFromResult(result.status) ??
                  AppointmentStatus.completed;
              ref
                  .read(appointmentsProvider.notifier)
                  .updateAppointment(
                    appointment.copyWith(status: nextStatus),
                  );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('نعم، مكتملة'),
        ),
      ],
    ),
  );
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment, this.isPast = false});
  final AppointmentModel appointment;
  final bool isPast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');

    // Determine if this appointment is tappable (completed status only)
    final isCompletedAndTappable =
        isPast && appointment.status == AppointmentStatus.completed;
    final canStartVideoCall =
        appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed ||
        appointment.status == AppointmentStatus.scheduled ||
        appointment.status == AppointmentStatus.declined;
    final requiresCompletionConfirmation =
        appointment.status == AppointmentStatus.endedPendingConfirmation;

    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.patientPhone,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    appointment.status,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      _getStatusText(appointment.status),
                      style: TextStyle(
                        color: _getStatusColor(appointment.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Add icon for completed appointments to indicate tappability
                    if (isCompletedAndTappable) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.medical_information,
                        size: 14,
                        color: _getStatusColor(appointment.status),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(appointment.appointmentDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('hh:mm a', 'ar').format(appointment.fullDateTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (appointment.type == AppointmentType.video) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.videocam, size: 16, color: AppColors.info),
                SizedBox(width: 8),
                Text(
                  'استشارة فيديو',
                  style: TextStyle(color: AppColors.info, fontSize: 12),
                ),
              ],
            ),
          ],
          if (requiresCompletionConfirmation) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () async {
                  await _showCompleteDialog(context, ref);
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Confirmation Required',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            Text(
              'ملاحظات: ${appointment.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],

          // Add hint text for completed appointments
          if (isCompletedAndTappable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 14,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'اضغط لعرض سجل المريض',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Video Consultation Buttons
          if (!isPast && appointment.type == AppointmentType.video) ...[
            const SizedBox(height: 16),

            // Start Call Button (Doctor initiates VoIP call)
            // يظهر فقط إذا لم يكن هناك رابط حقيقي للاجتماع بعد
            if (canStartVideoCall &&
                (appointment.meetingLink == null ||
                    appointment.meetingLink!.isEmpty ||
                    appointment.meetingLink == 'pending' ||
                    !appointment.meetingLink!.startsWith('https://'))) ...[
              _StartCallButton(appointment: appointment),
            ] else if (appointment.meetingLink != null &&
                appointment.meetingLink!.isNotEmpty &&
                appointment.meetingLink != 'pending' &&
                appointment.meetingLink!.startsWith('https://')) ...[
              // Join Meeting Button (Link exists)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(appointment.meetingLink!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.videocam, size: 18),
                  label: const Text('الانضمام للاجتماع'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                  ),
                ),
              ),
            ],
          ],
          if (!isPast &&
              appointment.status != AppointmentStatus.completed &&
              appointment.status != AppointmentStatus.cancelled) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await _showCancelDialog(context, ref);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('إلغاء الموعد'),
                ),
                if (requiresCompletionConfirmation) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _showCompleteDialog(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('تأكيد الجلسة'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: isCompletedAndTappable
          ? InkWell(
              onTap: () async {
                // Navigate to Patient Medical Record Screen
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => PatientMedicalRecordScreen(
                      patientId: appointment.patientId,
                      patientName: appointment.patientName,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: cardContent,
            )
          : cardContent,
    );
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    final doctorId = ref.read(authProvider).user?.id;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          appointment.status == AppointmentStatus.calling
              ? 'إلغاء المكالمة'
              : 'إلغاء الموعد',
        ),
        content: Text(
          appointment.status == AppointmentStatus.calling
              ? 'هل أنت متأكد من إلغاء المكالمة الجارية وإعادة الموعد إلى الحالة المجدولة؟'
              : 'هل أنت متأكد من إلغاء هذا الموعد؟ سيتم إشعار المريض بذلك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () async {
              if (appointment.status == AppointmentStatus.calling &&
                  doctorId != null) {
                await VideoConsultationService().cancelCall(
                  appointmentId: appointment.id,
                  doctorId: doctorId,
                );

                if (!context.mounted) return;
                ref
                    .read(appointmentsProvider.notifier)
                    .updateAppointment(
                      appointment.copyWith(
                        status: AppointmentStatus.scheduled,
                        callSessionActive: false,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إلغاء المكالمة')),
                );
                return;
              }

              // Intentionally not awaited - state update happens in background
              unawaited(
                ref
                    .read(appointmentsProvider.notifier)
                    .cancelAppointment(appointment.id, isDoctor: true),
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompleteDialog(BuildContext context, WidgetRef ref) async {
    await _showAppointmentCompletionDialog(context, ref, appointment);
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.scheduled:
        return Colors.purple;
      case AppointmentStatus.calling:
        return AppColors.primary;
      case AppointmentStatus.inProgress:
        return Colors.teal;
      case AppointmentStatus.declined:
        return Colors.deepOrange;
      case AppointmentStatus.endedPendingConfirmation:
        return Colors.amber.shade700;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.notCompleted:
        return Colors.brown;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.missed:
        return AppColors.error;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'قيد الانتظار';
      case AppointmentStatus.confirmed:
        return 'مؤكد';
      case AppointmentStatus.scheduled:
        return 'مجدول';
      case AppointmentStatus.calling:
        return 'جارٍ الاتصال';
      case AppointmentStatus.inProgress:
        return 'في الجلسة';
      case AppointmentStatus.declined:
        return 'تم الرفض';
      case AppointmentStatus.endedPendingConfirmation:
        return 'بانتظار التأكيد';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.notCompleted:
        return 'غير مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.missed:
        return 'فائت';
    }
  }
}

/// زر بدء المكالمة - Start Call Button
///
/// يستدعي Cloud Function لتوليد Agora token وإرسال VoIP للمريض
class _StartCallButton extends ConsumerStatefulWidget {
  const _StartCallButton({required this.appointment});
  final AppointmentModel appointment;

  @override
  ConsumerState<_StartCallButton> createState() => _StartCallButtonState();
}

class _StartCallButtonState extends ConsumerState<_StartCallButton> {
  bool _isLoading = false;

  Future<void> _startCall() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final doctorId = authState.user?.id;

      if (doctorId == null) {
        _showError('يرجى تسجيل الدخول مرة أخرى');
        return;
      }

      // ✅ DIAGNOSTIC: AppointmentId Tracing (Investigation 2)
      // Verify that appointment.id matches Firestore document ID
      debugPrint('🔍 [ID TRACE] Starting AppointmentId verification...');
      debugPrint(
        '🔍 [ID TRACE] Flutter appointment.id: ${widget.appointment.id}',
      );

      try {
        // Query Firestore to get actual document ID
        final firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'elajtech',
        );

        final firestoreDoc = await firestore
            .collection('appointments')
            .doc(widget.appointment.id)
            .get();

        debugPrint('🔍 [ID TRACE] Firestore doc.id: ${firestoreDoc.id}');
        debugPrint(
          '🔍 [ID TRACE] Firestore doc.exists: ${firestoreDoc.exists}',
        );
        debugPrint(
          '🔍 [ID TRACE] IDs match: ${widget.appointment.id == firestoreDoc.id}',
        );

        if (widget.appointment.id != firestoreDoc.id) {
          debugPrint('❌ [ID MISMATCH] AppointmentId mismatch detected!');
          debugPrint('❌ [ID MISMATCH] Flutter ID: ${widget.appointment.id}');
          debugPrint('❌ [ID MISMATCH] Firestore ID: ${firestoreDoc.id}');
        } else {
          debugPrint('✅ [ID TRACE] AppointmentId consistency verified');
        }

        if (!firestoreDoc.exists) {
          debugPrint('❌ [ID TRACE] Document does not exist in Firestore!');
          debugPrint(
            '❌ [ID TRACE] Attempted document path: appointments/${widget.appointment.id}',
          );

          // Query all appointments for this doctor to find potential matches
          final doctorAppointments = await firestore
              .collection('appointments')
              .where('doctorId', isEqualTo: doctorId)
              .limit(10)
              .get();

          debugPrint(
            '🔍 [ID TRACE] Found ${doctorAppointments.size} appointments for doctor',
          );
          for (final doc in doctorAppointments.docs) {
            debugPrint('🔍 [ID TRACE] Existing appointment ID: ${doc.id}');
            debugPrint(
              '🔍 [ID TRACE] Similarity check: ${doc.id.contains(widget.appointment.id) || widget.appointment.id.contains(doc.id)}',
            );
          }
        }
      } on Exception catch (e, stackTrace) {
        debugPrint('❌ [ID TRACE] Error during AppointmentId verification: $e');
        debugPrint('❌ [ID TRACE] StackTrace: $stackTrace');
        // Continue with call attempt even if verification fails
      }

      // استدعاء Cloud Function لبدء المكالمة
      debugPrint('🔍 Calling startVideoCall with:');
      debugPrint('   appointmentId: ${widget.appointment.id}');
      debugPrint('   doctorId: $doctorId');

      final result = await VideoConsultationService().startVideoCall(
        appointmentId: widget.appointment.id,
        doctorId: doctorId,
      );

      if (!mounted) return;

      // Validate Cloud Function response
      if (!result.success) {
        _showError(result.error ?? 'فشل بدء المكالمة');
        return;
      }

      // ✅ تحقق شامل من البيانات قبل Navigation
      if (result.agoraToken == null ||
          result.agoraChannelName == null ||
          result.agoraUid == null) {
        debugPrint('❌ Cloud Function returned incomplete data:');
        debugPrint('   - agoraToken: ${result.agoraToken != null ? "✅" : "❌"}');
        debugPrint(
          '   - agoraChannelName: ${result.agoraChannelName != null ? "✅" : "❌"}',
        );
        debugPrint('   - agoraUid: ${result.agoraUid != null ? "✅" : "❌"}');

        _showError(
          'فشل في الحصول على بيانات المكالمة من الخادم. يرجى المحاولة مرة أخرى.',
        );
        return;
      }

      // البيانات كاملة - الانتقال لشاشة الفيديو
      final navigationResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute<Map<String, dynamic>>(
          builder: (context) => AgoraVideoCallScreen(
            appointment: widget.appointment.copyWith(
              agoraToken: result.agoraToken,
              agoraChannelName: result.agoraChannelName,
              agoraUid: result.agoraUid,
            ),
          ),
        ),
      );

      if (!mounted) return;

      if (navigationResult?['showCompletionDialog'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(
            _showAppointmentCompletionDialog(
              context,
              ref,
              widget.appointment.copyWith(
                status: AppointmentStatus.endedPendingConfirmation,
              ),
            ),
          );
        });
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'تم بدء المكالمة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on Exception catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _isLoading ? null : _startCall,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.call, size: 18),
      label: Text(_isLoading ? 'جاري الاتصال...' : 'بدء الاتصال'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  );
}
