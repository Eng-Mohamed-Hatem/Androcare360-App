/// GetPackageDetailsUseCase — حالة استخدام تفاصيل الباقة
///
/// تقرأ هذه الحالة باقةً واحدة بمعرِّفَي العيادة والباقة من Firestore.
/// تُعيد [ClinicUnavailableFailure] إذا كانت العيادة معطَّلة أو غير موجودة.
///
/// **English**: Fetches a single clinic package by [clinicId] and [packageId].
/// Returns [ClinicUnavailableFailure] if the clinic is unavailable, or
/// [PackageNotFoundFailure] if the package document does not exist.
///
/// **Spec**: spec.md §7.9, §8.1, tasks.md T030.
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart'
    show ClinicUnavailableFailure, PackageNotFoundFailure;
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';

/// Use case: fetch full details of a single clinic package.
///
/// **English**
/// Calls [PackageRepository.getPackageById] with the given identifiers.
/// The repository maps `ClinicUnavailableFailure` when the clinic document is
/// inactive (`isActive == false` or document missing) — spec.md §7.9.
///
/// **Arabic**
/// يستدعي [PackageRepository.getPackageById] للحصول على الباقة كاملةً.
/// يُعاد [ClinicUnavailableFailure] إذا كانت العيادة معطَّلة (spec.md §7.9).
///
/// **Usage / الاستخدام**:
/// ```dart
/// final useCase = GetPackageDetailsUseCase(packageRepository);
/// final result = await useCase(
///   clinicId: ClinicIds.andrology,
///   packageId: 'pkg_123',
/// );
/// result.fold(
///   (failure) => /* show error */,
///   (package) => /* display details */,
/// );
/// ```
class GetPackageDetailsUseCase {
  /// Creates the use case with an injected [PackageRepository].
  ///
  /// يُنشئ حالة الاستخدام مع مستودع الباقات المُحقَن.
  const GetPackageDetailsUseCase(this._repo);

  final PackageRepository _repo;

  /// Executes the use case.
  ///
  /// **Parameters**:
  /// - [clinicId]: Clinic owning the package — معرف العيادة المالكة.
  /// - [packageId]: Package document ID — معرف مستند الباقة.
  ///
  /// **Returns**:
  /// - `Right(PackageEntity)` on success.
  /// - `Left(PackageNotFoundFailure)` if the package document is missing.
  /// - `Left(ClinicUnavailableFailure)` if the clinic is deactivated.
  /// - `Left(Failure)` for other errors (network, Firestore).
  ///
  /// يُعيد الباقة أو فشلاً مناسباً حسب حالة المستودع.
  Future<Either<Failure, PackageEntity>> call({
    required String clinicId,
    required String packageId,
  }) {
    return _repo.getPackageById(clinicId: clinicId, packageId: packageId);
  }
}
