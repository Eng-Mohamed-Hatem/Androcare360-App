/// Nutrition & Obesity Therapy EMR Questions
/// Contains all checklist items for the 8 main sections of the Nutrition EMR
class NutritionQuestions {
  NutritionQuestions._();

  // Section 1: Patient Visit Basics
  static const Map<String, List<String>> patientVisitBasics = {
    'visitReason': [
      'Weight Loss',
      'Weight Gain',
      'Maintenance',
      'Medical Nutrition Therapy',
      'Sports Nutrition',
      'Follow-up',
    ],
    'chiefComplaint': [
      'Obesity',
      'Overweight',
      'Underweight',
      'Eating Disorder',
      'Diabetes Management',
      'Hypertension',
      'Dyslipidemia',
      'Metabolic Syndrome',
      'Other',
    ],
    'presentIllness': [
      'Chronic Disease',
      'Acute Illness',
      'Post-surgical Recovery',
      'Pregnancy',
      'Lactation',
      'None',
    ],
    'medicationHistory': [
      'Current Medications',
      'Supplements',
      'Herbal Products',
      'None',
    ],
  };

  static const Map<String, String> patientVisitBasicsLabels = {
    'visitReason': 'Reason for Visit',
    'chiefComplaint': 'Chief Complaint',
    'presentIllness': 'Present Illness',
    'medicationHistory': 'Medication History',
  };

  // Section 2: Anthropometrics
  static const Map<String, List<String>> anthropometrics = {
    'height': ['Measured', 'Self-reported', 'Estimated'],
    'weight': ['Measured', 'Self-reported', 'Estimated'],
    'bmi': [
      'Underweight',
      'Normal',
      'Overweight',
      'Obese Class I',
      'Obese Class II',
      'Obese Class III',
    ],
    'waistCircumference': ['Normal', 'Increased Risk', 'High Risk'],
    'bodyComposition': [
      'Normal',
      'Increased Body Fat',
      'Decreased Muscle Mass',
      'Edema',
    ],
    'vitalSigns': [
      'Blood Pressure',
      'Heart Rate',
      'Respiratory Rate',
      'Temperature',
    ],
  };

  static const Map<String, String> anthropometricsLabels = {
    'height': 'Height',
    'weight': 'Weight',
    'bmi': 'BMI Classification',
    'waistCircumference': 'Waist Circumference',
    'bodyComposition': 'Body Composition',
    'vitalSigns': 'Vital Signs',
  };

  // Section 3: Dietary Intake Assessment
  static const Map<String, List<String>> dietaryIntake = {
    'dietaryPattern': [
      'Regular',
      'Vegetarian',
      'Vegan',
      'Mediterranean',
      'Low Carb',
      'Keto',
      'Intermittent Fasting',
      'Other',
    ],
    'mealFrequency': [
      '1-2 meals/day',
      '3 meals/day',
      '4-5 meals/day',
      '6+ meals/day',
      'Grazing',
    ],
    'foodPreferences': [
      'High Protein',
      'Low Fat',
      'Low Sugar',
      'Low Sodium',
      'Organic',
      'Processed Foods',
      'Fast Food',
    ],
    'fluidIntake': [
      'Water',
      'Sugary Beverages',
      'Alcohol',
      'Caffeine',
      'Juices',
      'Other',
    ],
    'eatingBehavior': [
      'Emotional Eating',
      'Binge Eating',
      'Night Eating',
      'Mindful Eating',
      'Social Eating',
      'Restrictive Eating',
    ],
    'foodAllergies': [
      'Dairy',
      'Gluten',
      'Nuts',
      'Shellfish',
      'Eggs',
      'Soy',
      'None',
    ],
  };

  static const Map<String, String> dietaryIntakeLabels = {
    'dietaryPattern': 'Dietary Pattern',
    'mealFrequency': 'Meal Frequency',
    'foodPreferences': 'Food Preferences',
    'fluidIntake': 'Fluid Intake',
    'eatingBehavior': 'Eating Behavior',
    'foodAllergies': 'Food Allergies/Intolerances',
  };

