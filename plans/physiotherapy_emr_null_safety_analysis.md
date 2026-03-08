// ignore_for_file: all  
// ignore_for_file: all
# تحليل Null Safety - Physiotherapy EMR

## تاريخ التحليل
- **التاريخ**: 2026-01-20
- **المشكلة**: استثناء 'Null check operator used on a null value' عند الضغط على زر الحفظ في PhysiotherapyEMRTab
- **الوضع الحالي**: مرحلة التحليل والتشخيص (لم يتم تعديل الكود بعد)

---

## المرحلة الأولى: التشخيص والتحليل المعمق

### 1. فحص دالة `_getCurrentEMRData` في `physiotherapy_emr_tab.dart` (السطر 177-217)

```dart
PhysiotherapyEMR _getCurrentEMRData() {
  return PhysiotherapyEMR(
    id: const Uuid().v4(),                    // ✅ آمن - لا يمكن أن يكون null
    patientId: widget.patientId,              // ✅ آمن - required في constructor
    doctorId: widget.doctorId,                // ✅ آمن - required في constructor
    doctorName: widget.doctorName,            // ✅ آمن - required في constructor
    appointmentId: widget.appointmentId,      // ✅ آمن - required في constructor
    visitDate: widget.visitDate,              // ✅ آمن - required في constructor
    createdAt: DateTime.now(),                // ✅ آمن - لا يمكن أن يكون null

    // جميع الـ Maps تستخدم `?? <String>[]` - ✅ آمنة
    basics: <String, List<String>>{
      'selected': _selections['Patient & Visit Basics'] ?? <String>[],
    },
    painAssessment: <String, List<String>>{
      'selected': _selections['Pain Assessment'] ?? <String>[],
    },
    functionalAssessment: <String, List<String>>{
      'selected': _selections['Functional Status'] ?? <String>[],
    },
    systemsReview: <String, List<String>>{
      'selected': _selections['Systems Screening'] ?? <String>[],
    },
    rangeOfMotion: <String, List<String>>{
      'selected': _selections['Range of Motion'] ?? <String>[],
    },
    strengthAssessment: <String, List<String>>{
      'selected': _selections['Strength Testing'] ?? <String>[],
    },
    devicesEquipment: <String, List<String>>{
      'selected': _selections['Assistive Devices'] ?? <String>[],
    },
    treatmentPlan: <String, List<String>>{
      'selected': _selections['Plan'] ?? <String>[],
    },

    // ✅ آمن - nullable fields
    primaryDiagnosis: _primaryDiagnosisController.text.trim().isEmpty
        ? null
        : _primaryDiagnosisController.text.trim(),
    managementPlan: _managementPlanController.text.trim().isEmpty
        ? null
        : _managementPlanController.text.trim(),
  );
}
```

**النتيجة**: الدالة `_getCurrentEMRData` آمنة تماماً من ناحية Null Safety.

---

### 2. فحص دالة `_save` في `add_emr_screen.dart` (السطر 317-479)

