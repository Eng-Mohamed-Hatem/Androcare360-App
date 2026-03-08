import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elajtech/core/di/injection_container.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_emr_notifier.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_emr_state.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_wizard_notifier.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_wizard_state.dart';

/// Nutrition EMR State Management Providers
///
/// **Providers:**
/// - nutritionEMRNotifierProvider: Core EMR state notifier
/// - nutritionWizardNotifierProvider: Wizard navigation notifier
///
/// **Dependencies:**
/// - Injected via GetIt service locator
/// - Requires NutritionEMRRepository to be registered
///
/// **Usage:**
/// ```dart
/// // Watch EMR state
/// final emrState = ref.watch(nutritionEMRNotifierProvider);
///
/// // Call notifier methods
/// ref.read(nutritionEMRNotifierProvider.notifier).loadPatientNutritionData(...);
///
/// // Watch wizard state
/// final wizardState = ref.watch(nutritionWizardNotifierProvider);
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// 📘 REPOSITORY PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Nutrition EMR Repository Provider
///
/// Provides access to the NutritionEMRRepository singleton from GetIt.
/// Used by notifiers to perform database operations.
final nutritionEMRRepositoryProvider = Provider<NutritionEMRRepository>((ref) {
  return getIt<NutritionEMRRepository>();
});

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 EMR STATE NOTIFIER PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Nutrition EMR State Notifier Provider
///
/// **Manages:**
/// - Loading patient nutrition EMR data
/// - Updating individual checkbox fields
/// - Auto-saving dirty fields every 30 seconds
/// - Manual save operations
/// - Lock management
/// - Completion percentage calculation
///
/// **State:**
/// - loading: Initial data fetch
/// - loaded: EMR data available with dirty tracking
/// - error: Failed operation with retry option
///
/// **Auto-Dispose:** No - persistent across screen navigation
///
/// **Example:**
/// ```dart
/// // Load EMR
/// await ref.read(nutritionEMRNotifierProvider.notifier)
///   .loadPatientNutritionData(
///     appointmentId: appointmentId,
///     patientId: patientId,
///     nutritionistId: currentUser.id,
///     nutritionistName: currentUser.fullName,
///   );
///
/// // Update field
/// ref.read(nutritionEMRNotifierProvider.notifier).updateField(
///   fieldName: 'weightMeasured',
///   value: true,
///   userId: currentUser.id,
///   userName: currentUser.fullName,
/// );
///
/// // Save manually
/// final success = await ref.read(nutritionEMRNotifierProvider.notifier).saveManually();
///
/// // Lock record
/// final locked = await ref.read(nutritionEMRNotifierProvider.notifier).lock();
/// ```
final nutritionEMRNotifierProvider =
    StateNotifierProvider<NutritionEMRNotifier, NutritionEMRState>((ref) {
      final repository = ref.watch(nutritionEMRRepositoryProvider);
      return NutritionEMRNotifier(repository);
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🧙 WIZARD STATE NOTIFIER PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Nutrition Wizard State Notifier Provider
///
/// **Manages:**
/// - 8-step wizard navigation (next, previous, jump)
/// - Step completion validation
/// - Visited steps tracking
/// - Last saved step restoration
/// - Overall completion percentage
///
/// **State:**
/// - currentStep: Active step (1-8)
/// - visitedSteps: Set of steps user has navigated to
/// - lastSavedStep: Last step successfully saved
/// - canProceed: Whether current step is valid for progression
/// - stepStatuses: Completion status for each step
///
/// **Auto-Dispose:** No - persistent during EMR editing session
///
/// **Example:**
/// ```dart
/// // Initialize wizard from EMR
/// ref.read(nutritionWizardNotifierProvider.notifier)
///   .initializeFromEMR(emr, forceStartOver: false);
///
/// // Navigate next
/// final canProceed = await ref.read(nutritionWizardNotifierProvider.notifier)
///   .nextStep(emr);
///
/// // Navigate back
/// ref.read(nutritionWizardNotifierProvider.notifier).previousStep(emr);
///
/// // Jump to step
/// ref.read(nutritionWizardNotifierProvider.notifier)
///   .jumpToStep(5, emr);
///
/// // Refresh validation after field update
/// ref.read(nutritionWizardNotifierProvider.notifier)
///   .refreshValidation(emr);
///
/// // Get progress summary
/// final summary = ref.read(nutritionWizardNotifierProvider.notifier)
///   .getProgressSummary();
/// ```
final nutritionWizardNotifierProvider =
    StateNotifierProvider<NutritionWizardNotifier, NutritionWizardState>((ref) {
      return NutritionWizardNotifier();
    });

// ═══════════════════════════════════════════════════════════════════════════
// 📊 COMPUTED STATE PROVIDERS (Derived Values)
// ═══════════════════════════════════════════════════════════════════════════

/// Current EMR Entity Provider
///
/// **Returns:** Current EMR entity if loaded, otherwise null
///
/// **Use Case:** Access EMR data without dealing with loading/error states
///
/// **Example:**
/// ```dart
/// final emr = ref.watch(currentNutritionEMRProvider);
/// if (emr != null) {
///   print('Completion: ${emr.completionPercentage}%');
/// }
/// ```
final AutoDisposeProvider<NutritionEMREntity?> currentNutritionEMRProvider =
    Provider.autoDispose((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.emrOrNull;
    });

/// EMR Loading State Provider
///
/// **Returns:** True if EMR is currently loading
///
/// **Use Case:** Show loading indicators
///
/// **Example:**
/// ```dart
/// final isLoading = ref.watch(isNutritionEMRLoadingProvider);
/// if (isLoading) return CircularProgressIndicator();
/// ```
final AutoDisposeProvider<bool> isNutritionEMRLoadingProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.isLoading;
    });

