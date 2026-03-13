/// MyPackagesPage — شاشة «باقاتي» للمريض
///
/// تعرض هذه الشاشة قائمة بجميع الباقات التي اشتراها المريض الحالي، مع
/// معالجة لحالات التحميل والفراغ والخطأ وفق المواصفات.
///
/// **English**: Patient-facing screen listing all purchased packages. Uses
/// [myPackagesProvider] to load data. Handles three states: loading,
/// empty (with CTA to Packages), and error (with retry button).
/// Each package is displayed as a [_PatientPackageCard] widget showing:
/// package name, status badge, Arabic dates, progress (X/Y + bar).
///
/// **R2 (Enforcement)**: No `notes` field is displayed or accessed anywhere.
/// **RTL**: All layout inherits global RTL; `PackageProgressWidget` handles LTR.
/// Supports visual distinction for test purchases (T005).
///
/// **Spec**: tasks.md T048, spec.md §4.2, §9.4, §9.14, tasks.md T005.
library;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/pages/my_packages_detail_page.dart';
import 'package:elajtech/features/packages/presentation/pages/package_categories_page.dart';
import 'package:elajtech/features/packages/presentation/providers/my_packages_provider.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_progress_widget.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Patient-facing page listing all purchased packages.
///
/// **English**
/// Watches [myPackagesProvider] and renders the appropriate state:
/// - Loading: centred [CircularProgressIndicator].
/// - Empty: Arabic empty-state message with a CTA navigating to Packages.
/// - Error: Arabic error message with retry button.
/// - Data: scrollable list of [_PatientPackageCard] widgets.
///
/// **Arabic**
/// شاشة قائمة باقات المريض المشتراة. تعرض حالات التحميل والفراغ والخطأ والبيانات.
class MyPackagesPage extends ConsumerWidget {
  /// Creates [MyPackagesPage].
  const MyPackagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(myPackagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('باقاتي'),
        actions: [
          // Refresh action
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () => ref.read(myPackagesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.read(myPackagesProvider.notifier).refresh(),
        ),
        data: (packages) {
          if (packages.isEmpty) {
            return _EmptyState(
              onBrowse: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const PackageCategoriesPage(),
                  ),
                );
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(myPackagesProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: packages.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pkg = packages[index];
                return _PatientPackageCard(
                  package: pkg,
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => MyPackagesDetailPage(
                          patientPackageId: pkg.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PatientPackageCard
// ─────────────────────────────────────────────────────────────────────────────

/// Card widget for a single patient package in the list.
class _PatientPackageCard extends StatelessWidget {
  const _PatientPackageCard({
    required this.package,
    required this.onTap,
  });

  final PatientPackageEntity package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat.yMMMMd('ar');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: category label + status badge
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          package.category.arabicLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (package.isTestPurchase) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'شراء تجريبي',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: PackageStatusBadge(status: package.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Package Name
              Text(
                package.packageName.isNotEmpty
                    ? package.packageName
                    : 'باقة: ${package.packageId}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Dates row
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'اشترى في: ${dateFormatter.format(package.purchaseDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'ينتهي في: ${dateFormatter.format(package.expiryDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress widget (LTR wrapped internally)
              PackageProgressWidget(
                used: package.usedServicesCount,
                total: package.totalServicesCount,
              ),

              // Chevron hint
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_membership_outlined,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'لم تشترِ أي باقة بعد…',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتصفح الباقات المتاحة وانتقِ ما يناسبك',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.search),
              label: const Text('تصفح الباقات'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorState
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل الباقات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
