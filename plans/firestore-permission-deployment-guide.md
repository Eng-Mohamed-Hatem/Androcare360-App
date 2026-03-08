// ignore_for_file: all  
// ignore_for_file: all
# 🚀 دليل نشر وحل مشكلة Permission-Denied على الأجهزة الحقيقية
# Deployment Guide for Permission-Denied Fix on Real Devices

## 📋 ملخص التغييرات | Summary of Changes

### 1. تحديث قواعد الأمان (Firestore Security Rules)
- **الملف**: [`firestore.rules`](../firestore.rules)
- **التغييرات**:
  - إضافة قواعد الوصول للمجموعات الفرعية تحت appointments (السطر 56-68)
  - استخدام `{path=**}` للسماح بالوصول العميق
  - التحقق من دور الطبيب من وثيقة المستخدم باستخدام `userType`

### 2. إنشاء خدمة تحديث Token (Token Refresh Service)
- **الملف الجديد**: [`lib/core/services/token_refresh_service.dart`](../lib/core/services/token_refresh_service.dart)
- **الوظيفة**: تحديث Firebase Auth Token بشكل إجباري على الأجهزة الحقيقية

### 3. تحديث مستودع المصادقة (Auth Repository)
- **الملف**: [`lib/features/auth/data/repositories/auth_repository_impl.dart`](../lib/features/auth/data/repositories/auth_repository_impl.dart)
- **التغييرات**:
  - دمج TokenRefreshService (السطر 7, 18, 22)
  - تحديث Token قبل عمليات التحديث (السطر 247-258)
  - إعادة المحاولة عند خطأ permission-denied (السطر 273-316)
  - معالجة أخطاء Firestore محسّنة (السطر 327-360)

---

## 📦 أوامر النشر (Deployment Commands)

### الخطوة 1: نشر قواعد الأمان إلى Firebase

```bash
# الانتقال إلى مجلد firebase_backend
cd firebase_backend

# نشر قواعد الأمان فقط
firebase deploy --only firestore:rules
```

**النتيجة المتوقعة**:
```
✔ firestore.rules: rules/firestore.rules (1.3 KB)
✔ firestore.rules: compiled successfully

✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project/overview
```

### الخطوة 2: التحقق من نجاح النشر

```bash
# التحقق من قواعد الأمان الحالية
firebase firestore:rules --project your-project-id
```

### الخطوة 3: إعادة بناء التطبيق (Rebuild App)

```bash
# العودة إلى مجلد المشروع الرئيسي
cd ..

# تنظيف البناء السابق
flutter clean

# الحصول على الاعتمادات
flutter pub get

# توليد الكود المطلوب (إذا كان هناك code generation)
dart run build_runner build --delete-conflicting-outputs

# بناء التطبيق للجهاز الحقيقي
flutter build apk --release
# أو
flutter build ios --release
```

### الخطوة 4: تثبيت التطبيق على الجهاز الحقيقي

```bash
# تثبيت APK على جهاز Android متصل
flutter install --release

# أو تثبيت APK يدوياً
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 اختبار الدخان (Smoke Test)

### اختبار 1: حفظ EMR (Electronic Medical Record)

**الخطوات**:
1. تسجيل الدخول كطبيب على الجهاز الحقيقي
2. فتح قائمة المواعيد
3. اختيار موعد مع مريض
4. الانتقال إلى شاشة السجلات الطبية (EMR)
5. إنشاء سجل طبي جديد
6. حفظ السجل الطبي

**النتيجة المتوقعة**:
- ✅ يتم حفظ السجل الطبي بنجاح
- ✅ لا يظهر خطأ `permission-denied`
- ✅ تظهر رسالة نجاح واضحة

**التحقق من السجلات**:
```bash
# فتح سجلات التطبيق
adb logcat | grep -i "elajtech"

# البحث عن رسائل التحديث
adb logcat | grep -i "AuthRepositoryImpl"
```

**السجلات المتوقعة**:
```
✅ AuthRepositoryImpl: Token refreshed successfully before update
📤 AuthRepositoryImpl: Updating user with userType: doctor
✅ AuthRepositoryImpl: User updated successfully
```

### اختبار 2: حفظ وصفة طبية (Prescription)

**الخطوات**:
1. من نفس الموعد، الانتقال إلى شاشة الوصفات الطبية
2. إنشاء وصفة طبية جديدة
3. إضافة الأدوية والتعليمات
4. حفظ الوصفة الطبية

**النتيجة المتوقعة**:
- ✅ يتم حفظ الوصفة الطبية بنجاح
- ✅ لا يظهر خطأ `permission-denied`
- ✅ تظهر الوصفة في قائمة الوصفات

### اختبار 3: حفظ طلب فحص مخبري (Lab Request)

**الخطوات**:
1. من شاشة الموعد، الانتقال إلى طلبات الفحوصات المخبرية
2. إنشاء طلب فحص مخبري جديد
3. اختيار أنواع الفحوصات المطلوبة
4. حفظ الطلب

**النتيجة المتوقعة**:
- ✅ يتم حفظ الطلب بنجاح
- ✅ لا يظهر خطأ `permission-denied`

### اختبار 4: حفظ طلب أشعة (Radiology Request)

**الخطوات**:
1. من شاشة الموعد، الانتقال إلى طلبات الأشعة
2. إنشاء طلب أشعة جديد
3. اختيار نوع الأشعة المطلوبة
4. حفظ الطلب

**النتيجة المتوقعة**:
- ✅ يتم حفظ الطلب بنجاح
- ✅ لا يظهر خطأ `permission-denied`

---

## 🔍 التحقق من الأداء (Performance Verification)

### 1. التحقق من سرعة حفظ البيانات

```bash
# مراقبة وقت الاستجابة
adb logcat | grep -i "firestore"
```

**المقاييس المتوقعة**:
- ⚡ وقت الاستجابة: < 2 ثانية
- ⚡ معدل النجاح: 100%

### 2. التحقق من استخدام الشبكة

```bash
# مراقبة حركة البيانات
adb shell dumpsys netstats | grep -A 20 "elajtech"
```

---

## 🐛 استكشاف الأخطاء (Troubleshooting)

### المشكلة 1: استمرار خطأ permission-denied

**الحل**:
```bash
# 1. التحقق من قواعد الأمان
firebase firestore:rules --project your-project-id

