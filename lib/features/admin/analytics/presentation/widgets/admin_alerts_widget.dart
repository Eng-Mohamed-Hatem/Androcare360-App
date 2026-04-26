import 'package:elajtech/features/admin/analytics/domain/entities/admin_alert.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/alerts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAlertsWidget extends ConsumerWidget {
  const AdminAlertsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertsProvider);
    final notifier = ref.read(alertsProvider.notifier);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'التنبيهات الذكية',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (state.unreadCount > 0)
                  Badge(label: Text(state.unreadCount.toString())),
                IconButton(
                  onPressed: state.isLoading ? null : notifier.load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (state.hasStaleData)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('قد لا تكون البيانات محدثة'),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (state.alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('لا توجد تنبيهات نشطة'),
              )
            else
              ...state.alerts.map(
                (alert) => _AlertTile(
                  alert: alert,
                  onAcknowledge: () => notifier.acknowledge(alert.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onAcknowledge});

  final AdminAlert alert;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Chip(label: Text(_labelForType(alert.type))),
      title: Text(alert.title),
      subtitle: Text(
        '${alert.doctorName}\n${alert.message}\n${alert.triggerValue} / ${alert.threshold}',
      ),
      isThreeLine: true,
      trailing: alert.isRead
          ? const Text('تمت القراءة')
          : TextButton(
              onPressed: onAcknowledge,
              child: const Text('تم القراءة'),
            ),
    );
  }

  String _labelForType(AlertType type) {
    switch (type) {
      case AlertType.performance:
        return 'أداء';
      case AlertType.activity:
        return 'نشاط';
      case AlertType.financial:
        return 'مالي';
    }
  }
}
