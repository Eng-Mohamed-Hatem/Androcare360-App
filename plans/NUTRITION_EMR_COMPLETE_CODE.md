// ignore_for_file: all  
// ignore_for_file: all
# 💻 Nutrition EMR - Complete Source Code
## الكود الكامل للنموذج المبسط

---

## 📦 Entity Layer Code

### File: `lib/features/nutrition/domain/entities/nutrition_emr_entity.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_emr_entity.freezed.dart';
part 'nutrition_emr_entity.g.dart';

/// Simplified Nutrition EMR Entity
/// 
/// Contains 32 checkbox fields across 8 sections for rapid clinical data entry.
/// Follows Clean Architecture principles with complete immutability via Freezed.
/// 
/// **Database:** elajtech
/// **Collection:** nutrition_emrs
/// **Security:** 24-hour edit window with automatic locking
@freezed
class NutritionEMREntity with _$NutritionEMREntity {
  const factory NutritionEMREntity({
    /// Unique EMR identifier (UUID v4)
    required String id,
    
    /// Patient identifier from patients collection
    required String patientId,
    
    /// Doctor identifier from users collection
    required String doctorId,
    
    /// Doctor's full name for audit trail
    required String doctorName,
    
    /// Appointment identifier for linking and security rules
    required String appointmentId,
    
    /// Visit date and time (from appointment)
    required DateTime visitDate,
    
    /// Record creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🔐 SECURITY & STATUS FIELDS
    // ═══════════════════════════════════════════════════════════════════════
    
    /// Lock status - prevents editing after 24 hours
    @Default(false) bool isLocked,
    
    /// Determines UI mode: Wizard (true) or Tabs (false)
    @Default(true) bool isFirstVisit,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 📋 SECTION 1: PATIENT & VISIT BASICS (4 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'identityVerified') bool identityVerified,
    @Default(false) @JsonKey(name: 'consentObtained') bool consentObtained,
    @Default(false) @JsonKey(name: 'reasonForVisit') bool reasonForVisit,
    @Default(false) @JsonKey(name: 'diagnosisReviewed') bool diagnosisReviewed,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 📏 SECTION 2: ANTHROPOMETRICS (5 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'weightRecorded') bool weightRecorded,
    @Default(false) @JsonKey(name: 'heightRecorded') bool heightRecorded,
    @Default(false) @JsonKey(name: 'bmiCalculated') bool bmiCalculated,
    @Default(false) @JsonKey(name: 'waistCircumference') bool waistCircumference,
    @Default(false) @JsonKey(name: 'recentWeightChange') bool recentWeightChange,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🍽️ SECTION 3: DIETARY INTAKE ASSESSMENT (4 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'hour24Recall') bool hour24Recall,
    @Default(false) @JsonKey(name: 'foodFrequency') bool foodFrequency,
    @Default(false) @JsonKey(name: 'allergiesIntolerances') bool allergiesIntolerances,
    @Default(false) @JsonKey(name: 'supplementsReviewed') bool supplementsReviewed,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🏥 SECTION 4: MEDICAL CONDITIONS (6 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'diabetesScreened') bool diabetesScreened,
    @Default(false) @JsonKey(name: 'hypertensionScreened') bool hypertensionScreened,
    @Default(false) @JsonKey(name: 'dyslipidemiaScreened') bool dyslipidemiaScreened,
    @Default(false) @JsonKey(name: 'obesityAssessed') bool obesityAssessed,
    @Default(false) @JsonKey(name: 'ckdScreened') bool ckdScreened,
    @Default(false) @JsonKey(name: 'giDisordersReviewed') bool giDisordersReviewed,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🔍 SECTION 5: NUTRITION FOCUSED PHYSICAL FINDINGS (5 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'muscleLossAssessed') bool muscleLossAssessed,
    @Default(false) @JsonKey(name: 'fatLossAssessed') bool fatLossAssessed,
    @Default(false) @JsonKey(name: 'edemaChecked') bool edemaChecked,
    @Default(false) @JsonKey(name: 'appetiteAssessed') bool appetiteAssessed,
    @Default(false) @JsonKey(name: 'chewingSwallowingIssues') bool chewingSwallowingIssues,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🧪 SECTION 6: BIOCHEMICAL DATA REVIEWED (5 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @ Default(false) @JsonKey(name: 'glucoseA1cReviewed') bool glucoseA1cReviewed,
    @Default(false) @JsonKey(name: 'lipidProfileReviewed') bool lipidProfileReviewed,
    @Default(false) @JsonKey(name: 'electrolytesReviewed') bool electrolytesReviewed,
    @Default(false) @JsonKey(name: 'renalFunctionReviewed') bool renalFunctionReviewed,
    @Default(false) @JsonKey(name: 'micronutrientsReviewed') bool micronutrientsReviewed,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🎯 SECTION 7: NUTRITION DIAGNOSIS (3 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'inadequateIntake') bool inadequateIntake,
    @Default(false) @JsonKey(name: 'excessiveIntake') bool excessiveIntake,
    @Default(false) @JsonKey(name: 'knowledgeDeficit') bool knowledgeDeficit,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 💊 SECTION 8: INTERVENTION PLAN (4 checkboxes)
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default(false) @JsonKey(name: 'caloriePrescription') bool caloriePrescription,
    @Default(false) @JsonKey(name: 'macroDistribution') bool macroDistribution,
    @Default(false) @JsonKey(name: 'educationProvided') bool educationProvided,
    @Default(false) @JsonKey(name: 'followUpPlan') bool followUpPlan,
    
    // ═══════════════════════════════════════════════════════════════════════
    // 📊 METADATA
    // ═══════════════════════════════════════════════════════════════════════
    
    @Default('عيادة السمنة والتغذية العلاجية') String specialization,
    @Default([]) List<AuditLogEntry> auditLog,
  }) = _NutritionEMREntity;
  
  const NutritionEMREntity._();
  
  factory NutritionEMREntity.fromJson(Map<String, dynamic> json) =>
      _$NutritionEMREntityFromJson(json);
  
  /// Calculate overall completion percentage
  double get completionPercentage {
    const totalFields = 32;
    int completedFields = 0;
    
    if (identityVerified) completedFields++;
    if (consentObtained) completedFields++;
    if (reasonForVisit) completedFields++;
    if (diagnosisReviewed) completedFields++;
    if (weightRecorded) completedFields++;
    if (heightRecorded) completedFields++;
    if (bmiCalculated) completedFields++;
    if (waistCircumference) completedFields++;
    if (recentWeightChange) completedFields++;
    if (hour24Recall) completedFields++;
    if (foodFrequency) completedFields++;
    if (allergiesIntolerances) completedFields++;
    if (supplementsReviewed) completedFields++;
    if (diabetesScreened) completedFields++;
    if (hypertensionScreened) completedFields++;
    if (dyslipidemiaScreened) completedFields++;
    if (obesityAssessed) completedFields++;
    if (ckdScreened) completedFields++;
    if (giDisordersReviewed) completedFields++;
    if (muscleLossAssessed) completedFields++;
    if (fatLossAssessed) completedFields++;
    if (edemaChecked) completedFields++;
    if (appetiteAssessed) completedFields++;
    if (chewingSwallowingIssues) completedFields++;
    if (glucoseA1cReviewed) completedFields++;
    if (lipidProfileReviewed) completedFields++;
    if (electrolytesReviewed) completedFields++;
    if (renalFunctionReviewed) completedFields++;
    if (micronutrientsReviewed) completedFields++;
    if (inadequateIntake) completedFields++;
    if (excessiveIntake) completedFields++;
    if (knowledgeDeficit) completedFields++;
    if (caloriePrescription) completedFields++;
    if (macroDistribution) completedFields++;
    if (educationProvided) completedFields++;
    if (followUpPlan) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }
  
  /// Check if section is complete
  bool isSectionComplete(int sectionNumber) {
    switch (sectionNumber) {
      case 1:
        return identityVerified && consentObtained && 
               reasonForVisit && diagnosisReviewed;
      case 2:
        return weightRecorded && heightRecorded && bmiCalculated &&
               waistCircumference && recentWeightChange;
      case 3:
        return hour24Recall && foodFrequency && 
               allergiesIntolerances && supplementsReviewed;
      case 4:
        return diabetesScreened && hypertensionScreened && 
               dyslipidemiaScreened && obesityAssessed &&
               ckdScreened && giDisordersReviewed;
      case 5:
        return muscleLossAssessed && fatLossAssessed && edemaChecked &&
               appetiteAssessed && chewingSwallowingIssues;
      case 6:
        return glucoseA1cReviewed && lipidProfileReviewed &&
               electrolytesReviewed && renalFunctionReviewed &&
               micronutrientsReviewed;
      case 7:
        return inadequateIntake || excessiveIntake || knowledgeDeficit;
      case 8:
        return caloriePrescription && macroDistribution &&
               educationProvided && followUpPlan;
      default:
        return false;
    }
  }
}

/// Audit log entry
@freezed
class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required DateTime timestamp,
    required String userId,
    required String userName,
    required String action,
    required String fieldChanged,
    required String previousValue,
    required String newValue,
  }) = _AuditLogEntry;
  
  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}
