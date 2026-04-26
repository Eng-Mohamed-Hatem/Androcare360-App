import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_performance_score_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns redistributed performance score from doctor detail', () async {
    final detail = testDoctor().copyWith(
      performanceScore: const PerformanceScore(
        totalScore: 91.7,
        completionRateScore: 25,
        patientRatingScore: 22.5,
        punctualityScore: 21.25,
        emrSpeedScore: 0,
        hasIncompleteData: true,
        missingDimensions: ['emrSpeed'],
      ),
    );
    final repository = FakeAnalyticsRepository(detail: detail);
    final useCase = GetPerformanceScoreUseCase(repository);
    final period = testPeriod();

    final result = await useCase(
      doctorId: 'doctor-1',
      periodStart: period.start,
      periodEnd: period.end,
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('expected score'),
      (score) {
        expect(score.hasIncompleteData, isTrue);
        expect(score.missingDimensions, contains('emrSpeed'));
        expect(score.totalScore, 91.7);
      },
    );
  });
}
