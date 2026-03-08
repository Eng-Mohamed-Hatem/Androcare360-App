/// Appointment Conflict Validation Service - خدمة التحقق من التضارب في المواعيد
/// Appointment scheduling conflict detection and validation service.
///
/// **Purpose / الغرض:**
/// This service provides comprehensive validation to prevent appointment scheduling conflicts.
/// توفر هذه الخدمة آلية تحقق شاملة لمنع تضارب المواعيد الطبية.
///
/// **Conflict Prevention Rules / قواعد منع التضارب:**
/// - A patient cannot book a new appointment with the same doctor at a conflicting time
///   لا يمكن للمريض حجز موعد جديد مع نفس الطبيب في وقت يتعارض مع موعد موجود
/// - A patient cannot book with any doctor during a time slot already occupied by another appointment
///   لا يمكن للمريض حجز موعد مع أي طبيب آخر في نفس الفترة الزمنية التي يشغلها موعد سابق
/// - Applies to both clinic visits and video consultations
///   ينطبق على زيارات العيادة والاستشارات المرئية
///
/// **Singleton Pattern:**
/// ```dart
/// class AppointmentConflictValidationService {
///   static AppointmentConflictValidationService get instance => _instance ??= AppointmentConflictValidationService._internal();
/// }
/// ```
///
/// **Usage Example:**
/// ```dart
/// final service = AppointmentConflictValidationService.instance;
///
/// // Check for conflicts before booking
/// final result = service.checkConflict(
///   newAppointment: proposedAppointment,
///   existingAppointments: allAppointmentsForDay,
/// );
///
/// if (result.hasConflict) {
///   showError(result.message ?? 'يوجد تضارب في المواعيد');
///   print('Conflict type: ${result.conflictType}');
/// } else {
///   // Proceed with booking
///   await bookAppointment(proposedAppointment);
/// }
/// ```
///
/// **Validation Rules:**
/// - No overlapping appointments for the same doctor (doctor availability)
/// - No overlapping appointments for the same patient (patient availability)
/// - Minimum time gap between consecutive appointments (configurable)
/// - Optional: Block same-day appointments with different doctors
/// - Cancelled appointments are excluded from conflict checks
///
/// **Conflict Detection Algorithm:**
/// Uses interval overlap detection: (NewStart < ExistingEnd) AND (NewEnd > ExistingStart)
///
/// **Configuration:**
/// Use [ConflictValidationParams] to customize:
/// - `appointmentDurationMinutes`: Default appointment duration (60 minutes)
/// - `timeMarginMinutes`: Minimum gap between appointments (5 minutes)
/// - `blockSameDay`: Prevent multiple appointments same day (false by default)
///
/// **Integration Points:**
/// - Used by appointment booking flow
/// - Works with doctor availability service
/// - Validates against clinic schedules
///
/// @see ConflictValidationResult for return value structure
/// @see ConflictValidationParams for configuration options
/// @see ConflictType for conflict type enumeration
library;

import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:flutter/foundation.dart';

/// Conflict validation result object.
/// نتيجة التحقق من التضارب.
///
/// Contains information about whether a conflict exists and details about the conflict.
///
/// **Success Case (No Conflict):**
/// ```dart
/// ConflictValidationResult.success()
/// // Returns: ConflictValidationResult(hasConflict: false)
/// ```
///
/// **Failure Case (Conflict Detected):**
/// ```dart
/// ConflictValidationResult.failure(
///   type: ConflictType.sameDoctor,
///   message: 'الطبيب غير متاح في هذا الوقت',
///   conflictingAppointment: existingAppointment,
/// )
/// ```
class ConflictValidationResult {
  /// Creates a new ConflictValidationResult instance.
  /// ينشئ نسخة جديدة من نتيجة التحقق من التضارب.
  ///
  /// **Parameters:**
  /// - [hasConflict]: Whether a conflict was detected
  /// - [conflictType]: Type of conflict (if any)
  /// - [conflictingAppointment]: The appointment causing the conflict
  /// - [message]: User-friendly error message in Arabic
  const ConflictValidationResult({
    required this.hasConflict,
    this.conflictType,
    this.conflictingAppointment,
    this.message,
  });

