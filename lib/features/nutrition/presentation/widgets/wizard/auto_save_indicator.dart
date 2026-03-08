import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';

/// Auto Save State
enum AutoSaveState {
  idle,
  saving,
  saved,
  error,
}

/// Auto Save Indicator Widget
///
/// Displays auto-save status with timestamp
/// Design: Quiet and unobtrusive
class AutoSaveIndicator extends StatelessWidget {
  const AutoSaveIndicator({
    required this.state,
    this.lastSavedAt,
    this.errorMessage,
    this.unsavedChangesCount = 0,
    super.key,
  });

  final AutoSaveState state;
  final DateTime? lastSavedAt;
  final String? errorMessage;
  final int unsavedChangesCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(state),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusText(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                    fontSize: 12,
                  ),
                ),
                if (_shouldShowTimestamp()) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getTimestampText(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: _getTextColor().withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get status text based on state
  String _getStatusText() {
    switch (state) {
      case AutoSaveState.idle:
        return unsavedChangesCount > 0
            ? 'تغييرات غير محفوظة ($unsavedChangesCount)'
            : 'لا توجد تغييرات';
      case AutoSaveState.saving:
        return 'جاري الحفظ...';
      case AutoSaveState.saved:
        return 'تم الحفظ';
      case AutoSaveState.error:
        return 'فشل الحفظ';
    }
  }

  /// Get timestamp text
  String _getTimestampText() {
    if (lastSavedAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastSavedAt!);

    if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      final timeFormat = DateFormat('h:mm a', 'ar');
      return 'في ${timeFormat.format(lastSavedAt!)}';
    }
  }

  /// Check if timestamp should be shown
  bool _shouldShowTimestamp() {
    return (state == AutoSaveState.saved || state == AutoSaveState.error) &&
        lastSavedAt != null;
  }

  /// Build icon widget
  Widget _buildIcon() {
    switch (state) {
      case AutoSaveState.idle:
        return Icon(
          unsavedChangesCount > 0
              ? Icons.edit_note_outlined
              : Icons.check_circle_outline,
          size: 18,
          color: _getTextColor(),
        );
      case AutoSaveState.saving:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
          ),
        );
      case AutoSaveState.saved:
        return Icon(
          Icons.check_circle,
          size: 18,
          color: _getTextColor(),
        );
      case AutoSaveState.error:
        return Icon(
          Icons.error_outline,
          size: 18,
          color: _getTextColor(),
        );
    }
  }

  /// Get background color
  Color _getBackgroundColor() {
    switch (state) {
      case AutoSaveState.idle:
        return unsavedChangesCount > 0
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.surfaceLight;
      case AutoSaveState.saving:
        return AppColors.info.withValues(alpha: 0.1);
      case AutoSaveState.saved:
        return AppColors.success.withValues(alpha: 0.1);
      case AutoSaveState.error:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  /// Get border color
  Color _getBorderColor() {
    switch (state) {
      case AutoSaveState.idle:
        return unsavedChangesCount > 0
            ? AppColors.warning.withValues(alpha: 0.3)
            : AppColors.borderLight;
      case AutoSaveState.saving:
        return AppColors.info.withValues(alpha: 0.3);
      case AutoSaveState.saved:
        return AppColors.success.withValues(alpha: 0.3);
      case AutoSaveState.error:
        return AppColors.error.withValues(alpha: 0.3);
    }
  }

  /// Get text color
  Color _getTextColor() {
    switch (state) {
      case AutoSaveState.idle:
        return unsavedChangesCount > 0
            ? AppColors.warning
            : AppColors.textSecondaryLight;
      case AutoSaveState.saving:
        return AppColors.info;
      case AutoSaveState.saved:
        return AppColors.success;
      case AutoSaveState.error:
        return AppColors.error;
    }
  }
}
