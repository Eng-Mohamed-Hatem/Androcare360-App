// ignore_for_file: all  
// ignore_for_file: all
# 📋 ملخص تنفيذ مزامنة appointmentTimestamp وتوحيد معرفات المواعيد
# Appointment Timestamp Synchronization and ID Unification Implementation Summary

## 🎯 الهدف (Objective)

إضافة حقل `appointmentTimestamp` إلى [`AppointmentModel`](../lib/shared/models/appointment_model.dart) مع دعم توقيت الرياض (Asia/Riyadh)، والتأكد من إرسال `appointmentId` في جميع دوال حفظ البيانات الطبية، مع معالجة خطأ انتهاء مدة 24 ساعة.

---

## 📦 الجزء 1: تحديث AppointmentModel (Domain Layer)

### الملف: [`lib/shared/models/appointment_model.dart`](../lib/shared/models/appointment_model.dart)

### التغييرات المطلوبة:

```dart
/// Appointment Model - نموذج الموعد
class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDate,
    required this.timeSlot,
    required this.type,
    required this.status,
    required this.fee,
    required this.createdAt,
    this.notes,
    this.meetingLink,
    // حقول جدولة المواعيد
    this.scheduledDateTime,
    this.reminderSent = false,
    // ✅ جديد: Timestamp للتوقيت الصحيح
    this.appointmentTimestamp,
  });

  /// From JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // التحقق من حالة الموعد
    final statusValue = json['status'] as String?;
    AppointmentStatus status;

    if (statusValue == null) {
      status = AppointmentStatus.pending;
    } else {
      status = AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.$statusValue',
        orElse: () => AppointmentStatus.pending,
      );
    }

    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientPhone: json['patientPhone'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialization: json['specialization'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      timeSlot: json['timeSlot'] as String,
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == 'AppointmentType.${json['type']}',
      ),
      status: status,
      fee: (json['fee'] as num).toDouble(),
      notes: json['notes'] as String?,
      meetingLink: json['meetingLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      // حقول جدولة المواعيد
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.parse(json['scheduledDateTime'] as String)
          : null,
      reminderSent: json['reminderSent'] as bool? ?? false,
      // ✅ جديد: قراءة appointmentTimestamp
      appointmentTimestamp: _parseAppointmentTimestamp(json['appointmentTimestamp']),
    );
  }

  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentType type;
  final AppointmentStatus status;
  final double fee;
  final String? notes;
  final DateTime createdAt;
  final String? meetingLink;

  // حقول جدولة المواعيد
  final DateTime? scheduledDateTime;
  final bool reminderSent;

  // ✅ جديد: Timestamp للتوقيت الصحيح
  final DateTime? appointmentTimestamp;

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'type': type.name,
      'status': status.name,
      'fee': fee,
      'notes': notes,
      'meetingLink': meetingLink,
      'createdAt': createdAt.toIso8601String(),
      // حقول جدولة المواعيد
      'scheduledDateTime': scheduledDateTime?.toIso8601String(),
      'reminderSent': reminderSent,
      // ✅ جديد: إرسال appointmentTimestamp
      'appointmentTimestamp': _formatAppointmentTimestamp(),
    };
  }

  /// ✅ جديد: دالة مساعدة لقراءة appointmentTimestamp
  static DateTime? _parseAppointmentTimestamp(dynamic value) {
    if (value == null) return null;
    
    // إذا كان Timestamp من Firestore
    if (value is Timestamp) {
      return (value as Timestamp).toDate();
    }
    
    // إذا كان String، حاول تحويله
    if (value is String) {
      return DateTime.tryParse(value as String);
    }
    
    return null;
  }

  /// ✅ جديد: دالة مساعدة لإرسال appointmentTimestamp
  dynamic _formatAppointmentTimestamp() {
    if (appointmentTimestamp == null) return null;
    
    // ✅ إرسال كـ Timestamp من Firestore
    return Timestamp.fromDate(appointmentTimestamp!);
  }

  // ... باقي الدوال (fullDateTime, copyWith, etc.)
}
```

