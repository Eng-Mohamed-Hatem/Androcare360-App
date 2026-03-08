/// CategoryPackagesListPage — شاشة قائمة الباقات حسب الفئة
///
/// تعرض هذه الشاشة قائمة الباقات النشطة لعيادة وفئة محددتَيْن.
/// تستمع إلى [categoryPackagesProvider] وتتعامل مع حالات التحميل، الخطأ، الفراغ، والبيانات.
///
/// **English**: Watches [categoryPackagesProvider] for the given [clinicId]
/// and [category]. Shows loading indicator, empty message, error with retry,
/// or [PackageCard] list.
///
/// **Spec**: tasks.md T036, spec.md §9.3.
library;

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A page listing active clinic packages for a given category.
///
/// **English**
/// Required args: [clinicId], [category], [pageTitle] (used as AppBar title).
/// Shows: loading spinner on data fetch, empty state with Arabic message,
/// error state with retry button, and a [ListView] of [PackageCard] widgets.
///
/// **Arabic**
/// تعرض قائمة الباقات النشطة. تُعالَج ثلاث حالات:
/// - التحميل: دوّامة.
/// - فارغة: "لا توجد باقات متاحة...".
/// - خطأ: رسالة + زر "إعادة المحاولة".
///
/// **Usage / الاستخدام**:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => CategoryPackagesListPage(
///     clinicId: 'andrology',
///     category: PackageCategory.andrologyInfertilityProstate,
///     pageTitle: 'باقات الذكورة والعقم',
///   ),
/// ));
/// ```
class CategoryPackagesListPage extends ConsumerWidget {
  /// Creates a [CategoryPackagesListPage].
  const CategoryPackagesListPage({
    required this.clinicId,
    required this.category,
    required this.pageTitle,
    super.key,
  });

  /// The clinic owning these packages — معرف العيادة.
  final String clinicId;

  /// The package category to display — فئة الباقة.
  final PackageCategory category;

  /// Arabic page title for the AppBar — عنوان الصفحة.
  final String pageTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(
      categoryPackagesProvider((clinicId: clinicId, category: category)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(
            categoryPackagesProvider(
              (clinicId: clinicId, category: category),
            ),
          ),
        ),
        data: (packages) => packages.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                key: const ValueKey('packages_list'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    PackageCard(package: packages[index]),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Empty state widget for when no packages are available.
///
/// ودجت الحالة الفارغة لعدم وجود باقات متاحة.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد باقات متاحة في هذا القسم حاليًا',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget with retry button.
///
/// ودجت حالة الخطأ مع زر إعادة المحاولة.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
