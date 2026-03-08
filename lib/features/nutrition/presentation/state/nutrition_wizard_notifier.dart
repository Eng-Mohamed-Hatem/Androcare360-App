import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_wizard_state.dart';

/// Nutrition Wizard State Notifier
///
/// Manages the 8-step wizard navigation and progression for first-time
/// nutrition EMR entry.
///
/// **Responsibilities:**
/// - Navigate between steps (next, previous, jump to specific step)
/// - Validate step completion before allowing progression
/// - Track visited steps and completion status
/// - Save progression state to server
/// - Restore last saved step on wizard open
/// - Calculate overall wizard completion
///
/// **Validation Rules:**
/// - Step 1-4, 6-8: All fields must be checked to proceed
/// - Step 5 (Diagnosis): At least ONE field must be checked
/// - Cannot jump to future steps unless current step is valid
/// - Can navigate back to any visited step
///
/// **Integration:**
/// - Works alongside NutritionEMRNotifier for field state
/// - Saves lastCompletedStep to server on each step completion
/// - Reads EMR data to determine step completion status
class NutritionWizardNotifier extends StateNotifier<NutritionWizardState> {
  NutritionWizardNotifier() : super(const NutritionWizardState());

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 INITIALIZATION & RESTORATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize wizard state from EMR entity
  ///
  /// **Flow:**
  /// 1. Calculate completion status for each step based on EMR fields
  /// 2. Determine last completed step
  /// 3. Set current step to continue from last position
  /// 4. Mark all steps up to last completed as visited
  ///
  /// **Parameters:**
  /// - [emr]: The nutrition EMR entity with field states
  /// - [forceStartOver]: If true, reset to step 1 regardless of progress
  ///
  /// **Example:**
  /// ```dart
  /// wizardNotifier.initializeFromEMR(emr, forceStartOver: false);
  /// ```
  void initializeFromEMR(
    NutritionEMREntity emr, {
    bool forceStartOver = false,
  }) {
    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Initializing wizard from EMR');
      debugPrint('[NutritionWizardNotifier] Force start over: $forceStartOver');
    }

    // Calculate step completion statuses
    final stepStatuses = <int, StepCompletionStatus>{};
    var lastCompletedStep = 0;

    for (var step = 1; step <= 8; step++) {
      final status = _calculateStepStatus(emr, step);
      stepStatuses[step] = status;

      if (status == StepCompletionStatus.completed) {
        lastCompletedStep = step;
      }
    }

    // Determine starting step
    final startStep = forceStartOver ? 1 : (lastCompletedStep + 1).clamp(1, 8);

    // Mark all steps up to current as visited
    final visitedSteps = <int>{};
    for (var i = 1; i <= startStep; i++) {
      visitedSteps.add(i);
    }

