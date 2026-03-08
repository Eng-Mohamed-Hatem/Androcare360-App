/// Test fixtures for PhysiotherapyEMR entities
///
/// Provides pre-configured PhysiotherapyEMR instances for testing
/// with various states and data completeness levels.

library;

import 'package:elajtech/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart';

class PhysiotherapyEMRFixtures {
  /// Creates a complete EMR with all sections filled
  static PhysiotherapyEMR createCompleteEMR({
    String id = 'emr_complete_001',
    String appointmentId = 'apt_test_001',
    String patientId = 'patient_test_001',
    String doctorId = 'doctor_test_001',
    String doctorName = 'Dr. Ahmed Ali',
  }) {
    final now = DateTime.now();
    return PhysiotherapyEMR(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      visitDate: now,
      createdAt: now.subtract(const Duration(hours: 1)),
      basics: {
        'identityVerified': ['yes'],
        'consentObtained': ['yes'],
        'chiefComplaint': ['back_pain'],
      },
      painAssessment: {
        'painLocation': ['lower_back', 'right_leg'],
        'painIntensity': ['7'],
        'painType': ['sharp', 'radiating'],
      },
      functionalAssessment: {
        'mobility': ['independent'],
        'transfers': ['minimal_assistance'],
        'balance': ['fair'],
      },
      systemsReview: {
        'cardiovascular': ['normal'],
        'respiratory': ['normal'],
        'neurological': ['decreased_sensation'],
      },
      rangeOfMotion: {
        'lumbar_flexion': ['limited'],
        'lumbar_extension': ['limited'],
        'hip_flexion': ['normal'],
      },
      strengthAssessment: {
        'lower_extremity': ['4/5'],
        'core': ['3/5'],
        'upper_extremity': ['5/5'],
      },
      devicesEquipment: {
        'assistive_devices': ['cane'],
        'orthotics': ['none'],
      },
      treatmentPlan: {
        'modalities': ['heat', 'ultrasound'],
        'exercises': ['stretching', 'strengthening'],
        'frequency': ['3x_per_week'],
      },
      primaryDiagnosis: 'Lower back pain with radiculopathy',
      managementPlan: 'Physical therapy 3x per week for 4 weeks',
    );
  }

  /// Creates an empty EMR with no data
  static PhysiotherapyEMR createEmptyEMR({
    String id = 'emr_empty_001',
    String appointmentId = 'apt_test_002',
    String patientId = 'patient_test_002',
  }) {
    final now = DateTime.now();
    return PhysiotherapyEMR(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: 'doctor_test_001',
      doctorName: 'Dr. Ahmed Ali',
      visitDate: now,
      createdAt: now,
      basics: {},
      painAssessment: {},
      functionalAssessment: {},
      systemsReview: {},
      rangeOfMotion: {},
      strengthAssessment: {},
      devicesEquipment: {},
      treatmentPlan: {},
    );
  }

  /// Creates an EMR with only basics section filled
  static PhysiotherapyEMR createEMRWithBasics({
    String id = 'emr_basics_001',
    String appointmentId = 'apt_test_003',
    String patientId = 'patient_test_003',
  }) {
    final now = DateTime.now();
    return PhysiotherapyEMR(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: 'doctor_test_001',
      doctorName: 'Dr. Ahmed Ali',
      visitDate: now,
      createdAt: now,
      basics: {
        'identityVerified': ['yes'],
        'consentObtained': ['yes'],
      },
      painAssessment: {},
      functionalAssessment: {},
      systemsReview: {},
      rangeOfMotion: {},
      strengthAssessment: {},
      devicesEquipment: {},
      treatmentPlan: {},
    );
  }

  /// Creates a partial EMR with some sections filled
  static PhysiotherapyEMR createPartialEMR({
    String id = 'emr_partial_001',
    String appointmentId = 'apt_test_004',
    String patientId = 'patient_test_004',
  }) {
    final now = DateTime.now();
    return PhysiotherapyEMR(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: 'doctor_test_001',
      doctorName: 'Dr. Ahmed Ali',
      visitDate: now,
      createdAt: now.subtract(const Duration(hours: 2)),
      basics: {
        'identityVerified': ['yes'],
        'consentObtained': ['yes'],
      },
      painAssessment: {
        'painLocation': ['knee'],
        'painIntensity': ['5'],
      },
      functionalAssessment: {
        'mobility': ['independent'],
      },
      systemsReview: {},
      rangeOfMotion: {},
      strengthAssessment: {},
      devicesEquipment: {},
      treatmentPlan: {},
      primaryDiagnosis: 'Knee pain',
    );
  }
}
