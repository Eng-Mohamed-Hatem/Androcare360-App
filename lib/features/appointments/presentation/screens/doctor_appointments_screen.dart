import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_colors.dart';
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
class DoctorAppointmentsScreen extends ConsumerWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          apt.status == AppointmentStatus.scheduled;
    }).toList();

    upcomingAppointments.sort(
      (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
    );

    // 2. Past Appointments (completed, cancelled, missed) - DESC
    final pastAppointments = myAppointments.where((apt) {
      return apt.status == AppointmentStatus.completed ||
          apt.status == AppointmentStatus.cancelled ||
          apt.status == AppointmentStatus.missed;
    }).toList();

    pastAppointments.sort(
      (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
    );

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
            appointment.status == AppointmentStatus.cancelled ||
            appointment.status == AppointmentStatus.missed;

        return _AppointmentCard(appointment: appointment, isPast: isPast);
      },
    );
  }
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
            if (appointment.meetingLink == null ||
                appointment.meetingLink!.isEmpty ||
                appointment.meetingLink == 'pending' ||
                !appointment.meetingLink!.startsWith('https://')) ...[
              _StartCallButton(appointment: appointment),
            ] else ...[
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await _showCompleteDialog(context, ref);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إكمال الموعد'),
                ),
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text(
          'هل أنت متأكد من إلغاء هذا الموعد؟ سيتم إشعار المريض بذلك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () {
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إكمال الموعد'),
        content: const Text(
          'هل تمت الزيارة بنجاح؟ سيتم تغيير حالة الموعد إلى مكتمل.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              // Intentionally not awaited - state update happens in background
              unawaited(
                ref
                    .read(appointmentsProvider.notifier)
                    .completeAppointment(appointment.id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('نعم، مكتمل'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.scheduled:
        return Colors.purple;
      case AppointmentStatus.completed:
        return AppColors.success;
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
      case AppointmentStatus.completed:
        return 'مكتمل';
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
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AgoraVideoCallScreen(
            appointment: widget.appointment.copyWith(
              agoraToken: result.agoraToken,
              agoraChannelName: result.agoraChannelName,
              agoraUid: result.agoraUid,
            ),
          ),
        ),
      );

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