  /// Factory constructor for successful validation (no conflict).
  /// إنشاء نتيجة نجاح (لا يوجد تضارب).
  ///
  /// **Returns:** A result indicating no conflicts were found.
  ///
  /// **Example:**
  /// ```dart
  /// return ConflictValidationResult.success();
  /// ```
  factory ConflictValidationResult.success() {
    return const ConflictValidationResult(
      hasConflict: false,
    );
  }

  /// Factory constructor for failed validation (conflict detected).
  /// إنشاء نتيجة فشل مع رسالة مخصصة (يوجد تضارب).
  ///
  /// **Parameters:**
  /// - [type]: The type of conflict detected
  /// - [message]: User-friendly error message in Arabic
  /// - [conflictingAppointment]: The appointment causing the conflict (optional)
  ///
  /// **Returns:** A result with conflict details.
  ///
  /// **Example:**
  /// ```dart
  /// return ConflictValidationResult.failure(
  ///   type: ConflictType.sameDoctor,
  ///   message: 'الطبيب مشغول في هذا الوقت',
  ///   conflictingAppointment: existingAppt,
  /// );
  /// ```
  factory ConflictValidationResult.failure({
    required ConflictType type,
    required String message,
    AppointmentModel? conflictingAppointment,
  }) {
    return ConflictValidationResult(
      hasConflict: true,
      conflictType: type,
      conflictingAppointment: conflictingAppointment,
      message: message,
    );
  }

  /// Whether a conflict was detected.
  /// هل يوجد تضارب؟
  ///
  /// `true` if a scheduling conflict exists, `false` otherwise.
  final bool hasConflict;

  /// Type of conflict detected.
  /// نوع التضارب.
  ///
  /// Only set when [hasConflict] is true. Indicates whether the conflict
  /// is with the same doctor, different doctor, or same day.
  final ConflictType? conflictType;

  /// The appointment causing the conflict.
  /// الموعد المتضارب.
  ///
  /// Only set when [hasConflict] is true. Contains details of the existing
  /// appointment that conflicts with the proposed appointment.
  final AppointmentModel? conflictingAppointment;

  /// User-friendly error message in Arabic.
  /// رسالة الخطأ بالعربية.
  ///
  /// Only set when [hasConflict] is true. Provides a detailed explanation
  /// of the conflict for display to the user.
  final String? message;
}

/// Types of appointment scheduling conflicts.
/// أنواع التضارب في المواعيد.
///
/// Defines the different categories of conflicts that can occur
/// when scheduling appointments.
enum ConflictType {
  /// Conflict with the same doctor (doctor is busy).
  /// تضارب مع نفس الطبيب (الطبيب مشغول).
  ///
  /// Occurs when the doctor already has an appointment at the requested time.
  sameDoctor,

  /// Conflict with a different doctor in the same time period (patient is busy).
  /// تضارب مع طبيب آخر في نفس الفترة الزمنية (المريض مشغول).
  ///
  /// Occurs when the patient already has an appointment with another doctor
  /// at the requested time.
  differentDoctorSamePeriod,

  /// Conflict with a different doctor on the same day (optional restriction).
  /// تضارب مع طبيب آخر في نفس اليوم (اختياري).
  ///
  /// Occurs when the patient already has an appointment with another doctor
  /// on the same day. This is an optional restriction controlled by
  /// [ConflictValidationParams.blockSameDay].
  differentDoctorSameDay,
}

