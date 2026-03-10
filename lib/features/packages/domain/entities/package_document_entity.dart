/// PackageDocumentEntity — كيان المستندات الطبية المرتبطة بالباقة
///
/// يمثل هذا الكيان مستندًا طبيًا (نتيجة تحليل، تقرير أشعة، مستند آخر)
/// مرتبطًا بباقة مريض محددة، كما هو مخزن في
/// `patients/{patientId}/packageDocuments/{documentId}` في Firestore.
///
/// **English**: Domain entity for a medical document linked to a patient package.
/// Pure Dart — no Firebase or Flutter imports. Immutable.
///
/// **Spec**: data-model.md §5.1, spec.md §7.15.
library;

import 'package:meta/meta.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DocumentType enum
// ─────────────────────────────────────────────────────────────────────────────

/// The type / modality of a package document upload.
///
/// **Arabic** نوع المستند الطبي المرفوع.
enum DocumentType {
  /// Laboratory test result — نتيجة تحليل معملي
  labResult('LAB_RESULT'),

  /// Radiology / imaging report — تقرير أشعة
  imagingReport('IMAGING_REPORT'),

  /// Any other medical document — مستند طبي آخر
  other('OTHER')
  ;

  const DocumentType(this.value);

  /// Firestore-stored string value.
  final String value;

  /// Arabic UI label — التسمية العربية للواجهة.
  String get arabicLabel => switch (this) {
    DocumentType.labResult => 'نتيجة تحليل معملي',
    DocumentType.imagingReport => 'تقرير أشعة',
    DocumentType.other => 'مستند طبي آخر',
  };

  /// Parses a Firestore string into a [DocumentType].
  ///
  /// تحويل نص Firestore إلى [DocumentType].
  static DocumentType fromString(String raw) {
    return DocumentType.values.firstWhere(
      (t) => t.value == raw.toUpperCase(),
      orElse: () => DocumentType.other,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PackageDocumentEntity
// ─────────────────────────────────────────────────────────────────────────────

/// Domain entity representing a medical document linked to a patient package.
///
/// **English**
/// Immutable pure-Dart class. Fields map 1-to-1 to data-model.md §5.1.
/// [serviceId] is optional — it links the document to a specific service
/// inside the package (e.g. a specific lab analysis). [fileUrl] is the
/// Firebase Storage download URL used by the app to render the file.
///
/// **Arabic**
/// كيان ثابت يمثل مستندًا طبيًا مرتبطًا بباقة مريض.
/// [serviceId] اختياري — يربط المستند بخدمة محددة داخل الباقة.
/// [fileUrl] هو رابط التحميل من Firebase Storage.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final doc = PackageDocumentEntity(
///   id: 'doc_001',
///   patientId: 'uid_123',
///   patientPackageId: 'pp_001',
///   packageId: 'pkg_001',
///   clinicId: ClinicIds.andrology,
///   documentType: DocumentType.labResult,
///   title: 'نتيجة تحليل السكر',
///   fileUrl: 'https://storage.googleapis.com/...',
///   uploadedByUserId: 'doctor_uid',
///   uploadedByRole: 'DOCTOR',
///   uploadedAt: DateTime.now(),
/// );
/// ```
@immutable
class PackageDocumentEntity {
  /// Creates a [PackageDocumentEntity].
  const PackageDocumentEntity({
    required this.id,
    required this.patientId,
    required this.patientPackageId,
    required this.packageId,
    required this.clinicId,
    required this.documentType,
    required this.title,
    required this.fileUrl,
    required this.uploadedByUserId,
    required this.uploadedByRole,
    required this.uploadedAt,
    this.serviceId,
    this.description,
  });

  // ── Identity ───────────────────────────────────────────────────────────────

  /// Document ID — معرف المستند.
  final String id;

  /// Patient UID (denormalized) — معرف المريض.
  final String patientId;

  /// Link to parent patient package record — معرف سجل شراء الباقة.
  final String patientPackageId;

  /// Source clinic package ID (denormalized) — معرف الباقة.
  final String packageId;

  /// Owning clinic — معرف العيادة.
  final String clinicId;

  // ── Classification ─────────────────────────────────────────────────────────

  /// Document modality — نوع المستند.
  final DocumentType documentType;

  /// Optional link to a specific service inside the package — خدمة مرتبطة.
  final String? serviceId;

  // ── Content ────────────────────────────────────────────────────────────────

  /// Short Arabic title shown to patient — العنوان بالعربية.
  final String title;

  /// Optional Arabic description / doctor notes — وصف/ملاحظات بالعربية.
  final String? description;

  // ── Storage ────────────────────────────────────────────────────────────────

  /// Firebase Storage download URL — رابط التحميل من Cloud Storage.
  final String fileUrl;

  // ── Uploader ───────────────────────────────────────────────────────────────

  /// UID of the user who uploaded this document — معرف الرافع.
  final String uploadedByUserId;

  /// Role of the uploader, e.g. 'DOCTOR' or 'ADMIN' — دور الرافع.
  final String uploadedByRole;

  /// Upload timestamp — تاريخ ووقت الرفع.
  final DateTime uploadedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageDocumentEntity &&
          other.id == id &&
          other.patientId == patientId);

  @override
  int get hashCode => Object.hash(id, patientId);

  @override
  String toString() =>
      'PackageDocumentEntity(id: $id, patientId: $patientId, '
      'type: ${documentType.value}, title: $title)';
}
