import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';

part 'payout_report.freezed.dart';

/// سطر واحد في تقرير المستحقات — one financially-eligible appointment row.
@freezed
abstract class PayoutEntry with _$PayoutEntry {
  const factory PayoutEntry({
    required String appointmentId,
    required String patientName,
    required DateTime appointmentDate,
    required String status,
    required double fee,
    required double commission,
    required double netAmount,
  }) = _PayoutEntry;
}

/// تقرير مستحقات شهري للطبيب — monthly payout report exported as PDF/Excel.
@freezed
abstract class PayoutReport with _$PayoutReport {
  const factory PayoutReport({
    // ── required ───────────────────────────────────────────────────────────
    required String doctorId,
    required String doctorName,
    required String specialty,
    required AnalyticsDateRange period,
    required List<PayoutEntry> entries,
    required double totalRevenue,
    required double totalCommission,
    required double totalNetPayout,
    required DateTime generatedAt,
  }) = _PayoutReport;
}
