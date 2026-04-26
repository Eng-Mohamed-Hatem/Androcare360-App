import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/financial_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';

part 'doctor_analytics.freezed.dart';

/// إحصائيات طبيب واحد — per-doctor analytics row (overview table + detail screen).
@freezed
abstract class DoctorAnalytics with _$DoctorAnalytics {
  const factory DoctorAnalytics({
    // ── required fields ────────────────────────────────────────────────────
    required String doctorId,
    required String doctorName,
    required String specialty,
    required bool isActive,
    required int totalAppointments,
    required int completedAppointments,
    required int cancelledAppointments,
    required int noShowAppointments,
    required double completionRate,
    required FinancialSummary financialSummary,
    required PerformanceScore performanceScore,
    required double pendingPayout,
    required AnalyticsDateRange period,

    // ── optional / defaulted fields ────────────────────────────────────────
    String? profileImage,
    double? averageResponseTime,
    double? patientRetentionRate,
    DateTime? lastLoginAt,
    @Default(PayoutStatus.pending) PayoutStatus payoutStatus,
  }) = _DoctorAnalytics;
}
