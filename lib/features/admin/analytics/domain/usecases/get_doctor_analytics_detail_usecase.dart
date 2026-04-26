import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب تفاصيل إحصائيات طبيب واحد — doctor detail analytics.
@lazySingleton
class GetDoctorAnalyticsDetailUseCase {
  const GetDoctorAnalyticsDetailUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, DoctorAnalytics>> call({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) => _repository.getDoctorDetail(
    doctorId: doctorId,
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
}