  // Section 4: Medical Conditions
  static const Map<String, List<String>> medicalConditions = {
    'chronicDiseases': [
      'Type 2 Diabetes',
      'Type 1 Diabetes',
      'Hypertension',
      'Dyslipidemia',
      'Cardiovascular Disease',
      'Metabolic Syndrome',
      'PCOS',
      'Thyroid Disorders',
      'None',
    ],
    'gastrointestinal': [
      'GERD',
      'IBS',
      'IBD',
      'Celiac Disease',
      'Food Intolerance',
      'Gallbladder Disease',
      'None',
    ],
    'endocrine': [
      'Hypothyroidism',
      'Hyperthyroidism',
      'Diabetes Insipidus',
      'Adrenal Insufficiency',
      'None',
    ],
    'psychological': [
      'Depression',
      'Anxiety',
      'Eating Disorders',
      'Stress',
      'None',
    ],
    'surgicalHistory': [
      'Bariatric Surgery',
      'Gastrointestinal Surgery',
      'Other Surgery',
      'None',
    ],
  };

  static const Map<String, String> medicalConditionsLabels = {
    'chronicDiseases': 'Chronic Diseases',
    'gastrointestinal': 'Gastrointestinal Conditions',
    'endocrine': 'Endocrine Conditions',
    'psychological': 'Psychological Conditions',
    'surgicalHistory': 'Surgical History',
  };

  // Section 5: Nutrition Focused Physical Findings
  static const Map<String, List<String>> physicalFindings = {
    'generalAppearance': [
      'Well-nourished',
      'Undernourished',
      'Overweight',
      'Obese',
      'Cachectic',
      'Edematous',
    ],
    'skin': [
      'Normal',
      'Dry',
      'Pale',
      'Jaundiced',
      'Petechiae',
      'Other',
    ],
    'hair': [
      'Normal',
      'Dry',
      'Brittle',
      'Thinning',
      'Other',
    ],
    'nails': [
      'Normal',
      'Brittle',
      'Spoon-shaped',
      'Clubbed',
      'Other',
    ],
    'oralCavity': [
      'Normal',
      'Dental Caries',
      'Gingivitis',
      'Oral Thrush',
      'Other',
    ],
    'abdomen': [
      'Normal',
      'Distended',
      'Tender',
      'Mass',
      'Other',
    ],
  };

  static const Map<String, String> physicalFindingsLabels = {
    'generalAppearance': 'General Appearance',
    'skin': 'Skin',
    'hair': 'Hair',
    'nails': 'Nails',
    'oralCavity': 'Oral Cavity',
    'abdomen': 'Abdomen',
  };

  // Section 6: Biochemical Data Reviewed
  static const Map<String, List<String>> biochemicalData = {
    'completeBloodCount': [
      'Hemoglobin',
      'Hematocrit',
      'WBC',
      'Platelets',
      'Normal',
      'Abnormal',
    ],
    'metabolicPanel': [
      'Glucose (Fasting)',
      'Glucose (Random)',
      'HbA1c',
      'Insulin',
      'C-Peptide',
      'Normal',
      'Abnormal',
    ],
    'lipidProfile': [
      'Total Cholesterol',
      'LDL',
      'HDL',
      'Triglycerides',
      'Normal',
      'Abnormal',
    ],
    'liverFunction': [
      'ALT',
      'AST',
      'ALP',
      'Bilirubin',
      'Albumin',
      'Normal',
      'Abnormal',
    ],
    'kidneyFunction': [
      'Creatinine',
      'BUN',
      'eGFR',
      'Normal',
      'Abnormal',
    ],
    'thyroidFunction': [
      'TSH',
      'Free T4',
      'Free T3',
      'Normal',
      'Abnormal',
    ],
    'vitamins': [
      'Vitamin D',
      'Vitamin B12',
      'Folate',
      'Iron',
      'Normal',
      'Abnormal',
    ],
  };

