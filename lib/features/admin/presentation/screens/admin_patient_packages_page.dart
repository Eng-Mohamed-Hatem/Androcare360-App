import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_package_context_page.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Screen: Lists all purchased packages for a specific patient.
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
                  // Safe access to patientPackageName using extension or directly if it exists.
                  // For now, we will use a fallback since patientPackageName is inside the package entity
                  // We'll just display a generic name or the packageId if name isn't directly available.
                  final packageName =
                      'باقة رقم ${pkg.id.substring(0, 4)}'; // Replaced later with real name if fetched

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.loyalty, color: Colors.white),
                      ),
                      title: Text(
                        packageName, // We might need to fetch the true PackageEntity for the name
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('العيادة: ${pkg.clinicId}'),
                          Text(
                            'الحالة: ${pkg.status == PatientPackageStatus.active ? "نشطة" : "غير نشطة"}',
                          ),
                          Text('الخدمات المستخدمة: ${pkg.usedServicesCount}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
