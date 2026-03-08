/// ListCategoryPackagesUseCase — حالة استخدام قائمة الباقات حسب الفئة
///
/// تُعيد هذه الحالة قائمة الباقات النشطة لعيادة وفئة معينة،
/// مُرتَّبة بحيث تظهر الباقات المميزة أولاً ثم حسب `displayOrder`.
///
/// **English**: Returns ACTIVE packages for a given [clinicId] and [category],
/// sorted: featured packages first, then by `displayOrder` ascending.
/// Delegates to [PackageRepository.listCategoryPackages].
///
/// **Spec**: spec.md §9.3, §8.1, tasks.md T028.
library;

import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';

/// Use case: list all ACTIVE packages for a clinic category.
///
/// **English**
/// Fetches packages from [PackageRepository], applies sort:
/// 1. Featured packages (isFeatured=true) appear first.
/// 2. Within each group, sort by displayOrder ascending.
///
/// **Arabic**
/// يجلب الباقات النشطة من المستودع ويُرتِّبها:
/// ١. الباقات المميزة أولاً، ثم حسب ترتيب العرض تصاعديًا.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final useCase = ListCategoryPackagesUseCase(packageRepository);
/// final result = await useCase(
///   clinicId: ClinicIds.andrology,
///   category: PackageCategory.andrologyInfertilityProstate,
/// );
/// ```
class ListCategoryPackagesUseCase {
  /// Creates the use case with an injected [PackageRepository].
  ///
  /// يُنشئ حالة الاستخدام مع مستودع الباقات المُحقَن.
  const ListCategoryPackagesUseCase(this._repo);

  final PackageRepository _repo;

  /// Executes the use case.
  ///
  /// **Parameters**:
  /// - [clinicId]: The owning clinic identifier — معرف العيادة.
  /// - [category]: The package category to filter by — فئة الباقة.
  ///
  /// **Returns**:
  /// - `Right(List<PackageEntity>)` sorted featured-first on success.
  /// - `Left(Failure)` on repository or network error.
  ///
  /// الإجراء: يُعيد الباقات مُرتَّبة (المميزة أولاً، ثم displayOrder).
  Future<Either<Failure, List<PackageEntity>>> call({
    required String clinicId,
    required PackageCategory category,
  }) async {
    final result = await _repo.listCategoryPackages(
      clinicId: clinicId,
      category: category,
    );

    return result.map(_sortPackages);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Sorts packages: featured first, then by displayOrder ascending.
  ///
  /// فرز الباقات: المميزة أولاً، ثم ترتيب العرض تصاعديًا.
  List<PackageEntity> _sortPackages(List<PackageEntity> packages) {
    final sorted = List<PackageEntity>.from(packages)
      ..sort((a, b) {
        // Featured packages come first
        if (a.isFeatured && !b.isFeatured) return -1;
        if (!a.isFeatured && b.isFeatured) return 1;
        // Within each group, sort by displayOrder ascending
        return a.displayOrder.compareTo(b.displayOrder);
      });
    return sorted;
  }
}
