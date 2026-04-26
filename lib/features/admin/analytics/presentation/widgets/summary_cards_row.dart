import 'package:elajtech/features/admin/analytics/domain/entities/platform_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({
    required this.summary,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    super.key,
  });

  final PlatformSummary? summary;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error != null && summary == null) {
      return _ErrorCard(message: error!, onRetry: onRetry);
    }

    final cards = [
      _SummaryCardData(
        title: 'إجمالي الحجوزات المكتملة',
        value: summary == null
            ? null
            : NumberFormat.decimalPattern('ar').format(
                summary!.totalCompletedAppointments,
              ),
        icon: Icons.event_available,
        color: const Color(0xFF2563EB),
      ),
      _SummaryCardData(
        title: 'إجمالي الإيرادات (SAR)',
        value: summary == null
            ? null
            : NumberFormat.currency(
                locale: 'ar',
                symbol: 'ر.س ',
                decimalDigits: 2,
              ).format(summary!.totalRevenue),
        icon: Icons.payments_outlined,
        color: const Color(0xFF059669),
      ),
      _SummaryCardData(
        title: 'متوسط نقطة الأداء',
        value: summary == null
            ? null
            : '${summary!.averagePerformanceScore.toStringAsFixed(1)} / 100',
        icon: Icons.speed_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _SummaryCardData(
        title: 'المستحقات المعلقة',
        value: summary == null
            ? null
            : NumberFormat.currency(
                locale: 'ar',
                symbol: 'ر.س ',
                decimalDigits: 2,
              ).format(summary!.totalPendingPayouts),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFFDC2626),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 36) / 4
                      : constraints.maxWidth,
                  child: _SummaryCard(data: card, isLoading: isLoading),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String? value;
  final IconData icon;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.isLoading});

  final _SummaryCardData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: data.color.withValues(alpha: 0.16)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, color: data.color),
            const SizedBox(height: 16),
            Text(
              data.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading && data.value == null)
              Container(
                height: 26,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            else
              Text(
                data.value ?? '0',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
