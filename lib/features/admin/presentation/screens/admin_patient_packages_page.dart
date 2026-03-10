import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_package_context_page.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_progress_widget.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Admin- [x] T076 [US4] Refine admin patient packages providers
/// - [x] T077 [US4] Refine Admin Patient Detail Integration
/// - [/] T078 [US4] Refine `AdminPatientPackagesPage`
class AdminPatientPackagesPage extends ConsumerWidget {
  const AdminPatientPackagesPage({required this.patient, super.key});

  final UserModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminPatientPackagesProvider(patient.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text('باقات ${patient.fullName}'),
        ),
        body: state.when(
          data: (packages) {
            if (packages.isEmpty) {
              return const Center(child: Text('لا توجد باقات لهذا المريض.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(adminPatientPackagesProvider(patient.id).notifier)
                    .refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final pkg = packages[index];
                  final isExpired =
                      pkg.status == PatientPackageStatus.completed ||
                      pkg.expiryDate.isBefore(DateTime.now());

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    color: AppColors.cardLight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => AdminPatientPackageContextPage(
                              patient: patient,
                              patientPackage: pkg,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.card_giftcard,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'باقة عيادة ${pkg.clinicId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'تاريخ الشراء: ${DateFormat.yMMMMd('ar').format(pkg.purchaseDate)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHintLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isExpired ? 'منتهية' : 'نشطة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isExpired
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PackageProgressWidget(
                              used: pkg.usedServicesCount,
                              total: pkg.totalServicesCount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('حدث خطأ: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(adminPatientPackagesProvider(patient.id).notifier)
                      .refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
