import 'package:elajtech/features/admin/analytics/domain/usecases/get_specialty_breakdown_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns specialty breakdown from repository', () async {
    final repository = FakeAnalyticsRepository();
    final useCase = GetSpecialtyBreakdownUseCase(repository);
    final period = testPeriod();

    final result = await useCase(
      doctorId: 'doctor-1',
      periodStart: period.start,
      periodEnd: period.end,
    );

    expect(result.isRight(), isTrue);
    expect(repository.specialtyBreakdownCalls, 1);
    result.fold(
      (_) => fail('expected specialty breakdown'),
      (breakdown) {
        expect(breakdown, hasLength(2));
        expect(breakdown.first.type, 'video');
        expect(breakdown.first.percentage, 60);
      },
    );
  });

  test('forwards optional clinic type filter', () async {
    final repository = FakeAnalyticsRepository();
    final useCase = GetSpecialtyBreakdownUseCase(repository);
    final period = testPeriod();

    await useCase(
      doctorId: 'doctor-1',
      periodStart: period.start,
      periodEnd: period.end,
      clinicType: 'chronic_diseases',
    );

    expect(repository.specialtyBreakdownCalls, 1);
    expect(repository.lastSpecialtyClinicType, 'chronic_diseases');
  });
}
