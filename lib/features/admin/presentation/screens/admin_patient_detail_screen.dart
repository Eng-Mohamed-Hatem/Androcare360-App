import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_emr_screen.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_packages_page.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_account_status_chip.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the full profile of a patient and allows the admin to:
/// - View EMR history
/// - Activate / deactivate the account
class AdminPatientDetailScreen extends ConsumerWidget {
  const AdminPatientDetailScreen({required this.patient, super.key});

  final UserModel patient;

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    bool currentStatus,
  ) async {
    final action = currentStatus ? 'تعطيل' : 'تفعيل';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action الحساب'),
        content: Text(
          'هل تريد $action حساب المريض "${patient.fullName}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: currentStatus ? Colors.red : AppColors.primary,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref
        .read(adminProvider.notifier)
        .setAccountStatus(
          targetUserId: patient.id,
          isActive: !currentStatus,
        );
    final state = ref.read(adminProvider);
    if (!context.mounted) return;
    if (state.error == null) {
      // Pop back to the list — it is already refreshed by setAccountStatus
      // → loadPatients(), so the badge reflects the new status immediately.
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('تفاصيل المريض'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _InfoCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: patient.profileImage != null
                          ? NetworkImage(patient.profileImage!)
                          : null,
                      backgroundColor: Colors.teal.withOpacity(0.15),
                      child: patient.profileImage == null
                          ? Text(
                              patient.fullName.isNotEmpty
                                  ? patient.fullName[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(patient.email),
                          if (patient.phoneNumber != null)
                            Text(patient.phoneNumber!),
                          const SizedBox(height: 6),
                          AdminAccountStatusChip(isActive: patient.isActive),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AdminPatientEmrScreen(patientId: patient.id),
                        ),
                      ),
                      icon: const Icon(Icons.folder_shared_outlined),
                      label: const Text('السجل الطبي'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Packages & Status Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      // TODO: Navigate to AdminPatientPackagesPage
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                AdminPatientPackagesPage(patient: patient),
                          ),
                        );
                      },
                      icon: const Icon(Icons.card_membership),
                      label: const Text('باقات المريض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () => _toggleStatus(
                              context,
                              ref,
                              patient.isActive,
                            ),
                      icon: state.isActionLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              patient.isActive
                                  ? Icons.block_outlined
                                  : Icons.check_circle_outline,
                            ),
                      label: Text(
                        patient.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: patient.isActive
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Show error if any
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}
