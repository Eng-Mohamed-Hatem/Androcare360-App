import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/presentation/providers/admin_approval_provider.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة مراجعة واعتماد الأطباء المعلقين للمسؤول.
///
/// Admin-only screen that lists pending doctor registrations and allows the
/// administrator to approve or reject each registration.
///
/// **Usage Example:**
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute<void>(
///     builder: (_) => const AdminApprovalScreen(),
///   ),
/// );
/// ```
class AdminApprovalScreen extends ConsumerStatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  ConsumerState<AdminApprovalScreen> createState() =>
      _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends ConsumerState<AdminApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminApprovalProvider.notifier).loadPendingDoctors().ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminApprovalState>(adminApprovalProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);

      if (next.error != null && next.error != previous?.error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(adminApprovalProvider.notifier).clearError();
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(adminApprovalProvider.notifier).clearSuccess();
      }
    });

    final authState = ref.watch(authProvider);
    final state = ref.watch(adminApprovalProvider);
    final currentUser = authState.user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('مراجعة طلبات الأطباء'),
        ),
        body: _buildBody(context, state, currentUser),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AdminApprovalState state,
    UserModel? currentUser,
  ) {
    if (currentUser == null || currentUser.userType != UserType.admin) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'هذه الشاشة متاحة للمسؤول فقط.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.pendingDoctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(adminApprovalProvider.notifier).loadPendingDoctors(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                'لا توجد طلبات أطباء معلقة حالياً.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminApprovalProvider.notifier).loadPendingDoctors(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.pendingDoctors.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doctor = state.pendingDoctors[index];
          final isBusy =
              state.isActionLoading && state.activeDoctorId == doctor.doctorId;

          return _PendingDoctorCard(
            doctorName: doctor.fullName,
            phoneNumber: doctor.phoneNumber,
            specialty: doctor.specialty,
            email: doctor.email,
            registrationDate: _formatDate(doctor.createdAt),
            isBusy: isBusy,
            onApprove: () {
              ref
                  .read(adminApprovalProvider.notifier)
                  .approveDoctor(doctor)
                  .ignore();
            },
            onReject: () async {
              final confirmed = await _showRejectConfirmationDialog(context);
              if (confirmed != true || !context.mounted) {
                return;
              }

              await ref
                  .read(adminApprovalProvider.notifier)
                  .rejectDoctor(doctor);
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showRejectConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('رفض الطلب'),
          content: const Text(
            'هل أنت متأكد من رفض هذا الطبيب؟ سيتم حذف الطلب من النظام.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('رفض'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }
}

class _PendingDoctorCard extends StatelessWidget {
  const _PendingDoctorCard({
    required this.doctorName,
    required this.phoneNumber,
    required this.specialty,
    required this.email,
    required this.registrationDate,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
  });

  final String doctorName;
  final String phoneNumber;
  final String specialty;
  final String email;
  final String registrationDate;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'التخصص', value: specialty),
            _InfoRow(label: 'الهاتف', value: phoneNumber),
            _InfoRow(label: 'البريد', value: email),
            _InfoRow(label: 'تاريخ التسجيل', value: registrationDate),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isBusy ? null : onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('موافقة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }
}
