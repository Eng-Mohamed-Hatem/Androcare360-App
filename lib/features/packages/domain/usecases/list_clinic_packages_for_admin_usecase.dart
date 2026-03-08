import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/auth/clinic_access_resolver.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/domain/failures/package_failures.dart';
import 'package:elajtech/features/packages/domain/repositories/package_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for listing clinic packages for admin.
class ListClinicPackagesForAdminParams {
  const ListClinicPackagesForAdminParams({
    required this.clinicId,
    this.category,
    this.status,
    this.isFeatured,
    this.lastDocument,
    this.limit = 20,
  });
  final String clinicId;
  final PackageCategory? category;
  final PackageStatus? status;
  final bool? isFeatured;
  final DocumentSnapshot? lastDocument;
  final int limit;
}

/// Use case for listing packages in a clinic for admins.
///
/// **English**: Retrieves a paginated list of all packages.
/// Validates access using [ClinicAccessResolver].
/// Implements local filtering since composite indexes for all these
/// arbitrary combinations would be excessive.
///
/// **Arabic**: استرجاع قائمة باقات العيادة للإدارة مع فلاتر.
@lazySingleton
class ListClinicPackagesForAdminUseCase {
  ListClinicPackagesForAdminUseCase(this._accessResolver);

  final ClinicAccessResolver _accessResolver;

  Future<Either<Failure, List<PackageEntity>>> call({
    required PackageRepository repository,
    required ListClinicPackagesForAdminParams params,
  }) async {
    // 1. Check access
    final canAccess = await _accessResolver.canAccessClinic(params.clinicId);
    if (!canAccess) {
      return const Left(
        ClinicUnavailableFailure('ليس لديك صلاحية لعرض باقات هذه العيادة.'),
      );
    }

    // 2. Fetch from repository
    final resultOr = await repository.listClinicPackagesForAdmin(
      clinicId: params.clinicId,
      lastDocument: params.lastDocument,
      limit: params.limit * 3, // over-fetch to allow local filtering
    );

    return resultOr.map((packages) {
      // 3. Apply optional filters locally
      // Since Firestore doesn't easily support arbitrary combination of equality filters
      // without defining 2^N composite indexes, we filter in memory for admin dashboard.
      var filtered = packages;
      if (params.category != null) {
        filtered = filtered
            .where((p) => p.category == params.category)
            .toList();
      }
      if (params.status != null) {
        filtered = filtered.where((p) => p.status == params.status).toList();
      }
      if (params.isFeatured != null) {
        filtered = filtered
            .where((p) => p.isFeatured == params.isFeatured)
            .toList();
      }
      return filtered.take(params.limit).toList();
    });
  }
}