#### ⚠️ المشكلة الرئيسية رقم 1: استخدام `!` على `user` (السطر 328)

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    // ...
  }

  setState(() => _isLoading = true);

  try {
    final user = ref.read(authProvider).user!;  // ❌ خطر - user قد يكون null!

    final emr = EMRModel(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      doctorId: user.id,          // يعتمد على user من السطر 328
      doctorName: user.fullName,  // يعتمد على user من السطر 328
      // ...
    );
```

**تحليل المشكلة**:
- في [`auth_provider.dart`](lib/features/auth/providers/auth_provider.dart) السطر 39: `final UserModel? user;`
- `user` في `AuthState` هو **nullable** (`UserModel?`)
- استخدام `!` operator سيؤدي إلى `Null check operator used on a null value` إذا لم يكن المستخدم مسجل الدخول

#### ⚠️ المشكلة الرئيسية رقم 2: استخدام `!` في `build` method (السطر 820-821)

```dart
@override
Widget build(BuildContext context) {
  // Null safety protection
  if (ref.watch(authProvider).user == null) {
    return const SizedBox();
  }

  return Scaffold(
    appBar: AppBar(title: const Text('إضافة سجل EMR')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Physiotherapy Tab (Conditional)
          if (_isPhysiotherapyDoctor)
            PhysiotherapyEMRTab(
              key: _physiotherapyTabKey,
              patientId: widget.patientId,
              doctorId: ref.read(authProvider).user!.id,        // ❌ خطر
              doctorName: ref.read(authProvider).user!.fullName,  // ❌ خطر
              appointmentId: widget.appointmentId,
              visitDate: DateTime.now(),
            ),
```

**تحليل المشكلة**:
- على الرغم من وجود فحص `if (ref.watch(authProvider).user == null)` في السطر 804، إلا أن هذا الفحص يحدث فقط عند بناء الـ Widget
- عندما يتم استدعاء `_save()`، قد يكون `user` قد أصبح null (مثلاً: تم تسجيل الخروج أثناء وجود المستخدم في الشاشة)
- استخدام `ref.read(authProvider).user!` مباشرة بدون فحص في `build` method

#### ⚠️ المشكلة المحتملة رقم 3: `_physiotherapyTabKey.currentState` (السطر 415)

```dart
// Save Physiotherapy EMR if applicable
if (_isPhysiotherapyDoctor) {
  final physioEMRData = _physiotherapyTabKey.currentState?.getEMRData();
  if (physioEMRData != null) {
    final physioResult = await GetIt.I<PhysiotherapyEMRRepository>()
        .createPhysiotherapyEMR(physioEMRData);
    physioResult.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }
}
```

**تحليل المشكلة**:
- استخدام `?.` operator صحيح، لكن `currentState` قد يكون null إذا لم يتم إنشاء الـ Widget بعد
- إذا كان `_isPhysiotherapyDoctor` true ولكن الـ Widget لم يتم بناؤه بعد، `currentState` سيكون null

#### ⚠️ المشكلة المحتملة رقم 4: `user.specializations?.first` (السطر 451)

```dart
// Save Nutrition EMR if applicable
if (_isNutritionDoctor) {
  final nutritionEMR = NutritionEMRModel(
    // ...
    specialization:
        user.specializations?.first ?? 'عام', // ⚠️ قد يكون null إذا كانت القائمة فارغة
  );
```

**تحليل المشكلة**:
- `user.specializations` قد يكون null أو قائمة فارغة
- `.first` سيرمي `StateError` إذا كانت القائمة فارغة
- `?? 'عام'` لن يحمي من القائمة الفارغة

---

### 3. فحص `physiotherapy_emr_model.dart` (السطر 42)

#### ⚠️ المشكلة رقم 5: استخدام `!` على `snapshot.data()` (السطر 42)

```dart
static PhysiotherapyEMR fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> snapshot,
) {
  final data = snapshot.data()!;  // ❌ خطر - قد يكون null

  return PhysiotherapyEMR(
    id: data['id'] as String,
    patientId: data['patientId'] as String,
    // ...
  );
}
```

**تحليل المشكلة**:
- `snapshot.data()` قد يكون null إذا لم يكن المستند موجوداً
- استخدام `!` operator سيؤدي إلى استثناء إذا كان المستند غير موجود

---

### 4. فحص `physiotherapy_emr_repository.dart` (السطر 23)

#### ⚠️ المشكلة رقم 6: متغير `late` (السطر 23)

```dart
@lazySingleton
class PhysiotherapyEMRRepository {
  PhysiotherapyEMRRepository() {
    // Initialize Firestore with custom database ID
    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'elajtech',
    );
  }

  late final FirebaseFirestore _firestore;  // ⚠️ متغير late
```

**تحليل المشكلة**:
- متغير `late` يتم تهيئته في constructor
- إذا تم استدعاء أي دالة قبل اكتمال constructor، سيحدث `LateInitializationError`

---

### 5. فحص `physiotherapy_emr.dart` Entity (السطر 12-37)

```dart
@freezed
abstract class PhysiotherapyEMR with _$PhysiotherapyEMR {
  const factory PhysiotherapyEMR({
    required String id,                    // إجباري
    required String patientId,             // إجباري
    required String doctorId,              // إجباري
    required String doctorName,            // إجباري
    required String appointmentId,        // إجباري
    required DateTime visitDate,           // إجباري
    required DateTime createdAt,           // إجباري

    // Phase One: 8 Checklist Sections
    required Map<String, List<String>> basics,
    required Map<String, List<String>> painAssessment,
    required Map<String, List<String>> functionalAssessment,
    required Map<String, List<String>> systemsReview,
    required Map<String, List<String>> rangeOfMotion,
    required Map<String, List<String>> strengthAssessment,
    required Map<String, List<String>> devicesEquipment,
    required Map<String, List<String>> treatmentPlan,

    // Phase Two: Unified Text Input Sections
    String? primaryDiagnosis,              // nullable
    String? managementPlan,                // nullable

    // Metadata
    @Default('عيادة العلاج الطبيعي والتأهيل') String specialization,
  }) = _PhysiotherapyEMR;
```

**النتيجة**: جميع الحقول المطلوبة (required) محددة بشكل صحيح. المشكلة ليست في Entity بل في كيفية استخدامه.

---

## المرحلة الثانية: خطة الحل المقترحة

### ملخص مصادر Null المحتملة

| # | الموقع | المشكلة | الأثر |
|---|--------|---------|-------|
| 1 | `add_emr_screen.dart:328` | `ref.read(authProvider).user!` | ⚠️ **خطير** - سبب محتمل رئيسي |
| 2 | `add_emr_screen.dart:820-821` | `ref.read(authProvider).user!.id` | ⚠️ **خطير** - سبب محتمل |
| 3 | `add_emr_screen.dart:451` | `user.specializations?.first` | ⚠️ **متوسط** - StateError |
| 4 | `physiotherapy_emr_model.dart:42` | `snapshot.data()!` | ⚠️ **متوسط** - عند القراءة من Firestore |
| 5 | `add_emr_screen.dart:415` | `_physiotherapyTabKey.currentState` | ℹ️ **منخفض** - Widget لم يتم بناؤه |
| 6 | `physiotherapy_emr_repository.dart:23` | `late final _firestore` | ℹ️ **منخفض** - LateInitializationError |

---

### خطة الحل التفصيلية

#### الحل 1: تأمين `user` في دالة `_save` (الأولوية القصوى)

**الموقع**: [`add_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart) السطر 317-479

**الحل المقترح**:

```dart
Future<void> _save() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
    );
    return;
  }

  // ✅ إضافة فحص user قبل المتابعة
  final user = ref.read(authProvider).user;
  if (user == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      Navigator.pop(context); // العودة للشاشة السابقة
    }
    return;
  }

  // ✅ إضافة سجلات تتبع قبل الحفظ
  if (kDebugMode) {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('📋 [EMR] Starting Save Operation');
    debugPrint('───────────────────────────────────────────────────');
    debugPrint('👤 User Info:');
    debugPrint('   ID: ${user.id}');
    debugPrint('   Name: ${user.fullName}');
    debugPrint('   Type: ${user.userType}');
    debugPrint('📝 Patient Info:');
    debugPrint('   Patient ID: ${widget.patientId}');
    debugPrint('   Appointment ID: ${widget.appointmentId}');
    debugPrint('───────────────────────────────────────────────────');
    debugPrint('🏥 Specialty Detection:');
    debugPrint('   Physiotherapy: $_isPhysiotherapyDoctor');
    debugPrint('   Nutrition: $_isNutritionDoctor');
    debugPrint('═══════════════════════════════════════════════════');
  }

  setState(() => _isLoading = true);

  try {
    final emr = EMRModel(
      id: const Uuid().v4(),
      patientId: widget.patientId,
      doctorId: user.id,          // ✅ آمن الآن
      doctorName: user.fullName,   // ✅ آمن الآن
      appointmentId: widget.appointmentId,
      createdAt: DateTime.now(),
      // ... باقي الحقول
    );

    final result = await GetIt.I<EMRRepository>().saveEMR(emr);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );

    // ✅ إضافة سجلات تتبع بعد الحفظ
    if (kDebugMode) {
      debugPrint('✅ [EMR] Main EMR saved successfully');
    }

    // Save Physiotherapy EMR if applicable
    if (_isPhysiotherapyDoctor) {
      if (kDebugMode) {
        debugPrint('🏥 [Physiotherapy] Attempting to save Physiotherapy EMR');
      }

      final physioEMRData = _physiotherapyTabKey.currentState?.getEMRData();
      if (physioEMRData != null) {
        if (kDebugMode) {
          debugPrint('   ✅ Physiotherapy EMR data retrieved');
          debugPrint('   📊 Data: ${physioEMRData.toString()}');
        }

        final physioResult = await GetIt.I<PhysiotherapyEMRRepository>()
            .createPhysiotherapyEMR(physioEMRData);
        physioResult.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );

        if (kDebugMode) {
          debugPrint('   ✅ Physiotherapy EMR saved successfully');
        }
      } else {
        if (kDebugMode) {
          debugPrint('   ⚠️ Physiotherapy EMR data is null');
        }
      }
    }

    // Save Nutrition EMR if applicable
    if (_isNutritionDoctor) {
      if (kDebugMode) {
        debugPrint('🥗 [Nutrition] Attempting to save Nutrition EMR');
      }

      // ✅ تأمين specializations
      final specialization = user.specializations != null &&
              user.specializations!.isNotEmpty
          ? user.specializations!.first
          : 'عام';

      if (kDebugMode) {
        debugPrint('   📋 Specialization: $specialization');
      }

      final nutritionEMR = NutritionEMRModel(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        doctorId: user.id,
        doctorName: user.fullName,
        appointmentId: widget.appointmentId,
        createdAt: DateTime.now(),
        // ... باقي الحقول
        specialization: specialization,
      );

      final nutritionResult = await GetIt.I<NutritionEMRRepository>().saveEMR(
        nutritionEMR,
      );
      nutritionResult.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );

      if (kDebugMode) {
        debugPrint('   ✅ Nutrition EMR saved successfully');
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ السجل بنجاح')));
    }
  } on Object catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [EMR] Error during save: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

**التغييرات الرئيسية**:
1. إضافة فحص `user == null` قبل المتابعة
2. إضافة رسالة خطأ واضحة للمستخدم إذا لم يكن مسجل الدخول
3. إضافة سجلات تتبع مفصلة (Debug Logs)
4. تأمين `user.specializations?.first` ضد القوائم الفارغة

---

#### الحل 2: تأمين `user` في `build` method (الأولوية العالية)

**الموقع**: [`add_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart) السطر 802-824

**الحل المقترح**:

```dart
@override
Widget build(BuildContext context) {
  // ✅ حفظ user في متغير محلي
  final user = ref.watch(authProvider).user;

  // Null safety protection
  if (user == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(title: const Text('إضافة سجل EMR')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Physiotherapy Tab (Conditional)
          if (_isPhysiotherapyDoctor)
            PhysiotherapyEMRTab(
              key: _physiotherapyTabKey,
              patientId: widget.patientId,
              doctorId: user.id,        // ✅ آمن
              doctorName: user.fullName, // ✅ آمن
              appointmentId: widget.appointmentId,
              visitDate: DateTime.now(),
            ),

          // Nutrition Tab (Conditional)
          if (_isNutritionDoctor) _buildNutritionTab(),

          // Andrology EMR (Conditional - only if not physiotherapy or nutrition)
          if (!_isPhysiotherapyDoctor && !_isNutritionDoctor)
            _buildAndrologyForm(),

          // Save Button (Always visible)
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
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    ),
  );
}
```

**التغييرات الرئيسية**:
1. حفظ `user` في متغير محلي بدلاً من استدعاء `ref.read(authProvider).user!` عدة مرات
2. استخدام `ref.watch` بدلاً من `ref.read` للتحديث التلقائي عند تغيير حالة المصادقة
3. إرجاع `Scaffold` مع `CircularProgressIndicator` بدلاً من `SizedBox` الفارغ

---

#### الحل 3: تأمين `snapshot.data()` في `fromFirestore` (الأولوية المتوسطة)

**الموقع**: [`physiotherapy_emr_model.dart`](lib/features/doctor/medical_records/data/models/physiotherapy_emr_model.dart) السطر 39-71

**الحل المقترح**:

```dart
/// Convert Firestore document to PhysiotherapyEMR entity
static PhysiotherapyEMR fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> snapshot,
) {
  // ✅ إضافة فحص null
  if (!snapshot.exists) {
    throw ArgumentError('Document does not exist');
  }

  final data = snapshot.data();
  if (data == null) {
    throw ArgumentError('Document data is null');
  }

  // ✅ إضافة سجلات تتبع
  if (kDebugMode) {
    debugPrint('📄 [PhysiotherapyEMRModel] Parsing document: ${snapshot.id}');
    debugPrint('   Data keys: ${data.keys.join(", ")}');
  }

  try {
    return PhysiotherapyEMR(
      id: data['id'] as String,
      patientId: data['patientId'] as String,
      doctorId: data['doctorId'] as String,
      doctorName: data['doctorName'] as String,
      appointmentId: data['appointmentId'] as String,
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),

      // 8 Checklist Sections
      basics: _parseMap(data['basics']),
      painAssessment: _parseMap(data['painAssessment']),
      functionalAssessment: _parseMap(data['functionalAssessment']),
      systemsReview: _parseMap(data['systemsReview']),
      rangeOfMotion: _parseMap(data['rangeOfMotion']),
      strengthAssessment: _parseMap(data['strengthAssessment']),
      devicesEquipment: _parseMap(data['devicesEquipment']),
      treatmentPlan: _parseMap(data['treatmentPlan']),

      // Unified Text Fields
      primaryDiagnosis: data['primaryDiagnosis'] as String?,
      managementPlan: data['managementPlan'] as String?,

      // Metadata
      specialization:
          data['specialization'] as String? ?? 'عيادة العلاج الطبيعي والتأهيل',
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [PhysiotherapyEMRModel] Error parsing document: $e');
      debugPrint('   Document data: $data');
    }
    rethrow;
  }
}
```

**التغييرات الرئيسية**:
1. إضافة فحص `!snapshot.exists`
2. إضافة فحص `data == null`
3. إضافة `try-catch` حول عملية التحويل
4. إضافة سجلات تتبع للتشخيص

---

#### الحل 4: تأمين `late final _firestore` (الأولوية المنخفضة)

**الموقع**: [`physiotherapy_emr_repository.dart`](lib/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart) السطر 14-24

**الحل المقترح**:

```dart
@lazySingleton
class PhysiotherapyEMRRepository {
  PhysiotherapyEMRRepository()
      : _firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'elajtech',
        ) {
    // ✅ استخدام initializer list بدلاً من late
  }

  final FirebaseFirestore _firestore;  // ✅ non-late
  static const String _collectionName = 'physiotherapy_emrs';
```

**التغييرات الرئيسية**:
1. استخدام `initializer list` بدلاً من `late final`
2. `_firestore` الآن `final` وليس `late final`

---

### استراتيجية السجلات التتبع (Logging Strategy)

#### سجلات التتبع المقترحة

```dart
// في بداية دالة _save()
if (kDebugMode) {
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('📋 [EMR] Starting Save Operation');
  debugPrint('───────────────────────────────────────────────────');
  debugPrint('👤 User Info:');
  debugPrint('   ID: ${user?.id ?? "null"}');
  debugPrint('   Name: ${user?.fullName ?? "null"}');
  debugPrint('   Type: ${user?.userType}');
  debugPrint('📝 Patient Info:');
  debugPrint('   Patient ID: ${widget.patientId}');
  debugPrint('   Appointment ID: ${widget.appointmentId}');
  debugPrint('───────────────────────────────────────────────────');
  debugPrint('🏥 Specialty Detection:');
  debugPrint('   Physiotherapy: $_isPhysiotherapyDoctor');
  debugPrint('   Nutrition: $_isNutritionDoctor');
  debugPrint('═══════════════════════════════════════════════════');
}

// قبل إنشاء EMR
if (kDebugMode) {
  debugPrint('📦 [EMR] Creating EMRModel...');
}

// بعد الحفظ
if (kDebugMode) {
  debugPrint('✅ [EMR] Main EMR saved successfully');
}

// قبل حفظ Physiotherapy EMR
if (_isPhysiotherapyDoctor) {
  if (kDebugMode) {
    debugPrint('🏥 [Physiotherapy] Attempting to save Physiotherapy EMR');
  }

  final physioEMRData = _physiotherapyTabKey.currentState?.getEMRData();
  if (physioEMRData != null) {
    if (kDebugMode) {
      debugPrint('   ✅ Physiotherapy EMR data retrieved');
      debugPrint('   📊 Data: ${physioEMRData.toString()}');
    }
  } else {
    if (kDebugMode) {
      debugPrint('   ⚠️ Physiotherapy EMR data is null');
    }
  }
}

// في catch block
if (kDebugMode) {
  debugPrint('❌ [EMR] Error during save: $e');
  debugPrint('   Stack trace: ${StackTrace.current}');
}
```

---

## ملخص التنفيذ

### الخطوات المطلوبة (بالترتيب)

1. **الأولوية القصوى**: تأمين `user` في دالة `_save` في `add_emr_screen.dart`
   - إضافة فحص `user == null`
   - إضافة رسالة خطأ واضحة
   - إضافة سجلات تتبع

2. **الأولوية العالية**: تأمين `user` في `build` method
   - حفظ `user` في متغير محلي
   - استخدام `ref.watch` بدلاً من `ref.read`

3. **الأولوية المتوسطة**: تأمين `snapshot.data()` في `fromFirestore`
   - إضافة فحص `!snapshot.exists`
   - إضافة `try-catch`

4. **الأولوية المنخفضة**: تأمين `late final _firestore`
   - استخدام initializer list

---

## ملاحظات إضافية

### 1. حالة `_physiotherapyTabKey.currentState`

إذا كان `_physiotherapyTabKey.currentState` null، فهذا يعني أن:
- الـ Widget لم يتم بناؤه بعد
- أو تم تدمير الـ Widget

**الحل المقترح**: إضافة فحص إضافي:

```dart
if (_isPhysiotherapyDoctor) {
  if (_physiotherapyTabKey.currentState == null) {
    if (kDebugMode) {
      debugPrint('⚠️ [Physiotherapy] Widget state is null');
    }
    // يمكنك اختيارياً إظهار رسالة خطأ أو تجاهل هذا الجزء
  } else {
    final physioEMRData = _physiotherapyTabKey.currentState!.getEMRData();
    // ...
  }
}
```

### 2. حالة `user.specializations?.first`

**الحل المقترح**:

```dart
final specialization = (user.specializations != null &&
        user.specializations!.isNotEmpty)
    ? user.specializations!.first
    : 'عام';
```

### 3. حالة `widget.patientId!`

إذا كان `patientId` nullable في `AddEMRScreen`، يجب فحصه أيضاً:

```dart
if (widget.patientId.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('معرف المريض مطلوب')),
  );
  return;
}
```

---

## الخاتمة

### المشكلة الرئيسية

المشكلة الرئيسية هي استخدام `!` operator على `ref.read(authProvider).user` في دالة `_save` (السطر 328) و `build` method (السطر 820-821) في [`add_emr_screen.dart`](lib/features/doctor/medical_records/presentation/screens/add_emr_screen.dart).

### السبب المحتمل

عندما يضغط المستخدم على زر الحفظ، إذا كان `user` null (مثلاً: تم تسجيل الخروج أثناء وجود المستخدم في الشاشة)، سيحدث الاستثناء 'Null check operator used on a null value'.

### الحل

تأمين جميع استخدامات `user` بإضافة فحوصات null قبل الوصول إلى خصائصه، وإضافة سجلات تتبع مفصلة لتشخيص المشاكل المستقبلية.
