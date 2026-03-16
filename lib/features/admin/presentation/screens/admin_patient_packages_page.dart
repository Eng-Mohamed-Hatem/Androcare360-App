import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_package_context_page.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_progress_widget.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Admin screen for viewing and filtering a patient's purchased packages.
///
/// **English**:
/// Lists all packages for [patient] with:
/// - Filter toggle to hide/show simulated test purchases (T015).
/// - Visual indicators for test vs real records (T014).
/// - Navigation to context-specific management page.
///
/// **Arabic**:
/// شاشة الأدمن لعرض وتصفية باقات المريض.
/// تتضمن مفتاح تبديل لإخفاء/إظهار العمليات التجريبية (T015).
///
/// **Usage / الاستخدام**:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => AdminPatientPackagesPage(patient: user),
/// ));
/// ```
class AdminPatientPackagesPage extends ConsumerStatefulWidget {
  const AdminPatientPackagesPage({required this.patient, super.key});

  final UserModel patient;

  @override
  ConsumerState<AdminPatientPackagesPage> createState() =>
      _AdminPatientPackagesPageState();
}

class _AdminPatientPackagesPageState
    extends ConsumerState<AdminPatientPackagesPage> {
  bool _hideTestPurchases = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPatientPackagesProvider(widget.patient.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text('باقات ${widget.patient.fullName}'),
          actions: [
            IconButton(
              icon: Icon(
                _hideTestPurchases ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: _hideTestPurchases
                  ? 'إظهار العمليات التجريبية'
                  : 'إخفاء العمليات التجريبية',
              onPressed: () =>
                  setState(() => _hideTestPurchases = !_hideTestPurchases),
            ),
          ],
        ),
        body: state.when(
          data: (packages) {
            var filteredPackages = packages;
            if (_hideTestPurchases) {
              filteredPackages = packages
                  .where((p) => !p.isTestPurchase)
                  .toList();
            }

            if (filteredPackages.isEmpty) {
              return Center(
                child: Text(
                  _hideTestPurchases
                      ? 'لا توجد باقات حقيقية.'
                      : 'لا توجد باقات لهذا المريض.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(
                      adminPatientPackagesProvider(widget.patient.id).notifier,
                    )
                    .refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPackages.length,
                itemBuilder: (context, index) {
                  final pkg = filteredPackages[index];
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
                              patient: widget.patient,
                              patientPackage: pkg,
                            ),
                          ),
                        ).ignore();
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
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
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
                                        pkg.packageName.isNotEmpty
                                            ? pkg.packageName
                                            : 'باقة عيادة ${pkg.clinicId}',
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
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : Colors.green.withValues(alpha: 0.1),
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
                                if (pkg.isTestPurchase) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.blue.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'تجريبي',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
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
                      .read(
                        adminPatientPackagesProvider(
                          widget.patient.id,
                        ).notifier,
                      )
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
