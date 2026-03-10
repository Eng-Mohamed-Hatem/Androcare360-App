/// Represents a document uploaded to a patient package.
/// يمثل مستند تم رفعه لحزمة مريض.
///
/// This entity stores information about documents (PDFs, images) that have been
/// uploaded to a patient package, including file metadata and upload information.
/// هذا الكيان يخزن معلومات حول المستندات (PDFs، صور) التي تم رفعها إلى حزمة مريض،
/// بما في ذلك بيانات الملف ومعلومات الرفع.
///
/// **Security Rules:**
/// - File size is validated before upload (max 20 MB)
/// - File types are validated (pdf, jpg, jpeg, png only)
/// - Storage paths follow the pattern: /patient_packages/{packageId}/{documentId}
/// - File metadata includes uploader info for audit purposes
///
/// **Example:**
/// ```dart
/// final document = PackageDocument(
///   id: 'doc_789',
///   documentUrl: 'gs://elajtech.appspot.com/patient_packages/pkg_123/doc_789.pdf',
///   fileName: 'prescription_example.pdf',
///   mimeType: 'application/pdf',
///   fileSize: 1024000, // 1 MB in bytes
///   uploadedBy: 'admin_456',
///   uploadedAt: DateTime.now(),
///   note: 'First prescription',
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_document.freezed.dart';
part 'package_document.g.dart';

@freezed
abstract class PackageDocument with _$PackageDocument {
  /// Creates a new PackageDocument instance.
  /// ينشئ مثيلاً جديدًا لـ PackageDocument.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the document
  /// - [documentUrl]: URL/path where the document is stored in Firebase Storage
  /// - [fileName]: Name of the file
  /// - [mimeType]: MIME type of the file (e.g., 'application/pdf', 'image/jpeg')
  /// - [fileSize]: Size of the file in bytes
  /// - [uploadedBy]: ID of the user who uploaded the document
  /// - [uploadedAt]: Timestamp when the document was uploaded
  /// - [note]: Optional note about this document
  const factory PackageDocument({
    required String id,
    required String documentUrl,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required String uploadedBy,
    required DateTime uploadedAt,
    String? note,
  }) = _PackageDocument;
  const PackageDocument._();

  /// Creates a PackageDocument from JSON map.
  /// ينشئ PackageDocument من خريطة JSON.
  factory PackageDocument.fromJson(Map<String, dynamic> json) =>
      _$PackageDocumentFromJson(json);

  /// Formats file size to human-readable string.
  /// تنسيق حجم الملف إلى نص قابل للقراءة.
  ///
  /// **Example:**
  /// ```dart
  /// final sizeInBytes = 1500000;
  /// print(document.formatFileSize(sizeInBytes));
  /// // Output: "1.5 MB"
  /// ```
  String formatFileSize(int fileSizeInBytes) {
    if (fileSizeInBytes < 1024) {
      return '$fileSizeInBytes B';
    } else if (fileSizeInBytes < 1024 * 1024) {
      return '${(fileSizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Returns the file extension from the file name.
  /// يعيد امتداد الملف من اسم الملف.
  ///
  /// **Example:**
  /// ```dart
  /// print(document.getFileExtension('prescription.pdf'));
  /// // Output: ".pdf"
  /// ```
  String getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex);
  }

  /// Checks if the document is a supported type.
  /// يتحقق مما إذا كان نوع المستند مدعومًا.
  ///
  /// **Supported Types:**
  /// - PDF (application/pdf)
  /// - JPG (image/jpeg)
  /// - PNG (image/png)
  ///
  /// **Example:**
  /// ```dart
  /// if (document.isSupportedType) {
  ///   print('This file can be uploaded');
  /// }
  /// ```
  bool get isSupportedType {
    const supportedTypes = {
      'application/pdf',
      'image/jpeg',
      'image/png',
    };
    return supportedTypes.contains(mimeType);
  }

  /// Checks if the document exceeds the maximum allowed size.
  /// يتحقق مما إذا كان حجم المستند يتجاوز الحد الأقصى المسموح به.
  ///
  /// **Max Size:** 20 MB (20971520 bytes)
  ///
  /// **Example:**
  /// ```dart
  /// if (document.isOverSizeLimit) {
  ///   print('File is too large! Max size is 20 MB');
  /// }
  /// ```
  bool get isOverSizeLimit {
    const maxSizeInBytes = 20 * 1024 * 1024; // 20 MB
    return fileSize > maxSizeInBytes;
  }

  /// Returns the formatted upload date.
  /// يعيد التاريخ المبرمج عند الرفع.
  ///
  /// **Example:**
  /// ```dart
  /// print(document.getFormattedUploadDate());
  /// // Output: "2026-03-08 at 14:30"
  /// ```
  String getFormattedUploadDate() {
    return '${uploadedAt.year}-${uploadedAt.month.toString().padLeft(2, '0')}-${uploadedAt.day.toString().padLeft(2, '0')} at ${uploadedAt.hour.toString().padLeft(2, '0')}:${uploadedAt.minute.toString().padLeft(2, '0')}';
  }
}
