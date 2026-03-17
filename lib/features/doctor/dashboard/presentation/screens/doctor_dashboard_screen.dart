import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/services/notification_service.dart';
import 'package:elajtech/features/appointments/presentation/screens/doctor_appointments_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/doctor/patients/presentation/screens/my_patients_screen.dart';
import 'package:elajtech/features/doctor/profile/presentation/screens/doctor_profile_screen.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:elajtech/shared/widgets/notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

/// Doctor Dashboard Screen - لوحة تحكم الطبيب
class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen>
    with WidgetsBindingObserver {
  DateTime _lastCheckTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      unawaited(ref.read(appointmentsProvider.notifier).loadForDoctor(user.id));

      // Listen for new notifications
      GetIt.I<NotificationRepository>().getNotificationsStream(user.id).listen((
        notifications,
      ) {
        if (!mounted) return;

        var shouldReload = false;

        for (final note in notifications) {
          if (note.createdAt.isAfter(_lastCheckTime)) {
            unawaited(
              NotificationService().showNotification(
                id: note.id.hashCode,
                title: note.title,
                body: note.body,
              ),
            );
            shouldReload = true;
          }
        }
        _lastCheckTime = DateTime.now();

        if (shouldReload) {
          unawaited(
            ref.read(appointmentsProvider.notifier).loadForDoctor(user.id),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final allAppointments = ref.watch(appointmentsProvider);

    // Filter appointments for this doctor
    final doctorAppointments = allAppointments
        .where((apt) => apt.doctorId == user?.id)
        .toList();

    // Get today's appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayAppointments = doctorAppointments.where((apt) {
      final aptDay = DateTime(
        apt.appointmentDate.year,
        apt.appointmentDate.month,
        apt.appointmentDate.day,
      );
      return aptDay.isAtSameMomentAs(today) &&
          apt.status != AppointmentStatus.cancelled &&
          apt.status != AppointmentStatus.completed;
    }).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    // Schedule Reminders for Doctor (30 mins before)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final apt in todayAppointments) {
        if (apt.status == AppointmentStatus.cancelled) continue;

        final reminderTime = apt.fullDateTime.subtract(
          const Duration(minutes: 30),
        );
        if (reminderTime.isAfter(DateTime.now())) {
          unawaited(
            NotificationService().scheduleNotification(
              id: apt.id.hashCode,
              title: 'تذكير بموعد',
              body: 'لديك موعد مع ${apt.patientName} بعد 30 دقيقة',
              scheduledDate: reminderTime,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DoctorProfileScreen(),
                ),
              );
            },
          ),
          if (user != null) NotificationIcon(userId: user.id),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحبا د. ${user?.fullName ?? ""}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todayAppointments.isEmpty
                        ? 'لا توجد مواعيد اليوم'
                        : 'لديك ${todayAppointments.length} ${todayAppointments.length == 1 ? "موعد" : "مواعيد"} اليوم',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today,
                    title: 'المواعيد القادمة',
                    value:
                        '${doctorAppointments.where((apt) => apt.status != AppointmentStatus.cancelled && apt.status != AppointmentStatus.completed && apt.appointmentDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length}',
                    color: AppColors.info,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const DoctorAppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final allPatientsAsync = ref.watch(allPatientsProvider);
                      return _StatCard(
                        icon: Icons.people,
                        title: 'المرضى',
                        value: allPatientsAsync.when(
                          data: (patients) => '${patients.length}',
                          loading: () => '...',
                          error: (err, stack) => '0',
                        ),
                        color: AppColors.primary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const MyPatientsScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Today's Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مواعيد اليوم',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (todayAppointments.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const DoctorAppointmentsScreen(),
                        ),
                      );
                    },
                    child: const Text('عرض الكل'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (todayAppointments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_available,
                        size: 64,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مواعيد اليوم',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayAppointments
                  .take(3)
                  .map(
                    (appointment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(appointment: appointment),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});
  final AppointmentModel appointment;

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
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                appointment.type == AppointmentType.video
                    ? 'Video Appointment'
                    : 'زيارة عيادة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Text(
          appointment.timeSlot,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
