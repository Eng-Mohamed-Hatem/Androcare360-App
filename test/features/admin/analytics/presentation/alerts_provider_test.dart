import 'package:elajtech/features/admin/analytics/domain/usecases/get_admin_alerts_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/alerts_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../analytics_test_helpers.dart';

void main() {
  test('loads alerts and tracks unread count', () async {
    final repository = FakeAnalyticsRepository();
    final notifier = AlertsNotifier(GetAdminAlertsUseCase(repository));

    await notifier.load();

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.alerts, hasLength(1));
    expect(notifier.state.unreadCount, 1);
  });

  test('acknowledges alert and decrements unread count', () async {
    final repository = FakeAnalyticsRepository();
    final notifier = AlertsNotifier(GetAdminAlertsUseCase(repository));

    await notifier.load();
    await notifier.acknowledge('alert-1');

    expect(repository.acknowledgeCalls, 1);
    expect(notifier.state.alerts.first.isRead, isTrue);
    expect(notifier.state.unreadCount, 0);
  });
}
