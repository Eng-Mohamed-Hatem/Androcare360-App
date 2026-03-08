// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_emr_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NutritionEMREntity _$NutritionEMREntityFromJson(
  Map<String, dynamic> json,
) => _NutritionEMREntity(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  nutritionistId: json['nutritionistId'] as String,
  nutritionistName: json['nutritionistName'] as String,
  appointmentId: json['appointmentId'] as String,
  visitDate: DateTime.parse(json['visitDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  editCount: (json['editCount'] as num?)?.toInt() ?? 0,
  lastEditedBy: json['lastEditedBy'] as String?,
  lastEditedByName: json['lastEditedByName'] as String?,
  isLocked: json['isLocked'] as bool? ?? false,
  lockedUntil: json['lockedUntil'] == null
      ? null
      : DateTime.parse(json['lockedUntil'] as String),
  isFirstVisit: json['isFirstVisit'] as bool? ?? true,
  heightValue: (json['heightValue'] as num?)?.toDouble(),
  weightValue: (json['weightValue'] as num?)?.toDouble(),
  waistCircumferenceValue: (json['waistCircumferenceValue'] as num?)
      ?.toDouble(),
  hipCircumferenceValue: (json['hipCircumferenceValue'] as num?)?.toDouble(),
  weightMeasured: json['weightMeasured'] as bool? ?? false,
  heightMeasured: json['heightMeasured'] as bool? ?? false,
  bmiCalculated: json['bmiCalculated'] as bool? ?? false,
  waistCircumferenceMeasured:
      json['waistCircumferenceMeasured'] as bool? ?? false,
  weightChangeDocumented: json['weightChangeDocumented'] as bool? ?? false,
  isIdentityVerified: json['isIdentityVerified'] as bool? ?? false,
  isConsentObtained: json['isConsentObtained'] as bool? ?? false,
  isReasonForVisitDocumented:
      json['isReasonForVisitDocumented'] as bool? ?? false,
  isDiagnosisReviewed: json['isDiagnosisReviewed'] as bool? ?? false,
  isWeightMeasured: json['isWeightMeasured'] as bool? ?? false,
  isHeightMeasured: json['isHeightMeasured'] as bool? ?? false,
  isBMICalculated: json['isBMICalculated'] as bool? ?? false,
  isWaistCircumferenceMeasured:
      json['isWaistCircumferenceMeasured'] as bool? ?? false,
  isRecentWeightChangeDocumented:
      json['isRecentWeightChangeDocumented'] as bool? ?? false,
  is24HourRecallCompleted: json['is24HourRecallCompleted'] as bool? ?? false,
  isFoodFrequencyAssessed: json['isFoodFrequencyAssessed'] as bool? ?? false,
  isAllergiesIntolerancesChecked:
      json['isAllergiesIntolerancesChecked'] as bool? ?? false,
  isSupplementsDocumented: json['isSupplementsDocumented'] as bool? ?? false,
  isDiabetesAssessed: json['isDiabetesAssessed'] as bool? ?? false,
  isHypertensionAssessed: json['isHypertensionAssessed'] as bool? ?? false,
  isDyslipidemiaAssessed: json['isDyslipidemiaAssessed'] as bool? ?? false,
  isObesityAssessed: json['isObesityAssessed'] as bool? ?? false,
  isCKDAssessed: json['isCKDAssessed'] as bool? ?? false,
  isGIDisordersAssessed: json['isGIDisordersAssessed'] as bool? ?? false,
  isMuscleWastingAssessed: json['isMuscleWastingAssessed'] as bool? ?? false,
  isFatLossAssessed: json['isFatLossAssessed'] as bool? ?? false,
  isEdemaAssessed: json['isEdemaAssessed'] as bool? ?? false,
  isAppetiteAssessed: json['isAppetiteAssessed'] as bool? ?? false,
  isChewingSwallowingAssessed:
      json['isChewingSwallowingAssessed'] as bool? ?? false,
  isGlucoseA1cReviewed: json['isGlucoseA1cReviewed'] as bool? ?? false,
  isLipidProfileReviewed: json['isLipidProfileReviewed'] as bool? ?? false,
  isElectrolytesReviewed: json['isElectrolytesReviewed'] as bool? ?? false,
  isRenalFunctionReviewed: json['isRenalFunctionReviewed'] as bool? ?? false,
  isMicronutrientsReviewed: json['isMicronutrientsReviewed'] as bool? ?? false,
  isInadequateIntakeDiagnosed:
      json['isInadequateIntakeDiagnosed'] as bool? ?? false,
  isExcessiveIntakeDiagnosed:
      json['isExcessiveIntakeDiagnosed'] as bool? ?? false,
  isFoodKnowledgeDeficitIdentified:
      json['isFoodKnowledgeDeficitIdentified'] as bool? ?? false,
  isCaloriePrescriptionSet: json['isCaloriePrescriptionSet'] as bool? ?? false,
  isMacronutrientDistributionPlanned:
      json['isMacronutrientDistributionPlanned'] as bool? ?? false,
  isEducationProvided: json['isEducationProvided'] as bool? ?? false,
  isFollowUpPlanEstablished:
      json['isFollowUpPlanEstablished'] as bool? ?? false,
  dietary24HRecall: json['dietary24HRecall'] as bool? ?? false,
  foodFrequencyChecked: json['foodFrequencyChecked'] as bool? ?? false,
  allergiesDocumented: json['allergiesDocumented'] as bool? ?? false,
  supplementsReviewed: json['supplementsReviewed'] as bool? ?? false,
  medicalHistoryReviewed: json['medicalHistoryReviewed'] as bool? ?? false,
  physicalExamCompleted: json['physicalExamCompleted'] as bool? ?? false,
  appetiteAssessed: json['appetiteAssessed'] as bool? ?? false,
  giSymptomsEvaluated: json['giSymptomsEvaluated'] as bool? ?? false,
  bloodGlucoseReviewed: json['bloodGlucoseReviewed'] as bool? ?? false,
  lipidProfileReviewed: json['lipidProfileReviewed'] as bool? ?? false,
  micronutrientsReviewed: json['micronutrientsReviewed'] as bool? ?? false,
  inadequateIntakeDiagnosed:
      json['inadequateIntakeDiagnosed'] as bool? ?? false,
  excessiveIntakeDiagnosed: json['excessiveIntakeDiagnosed'] as bool? ?? false,
  knowledgeDeficitIdentified:
      json['knowledgeDeficitIdentified'] as bool? ?? false,
  disorderedEatingIdentified:
      json['disorderedEatingIdentified'] as bool? ?? false,
  caloriePrescriptionSet: json['caloriePrescriptionSet'] as bool? ?? false,
  macroDistributionSet: json['macroDistributionSet'] as bool? ?? false,
  mealPlanProvided: json['mealPlanProvided'] as bool? ?? false,
  educationProvided: json['educationProvided'] as bool? ?? false,
  supplementsRecommended: json['supplementsRecommended'] as bool? ?? false,
  targetWeightSet: json['targetWeightSet'] as bool? ?? false,
  timelineDocumented: json['timelineDocumented'] as bool? ?? false,
  followUpScheduled: json['followUpScheduled'] as bool? ?? false,
  monitoringParametersSet: json['monitoringParametersSet'] as bool? ?? false,
  writtenInstructionsProvided:
      json['writtenInstructionsProvided'] as bool? ?? false,
  physicianNotified: json['physicianNotified'] as bool? ?? false,
  consentObtained: json['consentObtained'] as bool? ?? false,
  specialization:
      json['specialization'] as String? ?? 'عيادة السمنة والتغذية العلاجية',
  auditLog:
      (json['auditLog'] as List<dynamic>?)
          ?.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NutritionEMREntityToJson(
  _NutritionEMREntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'nutritionistId': instance.nutritionistId,
  'nutritionistName': instance.nutritionistName,
  'appointmentId': instance.appointmentId,
  'visitDate': instance.visitDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'editCount': instance.editCount,
  'lastEditedBy': instance.lastEditedBy,
  'lastEditedByName': instance.lastEditedByName,
  'isLocked': instance.isLocked,
  'lockedUntil': instance.lockedUntil?.toIso8601String(),
  'isFirstVisit': instance.isFirstVisit,
  'heightValue': instance.heightValue,
  'weightValue': instance.weightValue,
  'waistCircumferenceValue': instance.waistCircumferenceValue,
  'hipCircumferenceValue': instance.hipCircumferenceValue,
  'weightMeasured': instance.weightMeasured,
  'heightMeasured': instance.heightMeasured,
  'bmiCalculated': instance.bmiCalculated,
  'waistCircumferenceMeasured': instance.waistCircumferenceMeasured,
  'weightChangeDocumented': instance.weightChangeDocumented,
  'isIdentityVerified': instance.isIdentityVerified,
  'isConsentObtained': instance.isConsentObtained,
  'isReasonForVisitDocumented': instance.isReasonForVisitDocumented,
  'isDiagnosisReviewed': instance.isDiagnosisReviewed,
  'isWeightMeasured': instance.isWeightMeasured,
  'isHeightMeasured': instance.isHeightMeasured,
  'isBMICalculated': instance.isBMICalculated,
  'isWaistCircumferenceMeasured': instance.isWaistCircumferenceMeasured,
  'isRecentWeightChangeDocumented': instance.isRecentWeightChangeDocumented,
  'is24HourRecallCompleted': instance.is24HourRecallCompleted,
  'isFoodFrequencyAssessed': instance.isFoodFrequencyAssessed,
  'isAllergiesIntolerancesChecked': instance.isAllergiesIntolerancesChecked,
  'isSupplementsDocumented': instance.isSupplementsDocumented,
  'isDiabetesAssessed': instance.isDiabetesAssessed,
  'isHypertensionAssessed': instance.isHypertensionAssessed,
  'isDyslipidemiaAssessed': instance.isDyslipidemiaAssessed,
  'isObesityAssessed': instance.isObesityAssessed,
  'isCKDAssessed': instance.isCKDAssessed,
  'isGIDisordersAssessed': instance.isGIDisordersAssessed,
  'isMuscleWastingAssessed': instance.isMuscleWastingAssessed,
  'isFatLossAssessed': instance.isFatLossAssessed,
  'isEdemaAssessed': instance.isEdemaAssessed,
  'isAppetiteAssessed': instance.isAppetiteAssessed,
  'isChewingSwallowingAssessed': instance.isChewingSwallowingAssessed,
  'isGlucoseA1cReviewed': instance.isGlucoseA1cReviewed,
  'isLipidProfileReviewed': instance.isLipidProfileReviewed,
  'isElectrolytesReviewed': instance.isElectrolytesReviewed,
  'isRenalFunctionReviewed': instance.isRenalFunctionReviewed,
  'isMicronutrientsReviewed': instance.isMicronutrientsReviewed,
  'isInadequateIntakeDiagnosed': instance.isInadequateIntakeDiagnosed,
  'isExcessiveIntakeDiagnosed': instance.isExcessiveIntakeDiagnosed,
  'isFoodKnowledgeDeficitIdentified': instance.isFoodKnowledgeDeficitIdentified,
  'isCaloriePrescriptionSet': instance.isCaloriePrescriptionSet,
  'isMacronutrientDistributionPlanned':
      instance.isMacronutrientDistributionPlanned,
  'isEducationProvided': instance.isEducationProvided,
  'isFollowUpPlanEstablished': instance.isFollowUpPlanEstablished,
  'dietary24HRecall': instance.dietary24HRecall,
  'foodFrequencyChecked': instance.foodFrequencyChecked,
  'allergiesDocumented': instance.allergiesDocumented,
  'supplementsReviewed': instance.supplementsReviewed,
  'medicalHistoryReviewed': instance.medicalHistoryReviewed,
  'physicalExamCompleted': instance.physicalExamCompleted,
  'appetiteAssessed': instance.appetiteAssessed,
  'giSymptomsEvaluated': instance.giSymptomsEvaluated,
  'bloodGlucoseReviewed': instance.bloodGlucoseReviewed,
  'lipidProfileReviewed': instance.lipidProfileReviewed,
  'micronutrientsReviewed': instance.micronutrientsReviewed,
  'inadequateIntakeDiagnosed': instance.inadequateIntakeDiagnosed,
  'excessiveIntakeDiagnosed': instance.excessiveIntakeDiagnosed,
  'knowledgeDeficitIdentified': instance.knowledgeDeficitIdentified,
  'disorderedEatingIdentified': instance.disorderedEatingIdentified,
  'caloriePrescriptionSet': instance.caloriePrescriptionSet,
  'macroDistributionSet': instance.macroDistributionSet,
  'mealPlanProvided': instance.mealPlanProvided,
  'educationProvided': instance.educationProvided,
  'supplementsRecommended': instance.supplementsRecommended,
  'targetWeightSet': instance.targetWeightSet,
  'timelineDocumented': instance.timelineDocumented,
  'followUpScheduled': instance.followUpScheduled,
  'monitoringParametersSet': instance.monitoringParametersSet,
  'writtenInstructionsProvided': instance.writtenInstructionsProvided,
  'physicianNotified': instance.physicianNotified,
  'consentObtained': instance.consentObtained,
  'specialization': instance.specialization,
  'auditLog': instance.auditLog,
};

_AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) =>
    _AuditLogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      action: json['action'] as String,
      fieldChanged: json['fieldChanged'] as String,
      previousValue: json['previousValue'] as String,
      newValue: json['newValue'] as String,
    );

Map<String, dynamic> _$AuditLogEntryToJson(_AuditLogEntry instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'userId': instance.userId,
      'userName': instance.userName,
      'action': instance.action,
      'fieldChanged': instance.fieldChanged,
      'previousValue': instance.previousValue,
      'newValue': instance.newValue,
    };
