// ignore_for_file: all  
// ignore_for_file: all
# خطة إصلاح مشكلة Permission-Denied على الأجهزة الحقيقية
# Firestore Permission-Denied Fix Plan

**التاريخ:** 2026-01-13  
**المهندس:** مهندس ضمان الجودة (QA Engineer)  
**المشروع:** ElajTech - تطبيق المركز الطبي (AndroCare360)

---

## 📋 ملخص تنفيذي (Executive Summary)

يتم مواجهة خطأ `permission-denied` عند حفظ السجلات الطبية (EMR/الوصفات) على الأجهزة الحقيقية رغم نجاح Integration Tests. بعد التحليل الشامل، تم تحديد الأسباب الجذرية والحلول المقترحة.

---

## 🔍 تحليل المشكلة (Problem Analysis)

### 1.1 السلوك المتوقع (Expected Behavior)

عند محاولة الطبيب حفظ:
- السجلات الطبية (EMR Records)
- الوصفات الطبية (Prescriptions)
- طلبات التحاليل (Lab Requests)
- طلبات الأشعة (Radiology Requests)
- طلبات الأجهزة (Device Requests)

يظهر خطأ:
```
Error: Missing or insufficient permissions
Error: Permission denied
```

### 1.2 الفرق بين Integration Tests والأجهزة الحقيقية

| الجانب | Integration Tests | Real Device |
|--------|------------------|-------------|
| **قواعد الأمان** | قد يتم تجاوزها | مفعلة بالكامل |
| **Auth Token** | دائماً طازج | قد يكون قديماً |
| **User Document** | محمل في الذاكرة | يحتاج تحديث |
| **Subcollections** | قد لا تُختبر | تُستخدم فعلياً |

---

## 🎯 الأسباب الجذرية (Root Causes)

### السبب 1: عدم وجود قواعد للمجموعات الفرعية تحت appointments

**المشكلة:**
القواعد الحالية في [`firestore.rules`](../firebase_backend/firestore.rules:35-50) تغطي فقط مستندات appointments، وليس المجموعات الفرعية مثل:
- `appointments/{appointmentId}/medical_records/{recordId}`
- `appointments/{appointmentId}/prescriptions/{prescriptionId}`
- `appointments/{appointmentId}/lab_requests/{requestId}`
- إلخ...

**القاعدة الحالية (السطر 35-50):**
```javascript
match /appointments/{appointmentId} {
  allow read: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid ||
    isDoctor() 
  );
  allow create: if isAuthenticated();
  allow update: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid
  );
  allow delete: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid
  );
}
```

**المشكلة:** لا توجد قواعد `match /{path=**}` داخل appointments للسماح بالوصول للمجموعات الفرعية.

### السبب 2: القاعدة العامة للمجموعات الطبية قد لا تغطي Subcollections بشكل صحيح

**القاعدة الحالية (السطر 52-64):**
```javascript
match /{collection}/{docId} {
  allow read: if isAuthenticated() && (
    isDoctor() || 
    (resource.data.patientId == request.auth.uid && collection != 'emr_records')
  );
  
  allow create, update: if isAuthenticated() && 
    collection in ['prescriptions', 'lab_requests', 'radiology_requests', 'device_requests', 'emr_records', 'internal_medicine_emrs'] &&
    isDoctor();
}
```

**المشكلة:** هذه القاعدة تغطي المجموعات على مستوى الجذر، وليس المجموعات الفرعية تحت appointments.

### السبب 3: Auth Token قد يكون قديماً على الأجهزة الحقيقية

**المشكلة:**
- على الأجهزة الحقيقية، قد يكون Firebase Auth Token قديماً
- Firestore Security Rules تعتمد على `request.auth` الذي يحتوي على Token
- إذا كان Token قديماً، قد لا يحتوي على أحدث البيانات

**التأثير:**
- `isDoctor()` function تستخدم `get(userPath).data.userType`
- إذا كان Token قديماً، قد لا يتم تحميل بيانات المستخدم بشكل صحيح

### السبب 4: UserModel.toJson() يرسل userType بشكل صحيح ✅

**التحقق:**
```dart
// lib/shared/models/user_model.dart:109
'userType': userType.name,  // يخزن 'doctor' أو 'patient'
```

**النتيجة:** هذا صحيح ✅ - الحقل يتم إرساله بشكل صحيح.

---

## ✅ الحلول المقترحة (Proposed Solutions)

### الحل 1: تحديث firestore.rules لدعم المجموعات الفرعية

**الملف:** [`firebase_backend/firestore.rules`](../firebase_backend/firestore.rules)

**التغييرات المطلوبة:**

#### أ. إضافة قواعد للمجموعات الفرعية تحت appointments

