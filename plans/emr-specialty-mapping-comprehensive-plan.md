// ignore_for_file: all  
// ignore_for_file: all
# خطة شاملة: إصلاح عرض تبويبات EMR حسب التخصص الطبي
# Comprehensive Step-by-Step Plan for EMR Specialty Mapping Fix

**التاريخ:** 2026-01-18  
**المشروع:** Elajtech - Medical Center App  
**نوع المهمة:** Critical Bug Fix - Specialty Detection & Conditional UI Rendering  
**الأولوية:** 🔴 حرجة

---

## 📋 جدول المحتويات

1. [تحليل المشكلة الجذرية](#تحليل-المشكلة-الجذرية)
2. [المرحلة الأولى: تحليل البيانات ورسم الخرائط](#المرحلة-الأولى-تحليل-البيانات-ورسم-الخرائط)
3. [المرحلة الثانية: هندسة منطق الواجهات](#المرحلة-الثانية-هندسة-منطق-الواجهات)
4. [المرحلة الثالثة: ربط طبقات البيانات](#المرحلة-الثالثة-ربط-طبقات-البيانات)
5. [المرحلة الرابعة: التتبع والتحقق من الصحة](#المرحلة-الرابعة-التتبع-والتحقق-من-الصحة)
6. [خطة التنفيذ الكاملة](#خطة-التنفيذ-الكاملة)
7. [مقترحات المنع المستقبلي](#مقترحات-المنع-المستقبلي)

---

## 🔍 تحليل المشكلة الجذرية

### الأعراض المُلاحظة:
- تبويبات EMR الخاصة بالتغذية والعلاج الطبيعي **لا تظهر نهائياً** للأطباء
- الأسئلة المخصصة لكل تخصص غير مرئية
- فشل عملية الـ Specialty Detection

### السبب الجذري:

#### المشكلة الحالية في [`lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart:38-49):

```dart
// ❌ الكود الحالي - المشكلة
bool get _isPhysiotherapyDoctor {
  final user = ref.read(authProvider).user;
  return user?.specializations?.contains('عيادة العلاج الطبيعي والتأهيل') ?? false;
}

bool get _isNutritionDoctor {
  final user = ref.read(authProvider).user;
  return user?.specializations?.contains('عيادة السمنة والتغذية العلاجية') ?? false;
}
```

**لماذا يفشل:**
1. **String Matching Exact:** يتطلب تطابق **تام 100%** للنص
2. **Whitespace Sensitivity:** أي مسافة زائدة أو ناقصة = فشل
3. **Prefix/Suffix Variations:** "الـ" في البداية أو النهاية
4. **Database Variations:** قد تكون البيانات في Firestore مختلفة:
   - `"السمنة والتغذية العلاجية"` (بدون "عيادة")
   - `"عياده السمنة والتغذية"` (خطأ إملائي)
   - `"عيادة  السمنة"` (مسافتان)
   - `"عيادة الباطنة"` (نسخة مختصرة)

---

## 🗺️ المرحلة الأولى: تحليل البيانات ورسم الخرائط (Data Mapping Analysis)

### الهدف:
إنشاء نظام ثوابت شامل يمنع التكرار والأخطاء الإملائية ويدعم Fuzzy Matching.

---

### الخطوة 1.1: إنشاء ملف ثوابت التخصصات الطبية

**المسار:** `lib/core/constants/specialty_constants.dart`

```dart
/// Medical Specialty Constants
/// Contains all official specialty names used in Elajtech system
/// These MUST match the values stored in Firestore's user.specializations field
class SpecialtyConstants {
  SpecialtyConstants._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════════
  // PRIMARY SPECIALTY NAMES (المسميات الرسمية الكاملة)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Nutrition & Obesity Therapy Clinic
  /// Used in Firestore: user.specializations array
  static const String nutritionClinic = 'عيادة السمنة والتغذية العلاجية';
  
  /// Physiotherapy & Rehabilitation Clinic
  /// Used in Firestore: user.specializations array
  static const String physiotherapyClinic = 'عيادة العلاج الطبيعي والتأهيل';
  
  /// Internal Medicine & Family Medicine Clinic
  /// Used in Firestore: user.specializations array
  static const String internalMedicineClinic = 'عيادة الباطنة وطب الأسرة';
  
  /// Andrology, Infertility & Prostate Clinic
  /// Used in Firestore: user.specializations array
  static const String andrologyClinic = 'عيادة الذكورة والعقم والبروستات';
  
  /// Chronic Diseases Clinic
  /// Used in Firestore: user.specializations array
  static const String chronicDiseasesClinic = 'عيادة الأمراض المزمنة';

  // ═══════════════════════════════════════════════════════════════════
  // KEYWORD LISTS FOR FUZZY MATCHING (كلمات مفتاحية للبحث المرن)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Keywords that identify Nutrition/Obesity specialty
  /// Used for contains() matching to handle variations
  static const List<String> nutritionKeywords = [
    'تغذية',
    'سمنة',
    'nutrition',
    'obesity',
  ];
  
  /// Keywords that identify Physiotherapy specialty
  static const List<String> physiotherapyKeywords = [
    'علاج طبيعي',
    'تأهيل',
    'physiotherapy',
    'rehabilitation',
    'physical therapy',
  ];
  
  /// Keywords that identify Internal Medicine specialty
  static const List<String> internalMedicineKeywords = [
    'باطنة',
    'طب الأسرة',
    'internal medicine',
    'family medicine',
    'family practice',
  ];
  
  /// Keywords that identify Andrology specialty
  static const List<String> andrologyKeywords = [
    'ذكورة',
    'عقم',
    'بروستات',
    'andrology',
    'infertility',
    'prostate',
  ];

  // ═══════════════════════════════════════════════════════════════════
  // HELPER METHODS (دوال مساعدة)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Normalize Arabic text for comparison
  /// Removes extra whitespace, "ال" prefix, and converts to lowercase
  static String _normalizeArabicText(String text) {
    return text
        .trim() // Remove leading/trailing whitespace
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single
        .replaceAll('ال', '') // Remove "ال" prefix
        .replaceAll('ه', 'ة') // Normalize taa marbouta variations
        .toLowerCase(); // Convert to lowercase for case-insensitive matching
  }
  
  /// Check if a specialty string matches any keywords in the provided list
  /// Uses fuzzy matching with normalization
  static bool _matchesAnyKeyword(String specialty, List<String> keywords) {
    final normalized = _normalizeArabicText(specialty);
    return keywords.any((keyword) {
      final normalizedKeyword = _normalizeArabicText(keyword);
      return normalized.contains(normalizedKeyword);
    });
  }
  
  /// Check if user has Nutrition specialty
  /// Handles variations and typos in database
  static bool isNutritionDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) return false;
    
    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == nutritionClinic) return true;
      
      // Then, try fuzzy match with keywords
      return _matchesAnyKeyword(spec, nutritionKeywords);
    });
  }
  
  /// Check if user has Physiotherapy specialty
  /// Handles variations and typos in database
  static bool isPhysiotherapyDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) return false;
    
    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == physiotherapyClinic) return true;
      
      // Then, try fuzzy match with keywords
      return _matchesAnyKeyword(spec, physiotherapyKeywords);
    });
  }
  
  /// Check if user has Internal Medicine specialty
  /// Handles variations and typos in database
  static bool isInternalMedicineDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) return false;
    
    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == internalMedicineClinic) return true;
      
      // Then, try fuzzy match with keywords
      return _matchesAnyKeyword(spec, internalMedicineKeywords);
    });
  }
  
  /// Check if user has Andrology specialty
  /// Handles variations and typos in database
  static bool isAndrologyDoctor(List<String>? specializations) {
    if (specializations == null || specializations.isEmpty) return false;
    
    return specializations.any((spec) {
      // First, try exact match (fastest)
      if (spec == andrologyClinic) return true;
      
      // Then, try fuzzy match with keywords
      return _matchesAnyKeyword(spec, andrologyKeywords);
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // FIRESTORE COLLECTION PATHS (مسارات مجموعات Firestore)
  // ═══════════════════════════════════════════════════════════════════
  
  /// Firestore collection for Nutrition EMRs
  static const String nutritionEmrCollection = 'nutrition_emrs';
  
  /// Firestore collection for Physiotherapy EMRs
  static const String physiotherapyEmrCollection = 'physiotherapy_emrs';
  
  /// Firestore collection for Internal Medicine EMRs
  static const String internalMedicineEmrCollection = 'emr_records';
  
  /// Firestore collection for Andrology EMRs (default EMR)
  static const String andrologyEmrCollection = 'emr_records';
}
```

---

### الخطوة 1.2: تحديث ملف medical_specializations.dart

نحتاج تحديث `lib/core/constants/medical_specializations.dart` ليستخدم الثوابت الجديدة:

```dart
import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:flutter/material.dart';

/// Medical Specializations Hierarchy & Icons
/// Uses SpecialtyConstants for consistent naming
class MedicalSpecializations {
  // Use constants from SpecialtyConstants
  static const String andrologyClinic = SpecialtyConstants.andrologyClinic;
  static const String otherClinics = 'تخصصات أخرى';

  // Sub-specialties Hierarchy
  static const Map<String, List<String>> hierarchy = {
    andrologyClinic: [
      'طب الذكورة',
      'تأخر الإنجاب والعقم لدى الرجال',
      'صحة البروستات',
      'الأمراض الجنسية المعدية',
    ],
    otherClinics: [
      SpecialtyConstants.chronicDiseasesClinic,
      SpecialtyConstants.nutritionClinic,
      SpecialtyConstants.physiotherapyClinic,
      SpecialtyConstants.internalMedicineClinic,
    ],
  };

  // Icons Mapping (using the same constants)
  static const Map<String, IconData> icons = {
    // Main Categories
    andrologyClinic: Icons.male,
    otherClinics: Icons.medical_services,

    // Andrology Sub-specialties
    'طب الذكورة': Icons.health_and_safety,
    'تأخر الإنجاب والعقم لدى الرجال': Icons.child_friendly,
    'صحة البروستات': Icons.opacity,
    'الأمراض الجنسية المعدية': Icons.coronavirus,

    // Other Specialties (using SpecialtyConstants)
    SpecialtyConstants.chronicDiseasesClinic: Icons.monitor_heart,
    SpecialtyConstants.nutritionClinic: Icons.restaurant_menu,
    SpecialtyConstants.physiotherapyClinic: Icons.accessibility_new,
    SpecialtyConstants.internalMedicineClinic: Icons.family_restroom,
  };

  // Rest of the code remains the same...
  static IconData getIcon(String name) {
    return icons[name] ?? Icons.local_hospital;
  }

  static List<String> get mainCategories => hierarchy.keys.toList();

  static List<String> getSubSpecialties(String category) {
    return hierarchy[category] ?? [];
  }
}
```

---

### الخطوة 1.3: مزايا هذا النهج

#### ✅ **Single Source of Truth:**
- كل المسميات في مكان واحد
- سهولة التحديث والصيانة

#### ✅ **Fuzzy Matching:**
- يتعامل مع الاختلافات البسيطة
- يتجاهل المسافات الإضافية
- يتعامل مع "الـ" في البداية
- Normalization للنصوص العربية

#### ✅ **Type Safety:**
- استخدام `const` يمنع التعديل
- IDE autocomplete

#### ✅ **Performance:**
- Exact match أولاً (O(1))
- Fuzzy match ثانياً فقط عند الحاجة

#### ✅ **Maintainability:**
- إضافة تخصص جديد = إضافة constant واحد + keywords
- سهولة التوثيق

---

## 🏗️ المرحلة الثانية: هندسة منطق الواجهات (UI Logic Architecture)

### الهدف:
تعديل شاشات EMR لعرض التبويبات المناسبة بناءً على التخصص المُكتشف تلقائياً.

---

### الخطوة 2.1: تحديث AddEMRScreen

**الملف:** [`lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart)

#### التعديل 1: استيراد الثوابت الجديدة

```dart
// في بداية الملف
import 'package:elajtech/core/constants/specialty_constants.dart';
```

#### التعديل 2: تحديث دوال التحقق من التخصص

```dart
// ═══════════════════════════════════════════════════════════════════
// SPECIALTY DETECTION WITH FUZZY MATCHING
// ═══════════════════════════════════════════════════════════════════

// ✅ الكود الجديد - مع Fuzzy Matching والـ Logging
bool get _isPhysiotherapyDoctor {
  final user = ref.read(authProvider).user;
  final specializations = user?.specializations;
  
  // Debug logging
  debugPrint('🔍 [EMR] Checking Physiotherapy specialty...');
  debugPrint('   User specializations: ${specializations?.join(", ") ?? "null"}');
  
  final result = SpecialtyConstants.isPhysiotherapyDoctor(specializations);
  
  debugPrint('   ✅ Is Physiotherapy Doctor: $result');
  return result;
}

bool get _isNutritionDoctor {
  final user = ref.read(authProvider).user;
  final specializations = user?.specializations;
  
  // Debug logging
  debugPrint('🔍 [EMR] Checking Nutrition specialty...');
  debugPrint('   User specializations: ${specializations?.join(", ") ?? "null"}');
  
  final result = SpecialtyConstants.isNutritionDoctor(specializations);
  
  debugPrint('   ✅ Is Nutrition Doctor: $result');
  return result;
}

bool get _isInternalMedicineDoctor {
  final user = ref.read(authProvider).user;
  final specializations = user?.specializations;
  
  // Debug logging
  debugPrint('🔍 [EMR] Checking Internal Medicine specialty...');
  debugPrint('   User specializations: ${specializations?.join(", ") ?? "null"}');
  
  final result = SpecialtyConstants.isInternalMedicineDoctor(specializations);
  
  debugPrint('   ✅ Is Internal Medicine Doctor: $result');
  return result;
}
```

#### التعديل 3: إضافة Logging في initState

```dart
@override
void initState() {
  super.initState();
  
  // ═══════════════════════════════════════════════════════════════════
  // SPECIALTY DETECTION LOGGING (Debug Mode Only)
  // ═══════════════════════════════════════════════════════════════════
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      
      debugPrint('\n══════════════════════════════════════════════════════');
      debugPrint('📋 EMR Screen Initialized for Doctor:');
      debugPrint('   Doctor ID: ${user?.id ?? "null"}');
      debugPrint('   Doctor Name: ${user?.fullName ?? "null"}');
      debugPrint('   Specializations: ${user?.specializations?.join(", ") ?? "null"}');
      debugPrint('──────────────────────────────────────────────────────');
      debugPrint('🏥 Specialty Detection Results:');
      debugPrint('   Physiotherapy: $_isPhysiotherapyDoctor');
      debugPrint('   Nutrition: $_isNutritionDoctor');
      debugPrint('   Internal Medicine: $_isInternalMedicineDoctor');
      debugPrint('══════════════════════════════════════════════════════\n');
      
      // Warning if no specialty detected
      if (!_isPhysiotherapyDoctor && !_isNutritionDoctor && !_isInternalMedicineDoctor) {
        debugPrint('⚠️ WARNING: No specialty detected! EMR tabs may not display.');
        debugPrint('   Please check user.specializations in Firestore.');
      }
    });
  }
}
```

---

### الخطوة 2.2: تحديث Conditional Rendering في build()

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('إضافة سجل EMR')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ═══════════════════════════════════════════════════════════════
          // ANDROLOGY EMR FIELDS (Always visible for all doctors)
          // ═══════════════════════════════════════════════════════════════
          _buildSectionHeader('I. Sexual Function Assessment'),
          // ... (existing andrology fields)
          
          // ═══════════════════════════════════════════════════════════════
          // PHYSIOTHERAPY TAB (Conditional - Only for Physiotherapy Doctors)
          // ═══════════════════════════════════════════════════════════════
          if (_isPhysiotherapyDoctor) ...[
            const Divider(height: 48, thickness: 2),
            _buildSectionHeader('🏋️ Physiotherapy Assessment'),
            if (kDebugMode)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '✅ Physiotherapy questions visible',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            _buildPhysiotherapyTab(),
          ],
          
          // ═══════════════════════════════════════════════════════════════
          // NUTRITION TAB (Conditional - Only for Nutrition Doctors)
          // ═══════════════════════════════════════════════════════════════
          if (_isNutritionDoctor) ...[
            const Divider(height: 48, thickness: 2),
            _buildSectionHeader('🥗 Nutrition Assessment'),
            if (kDebugMode)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '✅ Nutrition questions visible',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            _buildNutritionTab(),
          ],
          
          // ═══════════════════════════════════════════════════════════════
          // DEBUG WARNING (Only in Debug Mode)
          // ═══════════════════════════════════════════════════════════════
          if (kDebugMode && !_isPhysiotherapyDoctor && !_isNutritionDoctor)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Developer Warning',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No specialty-specific tabs are displayed.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User specializations: ${ref.read(authProvider).user?.specializations?.join(", ") ?? "null"}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          
          // Save Button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ السجل', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    ),
  );
}
```

---

### الخطوة 2.3: Directionality للنصوص الإنجليزية

تأكد من أن `_buildPhysiotherapyTab()` و `_buildNutritionTab()` يستخدمان `Directionality`:

```dart
Widget _buildPhysiotherapyTab() {
  return Directionality(
    textDirection: TextDirection.ltr, // ✅ Force LTR for English content
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Physiotherapy Assessment'),
        // ... rest of the code
      ],
    ),
  );
}

Widget _buildNutritionTab() {
  return Directionality(
    textDirection: TextDirection.ltr, // ✅ Force LTR for English content
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Nutrition Assessment'),
        // ... rest of the code
      ],
    ),
  );
}
```

**ملاحظة مهمة:** التطبيق الأساسي RTL (عربي)، لكن داخل تبويبات Physiotherapy و Nutrition نستخدم LTR للأسئلة الإنجليزية.

---

### الخطوة 2.4: إنشاء شاشة AddInternalMedicineEMRScreen المُحسّنة

حالياً يوجد شاشة منفصلة للـ Internal Medicine. نحتاج تحديثها أيضاً:

**الملف:** [`lib/features/doctor/medical_records/presentation/screens/add_internal_medicine_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_internal_medicine_emr_screen.dart)

#### إضافة Debug Logging:

```dart
import 'package:flutter/foundation.dart'; // For kDebugMode

@override
void initState() {
  super.initState();
  _initializeControllers();
  
  // ═══════════════════════════════════════════════════════════════════
  // DEBUG LOGGING
  // ═══════════════════════════════════════════════════════════════════
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debug Print('\n══════════════════════════════════════════════════════');
      debugPrint('📋 Internal Medicine EMR Screen Initialized');
      debugPrint('   Patient ID: ${widget.patientId}');
      debugPrint('   Patient Name: ${widget.patientName}');
      debugPrint('   Appointment ID: ${widget.appointmentId}');
      debugPrint('══════════════════════════════════════════════════════\n');
    });
  }
}
```

---

## 🔌 المرحلة الثالثة: ربط طبقات البيانات (Repository Layer Injection)

### الهدف:
التأكد من أن كل تخصص يتصل بالـ Repository الصحيح ويستخدم `databaseId: 'elajtech'`.

---

### الخطوة 3.1: فحص الـ Repositories الحالية

#### 1. NutritionEMRRepository

**الملف:** [`lib/features/emr/data/repositories/nutrition_emr_repository_impl.dart`](lib/features/emr/data/repositories/nutrition_emr_repository_impl.dart)

تحقق من الكود الحالي - يجب أن يكون:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elajtech/core/constants/specialty_constants.dart';
// ...

@Injectable(as: NutritionEMRRepository)
class NutritionEMRRepositoryImpl implements NutritionEMRRepository {
  NutritionEMRRepositoryImpl(this._firestore); // ✅ Injected via GetIt
  
  final FirebaseFirestore _firestore; // ✅ Already uses 'elajtech' database
  
  @override
  Future<Either<Failure, void>> saveEMR(NutritionEMRModel emr) async {
    try {
      await _firestore
          .collection(SpecialtyConstants.nutritionEmrCollection) // ✅ Use constant
          .doc(emr.id)
          .set(emr.toJson());
      
      debugPrint('✅ [Repository] Nutrition EMR saved successfully: ${emr.id}');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error saving Nutrition EMR: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
  
  // ... other methods
}
```

#### 2. PhysiotherapyEMRRepository

**الملف:** [`lib/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart`](lib/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart)

نفس النهج:

```dart
@Injectable(as: PhysiotherapyEMRRepository)
class PhysiotherapyEMRRepositoryImpl implements PhysiotherapyEMRRepository {
  PhysiotherapyEMRRepositoryImpl(this._firestore);
  
  final FirebaseFirestore _firestore; // ✅ Already uses 'elajtech' database
  
  @override
  Future<Either<Failure, void>> saveEMR(PhysiotherapyEMRModel emr) async {
    try {
      await _firestore
          .collection(SpecialtyConstants.physiotherapyEmrCollection) // ✅ Use constant
          .doc(emr.id)
          .set(emr.toJson());
      
      debugPrint('✅ [Repository] Physiotherapy EMR saved successfully: ${emr.id}');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error saving Physiotherapy EMR: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

#### 3. InternalMedicineEMRRepository

**الملف:** [`lib/features/emr/data/repositories/internal_medicine_emr_repository_impl.dart`](lib/features/emr/data/repositories/internal_medicine_emr_repository_impl.dart)

```dart
@Injectable(as: InternalMedicineEMRRepository)
class InternalMedicineEMRRepositoryImpl implements InternalMedicineEMRRepository {
  InternalMedicineEMRRepositoryImpl(this._firestore);
  
  final FirebaseFirestore _firestore; // ✅ Already uses 'elajtech' database
  
  @override
  Future<Either<Failure, void>> saveEMR(InternalMedicineEMRModel emr) async {
    try {
      await _firestore
          .collection(SpecialtyConstants.internalMedicineEmrCollection) // ✅ Use constant
          .doc(emr.id)
          .set(emr.toJson());
      
      debugPrint('✅ [Repository] Internal Medicine EMR saved successfully: ${emr.id}');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error saving Internal Medicine EMR: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

---

### الخطوة 3.2: التحقق من Dependency Injection

**الملف:** `lib/core/di/injection_container.dart` (أو ملف GetIt configuration)

تأكد من تسجيل جميع الـ Repositories:

```dart
// ═══════════════════════════════════════════════════════════════════
// EMR REPOSITORIES (جميعها مُسجلة)
// ═══════════════════════════════════════════════════════════════════

// Automatically registered via @Injectable annotation:
// - EMRRepository -> EMRRepositoryImpl
// - NutritionEMRRepository -> NutritionEMRRepositoryImpl
// - PhysiotherapyEMRRepository -> PhysiotherapyEMRRepositoryImpl
// - InternalMedicineEMRRepository -> InternalMedicineEMRRepositoryImpl

// All inject FirebaseFirestore from FirebaseModule which uses 'elajtech' database
```

**تحقق من firebase_module.dart:**

```dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'elajtech', // ✅ Custom database ID
      );
}
```

---

### الخطوة 3.3: Error Handling Strategy

إضافة معالجة شاملة للأخطاء في `_save()` method:

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final user = ref.read(authProvider).user!;

    // ═══════════════════════════════════════════════════════════════
    // SAVE PHYSIOTHERAPY EMR
    // ═══════════════════════════════════════════════════════════════
    if (_isPhysiotherapyDoctor) {
      debugPrint('💾 [EMR] Saving Physiotherapy EMR...');
      
      final physioEMR = PhysiotherapyEMRModel(
        // ... fields
      );

      final physioResult = await GetIt.I<PhysiotherapyEMRRepository>().saveEMR(physioEMR);
      
      physioResult.fold(
        (failure) {
          debugPrint('❌ [EMR] Physiotherapy save failed: ${failure.message}');
          throw Exception('Physiotherapy: ${failure.message}');
        },
        (_) => debugPrint('✅ [EMR] Physiotherapy EMR saved successfully'),
      );
    }

    // ═══════════════════════════════════════════════════════════════
    // SAVE NUTRITION EMR
    // ═══════════════════════════════════════════════════════════════
    if (_isNutritionDoctor) {
      debugPrint('💾 [EMR] Saving Nutrition EMR...');
      
      final nutritionEMR = NutritionEMRModel(
        // ... fields
      );

      final nutritionResult = await GetIt.I<NutritionEMRRepository>().saveEMR(nutritionEMR);
      
      nutritionResult.fold(
        (failure) {
          debugPrint('❌ [EMR] Nutrition save failed: ${failure.message}');
          throw Exception('Nutrition: ${failure.message}');
        },
        (_) => debugPrint('✅ [EMR] Nutrition EMR saved successfully'),
      );
    }

    // ═══════════════════════════════════════════════════════════════
    // SUCCESS
    // ═══════════════════════════════════════════════════════════════
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ السجل بنجاح')),
      );
    }
  } on FirebaseException catch (e) {
    debugPrint('❌ [EMR] Firebase error: ${e.code} - ${e.message}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ Firebase: ${e.message}')),
      );
    }
  } on Exception catch (e) {
    debugPrint('❌ [EMR] General error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 🔬 المرحلة الرابعة: التتبع والتحقق من الصحة (Logging, Validation & Debugging)

### الهدف:
إنشاء نظام debug logging شامل واختبارات للتحقق من صحة العمل.

---

### الخطوة 4.1: Debug Logging Levels

إنشاء enum لمستويات الـ Logging:

**الملف:** `lib/core/utils/debug_logger.dart` (اختياري - تحسين إضافي)

```dart
import 'package:flutter/foundation.dart';

/// Debug Logger Utility for EMR Module
/// Only logs in Debug mode, ignored in Release
class DebugLogger {
  DebugLogger._();
  
  static const String _emrTag = '📋 [EMR]';
  static const String _repositoryTag = '💾 [Repository]';
  static const String _specialtyTag = '🏥 [Specialty]';
  
  /// Log EMR-related messages
  static void emr(String message) {
    if (kDebugMode) {
      debugPrint('$_emrTag $message');
    }
  }
  
  /// Log repository operations
  static void repository(String message) {
    if (kDebugMode) {
      debugPrint('$_repositoryTag $message');
    }
  }
  
  /// Log specialty detection
  static void specialty(String message) {
    if (kDebugMode) {
      debugPrint('$_specialtyTag $message');
    }
  }
  
  /// Log errors (always shown, even in release mode for critical errors)
  static void error(String message, [Object? error, StackTrace? stack]) {
    debugPrint('❌ [ERROR] $message');
    if (error != null) debugPrint('   Error: $error');
    if (stack != null) debugPrint('   Stack: $stack');
  }
  
  /// Log success messages
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }
  
  /// Log warnings
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARNING] $message');
    }
  }
}
```

**الاستخدام:**

```dart
// في specialty_constants.dart
DebugLogger.specialty('Checking Nutrition specialty');
DebugLogger.specialty('User specializations: $specializations');

// في add_emr_screen.dart
DebugLogger.emr('Initializing EMR screen for patient: ${widget.patientName}');

// في repositories
DebugLogger.repository('Saving Nutrition EMR to collection: nutrition_emrs');
DebugLogger.success('EMR saved successfully: ${emr.id}');
```

---

### الخطوة 4.2: Build Runner Commands

بعد إتمام جميع التعديلات، تشغيل:

```bash
# الخطوة 1: تنظيف كامل
flutter clean

# الخطوة 2: تحديث التبعيات
flutter pub get

# الخطوة 3: حذف الملفات المولدة القديمة
dart run build_runner clean

# الخطوة 4: إعادة توليد الكود
dart run build_runner build --delete-conflicting-outputs

# الخطوة 5: فحص الأخطاء
flutter analyze

# الخطوة 6: تشغيل الاختبارات (اختياري)
flutter test
```

**الملفات المُتوقع توليدها:**
- `lib/core/di/injection_container.config.dart` - تحديث DI configuration
- جميع `.g.dart` files للـ JSON serialization

---

### الخطوة 4.3: Flutter Analyze Expected Output

```bash
Analyzing elajtech...

# ====================================================================
# EXPECTED: 0 errors, 0 warnings related to EMR changes
# ====================================================================

✅ No issues found!
```

**إذا ظهرت أخطاء:**

1. **Missing imports:**
   ```
   Error: 'SpecialtyConstants' isn't defined
   ```
   **الحل:** أضف `import 'package:elajtech/core/constants/specialty_constants.dart';`

2. **Unused variables:**
   ```
   Warning: Unused local variable 'result'
   ```
   **الحل:** احذف المتغير أو استخدمه

3. **Lazy initialization:**
   ```
   Error: Late initialization error
   ```
   **الحل:** تأكد من `configureDependencies()` قبل `getIt<>()`

---

### الخطوة 4.4: اختبارات يدوية End-to-End

#### اختبار 1: طبيب تغذية

1. **تسجيل دخول** كطبيب تخصص `عيادة السمنة والتغذية العلاجية`
2. **فتح شاشة EMR** من موعد معين
3. **التحقق:**
   - ✅ Console يطبع: `Is Nutrition Doctor: true`
   - ✅ تبويب Nutrition Assessment ظاهر
   - ✅ الأسئلة باللغة الإنجليزية معروضة بشكل صحيح (LTR)
   - ✅ عند الحفظ: رسالة نجاح

#### اختبار 2: طبيب علاج طبيعي

1. **تسجيل دخول** كطبيب تخصص `عيادة العلاج الطبيعي والتأهيل`
2. **فتح شاشة EMR**
3. **التحقق:**
   - ✅ Console يطبع: `Is Physiotherapy Doctor: true`
   - ✅ تبويب Physiotherapy Assessment ظاهر

#### اختبار 3: طبيب باطنة

1. **تسجيل دخول** كطبيب تخصص `عيادة الباطنة وطب الأسرة`
2. **فتح شاشة Internal Medicine EMR**
3. **التحقق:**
   - ✅ System Review و Chronic Diseases sections ظاهرة

#### اختبار 4: اختبار Fuzzy Matching

تعديل مؤقت في Firestore لطبيب تغذية:
- تغيير `specializations` إلى `["تغذية وسمنة"]` (بدون "عيادة")
- **التوقع:** الكود يجب أن يكتشف التخصص بنجاح عبر keywords

---

### الخطوة 4.5: Rollback Plan

**في حالة فشل التنفيذ:**

1. **Revert Git:**
   ```bash
   git checkout HEAD -- lib/core/constants/specialty_constants.dart
   git checkout HEAD -- lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart
   ```

2. **Clean & Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Fallback Code:**
   العودة للكود القديم (exact match):
   ```dart
   bool get _isNutritionDoctor {
     final user = ref.read(authProvider).user;
     return user?.specializations?.contains('عيادة السمنة والتغذية العلاجية') ?? false;
   }
   ```

---

## 📋 خطة التنفيذ الكاملة (Full Implementation Checklist)

### Phase 1: Preparation (إعداد)
- [ ] عمل backup للمشروع (Git commit قبل البدء)
- [ ] عمل new branch: `git checkout -b feature/emr-specialty-fix`
- [ ] قراءة الخطة الكاملة وفهم كل خطوة

### Phase 2: Implementation (تنفيذ)
- [ ] **Step 1:** إنشاء `lib/core/constants/specialty_constants.dart`
- [ ] **Step 2:** تحديث `lib/core/constants/medical_specializations.dart`
- [ ] **Step 3:** تحديث `add_emr_screen.dart` - استيراد الثوابت
- [ ] **Step 4:** تحديث `add_emr_screen.dart` - دوال التحقق
- [ ] **Step 5:** تحديث `add_emr_screen.dart` - initState logging
- [ ] **Step 6:** تحديث `add_emr_screen.dart` - build() conditional rendering
- [ ] **Step 7:** تحديث `add_internal_medicine_emr_screen.dart` - logging
- [ ] **Step 8:** فحص Repositories - إضافة logging
- [ ] **Step 9:** (اختياري) إنشاء `debug_logger.dart`

### Phase 3: Build & Test (بناء واختبار)
- [ ] **Step 10:** `flutter clean`
- [ ] **Step 11:** `flutter pub get`
- [ ] **Step 12:** `dart run build_runner build --delete-conflicting-outputs`
- [ ] **Step 13:** `flutter analyze` - التحقق من 0 errors
- [ ] **Step 14:** حل أي أخطاء ظاهرة
- [ ] **Step 15:** تشغيل `flutter run`

### Phase 4: Manual Testing (اختبار يدوي)
- [ ] **Test 1:** طبيب تغذية - التحقق من ظهور التبويب
- [ ] **Test 2:** طبيب علاج طبيعي - التحقق من ظهور التبويب
- [ ] **Test 3:** طبيب باطنة - التحقق من الشاشة المنفصلة
- [ ] **Test 4:** Fuzzy Matching - اختبار مع variations
- [ ] **Test 5:** حفظ EMR - التحقق من نجاح الحفظ في Firestore
- [ ] **Test 6:** Console Logs - مراجعة جميع الرسائل

### Phase 5: Documentation & Cleanup (توثيق وتنظيف)
- [ ] **Step 16:** إنشاء تقرير النجاح
- [ ] **Step 17:** تنظيف Debug logs الإضافية (اختياري)
- [ ] **Step 18:** Git commit مع رسالة واضحة
- [ ] **Step 19:** Push & Create Pull Request
- [ ] **Step 20:** Code Review

---

## 🛡️ مقترحات المنع المستقبلي (Future Prevention)

### 1. Data Validation في Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/elajtech/documents {
    // Users collection with specialty validation
    match /users/{userId} {
      allow create, update: if request.resource.data.specializations is list &&
        request.resource.data.specializations.size() > 0 &&
        // Ensure specializations use exact constants
        request.resource.data.specializations[0] != null;
    }
  }
}
```

### 2. Firestore Triggers للتوحيد

إنشاء Cloud Function لتوحيد الأسماء تلقائياً:

```javascript
// Firebase Cloud Function
exports.normalizeSpecialties = functions.firestore
  .document('users/{userId}')
  .onWrite(async (change, context) => {
    const after = change.after.data();
    if (!after || !after.specializations) return;
    
    const normalized = after.specializations.map(spec => {
      // Normalize variations
      if (spec.includes('تغذية') || spec.includes('سمنة')) {
        return 'عيادة السمنة والتغذية العلاجية';
      }
      if (spec.includes('علاج طبيعي') || spec.includes('تأهيل')) {
        return 'عيادة العلاج الطبيعي والتأهيل';
      }
      if (spec.includes('باطنة') || spec.includes('طب الأسرة')) {
        return 'عيادة الباطنة وطب الأسرة';
      }
      return spec;
    });
    
    // Update if changed
    if (JSON.stringify(normalized) !== JSON.stringify(after.specializations)) {
      await change.after.ref.update({ specializations: normalized });
    }
  });
