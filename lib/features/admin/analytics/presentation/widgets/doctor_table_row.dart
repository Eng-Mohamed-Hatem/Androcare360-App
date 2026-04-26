import 'dart:async';

import 'package:elajtech/features/admin/analytics/domain/entities/doctor_analytics.dart';
import 'package:elajtech/features/admin/analytics/presentation/screens/doctor_analytics_detail_screen.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorTableRow extends StatelessWidget {
  const DoctorTableRow({required this.doctor, super.key});

  final DoctorAnalytics doctor;

  @override
  Widget build(BuildContext context) {
    final muted = !doctor.isActive;
    final amountFormat = NumberFormat.currency(
      locale: 'ar',
      symbol: 'ر.س ',
      decimalDigits: 2,
    );

    return Opacity(
      opacity: muted ? 0.62 : 1,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              if (compact) {
                return _CompactRow(
                  doctor: doctor,
                  amountFormat: amountFormat,
                  onDetails: () => _openDetails(context),
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _DoctorCell(doctor: doctor)),
                  Expanded(
                    child: Text(
                      '${doctor.completedAppointments}/${doctor.totalAppointments}',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      amountFormat.format(doctor.financialSummary.totalRevenue),
                    ),
                  ),
                  Expanded(
                    child: _ScoreCell(
                      score: doctor.performanceScore.totalScore,
                    ),
                  ),
                  Expanded(
                    child: Text(amountFormat.format(doctor.pendingPayout)),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _openDetails(context),
                        child: const Text('عرض التفاصيل'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DoctorAnalyticsDetailScreen(
            doctorId: doctor.doctorId,
            doctorName: doctor.doctorName,
            periodStart: doctor.period.start,
            periodEnd: doctor.period.end,
          ),
        ),
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.doctor,
    required this.amountFormat,
    required this.onDetails,
  });

  final DoctorAnalytics doctor;
  final NumberFormat amountFormat;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorCell(doctor: doctor),
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            Text(
              'الحجوزات: ${doctor.completedAppointments}/${doctor.totalAppointments}',
            ),
            Text(
              'الإيرادات: ${amountFormat.format(doctor.financialSummary.totalRevenue)}',
            ),
            Text('المستحق: ${amountFormat.format(doctor.pendingPayout)}'),
            _ScoreCell(score: doctor.performanceScore.totalScore),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onDetails,
            child: const Text('عرض التفاصيل'),
          ),
        ),
      ],
    );
  }
}

class _DoctorCell extends StatelessWidget {
  const _DoctorCell({required this.doctor});

  final DoctorAnalytics doctor;

  @override
  Widget build(BuildContext context) {
    final specialty =
        ClinicTypes.arabicLabels[doctor.specialty] ?? doctor.specialty;
    return Row(
      children: [
        CircleAvatar(
          child: Text(doctor.doctorName.isEmpty ? '?' : doctor.doctorName[0]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      doctor.doctorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (!doctor.isActive) ...[
                    const SizedBox(width: 8),
                    const _InactiveBadge(),
                  ],
                ],
              ),
              Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Text(
      score.toStringAsFixed(1),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _InactiveBadge extends StatelessWidget {
  const _InactiveBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text('غير نشط', style: TextStyle(fontSize: 11)),
      ),
    );
  }
}
