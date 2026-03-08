import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for toggling the status of a clinic package.
///
/// **English**: Updates only the status field and updatedAt timestamp.
///
/// **Arabic**: تحديث حالة الباقة فقط.
@lazySingleton
class TogglePackageStatusUseCase {
  TogglePackageStatusUseCase();

  Future<Either<Failure, Unit>> call({
    required PackageRepository repository,
    required String clinicId,
    required String packageId,
    required PackageStatus status,
  }) async {
    return repository.updatePackageStatus(
      clinicId: clinicId,
      packageId: packageId,
      status: status,
    );
  }
}
