import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_strings.dart';
import 'package:elajtech/core/constants/medical_specializations.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/select_doctor_for_appointment_screen.dart';
import 'package:elajtech/features/packages/presentation/pages/package_categories_page.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/lab_tests_info_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/medical_departments_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/sub_specialties_screen.dart';
import 'package:elajtech/features/patient/home/presentation/widgets/doctor_card.dart';
import 'package:elajtech/features/patient/notifications/presentation/screens/notifications_screen.dart';
import 'package:elajtech/features/patient/self_assessment/presentation/screens/self_assessment_list_screen.dart';
import 'package:elajtech/features/patient_profile_screen.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/home/presentation/screens/devices_screen.dart';
import 'package:elajtech/features/patient/home/presentation/screens/medical_screening_screen.dart';
import 'package:elajtech/features/patient/medical_records/presentation/screens/medical_records_screen.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Patient Home Screen - الصفحة الرئيسية للمريض
class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      // شريط التطبيق العلوي
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // أيقونة الملف الشخصي
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const PatientProfileScreen(),
                ),
              );
            },
            tooltip: 'الملف الشخصي',
          ),
          // أيقونة الإشعارات مع Badge لعرض عدد الإشعارات غير المقروءة
          StreamBuilder<int>(
            stream: user?.id != null
                ? GetIt.I<NotificationRepository>()
                      .getNotificationsStream(user!.id)
                      .map(
                        (notifications) =>
                            notifications.where((n) => !n.isRead).length,
                      )
                : Stream.value(0),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  tooltip: 'الإشعارات',
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 150),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً ${user?.fullName ?? ''}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'كيف يمكننا مساعدتك اليوم؟',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: AppStrings.search,
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    DoctorsListScreen(searchQuery: value),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.card_membership,
                        title: 'الباقات',
                        color: AppColors.primary,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const PackageCategoriesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.calendar_today,
                        title: 'حجز موعد',
                        color: AppColors.secondary,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const SelectDoctorForAppointmentScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Second Row of Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.devices_other,
                        title: AppStrings.myDevices,
                        color: Colors.indigo,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const MedicalRecordsScreen(initialIndex: 4),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.settings_input_component,
                        title: AppStrings.devices,
                        color: Colors.orange,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const DevicesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Third Row of Quick Actions (Lab Tests)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.biotech,
                        title: AppStrings.myLabTests,
                        color: Colors.teal,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const MedicalRecordsScreen(initialIndex: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_circle_outline,
                        title: AppStrings.labTestRequestBtn,
                        color: Colors.blueAccent,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const LabTestsInfoScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Fourth Row of Quick Actions (Medical Screening - Right slot RTL)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.health_and_safety,
                        title: AppStrings.medicalScreening,
                        color: Colors.purple,
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const MedicalScreeningScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: SizedBox.shrink(), // Empty placeholder slot
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Medical Departments Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.medicalDepartments,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const MedicalDepartmentsScreen(),
                          ),
                        );
                      },
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Medical Main Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: MedicalSpecializations.mainCategories
                      .map(
                        (category) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                MedicalSpecializations.getIcon(category),
                                color: AppColors.primary,
                                size: 32,
                              ),
                            ),
                            title: Text(
                              category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${MedicalSpecializations.getSubSpecialties(category).length} تخصصات',
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            onTap: () async {
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => SubSpecialtiesScreen(
                                    mainCategory: category,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Doctors Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.doctors,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const DoctorsListScreen(),
                          ),
                        );
                      },
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Doctors List
              _buildDoctorsSection(context, ref),

              const SizedBox(height: 32),

              // Self Assessment Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'قيم نفسك',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const SelfAssessmentListScreen(),
                              ),
                            );
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SelfAssessmentListScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fact_check_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'اختبر صحتك الجنسية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'قيم حالتك واحصل على نصائح طبية فورية',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsSection(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsListProvider);

    return doctorsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 8),
              Text(
                'خطأ في تحميل الأطباء',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      data: (doctors) => doctors.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_search,
                      size: 60,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا يوجد أطباء مسجلين حالياً',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: doctors.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DoctorCard(doctor: doctors[index]),
              ),
            ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

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
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
