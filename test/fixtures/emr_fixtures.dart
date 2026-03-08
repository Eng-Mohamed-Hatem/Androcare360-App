/// Test fixtures for EMR (Electronic Medical Records) models
///
/// Provides factory methods for creating test EMR data for different specializations.
/// These fixtures are used across unit, widget, and integration tests.
///
/// Note: This file provides basic EMR fixture structure. Specific EMR entity
/// fixtures should be added as the entities are implemented.
library;

import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/shared/models/physiotherapy_emr_model.dart';

/// Provides test fixtures for EMR models
class EMRFixtures {
  // ═══════════════════════════════════════════════════════════════════════════
  // NUTRITION EMR FIXTURES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a complete nutrition EMR for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'nutrition_emr_001')
  /// - [patientId]: Optional patient ID (defaults to 'patient_test_001')
  /// - [nutritionistId]: Optional nutritionist ID (defaults to 'doctor_test_001')
  /// - [isLocked]: Whether the EMR is locked (defaults to false)
  ///
  /// Returns a fully populated NutritionEMREntity with all checkboxes marked
  static NutritionEMREntity createCompleteNutritionEMR({
    String? id,
    String? patientId,
    String? nutritionistId,
    bool isLocked = false,
  }) {
    final now = DateTime.now();

    return NutritionEMREntity(
      id: id ?? 'nutrition_emr_001',
      patientId: patientId ?? 'patient_test_001',
      nutritionistId: nutritionistId ?? 'doctor_test_001',
      nutritionistName: 'Dr. Test Nutritionist',
      appointmentId: 'apt_test_001',
      visitDate: now,
      createdAt: now,
      updatedAt: now,
      isLocked: isLocked,
      lockedUntil: isLocked ? now.add(const Duration(hours: 24)) : null,

      // Anthropometric Measurements
      weightMeasured: true,
      heightMeasured: true,
      bmiCalculated: true,
      waistCircumferenceMeasured: true,
      weightChangeDocumented: true,
      heightValue: 170,
      weightValue: 75,
      waistCircumferenceValue: 85,
      hipCircumferenceValue: 95,

      // Patient and Visit Basics
      isIdentityVerified: true,
      isConsentObtained: true,
      isReasonForVisitDocumented: true,
      isDiagnosisReviewed: true,

      // Comprehensive Checklist - Anthropometric
      isWeightMeasured: true,
      isHeightMeasured: true,
      isBMICalculated: true,
      isWaistCircumferenceMeasured: true,
      isRecentWeightChangeDocumented: true,

      // Dietary Intake Assessment
      is24HourRecallCompleted: true,
    );
  }

  /// Creates a minimal nutrition EMR (first visit, few fields filled)
  static NutritionEMREntity createMinimalNutritionEMR({
    String? id,
    String? patientId,
    String? nutritionistId,
  }) {
    final now = DateTime.now();

    return NutritionEMREntity(
      id: id ?? 'nutrition_emr_minimal_001',
      patientId: patientId ?? 'patient_test_001',
      nutritionistId: nutritionistId ?? 'doctor_test_001',
      nutritionistName: 'Dr. Test Nutritionist',
      appointmentId: 'apt_test_002',
      visitDate: now,
      createdAt: now,
      updatedAt: now,

      // Only basic measurements
      weightMeasured: true,
      heightMeasured: true,
      bmiCalculated: true,
      heightValue: 165,
      weightValue: 70,
    );
  }

