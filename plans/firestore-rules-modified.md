// ignore_for_file: all  
// ignore_for_file: all
# نسخة معدلة من firestore.rules
# Modified Firestore Security Rules

**التاريخ:** 2026-01-13  
**الغرض:** إصلاح مشكلة permission-denied على الأجهزة الحقيقية

---

## 📝 النسخة الكاملة المعدلة (Complete Modified Version)

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

## 🔍 التغييرات الرئيسية (Key Changes)

### 1. إضافة قواعد للمجموعات الفرعية تحت appointments

**قبل:**
```javascript
match /appointments/{appointmentId} {
  // قواعد الموعد فقط
  // لا توجد قواعد للمجموعات الفرعية
}
```

**بعد:**
```javascript
match /appointments/{appointmentId} {
  // قواعد الموعد
  // ...
  
  // ✅ قواعد للمجموعات الفرعية
  match /{path=**} {
    allow read, write: if isDoctor() && canEditByAppointment(appointmentId);
    allow read: if isAuthenticated() && 
      exists(/databases/$(database)/documents/appointments/$(appointmentId)) &&
      get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == request.auth.uid;
  }
}
```

**الفائدة:**
- ✅ السماح للأطباء بحفظ EMR، وصفات، تحاليل، إلخ تحت appointments
- ✅ السماح للمرضى بقراءة هذه البيانات

### 2. إضافة قواعد للمجموعات الفرعية على مستوى الجذر

**قبل:**
```javascript
match /{collection}/{docId} {
  // قواعد المجموعات على مستوى الجذر فقط
  // لا توجد قواعد للمجموعات الفرعية
}
```

**بعد:**
```javascript
match /{collection}/{docId} {
  // قواعد المجموعات على مستوى الجذر
  // ...
  
  // ✅ قواعد للمجموعات الفرعية
  match /{subcollection=**} {
    allow read, write: if isDoctor();
  }
}
```

**الفائدة:**
- ✅ السماح للأطباء بالوصول لأي مجموعات فرعية
- ✅ دعم هيكلية مرنة للبيانات

### 3. التحقق من userType بدلاً من role ✅

**تم التأكد:**
```javascript
function isDoctor() {
  let userPath = /databases/$(database)/documents/users/$(request.auth.uid);
  return isAuthenticated() && 
    exists(userPath) && 
    get(userPath).data.userType == 'doctor';  // ✅ صحيح
}
```

---

## 🚀 خطوات النشر (Deployment Steps)

```bash
# الانتقال إلى مجلد firebase_backend
cd firebase_backend

# نسخ القواعد المعدلة
cp ../plans/firestore-rules-modified.md firestore.rules

# نشر قواعد الأمان
firebase deploy --only firestore:rules
```

**النتيجة المتوقعة:**
```
✔  firestore: rules firestore.rules (xxx B) uploaded successfully
```

---

## ✅ التحقق من الحل (Solution Validation)

### التحقق 1: القواعد تستخدم userType ✅

```javascript
// ✅ صحيح: القواعد تستخدم get(userPath).data.userType
function isDoctor() {
  let userPath = /databases/$(database)/documents/users/$(request.auth.uid);
  return isAuthenticated() && 
    exists(userPath) && 
    get(userPath).data.userType == 'doctor';
}
```

### التحقق 2: القواعد تدعم المجموعات الفرعية ✅

```javascript
// ✅ صحيح: استخدام {path=**} و {subcollection=**}
match /appointments/{appointmentId} {
  match /{path=**} {
    // قواعد للمجموعات الفرعية
  }
}
```

### التحقق 3: الأطباء يمكنهم الكتابة ✅

```javascript
// ✅ صحيح: isDoctor() && canEditByAppointment(appointmentId)
allow read, write: if isDoctor() && canEditByAppointment(appointmentId);
```

---

## 📊 الاختبار (Testing)

### اختبار 1: حفظ EMR
```
1. تسجيل الدخول كطبيب
2. فتح موعد
3. إنشاء سجل طبي (EMR)
4. حفظ السجل
5. ✅ التحقق من عدم وجود خطأ permission-denied
```

### اختبار 2: حفظ وصفة طبية
```
1. تسجيل الدخول كطبيب
2. فتح موعد
3. إنشاء وصفة طبية
4. حفظ الوصفة
5. ✅ التحقق من عدم وجود خطأ permission-denied
```

### اختبار 3: قراءة البيانات للمريض
```
1. تسجيل الدخول كمريض
2. فتح موعد
3. ✅ التحقق من إمكانية قراءة البيانات
```

---

## 📚 المراجع (References)

- [Firebase Security Rules - Recursive Wildcards](https://firebase.google.com/docs/firestore/security/rules-structure#recursive_wildcards)
- [Firestore Security Rules - Best Practices](https://firebase.google.com/docs/firestore/security/rules-best-practices)

---

**توقيع التقرير:** 2026-01-13  
**الحالة:** ✅ جاهز للنشر (Ready for Deployment)
