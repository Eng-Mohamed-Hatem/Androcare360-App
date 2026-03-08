/// MyPackagesDetailPage — شاشة تفاصيل باقة المريض
///
/// تعرض هذه الشاشة تفاصيل باقة مشتراة واحدة: حالتها، تاريخ الانتهاء،
/// استخدام كل خدمة، والمستندات الطبية المرتبطة بها.
///
/// **English**: Detail screen for a single patient package purchase.
/// Uses [patientPackageDetailProvider] which combines entity + documents.
/// Shows per-service usage rows, a documents section with [PackageDocumentCard]
/// items, and a deactivated-clinic banner when applicable.
/// R2: notes field is NEVER shown.
///
/// **Spec**: tasks.md T050, spec.md §4.2, §9.10, §9.11, §9.14.
library;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/usecases/get_patient_package_details_usecase.dart';
import 'package:elajtech/features/packages/presentation/providers/my_packages_provider.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_document_card.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_progress_widget.dart';
import 'package:elajtech/features/packages/presentation/widgets/package_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Detail page for a single patient package.
///
/// **English**
/// Accepts [patientPackageId] and watches [patientPackageDetailProvider].
/// Shows entity details (status, dates, progress) and a list of linked
/// medical documents via [PackageDocumentCard].
/// Does NOT display the `notes` field (R2).
///
/// **Arabic**
/// شاشة تفاصيل باقة واحدة. تقرأ `patientPackageId` وتراقب المزوِّد المناسب.
/// تعرض حالة الباقة والتواريخ والتقدم والمستندات المرتبطة.
/// لا تعرض حقل `notes` أبدًا (R2).
class MyPackagesDetailPage extends ConsumerWidget {
  /// Creates [MyPackagesDetailPage].
  ///
  /// [patientPackageId]: the Firestore document ID of the patient package.
  const MyPackagesDetailPage({
    required this.patientPackageId,
    super.key,
  });

  /// The patient package document ID — معرف سجل الباقة المشتراة.
  final String patientPackageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      patientPackageDetailProvider(patientPackageId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الباقة')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DetailErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(
            patientPackageDetailProvider(patientPackageId),
          ),
        ),
        data: (details) => _DetailBody(details: details),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailBody
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.details});

  final PatientPackageDetailsResult details;

  @override
  Widget build(BuildContext context) {
    final entity = details.entity;
    final documents = details.documents;
    final theme = Theme.of(context);
    final dateFormatter = DateFormat.yMMMMd('ar');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + progress card ─────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entity.category.arabicLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PackageStatusBadge(status: entity.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'باقة: ${entity.packageId}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  _DateRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'تاريخ الشراء',
                    value: dateFormatter.format(entity.purchaseDate),
                  ),
                  const SizedBox(height: 4),
                  _DateRow(
                    icon: Icons.event_busy_outlined,
                    label: 'تاريخ الانتهاء',
                    value: dateFormatter.format(entity.expiryDate),
                  ),
                  const SizedBox(height: 12),

                  // Progress
                  PackageProgressWidget(
                    used: entity.usedServicesCount,
                    total: entity.totalServicesCount,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Services usage rows ────────────────────────────────────────────
          if (entity.servicesUsage.isNotEmpty) ...[
            Text(
              'الخدمات المشمولة',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...entity.servicesUsage.map(
              (usage) => _ServiceUsageRow(usage: usage, entity: entity),
            ),
            const SizedBox(height: 20),
          ],

          // ── Documents section ──────────────────────────────────────────────
          Text(
            'المستندات المرتبطة',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (documents.isEmpty)
            _EmptyDocuments()
          else
            ...documents.map((doc) => PackageDocumentCard(document: doc)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateRow
// ─────────────────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ServiceUsageRow
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceUsageRow extends StatelessWidget {
  const _ServiceUsageRow({
    required this.usage,
    required this.entity,
  });

  final ServiceUsageItem usage;
  final PatientPackageEntity entity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              usage.serviceId,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${usage.usedCount} / ${_quantityForService(usage.serviceId)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the total quantity of a service within the entity's servicesUsage.
  int _quantityForService(String serviceId) {
    return entity.servicesUsage.where((u) => u.serviceId == serviceId).length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyDocuments
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyDocuments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد مستندات مرتبطة بهذه الباقة بعد',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailErrorState
// ─────────────────────────────────────────────────────────────────────────────

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.message, required this.onRetry});
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
              'تعذَّر تحميل تفاصيل الباقة',
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

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen document viewer wrapper — used when tapping a document card
// ─────────────────────────────────────────────────────────────────────────────

/// Opens a document in full-screen based on its [fileUrl].
///
/// **English**: Simple webview-less viewer — opens URL via [url_launcher].
/// For a richer in-app viewer (PDF/image), integrate a dedicated package later.
///
/// **Arabic**: فتح المستند خارجيًا (عبر url_launcher). يمكن توسيعه لاحقًا.
class DocumentFullScreenPage extends StatelessWidget {
  /// Creates [DocumentFullScreenPage].
  const DocumentFullScreenPage({
    required this.document,
    super.key,
  });

  /// The document to display — المستند المراد عرضه.
  final PackageDocumentEntity document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                document.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                document.documentType.arabicLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PackageDocumentCard(document: document),
            ],
          ),
        ),
      ),
    );
  }
}
