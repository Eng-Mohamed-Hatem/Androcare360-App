import 'package:elajtech/features/admin/analytics/domain/usecases/record_payout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('delegates payout recording to repository', () async {
    final repository = FakePayoutExportRepository();
    final useCase = RecordPayoutUseCase(repository);

    final result = await useCase(
      doctorId: 'doctor-1',
      amount: 120,
      note: 'bank transfer',
    );

    expect(result.isRight(), isTrue);
    expect(repository.recordCalls, 1);
    expect(repository.lastRecordedAmount, 120);
    expect(repository.lastRecordedNote, 'bank transfer');
  });
}
