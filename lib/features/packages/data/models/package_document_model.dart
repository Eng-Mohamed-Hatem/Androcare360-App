/// PackageDocumentModel — نموذج بيانات المستندات الطبية (Data Layer)
///
/// يمتد من `PackageDocumentEntity` ويضيف منطق تحويل Firestore.
///
/// **English**: Data-layer model extending `PackageDocumentEntity`. Implements
/// the mandatory 3-guard Firestore safety pattern in `fromFirestore`.
///
/// **Spec**: data-model.md §5.1, tasks.md T015.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart'
    show PackageNotFoundFailure;
import 'package:flutter/foundation.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';

/// Data model for a medical document linked to a patient package.
///
/// **English**
/// Extends `PackageDocumentEntity` with Firestore serialization.
/// Uses the 3-guard safety pattern: exists check, null data check, try-catch.
///
/// **Arabic**
/// نموذج بيانات يمتد من `PackageDocumentEntity` مع تسلسل Firestore.
/// يُطبِّق نمط الثلاثة فحوصات.
class PackageDocumentModel extends PackageDocumentEntity {
  /// Creates a [PackageDocumentModel].
  const PackageDocumentModel({
    required super.id,
    required super.patientId,
    required super.patientPackageId,
    required super.packageId,
    required super.clinicId,
    required super.documentType,
    required super.title,
    required super.fileUrl,
    required super.uploadedByUserId,
    required super.uploadedByRole,
    required super.uploadedAt,
    super.serviceId,
    super.description,
  });

  /// Creates a [PackageDocumentModel] from a Firestore [DocumentSnapshot].
  ///
  /// **English**: Returns `null` on guard failure or parse error — callers
  /// should map `null` to [PackageNotFoundFailure] or filter it out.
  ///
  /// **Arabic**: يُعيد `null` عند الفشل — المُستدعي يُصفِّيه أو يُحوِّله
  /// إلى فشل مناسب.
  static PackageDocumentModel? fromFirestore(DocumentSnapshot snapshot) {
    // Guard 1: document must exist
    if (!snapshot.exists) {
      if (kDebugMode) {
        debugPrint(
          '[PackageDocumentModel.fromFirestore] Does not exist: ${snapshot.id}',
        );
      }
      return null;
    }

    // Guard 2: data must be non-null
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      if (kDebugMode) {
        debugPrint(
          '[PackageDocumentModel.fromFirestore] Null data: ${snapshot.id}',
        );
      }
      return null;
    }

    // Guard 3: parse inside try-catch
    try {
      return PackageDocumentModel(
        id: snapshot.id,
        patientId: data['patientId'] as String? ?? '',
        patientPackageId: data['patientPackageId'] as String? ?? '',
        packageId: data['packageId'] as String? ?? '',
        clinicId: data['clinicId'] as String? ?? '',
        documentType: DocumentType.fromString(
          data['documentType'] as String? ?? '',
        ),
        title: data['title'] as String? ?? '',
        description: data['description'] as String?,
        fileUrl: data['fileUrl'] as String? ?? '',
        serviceId: data['serviceId'] as String?,
        uploadedByUserId: data['uploadedByUserId'] as String? ?? '',
        uploadedByRole: data['uploadedByRole'] as String? ?? '',
        uploadedAt:
            (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } on Exception catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[PackageDocumentModel.fromFirestore] Parse error ${snapshot.id}: $e',
        );
        debugPrint(st.toString());
      }
      return null;
    }
  }

  /// Converts to Firestore-compatible map for creating a new document.
  ///
  /// تحويل النموذج إلى خريطة Firestore لإنشاء مستند جديد.
  Map<String, dynamic> toFirestore() => {
    'patientId': patientId,
    'patientPackageId': patientPackageId,
    'packageId': packageId,
    'clinicId': clinicId,
    'documentType': documentType.value,
    'title': title,
    if (description != null) 'description': description,
    'fileUrl': fileUrl,
    if (serviceId != null) 'serviceId': serviceId,
    'uploadedByUserId': uploadedByUserId,
    'uploadedByRole': uploadedByRole,
    'uploadedAt': FieldValue.serverTimestamp(),
  };
}
