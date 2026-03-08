# دليل نشر Firebase CLI | Firebase CLI Deployment Guide

**التاريخ:** 2026-01-13  
**المهندس:** مهندس ضمان جودة (QA Engineer)  
**المشروع:** ElajTech - تطبيق المركز الطبي (AndroCare360)

---

## 📋 ملخص التغييرات (Summary of Changes)

تم تنفيذ الحلول التالية لمشكلة رفض الصلاحيات (permission-denied):

### 1. ✅ تحديث قواعد الأمان (Firestore Security Rules)

**الملف:** [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules)

**التغييرات:**
- ✅ إصلاح `resource.data.role` إلى `resource.data.userType` للتوافق مع UserModel
- ✅ إضافة قواعد للتحديث حسب الدور (doctor vs patient)
- ✅ السماح للأطباء بتحديث حقولهم المهنية:
  - `licenseNumber`, `specialization`, `workingHours`, `biography`
  - `yearsOfExperience`, `consultationFee`, `consultationTypes`
  - `clinicName`, `clinicAddress`, `education`, `certificates`
- ✅ السماح للمرضى بتحديث حقولهم الشخصية:
  - `fullName`, `profileImage`, `fcmToken`, `isOnline`, `phoneNumber`, `username`

### 2. ✅ إضافة Cloud Function للتحقق (Validation Function)

**الملف:** [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js)

**التغييرات:**
- ✅ إضافة دالة `validateDoctorUpdate` للتحقق من صحة البيانات
- ✅ التحقق من دور المستخدم (doctor vs patient)
- ✅ التحقق من الحقول المسموح بها لكل دور
- ✅ إرسال رسائل خطأ واضحة بالعربية

### 3. ✅ تحديث فهارس Firestore (Firestore Indexes)

**الملف:** [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json)

**التغييرات:**
- ✅ إضافة فهارس للمستخدمين (userType, fullName, profileImage, fcmToken, phoneNumber, username, specialization, clinicName)
- ✅ إضافة فهارس للمحادثات (participants, lastMessageTime, createdAt)
- ✅ إضافة فهارس للرسائل (senderId, timestamp, chatId)
- ✅ إضافة فهارس للمواعيد (patientId, doctorId, status, appointmentDate, type)

### 4. ✅ تحسين معالجة الأخطاء في Flutter Layer

**الملف:** [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart)

**التغييرات:**
- ✅ إضافة معالجة خاصة لخطأ `permission-denied`
- ✅ إضافة دالة `_mapFirestoreError` لتحويل أخطاء Firestore إلى رسائل عربية واضحة
- ✅ اتباع نمط `Either<Failure, Success>` من طبقة Domain

---

## 🚀 أوامر نشر Firebase CLI (Firebase CLI Deployment Commands)

### المتطلبات المسبقة (Prerequisites)

1. **تثبيت Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **تسجيل الدخول إلى Firebase:**
   ```bash
   firebase login
   ```

3. **التحقق من المشروع:**
   ```bash
   firebase projects:list
   ```

### خطوة 1: نشر قواعد الأمان (Deploy Firestore Security Rules)

```bash
# الانتقال إلى مجلد firebase_backend
cd firebase_backend

# نشر قواعد الأمان فقط
firebase deploy --only firestore:rules
```

**النتيجة المتوقعة:**
```
✔  firestore: rules firestore.rules (xxx B) compiled successfully
✔  firestore: rules firestore.rules (xxx B) uploaded successfully
```

### خطوة 2: نشر Cloud Functions (Deploy Cloud Functions)

```bash
# نشر جميع دوال السحاب
firebase deploy --only functions
```

**النتيجة المتوقعة:**
```
✔  functions: Finished running predeploy script.
i  functions: ensuring necessary APIs are enabled...
✔  functions: all necessary APIs are enabled
i  functions: preparing functions directory for uploading...
✔  functions: functions folder uploaded successfully
i  functions: current functions in project: generateMeetLink(xxx), sendAppointmentReminders(xxx), sendChatNotification(xxx), validateDoctorUpdate(xxx)
✔  functions: Node.js 18 modules loaded successfully
i  functions: uploading functions in project...
✔  functions[generateMeetLink]: Successful update operation.
✔  functions[sendAppointmentReminders]: Successful update operation.
✔  functions[sendChatNotification]: Successful update operation.
✔  functions[validateDoctorUpdate]: Successful create operation.
✔  Deploy complete!
```

### خطوة 3: نشر فهارس Firestore (Deploy Firestore Indexes)

```bash
# نشر الفهارس فقط
firebase deploy --only firestore:indexes
```

**النتيجة المتوقعة:**
```
✔  firestore: indexes firestore.indexes.json uploaded successfully
i  firestore: creating indexes...
✔  firestore: indexes created successfully
```

### خطوة 4: نشر كل شيء دفعة واحدة (Deploy All at Once)

```bash
# نشر كل شيء (قواعد الأمان، دوال السحاب، والفهارس)
firebase deploy --only firestore,functions
```

