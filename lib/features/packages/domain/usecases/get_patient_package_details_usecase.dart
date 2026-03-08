/// GetPatientPackageDetailsUseCase — حالة استخدام جلب تفاصيل باقة المريض
///
/// تجمع هذه الحالة كيان الباقة المشتراة مع قائمة المستندات المرتبطة بها
/// في نتيجة واحدة متكاملة.
///
/// **English**: Domain use case combining a patient package entity (notes
/// always null — R2) with its linked medical documents into a single
/// [PatientPackageDetailsResult]. Calls both repositories sequentially;
/// returns [PackageNotFoundFailure] if the entity lookup fails.
///
/// **R2 (Enforcement)**: Delegates to `getPatientPackageByIdForPatient()`
/// which strips `notes`. Use case does NOT re-add it.
///
/// **Spec**: tasks.md T045, spec.md §8.1, §9.10, Index 6.
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_document_entity.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart'
    show PackageNotFoundFailure;
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PatientPackageDetailsResult
// ─────────────────────────────────────────────────────────────────────────────

/// Combined result of a patient package entity plus its linked documents.
///
/// **English**: Immutable result returned by [GetPatientPackageDetailsUseCase].
/// [entity] always has `notes == null` (R2). [documents] is empty when no
/// documents have been uploaded yet.
///
/// **Arabic**
/// نتيجة مُدمَجة للكيان وقائمة المستندات. حقل `notes` دائمًا null (R2).
class PatientPackageDetailsResult {
  /// Creates a [PatientPackageDetailsResult].
  const PatientPackageDetailsResult({
    required this.entity,
    required this.documents,
  });

  /// The patient package entity — notes always null (R2).
  ///
  /// كيان الباقة المشتراة — حقل notes دائمًا null.
  final PatientPackageEntity entity;

  /// Documents linked to this patient package (may be empty).
  ///
  /// المستندات المرتبطة بهذه الباقة (قد تكون فارغة).
  final List<PackageDocumentEntity> documents;
}

// ─────────────────────────────────────────────────────────────────────────────
// GetPatientPackageDetailsUseCase
// ─────────────────────────────────────────────────────────────────────────────

/// Use case for retrieving full details of a single patient package.
///
/// **English**
/// 1. Calls `PatientPackageRepository.getPatientPackageByIdForPatient()`
///    which enforces R2 (notes = null).
/// 2. On success, calls `PackageDocumentRepository.getDocumentsByPatientPackage()`
///    (backed by Firestore Index 6: patientId + patientPackageId).
/// 3. Returns [PatientPackageDetailsResult] on success, or the first
///    encountered [Failure] if either call fails.
///
/// **Arabic**
/// 1. يستدعي مستودع الباقات بصيغة المريض (notes = null، R2).
/// 2. عند النجاح يستدعي مستودع المستندات (Index 6).
/// 3. يُعيد [PatientPackageDetailsResult] أو الفشل الأول في حال حدوث خطأ.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final useCase = GetPatientPackageDetailsUseCase(
///   patientPackageRepository: repo,
///   documentRepository: docRepo,
/// );
/// final result = await useCase(
///   patientId: 'uid_123',
///   patientPackageId: 'pp_001',
/// );
/// ```
class GetPatientPackageDetailsUseCase {
  /// Creates the use case with required repositories.
  ///
  /// يُنشئ حالة الاستخدام بالمستودعَيْن المطلوبَيْن.
  const GetPatientPackageDetailsUseCase({
    required PatientPackageRepository patientPackageRepository,
    required PackageDocumentRepository documentRepository,
  }) : _patientPackageRepository = patientPackageRepository,
       _documentRepository = documentRepository;

  final PatientPackageRepository _patientPackageRepository;
  final PackageDocumentRepository _documentRepository;

  /// Executes the use case.
  ///
  /// [patientId]: authenticated patient UID.
  /// [patientPackageId]: the document ID in `patients/{uid}/packages/`.
  ///
  /// Returns `Right(PatientPackageDetailsResult)` or `Left(Failure)`.
  ///
  /// **Arabic**: تنفيذ حالة الاستخدام. تُعيد تفاصيل الباقة + المستندات أو فشلًا.
  Future<Either<Failure, PatientPackageDetailsResult>> call({
    required String patientId,
    required String patientPackageId,
  }) async {
    // Step 1: fetch entity (notes = null, R2 enforced at repo level)
    final entityResult = await _patientPackageRepository
        .getPatientPackageByIdForPatient(
          patientId: patientId,
          patientPackageId: patientPackageId,
        );

    if (entityResult.isLeft()) {
      return Left(entityResult.fold((f) => f, (_) => throw StateError('')));
    }

    final entity = entityResult.fold((_) => throw StateError(''), (e) => e);

    // Step 2: fetch linked documents (Index 6)
    final docsResult = await _documentRepository.getDocumentsByPatientPackage(
      patientId: patientId,
      patientPackageId: patientPackageId,
    );

    return docsResult.fold(
      Left.new,
      (docs) => Right(
        PatientPackageDetailsResult(entity: entity, documents: docs),
      ),
    );
  }
}
