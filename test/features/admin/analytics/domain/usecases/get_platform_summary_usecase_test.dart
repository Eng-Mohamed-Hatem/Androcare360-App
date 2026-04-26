import 'package:elajtech/features/admin/analytics/domain/usecases/get_platform_summary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns platform summary from repository', () async {
    final repository = FakeAnalyticsRepository();
    final useCase = GetPlatformSummaryUseCase(repository);
    final period = testPeriod();

    final result = await useCase(
      periodStart: period.start,
      periodEnd: period.end,
      specialtyFilter: 'chronic_diseases',
    );

    expect(result.isRight(), isTrue);
    expect(repository.summaryCalls, 1);
    result.fold(
      (_) => fail('expected summary'),
      (summary) => expect(summary.totalRevenue, 1200),
    );
  });
}
