import 'dart:async';

import 'package:elajtech/features/admin/analytics/presentation/providers/analytics_provider.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/admin_alerts_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/doctors_overview_table.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/filters_bar.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/summary_cards_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsTabScreen extends ConsumerWidget {
  const AnalyticsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إحصائيات الأطباء')),
        body: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.hasStaleData) ...[
                const _StaleDataBanner(),
                const SizedBox(height: 12),
              ],
              const AdminAlertsWidget(),
              const SizedBox(height: 16),
              SummaryCardsRow(
                summary: state.platformSummary,
                isLoading: state.isLoading,
                error: state.error,
                onRetry: () => unawaited(notifier.refresh()),
              ),
              const SizedBox(height: 16),
              const FiltersBar(),
              const SizedBox(height: 16),
              const DoctorsOverviewTable(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaleDataBanner extends StatelessWidget {
  const _StaleDataBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('قد لا تكون البيانات محدثة')),
          ],
        ),
      ),
    );
  }
}
