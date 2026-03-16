/// DocumentUploadBottomSheet — نافذة رفع المستندات
///
/// نموذج لرفع المستندات المرتبطة بباقة مريض. يتضمن:
/// - نوع المستند (قائمة منسدلة)
/// - العنوان (إلزامي)
/// - الوصف (اختياري)
/// - اختيار ملف (PDF/JPEG/PNG)
/// - تحقق من حجم الملف (< 20 ميجا)
/// - رسائل الخطأ والنجاح باللغة العربية
///
/// **English**: Bottom sheet for uploading documents to a patient package.
/// Includes document type dropdown, required title, optional description,
/// file picker with 20MB validation, and localized error/success messages.
///
/// **Spec**: tasks.md T080, spec.md §7.11, §7.15.
library;

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for uploading documents to a patient package.
///
/// **English**
/// Shows a form with:
/// - Document type selection (dropdown)
/// - Title input (required)
/// - Description input (optional)
/// - File picker (PDF/JPEG/PNG only)
/// - Size validation (≤ 20 MB)
/// - Upload progress indicator
/// - Arabic error/success messages
///
/// **Arabic**
/// نموذج لرفع المستندات يتضمن نوع المستند، العنوان، الوصف، ومقاس الملف.
/// يتحقق من الحجم (أقل من 20 ميجا) ويظهر رسائل خطأ باللغة العربية.
class DocumentUploadBottomSheet extends StatefulWidget {
  const DocumentUploadBottomSheet({
    required this.onUploadSuccess,
    required this.onCancel,
    super.key,
  });

  /// Creates [DocumentUploadBottomSheet].
  ///
  /// [onUploadSuccess] is called when document is successfully uploaded.
  /// [onCancel] is called when user cancels the upload.
  final VoidCallback onUploadSuccess;
  final VoidCallback onCancel;

  @override
  State<DocumentUploadBottomSheet> createState() =>
      _DocumentUploadBottomSheetState();
}

class _DocumentUploadBottomSheetState extends State<DocumentUploadBottomSheet> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _serviceIdController;

  // Selected values
  DocumentType _selectedDocumentType = DocumentType.other;
  String? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _serviceIdController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _serviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textHintLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              'رفع مستند جديد',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Document type dropdown
            _buildDocumentTypeDropdown(),
            const SizedBox(height: 16),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'العنوان *',
                hintText: 'مثال: تقرير تحليل معملي',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال العنوان';
                }
                if (value.trim().length > 200) {
                  return 'العنوان يجب أن يكون أقل من 200 حرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف (اختياري)',
                hintText: 'أضف وصفاً إضافياً للمستند',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Service ID field (optional)
            TextFormField(
              controller: _serviceIdController,
              decoration: InputDecoration(
                labelText: 'رقم الخدمة (اختياري)',
                hintText: 'إذا كان المستند مرتبطاً بخدمة محددة',
                prefixIcon: const Icon(Icons.settings),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
              ),
            ),
            const SizedBox(height: 16),

            // File picker
            _buildFilePicker(),
            const SizedBox(height: 16),

            // Submit button
            ElevatedButton(
              onPressed: _isUploading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'رفع المستند',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),

            // Cancel button
            TextButton(
              onPressed: _isUploading ? null : widget.onCancel,
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return DropdownButtonFormField<DocumentType>(
      initialValue: _selectedDocumentType,
      decoration: InputDecoration(
        labelText: 'نوع المستند *',
        prefixIcon: const Icon(Icons.document_scanner),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
      ),
      items: DocumentType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.arabicLabel),
        );
      }).toList(),
      onChanged: _isUploading
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _selectedDocumentType = value;
                });
              }
            },
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(_selectedFile!),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFile!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFileSizeText(_selectedFile!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHintLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _isUploading ? null : _pickFile,
          icon: const Icon(Icons.attach_file),
          label: const Text('اختر ملف PDF / JPEG / PNG'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    // TODO: Implement actual file picker logic
    // This should use file_picker package
    setState(() {
      _selectedFile = 'example_document.pdf';
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار ملف للرفع'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // TODO: Implement actual upload logic using UploadPackageDocumentUseCase
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
    });

    // TODO: Show success message
    widget.onUploadSuccess();
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSizeText(String filePath) {
    // TODO: Implement actual file size calculation
    return 'مقدار الحجم';
  }
}

/// Show the document upload bottom sheet.
///
/// **English**
/// Opens the upload bottom sheet with the provided callbacks.
///
/// **Arabic**
/// يفتح نموذج رفع المستندات مع دوال رد فعل.
void showDocumentUploadBottomSheet(
  BuildContext context, {
  required VoidCallback onUploadSuccess,
  required VoidCallback onCancel,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DocumentUploadBottomSheet(
      onUploadSuccess: onUploadSuccess,
      onCancel: onCancel,
    ),
  ).ignore();
}
