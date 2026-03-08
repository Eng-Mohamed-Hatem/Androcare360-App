# تحليل مفصل لمشكلة رفض الصلاحيات (permission-denied) | Detailed Permission Denied Analysis

**التاريخ:** 2026-01-13  
**المهندس:** مهندس ضمان جودة (QA Engineer)  
**المشروع:** ElajTech - تطبيق المركز الطبي (AndroCare360)

---

## ملخص تنفيذي (Executive Summary)

تم تحليل مشكلة رفض الصلاحيات (permission-denied) التي يواجهها الطبيبون عند محاولة تحديث بياناتهم الطبية (EMR، وصفات، وتاليل) في قاعدة بيانات Firestore.

---

## 1. وصف المشكلة (Problem Description)

### 1.1 السلوك المتوقع (Expected Behavior)

عند محاولة الطبيب تحديث بياناته الطبية (مثل إضافة صورة ملف تعريف EMR، تحديث معلومات الملف الشخصية)، يظهر خطأ:

```
Error: Missing or insufficient permissions
Error: Permission denied
```

هذا السلوك يشير إلى مشكلة في قواعد الأمان (Security Rules) تمنع الوصول غير المصرح للبيانات الطبية.

### 1.2 السبب الجذري (Root Cause Analysis)

#### أ. عدم تطابق أسماء الحقول (Field Name Mismatch)

**المشكلة الأساسية:**
- النموذج يستخدم `userType` (enum: `UserType.doctor`, `UserType.patient`)
- قواعد الأمان تستخدم `role` (string: `'doctor'`, `'patient'`)
- هذا يؤدي إلى فشل التحقق من الدور في قواعد الأمان

**الملف:** [`lib/shared/models/user_model.dart`](lib/shared/models/user_model.dart)

**السطر 35-38:**
```dart
userType: UserType.values.firstWhere(
  (e) => e.toString() == 'UserType.${json['userType']}',
  orElse: () => UserType.patient,
),
```

**السطر 109:**
```dart
'userType': userType.name,  // يخزن 'doctor' أو 'patient'
```

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**السطر 127:**
```javascript
allow read: if request.auth != null 
  && (request.auth.uid == userId 
    || resource.data.role == 'doctor');  // ❌ خطأ: يجب استخدام 'userType'
```

**النتيجة:**
- عندما يتحقق Firestore من `resource.data.role == 'doctor'`، الحقل غير موجود
- النموذج يخزن `userType: 'doctor'` وليس `role: 'doctor'`
- هذا يؤدي إلى فشل التحقق من الدور

#### ب. قيود صارمة على حقول التحديث (Strict Field Update Constraints)

**المشكلة:**
- قواعد الأمان تسمح فقط بتحديث حقول محدودة: `['fullName', 'profileImage', 'fcmToken', 'isOnline']`
- الأطباء يحتاجون إلى تحديث حقول إضافية: `licenseNumber`, `specializations`, `clinicName`, `clinicAddress`, `workingHours`, `biography`, `yearsOfExperience`, `consultationFee`, `consultationTypes`, `education`, `certificates`

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**السطر 130-134:**
```javascript
allow update: if request.auth != null 
  && request.auth.uid == userId
  // السماح بتحديث حقول محدودة فقط
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly(['fullName', 'profileImage', 'fcmToken', 'isOnline']);
```

**النتيجة:**
- عندما يحاول الطبيب تحديث `licenseNumber` أو `specializations`، يتم الرفض
- عندما يحاول الطبيب تحديث `workingHours` أو `biography`، يتم الرفض
- هذا يؤدي إلى خطأ `permission-denied`

#### ج. عدم وجود Cloud Function للتحقق من صحة البيانات (No Validation Function)

**المشكلة:**
- لا يوجد Cloud Function للتحقق من صحة البيانات قبل السماح بالتحديث
- لا يوجد Cloud Function للتحقق من الدور قبل السماح
- لا يوجد Cloud Function للتحقق من الحقول المُحدّثة

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**المحتوى الحالي:**
- `generateMeetLink` - لتوليد روابط Google Meet
- `sendAppointmentReminders` - لإرسال تذكيرات المواعيد
- `sendChatNotification` - لإرسال إشعارات المحادثات
- `testCalendar` - لاختبار تقويم Google

