import 'package:dartz/dartz.dart';

import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/payout_report.dart';

/// واجهة مستودع تصدير المستحقات — Payout export repository interface.
/// Implemented by PayoutExportRepositoryImpl.
abstract class PayoutExportRepository {
  /// يجلب بيانات تقرير المستحقات من Cloud Function exportPayoutReport
  Future<Either<Failure, PayoutReport>> getPayoutReportData({
    required String doctorId,
    required int year,
    required int month,
  });

  /// ينشئ ملف PDF من تقرير المستحقات — returns saved file path
  Future<Either<Failure, String>> generatePdf(PayoutReport report);

  /// ينشئ ملف Excel من تقرير المستحقات — returns saved file path
  Future<Either<Failure, String>> generateExcel(PayoutReport report);

  /// يسجّل عملية صرف مستحقات طبيب (admin-only)
  Future<Either<Failure, Unit>> recordPayout({
    required String doctorId,
    required double amount,
    String? note,
  });
}
