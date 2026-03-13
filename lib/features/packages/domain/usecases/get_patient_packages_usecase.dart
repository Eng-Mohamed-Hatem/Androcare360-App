/// GetPatientPackagesUseCase — حالة استخدام جلب باقات المريض
///
/// تجلب هذه الحالة جميع الباقات التي اشتراها مريض معيَّن،
/// مرتبةً تنازليًا حسب تاريخ الشراء.
///
/// **English**: Domain use case that retrieves all purchased packages for the
/// authenticated patient. Delegates to [PatientPackageRepository.getPatientPackages]
/// which uses `fromFirestoreForPatient()` — guaranteeing `notes == null` (R2).
/// Applies client-side expiry re-derivation: if `status == ACTIVE &&
/// expiryDate < now()`, the returned entity has its status overridden to
/// [PatientPackageStatus.expired] (Cloud Function may have missed the window).
///
/// **R2 (Enforcement)**: notes field is null in all returned entities.
///
/// **Spec**: tasks.md T043, spec.md §8.1, §6.1 (expiry re-derivation).
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';

/// Use case for retrieving all patient package purchases (patient-facing).
///
/// **English**
/// - Always passes through `PatientPackageRepository.getPatientPackages()`.
/// - Applies expiry re-derivation to any ACTIVE entity whose `expiryDate`
///   has passed (before Cloud Function runs, UI shows correct status).
/// - Returns list sorted by `purchaseDate` descending (newest first).
///
/// **Arabic**
/// - يُفوِّض إلى `PatientPackageRepository.getPatientPackages()`.
/// - يُعيد حساب حالة الباقات النشطة التي انتهت صلاحيتها (قبل تشغيل Cloud Function).
/// - الترتيب: تنازلي حسب تاريخ الشراء.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final useCase = GetPatientPackagesUseCase(repository);
/// final result = await useCase(patientId: uid, now: DateTime.now());
/// result.fold((f) => handleFailure(f), (list) => updateUI(list));
/// ```
class GetPatientPackagesUseCase {
  /// Creates a [GetPatientPackagesUseCase] with the given [repository].
  ///
  /// يُنشئ حالة الاستخدام باستخدام [repository] المُمرَّر.
  const GetPatientPackagesUseCase(this._repository);

  final PatientPackageRepository _repository;

  /// Executes the use case.
  ///
  /// [patientId]: authenticated patient UID — never null (caller checks R4).
  /// [now]: reference time for expiry re-derivation. Defaults to `DateTime.now()`.
  ///
  /// Returns `Right(List<PatientPackageEntity>)` sorted newest-first,
  /// or `Left(Failure)` on any error.
  ///
  /// **Arabic**: تنفيذ حالة الاستخدام. تُعيد قائمة الباقات مرتبة حسب تاريخ
  /// الشراء تنازليًا، أو فشلًا في حال حدوث خطأ.
  Future<Either<Failure, List<PatientPackageEntity>>> call({
    required String patientId,
    DateTime? now,
  }) async {
    final referenceTime = now ?? DateTime.now();

    final result = await _repository.getPatientPackages(
      patientId: patientId,
    );

    return result.fold(
      Left.new,
      (entities) {
        // Apply expiry re-derivation (spec.md §6.1 / CHK036)
        final recomputed = entities
            .map((e) => _sanitizeEntity(e, referenceTime))
            .toList();

        // Sort by purchaseDate descending (newest first — spec.md §8.1)
        recomputed.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

        return Right(recomputed);
      },
    );
  }

  /// Recomputes expiry status and strips sensitive fields (R2).
  ///
  /// يُعيد حساب حالة الانتهاء ويحذف الحقول الحساسة (مثل ملاحظات الطبيب).
  PatientPackageEntity _sanitizeEntity(
    PatientPackageEntity entity,
    DateTime now,
  ) {
    final newStatus =
        (entity.status == PatientPackageStatus.active &&
            entity.expiryDate.isBefore(now))
        ? PatientPackageStatus.expired
        : entity.status;

    // R2: notes is always null in patient-facing entities.
    return PatientPackageEntity(
      id: entity.id,
      patientId: entity.patientId,
      packageId: entity.packageId,
      packageName: entity.packageName,
      clinicId: entity.clinicId,
      category: entity.category,
      status: newStatus,
      purchaseDate: entity.purchaseDate,
      expiryDate: entity.expiryDate,
      totalServicesCount: entity.totalServicesCount,
      usedServicesCount: entity.usedServicesCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      servicesUsage: entity.servicesUsage,
      paymentTransactionId: entity.paymentTransactionId,
    );
  }
}
