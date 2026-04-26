import 'package:elajtech/features/admin/analytics/domain/usecases/export_payout_report_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/payout_export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('exports payout report and shows success message', (
    tester,
  ) async {
    final repository = FakePayoutExportRepository(
      delay: const Duration(milliseconds: 50),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PayoutExportButton(
              doctorId: 'doctor-1',
              exportUseCase: ExportPayoutReportUseCase(repository),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('export_button')));
    await tester.pump();
    expect(find.text('جارٍ التصدير...'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(repository.pdfCalls, 1);
    expect(find.textContaining('تم حفظ التقرير'), findsOneWidget);
  });

  testWidgets('shows no-data message for empty payout report', (tester) async {
    final repository = FakePayoutExportRepository(
      report: testPayoutReport(entries: const []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PayoutExportButton(
              doctorId: 'doctor-1',
              exportUseCase: ExportPayoutReportUseCase(repository),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('export_button')));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بيانات لهذه الفترة'), findsOneWidget);
    expect(repository.pdfCalls, 0);
  });
}
