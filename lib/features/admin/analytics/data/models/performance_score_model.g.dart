// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerformanceScoreModel _$PerformanceScoreModelFromJson(
  Map<String, dynamic> json,
) => _PerformanceScoreModel(
  totalScore: (json['totalScore'] as num).toDouble(),
  completionRateScore: (json['completionRateScore'] as num).toDouble(),
  patientRatingScore: (json['patientRatingScore'] as num).toDouble(),
  punctualityScore: (json['punctualityScore'] as num).toDouble(),
  emrSpeedScore: (json['emrSpeedScore'] as num).toDouble(),
  hasIncompleteData: json['hasIncompleteData'] as bool,
  missingDimensions:
      (json['missingDimensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isOverviewScore: json['isOverviewScore'] as bool? ?? false,
);

Map<String, dynamic> _$PerformanceScoreModelToJson(
  _PerformanceScoreModel instance,
) => <String, dynamic>{
  'totalScore': instance.totalScore,
  'completionRateScore': instance.completionRateScore,
  'patientRatingScore': instance.patientRatingScore,
  'punctualityScore': instance.punctualityScore,
  'emrSpeedScore': instance.emrSpeedScore,
  'hasIncompleteData': instance.hasIncompleteData,
  'missingDimensions': instance.missingDimensions,
  'isOverviewScore': instance.isOverviewScore,
};
