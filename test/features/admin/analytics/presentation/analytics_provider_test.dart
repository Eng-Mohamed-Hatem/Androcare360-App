import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctors_overview_usecase.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_platform_summary_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/analytics_provider.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../analytics_test_helpers.dart';

void main() {
  test('refresh transitions from loading to loaded', () async {
    final repository = FakeAnalyticsRepository();
    final period = testPeriod();
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

    final states = <AnalyticsState>[];
    notifier.addListener(states.add, fireImmediately: false);

    await notifier.refresh();

    expect(states.first.isLoading, isTrue);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.platformSummary, isNotNull);
    expect(notifier.state.doctors, hasLength(1));
  });

  test('sort change refetches doctors with toggled order', () async {
    final repository = FakeAnalyticsRepository(
      doctors: [
        testDoctor(id: 'a', name: 'د. أ', revenue: 100),
        testDoctor(id: 'b', name: 'د. ب', revenue: 300),
      ],
    );
    final period = testPeriod();
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

    await notifier.sortBy('revenue');

    expect(notifier.state.filters.sortBy, 'revenue');
    expect(notifier.state.filters.sortOrder, 'asc');
    expect(notifier.state.doctors.first.financialSummary.totalRevenue, 100);
  });
}