```

---

## 🔄 Data Layer Code

### File: `lib/features/nutrition/data/models/nutrition_emr_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:flutter/foundation.dart';

/// Firestore Model Adapter for Nutrition EMR
class NutritionEMRModel {
  /// Convert Entity to Firestore Document
  static Map<String, dynamic> toFirestore(NutritionEMREntity entity) {
    return {
      'id': entity.id,
      'patientId': entity.patientId,
      'doctorId': entity.doctorId,
      'doctorName': entity.doctorName,
      'appointmentId': entity.appointmentId,
      'visitDate': Timestamp.fromDate(entity.visitDate),
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
      'isLocked': entity.isLocked,
      'isFirstVisit': entity.isFirstVisit,
      'identityVerified': entity.identityVerified,
      'consentObtained': entity.consentObtained,
      'reasonForVisit': entity.reasonForVisit,
      'diagnosisReviewed': entity.diagnosisReviewed,
      'weightRecorded': entity.weightRecorded,
      'heightRecorded': entity.heightRecorded,
      'bmiCalculated': entity.bmiCalculated,
      'waistCircumference': entity.waistCircumference,
      'recentWeightChange': entity.recentWeightChange,
      'hour24Recall': entity.hour24Recall,
      'foodFrequency': entity.foodFrequency,
      'allergiesIntolerances': entity.allergiesIntolerances,
      'supplementsReviewed': entity.supplementsReviewed,
      'diabetesScreened': entity.diabetesScreened,
      'hypertensionScreened': entity.hypertensionScreened,
      'dyslipidemiaScreened': entity.dyslipidemiaScreened,
      'obesityAssessed': entity.obesityAssessed,
      'ckdScreened': entity.ckdScreened,
      'giDisordersReviewed': entity.giDisordersReviewed,
      'muscleLossAssessed': entity.muscleLossAssessed,
      'fatLossAssessed': entity.fatLossAssessed,
      'edemaChecked': entity.edemaChecked,
      'appetiteAssessed': entity.appetiteAssessed,
      'chewingSwallowingIssues': entity.chewingSwallowingIssues,
      'glucoseA1cReviewed': entity.glucoseA1cReviewed,
      'lipidProfileReviewed': entity.lipidProfileReviewed,
      'electrolytesReviewed': entity.electrolytesReviewed,
      'renalFunctionReviewed': entity.renalFunctionReviewed,
      'micronutrientsReviewed': entity.micronutrientsReviewed,
      'inadequateIntake': entity.inadequateIntake,
      'excessiveIntake': entity.excessiveIntake,
      'knowledgeDeficit': entity.knowledgeDeficit,
      'caloriePrescription': entity.caloriePrescription,
      'macroDistribution': entity.macroDistribution,
      'educationProvided': entity.educationProvided,
      'followUpPlan': entity.followUpPlan,
      'specialization': entity.specialization,
      'auditLog': entity.auditLog.map((e) => e.toJson()).toList(),
    };
  }
  
