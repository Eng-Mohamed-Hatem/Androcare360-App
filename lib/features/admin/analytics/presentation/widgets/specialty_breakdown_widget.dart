import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpecialtyBreakdownWidget extends StatelessWidget {
  const SpecialtyBreakdownWidget({required this.breakdown, super.key});

  final List<SpecialtyBreakdown> breakdown;

  @override
  Widget build(BuildContext context) {
    final total = breakdown.fold<int>(0, (sum, item) => sum + item.count);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline),
                const SizedBox(width: 8),
                Text(
                  'توزيع نوع الخدمة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const _EmptyBreakdown()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 420;
                  final chart = SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 36,
                        sectionsSpace: 3,
                        sections: _sections(context),
                      ),
                    ),
                  );
                  final legend = _Legend(breakdown: breakdown);

                  if (isNarrow) {
                    return Column(
                      children: [chart, const SizedBox(height: 12), legend],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 16),
                      Expanded(child: legend),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _sections(BuildContext context) {
    return breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final color = _colorFor(context, index);
      return PieChartSectionData(
        value: item.count.toDouble(),
        title: '${item.percentage.toStringAsFixed(1)}%',
        radius: 56,
        color: color,
        titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.breakdown});

  final List<SpecialtyBreakdown> breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: breakdown.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final label = _serviceTypeLabel(item.type);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _colorFor(context, index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('$label - ${item.clinicType}')),
              Text('${item.count} (${item.percentage.toStringAsFixed(1)}%)'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyBreakdown extends StatelessWidget {
  const _EmptyBreakdown();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text('لا توجد بيانات لتوزيع نوع الخدمة')),
    );
  }
}

String _serviceTypeLabel(String type) {
  switch (type) {
    case 'video':
      return 'استشارة فيديو';
    case 'clinic':
      return 'زيارة عيادية';
    default:
      return 'غير محدد';
  }
}

Color _colorFor(BuildContext context, int index) {
  final scheme = Theme.of(context).colorScheme;
  final colors = [
    scheme.primary,
    scheme.tertiary,
    scheme.secondary,
    scheme.error,
  ];
  return colors[index % colors.length];
}
