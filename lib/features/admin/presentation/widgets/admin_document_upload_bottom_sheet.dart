import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_patient_packages_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet to upload a medical document to a patient package.
class AdminDocumentUploadBottomSheet extends ConsumerStatefulWidget {
  const AdminDocumentUploadBottomSheet({
    required this.patientPackage,
    super.key,
  });

  final PatientPackageEntity patientPackage;

  @override
  ConsumerState<AdminDocumentUploadBottomSheet> createState() =>
      _AdminDocumentUploadBottomSheetState();
}

class _AdminDocumentUploadBottomSheetState
    extends ConsumerState<AdminDocumentUploadBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DocumentType _selectedType = DocumentType.other;
  String? _selectedServiceId;
  String? _localFilePath;
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _localFilePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_localFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار ملف للرفع')),
      );
      return;
    }

    final currentAdmin = ref
        .read(authProvider)
        .user!; // Assuming the user is admin
    final adminId = currentAdmin.id;

    final success = await ref
        .read(adminPatientPackageWriteProvider.notifier)
        .uploadDocument(
          localFilePath: _localFilePath!,
          patientId: widget.patientPackage.patientId,
          patientPackageId: widget.patientPackage.id,
          packageId: widget.patientPackage.packageId,
          clinicId: widget.patientPackage.clinicId,
          documentType: _selectedType,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          serviceId: _selectedServiceId,
          uploadedByUserId: adminId,
          uploadedByRole: 'ADMIN',
        );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المستند بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeState = ref.watch(adminPatientPackageWriteProvider);
    final isLoading = writeState is AsyncLoading;

    // Build the list of service IDs available in the package for the dropdown
    // Since we don't have the full package context here (we only have PatientPackageEntity),
    // we can use servicesUsage keys if they exist, or just allow free text if we don't have it.
    // Assuming we want exact service IDs, we might need the original package services.
    // For now, we will extract them from servicesUsage as those are the instantiated ones.
    final availableServiceIds = widget.patientPackage.servicesUsage
        .map((s) => s.serviceId)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'رفع مستند جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المستند',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Type
                DropdownButtonFormField<DocumentType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع المستند',
                    border: OutlineInputBorder(),
                  ),
                  items: DocumentType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.arabicLabel),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف / ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Service ID
                if (availableServiceIds.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedServiceId,
                    decoration: const InputDecoration(
                      labelText: 'ربط بخدمة (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        child: Text('بدون ربط بخدمة'),
                      ),
                      ...availableServiceIds.map(
                        (sid) => DropdownMenuItem(
                          value: sid,
                          child: Text(sid),
                        ),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (val) => setState(() => _selectedServiceId = val),
                  ),
                if (availableServiceIds.isNotEmpty) const SizedBox(height: 16),

                // File Picker
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_fileName ?? 'اختيار ملف (PDF, JPG, PNG)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('رفع المستند'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
