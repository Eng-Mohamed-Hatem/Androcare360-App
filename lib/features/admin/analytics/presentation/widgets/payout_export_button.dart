import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/export_payout_report_usecase.dart';
import 'package:flutter/material.dart';

/// زر تصدير تقرير المستحقات — month/year picker + PDF/Excel format selector.
class PayoutExportButton extends StatefulWidget {
  const PayoutExportButton({
    required this.doctorId,
    this.exportUseCase,
    super.key,
  });

  final String doctorId;
  final ExportPayoutReportUseCase? exportUseCase;

  @override
  State<PayoutExportButton> createState() => _PayoutExportButtonState();
}

class _PayoutExportButtonState extends State<PayoutExportButton> {
  ExportPayoutReportUseCase? _exportUseCase;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _selectedFormat = 'pdf';
  bool _loading = false;
  String? _errorMessage;

  static const _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _exportUseCase =
        widget.exportUseCase ??
        (getIt.isRegistered<ExportPayoutReportUseCase>()
            ? getIt<ExportPayoutReportUseCase>()
            : null);
  }

  Future<void> _export() async {
    final exportUseCase = _exportUseCase;
    if (exportUseCase == null) {
      setState(() => _errorMessage = 'خدمة التصدير غير متاحة حالياً');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await exportUseCase(
      doctorId: widget.doctorId,
      year: _selectedYear,
      month: _selectedMonth,
      format: _selectedFormat,
    );

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        final msg = failure.when(
          firestore: (String m) => m,
          network: (String m) => m,
          agora: (String m) => m,
          voip: (String m) => m,
          app: (String m) => m,
          unexpected: (String _) => 'حدث خطأ غير متوقع',
        );
        setState(() {
          _loading = false;
          _errorMessage = msg;
        });
      },
      (String path) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ التقرير: $path')),
        );
      },
    );
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
                const Icon(Icons.file_download_outlined),
                const SizedBox(width: 8),
                Text(
                  'تصدير تقرير المستحقات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LabeledDropdown<int>(
                    label: 'السنة',
                    value: _selectedYear,
                    items: List.generate(5, (i) {
                      final year = DateTime.now().year - i;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: _loading
                        ? null
                        : (v) => setState(() => _selectedYear = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _LabeledDropdown<int>(
                    label: 'الشهر',
                    value: _selectedMonth,
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(_months[i]),
                      ),
                    ),
                    onChanged: _loading
                        ? null
                        : (v) => setState(() => _selectedMonth = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _FormatChip(
                  label: 'PDF',
                  selected: _selectedFormat == 'pdf',
                  onTap: _loading
                      ? null
                      : () => setState(() => _selectedFormat = 'pdf'),
                ),
                const SizedBox(width: 8),
                _FormatChip(
                  label: 'Excel',
                  selected: _selectedFormat == 'excel',
                  onTap: _loading
                      ? null
                      : () => setState(() => _selectedFormat = 'excel'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('export_button'),
                onPressed: _loading ? null : _export,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_loading ? 'جارٍ التصدير...' : 'تصدير التقرير'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
    );
  }
}
