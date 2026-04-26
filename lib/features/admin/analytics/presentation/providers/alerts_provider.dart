import 'dart:async';

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_admin_alerts_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((
  ref,
) {
  final notifier = AlertsNotifier(getIt<GetAdminAlertsUseCase>());
  unawaited(notifier.load());
  return notifier;
});

class AlertsNotifier extends StateNotifier<AlertsState> {
  AlertsNotifier(this._getAlerts) : super(const AlertsState());

  final GetAdminAlertsUseCase _getAlerts;

  Future<void> load({bool includeRead = false}) async {
    final hadCachedData = state.alerts.isNotEmpty;
    state = state.copyWith(isLoading: true, error: null, hasStaleData: false);
    final result = await _getAlerts(includeRead: includeRead);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _messageForFailure(failure),
        hasStaleData: hadCachedData,
      ),
      (alerts) => state = state.copyWith(
        isLoading: false,
        alerts: alerts,
        unreadCount: alerts.where((alert) => !alert.isRead).length,
        hasStaleData: false,
      ),
    );
  }

  Future<void> acknowledge(String alertId) async {
    final result = await _getAlerts.acknowledge(alertId);
    result.fold(
      (failure) => state = state.copyWith(error: _messageForFailure(failure)),
      (_) {
        final updated = state.alerts
            .map(
              (alert) =>
                  alert.id == alertId ? alert.copyWith(isRead: true) : alert,
            )
            .toList();
        state = state.copyWith(
          alerts: updated,
          unreadCount: updated.where((alert) => !alert.isRead).length,
        );
      },
    );
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
