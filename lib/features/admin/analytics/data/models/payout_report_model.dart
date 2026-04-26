import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/payout_report.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_report_model.freezed.dart';
part 'payout_report_model.g.dart';

/// نموذج بيانات سطر مستحقات — data layer model for a single payout entry.
@freezed
abstract class PayoutEntryModel with _$PayoutEntryModel {
  const factory PayoutEntryModel({
    required String appointmentId,
    required String patientName,
    required String appointmentDate,
    required String status,
    required double fee,
    required double commission,
    required double netAmount,
  }) = _PayoutEntryModel;

  const PayoutEntryModel._();

  factory PayoutEntryModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutEntryModelFromJson(json);

  PayoutEntry toDomain() => PayoutEntry(
    appointmentId: appointmentId,
    patientName: patientName,
    appointmentDate: DateTime.parse(appointmentDate),
    status: status,
    fee: fee,
    commission: commission,
    netAmount: netAmount,
  );
}

/// نموذج بيانات تقرير المستحقات الشهري — data layer model for a monthly payout report.
@freezed
abstract class PayoutReportModel with _$PayoutReportModel {
  const factory PayoutReportModel({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required Map<String, String> period,
    required List<PayoutEntryModel> entries,
    required double totalRevenue,
    required double totalCommission,
    required double totalNetPayout,
    required String generatedAt,
  }) = _PayoutReportModel;

  const PayoutReportModel._();

  factory PayoutReportModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutReportModelFromJson(json);

  /// Parses the raw CF response map for [PayoutReportModel].
  factory PayoutReportModel.fromCfResponse(Map<String, dynamic> data) {
    final periodRaw = data['period'] as Map? ?? {};
    final entriesRaw = data['entries'] as List<dynamic>? ?? [];
    return PayoutReportModel(
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      period: {
        'start': periodRaw['start']?.toString() ?? '',
        'end': periodRaw['end']?.toString() ?? '',
      },
      entries: entriesRaw
          .map(
            (e) => PayoutEntryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalCommission: (data['totalCommission'] as num?)?.toDouble() ?? 0,
      totalNetPayout: (data['totalNetPayout'] as num?)?.toDouble() ?? 0,
      generatedAt:
          data['generatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  PayoutReport toDomain() {
    final start = DateTime.parse(period['start']!);
    final end = DateTime.parse(period['end']!);
    return PayoutReport(
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      period: AnalyticsDateRange(start: start, end: end),
      entries: entries.map((e) => e.toDomain()).toList(),
      totalRevenue: totalRevenue,
      totalCommission: totalCommission,
      totalNetPayout: totalNetPayout,
      generatedAt: DateTime.parse(generatedAt),
    );
  }
}