---

## 📦 الجزء 2: تحديث AppointmentRepositoryImpl (Data Layer)

### الملف: [`lib/features/appointments/data/repositories/appointment_repository_impl.dart`](../lib/features/appointments/data/repositories/appointment_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/core/services/appointment_conflict_validation_service.dart';
import 'package:injectable/injectable.dart';
// ✅ جديد: استيراد timezone
import 'package:timezone/timezone.dart' as tz;

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

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

  // ... باقي الدوال بدون تغيير
}
```

---

## 📦 الجزء 3: تحديث PrescriptionRepositoryImpl (Data Layer)

### الملف: [`lib/features/prescriptions/data/repositories/prescription_repository_impl.dart`](../lib/features/prescriptions/data/repositories/prescription_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:elajtech/shared/models/prescription_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PrescriptionRepository)
class PrescriptionRepositoryImpl implements PrescriptionRepository {
  PrescriptionRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, Unit>> savePrescription(
    PrescriptionModel prescription,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId موجود
      if (prescription.appointmentId == null || prescription.appointmentId!.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ الوصفة الطبية'),
        );
      }

      final prescriptionData = prescription.toJson();
      
      // ✅ التحقق من أن appointmentId في البيانات
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

  // ... باقي الدوال بدون تغيير
}
```

---

## 📦 الجزء 4: تحديث LabRequestRepositoryImpl (Data Layer)

### الملف: [`lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart`](../lib/features/lab_requests/data/repositories/lab_request_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LabRequestRepository)
class LabRequestRepositoryImpl implements LabRequestRepository {
  LabRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, Unit>> saveLabRequest(
    LabRequestModel labRequest,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId موجود
      if (labRequest.appointmentId == null || labRequest.appointmentId!.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الفحص المخبري'),
        );
      }

      final labRequestData = labRequest.toJson();
      
      // ✅ التحقق من أن appointmentId في البيانات
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

  // ... باقي الدوال بدون تغيير
}
```

---

## 📦 الجزء 5: تحديث RadiologyRequestRepositoryImpl (Data Layer)

### الملف: [`lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart`](../lib/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RadiologyRequestRepository)
class RadiologyRequestRepositoryImpl implements RadiologyRequestRepository {
  RadiologyRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, Unit>> saveRadiologyRequest(
    RadiologyRequestModel radiologyRequest,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId موجود
      if (radiologyRequest.appointmentId == null || radiologyRequest.appointmentId!.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الأشعة'),
        );
      }

      final radiologyRequestData = radiologyRequest.toJson();
      
      // ✅ التحقق من أن appointmentId في البيانات
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

  // ... باقي الدوال بدون تغيير
}
```

---

## 📦 الجزء 6: تحديث EMRRepositoryImpl (Data Layer)

### الملف: [`lib/features/emr/data/repositories/emr_repository_impl.dart`](../lib/features/emr/data/repositories/emr_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: EMRRepository)
class EMRRepositoryImpl implements EMRRepository {
  EMRRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, Unit>> saveEMR(
    EMRModel emr,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId موجود
      if (emr.appointmentId == null || emr.appointmentId!.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ السجل الطبي (EMR)'),
        );
      }

      final emrData = emr.toJson();
      
      // ✅ التحقق من أن appointmentId في البيانات
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

