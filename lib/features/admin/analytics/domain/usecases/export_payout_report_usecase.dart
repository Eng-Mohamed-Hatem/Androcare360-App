import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/payout_report.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/payout_export_repository.dart';
import 'package:injectable/injectable.dart';

/// حالة استخدام تصدير تقرير المستحقات — fetches report data + generates file.
/// Returns the saved file path on success.
@lazySingleton
class ExportPayoutReportUseCase {
  const ExportPayoutReportUseCase(this._repository);

  final PayoutExportRepository _repository;

  /// Fetches report data from CF, then generates a PDF or Excel file.
  /// [format] must be 'pdf' or 'excel'.
  Future<Either<Failure, String>> call({
    required String doctorId,
    required int year,
    required int month,
    required String format,
  }) async {
    final reportResult = await _repository.getPayoutReportData(
      doctorId: doctorId,
      year: year,
      month: month,
    );

    return reportResult.fold(
      Left.new,
      (report) {
        if (report.entries.isEmpty) {
          return Future.value(
            const Left(Failure.app('لا توجد بيانات لهذه الفترة')),
          );
        }
        return format == 'excel'
            ? _repository.generateExcel(report)
            : _repository.generatePdf(report);
      },
    );
  }

  /// Fetches raw [PayoutReport] data without generating a file.
  Future<Either<Failure, PayoutReport>> fetchReport({
    required String doctorId,
    required int year,
    required int month,
  }) => _repository.getPayoutReportData(
    doctorId: doctorId,
    year: year,
    month: month,
  );
}