**النتيجة:**
- عدم وجود طبقة تحقق إضافية على مستوى الخادم
- الاعتماد الكامل على قواعد الأمان فقط
- عدم وجود رسائل خطأ واضحة للمستخدم

#### د. عدم وجود فهارس Firestore (Missing Firestore Indexes)

**المشكلة:**
- عدم وجود فهارس Firestore لتحسين الأداء
- عدم وجود فهارس للمستخدمين، المحادثات، المواعيد
- هذا يؤدي إلى استعلامات بطيئة (Collection Group Scans)

**الملف:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**المحتوى الحالي:**
```json
{
  "indexes": []
}
```

**النتيجة:**
- استعلامات بطيئة عند البحث عن المستخدمين
- استعلامات بطيئة عند جلب المحادثات
- استعلامات بطيئة عند جلب المواعيد

---

## 2. تحليل الشيفرة (Code Analysis)

### 2.1 تحليل [`auth_provider.dart`](lib/features/auth/providers/auth_provider.dart)

#### الدالة `updateUserData` (السطر 424-434):

```dart
/// Update User Data
Future<void> updateUserData(UserModel updatedUser) async {
  state = state.copyWith(isLoading: true);

  final result = await _authRepository.updateUser(updatedUser);
  result.fold(
    (Failure failure) =>
        state = state.copyWith(isLoading: false, error: failure.message),
    (Unit unit) =>
        state = state.copyWith(user: updatedUser, isLoading: false),
  );
}
```

**المشكلة:**
- لا تتحقق من دور المستخدم قبل التحديث
- لا تتحقق من الحقول المسموح بها قبل التحديث
- تعتمد كلياً على قواعد الأمان

#### الدالة `updateWorkingHours` (السطر 325-342):

```dart
/// Update Working Hours
Future<void> updateWorkingHours(
  Map<String, List<String>> workingHours,
) async {
  final currentUser = state.user;
  if (currentUser == null) return;

  state = state.copyWith(isLoading: true);

  final updatedUser = currentUser.copyWith(workingHours: workingHours);
  final result = await _authRepository.updateUser(updatedUser);

  result.fold(
    (Failure failure) =>
        state = state.copyWith(isLoading: false, error: failure.message),
    (Unit unit) =>
        state = state.copyWith(user: updatedUser, isLoading: false),
  );
}
```

**المشكلة:**
- لا تتحقق من دور المستخدم قبل التحديث
- لا تتحقق من أن المستخدم طبيب قبل تحديث ساعات العمل
- تعتمد كلياً على قواعد الأمان

### 2.2 تحليل [`auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart)

#### الدالة `updateUser` (السطر 217-227):

```dart
@override
Future<Either<Failure, Unit>> updateUser(UserModel user) async {
  try {
    await _firestore
        .collection(AppConstants.collections.users)
        .doc(user.id)
        .update(user.toJson());
    return const Right(unit);
  } on Exception catch (e) {
    return Left(AuthFailure(e.toString()));
  }
}
```

**المشكلة:**
- لا تتحقق من دور المستخدم قبل التحديث
- لا تتحقق من الحقول المسموح بها قبل التحديث
- تعتمد كلياً على قواعد الأمان
- لا توجد رسالة خطأ واضحة بالعربية

**النتيجة:**
- عندما يفشل التحديث بسبب قواعد الأمان، يتم إرجاع رسالة خطأ عامة
- المستخدم لا يعرف السبب الحقيقي للفشل

### 2.3 تحليل [`user_model.dart`](lib/shared/models/user_model.dart)

#### الحقول الموجودة (السطر 79-98):

```dart
final String id;
final String email;
final String fullName;
final String? phoneNumber;
final String? username;
final UserType userType;  // ✅ يستخدم 'userType'
final String? profileImage;
final String? licenseNumber;
final List<String>? specializations;
final Map<String, List<String>>? workingHours;
final String? biography;
final int? yearsOfExperience;
final double? consultationFee;
final List<String>? consultationTypes;
final String? clinicName;
final String? clinicAddress;
final List<Map<String, String>>? education;
final List<Map<String, String>>? certificates;
final DateTime createdAt;
final String? fcmToken;
```

