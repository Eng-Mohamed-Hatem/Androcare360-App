import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';

part 'state.freezed.dart';

/// فلاتر نشطة لطلبات التحليلات — active query filters (immutable snapshot).
@freezed
abstract class AnalyticsFilters with _$AnalyticsFilters {
  const factory AnalyticsFilters({
    required DateTime periodStart,
    required DateTime periodEnd,
    required String sortBy,
    required String sortOrder,
    @Default('all') String statusFilter,
    String? specialtyFilter,
    String? searchQuery,
  }) = _AnalyticsFilters;
}

/// حالة قائمة الأطباء وملخص المنصة — analytics overview screen state.
@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    required AnalyticsFilters filters,
    @Default([]) List<DoctorAnalytics> doctors,
    @Default(false) bool isLoading,
    @Default(false) bool hasMore,
    @Default(false) bool hasStaleData,
    PlatformSummary? platformSummary,
    String? error,
    String? nextCursor,
  }) = _AnalyticsState;
}

/// حالة فلاتر الفترة الزمنية — period/specialty/status/search filter state.
@freezed
abstract class FiltersState with _$FiltersState {
  const factory FiltersState({
    @Default(AnalyticsPeriod.month) AnalyticsPeriod period,
    @Default('all') String statusFilter,
    DateTime? customStart,
    DateTime? customEnd,
    String? specialtyFilter,
    String? searchQuery,
  }) = _FiltersState;
}

/// حالة لوحة التنبيهات الإدارية — admin alerts panel state.
@freezed
abstract class AlertsState with _$AlertsState {
  const factory AlertsState({
    @Default([]) List<AdminAlert> alerts,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    @Default(false) bool hasStaleData,
    String? error,
  }) = _AlertsState;
}
