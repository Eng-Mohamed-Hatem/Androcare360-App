import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يحسب معدل احتفاظ المرضى لطبيب واحد.
@lazySingleton
class GetPatientRetentionUseCase {
  const GetPatientRetentionUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, PatientRetention>> call({required String doctorId}) =>
      _repository.getPatientRetention(doctorId: doctorId);
}
