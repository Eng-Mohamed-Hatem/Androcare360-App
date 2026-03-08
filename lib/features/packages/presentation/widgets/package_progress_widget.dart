/// PackageProgressWidget — ودجت تقدم الباقة
///
/// يعرض هذا الودجت نص `"X / Y"` مع شريط تقدم أفقي (`LinearProgressIndicator`)
/// ملفوف داخل `Directionality(TextDirection.ltr)` لضمان العرض الصحيح.
///
/// **English**: Reusable widget displaying package service progress as
/// `"used / total"` text and a `LinearProgressIndicator`. Both are wrapped in
/// `Directionality(TextDirection.ltr)` per spec.md §9.14 to prevent RTL
/// mirroring of the progress bar and western digits.
///
/// **Spec**: tasks.md T049, spec.md §9.4, §9.14.
library package_progress_widget;

import 'package:flutter/material.dart';

/// Reusable progress widget for a patient package.
///
/// **English**
/// Shows `"X / Y"` with a coloured [LinearProgressIndicator]. Both are wrapped
/// in [TextDirection.ltr] so the progress bar fills left-to-right and the
/// numbers render in western digits even in an RTL app.
///
/// **Arabic**
/// يعرض نص `"X / Y"` مع شريط تقدم. ملفوف بـ `TextDirection.ltr` لضمان
/// الاتجاه الصحيح للأرقام والشريط بغض النظر عن إعداد RTL للتطبيق.
///
/// **Usage / الاستخدام**:
/// ```dart
/// PackageProgressWidget(used: 2, total: 5)
/// ```
class PackageProgressWidget extends StatelessWidget {
  /// Creates a [PackageProgressWidget].
  ///
  /// [used]: consumed services count — الخدمات المستهلكة.
  /// [total]: total services count — إجمالي الخدمات.
  const PackageProgressWidget({
    required this.used,
    required this.total,
    super.key,
  });

  /// Number of consumed services — الخدمات المستهلكة.
  final int used;

  /// Total services in the package — إجمالي الخدمات.
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    // Determine colour based on progress
    final color = fraction >= 1.0
        ? Colors.green
        : fraction >= 0.7
        ? Colors.orange
        : theme.colorScheme.primary;

    return Directionality(
      // spec.md §9.14: progress bar + western numerals must be LTR
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "X / Y" label
          Text(
            '$used / $total',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color?>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
