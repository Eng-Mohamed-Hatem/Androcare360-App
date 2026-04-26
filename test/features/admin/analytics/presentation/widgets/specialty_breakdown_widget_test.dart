import 'package:elajtech/features/admin/analytics/presentation/widgets/specialty_breakdown_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders chart and legend with data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SpecialtyBreakdownWidget(
              breakdown: testSpecialtyBreakdown(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('توزيع نوع الخدمة'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.textContaining('استشارة فيديو'), findsOneWidget);
    expect(find.textContaining('زيارة عيادية'), findsOneWidget);
    expect(find.text('6 (60.0%)'), findsOneWidget);
  });

  testWidgets('renders zero-data state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SpecialtyBreakdownWidget(breakdown: []),
          ),
        ),
      ),
    );

    expect(find.text('لا توجد بيانات لتوزيع نوع الخدمة'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
  });
}
