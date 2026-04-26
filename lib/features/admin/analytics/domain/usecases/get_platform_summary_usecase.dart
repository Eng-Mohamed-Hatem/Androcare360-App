import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب ملخص إحصائيات المنصة — fetches platform-wide summary for the 4 cards.
@lazySingleton
class GetPlatformSummaryUseCase {
  const GetPlatformSummaryUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, PlatformSummary>> call({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? specialtyFilter,
  }) => _repository.getPlatformSummary(
    periodStart: periodStart,
    periodEnd: periodEnd,
    specialtyFilter: specialtyFilter,
  );
}
