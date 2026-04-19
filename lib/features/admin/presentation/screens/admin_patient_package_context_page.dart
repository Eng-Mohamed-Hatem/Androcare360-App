import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_document_upload_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';

/// Admin Screen: Detailed management view for a specific patient package.
///
/// **English**:
/// Shows exactly what services are in a specific patient package,
/// their usage so far, the uploaded documents, and provides an action to upload
/// new documents. Includes technical notes (R2) and test indicator (T014).
///
/// **Arabic**:
/// شاشة الأدمن: عرض تفصيلي وإدارة لباقة مريض محددة.
/// تعرض الخدمات المستخدمة، المستندات المرفوعة، وتسمح برفع مستندات جديدة.
/// تشمل الملاحظات الفنية (R2) ومؤشر الشراء التجريبي (T014).
///
/// **Usage / الاستخدام**:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => AdminPatientPackageContextPage(
///     patient: patientModel,
///     patientPackage: packageEntity,
///   ),
/// ));
/// ```
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
  static const Map<String, String> _clinicNames = {
    'andrology': 'عيادة الذكورة والعقم والبروستاتا',
    'physiotherapy': 'عيادة العلاج الطبيعي والتأهيل',
    'internal_family': 'الطب الداخلي والأسرة',
    'nutrition': 'عيادة التغذية والسمنة',
    'chronic_diseases': 'الأمراض المزمنة',
  };

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
    ).ignore();
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

    // Watch documents to determine which services have linked documents
    final docsAsync = ref.watch(
      adminPackageDocumentsProvider((
        currentPkg.patientId,
        currentPkg.id,
      )),
    );
    final servicesWithDocs = <String>{};
    docsAsync.maybeWhen(
      data: (docs) {
        for (final doc in docs) {
          if (doc.serviceId != null) {
            servicesWithDocs.add(doc.serviceId!);
          }
        }
      },
      orElse: () {},
    );

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
                        Expanded(
                          child: Text(
                            'المريض: ${widget.patient.fullName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      label: 'اسم الباقة',
                      value: currentPkg.packageName.isNotEmpty
                          ? currentPkg.packageName
                          : currentPkg.packageId,
                    ),
                    _InfoRow(
                      label: 'العيادة / التخصص',
                      value:
                          _clinicNames[currentPkg.clinicId] ??
                          currentPkg.category.arabicLabel,
                    ),
                    _InfoRow(
                      label: 'إجمالي الجلسات / الزيارات',
                      value: '${currentPkg.totalServicesCount}',
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
                    _InfoRow(
                      label: 'معرف السجل',
                      value: currentPkg.id.length > 8
                          ? currentPkg.id.substring(0, 8)
                          : currentPkg.id,
                    ),
                    if (currentPkg.isTestPurchase)
                      const _InfoRow(
                        label: 'نوع العملية',
                        value: 'شراء تجريبي (Test)',
                        valueColor: Colors.blue,
                      ),
                  ],
                ),
                // ... existing lines ...
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
                Expanded(
                  child: Text(
                    '${servicesWithDocs.length} / ${currentPkg.totalServicesCount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildServiceUsageCards(
              currentPkg,
              isBusy: isBusy,
              servicesWithDocs: servicesWithDocs,
            ),

            const SizedBox(height: 24),

            // Documents
            Row(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_shared_outlined,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المستندات المرفقة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                                onTap: () async {
                                  final uri = Uri.tryParse(doc.fileUrl);
                                  if (uri == null) return;
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تعذر فتح المستند'),
                                      ),
                                    );
                                  }
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

            const SizedBox(height: 24),

            // Admin Notes Section (R2)
            Row(
              children: [
                const Icon(
                  Icons.note_alt_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ملاحظات الأدمن (خاصة)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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

            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServiceUsageCards(
    PatientPackageEntity package, {
    required bool isBusy,
    required Set<String> servicesWithDocs,
  }) {
    final usageByServiceId = {
      for (final usage in package.servicesUsage) usage.serviceId: usage,
    };
    final renderedServiceIds = <String>{};
    final cards = <Widget>[];

    for (final service in package.packageServices) {
      final usage = usageByServiceId[service.serviceId];
      renderedServiceIds.add(service.serviceId);
      cards.add(
        _buildServiceUsageCard(
          serviceName: service.displayName,
          serviceId: service.serviceId,
          allowedCount: service.quantity,
          usedCount: usage?.usedCount ?? 0,
          isBusy: isBusy,
          servicesWithDocs: servicesWithDocs,
        ),
      );
    }

    for (final usage in package.servicesUsage) {
      if (renderedServiceIds.contains(usage.serviceId)) {
        continue;
      }
      cards.add(
        _buildServiceUsageCard(
          serviceName: 'خدمة غير معرفة (${usage.serviceId})',
          serviceId: usage.serviceId,
          allowedCount: 0,
          usedCount: usage.usedCount,
          isBusy: isBusy,
          servicesWithDocs: servicesWithDocs,
        ),
      );
    }

    if (cards.isEmpty) {
      cards.add(
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('لا توجد خدمات معرفة في هذه الباقة.'),
          ),
        ),
      );
    }

    return cards;
  }

  Widget _buildServiceUsageCard({
    required String serviceName,
    required String serviceId,
    required int allowedCount,
    required int usedCount,
    required bool isBusy,
    required Set<String> servicesWithDocs,
  }) {
    final hasLinkedDocument = servicesWithDocs.contains(serviceId);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: hasLinkedDocument
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null,
        title: Row(
          children: [
            if (hasLinkedDocument) const SizedBox(width: 8),
            Expanded(
              child: Text(
                serviceName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'المسموح: $allowedCount • المستخدم: $usedCount',
          style: const TextStyle(fontSize: 12),
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondaryLight),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimaryLight,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
