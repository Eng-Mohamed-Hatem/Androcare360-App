// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_emr_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NutritionEMREntity {

/// Unique identifier for this EMR record (UUID v4)
 String get id;/// Patient identifier from patients collection
 String get patientId;/// Nutritionist/Doctor identifier from users collection
 String get nutritionistId;/// Nutritionist's full name for display and audit
 String get nutritionistName;/// Appointment ID linking to appointments collection
 String get appointmentId;/// Visit date and time (from appointment)
 DateTime get visitDate;/// Record creation timestamp
 DateTime get createdAt;/// Last modification timestamp
 DateTime get updatedAt;// ═══════════════════════════════════════════════════════════════════════
// 🔐 SECURITY & LOCKING FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// Number of times this EMR has been edited (after creation)
 int get editCount;/// User ID of the last person who edited this record
 String? get lastEditedBy;/// Name of the last person who edited this record (for audit display)
 String? get lastEditedByName;// ═══════════════════════════════════════════════════════════════════════
// 🔐 ORIGINAL LOCKING FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// Lock status - prevents editing after 24 hours from creation
 bool get isLocked;/// Lock expiration timestamp (createdAt + 24 hours)
 DateTime? get lockedUntil;/// Determines UI mode: true = Wizard (first visit), false = Tabs
 bool get isFirstVisit;// ═══════════════════════════════════════════════════════════════════════
// 📏 ANTHROPOMETRIC MEASUREMENT VALUES (Numeric Data)
// ═══════════════════════════════════════════════════════════════════════
/// Height in centimeters
 double? get heightValue;/// Weight in kilograms
 double? get weightValue;/// Waist circumference in centimeters
 double? get waistCircumferenceValue;/// Hip circumference in centimeters (optional)
 double? get hipCircumferenceValue;// ═══════════════════════════════════════════════════════════════════════
// 📋 SECTION 1: ANTHROPOMETRIC MEASUREMENTS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Body weight measured and documented (kg)
 bool get weightMeasured;/// Height/stature measured and documented (cm)
 bool get heightMeasured;/// Body Mass Index calculated (Weight/Height²)
 bool get bmiCalculated;/// Waist circumference measured (cm)
 bool get waistCircumferenceMeasured;/// Recent weight change documented (last 6 months)
 bool get weightChangeDocumented;// ═══════════════════════════════════════════════════════════════════════
// 📋 COMPREHENSIVE CHECKLIST - SECTION 1: PATIENT AND VISIT BASICS (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Patient identity verified
 bool get isIdentityVerified;/// Informed consent obtained
 bool get isConsentObtained;/// Reason for visit documented
 bool get isReasonForVisitDocumented;/// Diagnosis reviewed
 bool get isDiagnosisReviewed;// ═══════════════════════════════════════════════════════════════════════
// 📏 COMPREHENSIVE CHECKLIST - SECTION 2: ANTHROPOMETRIC MEASUREMENTS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Weight measured and documented
 bool get isWeightMeasured;/// Height measured and documented
 bool get isHeightMeasured;/// BMI calculated
 bool get isBMICalculated;/// Waist circumference measured
 bool get isWaistCircumferenceMeasured;/// Recent weight change documented
 bool get isRecentWeightChangeDocumented;// ═══════════════════════════════════════════════════════════════════════
// 🍽️ COMPREHENSIVE CHECKLIST - SECTION 3: DIETARY INTAKE ASSESSMENT (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// 24-hour dietary recall completed
 bool get is24HourRecallCompleted;/// Food frequency questionnaire assessed
 bool get isFoodFrequencyAssessed;/// Food allergies and intolerances checked
 bool get isAllergiesIntolerancesChecked;/// Dietary supplements documented
 bool get isSupplementsDocumented;// ═══════════════════════════════════════════════════════════════════════
// 🏥 COMPREHENSIVE CHECKLIST - SECTION 4: MEDICAL CONDITIONS REVIEW (6 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Diabetes mellitus assessed
 bool get isDiabetesAssessed;/// Hypertension assessed
 bool get isHypertensionAssessed;/// Dyslipidemia (lipid disorders) assessed
 bool get isDyslipidemiaAssessed;/// Obesity assessed
 bool get isObesityAssessed;/// Chronic kidney disease assessed
 bool get isCKDAssessed;/// Gastrointestinal disorders assessed
 bool get isGIDisordersAssessed;// ═══════════════════════════════════════════════════════════════════════
// 👁️ COMPREHENSIVE CHECKLIST - SECTION 5: NUTRITION FOCUSED PHYSICAL FINDINGS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Muscle wasting (sarcopenia) assessed
 bool get isMuscleWastingAssessed;/// Fat loss or gain assessed
 bool get isFatLossAssessed;/// Edema (fluid retention) assessed
 bool get isEdemaAssessed;/// Appetite level assessed
 bool get isAppetiteAssessed;/// Chewing and swallowing difficulties assessed
 bool get isChewingSwallowingAssessed;// ═══════════════════════════════════════════════════════════════════════
// 🧪 COMPREHENSIVE CHECKLIST - SECTION 6: BIOCHEMICAL DATA REVIEW (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Blood glucose and HbA1c reviewed
 bool get isGlucoseA1cReviewed;/// Lipid profile reviewed (cholesterol, triglycerides)
 bool get isLipidProfileReviewed;/// Electrolytes reviewed (Na, K, Cl)
 bool get isElectrolytesReviewed;/// Renal function reviewed (creatinine, BUN)
 bool get isRenalFunctionReviewed;/// Micronutrients reviewed (vitamins, minerals)
 bool get isMicronutrientsReviewed;// ═══════════════════════════════════════════════════════════════════════
// 🎯 COMPREHENSIVE CHECKLIST - SECTION 7: NUTRITION DIAGNOSIS (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Inadequate intake diagnosed
 bool get isInadequateIntakeDiagnosed;/// Excessive intake diagnosed
 bool get isExcessiveIntakeDiagnosed;/// Food/nutrition knowledge deficit identified
 bool get isFoodKnowledgeDeficitIdentified;// ═══════════════════════════════════════════════════════════════════════
// 💊 COMPREHENSIVE CHECKLIST - SECTION 8: INTERVENTION PLAN (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Calorie prescription set
 bool get isCaloriePrescriptionSet;/// Macronutrient distribution planned
 bool get isMacronutrientDistributionPlanned;/// Nutrition education provided
 bool get isEducationProvided;/// Follow-up plan established
 bool get isFollowUpPlanEstablished;// ═══════════════════════════════════════════════════════════════════════
// 🍽️ SECTION 2: DIETARY ASSESSMENT (4 fields) - ORIGINAL FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// 24-hour dietary recall completed
 bool get dietary24HRecall;/// Food frequency questionnaire administered
 bool get foodFrequencyChecked;/// Food allergies and intolerances documented
 bool get allergiesDocumented;/// Current dietary supplements reviewed and recorded
 bool get supplementsReviewed;// ═══════════════════════════════════════════════════════════════════════
// 🏥 SECTION 3: CLINICAL ASSESSMENT (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Medical history reviewed (chronic diseases, medications)
 bool get medicalHistoryReviewed;/// Physical examination completed (muscle/fat assessment)
 bool get physicalExamCompleted;/// Appetite and eating patterns assessed
 bool get appetiteAssessed;/// Gastrointestinal symptoms evaluated
 bool get giSymptomsEvaluated;// ═══════════════════════════════════════════════════════════════════════
// 🧪 SECTION 4: LAB RESULTS REVIEW (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Blood glucose/HbA1c results reviewed
 bool get bloodGlucoseReviewed;/// Lipid profile reviewed (cholesterol, triglycerides)
 bool get lipidProfileReviewed;/// Micronutrients status reviewed (vitamins, minerals)
 bool get micronutrientsReviewed;// ═══════════════════════════════════════════════════════════════════════
// 🎯 SECTION 5: NUTRITION DIAGNOSIS (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Inadequate energy or nutrient intake diagnosed
 bool get inadequateIntakeDiagnosed;/// Excessive energy or nutrient intake diagnosed
 bool get excessiveIntakeDiagnosed;/// Inappropriate food/nutrition knowledge deficit
 bool get knowledgeDeficitIdentified;/// Disordered eating pattern identified
 bool get disorderedEatingIdentified;// ═══════════════════════════════════════════════════════════════════════
// 💊 SECTION 6: NUTRITION INTERVENTION (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Calorie prescription determined and documented
 bool get caloriePrescriptionSet;/// Macronutrient distribution calculated (Carbs/Protein/Fat)
 bool get macroDistributionSet;/// Meal plan created and provided to patient
 bool get mealPlanProvided;/// Nutrition education session provided
 bool get educationProvided;/// Dietary supplements recommended (if needed)
 bool get supplementsRecommended;// ═══════════════════════════════════════════════════════════════════════
// 📊 SECTION 7: MONITORING AND EVALUATION (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Target weight goal established
 bool get targetWeightSet;/// Expected timeline for goals documented
 bool get timelineDocumented;/// Follow-up appointment scheduled
 bool get followUpScheduled;/// Monitoring parameters defined (weight, labs, symptoms)
 bool get monitoringParametersSet;// ═══════════════════════════════════════════════════════════════════════
// 📝 SECTION 8: DOCUMENTATION AND COMMUNICATION (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Patient given written instructions
 bool get writtenInstructionsProvided;/// Referring physician notified (if applicable)
 bool get physicianNotified;/// Patient consent for treatment obtained
 bool get consentObtained;// ═══════════════════════════════════════════════════════════════════════
// 📊 METADATA
// ═══════════════════════════════════════════════════════════════════════
/// Clinic specialization identifier
 String get specialization;/// Audit trail for all changes (list of change entries)
 List<AuditLogEntry> get auditLog;
