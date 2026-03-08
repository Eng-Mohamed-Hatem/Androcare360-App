import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/core/constants/app_text_styles.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_state_providers.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_wizard_state.dart';
import 'package:elajtech/features/nutrition/presentation/widgets/wizard/nutrition_wizard_view.dart';
import 'package:elajtech/features/nutrition/presentation/widgets/dialogs/unsaved_changes_dialog.dart';

/// Main screen for Nutrition Clinic
/// الشاشة الرئيسية لعيادة التغذية
class NutritionClinicScreen extends ConsumerStatefulWidget {
  const NutritionClinicScreen({
    required this.appointmentId,
    required this.patientId,
    super.key,
  });

  final String appointmentId;
  final String patientId;

  @override
  ConsumerState<NutritionClinicScreen> createState() =>
      _NutritionClinicScreenState();
}

class _NutritionClinicScreenState extends ConsumerState<NutritionClinicScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize EMR for this patient
    Future.microtask(() async {
      final currentUser = ref.read(authProvider).user;

      if (currentUser == null) {
        // Handle null user - should not happen in normal flow
        return;
      }

      await ref
          .read(nutritionEMRNotifierProvider.notifier)
          .loadPatientNutritionData(
            appointmentId: widget.appointmentId,
            patientId: widget.patientId,
            nutritionistId: currentUser.id,
            nutritionistName: currentUser.fullName,
          );
    }).ignore();
  }

  /// Handle back button press with unsaved changes check
  Future<bool> _onWillPop() async {
    final emrState = ref.read(nutritionEMRNotifierProvider);

    if (emrState.hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const UnsavedChangesDialog(),
      );

      if (result ?? false) {
        // Save before exit
        await ref.read(nutritionEMRNotifierProvider.notifier).saveManually();
        return true;
      } else if (result == false) {
        // Discard changes
        return true;
      } else {
        // Cancel - stay on screen
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(nutritionWizardNotifierProvider);
    final emrState = ref.watch(nutritionEMRNotifierProvider);

    return PopScope(
      canPop: !emrState.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: _buildAppBar(wizardState),
        body: SafeArea(
          child: Column(
            children: [
              // Progress bar
              _buildProgressBar(wizardState),

              // Main content with animated switcher
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: emrState.isLoading
                      ? _buildLoadingState()
                      : emrState.hasError
                      ? _buildErrorState()
                      : NutritionWizardView(
                          key: const ValueKey('wizard'),
                          patientId: widget.patientId,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build AppBar with dynamic title based on current step
  PreferredSizeWidget _buildAppBar(NutritionWizardState wizardState) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: FadeInDown(
        duration: const Duration(milliseconds: 300),
        child: Column(
          children: [
            Text(
              'Nutrition Clinic',
              style: AppTextStyles.h5.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getStepTitle(wizardState.currentStep),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Info button
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Step Information',
          onPressed: () {
            _showStepInfo(wizardState.currentStep);
          },
        ),
      ],
    );
  }

  /// Build progress bar showing completion percentage
  Widget _buildProgressBar(NutritionWizardState wizardState) {
    const totalSteps = 8;
    final progress = (wizardState.currentStep + 1) / totalSteps;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0,
                  end: progress,
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(progress),
                  ),
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get progress bar color based on completion percentage
  Color _getProgressColor(double progress) {
    if (progress < 0.25) {
      return AppColors.error;
    } else if (progress < 0.5) {
      return AppColors.warning;
    } else if (progress < 0.75) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading patient records...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    final state = ref.read(nutritionEMRNotifierProvider);

    // Extract error message using getters
    var errorMessage = 'Unknown error occurred';
    if (state.hasError) {
      errorMessage = 'Failed to load nutrition data';
    }

    return Center(
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Will retry loading through wizard initialization
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get step title for AppBar
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Anthropometric Data';
      case 1:
        return 'Dietary Habits';
      case 2:
        return 'Medical History';
      case 3:
        return 'Physical Activity';
      case 4:
        return 'Laboratory Tests';
      case 5:
        return 'Supplementation';
      case 6:
        return 'Nutritional Education';
      case 7:
        return 'Follow-Up Planning';
      default:
        return 'Step ${step + 1}';
    }
  }

  /// Show step information dialog
  void _showStepInfo(int step) {
    // Intentionally not awaited - dialog display happens in background
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _getStepTitle(step),
            style: AppTextStyles.h5,
          ),
          content: Text(
            _getStepDescription(step),
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get step description for info dialog
  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Collect basic body measurements including height, weight, BMI, and body composition data.';
      case 1:
        return "Record patient's dietary patterns, preferences, and eating habits.";
      case 2:
        return 'Document relevant medical history including allergies, chronic conditions, and medications.';
      case 3:
        return 'Assess physical activity levels and exercise routines.';
      case 4:
        return 'Record laboratory test results relevant to nutrition assessment.';
      case 5:
        return 'Document current supplement usage and recommendations.';
      case 6:
        return 'Provide nutritional education and dietary guidelines.';
      case 7:
        return 'Plan follow-up appointments and set goals.';
      default:
        return 'Complete this step to continue.';
    }
  }
}