```

### 3. Unit Tests

**الملف:** `test/core/constants/specialty_constants_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elajtech/core/constants/specialty_constants.dart';

void main() {
  group('SpecialtyConstants - Nutrition Detection', () {
    test('Exact match returns true', () {
      final result = SpecialtyConstants.isNutritionDoctor([
        'عيادة السمنة والتغذية العلاجية',
      ]);
      expect(result, true);
    });
    
    test('Fuzzy match with keyword returns true', () {
      final result = SpecialtyConstants.isNutritionDoctor([
        'تغذية وسمنة', // No "عيادة" prefix
      ]);
      expect(result, true);
    });
    
    test('Variation with extra spaces returns true', () {
      final result = SpecialtyConstants.isNutritionDoctor([
        'عيادة  السمنة  والتغذية', // Extra spaces
      ]);
      expect(result, true);
    });
    
    test('English keyword returns true', () {
      final result = SpecialtyConstants.isNutritionDoctor([
        'Nutrition Clinic',
      ]);
      expect(result, true);
    });
    
    test('Unrelated specialty returns false', () {
      final result = SpecialtyConstants.isNutritionDoctor([
        'عيادة الذكورة',
      ]);
      expect(result, false);
    });
    
    test('Null specializations returns false', () {
      final result = SpecialtyConstants.isNutritionDoctor(null);
      expect(result, false);
    });
    
    test('Empty list returns false', () {
      final result = SpecialtyConstants.isNutritionDoctor([]);
      expect(result, false);
    });
  });
  
  // Similar tests for Physiotherapy, Internal Medicine, etc.
}
```

### 4. Documentation

إضافة لـ README.md:

```markdown
## 🏥 Medical Specialties System

