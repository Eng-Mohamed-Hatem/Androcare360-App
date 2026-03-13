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
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_service_item.dart';
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
      appBar: AppBar(
        title: detailAsync.when(
          data: (details) => Text(
            details.entity.packageName.isNotEmpty
                ? details.entity.packageName
                : 'تفاصيل الباقة',
          ),
          loading: () => const Text('جاري التحميل...'),
          error: (error, stackTrace) => const Text('خطأ'),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DetailErrorState(
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
                    entity.packageName.isNotEmpty
                        ? entity.packageName
                        : 'باقة: ${entity.packageId}',
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

          const SizedBox(height: 16),

          // ── Package Info (New) ─────────────────────────────────────────────
          if (entity.description.isNotEmpty || entity.validityDays > 0)
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
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات الباقة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (entity.description.isNotEmpty) ...[
                      Text(
                        entity.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (entity.validityDays > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'مدة الصلاحية: ${entity.validityDays} يومًا',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ── Services usage rows ────────────────────────────────────────────
          if (entity.packageServices.isNotEmpty ||
              entity.servicesUsage.isNotEmpty) ...[
            Text(
              'Included Services',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildServiceUsageRows(entity),
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

  List<Widget> _buildServiceUsageRows(PatientPackageEntity entity) {
    final usageByServiceId = <String, ServiceUsageItem>{
      for (final usage in entity.servicesUsage) usage.serviceId: usage,
    };

    final renderedServiceIds = <String>{};
    final rows = <Widget>[];

    for (final service in entity.packageServices) {
      final usage = usageByServiceId[service.serviceId];
      renderedServiceIds.add(service.serviceId);

      rows.add(
        _ServiceUsageRow(
          displayName: service.displayName,
          used: usage?.usedCount ?? 0,
          total: service.quantity,
        ),
      );
    }

    for (final usage in entity.servicesUsage) {
      if (renderedServiceIds.contains(usage.serviceId)) {
        continue;
      }

      rows.add(
        _ServiceUsageRow(
          displayName: 'خدمة غير معروفة',
          used: usage.usedCount,
          total: 0,
        ),
      );
    }

    return rows;
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
    required this.displayName,
    required this.used,
    required this.total,
  });

  final String displayName;
  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate progress percentage for safety
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isFull = used >= total && total > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFull ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isFull ? Colors.green : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$used / $total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.green : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? Colors.green : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
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

/// Opens a document in full-screen based on its `fileUrl`.
///
/// **English**: Simple webview-less viewer — opens URL via url_launcher.
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
