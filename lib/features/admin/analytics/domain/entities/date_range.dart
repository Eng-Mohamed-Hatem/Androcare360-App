import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_range.freezed.dart';

/// نطاق زمني مستخدم في فلاتر التحليلات
/// Immutable date range value object used across all analytics queries.
@freezed
abstract class AnalyticsDateRange with _$AnalyticsDateRange {
  const factory AnalyticsDateRange({
    /// Period start (inclusive, UTC)
    required DateTime start,

    /// Period end (inclusive, UTC, >= start)
    required DateTime end,
  }) = _AnalyticsDateRange;
}

/// فترة التحليل المحددة مسبقاً
enum AnalyticsPeriod {
  /// اليوم الحالي
  day,

  /// الأسبوع الحالي (آخر 7 أيام)
  week,

  /// الشهر الحالي
  month,

  /// نطاق مخصص يحدده المستخدم
  custom,
}

/// حالة صرف مستحقات الطبيب
enum PayoutStatus {
  /// تم صرف جميع المستحقات
  paid,

  /// المستحقات في انتظار الصرف
  pending,

  /// تم صرف جزء من المستحقات
  partial,
}

/// نوع التنبيه الإداري
enum AlertType {
  /// تجاوز المستحقات للحد المحدد
  financial,

  /// انخفاض معدل إتمام المواعيد
  performance,

  /// عدم نشاط الطبيب لفترة طويلة
  activity,
}
