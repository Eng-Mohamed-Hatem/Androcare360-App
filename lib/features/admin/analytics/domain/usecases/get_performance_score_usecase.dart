import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب نقطة الأداء الكاملة من تفاصيل الطبيب.
@lazySingleton
class GetPerformanceScoreUseCase {
  const GetPerformanceScoreUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, PerformanceScore>> call({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final result = await _repository.getDoctorDetail(
      doctorId: doctorId,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    return result.map((detail) => detail.performanceScore);
  }
}