```javascript
// -- Appointments Collection --
match /appointments/{appointmentId} {
  // قواعد الموعد نفسه
  allow read: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid ||
    isDoctor() 
  );
  allow create: if isAuthenticated();
  allow update: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid
  );
  allow delete: if isAuthenticated() && (
    resource.data.patientId == request.auth.uid || 
    resource.data.doctorId == request.auth.uid
  );
  
  // ✅ إضافة قواعد للمجموعات الفرعية
  match /{path=**} {
    // السماح للطبيب بقراءة وكتابة جميع المجموعات الفرعية
    allow read, write: if isDoctor() && canEditByAppointment(appointmentId);
    
    // السماح للمريض بقراءة المجموعات الفرعية (باستثناء EMR)
    allow read: if isAuthenticated() && 
      get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == request.auth.uid;
  }
}
```

#### ب. تحديث القاعدة العامة للمجموعات الطبية

```javascript
// -- Medical Records (Prescriptions, Lab, EMR, etc) --
match /{collection}/{docId} {
  // ✅ تحديث: السماح بالوصول للمجموعات الفرعية أيضاً
  allow read: if isAuthenticated() && (
    isDoctor() || 
    (resource.data.patientId == request.auth.uid && collection != 'emr_records')
  );
  
  allow create, update: if isAuthenticated() && 
    collection in ['prescriptions', 'lab_requests', 'radiology_requests', 'device_requests', 'emr_records', 'internal_medicine_emrs'] &&
    isDoctor();
  
  // ✅ إضافة: السماح للمجموعات الفرعية
  match /{subcollection=**} {
    allow read, write: if isDoctor();
  }
}
```

### الحل 2: إضافة Force Refresh للـ User Token في Flutter

**الملف الجديد:** `lib/core/services/token_refresh_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// خدمة لتحديث User Token بشكل إجباري
/// Force Refresh User Token Service
class TokenRefreshService {
  final FirebaseAuth _firebaseAuth;

  TokenRefreshService(this._firebaseAuth);

  /// تحديث User Token بشكل إجباري
  /// Force refresh the user's ID token
  Future<bool> forceRefreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in');
        return false;
      }

      // تحديث Token بشكل إجباري
      await user.getIdToken(true); // true = force refresh
      
      debugPrint('✅ User token refreshed successfully');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Failed to refresh token: $e');
      return false;
    }
  }

  /// الحصول على Token جديد مع التحقق من الصلاحية
  /// Get a fresh token with validation
  Future<String?> getFreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // تحديث Token بشكل إجباري
      final token = await user.getIdToken(true);
      
      debugPrint('✅ Fresh token obtained');
      return token;
    } on Exception catch (e) {
      debugPrint('❌ Failed to get fresh token: $e');
      return null;
    }
  }

  /// التحقق من صلاحية Token وتحديثه إذا لزم الأمر
  /// Validate token and refresh if needed
  Future<bool> validateAndRefreshTokenIfNeeded() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return false;
      }

      // محاولة الحصول على Token بدون تحديث إجباري
      final token = await user.getIdToken(false);
      
      // إذا نجح، Token صالح
      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Token is valid');
        return true;
      }

      // إذا فشل، قم بتحديثه بشكل إجباري
      debugPrint('⚠️ Token invalid, refreshing...');
      return await forceRefreshToken();
    } on Exception catch (e) {
      debugPrint('❌ Failed to validate token: $e');
      return await forceRefreshToken();
    }
  }
}
```

**الاستخدام في AuthProvider:**

```dart
// lib/features/auth/providers/auth_provider.dart
import 'package:elajtech/core/services/token_refresh_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenRefreshService _tokenRefreshService;

  AuthNotifier(this._authRepository, FirebaseAuth firebaseAuth)
      : _tokenRefreshService = TokenRefreshService(firebaseAuth),
        super(AuthState.initial());

  /// تحديث بيانات المستخدم مع تحديث Token
  Future<void> updateUserData(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true);

    // ✅ تحديث Token قبل عملية التحديث
    final tokenRefreshed = await _tokenRefreshService.forceRefreshToken();
    
    if (!tokenRefreshed) {
      debugPrint('⚠️ Failed to refresh token before update');
    }

    final result = await _authRepository.updateUser(updatedUser);
    result.fold(
      (Failure failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (Unit unit) =>
          state = state.copyWith(user: updatedUser, isLoading: false),
    );
  }
}
```

**الاستخدام في main.dart عند بدء التطبيق:**

```dart
// lib/main.dart
import 'package:elajtech/core/services/token_refresh_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // ✅ تحديث Token عند بدء التطبيق
  final tokenRefreshService = TokenRefreshService(FirebaseAuth.instance);
  await tokenRefreshService.forceRefreshToken();

  runApp(MyApp());
}
```

### الحل 3: إضافة معالجة أخطاء محسّنة في Repository