  /// Convert Firestore Document to Entity
  static NutritionEMREntity fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      if (kDebugMode) {
        debugPrint('📥 [NutritionEMRModel] Loading from Firestore: ${doc.id}');
      }
      
      final List<AuditLogEntry> auditLog = [];
      if (data['auditLog'] != null) {
        for (final log in data['auditLog'] as List<dynamic>) {
          auditLog.add(AuditLogEntry.fromJson(log as Map<String, dynamic>));
        }
      }
      
      return NutritionEMREntity(
        id: data['id'] as String,
        patientId: data['patientId'] as String,
        doctorId: data['doctorId'] as String,
        doctorName: data['doctorName'] as String,
        appointmentId: data['appointmentId'] as String,
        visitDate: (data['visitDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        isLocked: data['isLocked'] as bool? ?? false,
        isFirstVisit: data['isFirstVisit'] as bool? ?? false,
        identityVerified: data['identityVerified'] as bool? ?? false,
        consentObtained: data['consentObtained'] as bool? ?? false,
        reasonForVisit: data['reasonForVisit'] as bool? ?? false,
        diagnosisReviewed: data['diagnosisReviewed'] as bool? ?? false,
        weightRecorded: data['weightRecorded'] as bool? ?? false,
        heightRecorded: data['heightRecorded'] as bool? ?? false,
        bmiCalculated: data['bmiCalculated'] as bool? ?? false,
        waistCircumference: data['waistCircumference'] as bool? ?? false,
        recentWeightChange: data['recentWeightChange'] as bool? ?? false,
        hour24Recall: data['hour24Recall'] as bool? ?? false,
        foodFrequency: data['foodFrequency'] as bool? ?? false,
        allergiesIntolerances: data['allergiesIntolerances'] as bool? ?? false,
        supplementsReviewed: data['supplementsReviewed'] as bool? ?? false,
        diabetesScreened: data['diabetesScreened'] as bool? ?? false,
        hypertensionScreened: data['hypertensionScreened'] as bool? ?? false,
        dyslipidemiaScreened: data['dyslipidemiaScreened'] as bool? ?? false,
        obesityAssessed: data['obesityAssessed'] as bool? ?? false,
        ckdScreened: data['ckdScreened'] as bool? ?? false,
        giDisordersReviewed: data['giDisordersReviewed'] as bool? ?? false,
        muscleLossAssessed: data['muscleLossAssessed'] as bool? ?? false,
        fatLossAssessed: data['fatLossAssessed'] as bool? ?? false,
        edemaChecked: data['edemaChecked'] as bool? ?? false,
        appetiteAssessed: data['appetiteAssessed'] as bool? ?? false,
        chewingSwallowingIssues: data['chewingSwallowingIssues'] as bool? ?? false,
        glucoseA1cReviewed: data['glucoseA1cReviewed'] as bool? ?? false,
        lipidProfileReviewed: data['lipidProfileReviewed'] as bool? ?? false,
        electrolytesReviewed: data['electrolytesReviewed'] as bool? ?? false,
        renalFunctionReviewed: data['renalFunctionReviewed'] as bool? ?? false,
        micronutrientsReviewed: data['micronutrientsReviewed'] as bool? ?? false,
        inadequateIntake: data['inadequateIntake'] as bool? ?? false,
        excessiveIntake: data['excessiveIntake'] as bool? ?? false,
        knowledgeDeficit: data['knowledgeDeficit'] as bool? ?? false,
        caloriePrescription: data['caloriePrescription'] as bool? ?? false,
        macroDistribution: data['macroDistribution'] as bool? ?? false,
        educationProvided: data['educationProvided'] as bool? ?? false,
        followUpPlan: data['followUpPlan'] as bool? ?? false,
        specialization: data['specialization'] as String? ?? 
            'عيادة السمنة والتغذية العلاجية',
        auditLog: auditLog,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [NutritionEMRModel] Parsing error: $e');
        debugPrint('   StackTrace: $stackTrace');
      }
      rethrow;
    }
  }
}
```

---

## 🔧 Build Runner Commands

```bash
# Install dependencies
flutter pub get

