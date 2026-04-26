import 'package:elajtech/features/admin/analytics/domain/entities/financial_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_summary_model.freezed.dart';
part 'financial_summary_model.g.dart';

/// Data model for doctor financial summary values returned by analytics CFs.
@freezed
abstract class FinancialSummaryModel with _$FinancialSummaryModel {
  const factory FinancialSummaryModel({
    required double totalRevenue,
    required double platformCommission,
    required double netPayout,
    required double paidAmount,
    required double pendingAmount,
    required double commissionRate,
  }) = _FinancialSummaryModel;

  const FinancialSummaryModel._();

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryModelFromJson(json);

  /// Parses flattened financial fields from `getDoctorsOverview`.
  factory FinancialSummaryModel.fromOverviewJson(Map<String, dynamic> json) {
    final totalRevenue = (json['totalRevenue'] as num?)?.toDouble() ?? 0;
    final platformCommission =
        (json['platformCommission'] as num?)?.toDouble() ?? 0;
    final netPayout = (json['netPayout'] as num?)?.toDouble() ?? 0;
    final pendingPayout = (json['pendingPayout'] as num?)?.toDouble() ?? 0;
    final paidAmount =
        (json['paidAmount'] as num?)?.toDouble() ??
        (netPayout - pendingPayout).clamp(0, double.infinity).toDouble();

    return FinancialSummaryModel(
      totalRevenue: totalRevenue,
      platformCommission: platformCommission,
      netPayout: netPayout,
      paidAmount: paidAmount,
      pendingAmount: pendingPayout,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.15,
    );
  }

  /// Parses nested financial summary fields from detail responses.
  factory FinancialSummaryModel.fromDetailJson(Map<String, dynamic> json) =>
      FinancialSummaryModel.fromJson(json);

  FinancialSummary toDomain() => FinancialSummary(
    totalRevenue: totalRevenue,
    platformCommission: platformCommission,
    netPayout: netPayout,
    paidAmount: paidAmount,
    pendingAmount: pendingAmount,
    commissionRate: commissionRate,
  );
}