/// Create a copy of NutritionEMREntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionEMREntityCopyWith<NutritionEMREntity> get copyWith => _$NutritionEMREntityCopyWithImpl<NutritionEMREntity>(this as NutritionEMREntity, _$identity);

  /// Serializes this NutritionEMREntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionEMREntity&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.nutritionistId, nutritionistId) || other.nutritionistId == nutritionistId)&&(identical(other.nutritionistName, nutritionistName) || other.nutritionistName == nutritionistName)&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.visitDate, visitDate) || other.visitDate == visitDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.lastEditedBy, lastEditedBy) || other.lastEditedBy == lastEditedBy)&&(identical(other.lastEditedByName, lastEditedByName) || other.lastEditedByName == lastEditedByName)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.lockedUntil, lockedUntil) || other.lockedUntil == lockedUntil)&&(identical(other.isFirstVisit, isFirstVisit) || other.isFirstVisit == isFirstVisit)&&(identical(other.heightValue, heightValue) || other.heightValue == heightValue)&&(identical(other.weightValue, weightValue) || other.weightValue == weightValue)&&(identical(other.waistCircumferenceValue, waistCircumferenceValue) || other.waistCircumferenceValue == waistCircumferenceValue)&&(identical(other.hipCircumferenceValue, hipCircumferenceValue) || other.hipCircumferenceValue == hipCircumferenceValue)&&(identical(other.weightMeasured, weightMeasured) || other.weightMeasured == weightMeasured)&&(identical(other.heightMeasured, heightMeasured) || other.heightMeasured == heightMeasured)&&(identical(other.bmiCalculated, bmiCalculated) || other.bmiCalculated == bmiCalculated)&&(identical(other.waistCircumferenceMeasured, waistCircumferenceMeasured) || other.waistCircumferenceMeasured == waistCircumferenceMeasured)&&(identical(other.weightChangeDocumented, weightChangeDocumented) || other.weightChangeDocumented == weightChangeDocumented)&&(identical(other.isIdentityVerified, isIdentityVerified) || other.isIdentityVerified == isIdentityVerified)&&(identical(other.isConsentObtained, isConsentObtained) || other.isConsentObtained == isConsentObtained)&&(identical(other.isReasonForVisitDocumented, isReasonForVisitDocumented) || other.isReasonForVisitDocumented == isReasonForVisitDocumented)&&(identical(other.isDiagnosisReviewed, isDiagnosisReviewed) || other.isDiagnosisReviewed == isDiagnosisReviewed)&&(identical(other.isWeightMeasured, isWeightMeasured) || other.isWeightMeasured == isWeightMeasured)&&(identical(other.isHeightMeasured, isHeightMeasured) || other.isHeightMeasured == isHeightMeasured)&&(identical(other.isBMICalculated, isBMICalculated) || other.isBMICalculated == isBMICalculated)&&(identical(other.isWaistCircumferenceMeasured, isWaistCircumferenceMeasured) || other.isWaistCircumferenceMeasured == isWaistCircumferenceMeasured)&&(identical(other.isRecentWeightChangeDocumented, isRecentWeightChangeDocumented) || other.isRecentWeightChangeDocumented == isRecentWeightChangeDocumented)&&(identical(other.is24HourRecallCompleted, is24HourRecallCompleted) || other.is24HourRecallCompleted == is24HourRecallCompleted)&&(identical(other.isFoodFrequencyAssessed, isFoodFrequencyAssessed) || other.isFoodFrequencyAssessed == isFoodFrequencyAssessed)&&(identical(other.isAllergiesIntolerancesChecked, isAllergiesIntolerancesChecked) || other.isAllergiesIntolerancesChecked == isAllergiesIntolerancesChecked)&&(identical(other.isSupplementsDocumented, isSupplementsDocumented) || other.isSupplementsDocumented == isSupplementsDocumented)&&(identical(other.isDiabetesAssessed, isDiabetesAssessed) || other.isDiabetesAssessed == isDiabetesAssessed)&&(identical(other.isHypertensionAssessed, isHypertensionAssessed) || other.isHypertensionAssessed == isHypertensionAssessed)&&(identical(other.isDyslipidemiaAssessed, isDyslipidemiaAssessed) || other.isDyslipidemiaAssessed == isDyslipidemiaAssessed)&&(identical(other.isObesityAssessed, isObesityAssessed) || other.isObesityAssessed == isObesityAssessed)&&(identical(other.isCKDAssessed, isCKDAssessed) || other.isCKDAssessed == isCKDAssessed)&&(identical(other.isGIDisordersAssessed, isGIDisordersAssessed) || other.isGIDisordersAssessed == isGIDisordersAssessed)&&(identical(other.isMuscleWastingAssessed, isMuscleWastingAssessed) || other.isMuscleWastingAssessed == isMuscleWastingAssessed)&&(identical(other.isFatLossAssessed, isFatLossAssessed) || other.isFatLossAssessed == isFatLossAssessed)&&(identical(other.isEdemaAssessed, isEdemaAssessed) || other.isEdemaAssessed == isEdemaAssessed)&&(identical(other.isAppetiteAssessed, isAppetiteAssessed) || other.isAppetiteAssessed == isAppetiteAssessed)&&(identical(other.isChewingSwallowingAssessed, isChewingSwallowingAssessed) || other.isChewingSwallowingAssessed == isChewingSwallowingAssessed)&&(identical(other.isGlucoseA1cReviewed, isGlucoseA1cReviewed) || other.isGlucoseA1cReviewed == isGlucoseA1cReviewed)&&(identical(other.isLipidProfileReviewed, isLipidProfileReviewed) || other.isLipidProfileReviewed == isLipidProfileReviewed)&&(identical(other.isElectrolytesReviewed, isElectrolytesReviewed) || other.isElectrolytesReviewed == isElectrolytesReviewed)&&(identical(other.isRenalFunctionReviewed, isRenalFunctionReviewed) || other.isRenalFunctionReviewed == isRenalFunctionReviewed)&&(identical(other.isMicronutrientsReviewed, isMicronutrientsReviewed) || other.isMicronutrientsReviewed == isMicronutrientsReviewed)&&(identical(other.isInadequateIntakeDiagnosed, isInadequateIntakeDiagnosed) || other.isInadequateIntakeDiagnosed == isInadequateIntakeDiagnosed)&&(identical(other.isExcessiveIntakeDiagnosed, isExcessiveIntakeDiagnosed) || other.isExcessiveIntakeDiagnosed == isExcessiveIntakeDiagnosed)&&(identical(other.isFoodKnowledgeDeficitIdentified, isFoodKnowledgeDeficitIdentified) || other.isFoodKnowledgeDeficitIdentified == isFoodKnowledgeDeficitIdentified)&&(identical(other.isCaloriePrescriptionSet, isCaloriePrescriptionSet) || other.isCaloriePrescriptionSet == isCaloriePrescriptionSet)&&(identical(other.isMacronutrientDistributionPlanned, isMacronutrientDistributionPlanned) || other.isMacronutrientDistributionPlanned == isMacronutrientDistributionPlanned)&&(identical(other.isEducationProvided, isEducationProvided) || other.isEducationProvided == isEducationProvided)&&(identical(other.isFollowUpPlanEstablished, isFollowUpPlanEstablished) || other.isFollowUpPlanEstablished == isFollowUpPlanEstablished)&&(identical(other.dietary24HRecall, dietary24HRecall) || other.dietary24HRecall == dietary24HRecall)&&(identical(other.foodFrequencyChecked, foodFrequencyChecked) || other.foodFrequencyChecked == foodFrequencyChecked)&&(identical(other.allergiesDocumented, allergiesDocumented) || other.allergiesDocumented == allergiesDocumented)&&(identical(other.supplementsReviewed, supplementsReviewed) || other.supplementsReviewed == supplementsReviewed)&&(identical(other.medicalHistoryReviewed, medicalHistoryReviewed) || other.medicalHistoryReviewed == medicalHistoryReviewed)&&(identical(other.physicalExamCompleted, physicalExamCompleted) || other.physicalExamCompleted == physicalExamCompleted)&&(identical(other.appetiteAssessed, appetiteAssessed) || other.appetiteAssessed == appetiteAssessed)&&(identical(other.giSymptomsEvaluated, giSymptomsEvaluated) || other.giSymptomsEvaluated == giSymptomsEvaluated)&&(identical(other.bloodGlucoseReviewed, bloodGlucoseReviewed) || other.bloodGlucoseReviewed == bloodGlucoseReviewed)&&(identical(other.lipidProfileReviewed, lipidProfileReviewed) || other.lipidProfileReviewed == lipidProfileReviewed)&&(identical(other.micronutrientsReviewed, micronutrientsReviewed) || other.micronutrientsReviewed == micronutrientsReviewed)&&(identical(other.inadequateIntakeDiagnosed, inadequateIntakeDiagnosed) || other.inadequateIntakeDiagnosed == inadequateIntakeDiagnosed)&&(identical(other.excessiveIntakeDiagnosed, excessiveIntakeDiagnosed) || other.excessiveIntakeDiagnosed == excessiveIntakeDiagnosed)&&(identical(other.knowledgeDeficitIdentified, knowledgeDeficitIdentified) || other.knowledgeDeficitIdentified == knowledgeDeficitIdentified)&&(identical(other.disorderedEatingIdentified, disorderedEatingIdentified) || other.disorderedEatingIdentified == disorderedEatingIdentified)&&(identical(other.caloriePrescriptionSet, caloriePrescriptionSet) || other.caloriePrescriptionSet == caloriePrescriptionSet)&&(identical(other.macroDistributionSet, macroDistributionSet) || other.macroDistributionSet == macroDistributionSet)&&(identical(other.mealPlanProvided, mealPlanProvided) || other.mealPlanProvided == mealPlanProvided)&&(identical(other.educationProvided, educationProvided) || other.educationProvided == educationProvided)&&(identical(other.supplementsRecommended, supplementsRecommended) || other.supplementsRecommended == supplementsRecommended)&&(identical(other.targetWeightSet, targetWeightSet) || other.targetWeightSet == targetWeightSet)&&(identical(other.timelineDocumented, timelineDocumented) || other.timelineDocumented == timelineDocumented)&&(identical(other.followUpScheduled, followUpScheduled) || other.followUpScheduled == followUpScheduled)&&(identical(other.monitoringParametersSet, monitoringParametersSet) || other.monitoringParametersSet == monitoringParametersSet)&&(identical(other.writtenInstructionsProvided, writtenInstructionsProvided) || other.writtenInstructionsProvided == writtenInstructionsProvided)&&(identical(other.physicianNotified, physicianNotified) || other.physicianNotified == physicianNotified)&&(identical(other.consentObtained, consentObtained) || other.consentObtained == consentObtained)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&const DeepCollectionEquality().equals(other.auditLog, auditLog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,patientId,nutritionistId,nutritionistName,appointmentId,visitDate,createdAt,updatedAt,editCount,lastEditedBy,lastEditedByName,isLocked,lockedUntil,isFirstVisit,heightValue,weightValue,waistCircumferenceValue,hipCircumferenceValue,weightMeasured,heightMeasured,bmiCalculated,waistCircumferenceMeasured,weightChangeDocumented,isIdentityVerified,isConsentObtained,isReasonForVisitDocumented,isDiagnosisReviewed,isWeightMeasured,isHeightMeasured,isBMICalculated,isWaistCircumferenceMeasured,isRecentWeightChangeDocumented,is24HourRecallCompleted,isFoodFrequencyAssessed,isAllergiesIntolerancesChecked,isSupplementsDocumented,isDiabetesAssessed,isHypertensionAssessed,isDyslipidemiaAssessed,isObesityAssessed,isCKDAssessed,isGIDisordersAssessed,isMuscleWastingAssessed,isFatLossAssessed,isEdemaAssessed,isAppetiteAssessed,isChewingSwallowingAssessed,isGlucoseA1cReviewed,isLipidProfileReviewed,isElectrolytesReviewed,isRenalFunctionReviewed,isMicronutrientsReviewed,isInadequateIntakeDiagnosed,isExcessiveIntakeDiagnosed,isFoodKnowledgeDeficitIdentified,isCaloriePrescriptionSet,isMacronutrientDistributionPlanned,isEducationProvided,isFollowUpPlanEstablished,dietary24HRecall,foodFrequencyChecked,allergiesDocumented,supplementsReviewed,medicalHistoryReviewed,physicalExamCompleted,appetiteAssessed,giSymptomsEvaluated,bloodGlucoseReviewed,lipidProfileReviewed,micronutrientsReviewed,inadequateIntakeDiagnosed,excessiveIntakeDiagnosed,knowledgeDeficitIdentified,disorderedEatingIdentified,caloriePrescriptionSet,macroDistributionSet,mealPlanProvided,educationProvided,supplementsRecommended,targetWeightSet,timelineDocumented,followUpScheduled,monitoringParametersSet,writtenInstructionsProvided,physicianNotified,consentObtained,specialization,const DeepCollectionEquality().hash(auditLog)]);

@override
String toString() {
  return 'NutritionEMREntity(id: $id, patientId: $patientId, nutritionistId: $nutritionistId, nutritionistName: $nutritionistName, appointmentId: $appointmentId, visitDate: $visitDate, createdAt: $createdAt, updatedAt: $updatedAt, editCount: $editCount, lastEditedBy: $lastEditedBy, lastEditedByName: $lastEditedByName, isLocked: $isLocked, lockedUntil: $lockedUntil, isFirstVisit: $isFirstVisit, heightValue: $heightValue, weightValue: $weightValue, waistCircumferenceValue: $waistCircumferenceValue, hipCircumferenceValue: $hipCircumferenceValue, weightMeasured: $weightMeasured, heightMeasured: $heightMeasured, bmiCalculated: $bmiCalculated, waistCircumferenceMeasured: $waistCircumferenceMeasured, weightChangeDocumented: $weightChangeDocumented, isIdentityVerified: $isIdentityVerified, isConsentObtained: $isConsentObtained, isReasonForVisitDocumented: $isReasonForVisitDocumented, isDiagnosisReviewed: $isDiagnosisReviewed, isWeightMeasured: $isWeightMeasured, isHeightMeasured: $isHeightMeasured, isBMICalculated: $isBMICalculated, isWaistCircumferenceMeasured: $isWaistCircumferenceMeasured, isRecentWeightChangeDocumented: $isRecentWeightChangeDocumented, is24HourRecallCompleted: $is24HourRecallCompleted, isFoodFrequencyAssessed: $isFoodFrequencyAssessed, isAllergiesIntolerancesChecked: $isAllergiesIntolerancesChecked, isSupplementsDocumented: $isSupplementsDocumented, isDiabetesAssessed: $isDiabetesAssessed, isHypertensionAssessed: $isHypertensionAssessed, isDyslipidemiaAssessed: $isDyslipidemiaAssessed, isObesityAssessed: $isObesityAssessed, isCKDAssessed: $isCKDAssessed, isGIDisordersAssessed: $isGIDisordersAssessed, isMuscleWastingAssessed: $isMuscleWastingAssessed, isFatLossAssessed: $isFatLossAssessed, isEdemaAssessed: $isEdemaAssessed, isAppetiteAssessed: $isAppetiteAssessed, isChewingSwallowingAssessed: $isChewingSwallowingAssessed, isGlucoseA1cReviewed: $isGlucoseA1cReviewed, isLipidProfileReviewed: $isLipidProfileReviewed, isElectrolytesReviewed: $isElectrolytesReviewed, isRenalFunctionReviewed: $isRenalFunctionReviewed, isMicronutrientsReviewed: $isMicronutrientsReviewed, isInadequateIntakeDiagnosed: $isInadequateIntakeDiagnosed, isExcessiveIntakeDiagnosed: $isExcessiveIntakeDiagnosed, isFoodKnowledgeDeficitIdentified: $isFoodKnowledgeDeficitIdentified, isCaloriePrescriptionSet: $isCaloriePrescriptionSet, isMacronutrientDistributionPlanned: $isMacronutrientDistributionPlanned, isEducationProvided: $isEducationProvided, isFollowUpPlanEstablished: $isFollowUpPlanEstablished, dietary24HRecall: $dietary24HRecall, foodFrequencyChecked: $foodFrequencyChecked, allergiesDocumented: $allergiesDocumented, supplementsReviewed: $supplementsReviewed, medicalHistoryReviewed: $medicalHistoryReviewed, physicalExamCompleted: $physicalExamCompleted, appetiteAssessed: $appetiteAssessed, giSymptomsEvaluated: $giSymptomsEvaluated, bloodGlucoseReviewed: $bloodGlucoseReviewed, lipidProfileReviewed: $lipidProfileReviewed, micronutrientsReviewed: $micronutrientsReviewed, inadequateIntakeDiagnosed: $inadequateIntakeDiagnosed, excessiveIntakeDiagnosed: $excessiveIntakeDiagnosed, knowledgeDeficitIdentified: $knowledgeDeficitIdentified, disorderedEatingIdentified: $disorderedEatingIdentified, caloriePrescriptionSet: $caloriePrescriptionSet, macroDistributionSet: $macroDistributionSet, mealPlanProvided: $mealPlanProvided, educationProvided: $educationProvided, supplementsRecommended: $supplementsRecommended, targetWeightSet: $targetWeightSet, timelineDocumented: $timelineDocumented, followUpScheduled: $followUpScheduled, monitoringParametersSet: $monitoringParametersSet, writtenInstructionsProvided: $writtenInstructionsProvided, physicianNotified: $physicianNotified, consentObtained: $consentObtained, specialization: $specialization, auditLog: $auditLog)';
}


}

