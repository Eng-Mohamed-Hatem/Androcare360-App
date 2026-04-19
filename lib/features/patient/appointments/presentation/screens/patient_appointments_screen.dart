import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/exceptions.dart';
import 'package:elajtech/core/services/video_consultation_service.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/features/medical_records/presentation/screens/appointment_medical_record_screen.dart';
import 'package:elajtech/features/patient/appointments/presentation/widgets/appointment_card_widget.dart';
import 'package:elajtech/features/patient/consultation/presentation/screens/agora_video_call_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Patient Appointments Screen - شاشة مواعيد المريض
class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  ConsumerState<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends ConsumerState<PatientAppointmentsScreen> {
  String? _joiningAppointmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  Future<void> _loadAppointments() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    // Re-subscribe the real-time stream (pull-to-refresh)
    ref.invalidate(patientAppointmentsStreamProvider(user.id));
  }

  /// Joins the meeting. Re-throws [AgoraException] with codes
  /// FAILED_PRECONDITION, NOT_FOUND, and DEADLINE_EXCEEDED so that
  /// AppointmentCardWidget can display the appropriate SnackBar per contract U1.
  Future<void> _joinMeeting(AppointmentModel appointment) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _joiningAppointmentId = appointment.id);

    try {
      final callData = await VideoConsultationService().patientJoinCall(
        appointmentId: appointment.id,
        patientId: user.id,
      );

      ref
          .read(appointmentsProvider.notifier)
          .updateAppointment(
            appointment.copyWith(
              status: AppointmentStatus.inProgress,
              callSessionActive: true,
              agoraToken: callData.agoraToken,
              agoraChannelName: callData.channelName,
              agoraUid: callData.uid,
            ),
          );

      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => AgoraVideoCallScreen(
            appointment: appointment.copyWith(
              status: AppointmentStatus.inProgress,
              callSessionActive: true,
              agoraToken: callData.agoraToken,
              agoraChannelName: callData.channelName,
              agoraUid: callData.uid,
            ),
            firebaseAuth: getIt<FirebaseAuth>(),
          ),
        ),
      );

      if (!mounted) return;
      unawaited(_loadAppointments());
    } on AgoraException catch (e) {
      // Re-throw specific codes so AppointmentCardWidget can show the
      // correct per-code SnackBar and log analytics outcome.
      if (e.code == 'FAILED_PRECONDITION' ||
          e.code == 'NOT_FOUND' ||
          e.code == 'DEADLINE_EXCEEDED') {
        rethrow;
      }
      if (!mounted) return;
      final error = e.toString().replaceAll(
        RegExp(r'^AgoraException( \[[^\]]+\])?: '),
        '',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      final error = e.toString().replaceAll(
        RegExp(r'^AgoraException( \[[^\]]+\])?: '),
        '',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _joiningAppointmentId = null);
    }
  }

  void _handleRescheduled(DateTime newDateTime) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تأجيل موعدك بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Checks if an EMR exists for [appointment], then navigates to
  /// [AppointmentMedicalRecordScreen] if found. Shows a SnackBar otherwise.
  Future<void> _openMedicalRecord(AppointmentModel appointment) async {
    if (!mounted) return;
    final user = ref.read(authProvider).user;
    final result = await getIt<EMRRepository>().getEMRByAppointmentId(
      appointment.id,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (emr) {
        if (emr == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يوجد ملف طبي لهذا الموعد بعد'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }
        unawaited(
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => AppointmentMedicalRecordScreen(
                appointment: appointment,
                patientName: user?.fullName ?? appointment.patientName,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('مواعيدي')),
        body: const Center(child: Text('يجب تسجيل الدخول أولاً')),
      );
    }

    // Real-time stream: emits an updated list whenever Firestore changes
    // (e.g. when doctor starts a call and sets status:'calling')
    final appointmentsAsync = ref.watch(
      patientAppointmentsStreamProvider(user.id),
    );

    return appointmentsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('مواعيدي')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('مواعيدي')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذر تحميل المواعيد. تحقق من الاتصال وأعد المحاولة.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointments,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
      data: (appointments) {
        final activeAppointments =
            appointments.where((appointment) {
              return appointment.status == AppointmentStatus.calling ||
                  appointment.status == AppointmentStatus.inProgress ||
                  (appointment.status == AppointmentStatus.missed &&
                      appointment.callSessionActive) ||
                  (appointment.callStartedAt != null &&
                      appointment.status != AppointmentStatus.completed) ||
                  appointment.status == AppointmentStatus.scheduled ||
                  appointment.status == AppointmentStatus.confirmed ||
                  appointment.status == AppointmentStatus.pending;
            }).toList()..sort(
              (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
            );

        final historyAppointments =
            appointments.where((appointment) {
              return appointment.status ==
                      AppointmentStatus.endedPendingConfirmation ||
                  appointment.status == AppointmentStatus.completed ||
                  appointment.status == AppointmentStatus.notCompleted ||
                  appointment.status == AppointmentStatus.cancelled ||
                  (appointment.status == AppointmentStatus.missed &&
                      !appointment.callSessionActive) ||
                  appointment.status == AppointmentStatus.declined;
            }).toList()..sort(
              (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
            );

        return Scaffold(
          appBar: AppBar(title: const Text('مواعيدي')),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'النشطة والقادمة'),
                    Tab(text: 'السجل'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AppointmentsListView(
                        appointments: activeAppointments,
                        joiningAppointmentId: _joiningAppointmentId,
                        onJoinMeeting: _joinMeeting,
                        onRefresh: _loadAppointments,
                        onRescheduled: _handleRescheduled,
                        emptyLabel: 'لا توجد مواعيد نشطة أو قادمة',
                      ),
                      _AppointmentsListView(
                        appointments: historyAppointments,
                        joiningAppointmentId: _joiningAppointmentId,
                        onJoinMeeting: _joinMeeting,
                        onMedicalRecord: _openMedicalRecord,
                        onRefresh: _loadAppointments,
                        onRescheduled: _handleRescheduled,
                        emptyLabel: 'لا يوجد سجل مواعيد بعد',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppointmentsListView extends StatelessWidget {
  const _AppointmentsListView({
    required this.appointments,
    required this.joiningAppointmentId,
    required this.onJoinMeeting,
    required this.onRefresh,
    required this.emptyLabel,
    this.onRescheduled,
    this.onMedicalRecord,
  });

  final List<AppointmentModel> appointments;
  final String? joiningAppointmentId;
  final Future<void> Function(AppointmentModel appointment) onJoinMeeting;
  final Future<void> Function(AppointmentModel appointment)? onMedicalRecord;
  final Future<void> Function() onRefresh;
  final String emptyLabel;
  final void Function(DateTime newDateTime)? onRescheduled;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final isCompleted = appointment.status == AppointmentStatus.completed;

          Widget card = AppointmentCardWidget(
            appointment: appointment,
            isJoining: joiningAppointmentId == appointment.id,
            onJoinMeeting: () => onJoinMeeting(appointment),
            onMedicalRecordTap: isCompleted && onMedicalRecord != null
                ? () => onMedicalRecord!(appointment)
                : null,
            onRescheduled: (newDateTime) {
              unawaited(onRefresh());
              onRescheduled?.call(newDateTime);
            },
          );

          // Completed cards in the History tab are also tappable for EMR nav.
          if (isCompleted && onMedicalRecord != null) {
            card = InkWell(
              onTap: () => onMedicalRecord!(appointment),
              borderRadius: BorderRadius.circular(16),
              child: card,
            );
          }

          return card;
        },
      ),
    );
  }
}
