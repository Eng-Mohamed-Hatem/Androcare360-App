import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';

/// Nutrition Checkbox Tile
///
/// Reusable checkbox component for all wizard steps
///
/// **Features:**
/// - Haptic feedback on selection
/// - Smooth animations
/// - RTL support
/// - Consistent styling
/// - Hover effects
/// - Accessibility support
///
/// **Usage:**
/// ```dart
/// NutritionCheckboxTile(
///   title: 'Height Measured',
///   subtitle: 'قياس الطول',
///   value: true,
///   onChanged: (value) => handleChange(value),
/// )
/// ```
class NutritionCheckboxTile extends StatefulWidget {
  const NutritionCheckboxTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.dense = false,
    super.key,
  });

  /// Main title (English)
  final String title;

  /// Optional subtitle (Arabic)
  final String? subtitle;

  /// Current checkbox value
  final bool value;

  /// Callback when value changes
  final ValueChanged<bool> onChanged;

  /// Optional leading icon
  final IconData? icon;

  /// Whether the tile is enabled for interaction
  final bool enabled;

  /// Whether to use dense layout
  final bool dense;

  @override
  State<NutritionCheckboxTile> createState() => _NutritionCheckboxTileState();
}

class _NutritionCheckboxTileState extends State<NutritionCheckboxTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;

    //Haptic feedback on selection
    await HapticFeedback.selectionClick();

    // Play animation
    await _controller.forward().then((_) => _controller.reverse());

    // Notify parent
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                bottom: widget.dense ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: widget.value
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.value
                      ? AppColors.primary
                      : _isHovered
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.borderLight,
                  width: widget.value ? 2 : 1,
                ),
                boxShadow: [
                  if (_isHovered || widget.value)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(widget.dense ? 12 : 16),
                child: Row(
                  children: [
                    // Leading Icon (if provided)
                    if (widget.icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.value
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.value
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // English Title
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              widget.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: widget.value
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: widget.enabled
                                    ? AppColors.textPrimaryLight
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),

                          // Arabic Subtitle
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.enabled
                                    ? AppColors.textSecondaryLight
                                    : AppColors.textSecondaryLight.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.value
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.value
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      child: widget.value
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
