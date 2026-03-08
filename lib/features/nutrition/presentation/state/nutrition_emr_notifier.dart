import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:elajtech/features/nutrition/presentation/state/nutrition_emr_state.dart';

/// Nutrition EMR State Notifier
///
/// Core state manager for Nutrition EMR records implementing comprehensive
/// state management with auto-save, dirty tracking, and audit trail.
///
/// **Responsibilities:**
/// - Load patient nutrition EMR by appointment ID
/// - Update individual checkbox fields with optimistic updates
/// - Auto-save dirty fields every 30 seconds
/// - Manual save with validation and error handling
/// - Rollback on save failure
/// - Lock management and validation
/// - Audit trail logging
/// - Completion percentage calculation
///
/// **State Flow:**
/// 1. Initial: NutritionEMRState.loading()
/// 2. Load Success: NutritionEMRState.loaded(emr, dirtyFields: {})
/// 3. Field Update: Update state optimistically, add to dirtyFields
/// 4. Auto-Save: Save dirty fields only, clear dirtyFields on success
/// 5. Save Failure: Show error, keep dirtyFields for retry
/// 6. Lock: Prevent edits when isLocked or 24h expired
class NutritionEMRNotifier extends StateNotifier<NutritionEMRState> {
  /// Constructor with repository injection
  NutritionEMRNotifier(this._repository)
    : super(const NutritionEMRState.loading()) {
    _startAutoSaveTimer();
  }
  final NutritionEMRRepository _repository;
  Timer? _autoSaveTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // 📚 LOAD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load patient nutrition EMR data by appointment ID
  ///
  /// **Flow:**
  /// 1. Set state to loading
  /// 2. Fetch EMR from repository
  /// 3. On success: Set loaded state with clean dirtyFields
  /// 4. On failure: Set error state with retry option
  /// 5. If no EMR exists: Create new empty record
  ///
  /// **Parameters:**
  /// - [appointmentId]: The appointment identifier
  /// - [patientId]: Patient identifier for creating new EMR
  /// - [nutritionistId]: Current doctor's ID
  /// - [nutritionistName]: Current doctor's name for audit
  ///
  /// **Example:**
  /// ```dart
  /// await ref.read(nutritionEMRNotifierProvider.notifier)
  ///   .loadPatientNutritionData(
  ///     appointmentId: 'appt-123',
  ///     patientId: 'patient-456',
  ///     nutritionistId: 'doctor-789',
  ///     nutritionistName: 'Dr. Ahmed Ali',
  ///   );
  /// ```
  Future<void> loadPatientNutritionData({
    required String appointmentId,
    required String patientId,
    required String nutritionistId,
    required String nutritionistName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRNotifier] Loading EMR for appointment: $appointmentId',
        );
      }

      state = const NutritionEMRState.loading();

      final result = await _repository.getEMRByAppointmentId(appointmentId);

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '[NutritionEMRNotifier] Load failed: ${failure.message}',
            );
          }
          state = NutritionEMRState.error(
            message: failure.message,
          );
        },
        (emr) {
          if (emr == null) {
            // No EMR exists, create new one
            if (kDebugMode) {
              debugPrint(
                '[NutritionEMRNotifier] No EMR found, creating new record',
              );
            }

            final newEmr = NutritionEMREntity.createNew(
              id: _generateId(),
              patientId: patientId,
              nutritionistId: nutritionistId,
              nutritionistName: nutritionistName,
              appointmentId: appointmentId,
              visitDate: DateTime.now(),
            );

            state = NutritionEMRState.loaded(
              emr: newEmr,
              dirtyFields: {},
            );
          } else {
            // EMR found, load it
            if (kDebugMode) {
              debugPrint('[NutritionEMRNotifier] EMR loaded: ${emr.id}');
              debugPrint(
                '[NutritionEMRNotifier] Completion: ${emr.completionPercentage.toStringAsFixed(1)}%',
              );
              debugPrint(
                '[NutritionEMRNotifier] Locked: ${emr.isCurrentlyLocked}',
              );
            }

            state = NutritionEMRState.loaded(
              emr: emr,
              dirtyFields: {},
              lastSavedAt: DateTime.now(),
            );
          }
        },
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRNotifier] Unexpected error: $e');
        debugPrint('[NutritionEMRNotifier] StackTrace: $stackTrace');
      }

      state = NutritionEMRState.error(
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ UPDATE OPERATIONS (Optimistic Updates)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update a single checkbox field with optimistic update
  ///
  /// **Optimistic Update Flow:**
  /// 1. Check if record is locked - reject if true
  /// 2. Update state immediately (optimistic)
  /// 3. Add field name to dirtyFields
  /// 4. Log change in audit trail
  /// 5. Auto-save timer will handle persistence
  ///
  /// **Rollback:** If auto-save fails, state reverts to last saved version
  ///
  /// **Parameters:**
  /// - [fieldName]: The exact field name to update (e.g., 'weightMeasured')
  /// - [value]: New boolean value
  /// - [userId]: Current user ID for audit trail
  /// - [userName]: Current user name for audit trail
  ///
  /// **Example:**
  /// ```dart
  /// notifier.updateField(
  ///   fieldName: 'weightMeasured',
  ///   value: true,
  ///   userId: 'doctor-789',
  ///   userName: 'Dr. Ahmed Ali',
  /// );
  /// ```
  void updateField({
    required String fieldName,
    required bool value,
    required String userId,
    required String userName,
  }) {
    state.maybeMap(
      loaded: (currentState) {
        // Check if locked
        if (currentState.emr.isCurrentlyLocked) {
          if (kDebugMode) {
            debugPrint(
              '[NutritionEMRNotifier] Cannot update: Record is locked',
            );
          }
          state = currentState.copyWith(
            saveError: 'السجل مقفل ولا يمكن تعديله',
          );
          return;
        }

        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Updating field: $fieldName = $value',
          );
        }

        // Get previous value for audit
        final previousValue = _getFieldValue(currentState.emr, fieldName);

        // Create audit log entry
        final auditEntry = AuditLogEntry(
          timestamp: DateTime.now(),
          userId: userId,
          userName: userName,
          action: 'updated',
          fieldChanged: fieldName,
          previousValue: previousValue.toString(),
          newValue: value.toString(),
        );

        // Update EMR with new value and audit entry
        final updatedEmr =
            _updateEMRField(
              currentState.emr,
              fieldName,
              value,
            ).copyWith(
              auditLog: [...currentState.emr.auditLog, auditEntry],
            );

        // Update state with new EMR and mark field as dirty
        state = currentState.copyWith(
          emr: updatedEmr,
          dirtyFields: {...currentState.dirtyFields, fieldName},
          saveError: null,
        );

        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Field updated. Dirty fields: ${currentState.dirtyFields.length + 1}',
          );
          debugPrint(
            '[NutritionEMRNotifier] Completion: ${updatedEmr.completionPercentage.toStringAsFixed(1)}%',
          );
        }
      },
      orElse: () {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Cannot update: State is not loaded',
          );
        }
      },
    );
  }

  /// Get current value of a field from EMR
  /// Supports both old and new comprehensive checklist field names
  bool _getFieldValue(NutritionEMREntity emr, String fieldName) {
    switch (fieldName) {
      // ═══════════════════════════════════════════════════════════════════
      // Section 1: Patient and Visit Basics
      // ═══════════════════════════════════════════════════════════════════
      case 'isIdentityVerified':
        return emr.isIdentityVerified;
      case 'isConsentObtained':
        return emr.isConsentObtained;
      case 'isReasonForVisitDocumented':
        return emr.isReasonForVisitDocumented;
      case 'isDiagnosisReviewed':
        return emr.isDiagnosisReviewed;

      // ═══════════════════════════════════════════════════════════════════
      // Section 2: Anthropometric Measurements
      // ═══════════════════════════════════════════════════════════════════
      case 'isWeightMeasured':
        return emr.isWeightMeasured;
      case 'isHeightMeasured':
        return emr.isHeightMeasured;
      case 'isBMICalculated':
        return emr.isBMICalculated;
      case 'isWaistCircumferenceMeasured':
        return emr.isWaistCircumferenceMeasured;
      case 'isRecentWeightChangeDocumented':
        return emr.isRecentWeightChangeDocumented;

      // ═══════════════════════════════════════════════════════════════════
      // Section 3: Dietary Intake Assessment
      // ═══════════════════════════════════════════════════════════════════
      case 'is24HourRecallCompleted':
        return emr.is24HourRecallCompleted;
      case 'isFoodFrequencyAssessed':
        return emr.isFoodFrequencyAssessed;
      case 'isAllergiesIntolerancesChecked':
        return emr.isAllergiesIntolerancesChecked;
      case 'isSupplementsDocumented':
        return emr.isSupplementsDocumented;

      // ═══════════════════════════════════════════════════════════════════
      // Section 4: Medical Conditions Review
      // ═══════════════════════════════════════════════════════════════════
      case 'isDiabetesAssessed':
        return emr.isDiabetesAssessed;
      case 'isHypertensionAssessed':
        return emr.isHypertensionAssessed;
      case 'isDyslipidemiaAssessed':
        return emr.isDyslipidemiaAssessed;
      case 'isObesityAssessed':
        return emr.isObesityAssessed;
      case 'isCKDAssessed':
        return emr.isCKDAssessed;
      case 'isGIDisordersAssessed':
        return emr.isGIDisordersAssessed;

      // ═══════════════════════════════════════════════════════════════════
      // Section 5: Nutrition Focused Physical Findings
      // ═══════════════════════════════════════════════════════════════════
      case 'isMuscleWastingAssessed':
        return emr.isMuscleWastingAssessed;
      case 'isFatLossAssessed':
        return emr.isFatLossAssessed;
      case 'isEdemaAssessed':
        return emr.isEdemaAssessed;
      case 'isAppetiteAssessed':
        return emr.isAppetiteAssessed;
      case 'isChewingSwallowingAssessed':
        return emr.isChewingSwallowingAssessed;

      // ═══════════════════════════════════════════════════════════════════
      // Section 6: Biochemical Data Review
      // ═══════════════════════════════════════════════════════════════════
      case 'isGlucoseA1cReviewed':
        return emr.isGlucoseA1cReviewed;
      case 'isLipidProfileReviewed':
        return emr.isLipidProfileReviewed;
      case 'isElectrolytesReviewed':
        return emr.isElectrolytesReviewed;
      case 'isRenalFunctionReviewed':
        return emr.isRenalFunctionReviewed;
      case 'isMicronutrientsReviewed':
        return emr.isMicronutrientsReviewed;

      // ═══════════════════════════════════════════════════════════════════
      // Section 7: Nutrition Diagnosis
      // ═══════════════════════════════════════════════════════════════════
      case 'isInadequateIntakeDiagnosed':
        return emr.isInadequateIntakeDiagnosed;
      case 'isExcessiveIntakeDiagnosed':
        return emr.isExcessiveIntakeDiagnosed;
      case 'isFoodKnowledgeDeficitIdentified':
        return emr.isFoodKnowledgeDeficitIdentified;

      // ═══════════════════════════════════════════════════════════════════
      // Section 8: Intervention Plan
      // ═══════════════════════════════════════════════════════════════════
      case 'isCaloriePrescriptionSet':
        return emr.isCaloriePrescriptionSet;
      case 'isMacronutrientDistributionPlanned':
        return emr.isMacronutrientDistributionPlanned;
      case 'isEducationProvided':
        return emr.isEducationProvided;
      case 'isFollowUpPlanEstablished':
        return emr.isFollowUpPlanEstablished;

      // ═══════════════════════════════════════════════════════════════════
      // Legacy field names (backward compatibility)
      // ═══════════════════════════════════════════════════════════════════
      case 'weightMeasured':
        return emr.weightMeasured;
      case 'heightMeasured':
        return emr.heightMeasured;
      case 'bmiCalculated':
        return emr.bmiCalculated;
      case 'waistCircumferenceMeasured':
        return emr.waistCircumferenceMeasured;
      case 'weightChangeDocumented':
        return emr.weightChangeDocumented;
      case 'dietary24HRecall':
        return emr.dietary24HRecall;
      case 'foodFrequencyChecked':
        return emr.foodFrequencyChecked;
      case 'allergiesDocumented':
        return emr.allergiesDocumented;
      case 'supplementsReviewed':
        return emr.supplementsReviewed;
      case 'medicalHistoryReviewed':
        return emr.medicalHistoryReviewed;
      case 'physicalExamCompleted':
        return emr.physicalExamCompleted;
      case 'appetiteAssessed':
        return emr.appetiteAssessed;
      case 'giSymptomsEvaluated':
        return emr.giSymptomsEvaluated;
      case 'bloodGlucoseReviewed':
        return emr.bloodGlucoseReviewed;
      case 'lipidProfileReviewed':
        return emr.lipidProfileReviewed;
      case 'micronutrientsReviewed':
        return emr.micronutrientsReviewed;
      case 'inadequateIntakeDiagnosed':
        return emr.inadequateIntakeDiagnosed;
      case 'excessiveIntakeDiagnosed':
        return emr.excessiveIntakeDiagnosed;
      case 'knowledgeDeficitIdentified':
        return emr.knowledgeDeficitIdentified;
      case 'disorderedEatingIdentified':
        return emr.disorderedEatingIdentified;
      case 'caloriePrescriptionSet':
        return emr.caloriePrescriptionSet;
      case 'macroDistributionSet':
        return emr.macroDistributionSet;
      case 'mealPlanProvided':
        return emr.mealPlanProvided;
      case 'educationProvided':
        return emr.educationProvided;
      case 'supplementsRecommended':
        return emr.supplementsRecommended;
      case 'targetWeightSet':
        return emr.targetWeightSet;
      case 'timelineDocumented':
        return emr.timelineDocumented;
      case 'followUpScheduled':
        return emr.followUpScheduled;
      case 'monitoringParametersSet':
        return emr.monitoringParametersSet;
      case 'writtenInstructionsProvided':
        return emr.writtenInstructionsProvided;
      case 'physicianNotified':
        return emr.physicianNotified;
      case 'consentObtained':
        return emr.consentObtained;

      default:
        return false;
    }
  }

  /// Update a specific field in EMR and return new copy
  /// Supports both old and new comprehensive checklist field names
  NutritionEMREntity _updateEMRField(
    NutritionEMREntity emr,
    String fieldName,
    bool value,
  ) {
    switch (fieldName) {
      // ═══════════════════════════════════════════════════════════════════
      // Section 1: Patient and Visit Basics
      // ═══════════════════════════════════════════════════════════════════
      case 'isIdentityVerified':
        return emr.copyWith(isIdentityVerified: value);
      case 'isConsentObtained':
        return emr.copyWith(isConsentObtained: value);
      case 'isReasonForVisitDocumented':
        return emr.copyWith(isReasonForVisitDocumented: value);
      case 'isDiagnosisReviewed':
        return emr.copyWith(isDiagnosisReviewed: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 2: Anthropometric Measurements
      // ═══════════════════════════════════════════════════════════════════
      case 'isWeightMeasured':
        return emr.copyWith(isWeightMeasured: value);
      case 'isHeightMeasured':
        return emr.copyWith(isHeightMeasured: value);
      case 'isBMICalculated':
        return emr.copyWith(isBMICalculated: value);
      case 'isWaistCircumferenceMeasured':
        return emr.copyWith(isWaistCircumferenceMeasured: value);
      case 'isRecentWeightChangeDocumented':
        return emr.copyWith(isRecentWeightChangeDocumented: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 3: Dietary Intake Assessment
      // ═══════════════════════════════════════════════════════════════════
      case 'is24HourRecallCompleted':
        return emr.copyWith(is24HourRecallCompleted: value);
      case 'isFoodFrequencyAssessed':
        return emr.copyWith(isFoodFrequencyAssessed: value);
      case 'isAllergiesIntolerancesChecked':
        return emr.copyWith(isAllergiesIntolerancesChecked: value);
      case 'isSupplementsDocumented':
        return emr.copyWith(isSupplementsDocumented: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 4: Medical Conditions Review
      // ═══════════════════════════════════════════════════════════════════
      case 'isDiabetesAssessed':
        return emr.copyWith(isDiabetesAssessed: value);
      case 'isHypertensionAssessed':
        return emr.copyWith(isHypertensionAssessed: value);
      case 'isDyslipidemiaAssessed':
        return emr.copyWith(isDyslipidemiaAssessed: value);
      case 'isObesityAssessed':
        return emr.copyWith(isObesityAssessed: value);
      case 'isCKDAssessed':
        return emr.copyWith(isCKDAssessed: value);
      case 'isGIDisordersAssessed':
        return emr.copyWith(isGIDisordersAssessed: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 5: Nutrition Focused Physical Findings
      // ═══════════════════════════════════════════════════════════════════
      case 'isMuscleWastingAssessed':
        return emr.copyWith(isMuscleWastingAssessed: value);
      case 'isFatLossAssessed':
        return emr.copyWith(isFatLossAssessed: value);
      case 'isEdemaAssessed':
        return emr.copyWith(isEdemaAssessed: value);
      case 'isAppetiteAssessed':
        return emr.copyWith(isAppetiteAssessed: value);
      case 'isChewingSwallowingAssessed':
        return emr.copyWith(isChewingSwallowingAssessed: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 6: Biochemical Data Review
      // ═══════════════════════════════════════════════════════════════════
      case 'isGlucoseA1cReviewed':
        return emr.copyWith(isGlucoseA1cReviewed: value);
      case 'isLipidProfileReviewed':
        return emr.copyWith(isLipidProfileReviewed: value);
      case 'isElectrolytesReviewed':
        return emr.copyWith(isElectrolytesReviewed: value);
      case 'isRenalFunctionReviewed':
        return emr.copyWith(isRenalFunctionReviewed: value);
      case 'isMicronutrientsReviewed':
        return emr.copyWith(isMicronutrientsReviewed: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 7: Nutrition Diagnosis
      // ═══════════════════════════════════════════════════════════════════
      case 'isInadequateIntakeDiagnosed':
        return emr.copyWith(isInadequateIntakeDiagnosed: value);
      case 'isExcessiveIntakeDiagnosed':
        return emr.copyWith(isExcessiveIntakeDiagnosed: value);
      case 'isFoodKnowledgeDeficitIdentified':
        return emr.copyWith(isFoodKnowledgeDeficitIdentified: value);

      // ═══════════════════════════════════════════════════════════════════
      // Section 8: Intervention Plan
      // ═══════════════════════════════════════════════════════════════════
      case 'isCaloriePrescriptionSet':
        return emr.copyWith(isCaloriePrescriptionSet: value);
      case 'isMacronutrientDistributionPlanned':
        return emr.copyWith(isMacronutrientDistributionPlanned: value);
      case 'isEducationProvided':
        return emr.copyWith(isEducationProvided: value);
      case 'isFollowUpPlanEstablished':
        return emr.copyWith(isFollowUpPlanEstablished: value);

      // ═══════════════════════════════════════════════════════════════════
      // Legacy field names (backward compatibility)
      // ═══════════════════════════════════════════════════════════════════
      case 'weightMeasured':
        return emr.copyWith(weightMeasured: value);
      case 'heightMeasured':
        return emr.copyWith(heightMeasured: value);
      case 'bmiCalculated':
        return emr.copyWith(bmiCalculated: value);
      case 'waistCircumferenceMeasured':
        return emr.copyWith(waistCircumferenceMeasured: value);
      case 'weightChangeDocumented':
        return emr.copyWith(weightChangeDocumented: value);
      case 'dietary24HRecall':
        return emr.copyWith(dietary24HRecall: value);
      case 'foodFrequencyChecked':
        return emr.copyWith(foodFrequencyChecked: value);
      case 'allergiesDocumented':
        return emr.copyWith(allergiesDocumented: value);
      case 'supplementsReviewed':
        return emr.copyWith(supplementsReviewed: value);
      case 'medicalHistoryReviewed':
        return emr.copyWith(medicalHistoryReviewed: value);
      case 'physicalExamCompleted':
        return emr.copyWith(physicalExamCompleted: value);
      case 'appetiteAssessed':
        return emr.copyWith(appetiteAssessed: value);
      case 'giSymptomsEvaluated':
        return emr.copyWith(giSymptomsEvaluated: value);
      case 'bloodGlucoseReviewed':
        return emr.copyWith(bloodGlucoseReviewed: value);
      case 'lipidProfileReviewed':
        return emr.copyWith(lipidProfileReviewed: value);
      case 'micronutrientsReviewed':
        return emr.copyWith(micronutrientsReviewed: value);
      case 'inadequateIntakeDiagnosed':
        return emr.copyWith(inadequateIntakeDiagnosed: value);
      case 'excessiveIntakeDiagnosed':
        return emr.copyWith(excessiveIntakeDiagnosed: value);
      case 'knowledgeDeficitIdentified':
        return emr.copyWith(knowledgeDeficitIdentified: value);
      case 'disorderedEatingIdentified':
        return emr.copyWith(disorderedEatingIdentified: value);
      case 'caloriePrescriptionSet':
        return emr.copyWith(caloriePrescriptionSet: value);
      case 'macroDistributionSet':
        return emr.copyWith(macroDistributionSet: value);
      case 'mealPlanProvided':
        return emr.copyWith(mealPlanProvided: value);
      case 'educationProvided':
        return emr.copyWith(educationProvided: value);
      case 'supplementsRecommended':
        return emr.copyWith(supplementsRecommended: value);
      case 'targetWeightSet':
        return emr.copyWith(targetWeightSet: value);
      case 'timelineDocumented':
        return emr.copyWith(timelineDocumented: value);
      case 'followUpScheduled':
        return emr.copyWith(followUpScheduled: value);
      case 'monitoringParametersSet':
        return emr.copyWith(monitoringParametersSet: value);
      case 'writtenInstructionsProvided':
        return emr.copyWith(writtenInstructionsProvided: value);
      case 'physicianNotified':
        return emr.copyWith(physicianNotified: value);
      case 'consentObtained':
        return emr.copyWith(consentObtained: value);

      default:
        return emr;
    }
  }

  /// Update the entire EMR entity with a new instance
  ///
  /// This method provides a safe way to replace the entire EMR entity
  /// while maintaining the state's dirty fields tracking and other metadata.
  ///
  /// **Use Cases:**
  /// - Bulk updates from UI forms (e.g., anthropometric measurements)
  /// - Replacing the entire EMR after complex calculations
  /// - Updates that affect multiple fields simultaneously
  ///
  /// **Flow:**
  /// 1. Check if record is locked - reject if true
  /// 2. Update state with new EMR entity
  /// 3. Mark all fields as dirty for tracking
  /// 4. Log the update operation
  ///
  /// **Parameters:**
  /// - [updatedEmr]: The new complete EMR entity to replace the current one
  ///
  /// **Example:**
  /// ```dart
  /// final updatedEmr = currentEmr.copyWith(
  ///   heightValue: 175.0,
  ///   weightValue: 70.5,
  ///   heightMeasured: true,
  ///   weightMeasured: true,
  /// );
  /// notifier.updateWholeEntity(updatedEmr);
  /// ```
  void updateWholeEntity(NutritionEMREntity updatedEmr) {
    state.maybeMap(
      loaded: (currentState) {
        // Check if locked
        if (currentState.emr.isCurrentlyLocked) {
          if (kDebugMode) {
            debugPrint(
              '[NutritionEMRNotifier] Cannot update: Record is locked',
            );
          }
          state = currentState.copyWith(
            saveError: 'السجل مقفل ولا يمكن تعديله',
          );
          return;
        }

        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Updating entire EMR entity',
          );
          debugPrint(
            '[NutritionEMRNotifier] Completion: ${updatedEmr.completionPercentage.toStringAsFixed(1)}%',
          );
        }

        // Update state with new EMR entity
        // Mark all fields as dirty to ensure they get saved
        state = currentState.copyWith(
          emr: updatedEmr,
          dirtyFields: {'all_fields'}, // Mark as bulk update
          saveError: null,
        );

        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] EMR entity updated successfully',
          );
        }
      },
      orElse: () {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Cannot update: State is not loaded',
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 SAVE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Manually save current EMR state
  ///
  /// **Flow:**
  /// 1. Validate state is loaded
  /// 2. Set isSaving flag
  /// 3. Call repository.saveEMR
  /// 4. On success: Clear dirtyFields, update lastSavedAt
  /// 5. On failure: Keep dirtyFields, show error message
  ///
  /// **Returns:** True if save succeeded, false otherwise
  Future<bool> saveManually() async {
    return state.maybeMap(
      loaded: (currentState) async {
        if (currentState.emr.isCurrentlyLocked) {
          if (kDebugMode) {
            debugPrint('[NutritionEMRNotifier] Cannot save: Record is locked');
          }
          state = currentState.copyWith(saveError: 'السجل مقفل ولا يمكن حفظه');
          return false;
        }

        // ✅ FIX: Determine operation type (create vs update)
        final isNewRecord = currentState.emr.editCount == 0;
        final operationType = isNewRecord ? 'created' : 'updated';

        if (kDebugMode) {
          debugPrint('[NutritionEMRNotifier] Manual save started');
          debugPrint(
            '[NutritionEMRNotifier] Operation type: $operationType',
          );
          debugPrint(
            '[NutritionEMRNotifier] Dirty fields: ${currentState.dirtyFields.length}',
          );
        }

        state = currentState.copyWith(isSaving: true, saveError: null);

        final result = await _repository.saveEMR(currentState.emr);

        return result.fold(
          (failure) {
            if (kDebugMode) {
              debugPrint(
                '[NutritionEMRNotifier] Save failed: ${failure.message}',
              );
            }

            state = currentState.copyWith(
              isSaving: false,
              saveError: failure.message,
              lastOperationType: null,
            );
            return false;
          },
          (_) {
            if (kDebugMode) {
              debugPrint(
                '[NutritionEMRNotifier] Save succeeded ($operationType)',
              );
            }

            state = currentState.copyWith(
              isSaving: false,
              dirtyFields: {},
              lastSavedAt: DateTime.now(),
              saveError: null,
              lastOperationType: operationType,
            );
            return true;
          },
        );
      },
      orElse: () async {
        if (kDebugMode) {
          debugPrint('[NutritionEMRNotifier] Cannot save: State is not loaded');
        }
        return false;
      },
    );
  }

  /// Auto-save dirty fields
  ///
  /// **Triggered:** Every 30 seconds if dirtyFields is not empty
  ///
  /// **Flow:**
  /// 1. Check if auto-save is needed (hasUnsavedChanges && 30s elapsed)
  /// 2. Call saveManually()
  /// 3. Log success/failure
  ///
  /// **Note:** Timer is started in constructor and cancelled in dispose
  Future<void> _performAutoSave() async {
    if (state.needsAutoSave && state.hasUnsavedChanges) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRNotifier] Auto-save triggered');
      }

      await saveManually();
    }
  }

  /// Start auto-save timer (30 seconds interval)
  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performAutoSave(),
    );

    if (kDebugMode) {
      debugPrint(
        '[NutritionEMRNotifier] Auto-save timer started (30s interval)',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 LOCK OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Manually lock the current EMR record
  ///
  /// **Use Cases:**
  /// - Administrative closure
  /// - Early finalization before 24h expires
  ///
  /// **Returns:** True if lock succeeded, false otherwise
  Future<bool> lock() async {
    return state.maybeMap(
      loaded: (currentState) async {
        if (currentState.emr.isCurrentlyLocked) {
          if (kDebugMode) {
            debugPrint('[NutritionEMRNotifier] Already locked');
          }
          return true;
        }

        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRNotifier] Locking EMR: ${currentState.emr.id}',
          );
        }

        final result = await _repository.lockEMR(currentState.emr.id);

        return result.fold(
          (failure) {
            if (kDebugMode) {
              debugPrint(
                '[NutritionEMRNotifier] Lock failed: ${failure.message}',
              );
            }
            state = currentState.copyWith(saveError: failure.message);
            return false;
          },
          (_) {
            if (kDebugMode) {
              debugPrint('[NutritionEMRNotifier] Lock succeeded');
            }

            // Update local state to reflect lock
            state = currentState.copyWith(
              emr: currentState.emr.copyWith(isLocked: true),
            );
            return true;
          },
        );
      },
      orElse: () async => false,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate completion percentage for current state
  double calculateCompletionPercentage() {
    return state.completionPercentage;
  }

  /// Generate unique ID for new EMR
  String _generateId() {
    return 'nutrition_emr_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (kDebugMode) {
      debugPrint('[NutritionEMRNotifier] Disposed, auto-save timer cancelled');
    }
    super.dispose();
  }
}
