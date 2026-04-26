import 'package:elajtech/features/admin/analytics/domain/usecases/get_admin_alerts_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns unread admin alerts from repository', () async {
    final repository = FakeAnalyticsRepository();
    final useCase = GetAdminAlertsUseCase(repository);

    final result = await useCase();

    expect(result.isRight(), isTrue);
    expect(repository.alertsCalls, 1);
    result.fold(
      (_) => fail('expected alerts'),
      (alerts) {
        expect(alerts, hasLength(1));
        expect(alerts.first.id, 'alert-1');
      },
    );
  });

  test('acknowledges alert through repository', () async {
    final repository = FakeAnalyticsRepository();
    final useCase = GetAdminAlertsUseCase(repository);

    final result = await useCase.acknowledge('alert-1');

    expect(result.isRight(), isTrue);
    expect(repository.acknowledgeCalls, 1);
    expect(repository.acknowledgedAlertId, 'alert-1');
  });
}
