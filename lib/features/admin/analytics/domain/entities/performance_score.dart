import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_score.freezed.dart';

/// نقطة أداء الطبيب — Composite performance score (0–100).
/// Each dimension contributes up to 25 points; weights redistributed
/// proportionally when a dimension lacks sufficient data (FR-008).
@freezed
abstract class PerformanceScore with _$PerformanceScore {
  const factory PerformanceScore({
    /// المجموع الكلي للنقاط (0–100)
    required double totalScore,

    /// نقاط معدل إتمام المواعيد (0–25)
    required double completionRateScore,

    /// نقاط تقييم المرضى بناءً على DoctorModel.rating (0–25)
    required double patientRatingScore,

    /// نقاط الالتزام بالمواعيد (0–25)
    required double punctualityScore,

    /// نقاط سرعة إنشاء التقارير الطبية (0–25)
    required double emrSpeedScore,

    /// هل تفتقر بعض الأبعاد إلى بيانات كافية؟
    required bool hasIncompleteData,

    /// أسماء الأبعاد التي تفتقر إلى البيانات
    @Default([]) List<String> missingDimensions,

    /// true = نقطة تقريبية من 3 أبعاد فقط (نظرة عامة)
    /// false = نقطة كاملة من 4 أبعاد (تفاصيل الطبيب)
    @Default(false) bool isOverviewScore,
  }) = _PerformanceScore;
}
