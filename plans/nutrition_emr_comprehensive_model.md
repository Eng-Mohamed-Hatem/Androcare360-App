// ignore_for_file: all  
// ignore_for_file: all
# Nutrition EMR Comprehensive Model Design

## Overview
This document presents the complete Enhanced [`NutritionEMRModel`](lib/shared/models/nutrition_emr_model.dart:1) using Freezed package for immutability and type safety.

## Model Design Philosophy

### Key Features
1. **Freezed Integration**: Immutable data classes with copyWith, equality, and toString
2. **Complete Medical Coverage**: All 8 sections with detailed fields
3. **Smart Visit Handling**: Separate flows for initial vs follow-up visits
4. **Audit Trail**: Complete change tracking with timestamps
5. **Type Safety**: Strong typing for all medical data points
6. **Null Safety**: Proper nullable fields with sensible defaults

### Database Integration
- Uses `databaseId: 'elajtech'` as per project rules
- JSON serialization with `json_serializable`
- Firestore collection: `nutrition_emrs`
- Follows existing pattern from [`PhysiotherapyEMRModel`](lib/shared/models/physiotherapy_emr_model.dart:1)

---

## Complete Dart Code

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_emr_model.freezed.dart';
part 'nutrition_emr_model.g.dart';

/// Enhanced Nutrition EMR Model for Nutrition & Obesity Therapy Clinic
/// Implements comprehensive medical data collection with Freezed immutability
/// 
/// This model supports:
/// - Initial Visit: Full 8-step wizard data collection
/// - Follow-up Visits: Streamlined tab-based updates
/// - Smart Record Locking: 24-hour modification window
/// - Audit Trail: Complete change tracking
@freezed
class NutritionEMRModel with _$NutritionEMRModel {
  const factory NutritionEMRModel({
    /// Core Identification Fields
    required String id,
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String appointmentId,
    required DateTime createdAt,
    DateTime? lastModifiedAt,
    String? lastModifiedBy,
    
    /// Visit Type Tracking
    @Default(true) bool isInitialVisit,
    @Default(false) bool isLocked,
    
    /// Specialization
    @Default('عيادة السمنة والتغذية العلاجية') String specialization,
    
    /// ==========================================
    /// SECTION 1: Anthropometric Measurements
    /// ==========================================
    /// Physical measurements and body composition analysis
    
    // Height Data
    double? heightCm,
    @Default('Measured') String heightMethod, // Measured, Self-reported, Estimated
    
    // Weight Data
    double? weightKg,
    double? previousWeightKg,
    @Default('Measured') String weightMethod,
    double? weightChange, // Calculated field
    
    // Body Mass Index
    double? bmi,
    String? bmiClassification, // Underweight, Normal, Overweight, Obese Class I/II/III
    
    // Circumference Measurements
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    double? waistToHipRatio,
    String? waistRiskLevel, // Normal, Increased Risk, High Risk
    
    // Body Composition (via BIA or other methods)
    double? bodyFatPercentage,
    double? muscleMassKg,
    double? visceralFatLevel,
    double? boneMassKg,
    double? bodyWaterPercentage,
    String? bodyCompositionStatus, // Normal, Increased Body Fat, Decreased Muscle Mass, Edema
    
    // Additional Measurements
    double? neckCircumferenceCm,
    double? midUpperArmCircumferenceCm,
    double? calfCircumferenceCm,
    
    /// ==========================================
    /// SECTION 2: Medical History
    /// ==========================================
    /// Comprehensive past and current medical conditions
    
    // Chronic Diseases
    List<String>? chronicDiseases, // Type 2 Diabetes, Type 1 Diabetes, Hypertension, etc.
    String? diabetesType,
    double? diabetesDurationYears,
    
    // Cardiovascular
    List<String>? cardiovascularConditions, // CVD, Dyslipidemia, Metabolic Syndrome
    
    // Gastrointestinal
    List<String>? gastrointestinalConditions, // GERD, IBS, IBD, Celiac Disease
    
    // Endocrine
    List<String>? endocrineConditions, // Hypothyroidism, Hyperthyroidism, PCOS
    
    // Psychological
    List<String>? psychologicalConditions, // Depression, Anxiety, Eating Disorders
    
    // Surgical History
    List<String>? surgicalHistory, // Bariatric Surgery, GI Surgery, etc.
    DateTime? bariatricSurgeryDate,
    String? bariatricSurgeryType, // Gastric Bypass, Sleeve, Band, etc.
    
    // Allergies and Intolerances
    List<String>? foodAllergies, // Dairy, Gluten, Nuts, Shellfish, Eggs, Soy
    List<String>? foodIntolerances,
    List<String>? medicationAllergies,
    
    // Current Medications
    List<String>? currentMedications,
    List<String>? supplements,
    List<String>? herbalProducts,
    
    // Family History
    List<String>? familyHistory, // Obesity, Diabetes, CVD, etc.
    
    /// ==========================================
    /// SECTION 3: Dietary Recall (24-hour & Habitual)
    /// ==========================================
    /// Food intake patterns and eating behaviors
    
    // Dietary Pattern
    String? dietaryPattern, // Regular, Vegetarian, Vegan, Mediterranean, Low Carb, Keto
    String? dietaryPatternOther,
    
    // Meal Frequency & Timing
    String? mealFrequency, // 1-2 meals/day, 3 meals/day, 4-5 meals/day, 6+ meals/day, Grazing
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    int? snacksPerDay,
    
    // Food Preferences
    List<String>? foodPreferences, // High Protein, Low Fat, Low Sugar, Low Sodium
    List<String>? dislikedFoods,
    List<String>? culturalDietaryRestrictions,
    
    // Portion Sizes
    String? portionSizePerception, // Small, Medium, Large, Very Large
    @Default(false) bool usesPortionControl,
    
    // Fluid Intake (ml/day)
    double? waterIntakeMl,
    double? sugaryBeveragesMl,
    double? alcoholMl,
    double? caffeineMg,
    double? juicesMl,
    
    // Eating Behaviors
    List<String>? eatingBehaviors, // Emotional Eating, Binge Eating, Night Eating
    @Default(false) bool eatsOutFrequently,
    int? restaurantMealsPerWeek,
    int? fastFoodMealsPerWeek,
    
    // Food Preparation
    String? primaryCook, // Self, Family Member, Other
    List<String>? cookingMethods, // Frying, Baking, Grilling, Steaming
    @Default(false) bool usesProcessedFoods,
    
    /// 24-Hour Dietary Recall (structured text or JSON)
    String? breakfast24h,
    String? morningSnack24h,
    String? lunch24h,
    String? afternoonSnack24h,
    String? dinner24h,
    String? eveningSnack24h,
    
    /// ==========================================
    /// SECTION 4: Nutritional Assessment
    /// ==========================================
    /// Calculated nutritional requirements and status
    
    // Activity Level
    String? activityLevel, // Sedentary, Lightly Active, Moderately Active, Very Active
    double? physicalActivityMinutesPerWeek,
    List<String>? exerciseTypes, // Aerobic, Resistance, Walking, Swimming, Yoga
    
    // Metabolic Calculations
    double? basalMetabolicRate, // BMR in kcal/day
    double? totalDailyEnergyExpenditure, // TDEE in kcal/day
    double? targetCalories, // Goal calories for weight loss/gain/maintenance
    
    // Macronutrient Distribution (in grams/day or %)
    double? targetProteinG,
    double? targetCarbohydrateG,
    double? targetFatG,
    double? targetFiberG,
    
    // Micronutrient Needs (if specific deficiencies)
    double? targetVitaminDIU,
    double? targetIronMg,
    double? targetCalciumMg,
    
    // Current Intake Assessment
    double? estimatedCurrentCalories,
    String? proteinIntakeStatus, // Excessive, Adequate, Inadequate
    String? carbohydrateIntakeStatus,
    String? fatIntakeStatus,
    String? fiberIntakeStatus,
    
    // Hydration
    String? hydrationStatus, // Well-hydrated, Mildly/Moderately/Severely Dehydrated
    
    /// ==========================================
    /// SECTION 5: Lifestyle Evaluation
    /// ==========================================
    /// Non-dietary factors affecting nutrition
    
    // Sleep
    double? averageSleepHours,
    String? sleepQuality, // Excellent, Good, Fair, Poor
    @Default(false) bool hasSleepDisorders,
    List<String>? sleepDisorders, // Insomnia, Sleep Apnea, etc.
    
    // Stress
    String? stressLevel, // Low, Moderate, High, Very High
    List<String>? stressManagementTechniques,
    
    // Smoking & Alcohol
    String? smokingStatus, // Never, Former, Current
    int? cigarettesPerDay,
    String? alcoholConsumption, // None, Occasional, Moderate, Heavy
    int? alcoholDrinksPerWeek,
    
    // Social & Economic
    String? occupationType, // Desk Job, Physical Job, Student, Retired
    String? eatingEnvironment, // Alone, With Family, With Friends
    String? foodAccessibility, // Easy Access, Limited Access, Financial Constraints
    
    /// ==========================================
    /// SECTION 6: Clinical Examination
    /// ==========================================
    /// Physical examination findings
    
    // Vital Signs
    double? systolicBP,
    double? diastolicBP,
    double? heartRateBpm,
    double? respiratoryRateBpm,
    double? temperatureCelsius,
    double? oxygenSaturationPercent,
    
    // General Appearance
    String? generalAppearance, // Well-nourished, Undernourished, Overweight, Obese, Cachectic
    
    // Skin Examination
    String? skinCondition, // Normal, Dry, Pale, Jaundiced, Petechiae
    @Default(false) bool hasEdema,
    String? edemaLocation,
    
    // Hair & Nails
    String? hairCondition, // Normal, Dry, Brittle, Thinning
    String? nailCondition, // Normal, Brittle, Spoon-shaped, Clubbed
    
    // Oral Cavity
    String? oralCavityCondition, // Normal, Dental Caries, Gingivitis, Oral Thrush
    
    // Abdominal Examination
    String? abdominalExam, // Normal, Distended, Tender, Mass
    String? abdominalExamNotes,
    
    // Nutritional Deficiency Signs
    List<String>? deficiencySigns, // Pallor, Angular Cheilitis, Glossitis, etc.
    
    /// ==========================================
    /// SECTION 7: Treatment Goals
    /// ==========================================
    /// Short-term and long-term objectives
    
    // Weight Goals
    double? targetWeightKg,
    double? weightToLoseOrGainKg,
    String? weightGoalTimeframe, // 1 month, 3 months, 6 months, 1 year
    double? weeklyWeightGoalKg, // Realistic weekly target
    
    // Body Composition Goals
    double? targetBodyFatPercentage,
    double? targetMuscleMassKg,
    
    // Health Goals
    List<String>? healthGoals, // Reduce HbA1c, Lower BP, Improve Lipid Profile
    String? primaryHealthGoal,
    
    // Behavioral Goals
    List<String>? behavioralGoals, // Meal Planning, Portion Control, Mindful Eating
    
    // Timeline
    DateTime? shortTermGoalDeadline, // 1-3 months
    DateTime? longTermGoalDeadline, // 6-12 months
    
    // Success Indicators
    List<String>? successIndicators, // Weight Loss, Improved Labs, Better Energy
    
    /// ==========================================
    /// SECTION 8: Progress Notes
    /// ==========================================
    /// Clinical notes, recommendations, and follow-up plan
    
    // Visit Summary
    String? chiefComplaint,
    String? presentIllnessHistory,
    String? visitPurpose, // Initial Assessment, Follow-up, Complication Management
    
    // Nutrition Diagnosis (ADIME format)
    String? nutritionDiagnosis, // Using PES statement format
    List<String>? nutritionDiagnosisCodes, // NCP codes if applicable
    
    // Clinical Impressions
    String? clinicalImpression,
    String? nutritionRiskLevel, // Low, Moderate, High, Very High Risk
    
    // Intervention Plan
    List<String>? dietaryModifications, // Calorie Restriction, Portion Control, etc.
    List<String>? macronutrientAdjustments,
    List<String>? supplementationPlan,
    List<String>? physicalActivityPlan,
    List<String>? behavioralTherapy,
    List<String>? educationTopics, // Label Reading, Healthy Cooking, etc.
   
    // Recommendations
    String? dietaryRecommendations,
    String? lifestyleRecommendations,
    String? supplementRecommendations,
    
    // Follow-up Plan
    String? followUpFrequency, // Weekly, Bi-weekly, Monthly, Quarterly
    DateTime? nextAppointmentDate,
    List<String>? followUpObjectives,
    
    // Lab Work Ordered
    List<String>? labTestsOrdered,
    
    // Referrals
    List<String>? referrals, // To Endocrinologist, Psychologist, etc.
    
    // Additional Notes
    String? additionalNotes,
    String? doctorNotes,
    
    /// ==========================================
    /// Biochemical Data Review (Lab Results)
    /// ==========================================
    /// Recent lab results reviewed during visit
    
    // Complete Blood Count
    double? hemoglobinGdL,
    double? hematocritPercent,
    double? wbcCount,
    double? plateletCount,
    
    // Metabolic Panel
    double? fastingGlucoseMgdL,
    double? randomGlucoseMgdL,
    double? hba1cPercent,
    double? insulinMuUmL,
    
    // Lipid Profile
    double? totalCholesterolMgdL,
    double? ldlMgdL,
    double? hdlMgdL,
    double? triglyceridesMgdL,
    
    // Liver Function
    double? altUL,
    double? astUL,
    double? alpUL,
    double? bilirubinMgdL,
    double? albuminGdL,
    
    // Kidney Function
    double? creatinineMgdL,
    double? bunMgdL,
    double? egfrMlMin,
    
    // Thyroid Function
    double? tshMuL,
    double? freeT4NgdL,
    double? freeT3PgmL,
    
    // Vitamins & Minerals
    double? vitaminDNgmL,
    double? vitaminB12PgmL,
    double? folatengmL,
    double? ironUgdL,
    double? ferritinNgmL,
    
    // Lab Review Date
    DateTime? labReviewDate,
    String? labInterpretation,
    
    /// ==========================================
    /// Audit & Compliance
    /// ==========================================
    
    // Change Log
    List<ChangeLogEntry>? changeLog,
    
    // Compliance Tracking
    @Default(false) bool patientConsentObtained,
    DateTime? consentDate,
    
    // Data Completeness
    double? dataCompletenessPercentage, // 0-100%
    List<String>? missingDataFields,
  }) = _NutritionEMRModel;

