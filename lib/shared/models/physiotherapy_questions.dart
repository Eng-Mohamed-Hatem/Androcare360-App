/// Physiotherapy questions and labels for EMR assessment.
///
/// This class contains static maps of questions organized by category
/// (Patient Basics, History, Physical Examination, Assessment, Plan)
/// along with their corresponding Arabic labels.
class PhysiotherapyQuestions {
  // Private constructor to prevent instantiation
  PhysiotherapyQuestions._();

  // ==================== PATIENT BASICS ====================
  /// Questions about patient basic information
  static const Map<String, List<String>> patientBasics = {
    'chief_complaint': [
      'Pain',
      'Weakness',
      'Stiffness',
      'Swelling',
      'Numbness/Tingling',
      'Difficulty Walking',
      'Loss of Balance',
      'Fatigue',
      'Other',
    ],
    'onset': [
      'Sudden',
      'Gradual',
      'Progressive',
      'Intermittent',
      'Constant',
    ],
    'duration': [
      '< 1 week',
      '1-4 weeks',
      '1-6 months',
      '6-12 months',
      '> 1 year',
    ],
    'pain_intensity': [
      'Mild (1-3/10)',
      'Moderate (4-6/10)',
      'Severe (7-10/10)',
    ],
    'pain_character': [
      'Sharp',
      'Dull/Aching',
      'Throbbing',
      'Burning',
      'Cramping',
      'Shooting',
    ],
  };

  /// Arabic labels for patient basics categories
  static const Map<String, String> patientBasicsLabels = {
    'chief_complaint': 'الشكوى الرئيسية',
    'onset': 'البداية',
    'duration': 'المدة',
    'pain_intensity': 'شدة الألم',
    'pain_character': 'طبيعة الألم',
  };

  // ==================== HISTORY ====================
  /// Questions about patient medical history
  static const Map<String, List<String>> history = {
    'past_medical_history': [
      'Hypertension',
      'Diabetes',
      'Heart Disease',
      'Stroke',
      'Cancer',
      'Arthritis',
      'Osteoporosis',
      'None',
    ],
    'surgical_history': [
      'Orthopedic Surgery',
      'Spinal Surgery',
      'Joint Replacement',
      'Fracture Repair',
      'None',
    ],
    'medications': [
      'Pain Relievers',
      'Anti-inflammatory',
      'Muscle Relaxants',
      'Blood Thinners',
      'Corticosteroids',
      'None',
    ],
    'previous_therapy': [
      'Physical Therapy',
      'Occupational Therapy',
      'Chiropractic',
      'Acupuncture',
      'Massage Therapy',
      'None',
    ],
    'lifestyle_factors': [
      'Smoking',
      'Alcohol',
      'Sedentary Lifestyle',
      'Heavy Lifting',
      'Repetitive Activities',
      'None',
    ],
  };

  /// Arabic labels for history categories
  static const Map<String, String> historyLabels = {
    'past_medical_history': 'التاريخ المرضي السابق',
    'surgical_history': 'التاريخ الجراحي',
    'medications': 'الأدوية الحالية',
    'previous_therapy': 'العلاج السابق',
    'lifestyle_factors': 'عوامل نمط الحياة',
  };

  // ==================== PHYSICAL EXAMINATION ====================
  /// Questions about physical examination findings
  static const Map<String, List<String>> physicalExamination = {
    'posture': [
      'Normal',
      'Kyphosis',
      'Lordosis',
      'Scoliosis',
      'Forward Head Posture',
      'Rounded Shoulders',
    ],
    'gait': [
      'Normal',
      'Antalgic',
      'Trendelenburg',
      'Steppage',
      'Staggering',
      'Using Assistive Device',
    ],
    'range_of_motion': [
      'Full',
      'Mildly Limited',
      'Moderately Limited',
      'Severely Limited',
      'Painful',
    ],
    'muscle_strength': [
      '5/5 (Normal)',
      '4/5 (Good)',
      '3/5 (Fair)',
      '2/5 (Poor)',
      '1/5 (Trace)',
      '0/5 (None)',
    ],
    'muscle_tone': [
      'Normal',
      'Hypertonic',
      'Hypotonic',
      'Spastic',
      'Flaccid',
    ],
    'sensation': [
      'Intact',
      'Diminished',
      'Absent',
      'Hyperesthesia',
      'Paresthesia',
    ],
    'reflexes': [
      'Normal',
      'Hyperreflexia',
      'Hyporeflexia',
      'Absent',
      'Asymmetric',
    ],
    'special_tests': [
      'Positive',
      'Negative',
      'Not Performed',
    ],
  };