/// @nodoc
abstract mixin class $NutritionEMREntityCopyWith<$Res>  {
  factory $NutritionEMREntityCopyWith(NutritionEMREntity value, $Res Function(NutritionEMREntity) _then) = _$NutritionEMREntityCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String nutritionistId, String nutritionistName, String appointmentId, DateTime visitDate, DateTime createdAt, DateTime updatedAt, int editCount, String? lastEditedBy, String? lastEditedByName, bool isLocked, DateTime? lockedUntil, bool isFirstVisit, double? heightValue, double? weightValue, double? waistCircumferenceValue, double? hipCircumferenceValue, bool weightMeasured, bool heightMeasured, bool bmiCalculated, bool waistCircumferenceMeasured, bool weightChangeDocumented, bool isIdentityVerified, bool isConsentObtained, bool isReasonForVisitDocumented, bool isDiagnosisReviewed, bool isWeightMeasured, bool isHeightMeasured, bool isBMICalculated, bool isWaistCircumferenceMeasured, bool isRecentWeightChangeDocumented, bool is24HourRecallCompleted, bool isFoodFrequencyAssessed, bool isAllergiesIntolerancesChecked, bool isSupplementsDocumented, bool isDiabetesAssessed, bool isHypertensionAssessed, bool isDyslipidemiaAssessed, bool isObesityAssessed, bool isCKDAssessed, bool isGIDisordersAssessed, bool isMuscleWastingAssessed, bool isFatLossAssessed, bool isEdemaAssessed, bool isAppetiteAssessed, bool isChewingSwallowingAssessed, bool isGlucoseA1cReviewed, bool isLipidProfileReviewed, bool isElectrolytesReviewed, bool isRenalFunctionReviewed, bool isMicronutrientsReviewed, bool isInadequateIntakeDiagnosed, bool isExcessiveIntakeDiagnosed, bool isFoodKnowledgeDeficitIdentified, bool isCaloriePrescriptionSet, bool isMacronutrientDistributionPlanned, bool isEducationProvided, bool isFollowUpPlanEstablished, bool dietary24HRecall, bool foodFrequencyChecked, bool allergiesDocumented, bool supplementsReviewed, bool medicalHistoryReviewed, bool physicalExamCompleted, bool appetiteAssessed, bool giSymptomsEvaluated, bool bloodGlucoseReviewed, bool lipidProfileReviewed, bool micronutrientsReviewed, bool inadequateIntakeDiagnosed, bool excessiveIntakeDiagnosed, bool knowledgeDeficitIdentified, bool disorderedEatingIdentified, bool caloriePrescriptionSet, bool macroDistributionSet, bool mealPlanProvided, bool educationProvided, bool supplementsRecommended, bool targetWeightSet, bool timelineDocumented, bool followUpScheduled, bool monitoringParametersSet, bool writtenInstructionsProvided, bool physicianNotified, bool consentObtained, String specialization, List<AuditLogEntry> auditLog
});




}
/// @nodoc
class _$NutritionEMREntityCopyWithImpl<$Res>
    implements $NutritionEMREntityCopyWith<$Res> {
  _$NutritionEMREntityCopyWithImpl(this._self, this._then);

  final NutritionEMREntity _self;
  final $Res Function(NutritionEMREntity) _then;

/// Create a copy of NutritionEMREntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? nutritionistId = null,Object? nutritionistName = null,Object? appointmentId = null,Object? visitDate = null,Object? createdAt = null,Object? updatedAt = null,Object? editCount = null,Object? lastEditedBy = freezed,Object? lastEditedByName = freezed,Object? isLocked = null,Object? lockedUntil = freezed,Object? isFirstVisit = null,Object? heightValue = freezed,Object? weightValue = freezed,Object? waistCircumferenceValue = freezed,Object? hipCircumferenceValue = freezed,Object? weightMeasured = null,Object? heightMeasured = null,Object? bmiCalculated = null,Object? waistCircumferenceMeasured = null,Object? weightChangeDocumented = null,Object? isIdentityVerified = null,Object? isConsentObtained = null,Object? isReasonForVisitDocumented = null,Object? isDiagnosisReviewed = null,Object? isWeightMeasured = null,Object? isHeightMeasured = null,Object? isBMICalculated = null,Object? isWaistCircumferenceMeasured = null,Object? isRecentWeightChangeDocumented = null,Object? is24HourRecallCompleted = null,Object? isFoodFrequencyAssessed = null,Object? isAllergiesIntolerancesChecked = null,Object? isSupplementsDocumented = null,Object? isDiabetesAssessed = null,Object? isHypertensionAssessed = null,Object? isDyslipidemiaAssessed = null,Object? isObesityAssessed = null,Object? isCKDAssessed = null,Object? isGIDisordersAssessed = null,Object? isMuscleWastingAssessed = null,Object? isFatLossAssessed = null,Object? isEdemaAssessed = null,Object? isAppetiteAssessed = null,Object? isChewingSwallowingAssessed = null,Object? isGlucoseA1cReviewed = null,Object? isLipidProfileReviewed = null,Object? isElectrolytesReviewed = null,Object? isRenalFunctionReviewed = null,Object? isMicronutrientsReviewed = null,Object? isInadequateIntakeDiagnosed = null,Object? isExcessiveIntakeDiagnosed = null,Object? isFoodKnowledgeDeficitIdentified = null,Object? isCaloriePrescriptionSet = null,Object? isMacronutrientDistributionPlanned = null,Object? isEducationProvided = null,Object? isFollowUpPlanEstablished = null,Object? dietary24HRecall = null,Object? foodFrequencyChecked = null,Object? allergiesDocumented = null,Object? supplementsReviewed = null,Object? medicalHistoryReviewed = null,Object? physicalExamCompleted = null,Object? appetiteAssessed = null,Object? giSymptomsEvaluated = null,Object? bloodGlucoseReviewed = null,Object? lipidProfileReviewed = null,Object? micronutrientsReviewed = null,Object? inadequateIntakeDiagnosed = null,Object? excessiveIntakeDiagnosed = null,Object? knowledgeDeficitIdentified = null,Object? disorderedEatingIdentified = null,Object? caloriePrescriptionSet = null,Object? macroDistributionSet = null,Object? mealPlanProvided = null,Object? educationProvided = null,Object? supplementsRecommended = null,Object? targetWeightSet = null,Object? timelineDocumented = null,Object? followUpScheduled = null,Object? monitoringParametersSet = null,Object? writtenInstructionsProvided = null,Object? physicianNotified = null,Object? consentObtained = null,Object? specialization = null,Object? auditLog = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,nutritionistId: null == nutritionistId ? _self.nutritionistId : nutritionistId // ignore: cast_nullable_to_non_nullable
as String,nutritionistName: null == nutritionistName ? _self.nutritionistName : nutritionistName // ignore: cast_nullable_to_non_nullable
as String,appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,visitDate: null == visitDate ? _self.visitDate : visitDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,lastEditedBy: freezed == lastEditedBy ? _self.lastEditedBy : lastEditedBy // ignore: cast_nullable_to_non_nullable
as String?,lastEditedByName: freezed == lastEditedByName ? _self.lastEditedByName : lastEditedByName // ignore: cast_nullable_to_non_nullable
as String?,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,isFirstVisit: null == isFirstVisit ? _self.isFirstVisit : isFirstVisit // ignore: cast_nullable_to_non_nullable
as bool,heightValue: freezed == heightValue ? _self.heightValue : heightValue // ignore: cast_nullable_to_non_nullable
as double?,weightValue: freezed == weightValue ? _self.weightValue : weightValue // ignore: cast_nullable_to_non_nullable
as double?,waistCircumferenceValue: freezed == waistCircumferenceValue ? _self.waistCircumferenceValue : waistCircumferenceValue // ignore: cast_nullable_to_non_nullable
as double?,hipCircumferenceValue: freezed == hipCircumferenceValue ? _self.hipCircumferenceValue : hipCircumferenceValue // ignore: cast_nullable_to_non_nullable
as double?,weightMeasured: null == weightMeasured ? _self.weightMeasured : weightMeasured // ignore: cast_nullable_to_non_nullable
as bool,heightMeasured: null == heightMeasured ? _self.heightMeasured : heightMeasured // ignore: cast_nullable_to_non_nullable
as bool,bmiCalculated: null == bmiCalculated ? _self.bmiCalculated : bmiCalculated // ignore: cast_nullable_to_non_nullable
as bool,waistCircumferenceMeasured: null == waistCircumferenceMeasured ? _self.waistCircumferenceMeasured : waistCircumferenceMeasured // ignore: cast_nullable_to_non_nullable
as bool,weightChangeDocumented: null == weightChangeDocumented ? _self.weightChangeDocumented : weightChangeDocumented // ignore: cast_nullable_to_non_nullable
as bool,isIdentityVerified: null == isIdentityVerified ? _self.isIdentityVerified : isIdentityVerified // ignore: cast_nullable_to_non_nullable
as bool,isConsentObtained: null == isConsentObtained ? _self.isConsentObtained : isConsentObtained // ignore: cast_nullable_to_non_nullable
as bool,isReasonForVisitDocumented: null == isReasonForVisitDocumented ? _self.isReasonForVisitDocumented : isReasonForVisitDocumented // ignore: cast_nullable_to_non_nullable
as bool,isDiagnosisReviewed: null == isDiagnosisReviewed ? _self.isDiagnosisReviewed : isDiagnosisReviewed // ignore: cast_nullable_to_non_nullable
as bool,isWeightMeasured: null == isWeightMeasured ? _self.isWeightMeasured : isWeightMeasured // ignore: cast_nullable_to_non_nullable
as bool,isHeightMeasured: null == isHeightMeasured ? _self.isHeightMeasured : isHeightMeasured // ignore: cast_nullable_to_non_nullable
as bool,isBMICalculated: null == isBMICalculated ? _self.isBMICalculated : isBMICalculated // ignore: cast_nullable_to_non_nullable
as bool,isWaistCircumferenceMeasured: null == isWaistCircumferenceMeasured ? _self.isWaistCircumferenceMeasured : isWaistCircumferenceMeasured // ignore: cast_nullable_to_non_nullable
as bool,isRecentWeightChangeDocumented: null == isRecentWeightChangeDocumented ? _self.isRecentWeightChangeDocumented : isRecentWeightChangeDocumented // ignore: cast_nullable_to_non_nullable
as bool,is24HourRecallCompleted: null == is24HourRecallCompleted ? _self.is24HourRecallCompleted : is24HourRecallCompleted // ignore: cast_nullable_to_non_nullable
as bool,isFoodFrequencyAssessed: null == isFoodFrequencyAssessed ? _self.isFoodFrequencyAssessed : isFoodFrequencyAssessed // ignore: cast_nullable_to_non_nullable
as bool,isAllergiesIntolerancesChecked: null == isAllergiesIntolerancesChecked ? _self.isAllergiesIntolerancesChecked : isAllergiesIntolerancesChecked // ignore: cast_nullable_to_non_nullable
as bool,isSupplementsDocumented: null == isSupplementsDocumented ? _self.isSupplementsDocumented : isSupplementsDocumented // ignore: cast_nullable_to_non_nullable
as bool,isDiabetesAssessed: null == isDiabetesAssessed ? _self.isDiabetesAssessed : isDiabetesAssessed // ignore: cast_nullable_to_non_nullable
as bool,isHypertensionAssessed: null == isHypertensionAssessed ? _self.isHypertensionAssessed : isHypertensionAssessed // ignore: cast_nullable_to_non_nullable
as bool,isDyslipidemiaAssessed: null == isDyslipidemiaAssessed ? _self.isDyslipidemiaAssessed : isDyslipidemiaAssessed // ignore: cast_nullable_to_non_nullable
as bool,isObesityAssessed: null == isObesityAssessed ? _self.isObesityAssessed : isObesityAssessed // ignore: cast_nullable_to_non_nullable
as bool,isCKDAssessed: null == isCKDAssessed ? _self.isCKDAssessed : isCKDAssessed // ignore: cast_nullable_to_non_nullable
as bool,isGIDisordersAssessed: null == isGIDisordersAssessed ? _self.isGIDisordersAssessed : isGIDisordersAssessed // ignore: cast_nullable_to_non_nullable
as bool,isMuscleWastingAssessed: null == isMuscleWastingAssessed ? _self.isMuscleWastingAssessed : isMuscleWastingAssessed // ignore: cast_nullable_to_non_nullable
as bool,isFatLossAssessed: null == isFatLossAssessed ? _self.isFatLossAssessed : isFatLossAssessed // ignore: cast_nullable_to_non_nullable
as bool,isEdemaAssessed: null == isEdemaAssessed ? _self.isEdemaAssessed : isEdemaAssessed // ignore: cast_nullable_to_non_nullable
as bool,isAppetiteAssessed: null == isAppetiteAssessed ? _self.isAppetiteAssessed : isAppetiteAssessed // ignore: cast_nullable_to_non_nullable
as bool,isChewingSwallowingAssessed: null == isChewingSwallowingAssessed ? _self.isChewingSwallowingAssessed : isChewingSwallowingAssessed // ignore: cast_nullable_to_non_nullable
as bool,isGlucoseA1cReviewed: null == isGlucoseA1cReviewed ? _self.isGlucoseA1cReviewed : isGlucoseA1cReviewed // ignore: cast_nullable_to_non_nullable
as bool,isLipidProfileReviewed: null == isLipidProfileReviewed ? _self.isLipidProfileReviewed : isLipidProfileReviewed // ignore: cast_nullable_to_non_nullable
as bool,isElectrolytesReviewed: null == isElectrolytesReviewed ? _self.isElectrolytesReviewed : isElectrolytesReviewed // ignore: cast_nullable_to_non_nullable
as bool,isRenalFunctionReviewed: null == isRenalFunctionReviewed ? _self.isRenalFunctionReviewed : isRenalFunctionReviewed // ignore: cast_nullable_to_non_nullable
as bool,isMicronutrientsReviewed: null == isMicronutrientsReviewed ? _self.isMicronutrientsReviewed : isMicronutrientsReviewed // ignore: cast_nullable_to_non_nullable
as bool,isInadequateIntakeDiagnosed: null == isInadequateIntakeDiagnosed ? _self.isInadequateIntakeDiagnosed : isInadequateIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,isExcessiveIntakeDiagnosed: null == isExcessiveIntakeDiagnosed ? _self.isExcessiveIntakeDiagnosed : isExcessiveIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,isFoodKnowledgeDeficitIdentified: null == isFoodKnowledgeDeficitIdentified ? _self.isFoodKnowledgeDeficitIdentified : isFoodKnowledgeDeficitIdentified // ignore: cast_nullable_to_non_nullable
as bool,isCaloriePrescriptionSet: null == isCaloriePrescriptionSet ? _self.isCaloriePrescriptionSet : isCaloriePrescriptionSet // ignore: cast_nullable_to_non_nullable
as bool,isMacronutrientDistributionPlanned: null == isMacronutrientDistributionPlanned ? _self.isMacronutrientDistributionPlanned : isMacronutrientDistributionPlanned // ignore: cast_nullable_to_non_nullable
as bool,isEducationProvided: null == isEducationProvided ? _self.isEducationProvided : isEducationProvided // ignore: cast_nullable_to_non_nullable
as bool,isFollowUpPlanEstablished: null == isFollowUpPlanEstablished ? _self.isFollowUpPlanEstablished : isFollowUpPlanEstablished // ignore: cast_nullable_to_non_nullable
as bool,dietary24HRecall: null == dietary24HRecall ? _self.dietary24HRecall : dietary24HRecall // ignore: cast_nullable_to_non_nullable
as bool,foodFrequencyChecked: null == foodFrequencyChecked ? _self.foodFrequencyChecked : foodFrequencyChecked // ignore: cast_nullable_to_non_nullable
as bool,allergiesDocumented: null == allergiesDocumented ? _self.allergiesDocumented : allergiesDocumented // ignore: cast_nullable_to_non_nullable
as bool,supplementsReviewed: null == supplementsReviewed ? _self.supplementsReviewed : supplementsReviewed // ignore: cast_nullable_to_non_nullable
as bool,medicalHistoryReviewed: null == medicalHistoryReviewed ? _self.medicalHistoryReviewed : medicalHistoryReviewed // ignore: cast_nullable_to_non_nullable
as bool,physicalExamCompleted: null == physicalExamCompleted ? _self.physicalExamCompleted : physicalExamCompleted // ignore: cast_nullable_to_non_nullable
as bool,appetiteAssessed: null == appetiteAssessed ? _self.appetiteAssessed : appetiteAssessed // ignore: cast_nullable_to_non_nullable
as bool,giSymptomsEvaluated: null == giSymptomsEvaluated ? _self.giSymptomsEvaluated : giSymptomsEvaluated // ignore: cast_nullable_to_non_nullable
as bool,bloodGlucoseReviewed: null == bloodGlucoseReviewed ? _self.bloodGlucoseReviewed : bloodGlucoseReviewed // ignore: cast_nullable_to_non_nullable
as bool,lipidProfileReviewed: null == lipidProfileReviewed ? _self.lipidProfileReviewed : lipidProfileReviewed // ignore: cast_nullable_to_non_nullable
as bool,micronutrientsReviewed: null == micronutrientsReviewed ? _self.micronutrientsReviewed : micronutrientsReviewed // ignore: cast_nullable_to_non_nullable
as bool,inadequateIntakeDiagnosed: null == inadequateIntakeDiagnosed ? _self.inadequateIntakeDiagnosed : inadequateIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,excessiveIntakeDiagnosed: null == excessiveIntakeDiagnosed ? _self.excessiveIntakeDiagnosed : excessiveIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,knowledgeDeficitIdentified: null == knowledgeDeficitIdentified ? _self.knowledgeDeficitIdentified : knowledgeDeficitIdentified // ignore: cast_nullable_to_non_nullable
as bool,disorderedEatingIdentified: null == disorderedEatingIdentified ? _self.disorderedEatingIdentified : disorderedEatingIdentified // ignore: cast_nullable_to_non_nullable
as bool,caloriePrescriptionSet: null == caloriePrescriptionSet ? _self.caloriePrescriptionSet : caloriePrescriptionSet // ignore: cast_nullable_to_non_nullable
as bool,macroDistributionSet: null == macroDistributionSet ? _self.macroDistributionSet : macroDistributionSet // ignore: cast_nullable_to_non_nullable
as bool,mealPlanProvided: null == mealPlanProvided ? _self.mealPlanProvided : mealPlanProvided // ignore: cast_nullable_to_non_nullable
as bool,educationProvided: null == educationProvided ? _self.educationProvided : educationProvided // ignore: cast_nullable_to_non_nullable
as bool,supplementsRecommended: null == supplementsRecommended ? _self.supplementsRecommended : supplementsRecommended // ignore: cast_nullable_to_non_nullable
as bool,targetWeightSet: null == targetWeightSet ? _self.targetWeightSet : targetWeightSet // ignore: cast_nullable_to_non_nullable
as bool,timelineDocumented: null == timelineDocumented ? _self.timelineDocumented : timelineDocumented // ignore: cast_nullable_to_non_nullable
as bool,followUpScheduled: null == followUpScheduled ? _self.followUpScheduled : followUpScheduled // ignore: cast_nullable_to_non_nullable
as bool,monitoringParametersSet: null == monitoringParametersSet ? _self.monitoringParametersSet : monitoringParametersSet // ignore: cast_nullable_to_non_nullable
as bool,writtenInstructionsProvided: null == writtenInstructionsProvided ? _self.writtenInstructionsProvided : writtenInstructionsProvided // ignore: cast_nullable_to_non_nullable
as bool,physicianNotified: null == physicianNotified ? _self.physicianNotified : physicianNotified // ignore: cast_nullable_to_non_nullable
as bool,consentObtained: null == consentObtained ? _self.consentObtained : consentObtained // ignore: cast_nullable_to_non_nullable
as bool,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,auditLog: null == auditLog ? _self.auditLog : auditLog // ignore: cast_nullable_to_non_nullable
as List<AuditLogEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionEMREntity].
extension NutritionEMREntityPatterns on NutritionEMREntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionEMREntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionEMREntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionEMREntity value)  $default,){
final _that = this;
switch (_that) {
case _NutritionEMREntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionEMREntity value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionEMREntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String nutritionistId,  String nutritionistName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  DateTime updatedAt,  int editCount,  String? lastEditedBy,  String? lastEditedByName,  bool isLocked,  DateTime? lockedUntil,  bool isFirstVisit,  double? heightValue,  double? weightValue,  double? waistCircumferenceValue,  double? hipCircumferenceValue,  bool weightMeasured,  bool heightMeasured,  bool bmiCalculated,  bool waistCircumferenceMeasured,  bool weightChangeDocumented,  bool isIdentityVerified,  bool isConsentObtained,  bool isReasonForVisitDocumented,  bool isDiagnosisReviewed,  bool isWeightMeasured,  bool isHeightMeasured,  bool isBMICalculated,  bool isWaistCircumferenceMeasured,  bool isRecentWeightChangeDocumented,  bool is24HourRecallCompleted,  bool isFoodFrequencyAssessed,  bool isAllergiesIntolerancesChecked,  bool isSupplementsDocumented,  bool isDiabetesAssessed,  bool isHypertensionAssessed,  bool isDyslipidemiaAssessed,  bool isObesityAssessed,  bool isCKDAssessed,  bool isGIDisordersAssessed,  bool isMuscleWastingAssessed,  bool isFatLossAssessed,  bool isEdemaAssessed,  bool isAppetiteAssessed,  bool isChewingSwallowingAssessed,  bool isGlucoseA1cReviewed,  bool isLipidProfileReviewed,  bool isElectrolytesReviewed,  bool isRenalFunctionReviewed,  bool isMicronutrientsReviewed,  bool isInadequateIntakeDiagnosed,  bool isExcessiveIntakeDiagnosed,  bool isFoodKnowledgeDeficitIdentified,  bool isCaloriePrescriptionSet,  bool isMacronutrientDistributionPlanned,  bool isEducationProvided,  bool isFollowUpPlanEstablished,  bool dietary24HRecall,  bool foodFrequencyChecked,  bool allergiesDocumented,  bool supplementsReviewed,  bool medicalHistoryReviewed,  bool physicalExamCompleted,  bool appetiteAssessed,  bool giSymptomsEvaluated,  bool bloodGlucoseReviewed,  bool lipidProfileReviewed,  bool micronutrientsReviewed,  bool inadequateIntakeDiagnosed,  bool excessiveIntakeDiagnosed,  bool knowledgeDeficitIdentified,  bool disorderedEatingIdentified,  bool caloriePrescriptionSet,  bool macroDistributionSet,  bool mealPlanProvided,  bool educationProvided,  bool supplementsRecommended,  bool targetWeightSet,  bool timelineDocumented,  bool followUpScheduled,  bool monitoringParametersSet,  bool writtenInstructionsProvided,  bool physicianNotified,  bool consentObtained,  String specialization,  List<AuditLogEntry> auditLog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionEMREntity() when $default != null:
return $default(_that.id,_that.patientId,_that.nutritionistId,_that.nutritionistName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.updatedAt,_that.editCount,_that.lastEditedBy,_that.lastEditedByName,_that.isLocked,_that.lockedUntil,_that.isFirstVisit,_that.heightValue,_that.weightValue,_that.waistCircumferenceValue,_that.hipCircumferenceValue,_that.weightMeasured,_that.heightMeasured,_that.bmiCalculated,_that.waistCircumferenceMeasured,_that.weightChangeDocumented,_that.isIdentityVerified,_that.isConsentObtained,_that.isReasonForVisitDocumented,_that.isDiagnosisReviewed,_that.isWeightMeasured,_that.isHeightMeasured,_that.isBMICalculated,_that.isWaistCircumferenceMeasured,_that.isRecentWeightChangeDocumented,_that.is24HourRecallCompleted,_that.isFoodFrequencyAssessed,_that.isAllergiesIntolerancesChecked,_that.isSupplementsDocumented,_that.isDiabetesAssessed,_that.isHypertensionAssessed,_that.isDyslipidemiaAssessed,_that.isObesityAssessed,_that.isCKDAssessed,_that.isGIDisordersAssessed,_that.isMuscleWastingAssessed,_that.isFatLossAssessed,_that.isEdemaAssessed,_that.isAppetiteAssessed,_that.isChewingSwallowingAssessed,_that.isGlucoseA1cReviewed,_that.isLipidProfileReviewed,_that.isElectrolytesReviewed,_that.isRenalFunctionReviewed,_that.isMicronutrientsReviewed,_that.isInadequateIntakeDiagnosed,_that.isExcessiveIntakeDiagnosed,_that.isFoodKnowledgeDeficitIdentified,_that.isCaloriePrescriptionSet,_that.isMacronutrientDistributionPlanned,_that.isEducationProvided,_that.isFollowUpPlanEstablished,_that.dietary24HRecall,_that.foodFrequencyChecked,_that.allergiesDocumented,_that.supplementsReviewed,_that.medicalHistoryReviewed,_that.physicalExamCompleted,_that.appetiteAssessed,_that.giSymptomsEvaluated,_that.bloodGlucoseReviewed,_that.lipidProfileReviewed,_that.micronutrientsReviewed,_that.inadequateIntakeDiagnosed,_that.excessiveIntakeDiagnosed,_that.knowledgeDeficitIdentified,_that.disorderedEatingIdentified,_that.caloriePrescriptionSet,_that.macroDistributionSet,_that.mealPlanProvided,_that.educationProvided,_that.supplementsRecommended,_that.targetWeightSet,_that.timelineDocumented,_that.followUpScheduled,_that.monitoringParametersSet,_that.writtenInstructionsProvided,_that.physicianNotified,_that.consentObtained,_that.specialization,_that.auditLog);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String nutritionistId,  String nutritionistName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  DateTime updatedAt,  int editCount,  String? lastEditedBy,  String? lastEditedByName,  bool isLocked,  DateTime? lockedUntil,  bool isFirstVisit,  double? heightValue,  double? weightValue,  double? waistCircumferenceValue,  double? hipCircumferenceValue,  bool weightMeasured,  bool heightMeasured,  bool bmiCalculated,  bool waistCircumferenceMeasured,  bool weightChangeDocumented,  bool isIdentityVerified,  bool isConsentObtained,  bool isReasonForVisitDocumented,  bool isDiagnosisReviewed,  bool isWeightMeasured,  bool isHeightMeasured,  bool isBMICalculated,  bool isWaistCircumferenceMeasured,  bool isRecentWeightChangeDocumented,  bool is24HourRecallCompleted,  bool isFoodFrequencyAssessed,  bool isAllergiesIntolerancesChecked,  bool isSupplementsDocumented,  bool isDiabetesAssessed,  bool isHypertensionAssessed,  bool isDyslipidemiaAssessed,  bool isObesityAssessed,  bool isCKDAssessed,  bool isGIDisordersAssessed,  bool isMuscleWastingAssessed,  bool isFatLossAssessed,  bool isEdemaAssessed,  bool isAppetiteAssessed,  bool isChewingSwallowingAssessed,  bool isGlucoseA1cReviewed,  bool isLipidProfileReviewed,  bool isElectrolytesReviewed,  bool isRenalFunctionReviewed,  bool isMicronutrientsReviewed,  bool isInadequateIntakeDiagnosed,  bool isExcessiveIntakeDiagnosed,  bool isFoodKnowledgeDeficitIdentified,  bool isCaloriePrescriptionSet,  bool isMacronutrientDistributionPlanned,  bool isEducationProvided,  bool isFollowUpPlanEstablished,  bool dietary24HRecall,  bool foodFrequencyChecked,  bool allergiesDocumented,  bool supplementsReviewed,  bool medicalHistoryReviewed,  bool physicalExamCompleted,  bool appetiteAssessed,  bool giSymptomsEvaluated,  bool bloodGlucoseReviewed,  bool lipidProfileReviewed,  bool micronutrientsReviewed,  bool inadequateIntakeDiagnosed,  bool excessiveIntakeDiagnosed,  bool knowledgeDeficitIdentified,  bool disorderedEatingIdentified,  bool caloriePrescriptionSet,  bool macroDistributionSet,  bool mealPlanProvided,  bool educationProvided,  bool supplementsRecommended,  bool targetWeightSet,  bool timelineDocumented,  bool followUpScheduled,  bool monitoringParametersSet,  bool writtenInstructionsProvided,  bool physicianNotified,  bool consentObtained,  String specialization,  List<AuditLogEntry> auditLog)  $default,) {final _that = this;
switch (_that) {
case _NutritionEMREntity():
return $default(_that.id,_that.patientId,_that.nutritionistId,_that.nutritionistName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.updatedAt,_that.editCount,_that.lastEditedBy,_that.lastEditedByName,_that.isLocked,_that.lockedUntil,_that.isFirstVisit,_that.heightValue,_that.weightValue,_that.waistCircumferenceValue,_that.hipCircumferenceValue,_that.weightMeasured,_that.heightMeasured,_that.bmiCalculated,_that.waistCircumferenceMeasured,_that.weightChangeDocumented,_that.isIdentityVerified,_that.isConsentObtained,_that.isReasonForVisitDocumented,_that.isDiagnosisReviewed,_that.isWeightMeasured,_that.isHeightMeasured,_that.isBMICalculated,_that.isWaistCircumferenceMeasured,_that.isRecentWeightChangeDocumented,_that.is24HourRecallCompleted,_that.isFoodFrequencyAssessed,_that.isAllergiesIntolerancesChecked,_that.isSupplementsDocumented,_that.isDiabetesAssessed,_that.isHypertensionAssessed,_that.isDyslipidemiaAssessed,_that.isObesityAssessed,_that.isCKDAssessed,_that.isGIDisordersAssessed,_that.isMuscleWastingAssessed,_that.isFatLossAssessed,_that.isEdemaAssessed,_that.isAppetiteAssessed,_that.isChewingSwallowingAssessed,_that.isGlucoseA1cReviewed,_that.isLipidProfileReviewed,_that.isElectrolytesReviewed,_that.isRenalFunctionReviewed,_that.isMicronutrientsReviewed,_that.isInadequateIntakeDiagnosed,_that.isExcessiveIntakeDiagnosed,_that.isFoodKnowledgeDeficitIdentified,_that.isCaloriePrescriptionSet,_that.isMacronutrientDistributionPlanned,_that.isEducationProvided,_that.isFollowUpPlanEstablished,_that.dietary24HRecall,_that.foodFrequencyChecked,_that.allergiesDocumented,_that.supplementsReviewed,_that.medicalHistoryReviewed,_that.physicalExamCompleted,_that.appetiteAssessed,_that.giSymptomsEvaluated,_that.bloodGlucoseReviewed,_that.lipidProfileReviewed,_that.micronutrientsReviewed,_that.inadequateIntakeDiagnosed,_that.excessiveIntakeDiagnosed,_that.knowledgeDeficitIdentified,_that.disorderedEatingIdentified,_that.caloriePrescriptionSet,_that.macroDistributionSet,_that.mealPlanProvided,_that.educationProvided,_that.supplementsRecommended,_that.targetWeightSet,_that.timelineDocumented,_that.followUpScheduled,_that.monitoringParametersSet,_that.writtenInstructionsProvided,_that.physicianNotified,_that.consentObtained,_that.specialization,_that.auditLog);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String nutritionistId,  String nutritionistName,  String appointmentId,  DateTime visitDate,  DateTime createdAt,  DateTime updatedAt,  int editCount,  String? lastEditedBy,  String? lastEditedByName,  bool isLocked,  DateTime? lockedUntil,  bool isFirstVisit,  double? heightValue,  double? weightValue,  double? waistCircumferenceValue,  double? hipCircumferenceValue,  bool weightMeasured,  bool heightMeasured,  bool bmiCalculated,  bool waistCircumferenceMeasured,  bool weightChangeDocumented,  bool isIdentityVerified,  bool isConsentObtained,  bool isReasonForVisitDocumented,  bool isDiagnosisReviewed,  bool isWeightMeasured,  bool isHeightMeasured,  bool isBMICalculated,  bool isWaistCircumferenceMeasured,  bool isRecentWeightChangeDocumented,  bool is24HourRecallCompleted,  bool isFoodFrequencyAssessed,  bool isAllergiesIntolerancesChecked,  bool isSupplementsDocumented,  bool isDiabetesAssessed,  bool isHypertensionAssessed,  bool isDyslipidemiaAssessed,  bool isObesityAssessed,  bool isCKDAssessed,  bool isGIDisordersAssessed,  bool isMuscleWastingAssessed,  bool isFatLossAssessed,  bool isEdemaAssessed,  bool isAppetiteAssessed,  bool isChewingSwallowingAssessed,  bool isGlucoseA1cReviewed,  bool isLipidProfileReviewed,  bool isElectrolytesReviewed,  bool isRenalFunctionReviewed,  bool isMicronutrientsReviewed,  bool isInadequateIntakeDiagnosed,  bool isExcessiveIntakeDiagnosed,  bool isFoodKnowledgeDeficitIdentified,  bool isCaloriePrescriptionSet,  bool isMacronutrientDistributionPlanned,  bool isEducationProvided,  bool isFollowUpPlanEstablished,  bool dietary24HRecall,  bool foodFrequencyChecked,  bool allergiesDocumented,  bool supplementsReviewed,  bool medicalHistoryReviewed,  bool physicalExamCompleted,  bool appetiteAssessed,  bool giSymptomsEvaluated,  bool bloodGlucoseReviewed,  bool lipidProfileReviewed,  bool micronutrientsReviewed,  bool inadequateIntakeDiagnosed,  bool excessiveIntakeDiagnosed,  bool knowledgeDeficitIdentified,  bool disorderedEatingIdentified,  bool caloriePrescriptionSet,  bool macroDistributionSet,  bool mealPlanProvided,  bool educationProvided,  bool supplementsRecommended,  bool targetWeightSet,  bool timelineDocumented,  bool followUpScheduled,  bool monitoringParametersSet,  bool writtenInstructionsProvided,  bool physicianNotified,  bool consentObtained,  String specialization,  List<AuditLogEntry> auditLog)?  $default,) {final _that = this;
switch (_that) {
case _NutritionEMREntity() when $default != null:
return $default(_that.id,_that.patientId,_that.nutritionistId,_that.nutritionistName,_that.appointmentId,_that.visitDate,_that.createdAt,_that.updatedAt,_that.editCount,_that.lastEditedBy,_that.lastEditedByName,_that.isLocked,_that.lockedUntil,_that.isFirstVisit,_that.heightValue,_that.weightValue,_that.waistCircumferenceValue,_that.hipCircumferenceValue,_that.weightMeasured,_that.heightMeasured,_that.bmiCalculated,_that.waistCircumferenceMeasured,_that.weightChangeDocumented,_that.isIdentityVerified,_that.isConsentObtained,_that.isReasonForVisitDocumented,_that.isDiagnosisReviewed,_that.isWeightMeasured,_that.isHeightMeasured,_that.isBMICalculated,_that.isWaistCircumferenceMeasured,_that.isRecentWeightChangeDocumented,_that.is24HourRecallCompleted,_that.isFoodFrequencyAssessed,_that.isAllergiesIntolerancesChecked,_that.isSupplementsDocumented,_that.isDiabetesAssessed,_that.isHypertensionAssessed,_that.isDyslipidemiaAssessed,_that.isObesityAssessed,_that.isCKDAssessed,_that.isGIDisordersAssessed,_that.isMuscleWastingAssessed,_that.isFatLossAssessed,_that.isEdemaAssessed,_that.isAppetiteAssessed,_that.isChewingSwallowingAssessed,_that.isGlucoseA1cReviewed,_that.isLipidProfileReviewed,_that.isElectrolytesReviewed,_that.isRenalFunctionReviewed,_that.isMicronutrientsReviewed,_that.isInadequateIntakeDiagnosed,_that.isExcessiveIntakeDiagnosed,_that.isFoodKnowledgeDeficitIdentified,_that.isCaloriePrescriptionSet,_that.isMacronutrientDistributionPlanned,_that.isEducationProvided,_that.isFollowUpPlanEstablished,_that.dietary24HRecall,_that.foodFrequencyChecked,_that.allergiesDocumented,_that.supplementsReviewed,_that.medicalHistoryReviewed,_that.physicalExamCompleted,_that.appetiteAssessed,_that.giSymptomsEvaluated,_that.bloodGlucoseReviewed,_that.lipidProfileReviewed,_that.micronutrientsReviewed,_that.inadequateIntakeDiagnosed,_that.excessiveIntakeDiagnosed,_that.knowledgeDeficitIdentified,_that.disorderedEatingIdentified,_that.caloriePrescriptionSet,_that.macroDistributionSet,_that.mealPlanProvided,_that.educationProvided,_that.supplementsRecommended,_that.targetWeightSet,_that.timelineDocumented,_that.followUpScheduled,_that.monitoringParametersSet,_that.writtenInstructionsProvided,_that.physicianNotified,_that.consentObtained,_that.specialization,_that.auditLog);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NutritionEMREntity extends NutritionEMREntity {
  const _NutritionEMREntity({required this.id, required this.patientId, required this.nutritionistId, required this.nutritionistName, required this.appointmentId, required this.visitDate, required this.createdAt, required this.updatedAt, this.editCount = 0, this.lastEditedBy, this.lastEditedByName, this.isLocked = false, this.lockedUntil, this.isFirstVisit = true, this.heightValue, this.weightValue, this.waistCircumferenceValue, this.hipCircumferenceValue, this.weightMeasured = false, this.heightMeasured = false, this.bmiCalculated = false, this.waistCircumferenceMeasured = false, this.weightChangeDocumented = false, this.isIdentityVerified = false, this.isConsentObtained = false, this.isReasonForVisitDocumented = false, this.isDiagnosisReviewed = false, this.isWeightMeasured = false, this.isHeightMeasured = false, this.isBMICalculated = false, this.isWaistCircumferenceMeasured = false, this.isRecentWeightChangeDocumented = false, this.is24HourRecallCompleted = false, this.isFoodFrequencyAssessed = false, this.isAllergiesIntolerancesChecked = false, this.isSupplementsDocumented = false, this.isDiabetesAssessed = false, this.isHypertensionAssessed = false, this.isDyslipidemiaAssessed = false, this.isObesityAssessed = false, this.isCKDAssessed = false, this.isGIDisordersAssessed = false, this.isMuscleWastingAssessed = false, this.isFatLossAssessed = false, this.isEdemaAssessed = false, this.isAppetiteAssessed = false, this.isChewingSwallowingAssessed = false, this.isGlucoseA1cReviewed = false, this.isLipidProfileReviewed = false, this.isElectrolytesReviewed = false, this.isRenalFunctionReviewed = false, this.isMicronutrientsReviewed = false, this.isInadequateIntakeDiagnosed = false, this.isExcessiveIntakeDiagnosed = false, this.isFoodKnowledgeDeficitIdentified = false, this.isCaloriePrescriptionSet = false, this.isMacronutrientDistributionPlanned = false, this.isEducationProvided = false, this.isFollowUpPlanEstablished = false, this.dietary24HRecall = false, this.foodFrequencyChecked = false, this.allergiesDocumented = false, this.supplementsReviewed = false, this.medicalHistoryReviewed = false, this.physicalExamCompleted = false, this.appetiteAssessed = false, this.giSymptomsEvaluated = false, this.bloodGlucoseReviewed = false, this.lipidProfileReviewed = false, this.micronutrientsReviewed = false, this.inadequateIntakeDiagnosed = false, this.excessiveIntakeDiagnosed = false, this.knowledgeDeficitIdentified = false, this.disorderedEatingIdentified = false, this.caloriePrescriptionSet = false, this.macroDistributionSet = false, this.mealPlanProvided = false, this.educationProvided = false, this.supplementsRecommended = false, this.targetWeightSet = false, this.timelineDocumented = false, this.followUpScheduled = false, this.monitoringParametersSet = false, this.writtenInstructionsProvided = false, this.physicianNotified = false, this.consentObtained = false, this.specialization = 'عيادة السمنة والتغذية العلاجية', final  List<AuditLogEntry> auditLog = const []}): _auditLog = auditLog,super._();
  factory _NutritionEMREntity.fromJson(Map<String, dynamic> json) => _$NutritionEMREntityFromJson(json);

/// Unique identifier for this EMR record (UUID v4)
@override final  String id;
/// Patient identifier from patients collection
@override final  String patientId;
/// Nutritionist/Doctor identifier from users collection
@override final  String nutritionistId;
/// Nutritionist's full name for display and audit
@override final  String nutritionistName;
/// Appointment ID linking to appointments collection
@override final  String appointmentId;
/// Visit date and time (from appointment)
@override final  DateTime visitDate;
/// Record creation timestamp
@override final  DateTime createdAt;
/// Last modification timestamp
@override final  DateTime updatedAt;
// ═══════════════════════════════════════════════════════════════════════
// 🔐 SECURITY & LOCKING FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// Number of times this EMR has been edited (after creation)
@override@JsonKey() final  int editCount;
/// User ID of the last person who edited this record
@override final  String? lastEditedBy;
/// Name of the last person who edited this record (for audit display)
@override final  String? lastEditedByName;
// ═══════════════════════════════════════════════════════════════════════
// 🔐 ORIGINAL LOCKING FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// Lock status - prevents editing after 24 hours from creation
@override@JsonKey() final  bool isLocked;
/// Lock expiration timestamp (createdAt + 24 hours)
@override final  DateTime? lockedUntil;
/// Determines UI mode: true = Wizard (first visit), false = Tabs
@override@JsonKey() final  bool isFirstVisit;
// ═══════════════════════════════════════════════════════════════════════
// 📏 ANTHROPOMETRIC MEASUREMENT VALUES (Numeric Data)
// ═══════════════════════════════════════════════════════════════════════
/// Height in centimeters
@override final  double? heightValue;
/// Weight in kilograms
@override final  double? weightValue;
/// Waist circumference in centimeters
@override final  double? waistCircumferenceValue;
/// Hip circumference in centimeters (optional)
@override final  double? hipCircumferenceValue;
// ═══════════════════════════════════════════════════════════════════════
// 📋 SECTION 1: ANTHROPOMETRIC MEASUREMENTS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Body weight measured and documented (kg)
@override@JsonKey() final  bool weightMeasured;
/// Height/stature measured and documented (cm)
@override@JsonKey() final  bool heightMeasured;
/// Body Mass Index calculated (Weight/Height²)
@override@JsonKey() final  bool bmiCalculated;
/// Waist circumference measured (cm)
@override@JsonKey() final  bool waistCircumferenceMeasured;
/// Recent weight change documented (last 6 months)
@override@JsonKey() final  bool weightChangeDocumented;
// ═══════════════════════════════════════════════════════════════════════
// 📋 COMPREHENSIVE CHECKLIST - SECTION 1: PATIENT AND VISIT BASICS (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Patient identity verified
@override@JsonKey() final  bool isIdentityVerified;
/// Informed consent obtained
@override@JsonKey() final  bool isConsentObtained;
/// Reason for visit documented
@override@JsonKey() final  bool isReasonForVisitDocumented;
/// Diagnosis reviewed
@override@JsonKey() final  bool isDiagnosisReviewed;
// ═══════════════════════════════════════════════════════════════════════
// 📏 COMPREHENSIVE CHECKLIST - SECTION 2: ANTHROPOMETRIC MEASUREMENTS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Weight measured and documented
@override@JsonKey() final  bool isWeightMeasured;
/// Height measured and documented
@override@JsonKey() final  bool isHeightMeasured;
/// BMI calculated
@override@JsonKey() final  bool isBMICalculated;
/// Waist circumference measured
@override@JsonKey() final  bool isWaistCircumferenceMeasured;
/// Recent weight change documented
@override@JsonKey() final  bool isRecentWeightChangeDocumented;
// ═══════════════════════════════════════════════════════════════════════
// 🍽️ COMPREHENSIVE CHECKLIST - SECTION 3: DIETARY INTAKE ASSESSMENT (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// 24-hour dietary recall completed
@override@JsonKey() final  bool is24HourRecallCompleted;
/// Food frequency questionnaire assessed
@override@JsonKey() final  bool isFoodFrequencyAssessed;
/// Food allergies and intolerances checked
@override@JsonKey() final  bool isAllergiesIntolerancesChecked;
/// Dietary supplements documented
@override@JsonKey() final  bool isSupplementsDocumented;
// ═══════════════════════════════════════════════════════════════════════
// 🏥 COMPREHENSIVE CHECKLIST - SECTION 4: MEDICAL CONDITIONS REVIEW (6 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Diabetes mellitus assessed
@override@JsonKey() final  bool isDiabetesAssessed;
/// Hypertension assessed
@override@JsonKey() final  bool isHypertensionAssessed;
/// Dyslipidemia (lipid disorders) assessed
@override@JsonKey() final  bool isDyslipidemiaAssessed;
/// Obesity assessed
@override@JsonKey() final  bool isObesityAssessed;
/// Chronic kidney disease assessed
@override@JsonKey() final  bool isCKDAssessed;
/// Gastrointestinal disorders assessed
@override@JsonKey() final  bool isGIDisordersAssessed;
// ═══════════════════════════════════════════════════════════════════════
// 👁️ COMPREHENSIVE CHECKLIST - SECTION 5: NUTRITION FOCUSED PHYSICAL FINDINGS (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Muscle wasting (sarcopenia) assessed
@override@JsonKey() final  bool isMuscleWastingAssessed;
/// Fat loss or gain assessed
@override@JsonKey() final  bool isFatLossAssessed;
/// Edema (fluid retention) assessed
@override@JsonKey() final  bool isEdemaAssessed;
/// Appetite level assessed
@override@JsonKey() final  bool isAppetiteAssessed;
/// Chewing and swallowing difficulties assessed
@override@JsonKey() final  bool isChewingSwallowingAssessed;
// ═══════════════════════════════════════════════════════════════════════
// 🧪 COMPREHENSIVE CHECKLIST - SECTION 6: BIOCHEMICAL DATA REVIEW (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Blood glucose and HbA1c reviewed
@override@JsonKey() final  bool isGlucoseA1cReviewed;
/// Lipid profile reviewed (cholesterol, triglycerides)
@override@JsonKey() final  bool isLipidProfileReviewed;
/// Electrolytes reviewed (Na, K, Cl)
@override@JsonKey() final  bool isElectrolytesReviewed;
/// Renal function reviewed (creatinine, BUN)
@override@JsonKey() final  bool isRenalFunctionReviewed;
/// Micronutrients reviewed (vitamins, minerals)
@override@JsonKey() final  bool isMicronutrientsReviewed;
// ═══════════════════════════════════════════════════════════════════════
// 🎯 COMPREHENSIVE CHECKLIST - SECTION 7: NUTRITION DIAGNOSIS (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Inadequate intake diagnosed
@override@JsonKey() final  bool isInadequateIntakeDiagnosed;
/// Excessive intake diagnosed
@override@JsonKey() final  bool isExcessiveIntakeDiagnosed;
/// Food/nutrition knowledge deficit identified
@override@JsonKey() final  bool isFoodKnowledgeDeficitIdentified;
// ═══════════════════════════════════════════════════════════════════════
// 💊 COMPREHENSIVE CHECKLIST - SECTION 8: INTERVENTION PLAN (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Calorie prescription set
@override@JsonKey() final  bool isCaloriePrescriptionSet;
/// Macronutrient distribution planned
@override@JsonKey() final  bool isMacronutrientDistributionPlanned;
/// Nutrition education provided
@override@JsonKey() final  bool isEducationProvided;
/// Follow-up plan established
@override@JsonKey() final  bool isFollowUpPlanEstablished;
// ═══════════════════════════════════════════════════════════════════════
// 🍽️ SECTION 2: DIETARY ASSESSMENT (4 fields) - ORIGINAL FIELDS
// ═══════════════════════════════════════════════════════════════════════
/// 24-hour dietary recall completed
@override@JsonKey() final  bool dietary24HRecall;
/// Food frequency questionnaire administered
@override@JsonKey() final  bool foodFrequencyChecked;
/// Food allergies and intolerances documented
@override@JsonKey() final  bool allergiesDocumented;
/// Current dietary supplements reviewed and recorded
@override@JsonKey() final  bool supplementsReviewed;
// ═══════════════════════════════════════════════════════════════════════
// 🏥 SECTION 3: CLINICAL ASSESSMENT (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Medical history reviewed (chronic diseases, medications)
@override@JsonKey() final  bool medicalHistoryReviewed;
/// Physical examination completed (muscle/fat assessment)
@override@JsonKey() final  bool physicalExamCompleted;
/// Appetite and eating patterns assessed
@override@JsonKey() final  bool appetiteAssessed;
/// Gastrointestinal symptoms evaluated
@override@JsonKey() final  bool giSymptomsEvaluated;
// ═══════════════════════════════════════════════════════════════════════
// 🧪 SECTION 4: LAB RESULTS REVIEW (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Blood glucose/HbA1c results reviewed
@override@JsonKey() final  bool bloodGlucoseReviewed;
/// Lipid profile reviewed (cholesterol, triglycerides)
@override@JsonKey() final  bool lipidProfileReviewed;
/// Micronutrients status reviewed (vitamins, minerals)
@override@JsonKey() final  bool micronutrientsReviewed;
// ═══════════════════════════════════════════════════════════════════════
// 🎯 SECTION 5: NUTRITION DIAGNOSIS (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Inadequate energy or nutrient intake diagnosed
@override@JsonKey() final  bool inadequateIntakeDiagnosed;
/// Excessive energy or nutrient intake diagnosed
@override@JsonKey() final  bool excessiveIntakeDiagnosed;
/// Inappropriate food/nutrition knowledge deficit
@override@JsonKey() final  bool knowledgeDeficitIdentified;
/// Disordered eating pattern identified
@override@JsonKey() final  bool disorderedEatingIdentified;
// ═══════════════════════════════════════════════════════════════════════
// 💊 SECTION 6: NUTRITION INTERVENTION (5 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Calorie prescription determined and documented
@override@JsonKey() final  bool caloriePrescriptionSet;
/// Macronutrient distribution calculated (Carbs/Protein/Fat)
@override@JsonKey() final  bool macroDistributionSet;
/// Meal plan created and provided to patient
@override@JsonKey() final  bool mealPlanProvided;
/// Nutrition education session provided
@override@JsonKey() final  bool educationProvided;
/// Dietary supplements recommended (if needed)
@override@JsonKey() final  bool supplementsRecommended;
// ═══════════════════════════════════════════════════════════════════════
// 📊 SECTION 7: MONITORING AND EVALUATION (4 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Target weight goal established
@override@JsonKey() final  bool targetWeightSet;
/// Expected timeline for goals documented
@override@JsonKey() final  bool timelineDocumented;
/// Follow-up appointment scheduled
@override@JsonKey() final  bool followUpScheduled;
/// Monitoring parameters defined (weight, labs, symptoms)
@override@JsonKey() final  bool monitoringParametersSet;
// ═══════════════════════════════════════════════════════════════════════
// 📝 SECTION 8: DOCUMENTATION AND COMMUNICATION (3 fields)
// ═══════════════════════════════════════════════════════════════════════
/// Patient given written instructions
@override@JsonKey() final  bool writtenInstructionsProvided;
/// Referring physician notified (if applicable)
@override@JsonKey() final  bool physicianNotified;
/// Patient consent for treatment obtained
@override@JsonKey() final  bool consentObtained;
// ═══════════════════════════════════════════════════════════════════════
// 📊 METADATA
// ═══════════════════════════════════════════════════════════════════════
/// Clinic specialization identifier
@override@JsonKey() final  String specialization;
/// Audit trail for all changes (list of change entries)
 final  List<AuditLogEntry> _auditLog;
/// Audit trail for all changes (list of change entries)
@override@JsonKey() List<AuditLogEntry> get auditLog {
  if (_auditLog is EqualUnmodifiableListView) return _auditLog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_auditLog);
}


/// Create a copy of NutritionEMREntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionEMREntityCopyWith<_NutritionEMREntity> get copyWith => __$NutritionEMREntityCopyWithImpl<_NutritionEMREntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionEMREntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionEMREntity&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.nutritionistId, nutritionistId) || other.nutritionistId == nutritionistId)&&(identical(other.nutritionistName, nutritionistName) || other.nutritionistName == nutritionistName)&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.visitDate, visitDate) || other.visitDate == visitDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.lastEditedBy, lastEditedBy) || other.lastEditedBy == lastEditedBy)&&(identical(other.lastEditedByName, lastEditedByName) || other.lastEditedByName == lastEditedByName)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.lockedUntil, lockedUntil) || other.lockedUntil == lockedUntil)&&(identical(other.isFirstVisit, isFirstVisit) || other.isFirstVisit == isFirstVisit)&&(identical(other.heightValue, heightValue) || other.heightValue == heightValue)&&(identical(other.weightValue, weightValue) || other.weightValue == weightValue)&&(identical(other.waistCircumferenceValue, waistCircumferenceValue) || other.waistCircumferenceValue == waistCircumferenceValue)&&(identical(other.hipCircumferenceValue, hipCircumferenceValue) || other.hipCircumferenceValue == hipCircumferenceValue)&&(identical(other.weightMeasured, weightMeasured) || other.weightMeasured == weightMeasured)&&(identical(other.heightMeasured, heightMeasured) || other.heightMeasured == heightMeasured)&&(identical(other.bmiCalculated, bmiCalculated) || other.bmiCalculated == bmiCalculated)&&(identical(other.waistCircumferenceMeasured, waistCircumferenceMeasured) || other.waistCircumferenceMeasured == waistCircumferenceMeasured)&&(identical(other.weightChangeDocumented, weightChangeDocumented) || other.weightChangeDocumented == weightChangeDocumented)&&(identical(other.isIdentityVerified, isIdentityVerified) || other.isIdentityVerified == isIdentityVerified)&&(identical(other.isConsentObtained, isConsentObtained) || other.isConsentObtained == isConsentObtained)&&(identical(other.isReasonForVisitDocumented, isReasonForVisitDocumented) || other.isReasonForVisitDocumented == isReasonForVisitDocumented)&&(identical(other.isDiagnosisReviewed, isDiagnosisReviewed) || other.isDiagnosisReviewed == isDiagnosisReviewed)&&(identical(other.isWeightMeasured, isWeightMeasured) || other.isWeightMeasured == isWeightMeasured)&&(identical(other.isHeightMeasured, isHeightMeasured) || other.isHeightMeasured == isHeightMeasured)&&(identical(other.isBMICalculated, isBMICalculated) || other.isBMICalculated == isBMICalculated)&&(identical(other.isWaistCircumferenceMeasured, isWaistCircumferenceMeasured) || other.isWaistCircumferenceMeasured == isWaistCircumferenceMeasured)&&(identical(other.isRecentWeightChangeDocumented, isRecentWeightChangeDocumented) || other.isRecentWeightChangeDocumented == isRecentWeightChangeDocumented)&&(identical(other.is24HourRecallCompleted, is24HourRecallCompleted) || other.is24HourRecallCompleted == is24HourRecallCompleted)&&(identical(other.isFoodFrequencyAssessed, isFoodFrequencyAssessed) || other.isFoodFrequencyAssessed == isFoodFrequencyAssessed)&&(identical(other.isAllergiesIntolerancesChecked, isAllergiesIntolerancesChecked) || other.isAllergiesIntolerancesChecked == isAllergiesIntolerancesChecked)&&(identical(other.isSupplementsDocumented, isSupplementsDocumented) || other.isSupplementsDocumented == isSupplementsDocumented)&&(identical(other.isDiabetesAssessed, isDiabetesAssessed) || other.isDiabetesAssessed == isDiabetesAssessed)&&(identical(other.isHypertensionAssessed, isHypertensionAssessed) || other.isHypertensionAssessed == isHypertensionAssessed)&&(identical(other.isDyslipidemiaAssessed, isDyslipidemiaAssessed) || other.isDyslipidemiaAssessed == isDyslipidemiaAssessed)&&(identical(other.isObesityAssessed, isObesityAssessed) || other.isObesityAssessed == isObesityAssessed)&&(identical(other.isCKDAssessed, isCKDAssessed) || other.isCKDAssessed == isCKDAssessed)&&(identical(other.isGIDisordersAssessed, isGIDisordersAssessed) || other.isGIDisordersAssessed == isGIDisordersAssessed)&&(identical(other.isMuscleWastingAssessed, isMuscleWastingAssessed) || other.isMuscleWastingAssessed == isMuscleWastingAssessed)&&(identical(other.isFatLossAssessed, isFatLossAssessed) || other.isFatLossAssessed == isFatLossAssessed)&&(identical(other.isEdemaAssessed, isEdemaAssessed) || other.isEdemaAssessed == isEdemaAssessed)&&(identical(other.isAppetiteAssessed, isAppetiteAssessed) || other.isAppetiteAssessed == isAppetiteAssessed)&&(identical(other.isChewingSwallowingAssessed, isChewingSwallowingAssessed) || other.isChewingSwallowingAssessed == isChewingSwallowingAssessed)&&(identical(other.isGlucoseA1cReviewed, isGlucoseA1cReviewed) || other.isGlucoseA1cReviewed == isGlucoseA1cReviewed)&&(identical(other.isLipidProfileReviewed, isLipidProfileReviewed) || other.isLipidProfileReviewed == isLipidProfileReviewed)&&(identical(other.isElectrolytesReviewed, isElectrolytesReviewed) || other.isElectrolytesReviewed == isElectrolytesReviewed)&&(identical(other.isRenalFunctionReviewed, isRenalFunctionReviewed) || other.isRenalFunctionReviewed == isRenalFunctionReviewed)&&(identical(other.isMicronutrientsReviewed, isMicronutrientsReviewed) || other.isMicronutrientsReviewed == isMicronutrientsReviewed)&&(identical(other.isInadequateIntakeDiagnosed, isInadequateIntakeDiagnosed) || other.isInadequateIntakeDiagnosed == isInadequateIntakeDiagnosed)&&(identical(other.isExcessiveIntakeDiagnosed, isExcessiveIntakeDiagnosed) || other.isExcessiveIntakeDiagnosed == isExcessiveIntakeDiagnosed)&&(identical(other.isFoodKnowledgeDeficitIdentified, isFoodKnowledgeDeficitIdentified) || other.isFoodKnowledgeDeficitIdentified == isFoodKnowledgeDeficitIdentified)&&(identical(other.isCaloriePrescriptionSet, isCaloriePrescriptionSet) || other.isCaloriePrescriptionSet == isCaloriePrescriptionSet)&&(identical(other.isMacronutrientDistributionPlanned, isMacronutrientDistributionPlanned) || other.isMacronutrientDistributionPlanned == isMacronutrientDistributionPlanned)&&(identical(other.isEducationProvided, isEducationProvided) || other.isEducationProvided == isEducationProvided)&&(identical(other.isFollowUpPlanEstablished, isFollowUpPlanEstablished) || other.isFollowUpPlanEstablished == isFollowUpPlanEstablished)&&(identical(other.dietary24HRecall, dietary24HRecall) || other.dietary24HRecall == dietary24HRecall)&&(identical(other.foodFrequencyChecked, foodFrequencyChecked) || other.foodFrequencyChecked == foodFrequencyChecked)&&(identical(other.allergiesDocumented, allergiesDocumented) || other.allergiesDocumented == allergiesDocumented)&&(identical(other.supplementsReviewed, supplementsReviewed) || other.supplementsReviewed == supplementsReviewed)&&(identical(other.medicalHistoryReviewed, medicalHistoryReviewed) || other.medicalHistoryReviewed == medicalHistoryReviewed)&&(identical(other.physicalExamCompleted, physicalExamCompleted) || other.physicalExamCompleted == physicalExamCompleted)&&(identical(other.appetiteAssessed, appetiteAssessed) || other.appetiteAssessed == appetiteAssessed)&&(identical(other.giSymptomsEvaluated, giSymptomsEvaluated) || other.giSymptomsEvaluated == giSymptomsEvaluated)&&(identical(other.bloodGlucoseReviewed, bloodGlucoseReviewed) || other.bloodGlucoseReviewed == bloodGlucoseReviewed)&&(identical(other.lipidProfileReviewed, lipidProfileReviewed) || other.lipidProfileReviewed == lipidProfileReviewed)&&(identical(other.micronutrientsReviewed, micronutrientsReviewed) || other.micronutrientsReviewed == micronutrientsReviewed)&&(identical(other.inadequateIntakeDiagnosed, inadequateIntakeDiagnosed) || other.inadequateIntakeDiagnosed == inadequateIntakeDiagnosed)&&(identical(other.excessiveIntakeDiagnosed, excessiveIntakeDiagnosed) || other.excessiveIntakeDiagnosed == excessiveIntakeDiagnosed)&&(identical(other.knowledgeDeficitIdentified, knowledgeDeficitIdentified) || other.knowledgeDeficitIdentified == knowledgeDeficitIdentified)&&(identical(other.disorderedEatingIdentified, disorderedEatingIdentified) || other.disorderedEatingIdentified == disorderedEatingIdentified)&&(identical(other.caloriePrescriptionSet, caloriePrescriptionSet) || other.caloriePrescriptionSet == caloriePrescriptionSet)&&(identical(other.macroDistributionSet, macroDistributionSet) || other.macroDistributionSet == macroDistributionSet)&&(identical(other.mealPlanProvided, mealPlanProvided) || other.mealPlanProvided == mealPlanProvided)&&(identical(other.educationProvided, educationProvided) || other.educationProvided == educationProvided)&&(identical(other.supplementsRecommended, supplementsRecommended) || other.supplementsRecommended == supplementsRecommended)&&(identical(other.targetWeightSet, targetWeightSet) || other.targetWeightSet == targetWeightSet)&&(identical(other.timelineDocumented, timelineDocumented) || other.timelineDocumented == timelineDocumented)&&(identical(other.followUpScheduled, followUpScheduled) || other.followUpScheduled == followUpScheduled)&&(identical(other.monitoringParametersSet, monitoringParametersSet) || other.monitoringParametersSet == monitoringParametersSet)&&(identical(other.writtenInstructionsProvided, writtenInstructionsProvided) || other.writtenInstructionsProvided == writtenInstructionsProvided)&&(identical(other.physicianNotified, physicianNotified) || other.physicianNotified == physicianNotified)&&(identical(other.consentObtained, consentObtained) || other.consentObtained == consentObtained)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&const DeepCollectionEquality().equals(other._auditLog, _auditLog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,patientId,nutritionistId,nutritionistName,appointmentId,visitDate,createdAt,updatedAt,editCount,lastEditedBy,lastEditedByName,isLocked,lockedUntil,isFirstVisit,heightValue,weightValue,waistCircumferenceValue,hipCircumferenceValue,weightMeasured,heightMeasured,bmiCalculated,waistCircumferenceMeasured,weightChangeDocumented,isIdentityVerified,isConsentObtained,isReasonForVisitDocumented,isDiagnosisReviewed,isWeightMeasured,isHeightMeasured,isBMICalculated,isWaistCircumferenceMeasured,isRecentWeightChangeDocumented,is24HourRecallCompleted,isFoodFrequencyAssessed,isAllergiesIntolerancesChecked,isSupplementsDocumented,isDiabetesAssessed,isHypertensionAssessed,isDyslipidemiaAssessed,isObesityAssessed,isCKDAssessed,isGIDisordersAssessed,isMuscleWastingAssessed,isFatLossAssessed,isEdemaAssessed,isAppetiteAssessed,isChewingSwallowingAssessed,isGlucoseA1cReviewed,isLipidProfileReviewed,isElectrolytesReviewed,isRenalFunctionReviewed,isMicronutrientsReviewed,isInadequateIntakeDiagnosed,isExcessiveIntakeDiagnosed,isFoodKnowledgeDeficitIdentified,isCaloriePrescriptionSet,isMacronutrientDistributionPlanned,isEducationProvided,isFollowUpPlanEstablished,dietary24HRecall,foodFrequencyChecked,allergiesDocumented,supplementsReviewed,medicalHistoryReviewed,physicalExamCompleted,appetiteAssessed,giSymptomsEvaluated,bloodGlucoseReviewed,lipidProfileReviewed,micronutrientsReviewed,inadequateIntakeDiagnosed,excessiveIntakeDiagnosed,knowledgeDeficitIdentified,disorderedEatingIdentified,caloriePrescriptionSet,macroDistributionSet,mealPlanProvided,educationProvided,supplementsRecommended,targetWeightSet,timelineDocumented,followUpScheduled,monitoringParametersSet,writtenInstructionsProvided,physicianNotified,consentObtained,specialization,const DeepCollectionEquality().hash(_auditLog)]);

@override
String toString() {
  return 'NutritionEMREntity(id: $id, patientId: $patientId, nutritionistId: $nutritionistId, nutritionistName: $nutritionistName, appointmentId: $appointmentId, visitDate: $visitDate, createdAt: $createdAt, updatedAt: $updatedAt, editCount: $editCount, lastEditedBy: $lastEditedBy, lastEditedByName: $lastEditedByName, isLocked: $isLocked, lockedUntil: $lockedUntil, isFirstVisit: $isFirstVisit, heightValue: $heightValue, weightValue: $weightValue, waistCircumferenceValue: $waistCircumferenceValue, hipCircumferenceValue: $hipCircumferenceValue, weightMeasured: $weightMeasured, heightMeasured: $heightMeasured, bmiCalculated: $bmiCalculated, waistCircumferenceMeasured: $waistCircumferenceMeasured, weightChangeDocumented: $weightChangeDocumented, isIdentityVerified: $isIdentityVerified, isConsentObtained: $isConsentObtained, isReasonForVisitDocumented: $isReasonForVisitDocumented, isDiagnosisReviewed: $isDiagnosisReviewed, isWeightMeasured: $isWeightMeasured, isHeightMeasured: $isHeightMeasured, isBMICalculated: $isBMICalculated, isWaistCircumferenceMeasured: $isWaistCircumferenceMeasured, isRecentWeightChangeDocumented: $isRecentWeightChangeDocumented, is24HourRecallCompleted: $is24HourRecallCompleted, isFoodFrequencyAssessed: $isFoodFrequencyAssessed, isAllergiesIntolerancesChecked: $isAllergiesIntolerancesChecked, isSupplementsDocumented: $isSupplementsDocumented, isDiabetesAssessed: $isDiabetesAssessed, isHypertensionAssessed: $isHypertensionAssessed, isDyslipidemiaAssessed: $isDyslipidemiaAssessed, isObesityAssessed: $isObesityAssessed, isCKDAssessed: $isCKDAssessed, isGIDisordersAssessed: $isGIDisordersAssessed, isMuscleWastingAssessed: $isMuscleWastingAssessed, isFatLossAssessed: $isFatLossAssessed, isEdemaAssessed: $isEdemaAssessed, isAppetiteAssessed: $isAppetiteAssessed, isChewingSwallowingAssessed: $isChewingSwallowingAssessed, isGlucoseA1cReviewed: $isGlucoseA1cReviewed, isLipidProfileReviewed: $isLipidProfileReviewed, isElectrolytesReviewed: $isElectrolytesReviewed, isRenalFunctionReviewed: $isRenalFunctionReviewed, isMicronutrientsReviewed: $isMicronutrientsReviewed, isInadequateIntakeDiagnosed: $isInadequateIntakeDiagnosed, isExcessiveIntakeDiagnosed: $isExcessiveIntakeDiagnosed, isFoodKnowledgeDeficitIdentified: $isFoodKnowledgeDeficitIdentified, isCaloriePrescriptionSet: $isCaloriePrescriptionSet, isMacronutrientDistributionPlanned: $isMacronutrientDistributionPlanned, isEducationProvided: $isEducationProvided, isFollowUpPlanEstablished: $isFollowUpPlanEstablished, dietary24HRecall: $dietary24HRecall, foodFrequencyChecked: $foodFrequencyChecked, allergiesDocumented: $allergiesDocumented, supplementsReviewed: $supplementsReviewed, medicalHistoryReviewed: $medicalHistoryReviewed, physicalExamCompleted: $physicalExamCompleted, appetiteAssessed: $appetiteAssessed, giSymptomsEvaluated: $giSymptomsEvaluated, bloodGlucoseReviewed: $bloodGlucoseReviewed, lipidProfileReviewed: $lipidProfileReviewed, micronutrientsReviewed: $micronutrientsReviewed, inadequateIntakeDiagnosed: $inadequateIntakeDiagnosed, excessiveIntakeDiagnosed: $excessiveIntakeDiagnosed, knowledgeDeficitIdentified: $knowledgeDeficitIdentified, disorderedEatingIdentified: $disorderedEatingIdentified, caloriePrescriptionSet: $caloriePrescriptionSet, macroDistributionSet: $macroDistributionSet, mealPlanProvided: $mealPlanProvided, educationProvided: $educationProvided, supplementsRecommended: $supplementsRecommended, targetWeightSet: $targetWeightSet, timelineDocumented: $timelineDocumented, followUpScheduled: $followUpScheduled, monitoringParametersSet: $monitoringParametersSet, writtenInstructionsProvided: $writtenInstructionsProvided, physicianNotified: $physicianNotified, consentObtained: $consentObtained, specialization: $specialization, auditLog: $auditLog)';
}


}

/// @nodoc
abstract mixin class _$NutritionEMREntityCopyWith<$Res> implements $NutritionEMREntityCopyWith<$Res> {
  factory _$NutritionEMREntityCopyWith(_NutritionEMREntity value, $Res Function(_NutritionEMREntity) _then) = __$NutritionEMREntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String nutritionistId, String nutritionistName, String appointmentId, DateTime visitDate, DateTime createdAt, DateTime updatedAt, int editCount, String? lastEditedBy, String? lastEditedByName, bool isLocked, DateTime? lockedUntil, bool isFirstVisit, double? heightValue, double? weightValue, double? waistCircumferenceValue, double? hipCircumferenceValue, bool weightMeasured, bool heightMeasured, bool bmiCalculated, bool waistCircumferenceMeasured, bool weightChangeDocumented, bool isIdentityVerified, bool isConsentObtained, bool isReasonForVisitDocumented, bool isDiagnosisReviewed, bool isWeightMeasured, bool isHeightMeasured, bool isBMICalculated, bool isWaistCircumferenceMeasured, bool isRecentWeightChangeDocumented, bool is24HourRecallCompleted, bool isFoodFrequencyAssessed, bool isAllergiesIntolerancesChecked, bool isSupplementsDocumented, bool isDiabetesAssessed, bool isHypertensionAssessed, bool isDyslipidemiaAssessed, bool isObesityAssessed, bool isCKDAssessed, bool isGIDisordersAssessed, bool isMuscleWastingAssessed, bool isFatLossAssessed, bool isEdemaAssessed, bool isAppetiteAssessed, bool isChewingSwallowingAssessed, bool isGlucoseA1cReviewed, bool isLipidProfileReviewed, bool isElectrolytesReviewed, bool isRenalFunctionReviewed, bool isMicronutrientsReviewed, bool isInadequateIntakeDiagnosed, bool isExcessiveIntakeDiagnosed, bool isFoodKnowledgeDeficitIdentified, bool isCaloriePrescriptionSet, bool isMacronutrientDistributionPlanned, bool isEducationProvided, bool isFollowUpPlanEstablished, bool dietary24HRecall, bool foodFrequencyChecked, bool allergiesDocumented, bool supplementsReviewed, bool medicalHistoryReviewed, bool physicalExamCompleted, bool appetiteAssessed, bool giSymptomsEvaluated, bool bloodGlucoseReviewed, bool lipidProfileReviewed, bool micronutrientsReviewed, bool inadequateIntakeDiagnosed, bool excessiveIntakeDiagnosed, bool knowledgeDeficitIdentified, bool disorderedEatingIdentified, bool caloriePrescriptionSet, bool macroDistributionSet, bool mealPlanProvided, bool educationProvided, bool supplementsRecommended, bool targetWeightSet, bool timelineDocumented, bool followUpScheduled, bool monitoringParametersSet, bool writtenInstructionsProvided, bool physicianNotified, bool consentObtained, String specialization, List<AuditLogEntry> auditLog
});




}
/// @nodoc
class __$NutritionEMREntityCopyWithImpl<$Res>
    implements _$NutritionEMREntityCopyWith<$Res> {
  __$NutritionEMREntityCopyWithImpl(this._self, this._then);

  final _NutritionEMREntity _self;
  final $Res Function(_NutritionEMREntity) _then;

/// Create a copy of NutritionEMREntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? nutritionistId = null,Object? nutritionistName = null,Object? appointmentId = null,Object? visitDate = null,Object? createdAt = null,Object? updatedAt = null,Object? editCount = null,Object? lastEditedBy = freezed,Object? lastEditedByName = freezed,Object? isLocked = null,Object? lockedUntil = freezed,Object? isFirstVisit = null,Object? heightValue = freezed,Object? weightValue = freezed,Object? waistCircumferenceValue = freezed,Object? hipCircumferenceValue = freezed,Object? weightMeasured = null,Object? heightMeasured = null,Object? bmiCalculated = null,Object? waistCircumferenceMeasured = null,Object? weightChangeDocumented = null,Object? isIdentityVerified = null,Object? isConsentObtained = null,Object? isReasonForVisitDocumented = null,Object? isDiagnosisReviewed = null,Object? isWeightMeasured = null,Object? isHeightMeasured = null,Object? isBMICalculated = null,Object? isWaistCircumferenceMeasured = null,Object? isRecentWeightChangeDocumented = null,Object? is24HourRecallCompleted = null,Object? isFoodFrequencyAssessed = null,Object? isAllergiesIntolerancesChecked = null,Object? isSupplementsDocumented = null,Object? isDiabetesAssessed = null,Object? isHypertensionAssessed = null,Object? isDyslipidemiaAssessed = null,Object? isObesityAssessed = null,Object? isCKDAssessed = null,Object? isGIDisordersAssessed = null,Object? isMuscleWastingAssessed = null,Object? isFatLossAssessed = null,Object? isEdemaAssessed = null,Object? isAppetiteAssessed = null,Object? isChewingSwallowingAssessed = null,Object? isGlucoseA1cReviewed = null,Object? isLipidProfileReviewed = null,Object? isElectrolytesReviewed = null,Object? isRenalFunctionReviewed = null,Object? isMicronutrientsReviewed = null,Object? isInadequateIntakeDiagnosed = null,Object? isExcessiveIntakeDiagnosed = null,Object? isFoodKnowledgeDeficitIdentified = null,Object? isCaloriePrescriptionSet = null,Object? isMacronutrientDistributionPlanned = null,Object? isEducationProvided = null,Object? isFollowUpPlanEstablished = null,Object? dietary24HRecall = null,Object? foodFrequencyChecked = null,Object? allergiesDocumented = null,Object? supplementsReviewed = null,Object? medicalHistoryReviewed = null,Object? physicalExamCompleted = null,Object? appetiteAssessed = null,Object? giSymptomsEvaluated = null,Object? bloodGlucoseReviewed = null,Object? lipidProfileReviewed = null,Object? micronutrientsReviewed = null,Object? inadequateIntakeDiagnosed = null,Object? excessiveIntakeDiagnosed = null,Object? knowledgeDeficitIdentified = null,Object? disorderedEatingIdentified = null,Object? caloriePrescriptionSet = null,Object? macroDistributionSet = null,Object? mealPlanProvided = null,Object? educationProvided = null,Object? supplementsRecommended = null,Object? targetWeightSet = null,Object? timelineDocumented = null,Object? followUpScheduled = null,Object? monitoringParametersSet = null,Object? writtenInstructionsProvided = null,Object? physicianNotified = null,Object? consentObtained = null,Object? specialization = null,Object? auditLog = null,}) {
  return _then(_NutritionEMREntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,nutritionistId: null == nutritionistId ? _self.nutritionistId : nutritionistId // ignore: cast_nullable_to_non_nullable
as String,nutritionistName: null == nutritionistName ? _self.nutritionistName : nutritionistName // ignore: cast_nullable_to_non_nullable
as String,appointmentId: null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,visitDate: null == visitDate ? _self.visitDate : visitDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,lastEditedBy: freezed == lastEditedBy ? _self.lastEditedBy : lastEditedBy // ignore: cast_nullable_to_non_nullable
as String?,lastEditedByName: freezed == lastEditedByName ? _self.lastEditedByName : lastEditedByName // ignore: cast_nullable_to_non_nullable
as String?,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,isFirstVisit: null == isFirstVisit ? _self.isFirstVisit : isFirstVisit // ignore: cast_nullable_to_non_nullable
as bool,heightValue: freezed == heightValue ? _self.heightValue : heightValue // ignore: cast_nullable_to_non_nullable
as double?,weightValue: freezed == weightValue ? _self.weightValue : weightValue // ignore: cast_nullable_to_non_nullable
as double?,waistCircumferenceValue: freezed == waistCircumferenceValue ? _self.waistCircumferenceValue : waistCircumferenceValue // ignore: cast_nullable_to_non_nullable
as double?,hipCircumferenceValue: freezed == hipCircumferenceValue ? _self.hipCircumferenceValue : hipCircumferenceValue // ignore: cast_nullable_to_non_nullable
as double?,weightMeasured: null == weightMeasured ? _self.weightMeasured : weightMeasured // ignore: cast_nullable_to_non_nullable
as bool,heightMeasured: null == heightMeasured ? _self.heightMeasured : heightMeasured // ignore: cast_nullable_to_non_nullable
as bool,bmiCalculated: null == bmiCalculated ? _self.bmiCalculated : bmiCalculated // ignore: cast_nullable_to_non_nullable
as bool,waistCircumferenceMeasured: null == waistCircumferenceMeasured ? _self.waistCircumferenceMeasured : waistCircumferenceMeasured // ignore: cast_nullable_to_non_nullable
as bool,weightChangeDocumented: null == weightChangeDocumented ? _self.weightChangeDocumented : weightChangeDocumented // ignore: cast_nullable_to_non_nullable
as bool,isIdentityVerified: null == isIdentityVerified ? _self.isIdentityVerified : isIdentityVerified // ignore: cast_nullable_to_non_nullable
as bool,isConsentObtained: null == isConsentObtained ? _self.isConsentObtained : isConsentObtained // ignore: cast_nullable_to_non_nullable
as bool,isReasonForVisitDocumented: null == isReasonForVisitDocumented ? _self.isReasonForVisitDocumented : isReasonForVisitDocumented // ignore: cast_nullable_to_non_nullable
as bool,isDiagnosisReviewed: null == isDiagnosisReviewed ? _self.isDiagnosisReviewed : isDiagnosisReviewed // ignore: cast_nullable_to_non_nullable
as bool,isWeightMeasured: null == isWeightMeasured ? _self.isWeightMeasured : isWeightMeasured // ignore: cast_nullable_to_non_nullable
as bool,isHeightMeasured: null == isHeightMeasured ? _self.isHeightMeasured : isHeightMeasured // ignore: cast_nullable_to_non_nullable
as bool,isBMICalculated: null == isBMICalculated ? _self.isBMICalculated : isBMICalculated // ignore: cast_nullable_to_non_nullable
as bool,isWaistCircumferenceMeasured: null == isWaistCircumferenceMeasured ? _self.isWaistCircumferenceMeasured : isWaistCircumferenceMeasured // ignore: cast_nullable_to_non_nullable
as bool,isRecentWeightChangeDocumented: null == isRecentWeightChangeDocumented ? _self.isRecentWeightChangeDocumented : isRecentWeightChangeDocumented // ignore: cast_nullable_to_non_nullable
as bool,is24HourRecallCompleted: null == is24HourRecallCompleted ? _self.is24HourRecallCompleted : is24HourRecallCompleted // ignore: cast_nullable_to_non_nullable
as bool,isFoodFrequencyAssessed: null == isFoodFrequencyAssessed ? _self.isFoodFrequencyAssessed : isFoodFrequencyAssessed // ignore: cast_nullable_to_non_nullable
as bool,isAllergiesIntolerancesChecked: null == isAllergiesIntolerancesChecked ? _self.isAllergiesIntolerancesChecked : isAllergiesIntolerancesChecked // ignore: cast_nullable_to_non_nullable
as bool,isSupplementsDocumented: null == isSupplementsDocumented ? _self.isSupplementsDocumented : isSupplementsDocumented // ignore: cast_nullable_to_non_nullable
as bool,isDiabetesAssessed: null == isDiabetesAssessed ? _self.isDiabetesAssessed : isDiabetesAssessed // ignore: cast_nullable_to_non_nullable
as bool,isHypertensionAssessed: null == isHypertensionAssessed ? _self.isHypertensionAssessed : isHypertensionAssessed // ignore: cast_nullable_to_non_nullable
as bool,isDyslipidemiaAssessed: null == isDyslipidemiaAssessed ? _self.isDyslipidemiaAssessed : isDyslipidemiaAssessed // ignore: cast_nullable_to_non_nullable
as bool,isObesityAssessed: null == isObesityAssessed ? _self.isObesityAssessed : isObesityAssessed // ignore: cast_nullable_to_non_nullable
as bool,isCKDAssessed: null == isCKDAssessed ? _self.isCKDAssessed : isCKDAssessed // ignore: cast_nullable_to_non_nullable
as bool,isGIDisordersAssessed: null == isGIDisordersAssessed ? _self.isGIDisordersAssessed : isGIDisordersAssessed // ignore: cast_nullable_to_non_nullable
as bool,isMuscleWastingAssessed: null == isMuscleWastingAssessed ? _self.isMuscleWastingAssessed : isMuscleWastingAssessed // ignore: cast_nullable_to_non_nullable
as bool,isFatLossAssessed: null == isFatLossAssessed ? _self.isFatLossAssessed : isFatLossAssessed // ignore: cast_nullable_to_non_nullable
as bool,isEdemaAssessed: null == isEdemaAssessed ? _self.isEdemaAssessed : isEdemaAssessed // ignore: cast_nullable_to_non_nullable
as bool,isAppetiteAssessed: null == isAppetiteAssessed ? _self.isAppetiteAssessed : isAppetiteAssessed // ignore: cast_nullable_to_non_nullable
as bool,isChewingSwallowingAssessed: null == isChewingSwallowingAssessed ? _self.isChewingSwallowingAssessed : isChewingSwallowingAssessed // ignore: cast_nullable_to_non_nullable
as bool,isGlucoseA1cReviewed: null == isGlucoseA1cReviewed ? _self.isGlucoseA1cReviewed : isGlucoseA1cReviewed // ignore: cast_nullable_to_non_nullable
as bool,isLipidProfileReviewed: null == isLipidProfileReviewed ? _self.isLipidProfileReviewed : isLipidProfileReviewed // ignore: cast_nullable_to_non_nullable
as bool,isElectrolytesReviewed: null == isElectrolytesReviewed ? _self.isElectrolytesReviewed : isElectrolytesReviewed // ignore: cast_nullable_to_non_nullable
as bool,isRenalFunctionReviewed: null == isRenalFunctionReviewed ? _self.isRenalFunctionReviewed : isRenalFunctionReviewed // ignore: cast_nullable_to_non_nullable
as bool,isMicronutrientsReviewed: null == isMicronutrientsReviewed ? _self.isMicronutrientsReviewed : isMicronutrientsReviewed // ignore: cast_nullable_to_non_nullable
as bool,isInadequateIntakeDiagnosed: null == isInadequateIntakeDiagnosed ? _self.isInadequateIntakeDiagnosed : isInadequateIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,isExcessiveIntakeDiagnosed: null == isExcessiveIntakeDiagnosed ? _self.isExcessiveIntakeDiagnosed : isExcessiveIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,isFoodKnowledgeDeficitIdentified: null == isFoodKnowledgeDeficitIdentified ? _self.isFoodKnowledgeDeficitIdentified : isFoodKnowledgeDeficitIdentified // ignore: cast_nullable_to_non_nullable
as bool,isCaloriePrescriptionSet: null == isCaloriePrescriptionSet ? _self.isCaloriePrescriptionSet : isCaloriePrescriptionSet // ignore: cast_nullable_to_non_nullable
as bool,isMacronutrientDistributionPlanned: null == isMacronutrientDistributionPlanned ? _self.isMacronutrientDistributionPlanned : isMacronutrientDistributionPlanned // ignore: cast_nullable_to_non_nullable
as bool,isEducationProvided: null == isEducationProvided ? _self.isEducationProvided : isEducationProvided // ignore: cast_nullable_to_non_nullable
as bool,isFollowUpPlanEstablished: null == isFollowUpPlanEstablished ? _self.isFollowUpPlanEstablished : isFollowUpPlanEstablished // ignore: cast_nullable_to_non_nullable
as bool,dietary24HRecall: null == dietary24HRecall ? _self.dietary24HRecall : dietary24HRecall // ignore: cast_nullable_to_non_nullable
as bool,foodFrequencyChecked: null == foodFrequencyChecked ? _self.foodFrequencyChecked : foodFrequencyChecked // ignore: cast_nullable_to_non_nullable
as bool,allergiesDocumented: null == allergiesDocumented ? _self.allergiesDocumented : allergiesDocumented // ignore: cast_nullable_to_non_nullable
as bool,supplementsReviewed: null == supplementsReviewed ? _self.supplementsReviewed : supplementsReviewed // ignore: cast_nullable_to_non_nullable
as bool,medicalHistoryReviewed: null == medicalHistoryReviewed ? _self.medicalHistoryReviewed : medicalHistoryReviewed // ignore: cast_nullable_to_non_nullable
as bool,physicalExamCompleted: null == physicalExamCompleted ? _self.physicalExamCompleted : physicalExamCompleted // ignore: cast_nullable_to_non_nullable
as bool,appetiteAssessed: null == appetiteAssessed ? _self.appetiteAssessed : appetiteAssessed // ignore: cast_nullable_to_non_nullable
as bool,giSymptomsEvaluated: null == giSymptomsEvaluated ? _self.giSymptomsEvaluated : giSymptomsEvaluated // ignore: cast_nullable_to_non_nullable
as bool,bloodGlucoseReviewed: null == bloodGlucoseReviewed ? _self.bloodGlucoseReviewed : bloodGlucoseReviewed // ignore: cast_nullable_to_non_nullable
as bool,lipidProfileReviewed: null == lipidProfileReviewed ? _self.lipidProfileReviewed : lipidProfileReviewed // ignore: cast_nullable_to_non_nullable
as bool,micronutrientsReviewed: null == micronutrientsReviewed ? _self.micronutrientsReviewed : micronutrientsReviewed // ignore: cast_nullable_to_non_nullable
as bool,inadequateIntakeDiagnosed: null == inadequateIntakeDiagnosed ? _self.inadequateIntakeDiagnosed : inadequateIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,excessiveIntakeDiagnosed: null == excessiveIntakeDiagnosed ? _self.excessiveIntakeDiagnosed : excessiveIntakeDiagnosed // ignore: cast_nullable_to_non_nullable
as bool,knowledgeDeficitIdentified: null == knowledgeDeficitIdentified ? _self.knowledgeDeficitIdentified : knowledgeDeficitIdentified // ignore: cast_nullable_to_non_nullable
as bool,disorderedEatingIdentified: null == disorderedEatingIdentified ? _self.disorderedEatingIdentified : disorderedEatingIdentified // ignore: cast_nullable_to_non_nullable
as bool,caloriePrescriptionSet: null == caloriePrescriptionSet ? _self.caloriePrescriptionSet : caloriePrescriptionSet // ignore: cast_nullable_to_non_nullable
as bool,macroDistributionSet: null == macroDistributionSet ? _self.macroDistributionSet : macroDistributionSet // ignore: cast_nullable_to_non_nullable
as bool,mealPlanProvided: null == mealPlanProvided ? _self.mealPlanProvided : mealPlanProvided // ignore: cast_nullable_to_non_nullable
as bool,educationProvided: null == educationProvided ? _self.educationProvided : educationProvided // ignore: cast_nullable_to_non_nullable
as bool,supplementsRecommended: null == supplementsRecommended ? _self.supplementsRecommended : supplementsRecommended // ignore: cast_nullable_to_non_nullable
as bool,targetWeightSet: null == targetWeightSet ? _self.targetWeightSet : targetWeightSet // ignore: cast_nullable_to_non_nullable
as bool,timelineDocumented: null == timelineDocumented ? _self.timelineDocumented : timelineDocumented // ignore: cast_nullable_to_non_nullable
as bool,followUpScheduled: null == followUpScheduled ? _self.followUpScheduled : followUpScheduled // ignore: cast_nullable_to_non_nullable
as bool,monitoringParametersSet: null == monitoringParametersSet ? _self.monitoringParametersSet : monitoringParametersSet // ignore: cast_nullable_to_non_nullable
as bool,writtenInstructionsProvided: null == writtenInstructionsProvided ? _self.writtenInstructionsProvided : writtenInstructionsProvided // ignore: cast_nullable_to_non_nullable
as bool,physicianNotified: null == physicianNotified ? _self.physicianNotified : physicianNotified // ignore: cast_nullable_to_non_nullable
as bool,consentObtained: null == consentObtained ? _self.consentObtained : consentObtained // ignore: cast_nullable_to_non_nullable
as bool,specialization: null == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String,auditLog: null == auditLog ? _self._auditLog : auditLog // ignore: cast_nullable_to_non_nullable
as List<AuditLogEntry>,
  ));
}


}


