import 'package:elajtech/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Loading Indicator Widget - مؤشر التحميل
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.color});
  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}
