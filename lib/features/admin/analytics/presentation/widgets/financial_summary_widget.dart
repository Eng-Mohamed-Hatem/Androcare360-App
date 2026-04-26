import 'dart:async';

import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/admin/analytics/domain/entities/financial_summary.dart';
import 'package:elajtech/features/admin/analytics/domain/usecases/record_payout_usecase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// ملخص مالي للطبيب مع إمكانية تسجيل الصرف (FR-007).
class FinancialSummaryWidget extends StatefulWidget {
  const FinancialSummaryWidget({
    required this.summary,
    required this.doctorId,
    this.recordPayoutUseCase,
    super.key,
  });

  final FinancialSummary summary;
  final String doctorId;
  final RecordPayoutUseCase? recordPayoutUseCase;

  @override
  State<FinancialSummaryWidget> createState() => _FinancialSummaryWidgetState();
}

class _FinancialSummaryWidgetState extends State<FinancialSummaryWidget> {
  final NumberFormat _amountFormat = NumberFormat.currency(
    locale: 'ar',
    symbol: 'ر.س ',
    decimalDigits: 2,
  );

  // Mutable paid/pending state so we can refresh locally after a payout
  late double _paidAmount;
  late double _pendingAmount;

  @override
  void initState() {
    super.initState();
    _paidAmount = widget.summary.paidAmount;
    _pendingAmount = widget.summary.pendingAmount;
  }

  bool get _isFullyPaid => _paidAmount >= widget.summary.totalRevenue;

  void _openPayoutSheet() {
    final recordPayout =
        widget.recordPayoutUseCase ?? getIt<RecordPayoutUseCase>();
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _RecordPayoutSheet(
          doctorId: widget.doctorId,
          pendingAmount: _pendingAmount,
          recordPayout: recordPayout,
          onSuccess: (double paidNow) {
            setState(() {
              _paidAmount = (_paidAmount + paidNow).clamp(
                0,
                widget.summary.totalRevenue,
              );
              _pendingAmount = (_pendingAmount - paidNow).clamp(
                0,
                double.infinity,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commissionRate = (widget.summary.commissionRate * 100)
        .toStringAsFixed(1);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الملخص المالي',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_isFullyPaid)
                  Chip(
                    key: const Key('paid_badge'),
                    label: const Text('مدفوع بالكامل'),
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                    labelStyle: const TextStyle(color: Colors.green),
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _FinancialLine(
              label: 'إجمالي الإيرادات',
              value: _amountFormat.format(widget.summary.totalRevenue),
            ),
            _FinancialLine(
              label: 'عمولة المنصة ($commissionRate%)',
              value: _amountFormat.format(widget.summary.platformCommission),
            ),
            _FinancialLine(
              label: 'صافي المستحق',
              value: _amountFormat.format(widget.summary.netPayout),
            ),
            const Divider(height: 24),
            _FinancialLine(
              label: 'المبلغ المدفوع',
              value: _amountFormat.format(_paidAmount),
            ),
            _FinancialLine(
              label: 'المستحق المعلق',
              value: _amountFormat.format(_pendingAmount),
              isEmphasized: true,
            ),
            if (!_isFullyPaid && _pendingAmount > 0) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                key: const Key('record_payout_button'),
                onPressed: _openPayoutSheet,
                icon: const Icon(Icons.payments),
                label: const Text('تسجيل صرف'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet for recording a payout
// ─────────────────────────────────────────────────────────────────────────────

class _RecordPayoutSheet extends StatefulWidget {
  const _RecordPayoutSheet({
    required this.doctorId,
    required this.pendingAmount,
    required this.recordPayout,
    required this.onSuccess,
  });

  final String doctorId;
  final double pendingAmount;
  final RecordPayoutUseCase recordPayout;
  final ValueChanged<double> onSuccess;

  @override
  State<_RecordPayoutSheet> createState() => _RecordPayoutSheetState();
}

class _RecordPayoutSheetState extends State<_RecordPayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.pendingAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    setState(() => _submitting = true);

    final result = await widget.recordPayout(
      doctorId: widget.doctorId,
      amount: amount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        setState(() => _submitting = false);
        final msg = failure.when(
          firestore: (String m) => m,
          network: (String m) => m,
          agora: (String m) => m,
          voip: (String m) => m,
          app: (String m) => m,
          unexpected: (String _) => 'حدث خطأ غير متوقع',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            action: SnackBarAction(label: 'إعادة', onPressed: _submit),
          ),
        );
      },
      (_) {
        Navigator.of(context).pop();
        widget.onSuccess(amount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الصرف بنجاح')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تسجيل صرف مستحقات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('payout_amount_field'),
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'المبلغ (ر.س)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final parsed = double.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'يجب أن يكون المبلغ أكبر من صفر';
                  }
                  if (parsed > widget.pendingAmount) {
                    return 'المبلغ يتجاوز المستحق المعلق';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('confirm_payout_button'),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تأكيد الصرف'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared row widget
// ─────────────────────────────────────────────────────────────────────────────

class _FinancialLine extends StatelessWidget {
  const _FinancialLine({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: isEmphasized ? FontWeight.w700 : null,
              color: isEmphasized
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
