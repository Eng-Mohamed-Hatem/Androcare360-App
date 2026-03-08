# ملخص تحليل مشكلة رفض الصلاحيات (permission-denied) | Summary

**التاريخ:** 2026-01-13  
**المهندس:** مهندس ضمان جودة (QA Engineer)  
**المشروع:** ElajTech - تطبيق المركز الطبي (AndroCare360)

---

## 🎯 المشكلة (Problem)

عند محاولة الطبيب تحديث بياناته الطبية (EMR، وصفات، وتاليل) في قاعدة بيانات Firestore، يظهر خطأ:

```
Error: Missing or insufficient permissions
Error: Permission denied
```

---

## 🔍 السبب الجذري (Root Cause)

تم تحديد **3 مشاكل رئيسية**:

### 1. عدم تطابق أسماء الحقول (Field Name Mismatch)

| النموذج (Model) | قواعد الأمان (Rules) |
|-------------------|----------------------|
| `userType` (enum) | `role` (string) ❌ |

**الملفات المتأثرة:**
- [`lib/shared/models/user_model.dart`](lib/shared/models/user_model.dart:35-38, 109)
- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules:127)

**التأثير:**
- عندما يتحقق Firestore من `resource.data.role == 'doctor'`، الحقل غير موجود
- النموذج يخزن `userType: 'doctor'` وليس `role: 'doctor'`
- هذا يؤدي إلى فشل التحقق من الدور

### 2. قيود صارمة على حقول التحديث (Strict Field Update Constraints)

**الحقول المسموح بها حالياً:**
```javascript
['fullName', 'profileImage', 'fcmToken', 'isOnline']
```

**الحقول المطلوبة للأطباء:**
```javascript
[
  'fullName', 'profileImage', 'fcmToken', 'isOnline',
  'licenseNumber', 'specialization', 'workingHours', 'biography',
  'yearsOfExperience', 'consultationFee', 'consultationTypes',
  'clinicName', 'clinicAddress', 'education', 'certificates'
]
```

**الملف المتأثر:**
- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules:130-134)

**التأثير:**
- عندما يحاول الطبيب تحديث `licenseNumber` أو `specializations`، يتم الرفض
- عندما يحاول الطبيب تحديث `workingHours` أو `biography`، يتم الرفض

### 3. عدم وجود Cloud Function للتحقق (No Validation Function)

**المشكلة:**
- لا يوجد Cloud Function للتحقق من صحة البيانات قبل السماح بالتحديث
- لا يوجد Cloud Function للتحقق من الدور قبل السماح
- لا يوجد Cloud Function للتحقق من الحقول المُحدّثة

