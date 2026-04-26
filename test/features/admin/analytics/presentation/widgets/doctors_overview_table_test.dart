import 'dart:async';

import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctors_overview_usecase.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_platform_summary_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/analytics_provider.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/state.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/doctors_overview_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  testWidgets('renders doctors and inactive badge', (tester) async {
    final repository = FakeAnalyticsRepository(
      doctors: [
        testDoctor(),
        testDoctor(id: 'inactive', name: 'د. ليلى', isActive: false),
      ],
    );
    final period = testPeriod();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWith((ref) {
            final notifier = AnalyticsNotifier(
              GetPlatformSummaryUseCase(repository),
              GetDoctorsOverviewUseCase(repository),
              AnalyticsFilters(
                periodStart: period.start,
                periodEnd: period.end,
                sortBy: 'name',
                sortOrder: 'asc',
              ),
            );
            unawaited(notifier.refresh());
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: DoctorsOverviewTable()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('د. أحمد'), findsOneWidget);
    expect(find.text('د. ليلى'), findsOneWidget);
    expect(find.text('غير نشط'), findsOneWidget);
  });

  testWidgets('sort header triggers refetch', (tester) async {
    final repository = FakeAnalyticsRepository(
      doctors: [
        testDoctor(name: 'د. أ', revenue: 300),
        testDoctor(id: 'b', name: 'د. ب', revenue: 100),
      ],
    );
    final period = testPeriod();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWith((ref) {
            final notifier = AnalyticsNotifier(
              GetPlatformSummaryUseCase(repository),
              GetDoctorsOverviewUseCase(repository),
              AnalyticsFilters(
                periodStart: period.start,
                periodEnd: period.end,
                sortBy: 'name',
                sortOrder: 'asc',
              ),
            );
            unawaited(notifier.refresh());
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(width: 900, child: DoctorsOverviewTable()),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final callsBefore = repository.overviewCalls;
    await tester.tap(find.text('الإيرادات'));
    await tester.pumpAndSettle();

    expect(repository.overviewCalls, callsBefore + 1);
  });
}
