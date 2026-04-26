import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_score_model.freezed.dart';
part 'performance_score_model.g.dart';

/// Data model for full/detail performance score values returned by analytics CFs.
@freezed
abstract class PerformanceScoreModel with _$PerformanceScoreModel {
  const factory PerformanceScoreModel({
    required double totalScore,
    required double completionRateScore,
    required double patientRatingScore,
    required double punctualityScore,
    required double emrSpeedScore,
    required bool hasIncompleteData,
    @Default([]) List<String> missingDimensions,
    @Default(false) bool isOverviewScore,
  }) = _PerformanceScoreModel;

  const PerformanceScoreModel._();

  factory PerformanceScoreModel.fromJson(Map<String, dynamic> json) =>
      _$PerformanceScoreModelFromJson(json);

  factory PerformanceScoreModel.fromDetailJson(
    Map<String, dynamic> json,
  ) => PerformanceScoreModel(
    totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0,
    completionRateScore: (json['completionRateScore'] as num?)?.toDouble() ?? 0,
    patientRatingScore: (json['patientRatingScore'] as num?)?.toDouble() ?? 0,
    punctualityScore: (json['punctualityScore'] as num?)?.toDouble() ?? 0,
    emrSpeedScore: (json['emrSpeedScore'] as num?)?.toDouble() ?? 0,
    hasIncompleteData: json['hasIncompleteData'] as bool? ?? false,
    missingDimensions:
        (json['missingDimensions'] as List<dynamic>?)
            ?.map((value) => value.toString())
            .toList() ??
        const [],
    isOverviewScore: json['isOverviewScore'] as bool? ?? false,
  );

  PerformanceScore toDomain() => PerformanceScore(
    totalScore: totalScore,
    completionRateScore: completionRateScore,
    patientRatingScore: patientRatingScore,
    punctualityScore: punctualityScore,
    emrSpeedScore: emrSpeedScore,
    hasIncompleteData: hasIncompleteData,
    missingDimensions: missingDimensions,
    isOverviewScore: isOverviewScore,
  );
}
