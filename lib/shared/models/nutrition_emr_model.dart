/// Represents an Electronic Medical Record (EMR) for the Nutrition clinic.
///
/// This model stores comprehensive nutrition assessment data including patient
/// visit basics, anthropometric measurements, dietary intake, medical conditions,
/// physical findings, biochemical data, nutrition diagnosis, and intervention plans.
///
/// **Firestore Collection:** `emr_records`
/// **Specialization:** 'عيادة السمنة والتغذية العلاجية' (Obesity and Therapeutic Nutrition Clinic)
///
/// **Clinic Isolation Principle:**
/// This model is specific to the Nutrition clinic and must remain independent
/// from other specialty clinics (Physiotherapy, Internal Medicine, etc.) to
/// maintain the Single Responsibility Principle (SRP).
///
/// **Data Structure:**
/// Most fields use `Map<String, List<String>>` format to store flexible
/// question-answer pairs where:
/// - Key: Question identifier or category
/// - Value: List of selected answers or values
///
/// **Usage Example:**
/// ```dart
/// final nutritionEMR = NutritionEMRModel(
///   id: 'emr_123',
///   patientId: 'patient_456',
///   doctorId: 'doctor_789',
///   doctorName: 'Dr. Sarah Ahmed',
///   appointmentId: 'apt_001',
///   createdAt: DateTime.now(),
///   patientVisitBasics: {
///     'chiefComplaint': ['Weight management'],
///     'visitType': ['Initial consultation'],
///   },
///   anthropometrics: {
///     'weight': ['85.5'],
///     'height': ['170'],
///     'bmi': ['29.6'],
///   },
///   dietaryIntake: {
///     'mealsPerDay': ['3'],
///     'waterIntake': ['2 liters'],
///   },
///   medicalConditions: {
///     'diabetes': ['Type 2'],
///   },
///   physicalFindings: {},
///   biochemicalData: {
///     'glucose': ['120 mg/dL'],
///   },
///   nutritionDiagnosis: {
///     'diagnosis': ['Excessive energy intake'],
///   },
///   interventionPlan: {
///     'goals': ['Reduce weight by 5kg in 3 months'],
///   },
///   primaryDiagnosis: 'Obesity',
///   managementPlan: 'Calorie-restricted diet with exercise',
/// );
/// ```
class NutritionEMRModel {
  NutritionEMRModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.createdAt,
    required this.patientVisitBasics,
    required this.anthropometrics,
    required this.dietaryIntake,
    required this.medicalConditions,
    required this.physicalFindings,
    required this.biochemicalData,
    required this.nutritionDiagnosis,
    required this.interventionPlan,
    this.primaryDiagnosis,
    this.managementPlan,
    this.specialization = 'عيادة السمنة والتغذية العلاجية',
  });

  /// Creates a NutritionEMRModel from JSON data.
  ///
  /// This factory constructor parses JSON data from Firestore and creates
  /// a NutritionEMRModel instance. It handles DateTime parsing and converts
  /// nested maps to the required `Map<String, List<String>>` format.
  ///
  /// Parameters:
  /// - [json]: Map containing EMR data with all required fields
  ///
  /// Returns a fully initialized NutritionEMRModel instance.
  factory NutritionEMRModel.fromJson(Map<String, dynamic> json) {
    return NutritionEMRModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      appointmentId: json['appointmentId'] as String? ?? '',
      createdAt: json['createdAt'] is DateTime
          ? (json['createdAt'] as DateTime)
          : DateTime.parse(json['createdAt'] as String),
      patientVisitBasics: _parseMap(json['patientVisitBasics']),
      anthropometrics: _parseMap(json['anthropometrics']),
      dietaryIntake: _parseMap(json['dietaryIntake']),
      medicalConditions: _parseMap(json['medicalConditions']),
      physicalFindings: _parseMap(json['physicalFindings']),
      biochemicalData: _parseMap(json['biochemicalData']),
      nutritionDiagnosis: _parseMap(json['nutritionDiagnosis']),
      interventionPlan: _parseMap(json['interventionPlan']),
      primaryDiagnosis: json['primaryDiagnosis'] as String?,
      managementPlan: json['managementPlan'] as String?,
      specialization:
          json['specialization'] as String? ?? 'عيادة السمنة والتغذية العلاجية',
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

  /// Patient visit basics including chief complaint, visit type, and history
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'chiefComplaint': ['Weight management', 'Dietary counseling'],
  ///   'visitType': ['Initial consultation'],
  ///   'referralSource': ['Self-referred'],
  /// }
  /// ```
  final Map<String, List<String>> patientVisitBasics;

  /// Anthropometric measurements including weight, height, BMI, body composition
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'weight': ['85.5'],
  ///   'height': ['170'],
  ///   'bmi': ['29.6'],
  ///   'waistCircumference': ['95'],
  /// }
  /// ```
  final Map<String, List<String>> anthropometrics;

  /// Dietary intake assessment including meals, portions, and eating patterns
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'mealsPerDay': ['3'],
  ///   'snacks': ['2'],
  ///   'waterIntake': ['2 liters'],
  ///   'dietaryRestrictions': ['None'],
  /// }
  /// ```
  final Map<String, List<String>> dietaryIntake;

  /// Medical conditions relevant to nutrition assessment
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'diabetes': ['Type 2'],
  ///   'hypertension': ['Controlled'],
  ///   'allergies': ['None'],
  /// }
  /// ```
  final Map<String, List<String>> medicalConditions;

  /// Physical examination findings related to nutrition status
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'generalAppearance': ['Well-nourished'],
  ///   'skinCondition': ['Normal'],
  /// }
  /// ```
  final Map<String, List<String>> physicalFindings;

  /// Laboratory and biochemical test results
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'glucose': ['120 mg/dL'],
  ///   'hba1c': ['6.5%'],
  ///   'lipidProfile': ['Total cholesterol: 200 mg/dL'],
  /// }
  /// ```
  final Map<String, List<String>> biochemicalData;

  /// Nutrition diagnosis using standardized terminology
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'diagnosis': ['Excessive energy intake', 'Inadequate fiber intake'],
  ///   'etiology': ['Sedentary lifestyle', 'Poor food choices'],
  /// }
  /// ```
  final Map<String, List<String>> nutritionDiagnosis;

  /// Nutrition intervention plan including goals and recommendations
  ///
  /// Example structure:
  /// ```dart
  /// {
  ///   'goals': ['Reduce weight by 5kg in 3 months', 'Improve HbA1c'],
  ///   'dietPlan': ['1800 kcal/day', 'Low glycemic index foods'],
  ///   'followUp': ['2 weeks'],
  /// }
  /// ```
  final Map<String, List<String>> interventionPlan;

  /// Primary medical diagnosis (optional free-text field)
  final String? primaryDiagnosis;

  /// Overall management plan summary (optional free-text field)
  final String? managementPlan;

  /// Specialization identifier for this EMR (default: Nutrition clinic)
  final String specialization;

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

  /// Converts this NutritionEMRModel to JSON format for Firestore storage.
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
      'patientVisitBasics': patientVisitBasics,
      'anthropometrics': anthropometrics,
      'dietaryIntake': dietaryIntake,
      'medicalConditions': medicalConditions,
      'physicalFindings': physicalFindings,
      'biochemicalData': biochemicalData,
      'nutritionDiagnosis': nutritionDiagnosis,
      'interventionPlan': interventionPlan,
      'primaryDiagnosis': primaryDiagnosis,
      'managementPlan': managementPlan,
      'specialization': specialization,
    };
  }
}
