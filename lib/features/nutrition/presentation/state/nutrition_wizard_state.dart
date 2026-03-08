import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_wizard_state.freezed.dart';

/// Step Completion Status
///
/// Tracks the completion state of each wizard step
enum StepCompletionStatus {
  /// Not yet started
  notStarted,

  /// In progress (at least one field filled)
  inProgress,

  /// Completed (all required fields filled)
  completed,

  /// Has validation errors
  hasErrors,
}

/// Nutrition Wizard State
///
/// Manages the 8-step wizard navigation and progression state.
///
/// **Wizard Steps:**
/// 1. Anthropometric Measurements (5 fields)
/// 2. Dietary Assessment (4 fields)
/// 3. Clinical Assessment (4 fields)
/// 4. Lab Results Review (3 fields)
/// 5. Nutrition Diagnosis (4 fields - at least one required)
/// 6. Nutrition Intervention (5 fields)
/// 7. Monitoring and Evaluation (4 fields)
/// 8. Documentation and Communication (3 fields)
///
/// **Features:**
/// - Current step tracking (1-8)
/// - Visited steps history
/// - Step completion status
/// - Validation before step transition
/// - Last saved step restoration
@freezed
abstract class NutritionWizardState with _$NutritionWizardState {
  const factory NutritionWizardState({
    /// Current active step (1-8)
    @Default(1) int currentStep,

    /// Set of steps that have been visited
    @Default({1}) Set<int> visitedSteps,

    /// Last step that was successfully saved
    @Default(0) int lastSavedStep,

    /// Whether user can proceed to next step
    /// (based on validation of current step)
    @Default(true) bool canProceed,

    /// Validation error message for current step
    String? validationError,

    /// Completion status for each step (1-8)
    @Default({
      1: StepCompletionStatus.notStarted,
      2: StepCompletionStatus.notStarted,
      3: StepCompletionStatus.notStarted,
      4: StepCompletionStatus.notStarted,
      5: StepCompletionStatus.notStarted,
      6: StepCompletionStatus.notStarted,
      7: StepCompletionStatus.notStarted,
      8: StepCompletionStatus.notStarted,
    })
    Map<int, StepCompletionStatus> stepStatuses,
  }) = _NutritionWizardState;

  const NutritionWizardState._();

  /// Check if currently on first step
  bool get isFirstStep => currentStep == 1;

  /// Check if currently on last step
  bool get isLastStep => currentStep == 8;

  /// Check if wizard is complete (all 8 steps completed)
  bool get isComplete => stepStatuses.values.every(
    (status) => status == StepCompletionStatus.completed,
  );

  /// Get overall completion percentage (0-100%)
  double get completionPercentage {
    final completedSteps = stepStatuses.values
        .where((status) => status == StepCompletionStatus.completed)
        .length;
    return (completedSteps / 8) * 100;
  }

  /// Get number of completed steps
  int get completedStepsCount => stepStatuses.values
      .where((status) => status == StepCompletionStatus.completed)
      .length;

  /// Check if a specific step has been visited
  bool isStepVisited(int step) => visitedSteps.contains(step);

  /// Get completion status for a specific step
  StepCompletionStatus getStepStatus(int step) {
    return stepStatuses[step] ?? StepCompletionStatus.notStarted;
  }

  /// Check if current step has errors
  bool get hasValidationError => validationError != null;

  /// Get step name (English)
  static String getStepName(int step) {
    switch (step) {
      case 1:
        return 'Anthropometric Measurements';
      case 2:
        return 'Dietary Assessment';
      case 3:
        return 'Clinical Assessment';
      case 4:
        return 'Lab Results Review';
      case 5:
        return 'Nutrition Diagnosis';
      case 6:
        return 'Nutrition Intervention';
      case 7:
        return 'Monitoring and Evaluation';
      case 8:
        return 'Documentation and Communication';
      default:
        return 'Unknown Step';
    }
  }

  /// Get step name (Arabic)
  static String getStepNameArabic(int step) {
    switch (step) {
      case 1:
        return 'القياسات الجسمية';
      case 2:
        return 'تقييم النظام الغذائي';
      case 3:
        return 'التقييم السريري';
      case 4:
        return 'مراجعة التحاليل';
      case 5:
        return 'التشخيص الغذائي';
      case 6:
        return 'الخطة العلاجية الغذائية';
      case 7:
        return 'المتابعة والتقييم';
      case 8:
        return 'التوثيق والتواصل';
      default:
        return 'خطوة غير معروفة';
    }
  }

  /// Get step description (Arabic)
  static String getStepDescriptionArabic(int step) {
    switch (step) {
      case 1:
        return 'قياس الوزن والطول ومؤشر كتلة الجسم';
      case 2:
        return 'تقييم النظام الغذائي الحالي والحساسية';
      case 3:
        return 'الفحص السريري والتاريخ المرضي';
      case 4:
        return 'مراجعة نتائج التحاليل المخبرية';
      case 5:
        return 'تشخيص الحالة الغذائية';
      case 6:
        return 'وضع الخطة العلاجية الغذائية';
      case 7:
        return 'تحديد أهداف المتابعة';
      case 8:
        return 'توثيق الجلسة والتواصل';
      default:
        return '';
    }
  }

  /// Get icon for step status
  static String getStepIcon(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.completed:
        return '✓';
      case StepCompletionStatus.inProgress:
        return '⋯';
      case StepCompletionStatus.hasErrors:
        return '⚠';
      case StepCompletionStatus.notStarted:
        return '○';
    }
  }

  /// Get color for step status
  static String getStepColor(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.completed:
        return '0xFF4CAF50'; // Green
      case StepCompletionStatus.inProgress:
        return '0xFF2196F3'; // Blue
      case StepCompletionStatus.hasErrors:
        return '0xFFF44336'; // Red
      case StepCompletionStatus.notStarted:
        return '0xFF9E9E9E'; // Grey
    }
  }
}