**الملف المتأثر:**
- [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**التأثير:**
- عدم وجود طبقة تحقق إضافية على مستوى الخادم
- الاعتماد الكامل على قواعد الأمان فقط
- عدم وجود رسائل خطأ واضحة للمستخدم

---

## ✅ الحلول المقترحة (Proposed Solutions)

### الحل 1: تحديث قواعد الأمان (Update Security Rules)

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**التغييرات المطلوبة:**

1. **إصلاح عدم تطابق أسماء الحقول:**
```javascript
// قبل الإصلاح:
allow read: if request.auth != null 
  && (request.auth.uid == userId 
    || resource.data.role == 'doctor');  // ❌ خطأ

// بعد الإصلاح:
allow read: if request.auth != null 
  && (request.auth.uid == userId 
    || resource.data.userType == 'doctor');  // ✅ صحيح
```

2. **تحديث قواعد التحديث:**
```javascript
// السماح للجميع بتحديث الحقول الأساسية
allow update: if request.auth != null 
  && request.auth.uid == userId
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 'profileImage', 'fcmToken', 'isOnline',
      'phoneNumber', 'username'
    ]);

// السماح للأطباء بتحديث حقولهم الخاصة
allow update: if request.auth != null 
  && request.auth.uid == userId
  && resource.data.userType == 'doctor'
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 'profileImage', 'fcmToken', 'isOnline',
      'phoneNumber', 'username',
      'licenseNumber', 'specialization', 'workingHours', 'biography',
      'yearsOfExperience', 'consultationFee', 'consultationTypes',
      'clinicName', 'clinicAddress', 'education', 'certificates'
    ]);

// السماح للمرضى بتحديث حقولهم الخاصة
allow update: if request.auth != null 
  && request.auth.uid == userId
  && resource.data.userType == 'patient'
  && request.resource.data.diff(resource.data).affectedKeys()
    .hasOnly([
      'fullName', 'profileImage', 'fcmToken', 'isOnline',
      'phoneNumber', 'username'
    ]);
```

### الحل 2: إنشاء Cloud Function للتحقق (Create Validation Function)

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**الكود المقترح:**
```javascript
exports.validateDoctorUpdate = functions.https.onCall(async (data, context) => {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(data.userId).get();
  
  if (!userDoc.exists) {
    return {
      success: false,
      message: "المستخدم غير موجود",
      errorCode: "USER_NOT_FOUND"
    };
  }
  
  const userData = userDoc.data();
  const userRole = userData.userType || 'patient';
  
  const doctorAllowedFields = [
    'fullName', 'profileImage', 'fcmToken', 'phoneNumber', 'username',
    'licenseNumber', 'specialization', 'workingHours', 'biography',
    'yearsOfExperience', 'consultationFee', 'consultationTypes',
    'clinicName', 'clinicAddress', 'education', 'certificates'
  ];
  
  const requestedFields = Object.keys(data.updateData || {});
  const invalidFields = requestedFields.filter(field => 
    userRole === 'doctor' 
      ? !doctorAllowedFields.includes(field)
      : !['fullName', 'profileImage', 'fcmToken', 'phoneNumber', 'username'].includes(field)
  );
  
  if (invalidFields.length > 0) {
    return {
      success: false,
      message: `الحقول التالية غير مسموحة للتحديث: ${invalidFields.join(', ')}`,
      errorCode: "INVALID_FIELDS"
    };
  }
  
  return {
    success: true,
    message: "تم التحقق من صحة البيانات",
    allowedUpdates: Object.keys(data.updateData || {})
  };
});
```

### الحل 3: إنشاء فهارس Firestore (Create Firestore Indexes)

**الملف:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**الكود المقترح:**
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userType", "order": "ASCENDING"},
        {"fieldPath": "fullName", "order": "ASCENDING"},
        {"fieldPath": "profileImage", "order": "ASCENDING"},
        {"fieldPath": "fcmToken", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "messages",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "senderId", "order": "ASCENDING"},
        {"fieldPath": "timestamp", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "chats",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "participants", "arrayConfig": "CONTAINS"},
        {"fieldPath": "lastMessageTime", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "patientId", "order": "ASCENDING"},
        {"fieldPath": "doctorId", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "appointmentDate", "order": "ASCENDING"}
      ]
    }
  ]
}
```

---

## 📋 خطة التنفيذ (Implementation Plan)

### المرحلة 1: تحديث قواعد الأمان
1. تحديث [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)
   - إصلاح `resource.data.role` إلى `resource.data.userType`
   - إضافة قواعد للتحديث حسب الدور

2. نشر القواعد:
   ```bash
   firebase deploy --only firestore:rules
   ```

3. اختبار التغييرات:
   - اختبار تحديث بيانات الطبيب
   - اختبار تحديث بيانات المريض

### المرحلة 2: إنشاء Cloud Function
1. إضافة `validateDoctorUpdate` إلى [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

2. نشر Cloud Function:
   ```bash
   firebase deploy --only functions:validateDoctorUpdate
   ```

3. اختبار Cloud Function:
   - اختبار التحقق من صحة البيانات
   - اختبار رسائل الخطأ

### المرحلة 3: إنشاء فهارس Firestore
1. تحديث [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

2. نشر الفهارس:
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. اختبار الأداء:
   - اختبار استعلامات المستخدمين
   - اختبار استعلامات المحادثات
   - اختبار استعلامات المواعيد

### المرحلة 4: اختبار شامل
1. اختبار جميع السيناريوهات:
   - تسجيل دخول طبيب
   - تحديث بيانات الطبيب
   - تسجيل دخول مريض
   - تحديث بيانات المريض
   - محاولة تحديث حقول غير مسموحة

2. اختبار رسائل الخطأ:
   - التحقق من وضوح الرسائل
   - التحقق من اللغة العربية

3. اختبار الأمان:
   - اختبار الوصول غير المصرح
   - اختبار التحقق من الدور

---

## 🎉 النتائج المتوقعة (Expected Results)

### تحسين تجربة المستخدم
- ✅ الطبيبون سيتمكنون من تحديث بياناتهم الطبية
- ✅ المرضى سيتمكنون من تحديث بياناتهم الشخصية
- ✅ رسائل خطأ واضحة بالعربية
- ✅ تجربة مستخدم خالية من الغموض

### تحسين الأمان
- ✅ التحقق من الدور قبل السماح بالتحديث
- ✅ التحقق من الحقول المسموح بها
- ✅ منع العمليات غير المصرحة
- ✅ حماية البيانات الحساسة

### تحسين الأداء
- ✅ استعلامات أسرع بفضل الفهارس
- ✅ تقليل تكلفة العمليات
- ✅ تحسين استجابة التطبيق

---

## 📊 الملفات المتأثرة (Affected Files)

| الملف | التغييرات | الأولوية |
|-------|-----------|----------|
| [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) | تحديث قواعد الأمان | 🔴 حرجة |
| [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) | إضافة Cloud Function للتحقق | 🟡 متوسطة |
| [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json) | إنشاء فهارس Firestore | 🟡 متوسطة |

---

## 🔗 المراجع (References)

- [`docs/permission-denied-detailed-analysis.md`](docs/permission-denied-detailed-analysis.md) - تحليل مفصل
- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) - قواعد الأمان
- [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) - دوال Cloud Functions
- [`lib/features/auth/providers/auth_provider.dart`](lib/features/auth/providers/auth_provider.dart) - مزود المصادقة
- [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart) - تنفيذ مستودع المصادقة
- [`lib/shared/models/user_model.dart`](lib/shared/models/user_model.dart) - نموذج المستخدم

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ مكتمل (Completed)
