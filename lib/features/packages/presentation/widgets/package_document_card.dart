/// PackageDocumentCard — بطاقة عرض مستند طبي
///
/// يعرض هذا الودجت معلومات مستند طبي واحد مرتبط بباقة المريض، مع زر
/// للفتح/التحميل عبر `url_launcher`.
///
/// **English**: Card widget displaying a single [PackageDocumentEntity] with
/// Arabic title, document type label, formatted upload date, and an
/// open/download button that launches the `fileUrl` with `url_launcher`.
///
/// **Spec**: tasks.md T051, spec.md §9.10, §9.14.
library;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card displaying a single medical document linked to a patient package.
///
/// **English**
/// Shows: document [title] (Arabic), [documentType] Arabic label, formatted
/// [uploadedAt] (`DateFormat.yMMMMd('ar')`), and a button to open the file.
///
/// **Arabic**
/// يعرض: عنوان المستند، نوعه، تاريخ الرفع، وزر لفتح الملف.
///
/// **Usage / الاستخدام**:
/// ```dart
/// PackageDocumentCard(document: documentEntity)
/// ```
class PackageDocumentCard extends StatelessWidget {
  /// Creates a [PackageDocumentCard].
  const PackageDocumentCard({required this.document, super.key});

  /// The document entity to display — كيان المستند المراد عرضه.
  final PackageDocumentEntity document;

  Future<void> _openDocument(BuildContext context) async {
    final uri = Uri.tryParse(document.fileUrl);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذَّر فتح الملف. يرجى المحاولة مرة أخرى.'),
          ),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadedDate = DateFormat.yMMMMd('ar').format(document.uploadedAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Document type icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(document.documentType),
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title, type, date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic title
                  Text(
                    document.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Document type Arabic label
                  Text(
                    document.documentType.arabicLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  // Upload date
                  Text(
                    'رُفع في: $uploadedDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Open/download button
            IconButton(
              icon: const Icon(Icons.open_in_new),
              color: AppColors.primary,
              tooltip: 'فتح المستند',
              onPressed: () => _openDocument(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns an icon appropriate for the document type.
  ///
  /// يُعيد أيقونة مناسبة لنوع المستند.
  IconData _iconForType(DocumentType type) {
    return switch (type) {
      DocumentType.labResult => Icons.science_outlined,
      DocumentType.imagingReport => Icons.medical_services_outlined,
      DocumentType.other => Icons.insert_drive_file_outlined,
    };
  }
}