### How to Add a New Specialty

1. **Add constant to `specialty_constants.dart`:**
   dart
   static const String newSpecialty = 'عيادة التخصص الجديد';
   

2. **Add keywords:**
   dart
   static const List<String> newSpecialtyKeywords = [
     'كلمة1',
     'كلمة2',
   ];
   

3. **Add detection method:**
   dart
   static bool isNewSpecialtyDoctor(List<String>? specializations) {
     if (specializations == null || specializations.isEmpty) return false;
     return specializations.any((spec) {
       if (spec == newSpecialty) return true;
       return _matchesAnyKeyword(spec, newSpecialtyKeywords);
     });
   }
   

4. **Use in UI:**
   dart
   bool get _isNewSpecialtyDoctor {
     return SpecialtyConstants.isNewSpecialtyDoctor(
       ref.read(authProvider).user?.specializations,
     );
   }
   

### Testing Specialty Detection

Run unit tests:
bash
flutter test test/core/constants/specialty_constants_test.dart

```

### 5. Linter Rule (Custom Analysis)

إضافة لـ `analysis_options.yaml`:

```yaml
linter:
  rules:
    # ... existing rules
    
    # Prevent direct string matching for specialties
    # (This is a conceptual example; would need custom analyzer)
    avoid_hardcoded_specialty_strings: true
