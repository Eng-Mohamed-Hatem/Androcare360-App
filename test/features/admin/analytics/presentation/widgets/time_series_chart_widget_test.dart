import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctor_time_series_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/time_series_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders line chart and comparison badge', (tester) async {
    final period = testPeriod();
    final repository = FakeAnalyticsRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: TimeSeriesChartWidget(
              doctorId: 'doctor-1',
              periodStart: period.start,
              periodEnd: period.end,
              useCase: GetDoctorTimeSeriesUseCase(repository),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اتجاه الأداء'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('↑ 12.5%'), findsOneWidget);
  });

  testWidgets('renders no-data state when series is empty', (tester) async {
    final period = testPeriod();

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: TimeSeriesChartWidget(
              doctorId: 'doctor-1',
              periodStart: period.start,
              periodEnd: period.end,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا تتوفر بيانات كافية للمخطط'), findsOneWidget);
  });
}