  static const Map<String, String> biochemicalDataLabels = {
    'completeBloodCount': 'Complete Blood Count',
    'metabolicPanel': 'Metabolic Panel',
    'lipidProfile': 'Lipid Profile',
    'liverFunction': 'Liver Function Tests',
    'kidneyFunction': 'Kidney Function Tests',
    'thyroidFunction': 'Thyroid Function Tests',
    'vitamins': 'Vitamins and Minerals',
  };

  // Section 7: Nutrition Diagnosis
  static const Map<String, List<String>> nutritionDiagnosis = {
    'energyIntake': [
      'Excessive',
      'Adequate',
      'Inadequate',
    ],
    'proteinIntake': [
      'Excessive',
      'Adequate',
      'Inadequate',
    ],
    'carbohydrateIntake': [
      'Excessive',
      'Adequate',
      'Inadequate',
    ],
    'fatIntake': [
      'Excessive',
      'Adequate',
      'Inadequate',
    ],
    'micronutrientDeficiency': [
      'Vitamin D Deficiency',
      'Vitamin B12 Deficiency',
      'Iron Deficiency Anemia',
      'Folate Deficiency',
      'None',
    ],
    'hydrationStatus': [
      'Well-hydrated',
      'Mildly Dehydrated',
      'Moderately Dehydrated',
      'Severely Dehydrated',
    ],
    'nutritionRisk': [
      'Low Risk',
      'Moderate Risk',
      'High Risk',
      'Very High Risk',
    ],
  };

  static const Map<String, String> nutritionDiagnosisLabels = {
    'energyIntake': 'Energy Intake',
    'proteinIntake': 'Protein Intake',
    'carbohydrateIntake': 'Carbohydrate Intake',
    'fatIntake': 'Fat Intake',
    'micronutrientDeficiency': 'Micronutrient Deficiencies',
    'hydrationStatus': 'Hydration Status',
    'nutritionRisk': 'Nutrition Risk Level',
  };

  // Section 8: Intervention Plan
  static const Map<String, List<String>> interventionPlan = {
    'dietaryModification': [
      'Calorie Restriction',
      'Portion Control',
      'Meal Planning',
      'Food Substitution',
      'Behavior Modification',
      'Mindful Eating',
    ],
    'macronutrientAdjustment': [
      'Increase Protein',
      'Decrease Carbohydrates',
      'Decrease Saturated Fat',
      'Increase Fiber',
      'Adjust Meal Timing',
    ],
    'supplementation': [
      'Multivitamin',
      'Vitamin D',
      'Omega-3',
      'Probiotics',
      'Calcium',
      'Iron',
      'None',
    ],
    'physicalActivity': [
      'Aerobic Exercise',
      'Resistance Training',
      'Walking Program',
      'Swimming',
      'Yoga',
      'Other',
    ],
    'behavioralTherapy': [
      'Cognitive Behavioral Therapy',
      'Motivational Interviewing',
      'Food Diary',
      'Self-Monitoring',
      'Goal Setting',
    ],
    'followUpPlan': [
      'Weekly',
      'Bi-weekly',
      'Monthly',
      'Quarterly',
      'As Needed',
    ],
    'educationTopics': [
      'Label Reading',
      'Healthy Cooking',
      'Dining Out',
      'Stress Management',
      'Sleep Hygiene',
      'Other',
    ],
  };

  static const Map<String, String> interventionPlanLabels = {
    'dietaryModification': 'Dietary Modifications',
    'macronutrientAdjustment': 'Macronutrient Adjustments',
    'supplementation': 'Supplementation',
    'physicalActivity': 'Physical Activity Recommendations',
    'behavioralTherapy': 'Behavioral Therapy',
    'followUpPlan': 'Follow-up Plan',
    'educationTopics': 'Education Topics',
  };
}
