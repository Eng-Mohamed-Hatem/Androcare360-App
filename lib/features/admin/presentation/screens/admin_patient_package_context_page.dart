import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_document_upload_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Screen: Shows exactly what services are in a specific patient package,
/// their usage so far, the uploaded documents, and provides an action to upload
/// new documents.
class AdminPatientPackageContextPage extends ConsumerWidget {
  const AdminPatientPackageContextPage({
    required this.patient,
    required this.patientPackage,
    super.key,
  });

  final UserModel patient;
  final PatientPackageEntity patientPackage;

  void _showUploadBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminDocumentUploadBottomSheet(
        patientPackage: patientPackage,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('تفاصيل الباقة'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المريض: ${patient.fullName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('معرف الباقة: ${patientPackage.id}'),
                    Text(
                      'تاريخ الشراء: ${patientPackage.purchaseDate.toLocal().toString().split(' ')[0]}',
                    ),
                    Text(
                      'تاريخ الانتهاء: ${patientPackage.expiryDate.toLocal().toString().split(' ')[0]}',
                    ),
                    Text('الحالة: ${patientPackage.status.arabicLabel}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Usage Progress
            const Text(
              'استخدام الخدمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display usages
            ...patientPackage.servicesUsage.map((usage) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('خدمة: ${usage.serviceId}'),
                trailing: Text('${usage.usedCount} مرات الاستخدام'),
              );
            }),

            const SizedBox(height: 24),

            // Documents
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المستندات المرفقة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUploadBottomSheet(context, ref),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('رفع مستند'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Documents list using Provider
            Consumer(
              builder: (context, ref, _) {
                // Assuming adminPackageDocumentsProvider is defined elsewhere and imported
                // For example: final adminPackageDocumentsProvider = StreamProvider.family<List<DocumentEntity>, (String, String)>((ref, args) => ...);
                final docsAsync = ref.watch(
                  adminPackageDocumentsProvider((
                    patientPackage.patientId,
                    patientPackage.id,
                  )),
                );
                return docsAsync.when(
                  data: (docs) {
                    if (docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('لا توجد مستندات لهذه الباقة'),
                        ),
                      );
                    }
                    return Column(
                      children: docs
                          .map(
                            (doc) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.redAccent,
                                ),
                                title: Text(doc.title),
                                subtitle: Text(doc.documentType.arabicLabel),
                                trailing: const Icon(Icons.download),
                                onTap: () {
                                  // TODO: View or download document
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
