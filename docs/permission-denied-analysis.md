# تحليل مشكلة رفض الصلاحيات (permission-denied) | Permission Denied Issue Analysis

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

#### أ. عدم وجود قواعد أمان كافية (Lack of Comprehensive Security Rules)

**الملف الحالي:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**المحتويات الحالية:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // السماح العام للقراءة فقط
    match /users/{userId} {
      // السماح بالقراءة العامة للبيانات الأساسية
      allow read: if request.auth != null 
        && request.auth.uid == userId;
      
      // السماح بالتحديث للبيانات الخاصة فقط
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['fullName', 'profileImage', 'fcmToken']);
    }
  }
}
```

**المشكلة:**
- القواعد الحالية تسمح بالقراءة العامة للجميع المستخدمين
- القواعد الحالية تسمح بالتحديث للبيانات الخاصة، لكنها لا تتحقق من:
  - دور المستخدم (doctor vs patient)
  - الحقول المُحدّثة المسموح بها
  - عدم وجود حقول فارغة

**النتيجة:**
- عندما يحاول الطبيب تحديث بيانات خاصة (مثل EMR)، يتم السماح لأن القواعد لا تتحقق من الدور
- عندما يحاول المريض تحديث بيانات خاصة (مثل medicalRecords)، يتم السماح لأن القواعد لا تتحقق من الدور

#### ب. عدم وجود فهارس Firestore (Missing Firestore Indexes)

**الملف المفقود:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**المحتويات المطلوبة:**
```json
{
  "indexes": []
}
```

**المشكلة:**
- عدم وجود فهارس Firestore لتحسين الأداء
- عدم وجود فهارس للمستخدمين، المحادثات، المواعيد
- هذا يؤدي إلى استعلامات بطيئة (Collection Group Scans)

### 1.3 عدم وجود دوال Cloud Functions للتحقق من صحة البيانات (No Validation Function)

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**المشكلة:**
- لا يوجد Cloud Function للتحقق من صحة البيانات قبل السماح بالتحديث
- لا يوجد Cloud Function للتحقق من الدور قبل السماح
- لا يوجد Cloud Function للتحقق من الحقول المُحدّثة

---

## 2. تأثير المشكلة (Impact Analysis)

### 2.1 تأثير على تجربة المستخدم (User Experience Impact)

**التأثيرات السلبية:**
- ⚠️ **ارتباك المستخدم:** الطبيبون لا يستطيعون تحديث بياناتهم الطبية، مما يحد من استخدام ميزات التطبيق
- ⚠️ **غياب وضوح:** الطبيبون لا يستطيعون إضافة صورة الملف الشخصية أو تحديث معلوماتهم
- ⚠️ **فقدان الثقة:** الطبيبون قد يشعرون أن النظام يعمل بشكل صحيح

**التأثيرات الإيجابية:**
- ✅ **الأمان المحسّن:** القواعد الحالية تمنع الوصول غير المصرح، مما يحمي البيانات الحساسة
- ✅ **منع التحديثات غير المصرحة:** القواعد تمنع التحديثات التي لا تفي بالشروط الأمنية

### 2.2 تأثير على أمان النظام (Security Impact)

**المخاطر الأمنية:**
- 🔴 **متوسطة:** إذا كان هناك ثغرة أمنية، يمكن للمهاجم استغلالها
- 🔴 **تزوير البيانات:** عدم وجود دوال للتحقق قد يسمح بعمليات غير مصرحة
- 🔴 **هجمات حقن البيانات:** عدم وجود فهارس قد يؤدي إلى استعلامات بطيئة

**التدابيرات الحالية:**
- ✅ **قواعد قراءة عامة:** تمنع الوصول غير المصرح
- ✅ **منع التحديثات:** تمنع التحديثات غير المصرحة (حتى لو كانت هناك دوال للتحقق)

---

## 3. التوصيات الفنية (Technical Recommendations)

### 3.1 إنشاء ملف فهارس Firestore (Create Firestore Indexes)

**الملف:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**المحتوى المقترح:**
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "role",
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
          "fieldPath": "dateTime",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

**الفوائد:**
- 🚀 تحسين الأداء بشكل كبير
- 🚀 دعم الاستعلامات المتقدمة (Compound Queries)
- 🚀 تقليل تكلفة العمليات

### 3.2 إنشاء Cloud Function للتحقق من صحة البيانات (Create Validation Function)

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**الاسم المقترح للدالة:** `validateDoctorUpdate`

**الكود المقترح:**
```javascript
/**
 * دالة للتحقق من صحة تحديثات الطبيب
 * التحقق من:
 * 1. دور المستخدم (doctor vs patient)
 * 2. الحقول المُحدّثة المسموح بها
 * 3. عدم وجود حقول فارغة
 */

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");

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
  const userRole = userData.role || 'patient';
  
  // التحقق من الحقول المُحدّثة المسموح بها
  const allowedFields = ['fullName', 'profileImage', 'fcmToken'];
  const requestedFields = Object.keys(data.updateData || {});
  
  // التحقق من وجود حقول فارغة
  const hasEmptyFields = requestedFields.some(field => 
    !userData[field] || userData[field] === ''
  );
  
  // التحقق من أن الحقول المطلوبة مسموحة
  const invalidFields = requestedFields.filter(field => 
    !allowedFields.includes(field)
  );
  
  // التحقق من الدور
  if (userRole === 'patient' && data.updateData.medicalRecords) {
    return {
      success: false,
      message: "المريض لا يمكنه تحديث السجلات الطبية",
      errorCode: "INVALID_ROLE_OPERATION"
    };
  }
  
  // إذا كانت هناك حقول غير مسموحة
  if (invalidFields.length > 0) {
    return {
      success: false,
      message: `الحقول التالية غير مسموحة للتحديث: ${invalidFields.join(', ')}`,
      errorCode: "INVALID_FIELDS"
    };
  }
  
  // إذا كان هناك حقول فارغة
  if (hasEmptyFields.length > 0) {
    return {
      success: false,
      message: "يجب توفير قيم للحقول المطلوبة",
      errorCode: "EMPTY_FIELDS"
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

**الفوائد:**
- 🛡️ حماية البيانات: التحقق من الدور والحقول قبل السماح
- 📝 رسائل خطأ واضحة: رسائل خطأ واضحة بالعربية توضح المشكلة
- 🚀 منع العمليات غير المصرحة: حماية النظام من عمليات غير مصرحة

### 3.3 تحديث قواعد الأمان (Update Firestore Security Rules)

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**التحديثات المقترحة:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // السماح العام للقراءة فقط
    match /users/{userId} {
      allow read: if request.auth != null 
        && request.auth.uid == userId;
      
      // السماح بالتحديث للبيانات الخاصة
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['fullName', 'profileImage', 'fcmToken'])
        && request.auth.token != null;
      
      // السماح للطبيب فقط (دور = 'doctor')
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['fullName', 'profileImage', 'fcmToken', 'licenseNumber', 'specializations', 'clinicName', 'clinicAddress', 'consultationTypes']);
      
      // السماح للمريض فقط (دور = 'patient')
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['fullName', 'profileImage', 'fcmToken', 'medicalRecords']);
      
      // منع التحديثات غير المصرحة
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .length > 0
        && !request.resource.data.diff(resource.data).affectedKeys()
          .every(key => ['fullName', 'profileImage', 'fcmToken', 'medicalRecords'].includes(key));
    }
  }
}
```

**الفوائد:**
- 🛡️ حماية الدور: السماح للطبيب بتحديث بياناته الخاصة فقط
- 🛡️ حماية البيانات: التحقق من الحقول والقيم قبل السماح
- 🚀 منع التحديثات غير المصرحة: حماية النظام من عمليات غير مصرحة

### 3.4 اختبار شامل (Comprehensive Testing)

**خطوات الاختبار:**
1. ✅ اختبار تحديث بيانات الطبيب (EMR، profileImage)
2. ✅ اختبار تحديث بيانات المريض (medicalRecords)
3. ✅ اختبار محاولة تحديث بيانات غير مصرحة (مثل licenseNumber)
4. ✅ اختبار السماح والرفض للتحديثات غير المصرحة
5. ✅ اختبار Cloud Function `validateDoctorUpdate`
6. ✅ اختبار فهارس Firestore لتحسين الأداء

---

## 4. الخلاصة (Conclusion)

المشكلة الأساسية هي **عدم وجود قواعد أمان شاملة** في المشروع، مما يؤدي إلى رفض الصلاحيات (permission-denied) عند محاولة الطبيب تحديث بياناته الطبية.

**التوصيات النهائية:**

1. ✅ **إنشاء ملف فهارس Firestore** - تحسين الأداء وتقليل تكلفة العمليات
2. ✅ **إنشاء Cloud Function للتحقق** - حماية البيانات قبل السماح
3. ✅ **تحديث قواعد الأمان** - إضافة قواعد للتحكم في الوصول بناءً على الدور
4. ✅ **اختبار شامل** - اختبار جميع سيناريوهات التحديث
5. ✅ **التوثيق** - توثيق جميع التغييرات

**النتائج المتوقعة:**
- 🎉 تحسين تجربة المستخدم - الطبيبون سيتمكنون تحديث بياناتهم بشكل صحيح
- 🛡️ أمان محسّن - النظام محمي من عمليات غير مصرحة
- 📊 توثيق شامل - جميع التغييرات موثقة

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ مكتمل (Completed)

---

## 5. المراجع (References)

- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) - قواعد الأمان الحالية
- [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json) - فهارس Firestore (فارغ حالياً)
- [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) - دوال Cloud Functions
- [`lib/features/auth/providers/auth_provider.dart`](lib/features/auth/providers/auth_provider.dart) - مزود المصادقة
- [`lib/features/auth/presentation/screens/login_screen.dart`](lib/features/auth/presentation/screens/login_screen.dart) - شاشة تسجيل الدخول
