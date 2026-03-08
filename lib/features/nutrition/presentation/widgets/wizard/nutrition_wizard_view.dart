import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_state_providers.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_emr_state.dart';
import 'package:elajtech/features/nutrition/presentation/widgets/wizard/auto_save_indicator.dart';
import 'package:elajtech/features/nutrition/presentation/widgets/wizard/steps/anthropometric_step.dart';

/// Simplified Nutrition Wizard View
///
/// Single-step simplified nutrition EMR entry focusing only on anthropometric data
///
/// **Features:**
/// - Single step view (Anthropometric measurements)
/// - Auto-save indicator
/// - Direct save functionality
/// - Responsive layout
class NutritionWizardView extends ConsumerStatefulWidget {
  const NutritionWizardView({
    required this.patientId,
    super.key,
  });

  final String patientId;

  @override
  ConsumerState<NutritionWizardView> createState() =>
      _NutritionWizardViewState();
}

class _NutritionWizardViewState extends ConsumerState<NutritionWizardView> {
  @override
  Widget build(BuildContext context) {
    final emrState = ref.watch(nutritionEMRNotifierProvider);
    final emr = emrState.emrOrNull;

    if (emr == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Auto-save Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lock Status
              if (emr.isCurrentlyLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'مقفل',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),

              // Auto-save Indicator
              AutoSaveIndicator(
                state: _getAutoSaveState(emrState),
                lastSavedAt: emrState.maybeMap(
                  loaded: (state) => state.lastSavedAt,
                  orElse: () => null,
                ),
                unsavedChangesCount: emrState.unsavedChangesCount,
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Single Step Content - Anthropometric Data Only
        const Expanded(
          child: AnthropometricStep(),
        ),
      ],
    );
  }

  /// Get auto-save state from EMR state
  AutoSaveState _getAutoSaveState(NutritionEMRState emrState) {
    return emrState.maybeMap(
      loaded: (state) {
        if (state.isSaving) return AutoSaveState.saving;
        if (state.saveError != null) return AutoSaveState.error;
        if (state.dirtyFields.isNotEmpty) return AutoSaveState.idle;
        if (state.lastSavedAt != null) return AutoSaveState.saved;
        return AutoSaveState.idle;
      },
      orElse: () => AutoSaveState.idle,
    );
  }
}
