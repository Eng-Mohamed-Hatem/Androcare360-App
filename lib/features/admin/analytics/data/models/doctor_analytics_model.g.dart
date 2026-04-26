// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoctorAnalyticsModel _$DoctorAnalyticsModelFromJson(
  Map<String, dynamic> json,
) => _DoctorAnalyticsModel(
  doctorId: json['doctorId'] as String,
  doctorName: json['doctorName'] as String,
  specialty: json['specialty'] as String,
  isActive: json['isActive'] as bool,
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  completedAppointments: (json['completedAppointments'] as num).toInt(),
  cancelledAppointments: (json['cancelledAppointments'] as num).toInt(),
  noShowAppointments: (json['noShowAppointments'] as num).toInt(),
  completionRate: (json['completionRate'] as num).toDouble(),
  financialSummary: FinancialSummaryModel.fromJson(
    json['financialSummary'] as Map<String, dynamic>,
  ),
  pendingPayout: (json['pendingPayout'] as num).toDouble(),
  payoutStatus: json['payoutStatus'] as String,
  performanceTotalScore: (json['performanceTotalScore'] as num).toDouble(),
  completionRateScore: (json['completionRateScore'] as num?)?.toDouble() ?? 0,
  patientRatingScore: (json['patientRatingScore'] as num?)?.toDouble() ?? 0,
  punctualityScore: (json['punctualityScore'] as num?)?.toDouble() ?? 0,
  emrSpeedScore: (json['emrSpeedScore'] as num?)?.toDouble() ?? 0,
  hasIncompleteData: json['hasIncompleteData'] as bool? ?? true,
  missingDimensions:
      (json['missingDimensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['emrSpeed'],
  isOverviewScore: json['isOverviewScore'] as bool? ?? true,
  profileImage: json['profileImage'] as String?,
  averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble(),
  patientRetentionRate: (json['patientRetentionRate'] as num?)?.toDouble(),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$DoctorAnalyticsModelToJson(
  _DoctorAnalyticsModel instance,
) => <String, dynamic>{
  'doctorId': instance.doctorId,
  'doctorName': instance.doctorName,
  'specialty': instance.specialty,
  'isActive': instance.isActive,
  'totalAppointments': instance.totalAppointments,
  'completedAppointments': instance.completedAppointments,
  'cancelledAppointments': instance.cancelledAppointments,
  'noShowAppointments': instance.noShowAppointments,
  'completionRate': instance.completionRate,
  'financialSummary': instance.financialSummary,
  'pendingPayout': instance.pendingPayout,
  'payoutStatus': instance.payoutStatus,
  'performanceTotalScore': instance.performanceTotalScore,
  'completionRateScore': instance.completionRateScore,
  'patientRatingScore': instance.patientRatingScore,
  'punctualityScore': instance.punctualityScore,
  'emrSpeedScore': instance.emrSpeedScore,
  'hasIncompleteData': instance.hasIncompleteData,
  'missingDimensions': instance.missingDimensions,
  'isOverviewScore': instance.isOverviewScore,
  'profileImage': instance.profileImage,
  'averageResponseTime': instance.averageResponseTime,
  'patientRetentionRate': instance.patientRetentionRate,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