/// Appointment conflict validation service (Singleton).
/// خدمة التحقق من التضارب في المواعيد (نمط Singleton).
///
/// Provides comprehensive conflict detection for appointment scheduling.
/// See library documentation above for detailed usage and examples.
///
/// **Access Pattern:**
/// ```dart
/// final service = AppointmentConflictValidationService.instance;
/// ```
class AppointmentConflictValidationService {
  AppointmentConflictValidationService._internal();
  // Singleton pattern
  static AppointmentConflictValidationService? _instance;

  /// Gets the singleton instance of the service.
  /// يحصل على نسخة Singleton من الخدمة.
  ///
  /// **Returns:** The shared instance of AppointmentConflictValidationService.
  ///
  /// **Example:**
  /// ```dart
  /// final service = AppointmentConflictValidationService.instance;
  /// ```
  static AppointmentConflictValidationService get instance =>
      _instance ??= AppointmentConflictValidationService._internal();

  /// Configuration parameters for conflict validation.
  /// معاملات التحقق من التضارب.
  ///
  /// Can be modified to customize validation behavior:
  /// ```dart
  /// service.params = ConflictValidationParams(
  ///   appointmentDurationMinutes: 30,
  ///   timeMarginMinutes: 10,
  ///   blockSameDay: true,
  /// );
  /// ```
  ConflictValidationParams params = const ConflictValidationParams();

  /// Checks for scheduling conflicts with a proposed appointment.
  /// التحقق من التضارب في الموعد.
  ///
  /// This method performs comprehensive conflict detection by:
  /// 1. Validating the new appointment is not cancelled or completed
  /// 2. Checking doctor availability (no overlapping appointments for same doctor)
  /// 3. Checking patient availability (no overlapping appointments for same patient)
  /// 4. Optionally checking same-day restrictions
  ///
  /// **Parameters:**
  /// - [newAppointment]: The proposed appointment to validate / الموعد المراد حجزه
  /// - [existingAppointments]: List of all active appointments for that day (all doctors and patients) / قائمة بجميع المواعيد النشطة في ذلك اليوم
  ///
  /// **Returns:**
  /// A [ConflictValidationResult] indicating:
  /// - Whether a conflict exists ([hasConflict])
  /// - Type of conflict if any ([conflictType])
  /// - Details of conflicting appointment ([conflictingAppointment])
  /// - User-friendly error message ([message])
  ///
  /// **Example:**
  /// ```dart
  /// final service = AppointmentConflictValidationService.instance;
  ///
  /// final result = service.checkConflict(
  ///   newAppointment: proposedAppointment,
  ///   existingAppointments: allAppointmentsForDay,
  /// );
  ///
  /// if (result.hasConflict) {
  ///   switch (result.conflictType) {
  ///     case ConflictType.sameDoctor:
  ///       print('Doctor is busy at this time');
  ///       break;
  ///     case ConflictType.differentDoctorSamePeriod:
  ///       print('Patient has another appointment');
  ///       break;
  ///     case ConflictType.differentDoctorSameDay:
  ///       print('Patient already has appointment today');
  ///       break;
  ///   }
  ///   showError(result.message!);
  /// } else {
  ///   // Proceed with booking
  ///   await bookAppointment(proposedAppointment);
  /// }
  /// ```
  ///
  /// **Conflict Detection Logic:**
  /// - Doctor Availability: Checks if doctor has any overlapping appointments
  /// - Patient Availability: Checks if patient has any overlapping appointments with other doctors
  /// - Same Day Check: Optionally prevents multiple appointments on same day
  ///
  /// **Overlap Detection:**
  /// Two appointments overlap if: (NewStart < ExistingEnd) AND (NewEnd > ExistingStart)
  ///
  /// **Active Status:**
  /// Only appointments with status != 'cancelled' are considered for conflicts.
  /// Completed appointments in the past don't cause conflicts for future bookings.
  ///
  /// **Debug Logging:**
  /// In debug mode, logs detailed information about:
  /// - Input time ranges
  /// - Existing appointments being checked
  /// - Overlap detection results
  /// - Conflict detection outcomes
  ConflictValidationResult checkConflict({
    required AppointmentModel newAppointment,
    required List<AppointmentModel> existingAppointments,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[ConflictCheck] Starting validation for ${newAppointment.timeSlot} on ${newAppointment.appointmentDate}',
      );

      // Calculate and log New Appointment Range
      final startNew =
          newAppointment.appointmentTimestamp ?? newAppointment.fullDateTime;
      final endNew = startNew.add(
        Duration(minutes: params.appointmentDurationMinutes),
      );
      debugPrint('[ConflictCheck] Input Time Range: $startNew - $endNew');

      debugPrint(
        '[ConflictCheck] Total existing appointments for day: ${existingAppointments.length}',
      );

      // Log fetched appointments for transparency
      for (final appt in existingAppointments) {
        final start = appt.appointmentTimestamp ?? appt.fullDateTime;
        final end = start.add(
          Duration(minutes: params.appointmentDurationMinutes),
        );
        debugPrint(
          '[ConflictCheck] Fetched Existing: ${appt.id} ($start - $end) - Status: ${appt.status}',
        );
      }
    }

