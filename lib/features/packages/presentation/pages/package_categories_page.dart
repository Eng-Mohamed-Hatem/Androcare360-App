/// PackageCategoriesPage — شاشة تصفح فئات الباقات
///
/// تعرض هذه الشاشة قائمة ثابتة بالفئات الخمس للباقات السريرية.
/// لا تُجري أي استعلامات بيانات — تعتمد على ثوابت `ClinicIds` و`PackageCategory`.
///
/// **English**: Static list of 5 clinic category cards. No network calls.
/// Each card navigates to `CategoryPackagesListPage` with the correct
/// `clinicId` and `category` arguments.
///
/// **Spec**: tasks.md T035, spec.md §9.2.
library;

import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/presentation/pages/category_packages_list_page.dart';
import 'package:flutter/material.dart';

/// Page showing all available package categories for the patient to browse.
///
/// **English**: Each `_CategoryCard` contains an icon, Arabic title, subtitle,
/// and navigates to `CategoryPackagesListPage` on tap.
///
/// **Arabic**: تعرض الفئات الخمس للباقات السريرية. كل بطاقة تنتقل إلى
/// شاشة قائمة الباقات الخاصة بالفئة.
///
/// **Usage / الاستخدام**:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const PackageCategoriesPage()),
/// );
/// ```
class PackageCategoriesPage extends StatelessWidget {
  /// Creates a [PackageCategoriesPage].
  const PackageCategoriesPage({super.key});

  /// Clinic category data: (clinicId, category, title, subtitle, icon, color)
  static const List<_CategoryData> _categories = [
    _CategoryData(
      clinicId: ClinicIds.andrology,
      category: PackageCategory.andrologyInfertilityProstate,
      title: 'باقات الذكورة والعقم والبروستاتا',
      subtitle: 'برامج متكاملة لصحة الرجل',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFF1565C0),
    ),
    _CategoryData(
      clinicId: ClinicIds.physiotherapy,
      category: PackageCategory.physiotherapyRehabilitation,
      title: 'باقات العلاج الطبيعي والتأهيل',
      subtitle: 'جلسات علاجية لاستعادة الحركة',
      icon: Icons.self_improvement,
      color: Color(0xFF2E7D32),
    ),
    _CategoryData(
      clinicId: ClinicIds.internalFamily,
      category: PackageCategory.internalFamilyMedicine,
      title: 'باقات الباطنة وطب الأسرة',
      subtitle: 'رعاية شاملة للأسرة',
      icon: Icons.family_restroom,
      color: Color(0xFF6A1B9A),
    ),
    _CategoryData(
      clinicId: ClinicIds.nutrition,
      category: PackageCategory.obesityTherapeuticNutrition,
      title: 'باقات السمنة والتغذية العلاجية',
      subtitle: 'برامج فقدان الوزن والتغذية',
      icon: Icons.restaurant_menu,
      color: Color(0xFFE65100),
    ),
    _CategoryData(
      clinicId: ClinicIds.chronicDiseases,
      category: PackageCategory.chronicDiseases,
      title: 'باقات الأمراض المزمنة',
      subtitle: 'متابعة وإدارة الأمراض المزمنة',
      icon: Icons.monitor_heart_outlined,
      color: Color(0xFFC62828),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباقات الطبية'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final data = _categories[index];
          return _CategoryCard(
            data: data,
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => CategoryPackagesListPage(
                    clinicId: data.clinicId,
                    category: data.category,
                    pageTitle: data.title,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private data class
// ─────────────────────────────────────────────────────────────────────────────

/// Holds static data for a single category card.
///
/// بيانات ثابتة لبطاقة فئة الباقات.
class _CategoryData {
  const _CategoryData({
    required this.clinicId,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String clinicId;
  final PackageCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Card Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Card displaying a single clinic package category.
///
/// **Arabic**: بطاقة فئة الباقات السريرية.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data, required this.onTap});

  final _CategoryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.color, size: 30),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing arrow
              Icon(Icons.chevron_left, color: data.color),
            ],
          ),
        ),
      ),
    );
  }
}
