import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_document_upload_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Admin Screen: Shows exactly what services are in a specific patient package,
/// their usage so far, the uploaded documents, and provides an action to upload
/// new documents.
class AdminPatientPackageContextPage extends ConsumerStatefulWidget {
  const AdminPatientPackageContextPage({
    required this.patient,
    required this.patientPackage,
    super.key,
  });

  final UserModel patient;
  final PatientPackageEntity patientPackage;

  @override
  ConsumerState<AdminPatientPackageContextPage> createState() =>
      _AdminPatientPackageContextPageState();
}

class _AdminPatientPackageContextPageState
    extends ConsumerState<AdminPatientPackageContextPage> {
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.patientPackage.notes ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showUploadBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminDocumentUploadBottomSheet(
        patientPackage: widget.patientPackage,
      ),
    );
  }

  Future<void> _incrementUsage(String serviceId) async {
    final success = await ref
        .read(adminPatientPackageWriteProvider.notifier)
        .updateServiceUsage(
          patientId: widget.patientPackage.patientId,
          patientPackageId: widget.patientPackage.id,
          serviceId: serviceId,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث استخدام الخدمة بنجاح')),
      );
    }
  }

  Future<void> _saveNotes() async {
    final newNotes = _notesController.text.trim();
    final success = await ref
        .read(adminPatientPackageWriteProvider.notifier)
        .updateNotes(
          patientId: widget.patientPackage.patientId,
          patientPackageId: widget.patientPackage.id,
          notes: newNotes,
        );

    if (success && mounted) {
      setState(() => _isEditingNotes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الملاحظات بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates to the specific package
    final packagesAsync = ref.watch(
      adminPatientPackagesProvider(widget.patient.id),
    );
    final currentPkg = packagesAsync.maybeWhen(
      data: (list) => list.firstWhere(
        (p) => p.id == widget.patientPackage.id,
        orElse: () => widget.patientPackage,
      ),
      orElse: () => widget.patientPackage,
    );

    final isExpired =
        currentPkg.status == PatientPackageStatus.completed ||
        currentPkg.expiryDate.isBefore(DateTime.now());

    final writeState = ref.watch(adminPatientPackageWriteProvider);
    final isBusy = writeState is AsyncLoading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('تفاصيل الباقة'),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المريض: ${widget.patient.fullName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      label: 'معرف الباقة',
                      value: currentPkg.id.substring(0, 8),
                    ),
                    _InfoRow(
                      label: 'تاريخ الشراء',
                      value: DateFormat.yMMMMd('ar').format(
                        currentPkg.purchaseDate,
                      ),
                    ),
                    _InfoRow(
                      label: 'تاريخ الانتهاء',
                      value: DateFormat.yMMMMd('ar').format(
                        currentPkg.expiryDate,
                      ),
                    ),
                    _InfoRow(
                      label: 'الحالة',
                      value: isExpired ? 'منتهية' : 'نشطة',
                      valueColor: isExpired ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Usage Section
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'استخدام الخدمات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${currentPkg.usedServicesCount} / ${currentPkg.totalServicesCount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...currentPkg.servicesUsage.map((usage) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    'خدمة: ${usage.serviceId}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'تم استخدام ${usage.usedCount} مرات',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: isBusy
                        ? null
                        : () => _incrementUsage(usage.serviceId),
                    tooltip: 'تسجيل استخدام',
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Admin Notes Section (R2)
            Row(
              children: [
                const Icon(Icons.note_alt_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'ملاحظات الأدمن (خاصة)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!_isEditingNotes)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => setState(() => _isEditingNotes = true),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isEditingNotes
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'اكتب ملاحظاتك هنا...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: isBusy
                                    ? null
                                    : () => setState(
                                        () => _isEditingNotes = false,
                                      ),
                                child: const Text('إلغاء'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: isBusy ? null : _saveNotes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: isBusy
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('حفظ'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Text(
                        currentPkg.notes?.isNotEmpty ?? false
                            ? currentPkg.notes!
                            : 'لا توجد ملاحظات مسجلة.',
                        style: TextStyle(
                          color: currentPkg.notes?.isNotEmpty ?? false
                              ? AppColors.textPrimaryLight
                              : AppColors.textHintLight,
                          fontStyle: currentPkg.notes?.isNotEmpty ?? false
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Documents
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.folder_shared_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'المستندات المرفقة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _showUploadBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('رفع ملف'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Documents list using Provider
            Consumer(
              builder: (context, ref, _) {
                final docsAsync = ref.watch(
                  adminPackageDocumentsProvider((
                    currentPkg.patientId,
                    currentPkg.id,
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
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  doc.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${doc.documentType.arabicLabel} • ${DateFormat.yMMMd('ar').format(doc.uploadedAt)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: const Icon(Icons.download, size: 20),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondaryLight),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
