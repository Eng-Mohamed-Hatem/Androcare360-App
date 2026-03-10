import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/presentation/pages/admin_packages_list_page.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AdminPackagesGridPage — شاشة شبكة عيادات الباقات للمسؤول
///
/// **English**: Entry point for admin package management. Displays a grid of
/// clinics. Selecting a clinic updates [adminSelectedClinicProvider] and
/// navigates to [AdminPackagesListPage].
///
/// **Arabic**: نقطة الدخول لإدارة باقات المسؤول. تعرض شبكة من العيادات. اختيار
/// العيادة يؤدي إلى تحديث [adminSelectedClinicProvider] والانتقال إلى
/// [AdminPackagesListPage].
class AdminPackagesGridPage extends ConsumerWidget {
  /// Creates an [AdminPackagesGridPage].
  const AdminPackagesGridPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الباقات - العيادات'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: ClinicIds.all.length,
        itemBuilder: (context, index) {
          final clinicId = ClinicIds.all[index];
          final category = _getCategoryForClinic(clinicId);

          return _ClinicGridCard(
            clinicId: clinicId,
            label: category.arabicLabel.replaceAll('باقات ', ''),
            icon: _getIconForClinic(clinicId),
            onTap: () {
              ref.read(adminSelectedClinicProvider.notifier).state = clinicId;
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const AdminPackagesListPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  PackageCategory _getCategoryForClinic(String clinicId) {
    return switch (clinicId) {
      ClinicIds.andrology => PackageCategory.andrologyInfertilityProstate,
      ClinicIds.physiotherapy => PackageCategory.physiotherapyRehabilitation,
      ClinicIds.internalFamily => PackageCategory.internalFamilyMedicine,
      ClinicIds.nutrition => PackageCategory.obesityTherapeuticNutrition,
      ClinicIds.chronicDiseases => PackageCategory.chronicDiseases,
      _ => PackageCategory.chronicDiseases,
    };
  }

  IconData _getIconForClinic(String clinicId) {
    return switch (clinicId) {
      ClinicIds.andrology => Icons.male,
      ClinicIds.physiotherapy => Icons.accessibility_new,
      ClinicIds.internalFamily => Icons.family_restroom,
      ClinicIds.nutrition => Icons.restaurant,
      ClinicIds.chronicDiseases => Icons.medical_services,
      _ => Icons.help_outline,
    };
  }
}

class _ClinicGridCard extends StatelessWidget {
  const _ClinicGridCard({
    required this.clinicId,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String clinicId;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