**النتيجة المتوقعة:**
```
✔  firestore: rules firestore.rules (xxx B) compiled successfully
✔  firestore: rules firestore.rules (xxx B) uploaded successfully
✔  firestore: indexes firestore.indexes.json uploaded successfully
i  firestore: creating indexes...
✔  firestore: indexes created successfully
✔  functions: Finished running predeploy script.
i  functions: ensuring necessary APIs are enabled...
✔  functions: all necessary APIs are enabled
i  functions: preparing functions directory for uploading...
✔  functions: functions folder uploaded successfully
i  functions: current functions in project: generateMeetLink(xxx), sendAppointmentReminders(xxx), sendChatNotification(xxx), validateDoctorUpdate(xxx)
✔  functions: Node.js 18 modules loaded successfully
i  functions: uploading functions in project...
✔  functions[generateMeetLink]: Successful update operation.
✔  functions[sendAppointmentReminders]: Successful update operation.
✔  functions[sendChatNotification]: Successful update operation.
✔  functions[validateDoctorUpdate]: Successful create operation.
✔  Deploy complete!
```

---

## ✅ التحقق من النشر (Verify Deployment)

### 1. التحقق من قواعد الأمان (Verify Security Rules)

**طريقة 1: Firebase Console**
1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. انتقل إلى **Firestore Database** > **Rules**
4. تأكد من أن القواعد محدثة

**طريقة 2: Firebase CLI**
```bash
firebase firestore:rules
```

### 2. التحقق من Cloud Functions (Verify Cloud Functions)

**طريقة 1: Firebase Console**
1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. انتقل إلى **Functions**
4. تأكد من وجود دالة `validateDoctorUpdate`

**طريقة 2: Firebase CLI**
```bash
firebase functions:list
```

**النتيجة المتوقعة:**
```
✔  Functions List
  ├─ generateMeetLink (europe-west1)
  ├─ sendAppointmentReminders (europe-west1)
  ├─ sendChatNotification (europe-west1)
  └─ validateDoctorUpdate (europe-west1)  ✅ دالة جديدة
```

### 3. التحقق من فهارس Firestore (Verify Firestore Indexes)

**طريقة 1: Firebase Console**
1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. انتقل إلى **Firestore Database** > **Indexes**
4. تأكد من وجود الفهارس الجديدة

**طريقة 2: Firebase CLI**
```bash
firebase firestore:indexes
```

---

## 🧪 اختبار النشر (Test Deployment)

### اختبار 1: تحديث بيانات الطبيب (Update Doctor Data)

**الخطوات:**
1. تسجيل دخول كطبيب
2. محاولة تحديث `licenseNumber`
3. محاولة تحديث `workingHours`
4. محاولة تحديث `biography`

**النتيجة المتوقعة:**
- ✅ التحديثات تنجح بدون أخطاء
- ✅ لا يظهر خطأ `permission-denied`

### اختبار 2: تحديث بيانات المريض (Update Patient Data)

**الخطوات:**
1. تسجيل دخول كمريض
2. محاولة تحديث `fullName`
3. محاولة تحديث `profileImage`

**النتيجة المتوقعة:**
- ✅ التحديثات تنجح بدون أخطاء
- ✅ لا يظهر خطأ `permission-denied`

### اختبار 3: محاولة تحديث حقول غير مسموحة (Attempt to Update Invalid Fields)

**الخطوات:**
1. تسجيل دخول كمريض
2. محاولة تحديث `licenseNumber` (حقل طبيب فقط)

**النتيجة المتوقعة:**
- ❌ التحديث يفشل
- ✅ تظهر رسالة خطأ واضحة بالعربية:
  ```
  لا تملك الصلاحية اللازمة لتحديث هذه البيانات. يرجى التأكد من أنك تحديث حقول مسموحة لدورك.
  ```

### اختبار 4: اختبار Cloud Function (Test Cloud Function)

**الخطوات:**
1. استدعاء دالة `validateDoctorUpdate` من Flutter
2. تمرير بيانات صحيحة
3. تمرير بيانات غير صحيحة

**النتيجة المتوقعة:**
- ✅ الدالة تتحقق من صحة البيانات
- ✅ تُرجع رسائل خطأ واضحة بالعربية

---

## 📊 الملفات المعدلة (Modified Files)

| الملف | التغييرات | الأولوية |
|-------|-----------|----------|
| [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) | تحديث قواعد الأمان | 🔴 حرجة |
| [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) | إضافة Cloud Function للتحقق | 🟡 متوسطة |
| [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json) | إنشاء فهارس Firestore | 🟡 متوسطة |
| [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart) | تحسين معالجة الأخطاء | 🟡 متوسطة |

---

## 🎯 النتائج المتوقعة (Expected Results)

### تحسين تجربة المستخدم
- ✅ الطبيبون سيتمكنون من تحديث بياناتهم الطبية
- ✅ المرضى سيتمكنون من تحديث بياناتهم الشخصية
- ✅ رسائل خطأ واضحة ومهنية بالعربية
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

## 🔗 المراجع (References)

- [`docs/permission-denied-detailed-analysis.md`](docs/permission-denied-detailed-analysis.md) - تحليل مفصل
- [`docs/permission-denied-summary.md`](docs/permission-denied-summary.md) - ملخص تنفيذي
- [`firebase_backend/firestore.rules`](firebase_backend/firestore.rules) - قواعد الأمان المحدثة
- [`firebase_backend/functions/index.js`](firebase_backend/functions/index.js) - دوال Cloud Functions المحدثة
- [`firebase_backend/firestore.indexes.json`](firebase_backend/firestore.indexes.json) - فهارس Firestore المحدثة
- [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart) - تنفيذ مستودع المصادقة المحدث

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ مكتمل (Completed)
