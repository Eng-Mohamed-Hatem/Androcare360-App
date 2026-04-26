import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب قائمة الأطباء المرقّمة مع فلترة وفرز — paginated doctors overview table.
@lazySingleton
class GetDoctorsOverviewUseCase {
  const GetDoctorsOverviewUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, DoctorsOverviewResult>> call({
    required DateTime periodStart,
    required DateTime periodEnd,
    required String sortBy,
    required String sortOrder,
    required int pageSize,
    String? specialtyFilter,
    String? statusFilter,
    String? searchQuery,
    String? cursor,
  }) => _repository.getDoctorsOverview(
    periodStart: periodStart,
    periodEnd: periodEnd,
    sortBy: sortBy,
    sortOrder: sortOrder,
    pageSize: pageSize,
    specialtyFilter: specialtyFilter,
    statusFilter: statusFilter,
    searchQuery: searchQuery,
    cursor: cursor,
  );
}
