import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/providers/theme_provider.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/common/privacy_policy_screen.dart';
// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/navigation/presentation/helpers/patient_navigation_helper.dart';
import 'package:elajtech/features/patient/profile/presentation/screens/edit_profile_screen.dart';
import 'package:elajtech/features/auth/presentation/screens/link_phone_screen.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:elajtech/shared/providers/appointments_provider.dart';
import 'package:elajtech/shared/widgets/biometric_switch.dart';
import 'package:elajtech/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Patient Profile Screen - Ø´Ø§Ø´Ø© Ø§Ù„Ù…Ù„Ù Ø§Ù„Ø´Ø®ØµÙŠ Ù„Ù„Ù…Ø±ÙŠØ¶
class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user from auth provider
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final patientName = user?.fullName ?? 'مريض';
    final patientEmail = user?.email ?? 'لا يوجد بريد إلكتروني';
    final patientPhone = user?.phoneNumber ?? 'لا يوجد رقم هاتف';

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patient Name
                  Text(
                    patientName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Edit Profile Button
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    label: const Text(
                      AppStrings.editProfile,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.personalInfo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.email_outlined,
                    title: AppStrings.email,
                    value: patientEmail,
                  ),
                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: Icons.phone_outlined,
                    title: AppStrings.phoneNumber,
                    value: patientPhone,
                  ),

                  // ── ربط رقم الهاتف (يظهر فقط إذا لم يكن هناك رقم مرتبط) ──
                  if (user?.phoneNumber == null || user!.phoneNumber!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _SettingsTile(
                        icon: Icons.link,
                        title: 'ربط رقم الهاتف',
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const LinkPhoneScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    AppStrings.settings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _SettingsTile(
                    icon: Icons.medical_services_outlined,
                    title: AppStrings.medicalRecords,
                    onTap: () async {
                      await PatientNavigationHelper.openMedicalRecords(context);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.calendar_today_outlined,
                    title: AppStrings.appointments,
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const AppointmentsManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.card_membership_outlined,
                    title: 'باقاتي',
                    onTap: () async {
                      await PatientNavigationHelper.openMyPackages(context);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: AppStrings.darkMode,
                    trailing: Switch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (value) {
                        // Intentionally not awaited - theme toggle happens in background
                        unawaited(
                          ref.read(themeModeProvider.notifier).toggleTheme(),
                        );
                      },
                    ),
                  ),
                  const _SettingsTile(
                    icon: Icons.fingerprint,
                    title: 'تفعيل الدخول بالبصمة',
                    trailing: BiometricSwitch(),
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.logout,
                    title: AppStrings.logout,
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text(
                            'هل تريد تسجيل الخروج من التطبيق؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Logout from auth provider
                                await ref.read(authProvider.notifier).logout();

                                if (context.mounted) {
                                  // Close dialog
                                  Navigator.pop(context);

                                  // Navigate to login screen
                                  await Navigator.of(
                                    context,
                                  ).pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text(
                                'تسجيل الخروج',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  _SettingsTile(
                    icon: Icons.delete_forever,
                    title: 'حذف الحساب',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('حذف الحساب نهائياً'),
                          content: const Text(
                            'هل أنت متأكد من رغبتك في حذف الحساب؟ سيتم فقدان جميع بياناتك وسجلاتك الطبية بشكل نهائي ولا يمكن استرجاعها.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close dialog

                                // Show loading
                                unawaited(
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                );

                                await ref
                                    .read(authProvider.notifier)
                                    .deleteAccount();

                                if (context.mounted) {
                                  Navigator.pop(context); // Close loading

                                  final error = ref.read(authProvider).error;
                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  } else {
                                    // Success - Navigate to Login (State listener in main usually handles this, but we force it here)
                                    await Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'حذف نهائي',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? AppColors.textPrimaryLight),
    title: Text(
      title,
      style: TextStyle(
        color: titleColor ?? AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
      ),
    ),
    trailing:
        trailing ??
        const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

/// Appointments Management Screen - O'OO'Oc OO_OOñOc OU,U.U^OO1USO_
/// Appointments Management Screen - إدارة المواعيد
class AppointmentsManagementScreen extends ConsumerStatefulWidget {
  const AppointmentsManagementScreen({super.key});

  @override
  ConsumerState<AppointmentsManagementScreen> createState() =>
      _AppointmentsManagementScreenState();
}

class _AppointmentsManagementScreenState
    extends ConsumerState<AppointmentsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authProvider).user;
      if (user != null) {
        try {
          await ref.read(appointmentsProvider.notifier).loadForPatient(user.id);
        } on Exception catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل أنت متأكد من إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      try {
        await ref
            .read(appointmentsProvider.notifier)
            .cancelAppointment(appointment.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الموعد بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _rescheduleAppointment(AppointmentModel appointment) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RescheduleDialog(appointment: appointment),
    );

    if (result != null && mounted) {
      final newDate = result['date'] as DateTime;
      final newTimeSlot = result['timeSlot'] as String;

      final updatedAppointment = appointment.copyWith(
        appointmentDate: newDate,
        timeSlot: newTimeSlot,
        status:
            AppointmentStatus.scheduled, // إعادة الحالة إلى مجدول عند التأجيل
      );

      final user = ref.read(authProvider).user;
      if (user == null) return;

      try {
        // Show loading dialog
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        ).ignore();

        // Check for conflicts
        final hasConflict = await ref
            .read(appointmentsProvider.notifier)
            .checkAppointmentConflict(user.id, updatedAppointment);

        if (hasConflict) {
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'عذراً، لا يمكن إتمام الحجز لوجود تعارض مع موعد آخر في نفس التوقيت. يرجى اختيار وقت مختلف.',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        await ref
            .read(appointmentsProvider.notifier)
            .rescheduleAppointment(updatedAppointment);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
        }

        // Send notification logic remains same...
        try {
          final notification = NotificationModel(
            userId: appointment.doctorId,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'تم تأجيل موعد',
            body:
                'لقد قام المريض بتأجيل الموعد إلى ${DateFormat('dd/MM/yyyy', 'ar').format(newDate)} الساعة $newTimeSlot',
            type: NotificationType.appointment,
            createdAt: DateTime.now(),
            data: {
              'appointmentId': appointment.id,
              'newDate': newDate.toIso8601String(),
              'newTimeSlot': newTimeSlot,
            },
          );
          await GetIt.I<NotificationRepository>().saveNotification(
            notification,
          );
        } on Exception catch (e) {
          debugPrint('Error saving notification: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تأجيل الموعد بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;
    final allAppointments = ref.watch(appointmentsProvider);

    // Upcoming: pending, confirmed, scheduled - Sorted ASC (nearest first)
    final upcomingAppointments = allAppointments.where((apt) {
      return (apt.status == AppointmentStatus.pending ||
              apt.status == AppointmentStatus.confirmed ||
              apt.status == AppointmentStatus.scheduled) &&
          apt.patientId == currentUserId;
    }).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    // Past: completed, cancelled, missed - Sorted DESC (newest first)
    final pastAppointments = allAppointments.where((apt) {
      return (apt.status == AppointmentStatus.completed ||
              apt.status == AppointmentStatus.cancelled ||
              apt.status == AppointmentStatus.missed) &&
          apt.patientId == currentUserId;
    }).toList()..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('المواعيد')),
        body: const Center(child: Text('يجب تسجيل الدخول')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('المواعيد'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'مواعيد قادمة'),
                Tab(text: 'مواعيد سابقة'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Upcoming Tab
              if (upcomingAppointments.isEmpty)
                _buildEmptyState(
                  'لا توجد مواعيد قادمة',
                  Icons.event_available,
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100, // Extra padding for bottom navigation
                  ),
                  itemCount: upcomingAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = upcomingAppointments[index];
                    return _AppointmentCard(
                      appointment: appointment,
                      onCancel: () => _cancelAppointment(appointment),
                      onReschedule: () => _rescheduleAppointment(appointment),
                    );
                  },
                ),

              // Past Tab
              if (pastAppointments.isEmpty)
                _buildEmptyState('لا يوجد سجل مواعيد سابق', Icons.history)
              else
                ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100, // Extra padding for bottom navigation
                  ),
                  itemCount: pastAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = pastAppointments[index];
                    return _AppointmentCard(
                      appointment: appointment,
                      onCancel: () {}, // No actions for past
                      onReschedule: () {}, // No actions for past
                      isPast: true,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondaryLight),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Appointment Card Widget
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
    this.isPast = false,
  });
  final AppointmentModel appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      appointment.appointmentDate.year,
      appointment.appointmentDate.month,
      appointment.appointmentDate.day,
    );
    final daysUntil = appointmentDay.difference(today).inDays;

    // Determine if this appointment is tappable (completed status only)
    final isCompletedAndTappable =
        isPast && appointment.status == AppointmentStatus.completed;

    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator for Past Appointments
          if (isPast) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appointment.status == AppointmentStatus.completed
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    appointment.status == AppointmentStatus.completed
                        ? Icons.check_circle_outline
                        : (appointment.status == AppointmentStatus.missed
                              ? Icons.event_busy
                              : Icons.cancel_outlined),
                    size: 20,
                    color: appointment.status == AppointmentStatus.completed
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.status == AppointmentStatus.completed
                        ? 'مكتمل'
                        : (appointment.status == AppointmentStatus.missed
                              ? 'فائت'
                              : 'ملغي'),
                    style: TextStyle(
                      color: appointment.status == AppointmentStatus.completed
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Add icon for completed appointments to indicate tappability
                  if (isCompletedAndTappable)
                    const Row(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'عرض السجل',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Doctor Info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appointment.specialization,
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
                  color: appointment.type == AppointmentType.video
                      ? AppColors.info.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      appointment.type == AppointmentType.video
                          ? Icons.videocam
                          : Icons.local_hospital,
                      size: 14,
                      color: appointment.type == AppointmentType.video
                          ? AppColors.info
                          : AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.type == AppointmentType.video
                          ? 'فيديو'
                          : 'عيادة',
                      style: TextStyle(
                        color: appointment.type == AppointmentType.video
                            ? AppColors.info
                            : AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Appointment Details
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(appointment.appointmentDate),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('hh:mm a', 'ar').format(appointment.fullDateTime),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Days Until Appointment (Only for upcoming)
          if (!isPast)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: daysUntil <= 1
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: daysUntil <= 1 ? AppColors.warning : AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    daysUntil == 0
                        ? 'الموعد اليوم'
                        : daysUntil <= 0
                        ? 'الموعد الآن' // In case it's 0 days
                        : daysUntil == 1
                        ? 'الموعد غداً'
                        : 'بعد $daysUntil أيام',
                    style: TextStyle(
                      color: daysUntil <= 1
                          ? AppColors.warning
                          : AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          if (appointment.notes != null) ...[
            const SizedBox(height: 12),
            Text(
              'ملاحظات: ${appointment.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],

          // Video Call Button (Only for upcoming video calls)
          if (!isPast && appointment.type == AppointmentType.video) ...[
            const SizedBox(height: 16),
            _VideoCallButton(appointment: appointment),
          ],

          const SizedBox(height: 16),

          // Action Buttons (Only for upcoming)
          if (!isPast)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('تأجيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: isCompletedAndTappable
          ? InkWell(
              onTap: () async {
                await PatientNavigationHelper.openMedicalRecords(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: cardContent,
            )
          : cardContent,
    );
  }
}

/// Reschedule Dialog
class _RescheduleDialog extends StatefulWidget {
  const _RescheduleDialog({required this.appointment});
  final AppointmentModel appointment;

  @override
  State<_RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<_RescheduleDialog> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    final baseTimeSlots = MockTimeSlots.getTimeSlots();

    // Filter out past time slots
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final timeSlots = baseTimeSlots.map((slot) {
      if (!slot.isAvailable) return slot;
      if (isToday) {
        try {
          final timeParts = slot.time.split(' ');
          final clockParts = timeParts[0].split(':');
          var hour = int.parse(clockParts[0]);
          final minute = int.parse(clockParts[1]);
          final period = timeParts[1].trim();

          if ((period == 'م' || period == 'PM' || period == 'pm') &&
              hour != 12) {
            hour += 12;
          }
          if ((period == 'ص' || period == 'AM' || period == 'am') &&
              hour == 12) {
            hour = 0;
          }

          final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
          if (slotTime.isBefore(now)) {
            return TimeSlot(time: slot.time, isAvailable: false);
          }
        } on Exception catch (_) {}
      }
      return slot;
    }).toList();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأجيل الموعد',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Calendar
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TableCalendar<dynamic>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTimeSlot = null;
                      });
                    },
                    startingDayOfWeek: StartingDayOfWeek.saturday,
                    locale: 'ar',
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Time Slots
                Text(
                  'اختر الوقت',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot.time;
                    return InkWell(
                      onTap: slot.isAvailable
                          ? () {
                              setState(() {
                                _selectedTimeSlot = slot.time;
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: !slot.isAvailable
                              ? AppColors.surfaceLight
                              : isSelected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !slot.isAvailable
                                ? AppColors.borderLight
                                : isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          slot.time,
                          style: TextStyle(
                            color: !slot.isAvailable
                                ? AppColors.textSecondaryLight
                                : isSelected
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'تأكيد',
                        onPressed: _selectedTimeSlot == null
                            ? () {}
                            : () {
                                Navigator.pop(context, {
                                  'date': _selectedDate,
                                  'timeSlot': _selectedTimeSlot,
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Video Call Button Widget with Real-time Firestore Updates
///
/// يستخدم StreamBuilder لمراقبة التغييرات في meetingLink
/// يظهر زر معطل مع "بانتظار بدء الطبيب للمكالمة" عندما يكون pending
/// يتحول لزر نشط تلقائياً عند توفر بيانات Agora
class _VideoCallButton extends StatelessWidget {
  const _VideoCallButton({required this.appointment});
  final AppointmentModel appointment;

  /// التحقق مما إذا كان الرابط صالحاً للانضمام
  bool _isValidMeetingLink(String? link) {
    if (link == null || link.isEmpty) return false;
    if (link == 'pending') return false;
    // التحقق من أن الرابط يبدأ بـ http أو https
    return link.startsWith('http://') || link.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot>(
    // مراقبة مستند الموعد في Firestore للتحديث اللحظي
    stream: FirebaseFirestore.instanceFor(
      app: FirebaseFirestore.instance.app,
      databaseId: 'elajtech',
    ).collection('appointments').doc(appointment.id).snapshots(),
    builder: (context, snapshot) {
      // استخدام قيمة meetingLink من Stream أو من الـ appointment الأصلي
      var meetingLink = appointment.meetingLink;

      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        meetingLink = data?['meetingLink'] as String?;
      }

      final isReady = _isValidMeetingLink(meetingLink);

      return SizedBox(
        width: double.infinity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isReady
              // زر نشط - الرابط جاهز
              ? OutlinedButton.icon(
                  key: const ValueKey('active'),
                  onPressed: () async {
                    final url = Uri.parse(meetingLink!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر فتح الرابط، تأكد من بيانات المكالمة',
                            ),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.videocam, size: 18),
                  label: const Text('الانضمام للاجتماع'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
              // زر معطل - بانتظار الطبيب
              : OutlinedButton.icon(
                  key: const ValueKey('pending'),
                  onPressed: null, // زر معطل
                  icon: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  label: const Text('بانتظار بدء الطبيب للمكالمة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondaryLight,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
        ),
      );
    },
  );
}
