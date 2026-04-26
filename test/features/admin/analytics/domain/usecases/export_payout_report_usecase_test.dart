import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/export_payout_report_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../analytics_test_helpers.dart';

void main() {
  test('fetches report data and generates PDF by default', () async {
    final repository = FakePayoutExportRepository();
    final useCase = ExportPayoutReportUseCase(repository);

    final result = await useCase(
      doctorId: 'doctor-1',
      year: 2026,
      month: 4,
      format: 'pdf',
    );

    expect(result.isRight(), isTrue);
    expect(repository.fetchCalls, 1);
    expect(repository.pdfCalls, 1);
    expect(repository.excelCalls, 0);
  });

  test('generates Excel when requested', () async {
    final repository = FakePayoutExportRepository();
    final useCase = ExportPayoutReportUseCase(repository);

    final result = await useCase(
      doctorId: 'doctor-1',
      year: 2026,
      month: 4,
      format: 'excel',
    );

    expect(result.isRight(), isTrue);
    expect(repository.excelCalls, 1);
    expect(repository.pdfCalls, 0);
  });

  test('returns no-data failure for empty report', () async {
    final repository = FakePayoutExportRepository(
      report: testPayoutReport(entries: const []),
    );
    final useCase = ExportPayoutReportUseCase(repository);

    final result = await useCase(
      doctorId: 'doctor-1',
      year: 2026,
      month: 4,
      format: 'pdf',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) =>
          expect(failure, const Failure.app('لا توجد بيانات لهذه الفترة')),
      (_) => fail('expected no-data failure'),
    );
    expect(repository.pdfCalls, 0);
  });
}
