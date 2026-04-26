// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformSummaryModel _$PlatformSummaryModelFromJson(
  Map<String, dynamic> json,
) => _PlatformSummaryModel(
  totalCompletedAppointments: (json['totalCompletedAppointments'] as num)
      .toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalPendingPayouts: (json['totalPendingPayouts'] as num).toDouble(),
  averagePerformanceScore: (json['averagePerformanceScore'] as num).toDouble(),
  activeDoctorsCount: (json['activeDoctorsCount'] as num).toInt(),
);

Map<String, dynamic> _$PlatformSummaryModelToJson(
  _PlatformSummaryModel instance,
) => <String, dynamic>{
  'totalCompletedAppointments': instance.totalCompletedAppointments,
  'totalRevenue': instance.totalRevenue,
  'totalPendingPayouts': instance.totalPendingPayouts,
  'averagePerformanceScore': instance.averagePerformanceScore,
  'activeDoctorsCount': instance.activeDoctorsCount,
};
