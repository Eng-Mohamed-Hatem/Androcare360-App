/// PackageDocumentRepository — واجهة مستودع مستندات الباقة
///
/// تُعرِّف هذه الواجهة عقد الوصول إلى المستندات الطبية المرتبطة بالباقات.
///
/// **English**: Domain-layer repository interface for package-linked medical
/// documents. Injects two separate datasources (R5 — SRP): Firestore for
/// metadata and Firebase Storage for file operations.
///
/// **Spec**: spec.md §7.15, tasks.md T012.
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart' show UploadFailure;

/// Abstract repository for medical documents linked to patient packages.
///
/// **English**
/// Two methods: list retrieval (Firestore) and document upload (Storage).
/// Both return `Either<Failure, T>`.
///
/// **Arabic**
/// واجهة مجردة لاسترجاع ورفع المستندات الطبية المرتبطة بباقة المريض.
abstract class PackageDocumentRepository {
  /// Returns all documents linked to [patientPackageId] for [patientId].
  ///
  /// **English**: Uses Index 6: `patientId + patientPackageId`. Limit = 50
  /// (CHK049 — sufficient for expected max per package).
  ///
  /// **Arabic**: يُعيد جميع مستندات سجل الشراء (بحد أقصى 50).
  Future<Either<Failure, List<PackageDocumentEntity>>>
  getDocumentsByPatientPackage({
    required String patientId,
    required String patientPackageId,
  });

  /// Uploads a document file and creates a Firestore metadata record.
  ///
  /// **English**: Storage path: `packageDocuments/{clinicId}/{patientId}/
  /// {patientPackageId}/{documentId}/{filename}`. File must be ≤ 20 MB and
  /// one of {pdf, jpg, jpeg, png}. Returns the created [PackageDocumentEntity]
  /// on success, or [UploadFailure] on any storage/Firestore error.
  ///
  /// **Arabic**: يرفع الملف إلى Cloud Storage ثم يُنشئ سجل بيانات واصفة
  /// في Firestore. الملف يجب أن يكون ≤ 20 ميجابايت من النوع المسموح به.
  Future<Either<Failure, PackageDocumentEntity>> uploadDocument({
    required String localFilePath,
    required String patientId,
    required String patientPackageId,
    required String packageId,
    required String clinicId,
    required DocumentType documentType,
    required String title,
    required String uploadedByUserId,
    required String uploadedByRole,
    String? serviceId,
    String? description,
  });
}