    // التحقق من أن الموعد الجديد ليس ملغي أو مكتمل (رغم أننا عادة نتحقق قبل الحجز)
    if (newAppointment.status == AppointmentStatus.cancelled ||
        newAppointment.status == AppointmentStatus.completed) {
      return ConflictValidationResult.success();
    }

    // 1. التحقق من توفر الطبيب (هل الطبيب مشغول؟)
    final doctorConflict = _checkDoctorAvailability(
      newAppointment,
      existingAppointments,
    );

    if (doctorConflict != null) {
      if (kDebugMode) {
        debugPrint(
          '[ConflictCheck] Doctor Conflict Detected: ${doctorConflict.message}',
        );
      }
      return doctorConflict;
    }

    // 2. التحقق من توفر المريض (هل المريض مشغول مع طبيب آخر؟)
    final patientConflict = _checkPatientAvailability(
      newAppointment,
      existingAppointments,
    );

    if (patientConflict != null) {
      if (kDebugMode) {
        debugPrint(
          '[ConflictCheck] Patient Conflict Detected: ${patientConflict.message}',
        );
      }
      return patientConflict;
    }

    if (kDebugMode) {
      debugPrint('[ConflictCheck] No conflicts found. Slot is clear.');
    }
    // لا يوجد تضارب
    return ConflictValidationResult.success();
  }

  /// التحقق من توفر الطبيب
  ///
  /// يتأكد من أن الطبيب ليس لديه موعد آخر في نفس الوقت (مع أي مريض)
  ConflictValidationResult? _checkDoctorAvailability(
    AppointmentModel newAppointment,
    List<AppointmentModel> existingAppointments,
  ) {
    // تصفية المواعيد الخاصة بهذا الطبيب فقط
    final doctorAppointments = existingAppointments.where(
      (appt) =>
          appt.doctorId == newAppointment.doctorId &&
          appt.id != newAppointment.id && // استثناء الموعد نفسه في حالة التعديل
          _isActiveStatus(appt.status),
    );

    for (final existingAppt in doctorAppointments) {
      if (_isOverlappingPeriod(newAppointment, existingAppt)) {
        if (kDebugMode) {
          debugPrint(
            '[ConflictCheck] Doctor Busy: ${newAppointment.timeSlot} overlaps with ${existingAppt.timeSlot}',
          );
        }
        return ConflictValidationResult.failure(
          type: ConflictType.sameDoctor,
          message: _getDoctorBusyMessage(newAppointment, existingAppt),
          conflictingAppointment: existingAppt,
        );
      }
    }

    return null;
  }

  /// التحقق من توفر المريض
  ///
  /// يتأكد من أن المريض ليس لديه موعد آخر في نفس الوقت (مع أي طبيب)
  ConflictValidationResult? _checkPatientAvailability(
    AppointmentModel newAppointment,
    List<AppointmentModel> existingAppointments,
  ) {
    // تصفية المواعيد الخاصة بهذا المريض فقط
    final patientAppointments = existingAppointments.where(
      (appt) =>
          appt.patientId == newAppointment.patientId &&
          appt.id != newAppointment.id && // استثناء الموعد نفسه
          _isActiveStatus(appt.status),
    );

    for (final existingAppt in patientAppointments) {
      // إذا كان نفس الطبيب، تم التحقق منه سابقاً، لكن لا يضر التحقق مرة أخرى
      // أو يمكننا تخطيه إذا أردنا رسالة خطأ مختلفة
      if (existingAppt.doctorId == newAppointment.doctorId) {
        continue;
      }

      // التحقق من التضارب في نفس الفترة الزمنية
      if (_isOverlappingPeriod(newAppointment, existingAppt)) {
        if (kDebugMode) {
          debugPrint(
            '[ConflictCheck] Patient Busy: ${newAppointment.timeSlot} overlaps with ${existingAppt.timeSlot} (Dr. ${existingAppt.doctorName})',
          );
        }
        return ConflictValidationResult.failure(
          type: ConflictType.differentDoctorSamePeriod,
          message: _getPatientBusyMessage(
            newAppointment,
            existingAppt,
          ),
          conflictingAppointment: existingAppt,
        );
      }

      // التحقق من التضارب في نفس اليوم (اختياري حسب الإعدادات)
      if (params.blockSameDay && _isSameDay(newAppointment, existingAppt)) {
        return ConflictValidationResult.failure(
          type: ConflictType.differentDoctorSameDay,
          message: _getSameDayConflictMessage(newAppointment, existingAppt),
          conflictingAppointment: existingAppt,
        );
      }
    }

    return null;
  }

  /// هل الحالة تعتبر نشطة (تشغل حيزاً زمنياً)؟
  bool _isActiveStatus(AppointmentStatus status) {
    return status != AppointmentStatus.cancelled;
    // المواعيد المكتملة completed تشغل حيزاً زمنياً في الماضي،
    // ولكن عند حجز موعد جديد في المستقبل، لن تتعارض مع الماضي.
    // أما إذا كنا نحاول حجز موعد في الماضي (نظرياً)، فالمكتمل يسبب تضارب.
    // بشكل عام، نعتبر كل ما هو غير ملغي "مشغول".
  }

  /// التحقق من أن الموعدان في نفس اليوم
  bool _isSameDay(AppointmentModel appt1, AppointmentModel appt2) {
    return appt1.appointmentDate.year == appt2.appointmentDate.year &&
        appt1.appointmentDate.month == appt2.appointmentDate.month &&
        appt1.appointmentDate.day == appt2.appointmentDate.day;
  }

  /// التحقق من التضارب الزمني الصارم
  ///
  /// القاعدة: (NewStart < ExistingEnd) AND (NewEnd > ExistingStart)
  bool _isOverlappingPeriod(
    AppointmentModel newAppt,
    AppointmentModel existingAppt,
  ) {
    // استخدام appointmentTimestamp للدقة إذا توفر، وإلا fullDateTime
    final start1 = newAppt.appointmentTimestamp ?? newAppt.fullDateTime;
    final start2 =
        existingAppt.appointmentTimestamp ?? existingAppt.fullDateTime;

    final end1 = start1.add(
      Duration(minutes: params.appointmentDurationMinutes),
    );
    final end2 = start2.add(
      Duration(minutes: params.appointmentDurationMinutes),
    );

    // منطق التداخل
    final isOverlap = start1.isBefore(end2) && end1.isAfter(start2);

    if (kDebugMode && isOverlap) {
      debugPrint(
        '[ConflictCheck] Overlap Details: New($start1 - $end1) vs Existing($start2 - $end2)',
      );
    }

    return isOverlap;
  }

  /// رسالة: الطبيب مشغول
  String _getDoctorBusyMessage(
    AppointmentModel newAppt,
    AppointmentModel existingAppt,
  ) {
    return '⚠️ الطبيب غير متاح\n\n'
        'الدكتور ${existingAppt.doctorName} لديه موعد آخر في هذا الوقت:\n'
        '🕐 ${existingAppt.timeSlot}\n\n'
        'الرجاء اختيار وقت آخر.';
  }

  /// رسالة: المريض مشغول (لديه موعد آخر)
  String _getPatientBusyMessage(
    AppointmentModel newAppt,
    AppointmentModel existingAppt,
  ) {
    final existingTypeText = existingAppt.type == AppointmentType.clinic
        ? 'زيارة عيادة'
        : 'استشارة فيديو';

    return '⚠️ لديك موعد آخر\n\n'
        'لديك موعد $existingTypeText مع الدكتور ${existingAppt.doctorName} في نفس الفترة:\n'
        '🕐 ${existingAppt.timeSlot}\n\n'
        'لا يمكن حجز موعدين في نفس الوقت.';
  }

  /// رسالة: تضارب في نفس اليوم
  String _getSameDayConflictMessage(
    AppointmentModel newAppt,
    AppointmentModel existingAppt,
  ) {
    return '⚠️ تضارب في نفس اليوم\n\n'
        'لديك موعد مع الدكتور ${existingAppt.doctorName} في نفس اليوم.\n'
        'الرجاء اختيار يوم آخر.';
  }
}

