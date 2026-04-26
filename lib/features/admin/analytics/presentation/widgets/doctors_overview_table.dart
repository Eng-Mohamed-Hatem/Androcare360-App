import 'dart:async';

import 'package:elajtech/features/admin/analytics/presentation/providers/analytics_provider.dart';
import 'package:elajtech/features/admin/analytics/presentation/widgets/doctor_table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorsOverviewTable extends ConsumerWidget {
  const DoctorsOverviewTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    if (state.error != null && state.doctors.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(state.error!)),
              TextButton(
                onPressed: () => unawaited(notifier.refresh()),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading && state.doctors.isEmpty) {
      return const _LoadingTable();
    }

    if (state.doctors.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Center(child: Text('لا يوجد أطباء مسجلين')),
        ),
      );
    }

    return Column(
      children: [
        _HeaderRow(
          sortBy: state.filters.sortBy,
          sortOrder: state.filters.sortOrder,
          onSort: (field) => unawaited(notifier.sortBy(field)),
        ),
        ...state.doctors.map((doctor) => DoctorTableRow(doctor: doctor)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: state.hasMore && !state.isLoading
                  ? () => unawaited(notifier.loadMore())
                  : null,
              icon: state.isLoading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: const Text('تحميل المزيد'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.sortBy,
    required this.sortOrder,
    required this.onSort,
  });

  final String sortBy;
  final String sortOrder;
  final ValueChanged<String> onSort;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return Row(
                children: [
                  Expanded(child: _SortButton('الطبيب', 'name', this)),
                  _SortButton('الأداء', 'performanceScore', this),
                ],
              );
            }
            return Row(
              children: [
                Expanded(flex: 3, child: _SortButton('الطبيب', 'name', this)),
                Expanded(child: _SortButton('الحجوزات', 'appointments', this)),
                Expanded(child: _SortButton('الإيرادات', 'revenue', this)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SortButton(
                          'نقطة الأداء*',
                          'performanceScore',
                          this,
                        ),
                      ),
                      const Tooltip(
                        message:
                            '* تقريبية (3 أبعاد) - افتح التفاصيل للنقطة الكاملة بـ 4 أبعاد',
                        child: Icon(Icons.info_outline, size: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _SortButton('المستحق', 'pendingPayout', this)),
                const Expanded(child: Text('الإجراءات')),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton(this.label, this.field, this.header);

  final String label;
  final String field;
  final _HeaderRow header;

  @override
  Widget build(BuildContext context) {
    final active = header.sortBy == field;
    final icon = header.sortOrder == 'asc'
        ? Icons.arrow_upward
        : Icons.arrow_downward;
    return InkWell(
      onTap: () => header.onSort(field),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (active) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 14),
          ],
        ],
      ),
    );
  }
}

class _LoadingTable extends StatelessWidget {
  const _LoadingTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
