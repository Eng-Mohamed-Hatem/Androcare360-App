import 'package:elajtech/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom Navigation Item Widget
/// عنصر واجهة عنصر التنقل المخصص
///
/// يعرض أيقونة مع تسمية أدناه، ويتغير اللون بناءً على حالة التحديد
/// يدعم RTL ويتضمن رسوم متحركة للنقر
class CustomNavItem extends StatelessWidget {
  /// إنشاء عنصر تنقل مخصص
  const CustomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// الأيقونة المعروضة
  final IconData icon;

  /// التسمية النصية
  final String label;

  /// حالة التحديد
  final bool isSelected;

  /// دالة الاستدعاء عند النقر
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // تحديد اللون بناءً على حالة التحديد
    final color = isSelected ? AppColors.primary : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة مع رسوم متحركة
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // التسمية
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
