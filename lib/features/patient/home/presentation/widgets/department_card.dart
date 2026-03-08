import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/home/presentation/screens/doctors_list_screen.dart';
import 'package:elajtech/shared/models/department_model.dart';
import 'package:flutter/material.dart';

/// Department Card Widget - بطاقة القسم الطبي
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({required this.department, super.key});
  final DepartmentModel department;

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColorFromHex(department.color);

    return InkWell(
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                DoctorsListScreen(category: department.nameAr),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Emoji
            Icon(department.icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),

            // Department Name
            Text(
              department.nameAr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
