import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';

part 'nutrition_emr_state.freezed.dart';

/// Nutrition EMR State
///
/// Comprehensive state model for managing Nutrition EMR records in the presentation layer.
/// Uses Freezed for immutability and copyWith support.
///
/// **State Categories:**
/// - Loading: Initial data fetch
/// - Loaded: EMR data successfully loaded with dirty tracking
/// - Error: Failed to load or save data
///
/// **Features:**
/// - Dirty Fields Tracking: Monitors which fields have been modified
/// - Auto-Save Timer: Tracks last save time for auto-save logic
/// - Lock Management: Prevents editing locked records
/// - Audit Trail: Maintains change history
/// - Completion Tracking: Calculates progress percentage
@freezed
class NutritionEMRState with _$NutritionEMRState {
  /// Loading state - initial data fetch in progress
  const factory NutritionEMRState.loading() = _Loading;

  /// Loaded state - EMR data available with full editing capabilities
  ///
  /// **Parameters:**
  /// - [emr]: Current EMR entity with all 32 fields
  /// - [dirtyFields]: Set of field names that have been modified since last save
  /// - [lastSavedAt]: Timestamp of last successful save (for auto-save timer)
  /// - [isSaving]: True when save operation is in progress
  /// - [saveError]: Error message if last save failed
  const factory NutritionEMRState.loaded({
    required NutritionEMREntity emr,
    @Default({}) Set<String> dirtyFields,
    DateTime? lastSavedAt,
    @Default(false) bool isSaving,
    String? saveError,

    /// ✅ FIX: Track last operation type for success messages
    /// Values: 'created', 'updated', null
    String? lastOperationType,
  }) = _Loaded;

  /// Error state - failed to load EMR data
  ///
  /// **Parameters:**
  /// - [message]: User-friendly error message
  /// - [canRetry]: Whether retry is possible (true for network errors, false for validation errors)
  const factory NutritionEMRState.error({
    required String message,
    @Default(true) bool canRetry,
  }) = _Error;

  const NutritionEMRState._();

  /// Check if state is currently loading
  bool get isLoading => this is _Loading;

  /// Check if state has loaded data
  bool get isLoaded => this is _Loaded;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Get EMR entity if state is loaded, otherwise null
  NutritionEMREntity? get emrOrNull => maybeMap(
    loaded: (state) => state.emr,
    orElse: () => null,
  );

  /// Check if there are unsaved changes
  bool get hasUnsavedChanges => maybeMap(
    loaded: (state) => state.dirtyFields.isNotEmpty,
    orElse: () => false,
  );

  /// Get number of unsaved changes
  int get unsavedChangesCount => maybeMap(
    loaded: (state) => state.dirtyFields.length,
    orElse: () => 0,
  );

  /// Check if EMR is currently locked
  bool get isLocked => maybeMap(
    loaded: (state) => state.emr.isCurrentlyLocked,
    orElse: () => false,
  );

  /// Get remaining edit hours
  int get remainingEditHours => maybeMap(
    loaded: (state) => state.emr.remainingEditHours,
    orElse: () => 0,
  );

  /// Get completion percentage
  double get completionPercentage => maybeMap(
    loaded: (state) => state.emr.completionPercentage,
    orElse: () => 0.0,
  );

  /// Check if auto-save is needed (30 seconds since last save)
  bool get needsAutoSave => maybeMap(
    loaded: (state) {
      if (state.dirtyFields.isEmpty) return false;
      if (state.lastSavedAt == null) return true;

      final timeSinceLastSave = DateTime.now().difference(state.lastSavedAt!);
      return timeSinceLastSave.inSeconds >= 30;
    },
    orElse: () => false,
  );

  /// ✅ FIX: Get last operation type (created/updated) for success messages
  String? get lastOperationType => maybeMap(
    loaded: (state) => state.lastOperationType,
    orElse: () => null,
  );
}
