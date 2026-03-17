/// Represents an Electronic Medical Record (EMR) for the Physiotherapy clinic.
///
/// This model stores comprehensive physiotherapy assessment data including
/// patient basics, medical history, physical examination findings, clinical
/// assessment, and treatment plan.
///
/// **Firestore Collection:** `emr_records`
/// **Specialization:** 'عيادة العلاج الطبيعي والتأهيل' (Physiotherapy and Rehabilitation Clinic)
///
/// **Clinic Isolation Principle:**
/// This model is specific to the Physiotherapy clinic and must remain independent
/// from other specialty clinics (Nutrition, Internal Medicine, etc.) to maintain
/// the Single Responsibility Principle (SRP).
///
/// **Data Structure:**
/// All section fields use `Map<String, List<String>>` format to store flexible
/// question-answer pairs where:
/// - Key: Question identifier or category
/// - Value: List of selected answers or values
///
/// **Usage Example:**
/// ```dart
/// final physioEMR = PhysiotherapyEMRModel(
///   id: 'emr_456',
///   patientId: 'patient_789',
///   doctorId: 'doctor_123',
///   doctorName: 'Dr. Ahmed Hassan',
///   appointmentId: 'apt_002',
///   createdAt: DateTime.now(),
///   patientBasics: {
///     'age': ['35'],
///     'occupation': ['Office worker'],
///   },
///   history: {
///     'chiefComplaint': ['Lower back pain'],
///     'duration': ['3 months'],
///     'previousTreatment': ['Pain medication'],
///   },
///   physicalExamination: {
///     'posture': ['Forward head posture'],
///     'rangeOfMotion': ['Limited lumbar flexion'],
///   },
///   assessment: {
///     'diagnosis': ['Mechanical lower back pain'],
///     'functionalLimitations': ['Difficulty sitting for long periods'],
///   },
///   plan: {
///     'treatment': ['Manual therapy', 'Exercise therapy'],
///     'frequency': ['3 sessions per week'],
///     'duration': ['4 weeks'],
///   },
///   primaryDiagnosis: 'Mechanical lower back pain',
///   managementPlan: 'Manual therapy with progressive strengthening exercises',
/// );
/// ```
class PhysiotherapyEMRModel {
  PhysiotherapyEMRModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.createdAt,
    required this.patientBasics,
    required this.history,
    required this.physicalExamination,
    required this.assessment,
    required this.plan,
    required this.primaryDiagnosis,
    required this.managementPlan,
    this.specialization =
        'عيادة العلاج الطبيعي والتأهيل', // Use Arabic name for Firestore storage
  });

  /// Creates a PhysiotherapyEMRModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// a PhysiotherapyEMRModel instance. It handles DateTime parsing and converts
  /// nested maps to the required `Map<String, List<String>>` format.
  ///
  /// Parameters:
  /// - [json]: Map containing EMR data with all required fields
  ///
  /// Returns a fully initialized PhysiotherapyEMRModel instance.
  factory PhysiotherapyEMRModel.fromJson(Map<String, dynamic> json) {
    return PhysiotherapyEMRModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      appointmentId: json['appointmentId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      patientBasics: _parseMap(json['patientBasics']),
      history: _parseMap(json['history']),
      physicalExamination: _parseMap(json['physicalExamination']),
      assessment: _parseMap(json['assessment']),
      plan: _parseMap(json['plan']),
      primaryDiagnosis: json['primaryDiagnosis'] as String?,
      managementPlan: json['managementPlan'] as String?,
      specialization:
          json['specialization'] as String? ?? 'عيادة العلاج الطبيعي والتأهيل',
    );
  }

  /// Helper method to parse `Map<String, List<String>>` from JSON data.
  ///
  /// This method safely converts dynamic JSON data into the required format,
  /// handling null values and type conversions.
  ///
  /// Parameters:
  /// - [data]: Dynamic data from JSON (can be null or Map)
  ///
  /// Returns an empty map if data is null, otherwise converts to proper format.
  static Map<String, List<String>> _parseMap(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
  }

  /// Unique identifier for this EMR record
  final String id;

  /// ID of the patient this EMR belongs to
  final String patientId;

  /// ID of the doctor who created this EMR
  final String doctorId;

  /// Full name of the doctor
  final String doctorName;

  /// ID of the associated appointment
  final String appointmentId;

  /// Timestamp when this EMR was created
  final DateTime createdAt;

  /// Patient basic information including demographics and occupation
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'age': ['35'],
  ///   'gender': ['Male'],
  ///   'occupation': ['Office worker'],
  ///   'activityLevel': ['Sedentary'],
  /// }
  /// ```
  final Map<String, List<String>> patientBasics;

  /// Medical and injury history including chief complaint and previous treatments
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'chiefComplaint': ['Lower back pain'],
  ///   'duration': ['3 months'],
  ///   'onsetMechanism': ['Gradual onset'],
  ///   'previousTreatment': ['Pain medication', 'Rest'],
  ///   'medicalHistory': ['No significant history'],
  /// }
  /// ```
  final Map<String, List<String>> history;

  /// Physical examination findings including posture, range of motion, strength
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'posture': ['Forward head posture', 'Increased lumbar lordosis'],
  ///   'rangeOfMotion': ['Limited lumbar flexion: 40 degrees'],
  ///   'muscleStrength': ['Hip flexors: 4/5'],
  ///   'palpation': ['Tenderness over L4-L5'],
  ///   'specialTests': ['Straight leg raise: Negative'],
  /// }
  /// ```
  final Map<String, List<String>> physicalExamination;

  /// Clinical assessment including diagnosis and functional limitations
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'diagnosis': ['Mechanical lower back pain', 'Postural dysfunction'],
  ///   'functionalLimitations': ['Difficulty sitting > 30 minutes', 'Limited bending'],
  ///   'prognosticFactors': ['Good motivation', 'Young age'],
  /// }
  /// ```
  final Map<String, List<String>> assessment;

  /// Treatment plan including interventions, frequency, and goals
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'treatment': ['Manual therapy', 'Exercise therapy', 'Postural education'],
  ///   'frequency': ['3 sessions per week'],
  ///   'duration': ['4 weeks'],
  ///   'goals': ['Pain reduction', 'Improve ROM', 'Return to work'],
  ///   'homeExercises': ['Core strengthening', 'Stretching'],
  /// }
  /// ```
  final Map<String, List<String>> plan;

  /// Primary diagnosis (free-text field for main clinical diagnosis)
  final String? primaryDiagnosis;

  /// Overall management plan summary (free-text field)
  final String? managementPlan;

  /// Specialization identifier for this EMR (default: Physiotherapy clinic)
  final String specialization;

  /// Converts this PhysiotherapyEMRModel to JSON format for Firestore storage.
  ///
  /// This method serializes all EMR data into a Map suitable for storing
  /// in Firestore. All nested maps and DateTime values are properly formatted.
  ///
  /// Returns a `Map<String, dynamic>` containing all EMR data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'createdAt': createdAt.toIso8601String(),
      'patientBasics': patientBasics,
      'history': history,
      'physicalExamination': physicalExamination,
      'assessment': assessment,
      'plan': plan,
      'primaryDiagnosis': primaryDiagnosis,
      'managementPlan': managementPlan,
      'specialization': specialization,
    };
  }
}
