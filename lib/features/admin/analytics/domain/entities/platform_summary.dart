import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';

part 'platform_summary.freezed.dart';

/// ملخص إحصائيات المنصة — Platform-wide summary for the overview cards row.
@freezed
abstract class PlatformSummary with _$PlatformSummary {
  const factory PlatformSummary({
    /// إجمالي المواعيد المكتملة في الفترة
    required int totalCompletedAppointments,

    /// إجمالي الإيرادات (SAR)
    required double totalRevenue,

    /// إجمالي المستحقات المعلقة (SAR)
    required double totalPendingPayouts,

    /// متوسط نقطة الأداء عبر الأطباء النشطين
    required double averagePerformanceScore,

    /// عدد الأطباء النشطين (isActive=true, userType=doctor)
    required int activeDoctorsCount,

    /// الفترة الزمنية لهذا الملخص
    required AnalyticsDateRange period,
  }) = _PlatformSummary;
}