# Generate Freezed files
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (optional - auto-generates on save)
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## ✅ Generated Files

After running build_runner, you will have:

1. `nutrition_emr_entity.freezed.dart` - Freezed code generation
2. `nutrition_emr_entity.g.dart` - JSON serialization
3. Auto-complete `copyWith` methods
4. Immutable data classes with equality

---

## 🎯 Usage Example

```dart
import 'package:uuid/uuid.dart';

// Create new EMR
final newEMR = NutritionEMREntity(
  id: const Uuid().v4(),
  patientId: 'patient_123',
  doctorId: 'doctor_456',
  doctorName: 'Dr. Ahmed Hassan',
  appointmentId: 'appt_789',
  visitDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  isFirstVisit: true,
);

// Update field (immutable - creates new instance)
final updatedEMR = newEMR.copyWith(
  identityVerified: true,
  consentObtained: true,
  updatedAt: DateTime.now(),
);

// Check completion
print('Overall: ${updatedEMR.completionPercentage.toStringAsFixed(1)}%');
print('Section 1: ${updatedEMR.isSectionComplete(1)}');

// Convert to/from JSON
final json = updatedEMR.toJson();
final fromJson = NutritionEMREntity.fromJson(json);

// Equality check (auto-generated by Freezed)
print(updatedEMR == fromJson); // true
```

---

## 📦 pubspec.yaml Dependencies

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  cloud_firestore: ^4.15.0
  uuid: ^4.2.0
  dartz: ^0.10.1

dev_dependencies:
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
```
