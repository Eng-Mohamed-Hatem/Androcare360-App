import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:flutter/foundation.dart';

/// Nutrition EMR Data Model
///
/// Data Layer converter that provides bidirectional conversion between
/// Domain Entity ([NutritionEMREntity]) and Firestore JSON.
///
/// **Database**: elajtech (mandatory databaseId)
/// **Collection**: nutrition_emrs
///
/// This model handles:
/// - Entity to JSON conversion for Firestore writes (entityToFirestore)
/// - JSON to Entity conversion for Firestore reads (firestoreToEntity)
/// - Server timestamp injection for audit trail accuracy
/// - Null-safety for optional fields
/// - Type-safe Timestamp to DateTime conversion
///
/// Since [NutritionEMREntity] is a Freezed class, this model works as a
/// pure converter and does not extend the entity.
class NutritionEMRModel {
  NutritionEMRModel._();

  // ═══════════════════════════════════════════════════════════════════════════
  // 📤 CONVERSION: ENTITY → FIRESTORE JSON
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert Domain Entity to Firestore JSON
  ///
  /// **CRITICAL SERVER TIMESTAMP RULES:**
  /// - Uses [FieldValue.serverTimestamp()] for visitDate and updatedAt
  /// - This ensures 24-hour lock calculation uses Google Cloud time
  /// - Prevents client-side time manipulation attacks
  /// - Guarantees timezone-independent timestamps
  /// - Enables accurate audit trail sequencing
  ///
  /// **Why server timestamps?**
  /// 1. Lock mechanism depends on accurate time difference calculation
  /// 2. Doctor's device time may be incorrect or tampered with
  /// 3. Multi-timezone clinics need standardized time reference
  /// 4. Audit trail must have server-verifiable chronology
  static Map<String, dynamic> entityToFirestore(NutritionEMREntity entity) {
    return {
      // Identity fields
      'id': entity.id,
      'patientId': entity.patientId,
      'nutritionistId': entity.nutritionistId,
      'nutritionistName': entity.nutritionistName,
      'appointmentId': entity.appointmentId,

      // Timestamps - CRITICAL: Use server timestamps
      'visitDate': FieldValue.serverTimestamp(),
      'createdAt': entity.createdAt.millisecondsSinceEpoch > 0
          ? Timestamp.fromDate(entity.createdAt)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      // Security fields
      'isLocked': entity.isLocked,
      'lockedUntil': entity.lockedUntil != null
          ? Timestamp.fromDate(entity.lockedUntil!)
          : null,
      'isFirstVisit': entity.isFirstVisit,

      // Section 1: Anthropometric Measurements
      'weightMeasured': entity.weightMeasured,
      'heightMeasured': entity.heightMeasured,
      'bmiCalculated': entity.bmiCalculated,
      'waistCircumferenceMeasured': entity.waistCircumferenceMeasured,
      'weightChangeDocumented': entity.weightChangeDocumented,

      // Anthropometric Measurement Values (Numeric Data)
      'heightValue': entity.heightValue,
      'weightValue': entity.weightValue,
      'waistCircumferenceValue': entity.waistCircumferenceValue,
      'hipCircumferenceValue': entity.hipCircumferenceValue,

      // Section 2: Dietary Assessment
      'dietary24HRecall': entity.dietary24HRecall,
      'foodFrequencyChecked': entity.foodFrequencyChecked,
      'allergiesDocumented': entity.allergiesDocumented,
      'supplementsReviewed': entity.supplementsReviewed,

      // Section 3: Clinical Assessment
      'medicalHistoryReviewed': entity.medicalHistoryReviewed,
      'physicalExamCompleted': entity.physicalExamCompleted,
      'appetiteAssessed': entity.appetiteAssessed,
      'giSymptomsEvaluated': entity.giSymptomsEvaluated,

      // Section 4: Lab Results Review
      'bloodGlucoseReviewed': entity.bloodGlucoseReviewed,
      'lipidProfileReviewed': entity.lipidProfileReviewed,
      'micronutrientsReviewed': entity.micronutrientsReviewed,

      // Section 5: Nutrition Diagnosis
      'inadequateIntakeDiagnosed': entity.inadequateIntakeDiagnosed,
      'excessiveIntakeDiagnosed': entity.excessiveIntakeDiagnosed,
      'knowledgeDeficitIdentified': entity.knowledgeDeficitIdentified,
      'disorderedEatingIdentified': entity.disorderedEatingIdentified,

      // Section 6: Nutrition Intervention
      'caloriePrescriptionSet': entity.caloriePrescriptionSet,
      'macroDistributionSet': entity.macroDistributionSet,
      'mealPlanProvided': entity.mealPlanProvided,
      'educationProvided': entity.educationProvided,
      'supplementsRecommended': entity.supplementsRecommended,

      // Section 7: Monitoring and Evaluation
      'targetWeightSet': entity.targetWeightSet,
      'timelineDocumented': entity.timelineDocumented,
      'followUpScheduled': entity.followUpScheduled,
      'monitoringParametersSet': entity.monitoringParametersSet,

      // Section 8: Documentation and Communication
      'writtenInstructionsProvided': entity.writtenInstructionsProvided,
      'physicianNotified': entity.physicianNotified,
      'consentObtained': entity.consentObtained,

      // Metadata
      'specialization': entity.specialization,
      'auditLog': entity.auditLog.map(_auditEntryToFirestore).toList(),

      // ═══════════════════════════════════════════════════════════════════
      // COMPREHENSIVE CHECKLIST FIELDS
      // ═══════════════════════════════════════════════════════════════════

      // Section 1: Patient and Visit Basics
      'isIdentityVerified': entity.isIdentityVerified,
      'isConsentObtained': entity.isConsentObtained,
      'isReasonForVisitDocumented': entity.isReasonForVisitDocumented,
      'isDiagnosisReviewed': entity.isDiagnosisReviewed,

      // Section 2: Anthropometric Measurements
      'isWeightMeasured': entity.isWeightMeasured,
      'isHeightMeasured': entity.isHeightMeasured,
      'isBMICalculated': entity.isBMICalculated,
      'isWaistCircumferenceMeasured': entity.isWaistCircumferenceMeasured,
      'isRecentWeightChangeDocumented': entity.isRecentWeightChangeDocumented,

      // Section 3: Dietary Intake Assessment
      'is24HourRecallCompleted': entity.is24HourRecallCompleted,
      'isFoodFrequencyAssessed': entity.isFoodFrequencyAssessed,
      'isAllergiesIntolerancesChecked': entity.isAllergiesIntolerancesChecked,
      'isSupplementsDocumented': entity.isSupplementsDocumented,

      // Section 4: Medical Conditions Review
      'isDiabetesAssessed': entity.isDiabetesAssessed,
      'isHypertensionAssessed': entity.isHypertensionAssessed,
      'isDyslipidemiaAssessed': entity.isDyslipidemiaAssessed,
      'isObesityAssessed': entity.isObesityAssessed,
      'isCKDAssessed': entity.isCKDAssessed,
      'isGIDisordersAssessed': entity.isGIDisordersAssessed,

      // Section 5: Nutrition Focused Physical Findings
      'isMuscleWastingAssessed': entity.isMuscleWastingAssessed,
      'isFatLossAssessed': entity.isFatLossAssessed,
      'isEdemaAssessed': entity.isEdemaAssessed,
      'isAppetiteAssessed': entity.isAppetiteAssessed,
      'isChewingSwallowingAssessed': entity.isChewingSwallowingAssessed,

      // Section 6: Biochemical Data Review
      'isGlucoseA1cReviewed': entity.isGlucoseA1cReviewed,
      'isLipidProfileReviewed': entity.isLipidProfileReviewed,
      'isElectrolytesReviewed': entity.isElectrolytesReviewed,
      'isRenalFunctionReviewed': entity.isRenalFunctionReviewed,
      'isMicronutrientsReviewed': entity.isMicronutrientsReviewed,

      // Section 7: Nutrition Diagnosis
      'isInadequateIntakeDiagnosed': entity.isInadequateIntakeDiagnosed,
      'isExcessiveIntakeDiagnosed': entity.isExcessiveIntakeDiagnosed,
      'isFoodKnowledgeDeficitIdentified':
          entity.isFoodKnowledgeDeficitIdentified,

      // Section 8: Intervention Plan
      'isCaloriePrescriptionSet': entity.isCaloriePrescriptionSet,
      'isMacronutrientDistributionPlanned':
          entity.isMacronutrientDistributionPlanned,
      'isEducationProvided': entity.isEducationProvided,
      'isFollowUpPlanEstablished': entity.isFollowUpPlanEstablished,

      // Additional security fields
      'editCount': entity.editCount,
      'lastEditedBy': entity.lastEditedBy,
      'lastEditedByName': entity.lastEditedByName,
    };
  }

