import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_emr_entity.freezed.dart';
part 'nutrition_emr_entity.g.dart';

/// Simplified Nutrition EMR Entity
///
/// Clean Architecture Domain Entity representing a nutrition clinical record
/// with 32 checkbox boolean fields distributed across 8 clinical sections.
///
/// **Database**: elajtech
/// **Collection**: nutrition_emrs
/// **Security**: 24-hour lock mechanism to prevent modifications after creation
///
/// This entity follows the Elajtech project's strict rules:
/// - Uses Freezed for complete immutability
/// - All checkboxes default to `false` on creation
/// - Automatic locking after 24 hours from creation
/// - Completion percentage calculation based on checked fields
@freezed
abstract class NutritionEMREntity with _$NutritionEMREntity {
  const factory NutritionEMREntity({
    /// Unique identifier for this EMR record (UUID v4)
    required String id,

    /// Patient identifier from patients collection
    required String patientId,

    /// Nutritionist/Doctor identifier from users collection
    required String nutritionistId,

    /// Nutritionist's full name for display and audit
    required String nutritionistName,

    /// Appointment ID linking to appointments collection
    required String appointmentId,

    /// Visit date and time (from appointment)
    required DateTime visitDate,

    /// Record creation timestamp
    required DateTime createdAt,

    /// Last modification timestamp
    required DateTime updatedAt,

    // ═══════════════════════════════════════════════════════════════════════
    // 🔐 SECURITY & LOCKING FIELDS
    // ═══════════════════════════════════════════════════════════════════════

    /// Number of times this EMR has been edited (after creation)
    @Default(0) int editCount,

    /// User ID of the last person who edited this record
    String? lastEditedBy,

    /// Name of the last person who edited this record (for audit display)
    String? lastEditedByName,

    // ═══════════════════════════════════════════════════════════════════════
    // 🔐 ORIGINAL LOCKING FIELDS
    // ═══════════════════════════════════════════════════════════════════════

    /// Lock status - prevents editing after 24 hours from creation
    @Default(false) bool isLocked,

    /// Lock expiration timestamp (createdAt + 24 hours)
    DateTime? lockedUntil,

    /// Determines UI mode: true = Wizard (first visit), false = Tabs
    @Default(true) bool isFirstVisit,

    // ═══════════════════════════════════════════════════════════════════════
    // 📏 ANTHROPOMETRIC MEASUREMENT VALUES (Numeric Data)
    // ═══════════════════════════════════════════════════════════════════════

    /// Height in centimeters
    double? heightValue,

    /// Weight in kilograms
    double? weightValue,

    /// Waist circumference in centimeters
    double? waistCircumferenceValue,

    /// Hip circumference in centimeters (optional)
    double? hipCircumferenceValue,

    // ═══════════════════════════════════════════════════════════════════════
    // 📋 SECTION 1: ANTHROPOMETRIC MEASUREMENTS (5 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Body weight measured and documented (kg)
    @Default(false) bool weightMeasured,

    /// Height/stature measured and documented (cm)
    @Default(false) bool heightMeasured,

    /// Body Mass Index calculated (Weight/Height²)
    @Default(false) bool bmiCalculated,

    /// Waist circumference measured (cm)
    @Default(false) bool waistCircumferenceMeasured,

    /// Recent weight change documented (last 6 months)
    @Default(false) bool weightChangeDocumented,

    // ═══════════════════════════════════════════════════════════════════════
    // 📋 COMPREHENSIVE CHECKLIST - SECTION 1: PATIENT AND VISIT BASICS (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Patient identity verified
    @Default(false) bool isIdentityVerified,

    /// Informed consent obtained
    @Default(false) bool isConsentObtained,

    /// Reason for visit documented
    @Default(false) bool isReasonForVisitDocumented,

    /// Diagnosis reviewed
    @Default(false) bool isDiagnosisReviewed,

    // ═══════════════════════════════════════════════════════════════════════
    // 📏 COMPREHENSIVE CHECKLIST - SECTION 2: ANTHROPOMETRIC MEASUREMENTS (5 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Weight measured and documented
    @Default(false) bool isWeightMeasured,

    /// Height measured and documented
    @Default(false) bool isHeightMeasured,

    /// BMI calculated
    @Default(false) bool isBMICalculated,

    /// Waist circumference measured
    @Default(false) bool isWaistCircumferenceMeasured,

    /// Recent weight change documented
    @Default(false) bool isRecentWeightChangeDocumented,

    // ═══════════════════════════════════════════════════════════════════════
    // 🍽️ COMPREHENSIVE CHECKLIST - SECTION 3: DIETARY INTAKE ASSESSMENT (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// 24-hour dietary recall completed
    @Default(false) bool is24HourRecallCompleted,

    /// Food frequency questionnaire assessed
    @Default(false) bool isFoodFrequencyAssessed,

    /// Food allergies and intolerances checked
    @Default(false) bool isAllergiesIntolerancesChecked,

    /// Dietary supplements documented
    @Default(false) bool isSupplementsDocumented,

    // ═══════════════════════════════════════════════════════════════════════
    // 🏥 COMPREHENSIVE CHECKLIST - SECTION 4: MEDICAL CONDITIONS REVIEW (6 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Diabetes mellitus assessed
    @Default(false) bool isDiabetesAssessed,

    /// Hypertension assessed
    @Default(false) bool isHypertensionAssessed,

    /// Dyslipidemia (lipid disorders) assessed
    @Default(false) bool isDyslipidemiaAssessed,

    /// Obesity assessed
    @Default(false) bool isObesityAssessed,

    /// Chronic kidney disease assessed
    @Default(false) bool isCKDAssessed,

    /// Gastrointestinal disorders assessed
    @Default(false) bool isGIDisordersAssessed,

    // ═══════════════════════════════════════════════════════════════════════
    // 👁️ COMPREHENSIVE CHECKLIST - SECTION 5: NUTRITION FOCUSED PHYSICAL FINDINGS (5 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Muscle wasting (sarcopenia) assessed
    @Default(false) bool isMuscleWastingAssessed,

    /// Fat loss or gain assessed
    @Default(false) bool isFatLossAssessed,

    /// Edema (fluid retention) assessed
    @Default(false) bool isEdemaAssessed,

    /// Appetite level assessed
    @Default(false) bool isAppetiteAssessed,

    /// Chewing and swallowing difficulties assessed
    @Default(false) bool isChewingSwallowingAssessed,

    // ═══════════════════════════════════════════════════════════════════════
    // 🧪 COMPREHENSIVE CHECKLIST - SECTION 6: BIOCHEMICAL DATA REVIEW (5 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Blood glucose and HbA1c reviewed
    @Default(false) bool isGlucoseA1cReviewed,

    /// Lipid profile reviewed (cholesterol, triglycerides)
    @Default(false) bool isLipidProfileReviewed,

    /// Electrolytes reviewed (Na, K, Cl)
    @Default(false) bool isElectrolytesReviewed,

    /// Renal function reviewed (creatinine, BUN)
    @Default(false) bool isRenalFunctionReviewed,

    /// Micronutrients reviewed (vitamins, minerals)
    @Default(false) bool isMicronutrientsReviewed,

    // ═══════════════════════════════════════════════════════════════════════
    // 🎯 COMPREHENSIVE CHECKLIST - SECTION 7: NUTRITION DIAGNOSIS (3 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Inadequate intake diagnosed
    @Default(false) bool isInadequateIntakeDiagnosed,

    /// Excessive intake diagnosed
    @Default(false) bool isExcessiveIntakeDiagnosed,

    /// Food/nutrition knowledge deficit identified
    @Default(false) bool isFoodKnowledgeDeficitIdentified,

    // ═══════════════════════════════════════════════════════════════════════
    // 💊 COMPREHENSIVE CHECKLIST - SECTION 8: INTERVENTION PLAN (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Calorie prescription set
    @Default(false) bool isCaloriePrescriptionSet,

    /// Macronutrient distribution planned
    @Default(false) bool isMacronutrientDistributionPlanned,

    /// Nutrition education provided
    @Default(false) bool isEducationProvided,

    /// Follow-up plan established
    @Default(false) bool isFollowUpPlanEstablished,

    // ═══════════════════════════════════════════════════════════════════════
    // 🍽️ SECTION 2: DIETARY ASSESSMENT (4 fields) - ORIGINAL FIELDS
    // ═══════════════════════════════════════════════════════════════════════

    /// 24-hour dietary recall completed
    @Default(false) bool dietary24HRecall,

    /// Food frequency questionnaire administered
    @Default(false) bool foodFrequencyChecked,

    /// Food allergies and intolerances documented
    @Default(false) bool allergiesDocumented,

    /// Current dietary supplements reviewed and recorded
    @Default(false) bool supplementsReviewed,

    // ═══════════════════════════════════════════════════════════════════════
    // 🏥 SECTION 3: CLINICAL ASSESSMENT (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Medical history reviewed (chronic diseases, medications)
    @Default(false) bool medicalHistoryReviewed,

    /// Physical examination completed (muscle/fat assessment)
    @Default(false) bool physicalExamCompleted,

    /// Appetite and eating patterns assessed
    @Default(false) bool appetiteAssessed,

    /// Gastrointestinal symptoms evaluated
    @Default(false) bool giSymptomsEvaluated,

    // ═══════════════════════════════════════════════════════════════════════
    // 🧪 SECTION 4: LAB RESULTS REVIEW (3 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Blood glucose/HbA1c results reviewed
    @Default(false) bool bloodGlucoseReviewed,

    /// Lipid profile reviewed (cholesterol, triglycerides)
    @Default(false) bool lipidProfileReviewed,

    /// Micronutrients status reviewed (vitamins, minerals)
    @Default(false) bool micronutrientsReviewed,

    // ═══════════════════════════════════════════════════════════════════════
    // 🎯 SECTION 5: NUTRITION DIAGNOSIS (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Inadequate energy or nutrient intake diagnosed
    @Default(false) bool inadequateIntakeDiagnosed,

    /// Excessive energy or nutrient intake diagnosed
    @Default(false) bool excessiveIntakeDiagnosed,

    /// Inappropriate food/nutrition knowledge deficit
    @Default(false) bool knowledgeDeficitIdentified,

    /// Disordered eating pattern identified
    @Default(false) bool disorderedEatingIdentified,

    // ═══════════════════════════════════════════════════════════════════════
    // 💊 SECTION 6: NUTRITION INTERVENTION (5 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Calorie prescription determined and documented
    @Default(false) bool caloriePrescriptionSet,

    /// Macronutrient distribution calculated (Carbs/Protein/Fat)
    @Default(false) bool macroDistributionSet,

    /// Meal plan created and provided to patient
    @Default(false) bool mealPlanProvided,

    /// Nutrition education session provided
    @Default(false) bool educationProvided,

    /// Dietary supplements recommended (if needed)
    @Default(false) bool supplementsRecommended,

    // ═══════════════════════════════════════════════════════════════════════
    // 📊 SECTION 7: MONITORING AND EVALUATION (4 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Target weight goal established
    @Default(false) bool targetWeightSet,

    /// Expected timeline for goals documented
    @Default(false) bool timelineDocumented,

    /// Follow-up appointment scheduled
    @Default(false) bool followUpScheduled,

    /// Monitoring parameters defined (weight, labs, symptoms)
    @Default(false) bool monitoringParametersSet,

    // ═══════════════════════════════════════════════════════════════════════
    // 📝 SECTION 8: DOCUMENTATION AND COMMUNICATION (3 fields)
    // ═══════════════════════════════════════════════════════════════════════

    /// Patient given written instructions
    @Default(false) bool writtenInstructionsProvided,

    /// Referring physician notified (if applicable)
    @Default(false) bool physicianNotified,

    /// Patient consent for treatment obtained
    @Default(false) bool consentObtained,

    // ═══════════════════════════════════════════════════════════════════════
    // 📊 METADATA
    // ═══════════════════════════════════════════════════════════════════════

    /// Clinic specialization identifier
    @Default('عيادة السمنة والتغذية العلاجية') String specialization,

    /// Audit trail for all changes (list of change entries)
    @Default([]) List<AuditLogEntry> auditLog,
  }) = _NutritionEMREntity;

