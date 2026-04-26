import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctor_time_series_usecase.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeSeriesChartWidget extends StatefulWidget {
  const TimeSeriesChartWidget({
    required this.doctorId,
    required this.periodStart,
    required this.periodEnd,
    this.useCase,
    super.key,
  });

  final String doctorId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final GetDoctorTimeSeriesUseCase? useCase;

  @override
  State<TimeSeriesChartWidget> createState() => _TimeSeriesChartWidgetState();
}

class _TimeSeriesChartWidgetState extends State<TimeSeriesChartWidget> {
  GetDoctorTimeSeriesUseCase? _useCase;
  late Future<TimeSeriesResult> _future;
  String _granularity = 'monthly';

  @override
  void initState() {
    super.initState();
    _useCase =
        widget.useCase ??
        (getIt.isRegistered<GetDoctorTimeSeriesUseCase>()
            ? getIt<GetDoctorTimeSeriesUseCase>()
            : null);
    _future = _load();
  }

  Future<TimeSeriesResult> _load() async {
    final useCase = _useCase;
    if (useCase == null) {
      return TimeSeriesResult(
        granularity: _granularity,
        dataPoints: const [],
        hasComparison: false,
      );
    }

    final result = await useCase(
      doctorId: widget.doctorId,
      periodStart: widget.periodStart,
      periodEnd: widget.periodEnd,
      granularity: _granularity,
    );
    return result.fold(
      (failure) => throw _ChartException(failure),
      (data) => data,
    );
  }

  void _selectGranularity(String value) {
    setState(() {
      _granularity = value;
      _future = _load();
    });
  }

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
                Expanded(
                  child: Text(
                    'اتجاه الأداء',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'daily', label: Text('يومي')),
                    ButtonSegment(value: 'weekly', label: Text('أسبوعي')),
                    ButtonSegment(value: 'monthly', label: Text('شهري')),
                  ],
                  selected: {_granularity},
                  onSelectionChanged: (value) =>
                      _selectGranularity(value.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<TimeSeriesResult>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _ChartMessage(
                    text: snapshot.error is _ChartException
                        ? (snapshot.error! as _ChartException).message
                        : 'تعذر تحميل المخطط',
                  );
                }
                final data = snapshot.data;
                if (data == null || data.dataPoints.isEmpty) {
                  return const _ChartMessage(
                    text: 'لا تتوفر بيانات كافية للمخطط',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 220, child: _Chart(data: data)),
                    const SizedBox(height: 12),
                    _ComparisonBadge(data: data),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.data});

  final TimeSeriesResult data;

  @override
  Widget build(BuildContext context) {
    final points = data.dataPoints;
    final maxY = points
        .map((point) => point.appointments.toDouble())
        .fold<double>(1, (max, value) => value > max ? value : max);

    if (points.length == 1 ||
        (data.granularity == 'monthly' && points.length == 1)) {
      return BarChart(
        BarChartData(
          maxY: maxY + 1,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: points.first.appointments.toDouble(),
                  width: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY + 1,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].appointments.toDouble()),
            ],
            isCurved: points.length >= 3,
            barWidth: 3,
            dotData: FlDotData(
              show: points.length < 3 || points.any((p) => p.isMarker),
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _ComparisonBadge extends StatelessWidget {
  const _ComparisonBadge({required this.data});

  final TimeSeriesResult data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasComparison || data.appointmentsChangePercent == null) {
      return const Text('لا تتوفر بيانات كافية للمقارنة');
    }
    final value = data.appointmentsChangePercent!;
    final positive = value >= 0;
    return Chip(
      label: Text('${positive ? '↑' : '↓'} ${value.abs().toStringAsFixed(1)}%'),
      labelStyle: TextStyle(
        color: positive ? Colors.green.shade800 : Colors.red.shade800,
      ),
      backgroundColor: positive ? Colors.green.shade50 : Colors.red.shade50,
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Center(child: Text(text, textAlign: TextAlign.center)),
  );
}

class _ChartException implements Exception {
  const _ChartException(this.failure);

  final Failure failure;

  String get message => failure.when(
    firestore: (message) => message,
    network: (message) => message,
    agora: (message) => message,
    voip: (message) => message,
    app: (message) => message,
    unexpected: (message) => message,
  );
}
