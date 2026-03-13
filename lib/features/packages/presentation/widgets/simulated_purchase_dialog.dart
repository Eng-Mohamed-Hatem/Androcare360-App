/// SimulatedPurchaseDialog — حوار شراء تجريبي
///
/// يعرض هذا الحوار إشعاراً للمستخدم بأن عملية الشراء تجريبية ولن يتم خصم أي مبالغ حقيقية.
///
/// **English**: Warning dialog for simulated test purchases.
/// Informs the user that no real payment will be processed.
///
/// **Spec**: spec.md §7.3, tasks.md T011.
library;

import 'package:flutter/material.dart';

/// A centered dialog explaining that the purchase is for testing purposes.
/// Includes both Arabic and English text to satisfy medical and technical requirements.
///
/// **Arabic**: حوار منبثق يُعلم المستخدم بأن الشراء تجريبي.
/// يتضمن نصوصاً باللغتين العربية والإنجليزية لتلبية المتطلبات الطبية والتقنية.
///
/// **Usage / الاستخدام**:
/// ```dart
/// final confirmed = await SimulatedPurchaseDialog.show(context);
/// if (confirmed ?? false) {
///   // proceed with use case call
/// }
/// ```
class SimulatedPurchaseDialog extends StatelessWidget {
  /// Creates a [SimulatedPurchaseDialog].
  ///
  /// **Arabic**: يُنشئ كائن [SimulatedPurchaseDialog].
  const SimulatedPurchaseDialog({super.key});

  /// Shows the dialog and returns true if confirmed.
  ///
  /// **Arabic**: يعرض الحوار ويُعيد `true` في حال التأكيد.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SimulatedPurchaseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'عملية شراء تجريبية',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Completed (Test)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'لقد اخترت باقة تجريبية. لن يتم إجراء أي عملية دفع حقيقية أو سحب من حسابك المالي.',
            style: TextStyle(height: 1.4),
          ),
          SizedBox(height: 8),
          Text(
            'سيتم تسجيل الباقة في حسابك كنسخة تجريبية لاختبار ميزات النظام.',
            style: TextStyle(height: 1.4, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('تأكيد عملية الشراء'),
        ),
      ],
    );
  }
}
