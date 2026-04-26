import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزوّد فلاتر التحليلات — manages period/specialty/status/search filter state.
final filtersProvider = StateNotifierProvider<FiltersNotifier, FiltersState>(
  (ref) => FiltersNotifier(),
);

/// Converts [FiltersState] to the `periodStart` / `periodEnd` DateTimes used
/// in CF requests. All boundaries are UTC.
(DateTime start, DateTime end) periodBounds(FiltersState filters) {
  final now = DateTime.now().toUtc();
  switch (filters.period) {
    case AnalyticsPeriod.day:
      final start = DateTime.utc(now.year, now.month, now.day);
      final end = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
      return (start, end);
    case AnalyticsPeriod.week:
      final start = now.subtract(const Duration(days: 7));
      return (start, now);
    case AnalyticsPeriod.month:
      final start = DateTime.utc(now.year, now.month);
      return (start, now);
    case AnalyticsPeriod.custom:
      final start =
          filters.customStart?.toUtc() ?? DateTime.utc(now.year, now.month);
      final end = filters.customEnd?.toUtc() ?? now;
      return (start, end);
  }
}

class FiltersNotifier extends StateNotifier<FiltersState> {
  FiltersNotifier() : super(const FiltersState());

  void setPeriod(AnalyticsPeriod period) => state = state.copyWith(
    period: period,
    customStart: null,
    customEnd: null,
  );

  void setCustomRange(DateTime start, DateTime end) => state = state.copyWith(
    period: AnalyticsPeriod.custom,
    customStart: start,
    customEnd: end,
  );

  void setSpecialtyFilter(String? specialty) =>
      state = state.copyWith(specialtyFilter: specialty);

  void setStatusFilter(String status) =>
      state = state.copyWith(statusFilter: status);

  void setSearchQuery(String? query) => state = state.copyWith(
    searchQuery: (query?.trim().isEmpty ?? false) ? null : query?.trim(),
  );

  void clearFilters() => state = const FiltersState();
}
