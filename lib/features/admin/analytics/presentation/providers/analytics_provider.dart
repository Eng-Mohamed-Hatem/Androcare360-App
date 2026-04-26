import 'dart:async';

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctors_overview_usecase.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_platform_summary_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/filters_provider.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pageSize = 20;

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
      final initialFilters = _filtersFromState(ref.read(filtersProvider));
      final notifier = AnalyticsNotifier(
        getIt<GetPlatformSummaryUseCase>(),
        getIt<GetDoctorsOverviewUseCase>(),
        initialFilters,
      );

      ref.listen<FiltersState>(filtersProvider, (_, next) {
        unawaited(notifier.applyFilters(_filtersFromState(next)));
      });

      unawaited(notifier.refresh());
      return notifier;
    });

AnalyticsFilters _filtersFromState(FiltersState filters) {
  final (start, end) = periodBounds(filters);
  return AnalyticsFilters(
    periodStart: start,
    periodEnd: end,
    sortBy: 'name',
    sortOrder: 'asc',
    specialtyFilter: filters.specialtyFilter,
    statusFilter: filters.statusFilter,
    searchQuery: filters.searchQuery,
  );
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(
    this._getPlatformSummary,
    this._getDoctorsOverview,
    AnalyticsFilters initialFilters,
  ) : super(AnalyticsState(filters: initialFilters));

  final GetPlatformSummaryUseCase _getPlatformSummary;
  final GetDoctorsOverviewUseCase _getDoctorsOverview;

  Future<void> refresh() async {
    final hadCachedData =
        state.platformSummary != null || state.doctors.isNotEmpty;
    state = state.copyWith(
      isLoading: true,
      error: null,
      nextCursor: null,
      hasStaleData: false,
    );

    final filters = state.filters;
    final summaryResult = await _getPlatformSummary(
      periodStart: filters.periodStart,
      periodEnd: filters.periodEnd,
      specialtyFilter: filters.specialtyFilter,
    );

    final doctorsResult = await _getDoctorsOverview(
      periodStart: filters.periodStart,
      periodEnd: filters.periodEnd,
      sortBy: filters.sortBy,
      sortOrder: filters.sortOrder,
      pageSize: _pageSize,
      specialtyFilter: filters.specialtyFilter,
      statusFilter: filters.statusFilter,
      searchQuery: filters.searchQuery,
    );

    summaryResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _messageForFailure(failure),
        hasStaleData: hadCachedData,
      ),
      (summary) => doctorsResult.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          platformSummary: summary,
          error: _messageForFailure(failure),
          hasStaleData: state.doctors.isNotEmpty,
        ),
        (result) => state = state.copyWith(
          isLoading: false,
          platformSummary: summary,
          doctors: result.doctors,
          hasMore: result.hasMore,
          nextCursor: result.nextCursor,
          hasStaleData: false,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (state.isLoading || !state.hasMore || cursor == null) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    final filters = state.filters;
    final result = await _getDoctorsOverview(
      periodStart: filters.periodStart,
      periodEnd: filters.periodEnd,
      sortBy: filters.sortBy,
      sortOrder: filters.sortOrder,
      pageSize: _pageSize,
      specialtyFilter: filters.specialtyFilter,
      statusFilter: filters.statusFilter,
      searchQuery: filters.searchQuery,
      cursor: cursor,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _messageForFailure(failure),
        hasStaleData: state.doctors.isNotEmpty,
      ),
      (page) => state = state.copyWith(
        isLoading: false,
        doctors: [...state.doctors, ...page.doctors],
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        hasStaleData: false,
      ),
    );
  }

  Future<void> applyFilters(AnalyticsFilters filters) async {
    state = state.copyWith(filters: filters, doctors: [], nextCursor: null);
    await refresh();
  }

  Future<void> sortBy(String field) async {
    final current = state.filters;
    final order = current.sortBy == field && current.sortOrder == 'asc'
        ? 'desc'
        : 'asc';
    state = state.copyWith(
      filters: current.copyWith(sortBy: field, sortOrder: order),
      doctors: [],
      nextCursor: null,
    );
    await refresh();
  }

  String _messageForFailure(Failure failure) => failure.when(
    firestore: (message) => message,
    network: (message) => message,
    agora: (message) => message,
    voip: (message) => message,
    app: (message) => message,
    unexpected: (message) => message,
  );
}
