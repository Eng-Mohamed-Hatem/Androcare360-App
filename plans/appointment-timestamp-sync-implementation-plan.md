// ignore_for_file: all  
// ignore_for_file: all
# 📋 خطة تنفيذ مزامنة appointmentTimestamp وتوحيد معرفات المواعيد
# Appointment Timestamp Synchronization and ID Unification Implementation Plan

## 📊 ملخص تنفيذي (Executive Summary)

الهدف من هذه الخطة هو إضافة حقل `appointmentTimestamp` إلى نموذج الموعد مع دعم توقيت الرياض (Asia/Riyadh)، والتأكد من إرسال `appointmentId` في جميع دوال حفظ البيانات الطبية، مع معالجة خطأ انتهاء مدة 24 ساعة.

---

## 🎯 المتطلبات التقنية (Technical Requirements)

### 1. تحديث الـ Models (Domain Layer)

#### أ. إضافة حقل appointmentTimestamp إلى AppointmentModel

**الملف**: [`lib/shared/models/appointment_model.dart`](../lib/shared/models/appointment_model.dart)

**التغييرات المطلوبة**:
```dart
class AppointmentModel {
  AppointmentModel({
    // ... حقول موجودة ...
    final DateTime? appointmentTimestamp,  // ✅ جديد: Timestamp للتوقيت الصحيح
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      // ... حقول موجودة ...
      // ✅ تحديث: التعامل مع Firebase Timestamp
      appointmentTimestamp: json['appointmentTimestamp'] != null
          ? (json['appointmentTimestamp'] is Timestamp)
              ? (json['appointmentTimestamp'] as Timestamp).toDate()
              : DateTime.tryParse(json['appointmentTimestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... حقول موجودة ...
      // ✅ تحديث: إرسال كـ Timestamp
      'appointmentTimestamp': appointmentTimestamp != null
          ? Timestamp.fromDate(appointmentTimestamp!)
          : null,
    };
  }
}
```

### 2. تعديل AppointmentRepositoryImpl (Data Layer)

#### أ. تحديث saveAppointment مع دعم توقيت الرياض