**الملف:** [`lib/features/auth/data/repositories/auth_repository_impl.dart`](../lib/features/auth/data/repositories/auth_repository_impl.dart)

**تحديث دالة `updateUser`:**

```dart
@override
Future<Either<Failure, Unit>> updateUser(UserModel user) async {
  try {
    // ✅ التأكد من أن userType موجود في البيانات
    final jsonData = user.toJson();
    
    if (!jsonData.containsKey('userType')) {
      return const Left(
        AuthFailure('خطأ: حقل userType مفقود من البيانات'),
      );
    }
    
    debugPrint('📤 Updating user with userType: ${jsonData['userType']}');
    debugPrint('📤 User ID: ${user.id}');
    debugPrint('📤 Fields: ${jsonData.keys.join(', ')}');

    await _firestore
        .collection(AppConstants.collections.users)
        .doc(user.id)
        .update(jsonData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    debugPrint('❌ Firestore error: ${e.code} - ${e.message}');
    
    // ✅ معالجة أخطاء Firestore بشكل أفضل
    if (e.code == 'permission-denied') {
      return Left(
        AuthFailure(
          'لا تملك الصلاحية اللازمة لتحديث هذه البيانات. '
          'يرجى التأكد من أنك تحديث حقول مسموحة لدورك (طبيب/مريض). '
          'إذا استمرت المشكلة، حاول تسجيل الخروج والدخول مرة أخرى.',
        ),
      );
    }
    return Left(AuthFailure(_mapFirestoreError(e)));
  } on Exception catch (e) {
    debugPrint('❌ Exception: $e');
    return Left(AuthFailure(e.toString()));
  }
}
```

---

## 📝 نسخة معدلة كاملة من firestore.rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // -- Helper Functions --
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isDoctor() {
      let userPath = /databases/$(database)/documents/users/$(request.auth.uid);
      return isAuthenticated() && 
        exists(userPath) && 
        get(userPath).data.userType == 'doctor';
    }

    function canEditByAppointment(appointmentId) {
       let apptPath = /databases/$(database)/documents/appointments/$(appointmentId);
       return exists(apptPath) && get(apptPath).data.doctorId == request.auth.uid;
    }
    
    // -- Users Collection --
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(userId);
    }
    
    // -- Appointments Collection --
    match /appointments/{appointmentId} {
      // قواعد الموعد نفسه
      allow read: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid || 
        resource.data.doctorId == request.auth.uid ||
        isDoctor() 
      );
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid || 
        resource.data.doctorId == request.auth.uid
      );
      allow delete: if isAuthenticated() && (
        resource.data.patientId == request.auth.uid || 
        resource.data.doctorId == request.auth.uid
      );
      
      // ✅ إضافة: قواعد للمجموعات الفرعية تحت appointments
      match /{path=**} {
        // السماح للطبيب بقراءة وكتابة جميع المجموعات الفرعية
        allow read, write: if isDoctor() && canEditByAppointment(appointmentId);
        
        // السماح للمريض بقراءة المجموعات الفرعية
        allow read: if isAuthenticated() && 
          exists(/databases/$(database)/documents/appointments/$(appointmentId)) &&
          get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == request.auth.uid;
      }
    }
    
    // -- Medical Records (Prescriptions, Lab, EMR, etc) --
    match /{collection}/{docId} {
      // السماح بالقراءة
      allow read: if isAuthenticated() && (
        // 1. Doctor (Global Access)
        isDoctor() || 
        // 2. Patient (Owner) - EXCEPT for EMR Records
        (resource.data.patientId == request.auth.uid && collection != 'emr_records')
      );
      
      // السماح بالإنشاء والتحديث
      allow create, update: if isAuthenticated() && 
        collection in ['prescriptions', 'lab_requests', 'radiology_requests', 'device_requests', 'emr_records', 'internal_medicine_emrs'] &&
        isDoctor();
      
      // ✅ إضافة: السماح للمجموعات الفرعية على مستوى الجذر
      match /{subcollection=**} {
        allow read, write: if isDoctor();
      }
    }

    // -- Notifications --
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow write: if isAuthenticated();
    }

    // -- Chats Collection --
    match /chats/{chatId} {
      // Allow read/write if user is a participant
      allow read, write: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      
      // Allow create if user is setting themselves as participant
      allow create: if isAuthenticated() && 
        request.auth.uid in request.resource.data.participants;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read, write: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }

    // -- Default Deny --
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 🚀 خطوات النشر (Deployment Steps)

### الخطوة 1: تحديث firestore.rules

```bash
# الانتقال إلى مجلد firebase_backend
cd firebase_backend

# نشر قواعد الأمان فقط
firebase deploy --only firestore:rules
```

**النتيجة المتوقعة:**
```
✔  firestore: rules firestore.rules (xxx B) uploaded successfully
```

