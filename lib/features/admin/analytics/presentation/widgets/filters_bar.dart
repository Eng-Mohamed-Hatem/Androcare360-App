import 'package:elajtech/features/admin/analytics/domain/entities/date_range.dart';
import 'package:elajtech/features/admin/analytics/presentation/providers/filters_provider.dart';
import 'package:elajtech/shared/constants/clinic_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiltersBar extends ConsumerWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    final notifier = ref.read(filtersProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Dropdown<AnalyticsPeriod>(
              label: 'الفترة',
              value: filters.period,
              items: const {
                AnalyticsPeriod.day: 'اليوم',
                AnalyticsPeriod.week: 'آخر 7 أيام',
                AnalyticsPeriod.month: 'الشهر الحالي',
                AnalyticsPeriod.custom: 'مخصص',
              },
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                if (value == AnalyticsPeriod.custom) {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.utc(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    initialDateRange: DateTimeRange(
                      start: filters.customStart ?? DateTime.now(),
                      end: filters.customEnd ?? DateTime.now(),
                    ),
                  );
                  if (range != null) {
                    notifier.setCustomRange(range.start, range.end);
                  }
                  return;
                }
                notifier.setPeriod(value);
              },
            ),
            _Dropdown<String>(
              label: 'التخصص',
              value: filters.specialtyFilter ?? 'all',
              items: {
                'all': 'كل التخصصات',
                for (final value in ClinicTypes.values)
                  value: ClinicTypes.arabicLabel(value),
              },
              onChanged: (value) => notifier.setSpecialtyFilter(
                value == null || value == 'all' ? null : value,
              ),
            ),
            _Dropdown<String>(
              label: 'الحالة',
              value: filters.statusFilter,
              items: const {
                'all': 'الكل',
                'active': 'نشط',
                'inactive': 'غير نشط',
              },
              onChanged: (value) => notifier.setStatusFilter(value ?? 'all'),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                key: const ValueKey('analytics-search-field'),
                decoration: const InputDecoration(
                  labelText: 'بحث باسم الطبيب',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: notifier.setSearchQuery,
              ),
            ),
            TextButton.icon(
              onPressed: notifier.clearFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('مسح الفلاتر'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: items.entries
            .map(
              (entry) => DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
