import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_summary.freezed.dart';

/// ملخص مالي للطبيب — Financial summary for a doctor within a period.
/// All amounts in SAR, rounded to 2 decimal places.
@freezed
abstract class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    /// إجمالي الإيرادات (المواعيد المكتملة فقط ذات الرسوم > 0)
    required double totalRevenue,

    /// عمولة المنصة = totalRevenue × commissionRate
    required double platformCommission,

    /// صافي المستحق = totalRevenue − platformCommission
    required double netPayout,

    /// المبلغ المدفوع فعلياً للطبيب
    required double paidAmount,

    /// المبلغ في انتظار الصرف
    required double pendingAmount,

    /// نسبة عمولة المنصة (من platform_settings/commission.rate)
    required double commissionRate,
  }) = _FinancialSummary;
}
