/// PackageStatusBadge — شارة حالة باقة المريض
///
/// تعرض هذه الشارة حالة [PatientPackageStatus] بألوان وتسميات عربية.
///
/// **English**: Renders [PatientPackageStatus] as a colored badge with an
/// Arabic label. Used in "My Packages" list items and package details.
///
/// **Spec**: tasks.md T039.
library;

import 'package:elajtech/features/packages/domain/entities/patient_package_entity.dart';
import 'package:flutter/material.dart';

/// Badge widget that displays a [PatientPackageStatus] with Arabic label.
///
/// **English**
/// Status → color + label mapping:
/// - `active` → green → "نشطة"
/// - `completed` → blue → "مكتملة"
/// - `expired` → red → "منتهية الصلاحية"
/// - `pending` → orange → "في انتظار التفعيل"
///
/// **Arabic**
/// تعرض حالة باقة المريض بلون ونص عربي.
///
/// **Usage / الاستخدام**:
/// ```dart
/// PackageStatusBadge(status: PatientPackageStatus.active)
/// ```
class PackageStatusBadge extends StatelessWidget {
  /// Creates a [PackageStatusBadge] for the given [status].
  const PackageStatusBadge({required this.status, super.key});

  /// The patient package status to display.
  final PatientPackageStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labelAndColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Private helper ────────────────────────────────────────────────────────

  /// Returns (label, color) for [status].
  ///
  /// يُعيد (التسمية، اللون) حسب الحالة.
  static (String, Color) _labelAndColor(PatientPackageStatus status) {
    return switch (status) {
      PatientPackageStatus.active => ('نشطة', const Color(0xFF2E7D32)),
      PatientPackageStatus.completed => ('مكتملة', const Color(0xFF1565C0)),
      PatientPackageStatus.expired => (
        'منتهية الصلاحية',
        const Color(0xFFC62828),
      ),
      PatientPackageStatus.pending => (
        'في انتظار التفعيل',
        const Color(0xFFE65100),
      ),
    };
  }
}
