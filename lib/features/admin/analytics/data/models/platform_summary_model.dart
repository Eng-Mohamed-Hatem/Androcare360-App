import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_summary_model.freezed.dart';
part 'platform_summary_model.g.dart';

/// Data model for the four platform summary cards.
@freezed
abstract class PlatformSummaryModel with _$PlatformSummaryModel {
  const factory PlatformSummaryModel({
    required int totalCompletedAppointments,
    required double totalRevenue,
    required double totalPendingPayouts,
    required double averagePerformanceScore,
    required int activeDoctorsCount,
  }) = _PlatformSummaryModel;

  const PlatformSummaryModel._();

  factory PlatformSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformSummaryModelFromJson(json);

  PlatformSummary toDomain(AnalyticsDateRange period) => PlatformSummary(
    totalCompletedAppointments: totalCompletedAppointments,
    totalRevenue: totalRevenue,
    totalPendingPayouts: totalPendingPayouts,
    averagePerformanceScore: averagePerformanceScore,
    activeDoctorsCount: activeDoctorsCount,
    period: period,
  );
}
