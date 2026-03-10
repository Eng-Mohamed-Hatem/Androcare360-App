/// GetPatientPackagesForAdminUseCase — جلب باقات المريض للأدمن
///
/// يجلب هذا الـ UseCase قائمة مشتريات مريض محدد للأدمن أو الطبيب.
/// **الإصدار للأدمن**: يدعم تقسيم النتائج لصفحات (Pagination) ولا يزيل
/// حقل الملاحظات `notes` (R2).
///
/// **English**: Domain use case for fetching a patient's packages for admins.
/// Retrieves paginated results via [PatientPackageRepository.listPatientPackagesForAdmin].
/// This version preserves the [notes] field (R2). Also dynamically re-derives
/// the `expired` status if an active package has passed its `expiryDate`.
///
/// **Spec**: spec.md §7.8, §8.3, tasks.md T071.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';

/// Use case: Get patient packages paginated (admin-facing).
///
/// **Arabic**: طلب جلب باقات المريض المُقسمة لصفحات (واجهة الأدمن).
@lazySingleton
class GetPatientPackagesForAdminUseCase {
  /// Constructor expecting the PatientPackageRepository.
  const GetPatientPackagesForAdminUseCase(this._repository);

  final PatientPackageRepository _repository;

  /// Executes the use case.
  ///
  /// [lastDocument] provides the pagination cursor.
  /// [limit] configures page size, defaulting to 20 (spec.md §8.3).
  /// [now] is used for testing expiry re-derivation.
  Future<Either<Failure, List<PatientPackageEntity>>> call({
    required String patientId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
    DateTime? now,
  }) async {
    final result = await _repository.listPatientPackagesForAdmin(
      patientId: patientId,
      lastDocument: lastDocument,
      limit: limit,
    );

    return result.map((packages) {
      final currentTime = now ?? DateTime.now();

      return packages.map((entity) {
        // Enforce expiry constraint locally for display accuracy.
        // Spec.md §6.1 implies ACTIVE packages past their expiryDate should be
        // presented as EXPIRED, even if the Cloud Function hasn't batched them yet.
        if (entity.status == PatientPackageStatus.active &&
            entity.expiryDate.isBefore(currentTime)) {
          return PatientPackageEntity(
            id: entity.id,
            patientId: entity.patientId,
            packageId: entity.packageId,
            clinicId: entity.clinicId,
            category: entity.category,
            status: PatientPackageStatus.expired,
            purchaseDate: entity.purchaseDate,
            expiryDate: entity.expiryDate,
            totalServicesCount: entity.totalServicesCount,
            usedServicesCount: entity.usedServicesCount,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            servicesUsage: entity.servicesUsage,
            paymentTransactionId: entity.paymentTransactionId,
            notes: entity.notes, // Notes MUST be preserved for admin (R2)
          );
        }
        return entity;
      }).toList();
    });
  }
}
