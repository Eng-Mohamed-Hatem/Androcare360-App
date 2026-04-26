import 'package:elajtech/features/admin/analytics/domain/usecases/get_patient_retention_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('returns patient retention from repository', () async {
    final repository = FakeAnalyticsRepository(
      retention: testPatientRetention(
        rate: 0.3,
        totalUniquePatients: 10,
        returningPatients: 3,
      ),
    );
    final useCase = GetPatientRetentionUseCase(repository);

    final result = await useCase(doctorId: 'doctor-1');

    expect(result.isRight(), isTrue);
    expect(repository.retentionCalls, 1);
    result.fold(
      (_) => fail('expected retention'),
      (retention) {
        expect(retention.retentionRate, 0.3);
        expect(retention.totalUniquePatients, 10);
        expect(retention.returningPatients, 3);
        expect(retention.hasSufficientData, isTrue);
      },
    );
  });

  test('supports insufficient data edge case', () async {
    final repository = FakeAnalyticsRepository(
      retention: testPatientRetention(
        rate: 0,
        totalUniquePatients: 3,
        returningPatients: 0,
        hasSufficientData: false,
      ),
    );
    final useCase = GetPatientRetentionUseCase(repository);

    final result = await useCase(doctorId: 'doctor-1');

    result.fold(
      (_) => fail('expected retention'),
      (retention) {
        expect(retention.hasSufficientData, isFalse);
        expect(retention.retentionRate, 0);
      },
    );
  });
}