  /// Arabic labels for physical examination categories
  static const Map<String, String> physicalExaminationLabels = {
    'posture': 'الوضعية',
    'gait': 'المشي',
    'range_of_motion': 'مدى الحركة',
    'muscle_strength': 'قوة العضلات',
    'muscle_tone': 'نبرة العضلات',
    'sensation': 'الإحساس',
    'reflexes': 'المنعكسات',
    'special_tests': 'الفحوصات الخاصة',
  };

  // ==================== ASSESSMENT ====================
  /// Questions about clinical assessment
  static const Map<String, List<String>> assessment = {
    'diagnosis': [
      'Musculoskeletal Disorder',
      'Neurological Condition',
      'Post-surgical Rehabilitation',
      'Sports Injury',
      'Chronic Pain Syndrome',
      'Degenerative Condition',
      'Other',
    ],
    'functional_limitations': [
      'Activities of Daily Living',
      'Mobility',
      'Work-related Activities',
      'Sports/Recreation',
      'Balance/Coordination',
      'Endurance',
    ],
    'prognosis': [
      'Excellent',
      'Good',
      'Fair',
      'Guarded',
      'Poor',
    ],
    'goals': [
      'Pain Reduction',
      'Improved Range of Motion',
      'Increased Strength',
      'Functional Independence',
      'Return to Work/Sport',
      'Prevention of Recurrence',
    ],
    'risk_factors': [
      'Age',
      'Obesity',
      'Comorbidities',
      'Poor Compliance',
      'Work Environment',
      'None Identified',
    ],
  };

  /// Arabic labels for assessment categories
  static const Map<String, String> assessmentLabels = {
    'diagnosis': 'التشخيص',
    'functional_limitations': 'القيود الوظيفية',
    'prognosis': 'التشخيص المستقبلي',
    'goals': 'الأهداف العلاجية',
    'risk_factors': 'عوامل الخطر',
  };

  // ==================== PLAN ====================
  /// Questions about treatment plan
  static const Map<String, List<String>> plan = {
    'treatment_modalities': [
      'Therapeutic Exercise',
      'Manual Therapy',
      'Electrical Stimulation',
      'Ultrasound',
      'Heat/Cold Therapy',
      'Traction',
      'Hydrotherapy',
      'Massage',
    ],
    'exercise_prescription': [
      'Range of Motion Exercises',
      'Strengthening Exercises',
      'Stretching/Flexibility',
      'Balance Training',
      'Core Stabilization',
      'Functional Training',
      'Aerobic Conditioning',
    ],
    'frequency': [
      '1x/week',
      '2x/week',
      '3x/week',
      'Daily Home Program',
      'As Needed',
    ],
    'duration': [
      '2-4 weeks',
      '4-8 weeks',
      '8-12 weeks',
      '3-6 months',
      'Ongoing',
    ],
    'education': [
      'Body Mechanics',
      'Ergonomics',
      'Home Exercise Program',
      'Pain Management',
      'Lifestyle Modifications',
    ],
    'follow_up': [
      '1 week',
      '2 weeks',
      '1 month',
      '6 weeks',
      'As Needed',
    ],
  };

  /// Arabic labels for plan categories
  static const Map<String, String> planLabels = {
    'treatment_modalities': 'طرق العلاج',
    'exercise_prescription': 'وصف التمارين',
    'frequency': 'التكرار',
    'duration': 'المدة',
    'education': 'التعليم',
    'follow_up': 'المتابعة',
  };
}
