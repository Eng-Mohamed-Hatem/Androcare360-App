/// PackageDetailsPage — شاشة تفاصيل الباقة وزر الشراء
///
/// تعرض هذه الشاشة تفاصيل باقة سريرية كاملة وتُتيح للمريض شراءها.
/// تستمع إلى [packageDetailsProvider] و[purchasePackageProvider] و[connectivityProvider].
///
/// **English**: Full package details screen with purchase flow.
/// Watches [packageDetailsProvider], [purchasePackageProvider], and
/// [connectivityProvider] to drive button state and offline messaging.
///
/// **Spec**: tasks.md T038, spec.md §9.4.
library;

import 'package:elajtech/core/constants/currency_constants.dart';
import 'package:elajtech/core/network/connectivity_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart'
    show ClinicUnavailableFailure;
import 'package:elajtech/features/packages/presentation/providers/packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-detail view of a clinic package with purchase button.
///
/// **English**
/// States:
/// - Loading: full-page spinner.
/// - Error ([ClinicUnavailableFailure]): red banner + buy button hidden.
/// - Loaded: package details + buy button with state driven by [purchasePackageProvider].
/// - Offline: buy button disabled + Arabic tooltip "لا يوجد اتصال بالإنترنت".
///
/// **Arabic**
/// تعرض تفاصيل الباقة وتُدير زر الشراء حسب حالة الاتصال والشراء.
///
/// **Usage / الاستخدام**:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => PackageDetailsPage(
///     clinicId: 'andrology',
///     packageId: 'pkg_001',
///   ),
/// ));
/// ```
class PackageDetailsPage extends ConsumerWidget {
  /// Creates a [PackageDetailsPage].
  const PackageDetailsPage({
    required this.clinicId,
    required this.packageId,
    super.key,
  });

  /// The owning clinic — معرف العيادة.
  final String clinicId;

  /// The package to display — معرف الباقة.
  final String packageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(
      packageDetailsProvider((clinicId, packageId)),
    );
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final purchaseState = ref.watch(purchasePackageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الباقة'), centerTitle: true),
      body: packageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBanner(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
        data: (package) => _PackageContent(
          package: package,
          isOnline: isOnline,
          purchaseNotifierState: purchaseState,
          onPurchase: () =>
              ref.read(purchasePackageProvider.notifier).purchase(package),
        ),
      ),
      bottomNavigationBar: packageAsync.whenOrNull(
        data: (package) => PackageDetailsBuyButton(package: package),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Package content
// ─────────────────────────────────────────────────────────────────────────────

/// Content view when package data is loaded.
///
/// عرض محتوى الباقة بعد التحميل.
class _PackageContent extends StatelessWidget {
  const _PackageContent({
    required this.package,
    required this.isOnline,
    required this.purchaseNotifierState,
    required this.onPurchase,
  });

  final PackageEntity package;
  final bool isOnline;
  final PurchaseNotifierState purchaseNotifierState;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ps = purchaseNotifierState.purchaseState;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package name + featured badge
          if (package.isFeatured)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'الأكثر اختيارًا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            package.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            package.shortDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),

          // Price card
          _InfoCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السعر', style: theme.textTheme.bodyMedium),
                    Text(
                      '${package.price.toStringAsFixed(0)} ${CurrencyConstants.sarArabic}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('مدة الصلاحية', style: theme.textTheme.bodyMedium),
                    Text(
                      '${package.validityDays} يوم',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Services list
          Text(
            'الخدمات المشمولة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _InfoCard(
            child: Column(
              children: package.services.map(_buildServiceRow).toList(),
            ),
          ),

          // Description (if any)
          if (package.description != null &&
              package.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'تفاصيل الباقة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              child: Text(package.description!),
            ),
          ],

          // Terms (if any)
          if (package.termsAndConditions != null &&
              package.termsAndConditions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'الشروط والأحكام',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              child: Text(
                package.termsAndConditions!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],

          // Failure message
          if (ps == PurchaseState.failure &&
              purchaseNotifierState.failureMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      purchaseNotifierState.failureMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceRow(PackageServiceItem service) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_serviceIcon(service.serviceType), size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(service.displayName)),
          if (service.quantity > 1)
            Text(
              '× ${service.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
        ],
      ),
    );
  }

  IconData _serviceIcon(ServiceType type) => switch (type) {
    ServiceType.lab => Icons.biotech,
    ServiceType.imaging => Icons.radio,
    ServiceType.visit => Icons.local_hospital,
    ServiceType.session => Icons.self_improvement,
    ServiceType.other => Icons.medical_services,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Purchase button (floating bottom)
// ─────────────────────────────────────────────────────────────────────────────

/// PackageDetailsPage with purchase button on bottom.
///
/// The buy button is handled by overriding the scaffold through a separate
/// ConsumerWidget to avoid nested Consumer pattern.

/// Purchase button area that adapts to online/offline and purchase state.
///
/// ودجت زر الشراء السفلي مع المعالجة الكاملة للحالات.
class PackageDetailsBuyButton extends ConsumerWidget {
  /// Creates a buy button for [package].
  const PackageDetailsBuyButton({required this.package, super.key});

  /// The package to purchase.
  final PackageEntity package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final ps = ref.watch(purchasePackageProvider).purchaseState;

    // Button label
    final label = switch (ps) {
      PurchaseState.success || PurchaseState.alreadyPurchased => 'عرض الباقة',
      _ => 'اشترِ الآن',
    };

    final isLoading = ps == PurchaseState.loading;
    final isEnabled =
        isOnline &&
        !isLoading &&
        ps != PurchaseState.success &&
        ps != PurchaseState.alreadyPurchased;

    Widget button = FilledButton.icon(
      key: const Key('buy_button'),
      onPressed: isEnabled
          ? () => ref
                .read(purchasePackageProvider.notifier)
                .purchase(
                  package,
                )
          : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              ps == PurchaseState.success ||
                      ps == PurchaseState.alreadyPurchased
                  ? Icons.inventory_2_outlined
                  : Icons.shopping_cart_outlined,
            ),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Wrap with tooltip when offline
    if (!isOnline) {
      button = Tooltip(
        message: 'لا يوجد اتصال بالإنترنت',
        child: button,
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: button,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Error banner for [ClinicUnavailableFailure] or network failures.
///
/// شريط الخطأ عند تعذُّر تحميل الباقة.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded card container used for info sections.
///
/// حاوية مُقرَّبة الزوايا لأقسام المعلومات.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
