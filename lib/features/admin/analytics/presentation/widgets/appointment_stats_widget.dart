import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:flutter/material.dart';

class AppointmentStatsWidget extends StatelessWidget {
  const AppointmentStatsWidget({required this.analytics, super.key});

  final DoctorAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final completion = (analytics.completionRate * 100).toStringAsFixed(1);
    final response = analytics.averageResponseTime == null
        ? 'غير متوفر'
        : '${analytics.averageResponseTime!.toStringAsFixed(1)} دقيقة';

    return _SectionCard(
      title: 'إحصائيات الحجوزات',
      icon: Icons.event_available_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusBadge(
                label: 'مكتملة',
                value: analytics.completedAppointments,
                color: Colors.green,
              ),
              _StatusBadge(
                label: 'ملغاة',
                value: analytics.cancelledAppointments,
                color: Colors.orange,
              ),
              _StatusBadge(
                label: 'فائتة',
                value: analytics.noShowAppointments,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricLine(label: 'معدل الإتمام', value: '$completion%'),
          _MetricLine(label: 'متوسط وقت الاستجابة', value: response),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