/// EMR Has Error Provider
///
/// **Returns:** True if EMR state has error
///
/// **Use Case:** Show error messages
///
/// **Example:**
/// ```dart
/// final hasError = ref.watch(hasNutritionEMRErrorProvider);
/// if (hasError) return ErrorWidget();
/// ```
final AutoDisposeProvider<bool> hasNutritionEMRErrorProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.hasError;
    });

/// EMR Unsaved Changes Provider
///
/// **Returns:** True if there are unsaved changes
///
/// **Use Case:** Show unsaved changes indicator, block navigation
///
/// **Example:**
/// ```dart
/// final hasUnsaved = ref.watch(hasUnsavedNutritionChangesProvider);
/// if (hasUnsaved) {
///   return Badge(
///     label: Text('${ref.read(unsavedChangesCountProvider)} unsaved'),
///     child: SaveButton(),
///   );
/// }
/// ```
final AutoDisposeProvider<bool> hasUnsavedNutritionChangesProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.hasUnsavedChanges;
    });

/// Unsaved Changes Count Provider
///
/// **Returns:** Number of fields with unsaved changes
///
/// **Use Case:** Display count in save button or warning dialog
///
/// **Example:**
/// ```dart
/// final count = ref.watch(unsavedChangesCountProvider);
/// Text('$count fields need saving');
/// ```
final AutoDisposeProvider<int> unsavedChangesCountProvider =
    Provider.autoDispose<int>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.unsavedChangesCount;
    });

/// EMR Is Locked Provider
///
/// **Returns:** True if EMR is currently locked (24h expired or manually locked)
///
/// **Use Case:** Disable edit buttons, show lock icon
///
/// **Example:**
/// ```dart
/// final isLocked = ref.watch(isNutritionEMRLockedProvider);
/// IconButton(
///   icon: Icon(isLocked ? Icons.lock : Icons.edit),
///   onPressed: isLocked ? null : () => openEditor(),
/// );
/// ```
final AutoDisposeProvider<bool> isNutritionEMRLockedProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.isLocked;
    });