  /// Factory constructor to create new EMR with auto-calculated lockedUntil
  factory NutritionEMREntity.createNew({
    required String id,
    required String patientId,
    required String nutritionistId,
    required String nutritionistName,
    required String appointmentId,
    required DateTime visitDate,
  }) {
    final now = DateTime.now();
    return NutritionEMREntity(
      id: id,
      patientId: patientId,
      nutritionistId: nutritionistId,
      nutritionistName: nutritionistName,
      appointmentId: appointmentId,
      visitDate: visitDate,
      createdAt: now,
      updatedAt: now,
      lockedUntil: now.add(const Duration(hours: 24)),
    );
  }

  const NutritionEMREntity._();

  factory NutritionEMREntity.fromJson(Map<String, dynamic> json) =>
      _$NutritionEMREntityFromJson(json);

  // ═══════════════════════════════════════════════════════════════════════
  // 📈 COMPUTED PROPERTIES & BUSINESS LOGIC
  // ═══════════════════════════════════════════════════════════════════════

  /// Calculate overall completion percentage (0-100)
  ///
  /// Returns the percentage of checked checkboxes out of total 32 fields.
  /// This is used in the UI to show progress indicators.
  double get completionPercentage {
    const totalFields = 32;
    var completedFields = 0;

    // Section 1: Anthropometric Measurements (5 fields)
    if (weightMeasured) completedFields++;
    if (heightMeasured) completedFields++;
    if (bmiCalculated) completedFields++;
    if (waistCircumferenceMeasured) completedFields++;
    if (weightChangeDocumented) completedFields++;

    // Section 2: Dietary Assessment (4 fields)
    if (dietary24HRecall) completedFields++;
    if (foodFrequencyChecked) completedFields++;
    if (allergiesDocumented) completedFields++;
    if (supplementsReviewed) completedFields++;

    // Section 3: Clinical Assessment (4 fields)
    if (medicalHistoryReviewed) completedFields++;
    if (physicalExamCompleted) completedFields++;
    if (appetiteAssessed) completedFields++;
    if (giSymptomsEvaluated) completedFields++;

    // Section 4: Lab Results Review (3 fields)
    if (bloodGlucoseReviewed) completedFields++;
    if (lipidProfileReviewed) completedFields++;
    if (micronutrientsReviewed) completedFields++;

    // Section 5: Nutrition Diagnosis (4 fields)
    if (inadequateIntakeDiagnosed) completedFields++;
    if (excessiveIntakeDiagnosed) completedFields++;
    if (knowledgeDeficitIdentified) completedFields++;
    if (disorderedEatingIdentified) completedFields++;

    // Section 6: Nutrition Intervention (5 fields)
    if (caloriePrescriptionSet) completedFields++;
    if (macroDistributionSet) completedFields++;
    if (mealPlanProvided) completedFields++;
    if (educationProvided) completedFields++;
    if (supplementsRecommended) completedFields++;

    // Section 7: Monitoring and Evaluation (4 fields)
    if (targetWeightSet) completedFields++;
    if (timelineDocumented) completedFields++;
    if (followUpScheduled) completedFields++;
    if (monitoringParametersSet) completedFields++;

    // Section 8: Documentation and Communication (3 fields)
    if (writtenInstructionsProvided) completedFields++;
    if (physicianNotified) completedFields++;
    if (consentObtained) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Check if a specific section is complete
  ///
  /// Returns `true` if all required checkboxes in the section are checked.
  /// [sectionNumber] must be between 1 and 8.
  bool isSectionComplete(int sectionNumber) {
    switch (sectionNumber) {
      case 1: // Anthropometric Measurements
        return weightMeasured &&
            heightMeasured &&
            bmiCalculated &&
            waistCircumferenceMeasured &&
            weightChangeDocumented;

      case 2: // Dietary Assessment
        return dietary24HRecall &&
            foodFrequencyChecked &&
            allergiesDocumented &&
            supplementsReviewed;

      case 3: // Clinical Assessment
        return medicalHistoryReviewed &&
            physicalExamCompleted &&
            appetiteAssessed &&
            giSymptomsEvaluated;

      case 4: // Lab Results Review
        return bloodGlucoseReviewed &&
            lipidProfileReviewed &&
            micronutrientsReviewed;

      case 5: // Nutrition Diagnosis (at least one must be checked)
        return inadequateIntakeDiagnosed ||
            excessiveIntakeDiagnosed ||
            knowledgeDeficitIdentified ||
            disorderedEatingIdentified;

      case 6: // Nutrition Intervention
        return caloriePrescriptionSet &&
            macroDistributionSet &&
            mealPlanProvided &&
            educationProvided &&
            supplementsRecommended;

      case 7: // Monitoring and Evaluation
        return targetWeightSet &&
            timelineDocumented &&
            followUpScheduled &&
            monitoringParametersSet;

      case 8: // Documentation and Communication
        return writtenInstructionsProvided &&
            physicianNotified &&
            consentObtained;

      default:
        return false;
    }
  }

  /// Get section completion percentage for a specific section
  ///
  /// Returns percentage (0-100) of completed fields in the section.
  double getSectionCompletionPercentage(int sectionNumber) {
    switch (sectionNumber) {
      case 1: // 5 fields
        var completed = 0;
        if (weightMeasured) completed++;
        if (heightMeasured) completed++;
        if (bmiCalculated) completed++;
        if (waistCircumferenceMeasured) completed++;
        if (weightChangeDocumented) completed++;
        return (completed / 5) * 100;

      case 2: // 4 fields
        var completed = 0;
        if (dietary24HRecall) completed++;
        if (foodFrequencyChecked) completed++;
        if (allergiesDocumented) completed++;
        if (supplementsReviewed) completed++;
        return (completed / 4) * 100;

      case 3: // 4 fields
        var completed = 0;
        if (medicalHistoryReviewed) completed++;
        if (physicalExamCompleted) completed++;
        if (appetiteAssessed) completed++;
        if (giSymptomsEvaluated) completed++;
        return (completed / 4) * 100;

      case 4: // 3 fields
        var completed = 0;
        if (bloodGlucoseReviewed) completed++;
        if (lipidProfileReviewed) completed++;
        if (micronutrientsReviewed) completed++;
        return (completed / 3) * 100;

      case 5: // 4 fields
        var completed = 0;
        if (inadequateIntakeDiagnosed) completed++;
        if (excessiveIntakeDiagnosed) completed++;
        if (knowledgeDeficitIdentified) completed++;
        if (disorderedEatingIdentified) completed++;
        return (completed / 4) * 100;

      case 6: // 5 fields
        var completed = 0;
        if (caloriePrescriptionSet) completed++;
        if (macroDistributionSet) completed++;
        if (mealPlanProvided) completed++;
        if (educationProvided) completed++;
        if (supplementsRecommended) completed++;
        return (completed / 5) * 100;

      case 7: // 4 fields
        var completed = 0;
        if (targetWeightSet) completed++;
        if (timelineDocumented) completed++;
        if (followUpScheduled) completed++;
        if (monitoringParametersSet) completed++;
        return (completed / 4) * 100;

      case 8: // 3 fields
        var completed = 0;
        if (writtenInstructionsProvided) completed++;
        if (physicianNotified) completed++;
        if (consentObtained) completed++;
        return (completed / 3) * 100;

      default:
        return 0;
    }
  }

  /// Get human-readable section name (English)
  String getSectionName(int sectionNumber) {
    switch (sectionNumber) {
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
        return 'Unknown Section';
    }
  }

  /// Get Arabic section name
  String getSectionNameArabic(int sectionNumber) {
    switch (sectionNumber) {
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
        return 'قسم غير معروف';
    }
  }

  /// Check if record is currently locked
  ///
  /// Returns true if 24 hours have passed since creation OR if manually locked.
  bool get isCurrentlyLocked {
    if (isLocked) return true;
    if (lockedUntil == null) return false;
    return DateTime.now().isAfter(lockedUntil!);
  }

  /// Get remaining edit time in hours
  ///
  /// Returns number of hours remaining before auto-lock.
  /// Returns 0 if already locked or expired.
  int get remainingEditHours {
    if (isLocked || lockedUntil == null) return 0;

    final now = DateTime.now();
    if (now.isAfter(lockedUntil!)) return 0;

    final difference = lockedUntil!.difference(now);
    return difference.inHours;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 AUDIT LOG ENTRY
// ═══════════════════════════════════════════════════════════════════════════

/// Audit log entry for tracking changes to EMR
///
/// Every modification to the EMR creates an audit entry with:
/// - Timestamp of change
/// - User who made the change
/// - Field that was changed
/// - Previous and new values
@freezed
abstract class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    /// When the change occurred
    required DateTime timestamp,

    /// User ID who made the change (nutritionist/doctor)
    required String userId,

    /// User name for display in audit trail
    required String userName,

    /// Action type: 'created', 'updated', 'locked', 'viewed'
    required String action,

    /// Field name that was changed (e.g., 'weightMeasured')
    required String fieldChanged,

    /// Previous value (for checkboxes: 'true' or 'false')
    required String previousValue,

    /// New value (for checkboxes: 'true' or 'false')
    required String newValue,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}
