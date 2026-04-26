import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:injectable/injectable.dart';

/// يجلب التنبيهات الإدارية ويؤكد قراءتها.
@lazySingleton
class GetAdminAlertsUseCase {
  const GetAdminAlertsUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<Either<Failure, List<AdminAlert>>> call({
    bool includeRead = false,
    int limit = 50,
  }) => _repository.getAdminAlerts(includeRead: includeRead, limit: limit);

  Future<Either<Failure, Unit>> acknowledge(String alertId) =>
      _repository.acknowledgeAlert(alertId);
}
