import 'dart:async';

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/domain/repositories/analytics_repository.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_doctor_analytics_detail_usecase.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/get_specialty_breakdown_usecase.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/appointment_stats_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/financial_summary_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/patient_retention_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/performance_score_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/payout_export_button.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/specialty_breakdown_widget.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/time_series_chart_widget.dart';
import 'package:flutter/material.dart';

class DoctorAnalyticsDetailScreen extends StatefulWidget {
  const DoctorAnalyticsDetailScreen({
    required this.doctorId,
    required this.doctorName,
    required this.periodStart,
    required this.periodEnd,
    this.getDetailUseCase,
    this.getSpecialtyBreakdownUseCase,
    super.key,
  });

  final String doctorId;
  final String doctorName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final GetDoctorAnalyticsDetailUseCase? getDetailUseCase;
  final GetSpecialtyBreakdownUseCase? getSpecialtyBreakdownUseCase;

  @override
  State<DoctorAnalyticsDetailScreen> createState() =>
      _DoctorAnalyticsDetailScreenState();
}

class _DoctorAnalyticsDetailScreenState
    extends State<DoctorAnalyticsDetailScreen> {
  late final GetDoctorAnalyticsDetailUseCase _getDetail;
  late final GetSpecialtyBreakdownUseCase _getSpecialtyBreakdown;
  late Future<_DetailData> _future;

  @override
  void initState() {
    super.initState();
    _getDetail =
        widget.getDetailUseCase ?? getIt<GetDoctorAnalyticsDetailUseCase>();
    _getSpecialtyBreakdown =
        widget.getSpecialtyBreakdownUseCase ??
        getIt<GetSpecialtyBreakdownUseCase>();
    _future = _load();
  }

  Future<_DetailData> _load() async {
    final detailResult = await _getDetail(
      doctorId: widget.doctorId,
      periodStart: widget.periodStart,
      periodEnd: widget.periodEnd,
    );
    final analytics = detailResult.fold(
      (failure) => throw _DetailException(failure),
      (data) => data,
    );

    final breakdownResult = await _getSpecialtyBreakdown(
      doctorId: widget.doctorId,
      periodStart: widget.periodStart,
      periodEnd: widget.periodEnd,
    );
    final breakdown = breakdownResult.fold(
      (failure) => throw _DetailException(failure),
      (items) => items,
    );

    return _DetailData(analytics: analytics, specialtyBreakdown: breakdown);
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('تفاصيل ${widget.doctorName}')),
        body: FutureBuilder<_DetailData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final error = snapshot.error is _DetailException
                  ? (snapshot.error! as _DetailException).message
                  : 'تعذر تحميل تفاصيل الطبيب';
              return _ErrorState(message: error, onRetry: _retry);
            }
            final data = snapshot.data;
            final analytics = data?.analytics;
            if (analytics == null || analytics.totalAppointments == 0) {
              return _EmptyState(onRetry: _retry);
            }

            return RefreshIndicator(
              onRefresh: () async {
                _retry();
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DoctorHeader(analytics: analytics),
                  const SizedBox(height: 12),
                  AppointmentStatsWidget(analytics: analytics),
                  FinancialSummaryWidget(
                    summary: analytics.financialSummary,
                    doctorId: widget.doctorId,
                  ),
                  PerformanceScoreWidget(score: analytics.performanceScore),
                  TimeSeriesChartWidget(
                    doctorId: widget.doctorId,
                    periodStart: widget.periodStart,
                    periodEnd: widget.periodEnd,
                  ),
                  SpecialtyBreakdownWidget(
                    breakdown: data?.specialtyBreakdown ?? const [],
                  ),
                  PatientRetentionWidget(
                    retention: PatientRetention(
                      retentionRate: analytics.patientRetentionRate ?? 0,
                      totalUniquePatients: 0,
                      returningPatients: 0,
                      hasSufficientData: analytics.patientRetentionRate != null,
                    ),
                  ),
                  PayoutExportButton(doctorId: widget.doctorId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailData {
  const _DetailData({
    required this.analytics,
    required this.specialtyBreakdown,
  });

  final DoctorAnalytics analytics;
  final List<SpecialtyBreakdown> specialtyBreakdown;
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.analytics});

  final DoctorAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Text(
                analytics.doctorName.isEmpty ? '?' : analytics.doctorName[0],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analytics.doctorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(analytics.specialty),
                ],
              ),
            ),
            if (!analytics.isActive) const Chip(label: Text('غير نشط')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('لا توجد بيانات لهذا الطبيب في الفترة المحددة'),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('تحديث')),
          ],
        ),
      ),
    );
  }
}

class _DetailException implements Exception {
  const _DetailException(this.failure);

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
