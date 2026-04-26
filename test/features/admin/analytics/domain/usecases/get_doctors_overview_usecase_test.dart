import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctors_overview_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns paginated doctors overview from repository', () async {
    final repository = FakeAnalyticsRepository(
      doctors: [
        testDoctor(id: 'doctor-2'),
        testDoctor(),
      ],
    );
    final useCase = GetDoctorsOverviewUseCase(repository);
    final period = testPeriod();

    final result = await useCase(
      periodStart: period.start,
      periodEnd: period.end,
      sortBy: 'name',
      sortOrder: 'asc',
      pageSize: 20,
    );

    expect(result.isRight(), isTrue);
    expect(repository.overviewCalls, 1);
    result.fold(
      (_) => fail('expected doctors'),
      (page) => expect(page.doctors, hasLength(2)),
    );
  });
}
