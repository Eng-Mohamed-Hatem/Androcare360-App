/// Represents an Electronic Medical Record (EMR) for Internal Medicine and Family Medicine.
///
/// This model stores comprehensive internal medicine assessment data including
/// system review, chronic disease management, ICD-10 diagnosis codes, and
/// clinical notes.
///
/// **Firestore Collection:** `emr_records`
/// **Specializations:** Internal Medicine, Family Medicine
///
/// **Clinic Isolation Principle:**
/// This model is specific to Internal Medicine and Family Medicine clinics
/// and must remain independent from other specialty clinics (Nutrition,
/// Physiotherapy, etc.) to maintain the Single Responsibility Principle (SRP).
///
/// **Data Structure:**
/// - `systemReview`: Map of body system to list of symptoms/findings
/// - `chronicDiseases`: Map of disease name to list of management items
/// - `icd10Codes`: List of ICD-10 diagnosis codes
///
/// **Usage Example:**
/// ```dart
/// final internalMedEMR = InternalMedicineEMRModel(
///   id: 'emr_789',
///   patientId: 'patient_123',
///   doctorId: 'doctor_456',
///   doctorName: 'Dr. Mohammed Ali',
///   appointmentId: 'apt_003',
///   createdAt: DateTime.now(),
///   systemReview: {
///     'general': ['fever', 'fatigue'],
///     'cardiovascular': ['chest pain'],
///     'respiratory': ['cough'],
///   },
///   chronicDiseases: {
///     'diabetes': ['A1c reviewed', 'SMBG/CGM reviewed'],
///     'hypertension': ['home BP reviewed', 'adherence checked'],
///   },
///   icd10Codes: ['E11.9', 'I10', 'J06.9'],
///   notes: 'Patient presents with acute URI symptoms. Diabetes well controlled.',
/// );
/// ```
class InternalMedicineEMRModel {
  InternalMedicineEMRModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.createdAt,
    required this.systemReview,
    required this.chronicDiseases,
    required this.icd10Codes,
    this.notes,
  });

  /// Creates an InternalMedicineEMRModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// an InternalMedicineEMRModel instance. It handles DateTime parsing and
  /// safely converts nested maps and lists with null-safety.
  ///
  /// Parameters:
  /// - [json]: Map containing EMR data with all required fields
  ///
  /// Returns a fully initialized InternalMedicineEMRModel instance.
  factory InternalMedicineEMRModel.fromJson(Map<String, dynamic> json) =>
      InternalMedicineEMRModel(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        appointmentId: json['appointmentId'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        systemReview:
            (json['systemReview'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
        chronicDiseases:
            (json['chronicDiseases'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((e) => e as String).toList(),
              ),
            ) ??
            {},
        icd10Codes:
            (json['icd10Codes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        notes: json['notes'] as String?,
      );

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

  /// System review organized by body system with selected symptoms/findings.
  ///
  /// This comprehensive review of systems helps identify symptoms across
  /// different body systems. Each system maps to a list of selected findings.
  ///
  /// **Available Systems:**
  /// - general, skin, heent, neck, cardiovascular, respiratory
  /// - gastrointestinal, genitourinary, musculoskeletal, neurological
  /// - psychiatric, endocrine, hematologic, allergy
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'general': ['fever', 'fatigue', 'weight change'],
  ///   'cardiovascular': ['chest pain', 'palpitations'],
  ///   'respiratory': ['cough', 'dyspnea'],
  /// }
  /// ```
  final Map<String, List<String>> systemReview;

  /// Chronic disease management tracking with selected management items.
  ///
  /// This field tracks ongoing management of chronic conditions. Each disease
  /// maps to a list of management activities or assessments performed.
  ///
  /// **Available Diseases:**
  /// - diabetes, hypertension, asthma_copd, chf_cad, ckd, mental_health
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'diabetes': ['A1c reviewed', 'SMBG/CGM reviewed', 'complications assessed'],
  ///   'hypertension': ['home BP reviewed', 'adherence checked'],
  /// }
  /// ```
  final Map<String, List<String>> chronicDiseases;

  /// List of ICD-10 diagnosis codes for this visit.
  ///
  /// ICD-10 codes provide standardized diagnosis coding for billing and
  /// medical records. Multiple codes can be assigned per visit.
  ///
  /// **Common Codes:**
  /// - J06.9: Acute URI
  /// - I10: Essential hypertension
  /// - E11.9: Type 2 diabetes without complications
  /// - J45.909: Asthma, unspecified
  ///
  /// Example:
  /// ```dart
  /// ['J06.9', 'I10', 'E11.9']
  /// ```
  final List<String> icd10Codes;

  /// Additional clinical notes (free-text field for detailed documentation)
  final String? notes;

  /// Converts this InternalMedicineEMRModel to JSON format for Firestore storage.
  ///
  /// This method serializes all EMR data into a Map suitable for storing
  /// in Firestore. All nested maps, lists, and DateTime values are properly formatted.
  ///
  /// Returns a Map<String, dynamic> containing all EMR data.
  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'appointmentId': appointmentId,
    'createdAt': createdAt.toIso8601String(),
    'systemReview': systemReview,
    'chronicDiseases': chronicDiseases,
    'icd10Codes': icd10Codes,
    'notes': notes,
  };
}

/// Provides system review options for Internal Medicine EMR.
///
/// This class defines all available body systems and their associated
/// symptoms/findings that can be selected during a system review.
///
/// **Usage:**
/// ```dart
/// final systems = SystemReviewOptions.systems;
/// final generalSymptoms = systems['general']; // ['fever', 'weight change', ...]
/// ```
class SystemReviewOptions {
  static const Map<String, List<String>> systems = {
    'general': ['fever', 'weight change', 'fatigue', 'night sweats'],
    'skin': ['rash', 'itching', 'lesions', 'color change'],
    'heent': ['headache', 'vision problems', 'hearing problems', 'sore throat'],
    'neck': ['pain', 'swelling', 'stiffness'],
    'cardiovascular': ['chest pain', 'palpitations', 'edema', 'syncope'],
    'respiratory': ['cough', 'wheeze', 'dyspnea', 'hemoptysis'],
    'gastrointestinal': [
      'abdominal pain',
      'N/V/D',
      'constipation',
      'reflux',
      'bleeding',
    ],
    'genitourinary': ['dysuria', 'frequency', 'hematuria', 'discharge'],
    'musculoskeletal': [
      'joint pain',
      'back/neck pain',
      'trauma',
      'Signs of autoimmune Disorders',
    ],
    'neurological': ['weakness', 'dizziness', 'numbness', 'tremor', 'seizures'],
    'psychiatric': [
      'anxiety',
      'depression',
      'sleep disturbance',
      'suicidal ideation',
    ],
    'endocrine': ['heat/cold intolerance', 'polyuria', 'polydipsia'],
    'hematologic': ['bleeding', 'bruising', 'lymph node swelling'],
    'allergy': ['allergic reactions', 'recurrent infections', 'Food Allergies'],
  };

  /// Human-readable labels for each body system
  static const Map<String, String> systemLabels = {
    'general': 'General',
    'skin': 'Skin',
    'heent': 'HEENT',
    'neck': 'Neck',
    'cardiovascular': 'Cardiovascular',
    'respiratory': 'Respiratory',
    'gastrointestinal': 'Gastrointestinal',
    'genitourinary': 'Genitourinary',
    'musculoskeletal': 'Musculoskeletal',
    'neurological': 'Neurological',
    'psychiatric': 'Psychiatric',
    'endocrine': 'Endocrine',
    'hematologic': 'Hematologic/Lymphatic',
    'allergy': 'Allergy/Immunologic',
  };
}

/// Provides chronic disease management options for Internal Medicine EMR.
///
/// This class defines common chronic diseases and their associated
/// management activities that should be reviewed during visits.
///
/// **Usage:**
/// ```dart
/// final diseases = ChronicDiseaseOptions.diseases;
/// final diabetesItems = diseases['diabetes']; // ['A1c reviewed', ...]
/// ```
class ChronicDiseaseOptions {
  static const Map<String, List<String>> diseases = {
    'diabetes': ['A1c reviewed', 'SMBG/CGM reviewed', 'complications assessed'],
    'hypertension': ['home BP reviewed', 'adherence checked', 'red flags'],
    'asthma_copd': [
      'control level',
      'triggers',
      'action plan',
      'inhaler technique',
    ],
    'chf_cad': ['dyspnea', 'edema', 'medication review'],
    'ckd': ['stage documented', 'labs reviewed'],
    'mental_health': ['PHQ/GAD reviewed', 'safety assessed'],
  };

  /// Human-readable labels for each chronic disease category
  static const Map<String, String> diseaseLabels = {
    'diabetes': 'Diabetes Mellitus',
    'hypertension': 'Hypertension',
    'asthma_copd': 'Asthma/COPD',
    'chf_cad': 'CHF/CAD',
    'ckd': 'CKD',
    'mental_health': 'Mental Health',
  };
}

/// Provides commonly used ICD-10 diagnosis codes for Internal Medicine.
///
/// This class contains a curated list of frequently used ICD-10 codes
/// for common conditions seen in internal medicine and family practice.
///
/// **Usage:**
/// ```dart
/// final codes = ICD10Codes.codes;
/// // Display in UI: codes[0]['code'] + ' - ' + codes[0]['description']
/// // Result: "J06.9 - Acute URI"
/// ```
class ICD10Codes {
  /// List of ICD-10 codes with their descriptions
  ///
  /// Each entry contains:
  /// - 'code': The ICD-10 code (e.g., 'J06.9')
  /// - 'description': Human-readable description (e.g., 'Acute URI')
  static const List<Map<String, String>> codes = [
    {'code': 'J06.9', 'description': 'Acute URI'},
    {'code': 'J02.9', 'description': 'Acute pharyngitis'},
    {'code': 'H66.90', 'description': 'Acute otitis media'},
    {'code': 'J20.9', 'description': 'Acute bronchitis'},
    {'code': 'J11.1', 'description': 'Influenza'},
    {'code': 'U07.1', 'description': 'COVID-19'},
    {'code': 'I10', 'description': 'Essential hypertension'},
    {'code': 'E11.9', 'description': 'Type 2 diabetes without complications'},
    {'code': 'E78.5', 'description': 'Hyperlipidemia'},
    {'code': 'J45.909', 'description': 'Asthma, unspecified'},
    {'code': 'K21.9', 'description': 'GERD'},
    {'code': 'F41.1', 'description': 'Generalized anxiety disorder'},
    {'code': 'F32.9', 'description': 'Major depressive disorder'},
    {'code': 'M54.50', 'description': 'Low back pain'},
    {'code': 'N39.0', 'description': 'Uncomplicated UTI'},
  ];
}