# 2. التحقق من وثيقة المستخدم
# افتح Firebase Console -> Firestore -> users -> {user-id}
# تأكد من أن حقل userType موجود وقيمته 'doctor'

# 3. تسجيل الخروج والدخول مرة أخرى
# من التطبيق: Settings -> Logout -> Login
```

### المشكلة 2: فشل تحديث Token

**الحل**:
```bash
# التحقق من سجلات التطبيق
adb logcat | grep -i "TokenRefreshService"

# السجلات المتوقعة:
# ✅ TokenRefreshService: User token refreshed successfully

# إذا ظهر خطأ:
# ❌ TokenRefreshService: Failed to refresh token: {error}
# تحقق من اتصال الإنترنت وحاول مرة أخرى
```

### المشكلة 3: بطء في حفظ البيانات

**الحل**:
```bash
# 1. التحقق من اتصال الإنترنت
adb shell ping -c 4 google.com

# 2. التحقق من حالة Firestore
# Firebase Console -> Firestore -> Indexes
# تأكد من وجود الفهارس المطلوبة

# 3. مراقبة الاستعلامات البطيئة
adb logcat | grep -i "slow"
```

---

## 📊 التقرير النهائي (Final Report)

### ✅ قائمة التحقق (Checklist)

| # | المهمة | الحالة |
|---|--------|--------|
| 1 | نشر قواعد الأمان المحدثة | ⬜ |
| 2 | إعادة بناء التطبيق | ⬜ |
| 3 | تثبيت التطبيق على الجهاز الحقيقي | ⬜ |
| 4 | اختبار حفظ EMR | ⬜ |
| 5 | اختبار حفظ وصفة طبية | ⬜ |
| 6 | اختبار حفظ طلب فحص مخبري | ⬜ |
| 7 | اختبار حفظ طلب أشعة | ⬜ |
| 8 | التحقق من السجلات | ⬜ |
| 9 | التحقق من الأداء | ⬜ |

### 📈 النتائج المتوقعة (Expected Results)

- **معدل النجاح**: 100%
- **وقت الاستجابة**: < 2 ثانية
- **عدد الأخطاء**: 0

---

## 📝 ملاحظات إضافية (Additional Notes)

### 1. التحقق من userType في Firestore

```javascript
// استخدم Firestore Console للتحقق من وثيقة المستخدم
// المسار: users/{userId}

// تأكد من أن البيانات تحتوي على:
{
  "id": "user-uid",
  "email": "doctor@example.com",
  "fullName": "Dr. Name",
  "userType": "doctor",  // ✅ يجب أن يكون 'doctor'
  "phoneNumber": "+1234567890",
  "createdAt": {...}
}
```

### 2. اختبار على محاكي (Emulator Test)

```bash
# تشغيل محاكي Firestore
firebase emulators:start --only firestore

# تشغيل التطبيق على محاكي
flutter run -d emulator

# اختبار حفظ البيانات
# إذا نجح على المحاكي، المشكلة في قواعد الأمان
```

### 3. مراقبة سجلات Firebase

```bash
# فتح Firebase Console
# Project -> Firestore -> Logs

# البحث عن:
# - permission-denied
# - AuthRepositoryImpl
# - TokenRefreshService
```

---

## 🎯 الخلاصة (Conclusion)

تم تطبيق جميع الحلول المطلوبة:

1. ✅ تحديث قواعد الأمان لدعم المجموعات الفرعية
2. ✅ إنشاء خدمة تحديث Token
3. ✅ تحديث مستودع المصادقة مع معالجة الأخطاء
4. ✅ توفير أوامر النشر وخطوات الاختبار

**الخطوة التالية**: اتبع دليل النشر أعلاه وقم بإجراء اختبار الدخان على الجهاز الحقيقي.

---

**تاريخ التحديث**: 2026-01-13  
**الحالة**: جاهز للنشر (Ready for Deployment)
