import 'package:elajtech/features/admin/analytics/presentation/widgets/summary_cards_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders four summary cards with data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SummaryCardsRow(
              summary: testSummary(),
              isLoading: false,
              error: null,
              onRetry: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('إجمالي الحجوزات المكتملة'), findsOneWidget);
    expect(find.text('إجمالي الإيرادات (SAR)'), findsOneWidget);
    expect(find.text('متوسط نقطة الأداء'), findsOneWidget);
    expect(find.text('المستحقات المعلقة'), findsOneWidget);
  });

  testWidgets('renders loading placeholders when summary is absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SummaryCardsRow(
              summary: null,
              isLoading: true,
              error: null,
              onRetry: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('إجمالي الحجوزات المكتملة'), findsOneWidget);
  });
}
