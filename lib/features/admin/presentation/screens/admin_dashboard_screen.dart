import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/presentation/screens/admin_approval_screen.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_audit_log_screen.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_doctor_list_screen.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_list_screen.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/presentation/pages/admin_packages_grid_page.dart';
import 'package:elajtech/main.dart' show AuthWrapper;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main entry point for the admin panel.
///
/// Shows summary statistics and quick-access navigation cards for:
/// - Doctor management
/// - Patient management
/// - Audit log
///
/// The admin is automatically directed here by [AuthWrapper] in main.dart
/// after a successful admin login.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Preload doctor + patient counts for stats display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDoctors().ignore();
      ref.read(adminProvider.notifier).loadPatients().ignore();
    });
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد الخروج من لوحة التحكم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final admin = ref.watch(authProvider).user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('لوحة التحكم'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'مرحباً، ${admin?.fullName ?? 'المسؤول'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'لوحة تحكم AndroCare360',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Stats row
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    _StatCard(
                      label: 'الأطباء',
                      value: state.doctors.length.toString(),
                      icon: Icons.medical_services_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'المرضى',
                      value: state.patients.length.toString(),
                      icon: Icons.people_outline,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'معطّلون',
                      value: [
                        ...state.doctors,
                        ...state.patients,
                      ].where((u) => !u.isActive).length.toString(),
                      icon: Icons.block_outlined,
                      color: Colors.red.shade400,
                    ),
                  ],
                ),
              const SizedBox(height: 28),

              // Navigation cards
              const Text(
                'الإدارة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.verified_outlined,
                title: 'مراجعة طلبات الأطباء',
                subtitle: 'اعتماد أو رفض حسابات الأطباء الجديدة المعلقة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminApprovalScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.medical_services_outlined,
                title: 'إدارة الأطباء',
                subtitle: 'إضافة وتعديل وتفعيل/تعطيل حسابات الأطباء',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminDoctorListScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.people_outline,
                title: 'إدارة المرضى',
                subtitle: 'عرض وتفعيل/تعطيل حسابات المرضى',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminPatientListScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.history_outlined,
                title: 'سجل المراجعة',
                subtitle: 'عرض جميع إجراءات المسؤول مع الوقت والتفاصيل',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminAuditLogScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.card_giftcard_outlined,
                title: 'إدارة الباقات',
                subtitle: 'إضافة وتعديل الباقات وعروض العيادات المختلفة',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminPackagesGridPage(),
                    ),
                  ).ignore();
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}
