import 'package:flutter/material.dart';

/// Small badge widget showing account active/inactive status.
///
/// Used across doctor and patient list/detail admin screens.
class AdminAccountStatusChip extends StatelessWidget {
  const AdminAccountStatusChip({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(
      isActive ? 'نشط' : 'معطّل',
      style: TextStyle(
        color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: isActive ? Colors.green.shade50 : Colors.red.shade50,
    side: BorderSide(
      color: isActive ? Colors.green.shade200 : Colors.red.shade200,
    ),
    padding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}