**الملف**: [`lib/features/appointments/data/repositories/appointment_repository_impl.dart`](../lib/features/appointments/data/repositories/appointment_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

@override
Future<Either<Failure, Unit>> saveAppointment(
  AppointmentModel appointment,
) async {
  try {
    // ✅ تحويل التاريخ إلى توقيت الرياض
    final riyadhTimezone = tz.getLocation('Asia/Riyadh');
    final now = tz.TZDateTime.now(riyadhTimezone);
    
    // ✅ إنشاء appointmentTimestamp من fullDateTime
    final appointmentTimestamp = appointment.fullDateTime != null
        ? tz.TZDateTime.from(
            riyadhTimezone,
            appointment.fullDateTime!.year,
            appointment.fullDateTime!.month,
            appointment.fullDateTime!.day,
            appointment.fullDateTime!.hour,
            appointment.fullDateTime!.minute,
            appointment.fullDateTime!.second,
          )
        : now;

    // ✅ إنشاء نسخة من الموعد مع appointmentTimestamp
    final appointmentWithTimestamp = appointment.copyWith(
      appointmentTimestamp: appointmentTimestamp,
    );

    await _firestore
        .collection(AppConstants.collections.appointments)
        .doc(appointment.id)
        .set(appointmentWithTimestamp.toJson());
    
    return const Right(unit);
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

### 3. تعديل PrescriptionRepositoryImpl والوحدات الطبية (Data Layer)

#### أ. تحديث savePrescription لإضافة appointmentId

**الملف**: [`lib/features/prescriptions/data/repositories/prescription_repository_impl.dart`](../lib/features/prescriptions/data/repositories/prescription_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
@override
Future<Either<Failure, Unit>> savePrescription(
  PrescriptionModel prescription,
) async {
  try {
    // ✅ التأكد من أن appointmentId موجود
    if (prescription.appointmentId == null || prescription.appointmentId!.isEmpty) {
      return const Left(
        ServerFailure('appointmentId مطلوب لحفظ الوصفة الطبية'),
      );
    }

    final prescriptionData = prescription.toJson();
    
    // ✅ التأكد من أن appointmentId في البيانات
    if (!prescriptionData.containsKey('appointmentId')) {
      return const Left(
        ServerFailure('appointmentId غير موجود في البيانات'),
      );
    }

    await _firestore
        .collection(AppConstants.collections.prescriptions)
        .doc(prescription.id)
        .set(prescriptionData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
    if (e.code == 'permission-denied') {
      return const Left(
        ServerFailure(
          'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
        ),
      );
    }
    return Left(ServerFailure(e.toString()));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### ب. تحديث LabRequestRepositoryImpl

**الملف**: [`lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart`](../lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
@override
Future<Either<Failure, Unit>> saveLabRequest(
  LabRequestModel labRequest,
) async {
  try {
    // ✅ التأكد من أن appointmentId موجود
    if (labRequest.appointmentId == null || labRequest.appointmentId!.isEmpty) {
      return const Left(
        ServerFailure('appointmentId مطلوب لحفظ طلب الفحص المخبري'),
      );
    }

    final labRequestData = labRequest.toJson();
    
    // ✅ التأكد من أن appointmentId في البيانات
    if (!labRequestData.containsKey('appointmentId')) {
      return const Left(
        ServerFailure('appointmentId غير موجود في البيانات'),
      );
    }

    await _firestore
        .collection(AppConstants.collections.labRequests)
        .doc(labRequest.id)
        .set(labRequestData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
    if (e.code == 'permission-denied') {
      return const Left(
        ServerFailure(
          'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
        ),
      );
    }
    return Left(ServerFailure(e.toString()));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### ج. تحديث RadiologyRequestRepositoryImpl

**الملف**: [`lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart`](../lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
@override
Future<Either<Failure, Unit>> saveRadiologyRequest(
  RadiologyRequestModel radiologyRequest,
) async {
  try {
    // ✅ التأكد من أن appointmentId موجود
    if (radiologyRequest.appointmentId == null || radiologyRequest.appointmentId!.isEmpty) {
      return const Left(
        ServerFailure('appointmentId مطلوب لحفظ طلب الأشعة'),
      );
    }

    final radiologyRequestData = radiologyRequest.toJson();
    
    // ✅ التأكد من أن appointmentId في البيانات
    if (!radiologyRequestData.containsKey('appointmentId')) {
      return const Left(
        ServerFailure('appointmentId غير موجود في البيانات'),
      );
    }

    await _firestore
        .collection(AppConstants.collections.radiologyRequests)
        .doc(radiologyRequest.id)
        .set(radiologyRequestData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
    if (e.code == 'permission-denied') {
      return const Left(
        ServerFailure(
          'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
        ),
      );
    }
    return Left(ServerFailure(e.toString()));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### د. تحديث EMRRepositoryImpl

**الملف**: [`lib/features/emr/data/repositories/emr_repository_impl.dart`](../lib/features/emr/data/repositories/emr_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
@override
Future<Either<Failure, Unit>> saveEMR(
  EMRModel emr,
) async {
  try {
    // ✅ التأكد من أن appointmentId موجود
    if (emr.appointmentId == null || emr.appointmentId!.isEmpty) {
      return const Left(
        ServerFailure('appointmentId مطلوب لحفظ السجل الطبي (EMR)'),
      );
    }

    final emrData = emr.toJson();
    
    // ✅ التأكد من أن appointmentId في البيانات
    if (!emrData.containsKey('appointmentId')) {
      return const Left(
        ServerFailure('appointmentId غير موجود في البيانات'),
      );
    }

    await _firestore
        .collection(AppConstants.collections.emrRecords)
        .doc(emr.id)
        .set(emrData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
    if (e.code == 'permission-denied') {
      return const Left(
        ServerFailure(
          'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
        ),
      );
    }
    return Left(ServerFailure(e.toString()));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### هـ. تحديث DeviceRequestRepositoryImpl

**الملف**: [`lib/features/device_requests/data/repositories/device_request_repository_impl.dart`](../lib/features/device_requests/data/repositories/device_request_repository_impl.dart)

**التغييرات المطلوبة**:
```dart
@override
Future<Either<Failure, Unit>> saveDeviceRequest(
  DeviceRequestModel deviceRequest,
) async {
  try {
    // ✅ التأكد من أن appointmentId موجود
    if (deviceRequest.appointmentId == null || deviceRequest.appointmentId!.isEmpty) {
      return const Left(
        ServerFailure('appointmentId مطلوب لحفظ طلب الجهاز الطبي'),
      );
    }

    final deviceRequestData = deviceRequest.toJson();
    
    // ✅ التأكد من أن appointmentId في البيانات
    if (!deviceRequestData.containsKey('appointmentId')) {
      return const Left(
        ServerFailure('appointmentId غير موجود في البيانات'),
      );
    }

    await _firestore
        .collection(AppConstants.collections.deviceRequests)
        .doc(deviceRequest.id)
        .set(deviceRequestData);
    
    return const Right(unit);
  } on FirebaseException catch (e) {
    // ✅ معالجة خطأ permission-denied (انتهاء 24 ساعة)
    if (e.code == 'permission-denied') {
      return const Left(
        ServerFailure(
          'عذراً، انتهت المدة المسموح بها لإضافة أو تعديل البيانات الطبية لهذا الموعد (24 ساعة)',
        ),
      );
    }
    return Left(ServerFailure(e.toString()));
  } on Exception catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

### 4. التحقق من صحة البيانات (Data Validation)

#### أ. التحقق من أن appointmentId موجود في جميع النماذج

**النماذج المطلوب التحقق منها**:
1. [`PrescriptionModel`](../lib/shared/models/prescription_model.dart)
2. [`LabRequestModel`](../lib/shared/models/lab_request_model.dart)
3. [`RadiologyRequestModel`](../lib/shared/models/radiology_request_model.dart)
4. [`EMRModel`](../lib/shared/models/emr_model.dart)
5. [`DeviceRequestModel`](../lib/shared/models/device_request_model.dart)
6. [`InternalMedicineEMRModel`](../lib/shared/models/internal_medicine_emr_model.dart)

**التغييرات المطلوبة في كل نموذج**:
```dart
// في كل نموذج، تأكد من:
class XModel {
  final String appointmentId;  // ✅ يجب أن يكون موجود
  
  XModel({
    required this.appointmentId,  // ✅ required
    // ... حقول أخرى
  });
  
  factory XModel.fromJson(Map<String, dynamic> json) {
    return XModel(
      appointmentId: json['appointmentId'] as String,  // ✅ قراءة من JSON
      // ... حقول أخرى
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,  // ✅ إرسال في JSON
      // ... حقول أخرى
    };
  }
}
```

---

## 🔍 شرح كيفية التحقق من أن حقل التوقيت يتم إرساله بصيغة Timestamp

### 1. في toJson() - إرسال Timestamp

```dart
Map<String, dynamic> toJson() {
  return {
    // ... حقول أخرى
    'appointmentTimestamp': appointmentTimestamp != null
        ? Timestamp.fromDate(appointmentTimestamp!)  // ✅ إنشاء Timestamp
        : null,  // ✅ أو null إذا غير موجود
  };
}
```

**التوضيح**:
- `Timestamp.fromDate(DateTime)` يحول `DateTime` إلى `Firebase Timestamp`
- هذا يضمن أن Firestore يستقبل البيانات بصيغة Timestamp الصحيحة
- إذا كان `appointmentTimestamp` null، نرسل null مباشرة

### 2. في fromJson() - قراءة Timestamp

```dart
factory AppointmentModel.fromJson(Map<String, dynamic> json) {
  return AppointmentModel(
    // ... حقول أخرى
    appointmentTimestamp: json['appointmentTimestamp'] != null
        ? (json['appointmentTimestamp'] is Timestamp)
            ? (json['appointmentTimestamp'] as Timestamp).toDate()  // ✅ تحويل Timestamp إلى DateTime
            : DateTime.tryParse(json['appointmentTimestamp'].toString())  // ✅ أو محاولة تحويل String
        : null,
  );
}
```

**التوضيح**:
- نتحقق أولاً إذا كان الحقل موجود
- نتحقق إذا كان النوع `Timestamp` (من Firestore)
- إذا كان Timestamp، نستخدم `.toDate()` لتحويله إلى DateTime
- إذا كان String (من JSON عادي)، نستخدم `DateTime.tryParse()`
- إذا كان null، نعيين null

### 3. في Firestore Rules - التحقق من Timestamp

```javascript
// في firestore.rules
function isWithin24Hours(appointmentId) {
  let apptPath = /databases/$(database)/documents/appointments/$(appointmentId);
  let appointment = get(apptPath).data;
  
  // ✅ التحقق من أن appointmentTimestamp موجود
  if (!appointment.appointmentTimestamp) {
    return false;
  }
  
  // ✅ حساب الفرق بالساعات
  let appointmentTime = appointment.appointmentTimestamp.toDate();
  let now = request.time.toDate();
  let hoursDiff = (now - appointmentTime) / (1000 * 60 * 60);
  
  return hoursDiff <= 24;
}

// ✅ استخدام في قواعد المجموعات الفرعية
match /{path=**} {
  allow read, write: if isDoctor() && 
    canEditByAppointment(appointmentId) && 
    isWithin24Hours(appointmentId);  // ✅ التحقق من 24 ساعة
}
```

---

## 📦 الملفات المطلوب تحديثها (Files to Update)

| # | الملف | التغييرات | الأولوية |
|---|--------|-----------|----------|
| 1 | [`lib/shared/models/appointment_model.dart`](../lib/shared/models/appointment_model.dart) | إضافة `appointmentTimestamp` | 🔴 حرجة |
| 2 | [`lib/features/appointments/data/repositories/appointment_repository_impl.dart`](../lib/features/appointments/data/repositories/appointment_repository_impl.dart) | دعم توقيت الرياض | 🔴 حرجة |
| 3 | [`lib/features/prescriptions/data/repositories/prescription_repository_impl.dart`](../lib/features/prescriptions/data/repositories/prescription_repository_impl.dart) | التحقق من appointmentId | 🔴 حرجة |
| 4 | [`lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart`](../lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart) | التحقق من appointmentId | 🔴 حرجة |
| 5 | [`lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart`](../lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart) | التحقق من appointmentId | 🔴 حرجة |
| 6 | [`lib/features/emr/data/repositories/emr_repository_impl.dart`](../lib/features/emr/data/repositories/emr_repository_impl.dart) | التحقق من appointmentId | 🔴 حرجة |
| 7 | [`lib/features/device_requests/data/repositories/device_request_repository_impl.dart`](../lib/features/device_requests/data/repositories/device_request_repository_impl.dart) | التحقق من appointmentId | 🔴 حرجة |
| 8 | [`lib/shared/models/prescription_model.dart`](../lib/shared/models/prescription_model.dart) | التحقق من appointmentId | 🟡 متوسطة |
| 9 | [`lib/shared/models/lab_request_model.dart`](../lib/shared/models/lab_request_model.dart) | التحقق من appointmentId | 🟡 متوسطة |
| 10 | [`lib/shared/models/radiology_request_model.dart`](../lib/shared/models/radiology_request_model.dart) | التحقق من appointmentId | 🟡 متوسطة |
| 11 | [`lib/shared/models/emr_model.dart`](../lib/shared/models/emr_model.dart) | التحقق من appointmentId | 🟡 متوسطة |
| 12 | [`lib/shared/models/device_request_model.dart`](../lib/shared/models/device_request_model.dart) | التحقق من appointmentId | 🟡 متوسطة |

---

## 🧪 خطوات الاختبار (Testing Steps)

### اختبار 1: حفظ موعد جديد

```dart
// 1. إنشاء موعد جديد
final appointment = AppointmentModel(
  id: 'test-appointment-id',
  // ... حقول أخرى
  appointmentDate: DateTime(2026, 1, 15),
  timeSlot: '10:00 ص',
);

// 2. حفظ الموعد
final result = await appointmentRepository.saveAppointment(appointment);

// 3. التحقق من النتيجة
result.fold(
  (failure) => print('❌ Failed: ${failure.message}'),
  (unit) => print('✅ Success'),
);

// 4. التحقق من Firestore
// افتح Firebase Console -> Firestore -> appointments -> test-appointment-id
// تأكد من وجود حقل appointmentTimestamp بصيغة Timestamp
```

### اختبار 2: حفظ وصفة طبية

```dart
// 1. إنشاء وصفة طبية
final prescription = PrescriptionModel(
  id: 'test-prescription-id',
  appointmentId: 'test-appointment-id',  // ✅ مطلوب
  // ... حقول أخرى
);

// 2. حفظ الوصفة
final result = await prescriptionRepository.savePrescription(prescription);

// 3. التحقق من النتيجة
result.fold(
  (failure) => print('❌ Failed: ${failure.message}'),
  (unit) => print('✅ Success'),
);

// 4. التحقق من Firestore
// افتح Firebase Console -> Firestore -> prescriptions -> test-prescription-id
// تأكد من وجود حقل appointmentId
```

### اختبار 3: حفظ بعد 24 ساعة (يجب أن يفشل)

```dart
// 1. إنشاء موعد قديم (قبل 24 ساعة)
final oldAppointment = AppointmentModel(
  id: 'old-appointment-id',
  appointmentDate: DateTime.now().subtract(Duration(hours: 25)),
  timeSlot: '10:00 ص',
  // ... حقول أخرى
);

// 2. حفظ الموعد
await appointmentRepository.saveAppointment(oldAppointment);

// 3. محاولة حفظ وصفة
final prescription = PrescriptionModel(
  id: 'test-prescription-id',
  appointmentId: 'old-appointment-id',
  // ... حقول أخرى
);

final result = await prescriptionRepository.savePrescription(prescription);

// 4. التحقق من النتيجة (يجب أن تفشل)
result.fold(
  (failure) {
    // ✅ يجب أن يحتوي على رسالة 24 ساعة
    print('✅ Expected failure: ${failure.message}');
    assert(failure.message.contains('24 ساعة'));
  },
  (unit) {
    print('❌ Should have failed!');
    assert(false);
  },
);
```

---

## 📝 ملاحظات إضافية (Additional Notes)

### 1. إضافة timezone إلى pubspec.yaml

تأكد من إضافة الحزمة المطلوبة:

```yaml
dependencies:
  timezone: ^0.9.4  # ✅ مطلوب لدعم توقيت الرياض
```

### 2. تحديث firestore.rules للتحقق من 24 ساعة

```javascript
// إضافة دالة للتحقق من 24 ساعة
function isWithin24Hours(appointmentId) {
  let apptPath = /databases/$(database)/documents/appointments/$(appointmentId);
  let appointment = get(apptPath).data;
  
  if (!appointment.appointmentTimestamp) {
    return false;
  }
  
  let appointmentTime = appointment.appointmentTimestamp.toDate();
  let now = request.time.toDate();
  let hoursDiff = (now - appointmentTime) / (1000 * 60 * 60);
  
  return hoursDiff <= 24;
}

// تحديث قواعد المجموعات الفرعية
match /appointments/{appointmentId}/{path=**} {
  allow read, write: if isDoctor() && 
    canEditByAppointment(appointmentId) && 
    isWithin24Hours(appointmentId);  // ✅ التحقق من 24 ساعة
}
```

---

## 🎯 الخلاصة (Summary)

### التغييرات الرئيسية:

1. ✅ **إضافة appointmentTimestamp** إلى [`AppointmentModel`](../lib/shared/models/appointment_model.dart)
2. ✅ **دعم توقيت الرياض** في [`AppointmentRepositoryImpl`](../lib/features/appointments/data/repositories/appointment_repository_impl.dart)
3. ✅ **التحقق من appointmentId** في جميع دوال حفظ البيانات الطبية
4. ✅ **معالجة خطأ 24 ساعة** برسالة واضحة بالعربية
5. ✅ **إرسال Timestamp** بصيغة صحيحة إلى Firestore

### النتائج المتوقعة:

- ✅ يتم حفظ `appointmentTimestamp` بصيغة Timestamp
- ✅ يتم استخدام توقيت الرياض لجميع المواعيد
- ✅ يتم إرسال `appointmentId` في جميع البيانات الطبية
- ✅ يتم منع الحفظ بعد 24 ساعة برسالة واضحة
- ✅ تتبع قواعد الأمان المحدثة

---

**تاريخ التحديث**: 2026-01-14  
**الحالة**: جاهز للتنفيذ (Ready for Implementation)