### الخطوة 2: إضافة TokenRefreshService إلى المشروع

1. إنشاء الملف: `lib/core/services/token_refresh_service.dart`
2. إضافة الكود المذكور أعلاه
3. تحديث `lib/features/auth/providers/auth_provider.dart`
4. تحديث `lib/main.dart`

### الخطوة 3: تحديث AuthRepositoryImpl

1. تحديث دالة `updateUser` في [`lib/features/auth/data/repositories/auth_repository_impl.dart`](../lib/features/auth/data/repositories/auth_repository_impl.dart:217-237)
2. إضافة logging مفصل
3. إضافة معالجة أخطاء محسّنة

### الخطوة 4: الاختبار

#### اختبار 1: حفظ EMR على جهاز حقيقي
```
1. تسجيل الدخول كطبيب
2. فتح موعد
3. إنشاء سجل طبي (EMR)
4. حفظ السجل
5. التحقق من عدم وجود خطأ permission-denied
```

#### اختبار 2: حفظ وصفة طبية
```
1. تسجيل الدخول كطبيب
2. فتح موعد
3. إنشاء وصفة طبية
4. حفظ الوصفة
5. التحقق من عدم وجود خطأ permission-denied
```

#### اختبار 3: Force Refresh Token
```
1. تسجيل الدخول
2. التحقق من سجلات التطبيق
3. البحث عن "✅ User token refreshed successfully"
```

---

## 📊 ملخص التغييرات (Summary of Changes)

| الملف | التغييرات | الأولوية | الحالة |
|-------|-----------|----------|--------|
| [`firebase_backend/firestore.rules`](../firebase_backend/firestore.rules) | إضافة قواعد للمجموعات الفرعية | 🔴 حرجة | ⏳ في الانتظار |
| `lib/core/services/token_refresh_service.dart` | إنشاء خدمة جديدة لتحديث Token | 🟡 متوسطة | ⏳ في الانتظار |
| [`lib/features/auth/providers/auth_provider.dart`](../lib/features/auth/providers/auth_provider.dart) | تحديث لاستخدام TokenRefreshService | 🟡 متوسطة | ⏳ في الانتظار |
| [`lib/main.dart`](../lib/main.dart) | تحديث Token عند بدء التطبيق | 🟡 متوسطة | ⏳ في الانتظار |
| [`lib/features/auth/data/repositories/auth_repository_impl.dart`](../lib/features/auth/data/repositories/auth_repository_impl.dart) | تحسين معالجة الأخطاء | 🟢 منخفضة | ⏳ في الانتظار |

---

## ✅ التحقق من الحلول (Solution Validation)

### التحقق 1: قواعد الأمان تستخدم userType ✅

```javascript
// ✅ صحيح: القواعد تستخدم get(userPath).data.userType
function isDoctor() {
  let userPath = /databases/$(database)/documents/users/$(request.auth.uid);
  return isAuthenticated() && 
    exists(userPath) && 
    get(userPath).data.userType == 'doctor';
}
```

### التحقق 2: UserModel.toJson() يرسل userType ✅

```dart
// ✅ صحيح: الحقل يتم إرساله
Map<String, dynamic> toJson() {
  return {
    // ... حقول أخرى
    'userType': userType.name,  // 'doctor' أو 'patient'
    // ... حقول أخرى
  };
}
```

### التحقق 3: updateUser يرسل جميع الحقول ✅

```dart
// ✅ صحيح: جميع الحقول تُرسل
await _firestore
    .collection(AppConstants.collections.users)
    .doc(user.id)
    .update(user.toJson()); // يحتوي على userType
```

---

## 🎯 النتائج المتوقعة (Expected Results)

### بعد تطبيق الحلول:

1. ✅ **القواعد تدعم المجموعات الفرعية:**
   - الأطباء يمكنهم حفظ EMR، وصفات، تحاليل، إلخ
   - المجموعات الفرعية تحت appointments مسموحة

2. ✅ **Token يتم تحديثه بشكل دوري:**
   - عند بدء التطبيق
   - قبل عمليات التحديث
   - عند الحاجة

3. ✅ **رسائل خطأ واضحة:**
   - رسائل عربية واضحة
   - توضح السبب والحل

4. ✅ **Logging مفصل:**
   - تتبع العمليات
   - سهولة التصحيح

---

## 📚 المراجع (References)

- [Firebase Security Rules - Recursive Wildcards](https://firebase.google.com/docs/firestore/security/rules-structure#recursive_wildcards)
- [Firebase Auth - ID Tokens](https://firebase.google.com/docs/auth/users#id_tokens)
- [Firestore Security Rules - Best Practices](https://firebase.google.com/docs/firestore/security/rules-best-practices)

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ جاهز للتنفيذ (Ready for Implementation)
