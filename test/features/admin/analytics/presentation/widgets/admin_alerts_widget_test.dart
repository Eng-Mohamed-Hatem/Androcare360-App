import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_admin_alerts_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/admin_alerts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders alert card by type and acknowledges it', (tester) async {
    final repository = FakeAnalyticsRepository();
    getIt.registerSingleton<GetAdminAlertsUseCase>(
      GetAdminAlertsUseCase(repository),
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: AdminAlertsWidget()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('التنبيهات الذكية'), findsOneWidget);
    expect(find.text('مالي'), findsOneWidget);
    expect(find.text('مستحقات مرتفعة'), findsOneWidget);
    expect(find.text('تم القراءة'), findsOneWidget);

    await tester.tap(find.text('تم القراءة'));
    await tester.pumpAndSettle();

    expect(repository.acknowledgeCalls, 1);
    expect(repository.acknowledgedAlertId, 'alert-1');
  });
}
