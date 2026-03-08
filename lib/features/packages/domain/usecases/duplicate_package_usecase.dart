import 'package:dartz/dartz.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for duplicating a clinic package.
///
/// **English**: Reads source package, strips ID, appends "(نسخة)" to name,
/// sets status to HIDDEN, unsets isFeatured, and writes as a new document.
///
/// **Arabic**: تكرار الباقة، مع تصفير المعرف وتغيير الاسم والحالة إلى مخفية.
@lazySingleton
class DuplicatePackageUseCase {
  DuplicatePackageUseCase(this._accessResolver);

  final ClinicAccessResolver _accessResolver;

  Future<Either<Failure, String>> call({
    required PackageRepository repository,
    required String clinicId,
    required String packageId,
  }) async {
    // 1. Check access
    final allowed = await _accessResolver.getAllowedClinics();
    if (!allowed.contains(clinicId)) {
      return const Left(
        ClinicUnavailableFailure('ليس لديك صلاحية لإضافة باقة في هذه العيادة.'),
      );
    }

    // 2. Read source package
    final sourceOr = await repository.getPackageById(
      clinicId: clinicId,
      packageId: packageId,
    );

    return sourceOr.fold(
      Left.new,
      (source) async {
        // 3. Prepare duplicated entity
        var newName = '${source.name} (نسخة)';
        if (newName.length > 200) {
          newName = newName.substring(0, 200);
        }

        final now = DateTime.now();
        final duplicate = PackageEntity.fromType(
          id: '', // Empty triggers creation
          clinicId: source.clinicId,
          category: source.category,
          name: newName,
          shortDescription: source.shortDescription,
          description: source.description,
          services: source.services,
          validityDays: source.validityDays,
          price: source.price,
          currency: source.currency,
          type: source.packageType,
          status: PackageStatus.hidden, // HIDDEN as per spec
          displayOrder: source.displayOrder + 1, // place it next to original
          isFeatured: false, // Don't copy isFeatured implicitly
          createdAt: now,
          updatedAt: now,
          termsAndConditions: source.termsAndConditions,
          discountPercentage: source.discountPercentage,
        );

        // 4. Save
        return repository.createPackage(duplicate);
      },
    );
  }
}