  factory NutritionEMRModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionEMRModelFromJson(json);
}

/// Change Log Entry for Audit Trail
@freezed
class ChangeLogEntry with _$ChangeLogEntry {
  const factory ChangeLogEntry({
    required DateTime timestamp,
    required String userId,
    required String userName,
    required String action, // Created, Updated, Viewed
    String? fieldChanged,
    String? previousValue,
    String? newValue,
    String? notes,
  }) = _ChangeLogEntry;

  factory ChangeLogEntry.fromJson(Map<String, dynamic> json) =>
      _$ChangeLogEntryFromJson(json);
}
```

---

## Field Grouping Analysis

### Section 1: Anthropometric Measurements (20 fields)
- Height: 2 fields (value + method)
- Weight: 4 fields (current, previous, method, change)
- BMI: 2 fields (value + classification)
- Circumferences: 6 fields (waist, hip, WHR, risk level, neck, arm, calf)
- Body Composition: 6 fields (fat%, muscle mass, visceral fat, bone mass, water%, status)

### Section 2: Medical History (18 fields)
- Diseases: 5 lists (chronic, cardiovascular, GI, endocrine, psychological)
- Diabetes: 2 fields (type, duration)
- Surgery: 3 fields (history list, bariatric date, bariatric type)
- Allergies: 3 lists (food allergies, intolerances, medication allergies)
- Medications: 3 lists (medications, supplements, herbals)
- Family: 1 list

### Section 3: Dietary Recall (27 fields)
- Pattern: 2 fields (main pattern + other)
- Timing: 5 fields (frequency + meal times + snacks)
- Preferences: 3 lists (preferences, dislikes, restrictions)
- Portions: 2 fields (perception + control boolean)
- Fluids: 5 fields (water, sugary drinks, alcohol, caffeine, juices)
- Behaviors: 4 fields (behaviors list + dining out frequency)
- Preparation: 3 fields (cook, methods, processed foods)
- 24h Recall: 6 fields (each meal/snack)

### Section 4: Nutritional Assessment (22 fields)
- Activity: 3 fields (level + minutes + types)
- Metabolism: 3 fields (BMR, TDEE, target calories)
- Macros: 4 fields (protein, carbs, fat, fiber targets)
- Micros: 3 fields (vitamin D, iron, calcium targets)
- Current Intake: 5 fields (estimated calories + statuses)
- Hydration: 1 field

### Section 5: Lifestyle Evaluation (16 fields)
- Sleep: 4 fields (hours, quality, has disorders, disorders list)
- Stress: 2 fields (level + management techniques)
- Substance: 4 fields (smoking status, cigarettes, alcohol consumption, drinks/week)
- Social: 3 fields (occupation, eating environment, food accessibility)

### Section 6: Clinical Examination (17 fields)
- Vitals: 6 fields (BP, HR, RR, temp, O2 sat)
- Appearance: 1 field
- Skin: 3 fields (condition, has edema, edema location)
- Hair/Nails: 2 fields
- Oral: 1 field
- Abdomen: 2 fields (exam + notes)
- Deficiency: 1 list

### Section 7: Treatment Goals (13 fields)
- Weight: 4 fields (target, to lose/gain, timeframe, weekly goal)
- Body Comp: 2 fields (target fat%, target muscle mass)
- Health: 2 fields (goals list + primary goal)
- Behavioral: 1 list
- Timeline: 2 fields (short-term, long-term deadlines)
- Success: 1 list

### Section 8: Progress Notes (24 fields)
- Visit: 3 fields (chief complaint, history, purpose)
- Diagnosis: 3 fields (nutrition diagnosis, codes, risk level)
- Clinical: 1 field (impression)
- Intervention: 6 lists (dietary, macros, supplements, activity, behavior, education)
- Recommendations: 3 fields (dietary, lifestyle, supplements)
- Follow-up: 3 fields (frequency, next date, objectives)
- Other: 3 fields (labs ordered, referrals, additional notes + doctor notes)

### Biochemical Data (21 fields)
- CBC: 4 fields
- Metabolic: 4 fields
- Lipids: 4 fields
- Liver: 5 fields
- Kidney: 3 fields
- Thyroid: 3 fields
- Vitamins: 5 fields
- Review: 2 fields (date + interpretation)

### Audit & Compliance (6 fields)
- Change log, consent (2 fields), data completeness (2 fields)

---

## Total Field Count
- Core fields: 11
- Section 1: 20
- Section 2: 18
- Section 3: 27
- Section 4: 22
- Section 5: 16
- Section 6: 17
- Section 7: 13
- Section 8: 24
- Biochemical: 21
- Audit: 6

**Grand Total: 195 fields** covering comprehensive nutrition clinical documentation

---

## Comparison with Current Model

### Current Model (8 fields):
```dart
final Map<String, List<String>> patientVisitBasics;
final Map<String, List<String>> anthropometrics;
final Map<String, List<String>> dietaryIntake;
final Map<String, List<String>> medicalConditions;
final Map<String, List<String>> physicalFindings;
final Map<String, List<String>> biochemicalData;
final Map<String, List<String>> nutritionDiagnosis;
final Map<String, List<String>> interventionPlan;
```

### Issues with Current Model:
1. ❌ Not using Freezed - no immutability
2. ❌ All data stored as `Map<String, List<String>>` - weak typing
3. ❌ No structured fields for calculations (BMI, BMR, TDEE)
4. ❌ No audit trail
5. ❌ No visit type differentiation
6. ❌ No locking mechanism
7. ❌ Difficult to query specific fields
8. ❌ No validation support

### Enhanced Model Benefits:
1. ✅ Freezed integration with immutability
2. ✅ Strong typing for all medical data
3. ✅ Calculated fields support
4. ✅ Complete audit trail with `ChangeLogEntry`
5. ✅ Visit type tracking (`isInitialVisit`)
6. ✅ Record locking (`isLocked`)
7. ✅ Easy Firestore queries on specific fields
8. ✅ Built-in validation capabilities

---

## Migration Strategy

### Option 1: Complete Replacement
- Replace current model entirely
- Migrate existing data with transformation script
- Most powerful but requires data migration

### Option 2: Hybrid Approach
- Keep `Map<String, List<String>>` fields for compatibility
- Add new structured fields alongside
- Gradual migration path
- Both old and new data structures coexist

### Recommendation: **Option 1** for long-term maintainability

---

## Next Steps

After model approval:
1. Generate Freezed files via `build_runner`
2. Update [`NutritionEMRRepository`](lib/features/emr/data/repositories/nutrition_emr_repository_impl.dart:1) implementation
3. Create UI components for 8-step Wizard
4. Create UI components for tabbed follow-up view
5. Implement locking logic
6. Add audit trail tracking