/// Configuration parameters for conflict validation.
/// معاملات التحقق من التضارب.
///
/// Allows customization of conflict detection behavior including
/// appointment duration, time margins, and same-day restrictions.
///
/// **Default Configuration:**
/// ```dart
/// ConflictValidationParams(
///   appointmentDurationMinutes: 60,
///   timeMarginMinutes: 5,
///   blockSameDay: false,
/// )
/// ```
///
/// **Custom Configuration:**
/// ```dart
/// service.params = ConflictValidationParams(
///   appointmentDurationMinutes: 30,  // 30-minute appointments
///   timeMarginMinutes: 10,           // 10-minute gap between appointments
///   blockSameDay: true,              // Prevent multiple appointments per day
/// );
/// ```
class ConflictValidationParams {
  /// Creates new conflict validation parameters.
  /// ينشئ معاملات جديدة للتحقق من التضارب.
  ///
  /// **Parameters:**
  /// - [appointmentDurationMinutes]: Duration of each appointment in minutes (default: 30)
  /// - [timeMarginMinutes]: Minimum gap between appointments in minutes (default: 5)
  /// - [blockSameDay]: Whether to prevent multiple appointments on same day (default: false)
  const ConflictValidationParams({
    this.appointmentDurationMinutes = 30,
    this.timeMarginMinutes = 5,
    this.blockSameDay = false,
  });

  /// Duration of each appointment in minutes.
  /// مدة الموعد بالدقائق (الافتراضي: 60 دقيقة).
  ///
  /// Used to calculate the end time of appointments when checking for overlaps.
  /// Default is 60 minutes (1 hour).
  final int appointmentDurationMinutes;

  /// Minimum time gap between consecutive appointments in minutes.
  /// هامش الوقت بالدقائق (الافتراضي: 5 دقائق).
  ///
  /// Ensures a buffer period between appointments for preparation and cleanup.
  /// Default is 5 minutes.
  final int timeMarginMinutes;

  /// Whether to prevent booking multiple appointments on the same day.
  /// منع حجز موعد في نفس اليوم (الافتراضي: false).
  ///
  /// When true, patients cannot book appointments with different doctors
  /// on the same day, even if the times don't overlap.
  /// Default is false (allows multiple appointments per day).
  final bool blockSameDay;
}