  /// Creates a locked nutrition EMR for testing edit restrictions
  static NutritionEMREntity createLockedNutritionEMR({
    String? id,
    String? patientId,
    String? nutritionistId,
  }) {
    return createCompleteNutritionEMR(
      id: id ?? 'nutrition_emr_locked_001',
      patientId: patientId,
      nutritionistId: nutritionistId,
      isLocked: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MULTI-EMR FIXTURES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates multiple nutrition EMRs for a patient
  static List<NutritionEMREntity> createMultipleNutritionEMRs({
    required String patientId,
    String? nutritionistId,
  }) {
    return [
      createCompleteNutritionEMR(
        id: 'nutrition_emr_001',
        patientId: patientId,
        nutritionistId: nutritionistId,
      ),
      createMinimalNutritionEMR(
        id: 'nutrition_emr_002',
        patientId: patientId,
        nutritionistId: nutritionistId,
      ),
      createLockedNutritionEMR(
        id: 'nutrition_emr_003',
        patientId: patientId,
        nutritionistId: nutritionistId,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHYSIOTHERAPY EMR FIXTURES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a complete physiotherapy EMR for testing
  ///
  /// Parameters:
  /// - [id]: Optional custom ID (defaults to 'physio_emr_001')
  /// - [patientId]: Optional patient ID (defaults to 'patient_test_001')
  /// - [doctorId]: Optional doctor ID (defaults to 'doctor_test_001')
  ///
  /// Returns a fully populated PhysiotherapyEMRModel with all sections filled
  static PhysiotherapyEMRModel createCompletePhysiotherapyEMR({
    String? id,
    String? patientId,
    String? doctorId,
  }) {
    final now = DateTime.now();

    return PhysiotherapyEMRModel(
      id: id ?? 'physio_emr_001',
      patientId: patientId ?? 'patient_test_001',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Physiotherapist',
      appointmentId: 'apt_test_001',
      createdAt: now,
      patientBasics: {
        'age': ['35'],
        'gender': ['Male'],
        'occupation': ['Software Engineer'],
      },
      history: {
        'chiefComplaint': ['Lower back pain'],
        'duration': ['3 months'],
        'previousTreatment': ['Pain medication'],
      },
      physicalExamination: {
        'posture': ['Forward head posture'],
        'gait': ['Normal'],
        'rangeOfMotion': ['Limited lumbar flexion'],
      },
      assessment: {
        'diagnosis': ['Chronic lower back pain'],
        'functionalLimitations': ['Difficulty sitting for long periods'],
      },
      plan: {
        'treatment': ['Manual therapy', 'Exercise therapy'],
        'frequency': ['3 times per week'],
        'duration': ['6 weeks'],
      },
      primaryDiagnosis: 'Chronic mechanical lower back pain',
      managementPlan:
          'Manual therapy combined with core strengthening exercises',
    );
  }

  /// Creates a minimal physiotherapy EMR (basic fields only)
  static PhysiotherapyEMRModel createMinimalPhysiotherapyEMR({
    String? id,
    String? patientId,
    String? doctorId,
  }) {
    final now = DateTime.now();

    return PhysiotherapyEMRModel(
      id: id ?? 'physio_emr_minimal_001',
      patientId: patientId ?? 'patient_test_001',
      doctorId: doctorId ?? 'doctor_test_001',
      doctorName: 'Dr. Test Physiotherapist',
      appointmentId: 'apt_test_002',
      createdAt: now,
      patientBasics: {
        'age': ['30'],
        'gender': ['Female'],
      },
      history: {},
      physicalExamination: {},
      assessment: {},
      plan: {},
      primaryDiagnosis: null,
      managementPlan: null,
    );
  }

  /// Creates multiple physiotherapy EMRs for a patient
  static List<PhysiotherapyEMRModel> createMultiplePhysiotherapyEMRs({
    required String patientId,
    String? doctorId,
  }) {
    return [
      createCompletePhysiotherapyEMR(
        id: 'physio_emr_001',
        patientId: patientId,
        doctorId: doctorId,
      ),
      createMinimalPhysiotherapyEMR(
        id: 'physio_emr_002',
        patientId: patientId,
        doctorId: doctorId,
      ),
      createCompletePhysiotherapyEMR(
        id: 'physio_emr_003',
        patientId: patientId,
        doctorId: doctorId,
      ),
    ];
  }
}