/// Remaining Edit Hours Provider
///
/// **Returns:** Hours remaining before EMR auto-locks
///
/// **Use Case:** Show countdown timer
///
/// **Example:**
/// ```dart
/// final hours = ref.watch(remainingEditHoursProvider);
/// if (hours > 0 && hours < 4) {
///   return WarningBanner('Only $hours hours remaining to edit!');
/// }
/// ```
final AutoDisposeProvider<int> remainingEditHoursProvider =
    Provider.autoDispose<int>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.remainingEditHours;
    });

/// EMR Completion Percentage Provider
///
/// **Returns:** Overall completion percentage (0-100)
///
/// **Use Case:** Show progress bar
///
/// **Example:**
/// ```dart
/// final completion = ref.watch(nutritionEMRCompletionProvider);
/// LinearProgressIndicator(value: completion / 100);
/// Text('${completion.toStringAsFixed(0)}% complete');
/// ```
final AutoDisposeProvider<double> nutritionEMRCompletionProvider =
    Provider.autoDispose<double>((ref) {
      final state = ref.watch(nutritionEMRNotifierProvider);
      return state.completionPercentage;
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🧙 WIZARD COMPUTED PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Current Wizard Step Provider
///
/// **Returns:** Current active step number (1-8)
///
/// **Example:**
/// ```dart
/// final step = ref.watch(currentWizardStepProvider);
/// Text('Step $step of 8');
/// ```
final AutoDisposeProvider<int> currentWizardStepProvider =
    Provider.autoDispose<int>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.currentStep;
    });

/// Wizard Can Proceed Provider
///
/// **Returns:** True if current step is valid and can proceed
///
/// **Example:**
/// ```dart
/// final canProceed = ref.watch(wizardCanProceedProvider);
/// ElevatedButton(
///   onPressed: canProceed ? () => nextStep() : null,
///   child: Text('Next'),
/// );
/// ```
final AutoDisposeProvider<bool> wizardCanProceedProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.canProceed;
    });

/// Wizard Is First Step Provider
///
/// **Returns:** True if on first step
///
/// **Example:**
/// ```dart
/// final isFirst = ref.watch(wizardIsFirstStepProvider);
/// if (!isFirst) {
///   return BackButton();
/// }
/// ```
final AutoDisposeProvider<bool> wizardIsFirstStepProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.isFirstStep;
    });

/// Wizard Is Last Step Provider
///
/// **Returns:** True if on last step
///
/// **Example:**
/// ```dart
/// final isLast = ref.watch(wizardIsLastStepProvider);
/// Text(isLast ? 'Finish' : 'Next');
/// ```
final AutoDisposeProvider<bool> wizardIsLastStepProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.isLastStep;
    });

/// Wizard Completion Percentage Provider
///
/// **Returns:** Wizard completion (0-100)
///
/// **Example:**
/// ```dart
/// final completion = ref.watch(wizardCompletionProvider);
/// LinearProgressIndicator(value: completion / 100);
/// ```
final AutoDisposeProvider<double> wizardCompletionProvider =
    Provider.autoDispose<double>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.completionPercentage;
    });

/// Wizard Is Complete Provider
///
/// **Returns:** True if all 8 steps are completed
///
/// **Example:**
/// ```dart
/// final isComplete = ref.watch(wizardIsCompleteProvider);
/// if (isComplete) {
///   return CompleteButton(onPressed: () => finishWizard());
/// }
/// ```
final AutoDisposeProvider<bool> wizardIsCompleteProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.isComplete;
    });

/// Wizard Has Validation Error Provider
///
/// **Returns:** True if current step has validation error
///
/// **Example:**
/// ```dart
/// final hasError = ref.watch(wizardHasValidationErrorProvider);
/// if (hasError) {
///   final state = ref.watch(nutritionWizardNotifierProvider);
///   return ErrorText(state.validationError ?? '');
/// }
/// ```
final AutoDisposeProvider<bool> wizardHasValidationErrorProvider =
    Provider.autoDispose<bool>((ref) {
      final state = ref.watch(nutritionWizardNotifierProvider);
      return state.hasValidationError;
    });