/// @nodoc
mixin _$AuditLogEntry {

/// When the change occurred
 DateTime get timestamp;/// User ID who made the change (nutritionist/doctor)
 String get userId;/// User name for display in audit trail
 String get userName;/// Action type: 'created', 'updated', 'locked', 'viewed'
 String get action;/// Field name that was changed (e.g., 'weightMeasured')
 String get fieldChanged;/// Previous value (for checkboxes: 'true' or 'false')
 String get previousValue;/// New value (for checkboxes: 'true' or 'false')
 String get newValue;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.action, action) || other.action == action)&&(identical(other.fieldChanged, fieldChanged) || other.fieldChanged == fieldChanged)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,userId,userName,action,fieldChanged,previousValue,newValue);

@override
String toString() {
  return 'AuditLogEntry(timestamp: $timestamp, userId: $userId, userName: $userName, action: $action, fieldChanged: $fieldChanged, previousValue: $previousValue, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp, String userId, String userName, String action, String fieldChanged, String previousValue, String newValue
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? userId = null,Object? userName = null,Object? action = null,Object? fieldChanged = null,Object? previousValue = null,Object? newValue = null,}) {
  return _then(_self.copyWith(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,fieldChanged: null == fieldChanged ? _self.fieldChanged : fieldChanged // ignore: cast_nullable_to_non_nullable
as String,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timestamp,  String userId,  String userName,  String action,  String fieldChanged,  String previousValue,  String newValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.timestamp,_that.userId,_that.userName,_that.action,_that.fieldChanged,_that.previousValue,_that.newValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timestamp,  String userId,  String userName,  String action,  String fieldChanged,  String previousValue,  String newValue)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.timestamp,_that.userId,_that.userName,_that.action,_that.fieldChanged,_that.previousValue,_that.newValue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timestamp,  String userId,  String userName,  String action,  String fieldChanged,  String previousValue,  String newValue)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.timestamp,_that.userId,_that.userName,_that.action,_that.fieldChanged,_that.previousValue,_that.newValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.timestamp, required this.userId, required this.userName, required this.action, required this.fieldChanged, required this.previousValue, required this.newValue});
  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) => _$AuditLogEntryFromJson(json);

