import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart';
import 'package:injectable/injectable.dart';

/// GetPatientPackagesForAdminUseCase
///
/// **English**: Fetches a paginated list of patient packages for the admin dashboard.
/// Crucially, this uses the admin-facing repository method which INCLUDES
/// the `notes` field (R2 compliance).
///
/// **Arabic**: يجلب قائمة مبوبة لباقات المريض الخاصة بلوحة تحكم الأدمن.
/// بشكل حاسم، يستخدم هذا الأسلوب طريقة المستودع الخاصة بالأدمن والتي
/// **تتضمن** حقل الملاحظات `notes` (امتثالًا لقاعدة R2).
@lazySingleton
class GetPatientPackagesForAdminUseCase {
  final PatientPackageRepository _repository;

  GetPatientPackagesForAdminUseCase(this._repository);

  Future<Either<Failure, List<PatientPackageEntity>>> call({
    required String patientId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    return _repository.listPatientPackagesForAdmin(
      patientId: patientId,
      lastDocument: lastDocument,
      limit: limit,
    );
  }
}