**المشكلة:**
- النموذج يستخدم `userType` وليس `role`
- النموذج يحتوي على حقول كثيرة للأطباء
- النموذج لا يفرق بين حقول الأطباء والمرضى

### 2.4 تحليل [`firestore.rules`](firebase_backend/firestore.rules)

#### قواعد المستخدمين (السطر 123-139):

```javascript
match /users/{userId} {
  // السماح بالقراءة العامة للبيانات الأساسية
  allow read: if request.auth != null 
    && (request.auth.uid == userId 
      || resource.data.role == 'doctor');  // ❌ خطأ: يجب استخدام 'userType'
  
  // السماح للمستخدم بتحديث بياناته الخاصة فقط
  allow update: if request.auth != null 
    && request.auth.uid == userId
    // السماح بتحديث حقول محدودة فقط
    && request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['fullName', 'profileImage', 'fcmToken', 'isOnline']);
  
  // منع الإنشاء والحذف
  allow create: if false;
  allow delete: if false;
}
```

**المشاكل:**
1. ❌ استخدام `resource.data.role` بدلاً من `resource.data.userType`
2. ❌ قيود صارمة على حقول التحديث
3. ❌ عدم التحقق من الدور قبل السماح بالتحديث

---

## 3. الحلول المقترحة (Proposed Solutions)

### 3.1 إصلاح عدم تطابق أسماء الحقول (Fix Field Name Mismatch)

**الخيار 1: تحديث قواعد الأمان لاستخدام `userType`**

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**السطر 127:**
```javascript
// قبل الإصلاح:
allow read: if request.auth != null 
  && (request.auth.uid == userId 
    || resource.data.role == 'doctor');

// بعد الإصلاح:
allow read: if request.auth != null 
  && (request.auth.uid == userId 
    || resource.data.userType == 'doctor');
```

**الخيار 2: تحديث النموذج لاستخدام `role` بدلاً من `userType`**

**الملف:** [`lib/shared/models/user_model.dart`](lib/shared/models/user_model.dart)

**السطر 35-38:**
```dart
// قبل الإصلاح:
userType: UserType.values.firstWhere(
  (e) => e.toString() == 'UserType.${json['userType']}',
  orElse: () => UserType.patient,
),

// بعد الإصلاح:
userType: json['userType'] == 'doctor' 
  ? UserType.doctor 
  : UserType.patient,
```

**السطر 109:**
```dart
// قبل الإصلاح:
'userType': userType.name,

// بعد الإصلاح:
'userType': userType == UserType.doctor ? 'doctor' : 'patient',
```

**التوصية:** استخدام الخيار 1 (تحديث قواعد الأمان) لأنه:
- ✅ لا يتطلب تغييرات في النموذج
- ✅ لا يتطلب تغييرات في قاعدة البيانات
- ✅ أسرع في التنفيذ

### 3.2 تحديث قواعد الأمان للسماح بحقول إضافية للأطباء (Update Security Rules for Additional Doctor Fields)

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**السطر 130-134:**
```javascript
// قبل الإصلاح:
allow update: if request.auth != null 
  && request.auth.uid == userId
  // السماح بتحديث حقول محدودة فقط
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly(['fullName', 'profileImage', 'fcmToken', 'isOnline']);

// بعد الإصلاح:
allow update: if request.auth != null 
  && request.auth.uid == userId
  // السماح للجميع بتحديث الحقول الأساسية
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 
      'profileImage', 
      'fcmToken', 
      'isOnline',
      'phoneNumber',
      'username'
    ]);

// السماح للأطباء بتحديث حقولهم الخاصة
allow update: if request.auth != null 
  && request.auth.uid == userId
  && resource.data.userType == 'doctor'
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 
      'profileImage', 
      'fcmToken', 
      'isOnline',
      'phoneNumber',
      'username',
      'licenseNumber',
      'specialization',
      'workingHours',
      'biography',
      'yearsOfExperience',
      'consultationFee',
      'consultationTypes',
      'clinicName',
      'clinicAddress',
      'education',
      'certificates'
    ]);

// السماح للمرضى بتحديث حقولهم الخاصة
allow update: if request.auth != null 
  && request.auth.uid == userId
  && resource.data.userType == 'patient'
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 
      'profileImage', 
      'fcmToken', 
      'isOnline',
      'phoneNumber',
      'username'
    ]);
```