  // ... باقي الدوال بدون تغيير
}
```

---

## 📦 الجزء 7: تحديث DeviceRequestRepositoryImpl (Data Layer)

### الملف: [`lib/features/device_requests/data/repositories/device_request_repository_impl.dart`](../lib/features/device_requests/data/repositories/device_request_repository_impl.dart)

### التغييرات المطلوبة:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DeviceRequestRepository)
class DeviceRequestRepositoryImpl implements DeviceRequestRepository {
  DeviceRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, Unit>> saveDeviceRequest(
    DeviceRequestModel deviceRequest,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId موجود
      if (deviceRequest.appointmentId == null || deviceRequest.appointmentId!.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الجهاز الطبي'),
        );
      }

      final deviceRequestData = deviceRequest.toJson();
      
      // ✅ التحقق من أن appointmentId في البيانات
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

  // ... باقي الدوال بدون تغيير
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

## 📦 الجزء 8: تحديث جميع النماذج الطبية (Models)

### النماذج المطلوب تحديثها:

1. [`PrescriptionModel`](../lib/shared/models/prescription_model.dart)
2. [`LabRequestModel`](../lib/shared/models/lab_request_model.dart)
3. [`RadiologyRequestModel`](../lib/shared/models/radiology_request_model.dart)
4. [`EMRModel`](../lib/shared/models/emr_model.dart)
5. [`DeviceRequestModel`](../lib/shared/models/device_request_model.dart)
6. [`InternalMedicineEMRModel`](../lib/shared/models/internal_medicine_emr_model.dart)

### التغييرات المطلوبة في كل نموذج:

```dart
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

## 📦 الجزء 9: تحديث pubspec.yaml

### إضافة حزمة timezone:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... حزم أخرى
  timezone: ^0.9.4  # ✅ مطلوب لدعم توقيت الرياض
```

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

// 2. حفظ الموعد القديم
await appointmentRepository.saveAppointment(oldAppointment);

// 3. محاولة حفظ وصفة طبية
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

### 1. التحقق من توقيت الرياض

تأكد من أن توقيت الرياض يعمل بشكل صحيح:

```dart
import 'package:timezone/timezone.dart' as tz;

void main() async {
  // الحصول على توقيت الرياض
  final riyadhTimezone = tz.getLocation('Asia/Riyadh');
  print('Riyadh Timezone: ${riyadhTimezone}');
  
  // الحصول على الوقت الحالي في الرياض
  final now = tz.TZDateTime.now(riyadhTimezone);
  print('Current time in Riyadh: $now');
}
```

### 2. التحقق من صحة Timestamp في Firestore

افتح Firebase Console وتحقق من:
1. أن حقل `appointmentTimestamp` موجود في وثيقة الموعد
2. أن النوع هو `Timestamp` (وليس String)
3. أن القيمة صحيحة (التاريخ والوقت في توقيت الرياض)

### 3. التحقق من وجود appointmentId في البيانات الطبية

افتح Firebase Console وتحقق من:
1. أن حقل `appointmentId` موجود في جميع الوثائق الطبية
2. أن القيمة صحيحة (تطابق معرف الموعد)
3. أن الوثائق مرتبطة بالمجموعة الفرعية الصحيحة

---

## 📊 ملخص التغييرات (Summary of Changes)

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
| 13 | [`lib/shared/models/internal_medicine_emr_model.dart`](../lib/shared/models/internal_medicine_emr_model.dart) | التحقق من appointmentId | 🟡 متوسطة |
| 14 | [`pubspec.yaml`](../pubspec.yaml) | إضافة timezone | 🟡 متوسطة |

---

## 🎯 النتائج المتوقعة (Expected Results)

### بعد تطبيق جميع التغييرات:

1. ✅ **يتم حفظ `appointmentTimestamp`** بصيغة Timestamp في Firestore
2. ✅ **يتم استخدام توقيت الرياض** لجميع المواعيد
3. ✅ **يتم إرسال `appointmentId`** في جميع البيانات الطبية
4. ✅ **يتم منع الحفظ** بعد 24 ساعة برسالة واضحة
5. ✅ **يتم التحقق من صحة البيانات** قبل الحفظ

---

**تاريخ التحديث**: 2026-01-14  
**الحالة**: جاهز للتنفيذ (Ready for Implementation)