```

---

## 📊 الخلاصة والتقييم النهائي

### ما تم تحقيقه:

#### ✅ **Phase 1: Data Mapping**
- إنشاء `SpecialtyConstants` - مصدر واحد للحقيقة
- Fuzzy Matching Algorithm - يتعامل مع الاختلافات
- Text Normalization - يتجاهل المسافات و"الـ"

#### ✅ **Phase 2: UI Logic**
- Conditional Rendering دقيق لكل تخصص
- Directionality صحيح (RTL للعربي، LTR للإنجليزي)
- Debug Logging شامل
- Developer Warnings في Debug Mode

#### ✅ **Phase 3: Repository Layer**
- استخدام `databaseId: 'elajtech'` ✅
- Repository لكل تخصص مستقل
- Error Handling محسّن

#### ✅ **Phase 4: Validation & Testing**
- Build Runner commands واضحة
- Manual Testing Checklist
- Unit Tests للـ Constants
- Rollback Plan جاهز

---

### مؤشرات النجاح (Success Metrics):

| المؤشر | الهدف | الطريقة |
|--------|-------|---------|
| **Specialty Detection Rate** | 100% | Console logs تُظهر `true` للتخصص الصحيح |
| **UI Visibility** | 100% | جميع التبويبات تظهر للأطباء المناسبين |
| **Save Success Rate** | 100% | لا توجد أخطاء عند حفظ EMR |
| **Firestore Database** | elajtech | جميع العمليات على قاعدة البيانات الصحيحة |
| **Flutter Analyze** | 0 errors | نظيف بدون أخطاء |
| **Build Success** | ✅ | Build runner بدون تعارضات |

---

### التوصيات النهائية:

1. **تنفيذ الخطة بالترتيب المحدد** - كل خطوة تعتمد على السابقة
2. **لا تتخطَ الـ Logging** - سيوفر عليك ساعات من التحليل
3. **اختبار كل تخصص على حدة** - تأكد من كل حالة
4. **Review Console Logs** - افهم سير العمل
5. **Commit بعد كل مرحلة ناجحة** - سهولة الـ Rollback

---

**تاريخ الإنشاء:** 2026-01-18  
**الحالة:** ✅ جاهز للتنفيذ  
**المدة المتوقعة:** 3-4 ساعات (شاملة الاختبار)  
**الأولوية:** 🔴 حرجة - يجب التنفيذ فوراً

---

**End of Plan** 🎯