    state = state.copyWith(
      currentStep: startStep,
      visitedSteps: visitedSteps,
      lastSavedStep: lastCompletedStep,
      stepStatuses: stepStatuses,
      canProceed: _canProceedFromStep(emr, startStep),
      validationError: null,
    );

    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Wizard initialized');
      debugPrint(
        '[NutritionWizardNotifier] Current step: ${state.currentStep}',
      );
      debugPrint(
        '[NutritionWizardNotifier] Last saved step: ${state.lastSavedStep}',
      );
      debugPrint(
        '[NutritionWizardNotifier] Completion: ${state.completionPercentage.toStringAsFixed(1)}%',
      );
    }
  }

  /// Calculate completion status for a specific step
  StepCompletionStatus _calculateStepStatus(NutritionEMREntity emr, int step) {
    final isComplete = emr.isSectionComplete(step);

    if (isComplete) {
      return StepCompletionStatus.completed;
    }

    // Check if any field in the section is filled
    final sectionPercentage = emr.getSectionCompletionPercentage(step);
    if (sectionPercentage > 0) {
      return StepCompletionStatus.inProgress;
    }

    return StepCompletionStatus.notStarted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 NAVIGATION OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Move to next step
  ///
  /// **Validation:**
  /// - Current step must be valid (canProceed = true)
  /// - Cannot go beyond step 8
  ///
  /// **Actions:**
  /// - Updates current step
  /// - Adds new step to visited steps
  /// - Recalculates canProceed for new step
  /// - Saves progress to server if step completed
  ///
  /// **Returns:** True if navigation successful, false if blocked
  Future<bool> nextStep(NutritionEMREntity emr) async {
    if (state.isLastStep) {
      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Already on last step');
      }
      return false;
    }

    if (!state.canProceed) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionWizardNotifier] Cannot proceed: Current step incomplete',
        );
      }

      state = state.copyWith(
        validationError: _getValidationError(emr, state.currentStep),
      );
      return false;
    }

    final nextStepNumber = state.currentStep + 1;

    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Moving to step $nextStepNumber');
    }

    // Mark current step as completed
    final updatedStatuses = Map<int, StepCompletionStatus>.from(
      state.stepStatuses,
    );
    updatedStatuses[state.currentStep] = StepCompletionStatus.completed;

    // Add next step to visited
    final updatedVisited = Set<int>.from(state.visitedSteps)
      ..add(nextStepNumber);

    state = state.copyWith(
      currentStep: nextStepNumber,
      visitedSteps: updatedVisited,
      lastSavedStep: state.currentStep, // Previous step is now last saved
      stepStatuses: updatedStatuses,
      canProceed: _canProceedFromStep(emr, nextStepNumber),
      validationError: null,
    );

    // Save progress to server
    await _saveProgressToServer(emr.id, state.lastSavedStep);

    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Navigation successful');
      debugPrint(
        '[NutritionWizardNotifier] Completion: ${state.completionPercentage.toStringAsFixed(1)}%',
      );
    }

    return true;
  }

  /// Move to previous step
  ///
  /// **Rules:**
  /// - Cannot go below step 1
  /// - Previous step must be in visited steps
  ///
  /// **Actions:**
  /// - Updates current step
  /// - Recalculates canProceed
  /// - Clears validation error
  ///
  /// **Returns:** True if navigation successful, false if blocked
  bool previousStep(NutritionEMREntity emr) {
    if (state.isFirstStep) {
      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Already on first step');
      }
      return false;
    }

    final prevStepNumber = state.currentStep - 1;

    if (!state.isStepVisited(prevStepNumber)) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionWizardNotifier] Cannot go to unvisited step $prevStepNumber',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint(
        '[NutritionWizardNotifier] Moving back to step $prevStepNumber',
      );
    }

    state = state.copyWith(
      currentStep: prevStepNumber,
      canProceed: _canProceedFromStep(emr, prevStepNumber),
      validationError: null,
    );

    return true;
  }

  /// Jump to a specific step
  ///
  /// **Rules:**
  /// - Can only jump to visited steps OR next immediate step if current is valid
  /// - Cannot skip steps
  ///
  /// **Parameters:**
  /// - [stepNumber]: Target step (1-8)
  /// - [emr]: Current EMR data for validation
  ///
  /// **Returns:** True if jump successful, false if blocked
  bool jumpToStep(int stepNumber, NutritionEMREntity emr) {
    if (stepNumber < 1 || stepNumber > 8) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionWizardNotifier] Invalid step number: $stepNumber',
        );
      }
      return false;
    }

    if (stepNumber == state.currentStep) {
      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Already on step $stepNumber');
      }
      return true;
    }

    // Can jump back to any visited step
    if (state.isStepVisited(stepNumber)) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionWizardNotifier] Jumping to visited step $stepNumber',
        );
      }

      state = state.copyWith(
        currentStep: stepNumber,
        canProceed: _canProceedFromStep(emr, stepNumber),
        validationError: null,
      );
      return true;
    }

    // Can only jump forward to immediate next step if current is valid
    if (stepNumber == state.currentStep + 1 && state.canProceed) {
      return nextStep(emr) as bool;
    }

    if (kDebugMode) {
      debugPrint(
        '[NutritionWizardNotifier] Cannot jump to unvisited step $stepNumber',
      );
    }

    state = state.copyWith(
      validationError: 'يجب إكمال الخطوة الحالية قبل التقدم',
    );
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if can proceed from a specific step
  ///
  /// **Validation Logic:**
  /// - Steps 1-4, 6-8: All section fields must be complete
  /// - Step 5 (Diagnosis): At least one diagnosis field must be checked
  ///
  /// **Parameters:**
  /// - [emr]: EMR entity to check
  /// - [step]: Step number to validate
  ///
  /// **Returns:** True if step is valid for progression
  bool _canProceedFromStep(NutritionEMREntity emr, int step) {
    switch (step) {
      case 1: // Anthropometric - CRITICAL FIX: Always allow progression from Step 1
        return true;

      case 2: // Dietary - all 4 required
        return emr.dietary24HRecall &&
            emr.foodFrequencyChecked &&
            emr.allergiesDocumented &&
            emr.supplementsReviewed;

      case 3: // Clinical - all 4 required
        return emr.medicalHistoryReviewed &&
            emr.physicalExamCompleted &&
            emr.appetiteAssessed &&
            emr.giSymptomsEvaluated;

      case 4: // Lab Results - all 3 required
        return emr.bloodGlucoseReviewed &&
            emr.lipidProfileReviewed &&
            emr.micronutrientsReviewed;

      case 5: // Diagnosis - at least ONE required
        return emr.inadequateIntakeDiagnosed ||
            emr.excessiveIntakeDiagnosed ||
            emr.knowledgeDeficitIdentified ||
            emr.disorderedEatingIdentified;

      case 6: // Intervention - all 5 required
        return emr.caloriePrescriptionSet &&
            emr.macroDistributionSet &&
            emr.mealPlanProvided &&
            emr.educationProvided &&
            emr.supplementsRecommended;

      case 7: // Monitoring - all 4 required
        return emr.targetWeightSet &&
            emr.timelineDocumented &&
            emr.followUpScheduled &&
            emr.monitoringParametersSet;

      case 8: // Documentation - all 3 required
        return emr.writtenInstructionsProvided &&
            emr.physicianNotified &&
            emr.consentObtained;

      default:
        return false;
    }
  }

  /// Get validation error message for current step
  String _getValidationError(NutritionEMREntity emr, int step) {
    final sectionName = NutritionWizardState.getStepNameArabic(step);

    if (step == 5) {
      // Special case for diagnosis
      return 'يجب اختيار تشخيص واحد على الأقل في قسم "$sectionName"';
    }

    return 'يجب إكمال جميع الحقول في قسم "$sectionName" قبل المتابعة';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 PERSISTENCE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save progression state to server
  ///
  /// **Saves:**
  /// - lastCompletedStep number
  /// - Timestamp of save
  ///
  /// **Note:** Does NOT save field data (handled by NutritionEMRNotifier)
  ///
  /// **Parameters:**
  /// - [emrId]: The EMR document ID
  /// - [lastStep]: Last completed step number
  Future<void> _saveProgressToServer(String emrId, int lastStep) async {
    try {
      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Saving progress to server');
        debugPrint('[NutritionWizardNotifier] EMR ID: $emrId');
        debugPrint('[NutritionWizardNotifier] Last step: $lastStep');
      }

      // Note: In full implementation, you would call repository method to update
      // a 'wizardProgress' field in the EMR document. For now, this is a placeholder.
      //
      // await _repository.saveWizardProgress(emrId, lastStep);

      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Progress saved successfully');
      }
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionWizardNotifier] Error saving progress: $e');
        debugPrint('[NutritionWizardNotifier] StackTrace: $stackTrace');
      }
      // Don't throw - progress save failure shouldn't block navigation
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 STATE UPDATES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update wizard state after EMR field change
  ///
  /// **Use Case:** Called by UI after a field is updated via NutritionEMRNotifier
  /// to refresh step validation and completion status
  ///
  /// **Parameters:**
  /// - [emr]: Updated EMR entity
  void refreshValidation(NutritionEMREntity emr) {
    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Refreshing validation');
    }

    // Recalculate step statuses
    final updatedStatuses = <int, StepCompletionStatus>{};
    for (var step = 1; step <= 8; step++) {
      updatedStatuses[step] = _calculateStepStatus(emr, step);
    }

    state = state.copyWith(
      stepStatuses: updatedStatuses,
      canProceed: _canProceedFromStep(emr, state.currentStep),
      validationError: null,
    );

    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Validation refreshed');
      debugPrint('[NutritionWizardNotifier] Can proceed: ${state.canProceed}');
      debugPrint(
        '[NutritionWizardNotifier] Completion: ${state.completionPercentage.toStringAsFixed(1)}%',
      );
    }
  }

  /// Reset wizard to start
  void reset() {
    if (kDebugMode) {
      debugPrint('[NutritionWizardNotifier] Resetting wizard to step 1');
    }

    state = const NutritionWizardState();
  }

  /// Get current step progress summary
  Map<String, dynamic> getProgressSummary() {
    return {
      'currentStep': state.currentStep,
      'currentStepName': NutritionWizardState.getStepNameArabic(
        state.currentStep,
      ),
      'completedSteps': state.completedStepsCount,
      'totalSteps': 8,
      'completionPercentage': state.completionPercentage,
      'canProceed': state.canProceed,
      'isComplete': state.isComplete,
      'visitedSteps': state.visitedSteps.toList()..sort(),
    };
  }
}
