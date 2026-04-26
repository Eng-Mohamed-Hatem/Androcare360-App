import 'package:elajtech/features/admin/analytics/data/models/financial_summary_model.dart';
import 'package:elajtech/features/admin/analytics/data/models/performance_score_model.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_analytics_model.freezed.dart';
part 'doctor_analytics_model.g.dart';

/// Data model for one doctor row in the overview table.
@freezed
abstract class DoctorAnalyticsModel with _$DoctorAnalyticsModel {
  const factory DoctorAnalyticsModel({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required bool isActive,
    required int totalAppointments,
    required int completedAppointments,
    required int cancelledAppointments,
    required int noShowAppointments,
    required double completionRate,
    required FinancialSummaryModel financialSummary,
    required double pendingPayout,
    required String payoutStatus,
    required double performanceTotalScore,
    @Default(0) double completionRateScore,
    @Default(0) double patientRatingScore,
    @Default(0) double punctualityScore,
    @Default(0) double emrSpeedScore,
    @Default(true) bool hasIncompleteData,
    @Default(['emrSpeed']) List<String> missingDimensions,
    @Default(true) bool isOverviewScore,
    String? profileImage,
    double? averageResponseTime,
    double? patientRetentionRate,
    DateTime? lastLoginAt,
  }) = _DoctorAnalyticsModel;

  const DoctorAnalyticsModel._();

  factory DoctorAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorAnalyticsModelFromJson(json);

  /// Parses flattened fields from the `getDoctorsOverview` callable response.
  factory DoctorAnalyticsModel.fromOverviewJson(Map<String, dynamic> json) {
    final performance = Map<String, dynamic>.from(
      (json['performanceScore'] as Map?) ?? const <String, dynamic>{},
    );

    return DoctorAnalyticsModel(
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      specialty: json['specialty'] as String? ?? 'General',
      isActive: json['isActive'] as bool? ?? true,
      totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
      completedAppointments:
          (json['completedAppointments'] as num?)?.toInt() ?? 0,
      cancelledAppointments:
          (json['cancelledAppointments'] as num?)?.toInt() ?? 0,
      noShowAppointments: (json['noShowAppointments'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      financialSummary: FinancialSummaryModel.fromOverviewJson(json),
      pendingPayout: (json['pendingPayout'] as num?)?.toDouble() ?? 0,
      payoutStatus: json['payoutStatus'] as String? ?? 'pending',
      performanceTotalScore:
          (performance['totalScore'] as num?)?.toDouble() ??
          (json['performanceTotalScore'] as num?)?.toDouble() ??
          0,
      completionRateScore:
          (performance['completionRateScore'] as num?)?.toDouble() ?? 0,
      patientRatingScore:
          (performance['patientRatingScore'] as num?)?.toDouble() ?? 0,
      punctualityScore:
          (performance['punctualityScore'] as num?)?.toDouble() ?? 0,
      emrSpeedScore: (performance['emrSpeedScore'] as num?)?.toDouble() ?? 0,
      hasIncompleteData: performance['hasIncompleteData'] as bool? ?? true,
      missingDimensions:
          (performance['missingDimensions'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const ['emrSpeed'],
      isOverviewScore: performance['isOverviewScore'] as bool? ?? true,
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble(),
      patientRetentionRate: (json['patientRetentionRate'] as num?)?.toDouble(),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
    );
  }

  /// Parses nested fields from the `getDoctorAnalyticsDetail` callable response.
  factory DoctorAnalyticsModel.fromDetailJson(Map<String, dynamic> json) {
    final doctor = Map<String, dynamic>.from(
      (json['doctor'] as Map?) ?? const <String, dynamic>{},
    );
    final stats = Map<String, dynamic>.from(
      (json['appointmentStats'] as Map?) ?? const <String, dynamic>{},
    );
    final financial = Map<String, dynamic>.from(
      (json['financialSummary'] as Map?) ?? const <String, dynamic>{},
    );
    final score = PerformanceScoreModel.fromDetailJson(
      Map<String, dynamic>.from(
        (json['performanceScore'] as Map?) ?? const <String, dynamic>{},
      ),
    );
    final retention = Map<String, dynamic>.from(
      (json['patientRetention'] as Map?) ?? const <String, dynamic>{},
    );

    final financialModel = FinancialSummaryModel.fromDetailJson(financial);
    final paidAmount = financialModel.paidAmount;
    final payoutStatus =
        paidAmount >= financialModel.netPayout && financialModel.netPayout > 0
        ? 'paid'
        : paidAmount > 0
        ? 'partial'
        : 'pending';

    return DoctorAnalyticsModel(
      doctorId: doctor['doctorId'] as String? ?? '',
      doctorName: doctor['doctorName'] as String? ?? '',
      profileImage: doctor['profileImage'] as String?,
      specialty: doctor['specialty'] as String? ?? 'General',
      isActive: doctor['isActive'] as bool? ?? true,
      totalAppointments: (stats['total'] as num?)?.toInt() ?? 0,
      completedAppointments: (stats['completed'] as num?)?.toInt() ?? 0,
      cancelledAppointments: (stats['cancelled'] as num?)?.toInt() ?? 0,
      noShowAppointments: (stats['noShow'] as num?)?.toInt() ?? 0,
      completionRate: (stats['completionRate'] as num?)?.toDouble() ?? 0,
      averageResponseTime: (stats['averageResponseTimeMinutes'] as num?)
          ?.toDouble(),
      financialSummary: financialModel,
      pendingPayout: financialModel.pendingAmount,
      payoutStatus: payoutStatus,
      performanceTotalScore: score.totalScore,
      completionRateScore: score.completionRateScore,
      patientRatingScore: score.patientRatingScore,
      punctualityScore: score.punctualityScore,
      emrSpeedScore: score.emrSpeedScore,
      hasIncompleteData: score.hasIncompleteData,
      missingDimensions: score.missingDimensions,
      isOverviewScore: score.isOverviewScore,
      patientRetentionRate: (retention['retentionRate'] as num?)?.toDouble(),
      lastLoginAt: _parseDateTime(doctor['lastLoginAt']),
    );
  }

  DoctorAnalytics toDomain(AnalyticsDateRange period) {
    return DoctorAnalytics(
      doctorId: doctorId,
      doctorName: doctorName,
      profileImage: profileImage,
      specialty: specialty,
      isActive: isActive,
      totalAppointments: totalAppointments,
      completedAppointments: completedAppointments,
      cancelledAppointments: cancelledAppointments,
      noShowAppointments: noShowAppointments,
      completionRate: completionRate,
      averageResponseTime: averageResponseTime,
      financialSummary: financialSummary.toDomain(),
      performanceScore: PerformanceScore(
        totalScore: performanceTotalScore,
        completionRateScore: completionRateScore,
        patientRatingScore: patientRatingScore,
        punctualityScore: punctualityScore,
        emrSpeedScore: emrSpeedScore,
        hasIncompleteData: hasIncompleteData,
        missingDimensions: missingDimensions,
        isOverviewScore: isOverviewScore,
      ),
      pendingPayout: pendingPayout,
      payoutStatus: _parsePayoutStatus(payoutStatus),
      patientRetentionRate: patientRetentionRate,
      lastLoginAt: lastLoginAt,
      period: period,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }

  static PayoutStatus _parsePayoutStatus(String? status) {
    switch (status) {
      case 'paid':
        return PayoutStatus.paid;
      case 'partial':
        return PayoutStatus.partial;
      default:
        return PayoutStatus.pending;
    }
  }
}
