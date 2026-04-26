import 'package:elajtech/features/admin/analytics/domain/entities/performance_score.dart';
import 'package:flutter/material.dart';

class PerformanceScoreWidget extends StatelessWidget {
  const PerformanceScoreWidget({required this.score, super.key});

  final PerformanceScore score;

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
                const Icon(Icons.speed_outlined),
                const SizedBox(width: 8),
                Text(
                  'نقطة الأداء',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: score.totalScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: ' /100',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ScoreBar(label: 'معدل الإتمام', value: score.completionRateScore),
            _ScoreBar(label: 'تقييم المرضى', value: score.patientRatingScore),
            _ScoreBar(
              label: 'الالتزام بالمواعيد',
              value: score.punctualityScore,
            ),
            _ScoreBar(label: 'سرعة التقارير', value: score.emrSpeedScore),
            if (score.hasIncompleteData) ...[
              const SizedBox(height: 12),
              _IncompleteDataNotice(missingDimensions: score.missingDimensions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 25).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('${value.toStringAsFixed(1)} /25'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: clamped / 25),
        ],
      ),
    );
  }
}

class _IncompleteDataNotice extends StatelessWidget {
  const _IncompleteDataNotice({required this.missingDimensions});

  final List<String> missingDimensions;

  @override
  Widget build(BuildContext context) {
    final labels = missingDimensions.map(_dimensionLabel).join('، ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                labels.isEmpty
                    ? 'بيانات غير كافية لبعض أبعاد الأداء.'
                    : 'بيانات غير كافية: $labels',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dimensionLabel(String value) => switch (value) {
    'completionRate' => 'معدل الإتمام',
    'patientRating' => 'تقييم المرضى',
    'punctuality' => 'الالتزام بالمواعيد',
    'emrSpeed' => 'سرعة التقارير',
    _ => value,
  };
}
