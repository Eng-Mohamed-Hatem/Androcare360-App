/// AdminPatientPackageContextView — عرض تفصيلي لباقة مريض للأدمن
///
/// يعرض هذا العرض التفاصيل الكاملة لباقة مريض معين، بما في ذلك:
/// - استخدام الخدمات (مثال: 2/5)
/// - قائمة المستندات المرتبطة
/// - زر رفع مستندات عائم
/// - تسميات الأدوار (طبيب/أدمن)
///
/// **English**: Detailed view of a patient package for admin.
/// Shows service usage, documents list, and upload FAB.
/// Role labels for doctor/admin.
///
/// **Spec**: tasks.md T079, spec.md §9.11.
library;

import 'dart:ui' as ui;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Detailed view of a patient package for admin.
///
/// **English**
/// Takes [patientId] and [patientPackageId] as parameters.
/// Displays:
/// - Services with usage counts (e.g., 2/5)
/// - Documents list per service
/// - FAB for uploading documents
/// - Role labels for uploader
///
/// **Arabic**
/// عرض تفصيلي لباقة مريض للأدمن.
/// يعرض استخدام الخدمات، قائمة المستندات، وزر رفع عائم.
class AdminPatientPackageContextView extends ConsumerWidget {
  /// Creates [AdminPatientPackageContextView].
  const AdminPatientPackageContextView({
    required this.patientId,
    required this.patientPackageId,
    required this.package,
    super.key,
  });

  /// User ID of the patient.
  final String patientId;

  /// ID of the purchased package.
  final String patientPackageId;

  /// The patient package entity.
  final PatientPackageEntity package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(
      adminPackageDocumentsProvider(
        (patientId, patientPackageId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(package.packageId),
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
        data: (documents) => _ServiceUsageList(
          package: package,
          documents: documents,
          onUploadPressed: () {
            // TODO(Elajtech): Show document upload bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فتح نافذة رفع المستندات'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO(Elajtech): Show document upload bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فتح نافذة رفع المستندات'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('رفع مستند'),
      ),
    );
  }
}

/// Error state for documents.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
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

/// List of services with usage details.
class _ServiceUsageList extends StatelessWidget {
  const _ServiceUsageList({
    required this.package,
    required this.documents,
    required this.onUploadPressed,
  });
  final PatientPackageEntity package;
  final List<PackageDocumentEntity> documents;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceUsages = package.servicesUsage;

    if (serviceUsages.isEmpty) {
      return _EmptyServiceList(
        onUploadPressed: () => Navigator.pop(context),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: serviceUsages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final serviceUsage = serviceUsages[index];
        final serviceName = _getServiceName(serviceUsage.serviceId);
        final usageCount = serviceUsage.usedCount;
        final quantity = _getServiceQuantity(serviceUsage.serviceId);

        return _ServiceUsageCard(
          serviceName: serviceName,
          usageCount: usageCount,
          quantity: quantity,
          color: _getProgressColor(usageCount, quantity, theme),
          documents: documents
              .where((doc) => doc.serviceId == serviceUsage.serviceId)
              .toList(),
        );
      },
    );
  }

  Color _getProgressColor(int used, int total, ThemeData theme) {
    if (total == 0) return theme.colorScheme.primary;
    final fraction = (used / total).clamp(0.0, 1.0);
    if (fraction >= 1.0) return Colors.green;
    if (fraction >= 0.7) return Colors.orange;
    return theme.colorScheme.primary;
  }

  String _getServiceName(String serviceId) {
    // TODO(Elajtech): Map serviceId to actual service name
    return 'خدمة #$serviceId';
  }

  int _getServiceQuantity(String serviceId) {
    // TODO(Elajtech): Get quantity from package definition
    return 1;
  }
}

/// Empty state when no services exist.
class _EmptyServiceList extends StatelessWidget {
  const _EmptyServiceList({
    required this.onUploadPressed,
  });
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد خدمات في هذه الباقة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك الآن رفع مستندات لهذه الباقة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHintLight,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUploadPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع مستند جديد'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for service usage.
class _ServiceUsageCard extends StatelessWidget {
  const _ServiceUsageCard({
    required this.serviceName,
    required this.usageCount,
    required this.quantity,
    required this.color,
    required this.documents,
  });
  final String serviceName;
  final int usageCount;
  final int quantity;
  final Color color;
  final List<PackageDocumentEntity> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFullyUsed = usageCount >= quantity;
    final progressFraction = quantity > 0 ? usageCount / quantity : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isFullyUsed)
                  const Chip(
                    label: Text('مكتمل'),
                    backgroundColor: AppColors.success,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            // US4/T083: progress bar + western numerals must be LTR
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            backgroundColor: color.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color?>(color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$usageCount / $quantity',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Documents count
            if (documents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: AppColors.textHintLight,
                    ),
                    Text(
                      '${documents.length} مستند',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHintLight,
                      ),
                    ),
                  ],
                ),
              ),

            // Documents list
            if (documents.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return _DocumentItem(doc: doc);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual document item.
class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.doc,
  });
  final PackageDocumentEntity doc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(
            _getDocumentIcon(doc.documentType),
            size: 16,
            color: AppColors.textHintLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(doc.uploadedAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHintLight,
                  ),
                ),
              ],
            ),
          ),
          // Role label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: doc.uploadedByRole == 'DOCTOR'
                  ? AppColors.primaryLight
                  : AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getRoleLabel(doc.uploadedByRole),
              style: TextStyle(
                fontSize: 10,
                color: doc.uploadedByRole == 'DOCTOR'
                    ? AppColors.primary
                    : AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.labResult:
        return Icons.science;
      case DocumentType.imagingReport:
        return Icons.image_not_supported;
      case DocumentType.other:
        return Icons.attach_file;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'DOCTOR':
        return 'طبيب';
      case 'ADMIN':
        return 'أدمن';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    // US4/T084: Arabic date format correctly localized
    return DateFormat.yMMMMd('ar').format(date);
  }
}