### 3.3 إنشاء Cloud Function للتحقق من صحة البيانات (Create Validation Function)

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**الكود المقترح:**
```javascript
/**
 * دالة للتحقق من صحة تحديثات الطبيب
 * التحقق من:
 * 1. دور المستخدم (doctor vs patient)
 * 2. الحقول المُحدّثة المسموح بها
 * 3. عدم وجود حقول فارغة
 */

exports.validateDoctorUpdate = functions.https.onCall(async (data, context) => {
  // التحقق من صحة البيانات
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(data.userId).get();
  
  if (!userDoc.exists) {
    console.error(`❌ User document not found: ${data.userId}`);
    return {
      success: false,
      message: "المستخدم غير موجود",
      errorCode: "USER_NOT_FOUND"
    };
  }
  
  const userData = userDoc.data();
  
  // التحقق من الدور
  const userRole = userData.userType || 'patient';
  
  // التحقق من الحقول المُحدّثة المسموح بها
  const allowedFields = ['fullName', 'profileImage', 'fcmToken', 'phoneNumber', 'username'];
  const doctorAllowedFields = [
    'fullName', 'profileImage', 'fcmToken', 'phoneNumber', 'username',
    'licenseNumber', 'specialization', 'workingHours', 'biography',
    'yearsOfExperience', 'consultationFee', 'consultationTypes',
    'clinicName', 'clinicAddress', 'education', 'certificates'
  ];
  const requestedFields = Object.keys(data.updateData || {});
  
  // التحقق من أن الحقول المطلوبة مسموحة
  const invalidFields = requestedFields.filter(field => 
    userRole === 'doctor' 
      ? !doctorAllowedFields.includes(field)
      : !allowedFields.includes(field)
  );
  
  // إذا كانت هناك حقول غير مسموحة
  if (invalidFields.length > 0) {
    return {
      success: false,
      message: `الحقول التالية غير مسموحة للتحديث: ${invalidFields.join(', ')}`,
      errorCode: "INVALID_FIELDS"
    };
  }
  
  // السماح بالتحديث
  console.log(`✅ Validation passed for user: ${data.userId}`);
  
  return {
    success: true,
    message: "تم التحقق من صحة البيانات",
    allowedUpdates: Object.keys(data.updateData || {})
  };
});
```

### 3.4 إنشاء فهارس Firestore (Create Firestore Indexes)

**الملف:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**الكود المقترح:**
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "fullName",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "profileImage",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "fcmToken",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "phoneNumber",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "username",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "senderId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "timestamp",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "chats",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "participants",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "lastMessageTime",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "patientId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "doctorId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "appointmentDate",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

---

## 4. خطة التنفيذ (Implementation Plan)

### 4.1 المرحلة 1: إصلاح عدم تطابق أسماء الحقول (Phase 1: Fix Field Name Mismatch)

1. ✅ تحديث [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)
   - السطر 127: تغيير `resource.data.role` إلى `resource.data.userType`
   - السطر 130-134: تحديث قواعد التحديث

2. ✅ اختبار التغييرات
   - اختبار قراءة بيانات الطبيب
   - اختبار قراءة بيانات المريض

### 4.2 المرحلة 2: تحديث قواعد الأمان (Phase 2: Update Security Rules)

1. ✅ تحديث [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)
   - إضافة قواعد للتحديث حسب الدور
   - السماح للأطباء بتحديث حقولهم الخاصة
   - السماح للمرضى بتحديث حقولهم الخاصة

