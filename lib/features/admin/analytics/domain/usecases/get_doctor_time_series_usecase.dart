import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب بيانات السلاسل الزمنية لطبيب واحد.
@lazySingleton
class GetDoctorTimeSeriesUseCase {
  const GetDoctorTimeSeriesUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, TimeSeriesResult>> call({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String granularity,
  }) => _repository.getDoctorTimeSeries(
    doctorId: doctorId,
    periodStart: periodStart,
    periodEnd: periodEnd,
    granularity: granularity,
  );
}
