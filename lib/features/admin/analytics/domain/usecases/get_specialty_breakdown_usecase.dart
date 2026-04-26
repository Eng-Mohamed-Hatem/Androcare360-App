import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب توزيع حجوزات الطبيب حسب نوع الخدمة والتخصص.
@lazySingleton
class GetSpecialtyBreakdownUseCase {
  const GetSpecialtyBreakdownUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, List<SpecialtyBreakdown>>> call({
    required String doctorId,
    required DateTime periodStart,
    required DateTime periodEnd,
    String? clinicType,
  }) => _repository.getSpecialtyBreakdown(
    doctorId: doctorId,
    periodStart: periodStart,
    periodEnd: periodEnd,
    clinicType: clinicType,
  );
}