/// When the change occurred
@override final  DateTime timestamp;
/// User ID who made the change (nutritionist/doctor)
@override final  String userId;
/// User name for display in audit trail
@override final  String userName;
/// Action type: 'created', 'updated', 'locked', 'viewed'
@override final  String action;
/// Field name that was changed (e.g., 'weightMeasured')
@override final  String fieldChanged;
/// Previous value (for checkboxes: 'true' or 'false')
@override final  String previousValue;
/// New value (for checkboxes: 'true' or 'false')
@override final  String newValue;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.action, action) || other.action == action)&&(identical(other.fieldChanged, fieldChanged) || other.fieldChanged == fieldChanged)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,userId,userName,action,fieldChanged,previousValue,newValue);

@override
String toString() {
  return 'AuditLogEntry(timestamp: $timestamp, userId: $userId, userName: $userName, action: $action, fieldChanged: $fieldChanged, previousValue: $previousValue, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 DateTime timestamp, String userId, String userName, String action, String fieldChanged, String previousValue, String newValue
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? userId = null,Object? userName = null,Object? action = null,Object? fieldChanged = null,Object? previousValue = null,Object? newValue = null,}) {
  return _then(_AuditLogEntry(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,fieldChanged: null == fieldChanged ? _self.fieldChanged : fieldChanged // ignore: cast_nullable_to_non_nullable
as String,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
