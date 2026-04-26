import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctor_analytics_detail_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns doctor analytics detail from repository', () async {
    final repository = FakeAnalyticsRepository(detail: testDoctor(score: 88));
    final useCase = GetDoctorAnalyticsDetailUseCase(repository);
    final period = testPeriod();

    final result = await useCase(
      doctorId: 'doctor-1',
      periodStart: period.start,
      periodEnd: period.end,
    );

    expect(result.isRight(), isTrue);
    expect(repository.detailCalls, 1);
    result.fold(
      (_) => fail('expected doctor detail'),
      (detail) => expect(detail.performanceScore.totalScore, 88),
    );
  });
}