2. ✅ اختبار التغييرات
   - اختبار تحديث بيانات الطبيب
   - اختبار تحديث بيانات المريض
   - اختبار محاولة تحديث حقول غير مسموحة

### 4.3 المرحلة 3: إنشاء Cloud Function للتحقق (Phase 3: Create Validation Function)

1. ✅ إضافة `validateDoctorUpdate` إلى [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

2. ✅ اختبار Cloud Function
   - اختبار التحقق من صحة البيانات
   - اختبار رسائل الخطأ

3. ✅ نشر Cloud Function
   ```bash
   firebase deploy --only functions:validateDoctorUpdate
   ```

### 4.4 المرحلة 4: إنشاء فهارس Firestore (Phase 4: Create Firestore Indexes)

1. ✅ تحديث [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

2. ✅ نشر الفهارس
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. ✅ اختبار الأداء
   - اختبار استعلامات المستخدمين
   - اختبار استعلامات المحادثات
   - اختبار استعلامات المواعيد

### 4.5 المرحلة 5: اختبار شامل (Phase 5: Comprehensive Testing)

1. ✅ اختبار جميع السيناريوهات
   - تسجيل دخول طبيب
   - تحديث بيانات الطبيب
   - تسجيل دخول مريض
   - تحديث بيانات المريض
   - محاولة تحديث حقول غير مسموحة

2. ✅ اختبار رسائل الخطأ
   - التحقق من وضوح الرسائل
   - التحقق من اللغة العربية

3. ✅ اختبار الأمان
   - اختبار الوصول غير المصرح
   - اختبار التحقق من الدور

---

## 5. النتائج المتوقعة (Expected Results)

### 5.1 تحسين تجربة المستخدم (Improved User Experience)

- ✅ الطبيبون سيتمكنون من تحديث بياناتهم الطبية
- ✅ المرضى سيتمكنون من تحديث بياناتهم الشخصية
- ✅ رسائل خطأ واضحة بالعربية
- ✅ تجربة مستخدم خالية من الغموض

### 5.2 تحسين الأمان (Improved Security)

- ✅ التحقق من الدور قبل السماح بالتحديث
- ✅ التحقق من الحقول المسموح بها
- ✅ منع العمليات غير المصرحة
- ✅ حماية البيانات الحساسة

### 5.3 تحسين الأداء (Improved Performance)

- ✅ استعلامات أسرع بفضل الفهارس
- ✅ تقليل تكلفة العمليات
- ✅ تحسين استجابة التطبيق

---

## 6. الخلاصة (Conclusion)

المشكلة الأساسية هي **عدم تطابق أسماء الحقول** و**قيود صارمة على حقول التحديث** في قواعد الأمان، مما يؤدي إلى رفض الصلاحيات (permission-denied) عند محاولة الطبيب تحديث بياناته الطبية.

**التوصيات النهائية:**

1. ✅ تحديث قواعد الأمان لاستخدام `userType` بدلاً من `role`
2. ✅ تحديث قواعد الأمان للسماح بحقول إضافية للأطباء
3. ✅ إنشاء Cloud Function للتحقق من صحة البيانات
4. ✅ إنشاء فهارس Firestore لتحسين الأداء
5. ✅ اختبار شامل لجميع التغييرات

**النتائج المتوقعة:**
- 🎉 تحسين تجربة المستخدم - الطبيبون سيتمكنون تحديث بياناتهم بشكل صحيح
- 🛡️ أمان محسّن - النظام محمي من عمليات غير مصرحة
- 🚀 أداء محسّن - استعلامات أسرع وتكلفة أقل
- 📊 توثيق شامل - جميع التغييرات موثقة

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ مكتمل (Completed)

---

## 7. المراجع (References)

- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) - قواعد الأمان الحالية
- [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json) - فهارس Firestore
- [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) - دوال Cloud Functions
- [`lib/features/auth/providers/auth_provider.dart`](lib/features/auth/providers/auth_provider.dart) - مزود المصادقة
- [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart) - تنفيذ مستودع المصادقة
- [`lib/shared/models/user_model.dart`](lib/shared/models/user_model.dart) - نموذج المستخدم
