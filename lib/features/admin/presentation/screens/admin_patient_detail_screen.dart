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
                      backgroundColor: Colors.teal.withValues(alpha: 0.15),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final action = patient.isActive ? 'تعطيل' : 'تفعيل';
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('$action الحساب'),
                            content: Text(
                              'هل أنت متأكد من $action حساب المريض؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: patient.isActive
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                child: Text(action),
                              ),
                            ],
                          ),
                        );

                        if (confirmed ?? false) {
                          await ref
                              .read(adminProvider.notifier)
                              .setAccountStatus(
                                targetUserId: patient.id,
                                isActive: !patient.isActive,
                              );
                        }
                      },
                      icon: Icon(
                        patient.isActive
                            ? Icons.block
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
              const SizedBox(height: 24),

              // Patient Packages Section
              _PackageSection(
                patient: patient,
              ),
              const SizedBox(height: 24),

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
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _PackageSection extends StatelessWidget {
  const _PackageSection({
    required this.patient,
  });
  final UserModel patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AdminPatientPackagesPage(
                patient: patient,
              ),
            ),
          ).ignore();
        },
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'باقات المريض',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'عرض جميع الباقات المشتراة وارفاق المستندات',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHintLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