  /// Convert AuditLogEntry to Firestore JSON
  ///
  /// Helper method to serialize audit log entries for Firestore.
  static Map<String, dynamic> _auditEntryToFirestore(AuditLogEntry entry) {
    return {
      'timestamp': Timestamp.fromDate(entry.timestamp),
      'userId': entry.userId,
      'userName': entry.userName,
      'action': entry.action,
      'fieldChanged': entry.fieldChanged,
      'previousValue': entry.previousValue,
      'newValue': entry.newValue,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📥 CONVERSION: FIRESTORE JSON → ENTITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert Firestore JSON to Domain Entity
  ///
  /// **CRITICAL SAFETY RULES:**
  /// 1. Always check snapshot.exists before calling this
  /// 2. Wrap in try-catch to handle malformed data
  /// 3. Convert Timestamp objects to DateTime safely
  /// 4. Provide default values for missing fields
  /// 5. Handle empty or null auditLog arrays
  ///
  /// This method handles backwards compatibility with older records.
  static NutritionEMREntity firestoreToEntity(Map<String, dynamic> json) {
    try {
      // Helper function to safely convert Timestamp to DateTime
      DateTime? parseTimestamp(dynamic value) {
        if (value == null) return null;
        if (value is Timestamp) return value.toDate();
        if (value is DateTime) return value;
        return null;
      }

      // Helper function to parse audit log safely
      List<AuditLogEntry> parseAuditLog(dynamic value) {
        if (value == null) return [];
        if (value is! List) return [];

        try {
          return value
              .map(
                (entry) =>
                    AuditLogEntry.fromJson(entry as Map<String, dynamic>),
              )
              .toList();
        } on Exception catch (e) {
          if (kDebugMode) {
            debugPrint('[NutritionEMRModel] Error parsing audit log: $e');
          }
          return [];
        }
      }

      return NutritionEMREntity(
        // Required fields
        id: json['id'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        nutritionistId: json['nutritionistId'] as String? ?? '',
        nutritionistName: json['nutritionistName'] as String? ?? '',
        appointmentId: json['appointmentId'] as String? ?? '',
        visitDate: parseTimestamp(json['visitDate']) ?? DateTime.now(),
        createdAt: parseTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseTimestamp(json['updatedAt']) ?? DateTime.now(),

        // Security fields
        isLocked: json['isLocked'] as bool? ?? false,
        lockedUntil: parseTimestamp(json['lockedUntil']),
        isFirstVisit: json['isFirstVisit'] as bool? ?? true,

        // Section 1: Anthropometric Measurements
        weightMeasured: json['weightMeasured'] as bool? ?? false,
        heightMeasured: json['heightMeasured'] as bool? ?? false,
        bmiCalculated: json['bmiCalculated'] as bool? ?? false,
        waistCircumferenceMeasured:
            json['waistCircumferenceMeasured'] as bool? ?? false,
        weightChangeDocumented:
            json['weightChangeDocumented'] as bool? ?? false,

        // Anthropometric Measurement Values (Numeric Data)
        heightValue: json['heightValue'] as double?,
        weightValue: json['weightValue'] as double?,
        waistCircumferenceValue: json['waistCircumferenceValue'] as double?,
        hipCircumferenceValue: json['hipCircumferenceValue'] as double?,

        // Section 2: Dietary Assessment
        dietary24HRecall: json['dietary24HRecall'] as bool? ?? false,
        foodFrequencyChecked: json['foodFrequencyChecked'] as bool? ?? false,
        allergiesDocumented: json['allergiesDocumented'] as bool? ?? false,
        supplementsReviewed: json['supplementsReviewed'] as bool? ?? false,

        // Section 3: Clinical Assessment
        medicalHistoryReviewed:
            json['medicalHistoryReviewed'] as bool? ?? false,
        physicalExamCompleted: json['physicalExamCompleted'] as bool? ?? false,
        appetiteAssessed: json['appetiteAssessed'] as bool? ?? false,
        giSymptomsEvaluated: json['giSymptomsEvaluated'] as bool? ?? false,

        // Section 4: Lab Results Review
        bloodGlucoseReviewed: json['bloodGlucoseReviewed'] as bool? ?? false,
        lipidProfileReviewed: json['lipidProfileReviewed'] as bool? ?? false,
        micronutrientsReviewed:
            json['micronutrientsReviewed'] as bool? ?? false,

        // Section 5: Nutrition Diagnosis
        inadequateIntakeDiagnosed:
            json['inadequateIntakeDiagnosed'] as bool? ?? false,
        excessiveIntakeDiagnosed:
            json['excessiveIntakeDiagnosed'] as bool? ?? false,
        knowledgeDeficitIdentified:
            json['knowledgeDeficitIdentified'] as bool? ?? false,
        disorderedEatingIdentified:
            json['disorderedEatingIdentified'] as bool? ?? false,

        // Section 6: Nutrition Intervention
        caloriePrescriptionSet:
            json['caloriePrescriptionSet'] as bool? ?? false,
        macroDistributionSet: json['macroDistributionSet'] as bool? ?? false,
        mealPlanProvided: json['mealPlanProvided'] as bool? ?? false,
        educationProvided: json['educationProvided'] as bool? ?? false,
        supplementsRecommended:
            json['supplementsRecommended'] as bool? ?? false,

        // Section 7: Monitoring and Evaluation
        targetWeightSet: json['targetWeightSet'] as bool? ?? false,
        timelineDocumented: json['timelineDocumented'] as bool? ?? false,
        followUpScheduled: json['followUpScheduled'] as bool? ?? false,
        monitoringParametersSet:
            json['monitoringParametersSet'] as bool? ?? false,

        // Section 8: Documentation and Communication
        writtenInstructionsProvided:
            json['writtenInstructionsProvided'] as bool? ?? false,
        physicianNotified: json['physicianNotified'] as bool? ?? false,
        consentObtained: json['consentObtained'] as bool? ?? false,

        // ═════════════════════════════════════════════════════════════════
        // COMPREHENSIVE CHECKLIST FIELDS
        // ═════════════════════════════════════════════════════════════════

        // Section 1: Patient and Visit Basics
        isIdentityVerified: json['isIdentityVerified'] as bool? ?? false,
        isConsentObtained: json['isConsentObtained'] as bool? ?? false,
        isReasonForVisitDocumented:
            json['isReasonForVisitDocumented'] as bool? ?? false,
        isDiagnosisReviewed: json['isDiagnosisReviewed'] as bool? ?? false,

        // Section 2: Anthropometric Measurements
        isWeightMeasured: json['isWeightMeasured'] as bool? ?? false,
        isHeightMeasured: json['isHeightMeasured'] as bool? ?? false,
        isBMICalculated: json['isBMICalculated'] as bool? ?? false,
        isWaistCircumferenceMeasured:
            json['isWaistCircumferenceMeasured'] as bool? ?? false,
        isRecentWeightChangeDocumented:
            json['isRecentWeightChangeDocumented'] as bool? ?? false,

        // Section 3: Dietary Intake Assessment
        is24HourRecallCompleted:
            json['is24HourRecallCompleted'] as bool? ?? false,
        isFoodFrequencyAssessed:
            json['isFoodFrequencyAssessed'] as bool? ?? false,
        isAllergiesIntolerancesChecked:
            json['isAllergiesIntolerancesChecked'] as bool? ?? false,
        isSupplementsDocumented:
            json['isSupplementsDocumented'] as bool? ?? false,

        // Section 4: Medical Conditions Review
        isDiabetesAssessed: json['isDiabetesAssessed'] as bool? ?? false,
        isHypertensionAssessed:
            json['isHypertensionAssessed'] as bool? ?? false,
        isDyslipidemiaAssessed:
            json['isDyslipidemiaAssessed'] as bool? ?? false,
        isObesityAssessed: json['isObesityAssessed'] as bool? ?? false,
        isCKDAssessed: json['isCKDAssessed'] as bool? ?? false,
        isGIDisordersAssessed: json['isGIDisordersAssessed'] as bool? ?? false,

        // Section 5: Nutrition Focused Physical Findings
        isMuscleWastingAssessed:
            json['isMuscleWastingAssessed'] as bool? ?? false,
        isFatLossAssessed: json['isFatLossAssessed'] as bool? ?? false,
        isEdemaAssessed: json['isEdemaAssessed'] as bool? ?? false,
        isAppetiteAssessed: json['isAppetiteAssessed'] as bool? ?? false,
        isChewingSwallowingAssessed:
            json['isChewingSwallowingAssessed'] as bool? ?? false,

        // Section 6: Biochemical Data Review
        isGlucoseA1cReviewed: json['isGlucoseA1cReviewed'] as bool? ?? false,
        isLipidProfileReviewed:
            json['isLipidProfileReviewed'] as bool? ?? false,
        isElectrolytesReviewed:
            json['isElectrolytesReviewed'] as bool? ?? false,
        isRenalFunctionReviewed:
            json['isRenalFunctionReviewed'] as bool? ?? false,
        isMicronutrientsReviewed:
            json['isMicronutrientsReviewed'] as bool? ?? false,

        // Section 7: Nutrition Diagnosis
        isInadequateIntakeDiagnosed:
            json['isInadequateIntakeDiagnosed'] as bool? ?? false,
        isExcessiveIntakeDiagnosed:
            json['isExcessiveIntakeDiagnosed'] as bool? ?? false,
        isFoodKnowledgeDeficitIdentified:
            json['isFoodKnowledgeDeficitIdentified'] as bool? ?? false,

        // Section 8: Intervention Plan
        isCaloriePrescriptionSet:
            json['isCaloriePrescriptionSet'] as bool? ?? false,
        isMacronutrientDistributionPlanned:
            json['isMacronutrientDistributionPlanned'] as bool? ?? false,
        isEducationProvided: json['isEducationProvided'] as bool? ?? false,
        isFollowUpPlanEstablished:
            json['isFollowUpPlanEstablished'] as bool? ?? false,

        // Additional security fields
        editCount: json['editCount'] as int? ?? 0,
        lastEditedBy: json['lastEditedBy'] as String?,
        lastEditedByName: json['lastEditedByName'] as String?,

        // Metadata
        specialization:
            json['specialization'] as String? ??
            'عيادة السمنة والتغذية العلاجية',
        auditLog: parseAuditLog(json['auditLog']),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRModel] Error parsing JSON: $e');
        debugPrint('[NutritionEMRModel] StackTrace: $stackTrace');
        debugPrint('[NutritionEMRModel] JSON data: $json');
      }
      rethrow;
    }
  }
}
