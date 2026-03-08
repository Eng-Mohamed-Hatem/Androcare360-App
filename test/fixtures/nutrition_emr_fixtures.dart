/// Test fixtures for NutritionEMR entities
///
/// Provides pre-configured NutritionEMREntity instances for testing
/// with various states and data completeness levels.

library;

import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';

class NutritionEMRFixtures {
  /// Creates a complete EMR with all fields filled
  static NutritionEMREntity createCompleteEMR({
    String id = 'emr_complete_001',
    String appointmentId = 'apt_test_001',
    String patientId = 'patient_test_001',
    String nutritionistId = 'doctor_test_001',
    String nutritionistName = 'Dr. Ahmed Ali',
  }) {
    final now = DateTime.now();
    return NutritionEMREntity(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      nutritionistId: nutritionistId,
      nutritionistName: nutritionistName,
      visitDate: now,
      createdAt: now.subtract(const Duration(hours: 1)),
      updatedAt: now,
      lockedUntil: now.add(const Duration(hours: 23)),
      editCount: 1,
      lastEditedBy: nutritionistId,
      lastEditedByName: nutritionistName,
      // Anthropometric measurements
      heightValue: 170,
      weightValue: 70,
      waistCircumferenceValue: 85,
      weightMeasured: true,
      heightMeasured: true,
      bmiCalculated: true,
      waistCircumferenceMeasured: true,
      weightChangeDocumented: true,
      // Dietary assessment
      dietary24HRecall: true,
      foodFrequencyChecked: true,
      allergiesDocumented: true,
      supplementsReviewed: true,
      // Medical history
      medicalHistoryReviewed: true,
      physicalExamCompleted: true,
      appetiteAssessed: true,
      giSymptomsEvaluated: true,
      // Biochemical data
      bloodGlucoseReviewed: true,
      lipidProfileReviewed: true,
      micronutrientsReviewed: true,
      knowledgeDeficitIdentified: true,
      // Intervention plan
      caloriePrescriptionSet: true,
      macroDistributionSet: true,
      mealPlanProvided: true,
      educationProvided: true,
      supplementsRecommended: true,
      // Goals and monitoring
      targetWeightSet: true,
      timelineDocumented: true,
      followUpScheduled: true,
      monitoringParametersSet: true,
      writtenInstructionsProvided: true,
      consentObtained: true,
      auditLog: [],
    );
  }

  /// Creates a partial EMR with some fields missing
  static NutritionEMREntity createPartialEMR({
    String id = 'emr_partial_001',
    String appointmentId = 'apt_test_002',
    String patientId = 'patient_test_002',
  }) {
    final now = DateTime.now();
    return NutritionEMREntity(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      nutritionistId: 'doctor_test_001',
      nutritionistName: 'Dr. Ahmed Ali',
      visitDate: now,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
      lockedUntil: now.add(const Duration(hours: 22)),
      heightValue: 165,
      weightValue: 60,
      weightMeasured: true,
      heightMeasured: true,
      bmiCalculated: true,
      dietary24HRecall: true,
      allergiesDocumented: true,
      auditLog: [],
    );
  }

  /// Creates a locked EMR
  static NutritionEMREntity createLockedEMR({
    String id = 'emr_locked_001',
    String appointmentId = 'apt_test_004',
    String patientId = 'patient_test_004',
  }) {
    final now = DateTime.now();
    return NutritionEMREntity(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      nutritionistId: 'doctor_test_001',
      nutritionistName: 'Dr. Ahmed Ali',
      visitDate: now.subtract(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
      lockedUntil: now.subtract(const Duration(hours: 1)),
      isLocked: true,
      heightValue: 175,
      weightValue: 80,
      weightMeasured: true,
      heightMeasured: true,
      bmiCalculated: true,
      waistCircumferenceMeasured: true,
      dietary24HRecall: true,
      foodFrequencyChecked: true,
      allergiesDocumented: true,
      medicalHistoryReviewed: true,
      auditLog: [],
    );
  }
}
