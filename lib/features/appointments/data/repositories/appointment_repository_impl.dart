import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:elajtech/shared/models/appointment_model.dart';
import 'package:elajtech/core/services/appointment_conflict_validation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
// ✅ جديد: استيراد timezone لدعم توقيت الرياض
import 'package:timezone/timezone.dart' as tz;

/// Appointment Repository implementation for the AndroCare360 system.
///
/// This repository implements the [AppointmentRepository] interface and handles
/// all Firestore operations for appointment management including booking, retrieval,
/// conflict detection, and timezone handling for Riyadh (Asia/Riyadh).
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'appointments' (from AppConstants.collections.appointments)
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - Timezone: All timestamps use Asia/Riyadh timezone
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final appointmentRepository = getIt<AppointmentRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(ServerFailure): Operation failed with error message
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - ServerFailure: Database operation errors, network issues, timeouts
///
/// **Conflict Detection:**
/// Uses compound Firestore indexes for efficient conflict checking:
/// - Patient-centric index: patientId + status + appointmentTimestamp
/// - Doctor-centric index: doctorId + status + appointmentTimestamp
/// - Includes retry logic for index propagation delays
///
/// **Retry Logic:**
/// - Max retry attempts: 1
/// - Retry delay: 2500ms
/// - Query timeout: 10 seconds
/// - Handles 'failed-precondition' errors during index propagation
///
/// **Usage Example:**
/// ```dart
/// final appointment = AppointmentModel(...);
/// final result = await appointmentRepository.saveAppointment(appointment);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('تم حجز الموعد بنجاح'),
/// );
/// ```
@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  /// The [_firestore] instance is configured with databaseId: 'elajtech'
  /// in firebase_module.dart and injected by GetIt.
  AppointmentRepositoryImpl(this._firestore, this._functions);

  /// Firestore instance configured for 'elajtech' database
  final FirebaseFirestore _firestore;

  /// Firebase Functions instance configured for 'europe-west1'
  final FirebaseFunctions _functions;

  /// Maximum number of retry attempts for failed-precondition errors
  static const int _maxRetryAttempts = 1;

  /// Delay between retry attempts
  static const Duration _retryDelay = Duration(milliseconds: 2500);

  /// Timeout duration for Firestore queries
  static const Duration _queryTimeout = Duration(seconds: 10);

  /// Saves a new appointment to Firestore with Riyadh timezone handling.
  ///
  /// This method creates or updates an appointment document in Firestore.
  /// It automatically converts the appointment time to Asia/Riyadh timezone
  /// and adds an appointmentTimestamp field for accurate time-based queries.
  ///
  /// **Timezone Handling:**
  /// - Converts fullDateTime to Asia/Riyadh timezone
  /// - Stores as appointmentTimestamp for query accuracy
  /// - Ensures consistent time handling across the system
  ///
  /// **Debug Logging:**
  /// Logs appointment ID, patient ID, doctor ID, timestamp, and database name.
  ///
  /// Parameters:
  /// - [appointment]: AppointmentModel to save (required)
  ///
  /// Returns:
  /// - Right(Unit): Appointment saved successfully
  /// - Left(ServerFailure): Save operation failed
  ///
  /// Example:
  /// ```dart
  /// final appointment = AppointmentModel(
  ///   id: 'apt_123',
  ///   patientId: 'patient_456',
  ///   doctorId: 'doctor_789',
  ///   appointmentDate: DateTime(2024, 3, 15),
  ///   timeSlot: '10:00 ص',
  ///   status: AppointmentStatus.pending,
  ///   // ... other fields
  /// );
  /// final result = await repository.saveAppointment(appointment);
  /// ```
  @override
  Future<Either<Failure, Unit>> saveAppointment(
    AppointmentModel appointment,
  ) async {
    try {
      // ✅ تحويل التاريخ إلى توقيت الرياض
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');

      // ✅ إنشاء appointmentTimestamp من fullDateTime
      DateTime appointmentTimestamp;
      // تحويل DateTime إلى توقيت الرياض
      appointmentTimestamp = tz.TZDateTime.from(
        appointment.fullDateTime,
        riyadhTimezone,
      );

      // ✅ إنشاء نسخة من الموعد مع appointmentTimestamp
      final appointmentWithTimestamp = appointment.copyWith(
        appointmentTimestamp: appointmentTimestamp,
      );

      // ✅ منع حجز المواعيد في الماضي (أكثر من 5 دقائق من الآن)
      // يتم تجاوز هذا الفحص فقط في حالات الإلغاء والاكتمال وما شابه ذلك
      if (appointment.status != AppointmentStatus.cancelled &&
          appointment.status != AppointmentStatus.completed &&
          appointment.status != AppointmentStatus.missed) {
        final now = tz.TZDateTime.now(riyadhTimezone);
        if (appointmentTimestamp.isBefore(
          now.subtract(const Duration(minutes: 5)),
        )) {
          if (kDebugMode) {
            debugPrint(
              '❌ [AppointmentRepository] Cannot save appointment in the past',
            );
          }
          return const Left(ServerFailure('لا يمكن حجز موعد في وقت سابق'));
        }
      }

      if (kDebugMode) {
        debugPrint('🔵 [AppointmentRepository] Saving appointment:');
        debugPrint('   • Appointment ID: ${appointment.id}');
        debugPrint('   • Patient ID: ${appointment.patientId}');
        debugPrint('   • Doctor ID: ${appointment.doctorId}');
        debugPrint('   • Timestamp: $appointmentTimestamp');
        debugPrint('   • Database: elajtech (via injected _firestore)');
      }

      await _firestore
          .collection(AppConstants.collections.appointments)
          .doc(appointment.id)
          .set(appointmentWithTimestamp.toJson());

      // ✅ إذا تم إلغاء الموعد، نقوم بتفريغ الـ slot
      if (appointment.status == AppointmentStatus.cancelled) {
        final slotId =
            '${appointment.doctorId}_${appointmentWithTimestamp.appointmentTimestamp?.millisecondsSinceEpoch}';
        await _firestore.collection('appointment_slots').doc(slotId).delete();
        if (kDebugMode) {
          debugPrint('🗑️ [AppointmentRepository] Removed slot lock: $slotId');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ [AppointmentRepository] Appointment saved successfully');
      }

      return const Right(unit);
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AppointmentRepository] Save failed: $e');
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieves all appointments for a specific patient.
  ///
  /// This method fetches all appointments associated with a patient ID,
  /// ordered by appointment date in descending order (newest first).
  ///
  /// Parameters:
  /// - [patientId]: ID of the patient (required)
  ///
  /// Returns:
  /// - `Right(List<AppointmentModel>)`: List of patient's appointments
  /// - `Left(ServerFailure)`: Query failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getAppointmentsForPatient('patient_123');
  /// result.fold(
  ///   (failure) => showError('فشل تحميل المواعيد'),
  ///   (appointments) => displayAppointments(appointments),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForPatient(
    String patientId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.appointments)
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: true)
          .get();

      final appointments = query.docs
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();

      return Right(appointments);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<AppointmentModel>>>
  getAppointmentsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.appointments)
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: true)
          .limit(limit + 1)
          .get();

      final hasMore = query.docs.length > limit;
      final appointments = query.docs
          .take(limit)
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();

      return Right(PaginatedResult(items: appointments, hasMore: hasMore));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieves all appointments for a specific doctor.
  ///
  /// This method fetches all appointments associated with a doctor ID.
  /// Results are not ordered by default.
  ///
  /// Parameters:
  /// - [doctorId]: ID of the doctor (required)
  ///
  /// Returns:
  /// - `Right(List<AppointmentModel>)`: List of doctor's appointments
  /// - `Left(ServerFailure)`: Query failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getAppointmentsForDoctor('doctor_789');
  /// result.fold(
  ///   (failure) => showError('فشل تحميل المواعيد'),
  ///   (appointments) => displayDoctorSchedule(appointments),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<AppointmentModel>>> getAppointmentsForDoctor(
    String doctorId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.appointments)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final appointments = query.docs
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();

      return Right(appointments);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getDoctorAppointmentsViaCloudFunction({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');
      final startOfDay = tz.TZDateTime(
        riyadhTimezone,
        date.year,
        date.month,
        date.day,
      );
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      if (kDebugMode) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint(
          '📊 [Doctor Slots CF] Loading doctor appointments via Cloud Function',
        );
        debugPrint('   • Doctor ID: $doctorId');
        debugPrint('   • Date: $date');
        debugPrint('   • Time Range: $startOfDay → $endOfDay');
        debugPrint('   • Region: europe-west1 (via injected _functions)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      final callable = _functions.httpsCallable(
        'checkDoctorAppointments',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final result = await callable.call<Map<String, dynamic>>(
        <String, dynamic>{
          'doctorId': doctorId,
          'startTimeMs': startOfDay.millisecondsSinceEpoch,
          'endTimeMs': endOfDay.millisecondsSinceEpoch,
        },
      );

      final appointmentsData =
          (result.data['appointments'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      if (kDebugMode) {
        debugPrint(
          '✅ [Doctor Slots CF] Loaded ${appointmentsData.length} appointments',
        );
      }

      return Right(appointmentsData);
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [Doctor Slots CF] FirebaseFunctionsException: ${e.code} - ${e.message}',
        );
      }
      return Left(ServerFailure(e.message ?? e.toString()));
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Doctor Slots CF] Unexpected error: $e');
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Executes a Firestore query with intelligent retry logic for index propagation.
  ///
  /// This helper method handles the 'failed-precondition' error that occurs when
  /// Firestore indexes are still propagating across distributed nodes. It implements
  /// a retry strategy with configurable attempts and delays.
  ///
  /// **Retry Strategy:**
  /// - Retries on 'failed-precondition' errors only
  /// - Maximum attempts: _maxRetryAttempts (1)
  /// - Delay between retries: _retryDelay (2500ms)
  /// - Query timeout: _queryTimeout (10 seconds)
  ///
  /// **Debug Logging:**
  /// Logs retry attempts, query results, timeouts, and errors.
  ///
  /// Parameters:
  /// - [query]: Firestore query to execute (required)
  /// - [queryName]: Descriptive name for logging (required)
  ///
  /// Returns QuerySnapshot on success.
  ///
  /// Throws:
  /// - FirebaseException: If all retries fail or other Firebase errors occur
  /// - TimeoutException: If query exceeds timeout duration
  ///
  /// Example usage:
  /// ```dart
  /// final result = await _executeQueryWithRetry(
  ///   query,
  ///   queryName: 'Patient Conflict Check',
  /// );
  /// ```
  Future<QuerySnapshot<Map<String, dynamic>>> _executeQueryWithRetry(
    Query<Map<String, dynamic>> query, {
    required String queryName,
  }) async {
    var attempt = 0;

    while (attempt <= _maxRetryAttempts) {
      try {
        if (kDebugMode && attempt > 0) {
          debugPrint(
            '🔄 [Retry] Attempting $queryName (Attempt ${attempt + 1}/${_maxRetryAttempts + 1})',
          );
        }

        final result = await query.get().timeout(_queryTimeout);

        if (kDebugMode) {
          debugPrint(
            '✅ [$queryName] Query succeeded with ${result.docs.length} results',
          );
        }

        return result;
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition' && attempt < _maxRetryAttempts) {
          if (kDebugMode) {
            debugPrint('⚠️ [$queryName] Index not ready (failed-precondition)');
            debugPrint('   • Error: ${e.message}');
            debugPrint(
              '   • Waiting ${_retryDelay.inMilliseconds}ms before retry...',
            );
          }

          attempt++;
          await Future<void>.delayed(_retryDelay);
          continue;
        }

        // إذا فشلت جميع المحاولات أو كان الخطأ من نوع آخر، نعيد رمي الاستثناء
        rethrow;
      } on TimeoutException {
        if (kDebugMode) {
          debugPrint(
            '❌ [$queryName] Query timeout after ${_queryTimeout.inSeconds}s',
          );
        }
        rethrow;
      }
    }

    // هذا السطر لن يصل إليه أبداً، لكنه ضروري للتوافق مع Dart type system
    throw Exception('Unexpected error in _executeQueryWithRetry');
  }

  /// Checks for appointment conflicts for both patient and doctor.
  ///
  /// This method performs a comprehensive dual conflict check using compound
  /// Firestore indexes to efficiently detect scheduling conflicts. It checks:
  /// 1. Patient conflicts: Same patient, same day, active status
  /// 2. Doctor conflicts: Same doctor, same day, active status
  ///
  /// **Compound Indexes Used:**
  /// - Patient-centric: patientId + status + appointmentTimestamp
  /// - Doctor-centric: doctorId + status + appointmentTimestamp
  ///
  /// **Active Statuses Checked:**
  /// - pending, confirmed, scheduled, completed (excludes cancelled/missed)
  ///
  /// **Timezone Handling:**
  /// - Uses Asia/Riyadh timezone for day boundaries
  /// - Queries appointmentTimestamp field for accuracy
  ///
  /// **Parallel Execution:**
  /// - Runs both queries concurrently using Future.wait
  /// - Includes retry logic for index propagation delays
  ///
  /// **Conflict Validation:**
  /// - Uses AppointmentConflictValidationService for time slot validation
  /// - Checks for overlapping time slots
  /// - Provides detailed conflict reasons
  ///
  /// **Debug Logging:**
  /// Comprehensive logging of:
  /// - Query parameters and time ranges
  /// - Query results (patient and doctor conflicts)
  /// - Validation decisions
  /// - Error details
  ///
  /// Parameters:
  /// - [patientId]: ID of the patient booking the appointment (required)
  /// - [newAppointment]: Appointment to check for conflicts (required)
  ///
  /// Returns:
  /// - Right(true): Conflict detected, appointment cannot be booked
  /// - Right(false): No conflict, appointment can be booked
  /// - Left(ServerFailure): Check failed with error message
  ///
  /// Possible Failures:
  /// - 'الفهارس الأمنية لا تزال قيد الإعداد...': Indexes still propagating
  /// - 'لا يوجد اتصال بالإنترنت': Network error
  /// - 'انتهت مهلة الاتصال...': Query timeout
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.checkAppointmentConflict(
  ///   patientId: 'patient_123',
  ///   newAppointment: appointment,
  /// );
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (hasConflict) {
  ///     if (hasConflict) {
  ///       showError('يوجد تعارض في المواعيد');
  ///     } else {
  ///       proceedWithBooking();
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, bool>> checkAppointmentConflict({
    required String patientId,
    required AppointmentModel newAppointment,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔍 [Dual Conflict Check] Starting validation...');
        debugPrint('   • Patient ID: $patientId');
        debugPrint('   • Doctor ID: ${newAppointment.doctorId}');
        debugPrint('   • Appointment Date: ${newAppointment.appointmentDate}');
        debugPrint('   • Appointment Time Slot: ${newAppointment.timeSlot}');
        debugPrint('   • Database: elajtech (via injected _firestore)');
      }

      // ✅ تحديد بداية ونهاية اليوم بتوقيت الرياض
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');
      final startOfDay = tz.TZDateTime(
        riyadhTimezone,
        newAppointment.appointmentDate.year,
        newAppointment.appointmentDate.month,
        newAppointment.appointmentDate.day,
      );
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      if (kDebugMode) {
        debugPrint('   • Time Range: $startOfDay → $endOfDay');
      }

      // قائمة الحالات النشطة
      final activeStatuses = [
        AppointmentStatus.pending.name,
        AppointmentStatus.confirmed.name,
        AppointmentStatus.scheduled.name,
        AppointmentStatus.completed.name,
      ];

      if (kDebugMode) {
        debugPrint('   • Active Statuses: ${activeStatuses.join(", ")}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      // ✅ 1. استعلام مواعيد المريض (Patient-Centric Index)
      // الفهرس: patientId (ASC) + status (ASC) + appointmentTimestamp (ASC)
      if (kDebugMode) {
        debugPrint('📊 [Patient Query] Preparing query with compound index:');
        debugPrint('   • Index: patientId + status + appointmentTimestamp');
      }

      final patientQuery = _firestore
          .collection(AppConstants.collections.appointments)
          .where('patientId', isEqualTo: patientId)
          .where('status', whereIn: activeStatuses)
          .where(
            'appointmentTimestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'appointmentTimestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          );

      // ✅ 2. استعلام مواعيد الطبيب (Doctor-Centric - Cloud Function)
      // تم نقل هذا الاستعلام إلى Cloud Function لتجاوز قيود التصاريح الأمنية
      if (kDebugMode) {
        debugPrint(
          '📊 [Doctor Query] Calling Cloud Function: checkDoctorAppointments',
        );
      }

      // ✅ استخدام الخادم في نفس المنطقة المرفوع عليها (europe-west1)
      final checkDoctorCall = _functions.httpsCallable(
        'checkDoctorAppointments',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      // ✅ تنفيذ الاستعلامين بشكل متوازي
      if (kDebugMode) {
        debugPrint(
          '⚡ [Parallel Execution] Running patient query and doctor cloud function...',
        );
      }

      final results = await Future.wait<dynamic>([
        _executeQueryWithRetry(
          patientQuery,
          queryName: 'Patient Conflict Check',
        ),
        checkDoctorCall.call<Map<String, dynamic>>(<String, dynamic>{
          'doctorId': newAppointment.doctorId,
          'startTimeMs': startOfDay.millisecondsSinceEpoch,
          'endTimeMs': endOfDay.millisecondsSinceEpoch,
        }),
      ]);

      final patientDocs =
          (results[0] as QuerySnapshot<Map<String, dynamic>>).docs;
      final doctorResult = results[1] as HttpsCallableResult<dynamic>;
      final doctorAppointmentsData =
          (doctorResult.data as Map<String, dynamic>)['appointments']
              as List<dynamic>;

      if (kDebugMode) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📋 [Query Results Summary]:');
        debugPrint('   • Patient Conflicts Found: ${patientDocs.length}');
        debugPrint(
          '   • Doctor Conflicts Found: ${doctorAppointmentsData.length}',
        );
      }

      // دمج النتائج (مع إزالة التكرار)
      final allAppointments = <AppointmentModel>[];

      for (final doc in patientDocs) {
        final appointment = AppointmentModel.fromJson(doc.data());
        allAppointments.add(appointment);

        if (kDebugMode) {
          debugPrint(
            '   • Patient Appointment: ${doc.id} at ${appointment.timeSlot}',
          );
        }
      }

      for (final apptData in doctorAppointmentsData) {
        final data = Map<String, dynamic>.from(apptData as Map);
        // تجنب إضافة نفس الموعد مرتين (إذا كان المريض هو نفسه صاحب الطلب وتكرر الموعد)
        if (!allAppointments.any((app) => app.id == data['id'])) {
          // نحتاج لتحويل البيانات القادمة من Cloud Function إلى AppointmentModel
          // بما أن Cloud Function ترجع بيانات مختزلة، سنقوم بإنشاء موديل بسيط للتحقق فقط
          final appointment = AppointmentModel(
            id: data['id'] as String,
            patientId: data['patientId'] as String,
            patientName: '', // غير مطلوب للتحقق
            patientPhone: '', // غير مطلوب للتحقق
            doctorId: data['doctorId'] as String,
            doctorName: data['doctorName'] as String? ?? '',
            specialization: '', // غير مطلوب للتحقق
            appointmentDate:
                newAppointment.appointmentDate, // نستخدم تاريخ اليوم
            timeSlot: data['timeSlot'] as String,
            type: data['type'] == 'clinic'
                ? AppointmentType.clinic
                : AppointmentType.video,
            status: AppointmentStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => AppointmentStatus.pending,
            ),
            fee: 0,
            createdAt: DateTime.now(),
            appointmentTimestamp: DateTime.fromMillisecondsSinceEpoch(
              data['appointmentTimestamp'] as int,
            ),
          );

          allAppointments.add(appointment);

          if (kDebugMode) {
            debugPrint(
              '   • Doctor Appointment (via CF): ${data['id']} at ${appointment.timeSlot}',
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint('   • Total Unique Appointments: ${allAppointments.length}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      // استخدام خدمة التحقق من التضارب
      if (kDebugMode) {
        debugPrint('🔍 [Conflict Validation] Running validation service...');
      }

      final validationResult = AppointmentConflictValidationService()
          .checkConflict(
            newAppointment: newAppointment,
            existingAppointments: allAppointments,
          );

      if (kDebugMode) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🎯 [Final Decision]:');
        debugPrint('   • Has Conflict: ${validationResult.hasConflict}');
        if (validationResult.hasConflict) {
          debugPrint('   • Conflict Reason: ${validationResult.message}');
        }
        debugPrint(
          '   • Decision: ${validationResult.hasConflict ? "BLOCK ❌" : "ALLOW ✅"}',
        );
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }

      return Right(validationResult.hasConflict);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Firebase Exception]:');
        debugPrint('   • Code: ${e.code}');
        debugPrint('   • Message: ${e.message}');
        debugPrint('   • Stack Trace: ${e.stackTrace}');
      }

      if (e.code == 'failed-precondition') {
        // إذا وصلنا هنا، فهذا يعني أن جميع محاولات الـ Retry فشلت
        return const Left(
          ServerFailure(
            'الفهارس الأمنية لا تزال قيد الإعداد. يرجى المحاولة مرة أخرى بعد دقيقتين.',
          ),
        );
      }
      if (e.code == 'unavailable') {
        return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
      }
      return Left(ServerFailure(e.message ?? e.toString()));
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Network Exception]: ${e.message}');
      }
      return const Left(ServerFailure('لا يوجد اتصال بالإنترنت'));
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [Timeout Exception]: ${e.message}');
      }
      return const Left(
        ServerFailure('انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [Unexpected Exception]: $e');
        debugPrint('   • Stack Trace: $stackTrace');
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieves active appointments for a specific patient.
  ///
  /// This method fetches appointments with 'pending' or 'confirmed' status
  /// for a patient, ordered by appointment date in descending order.
  /// Excludes completed, cancelled, and missed appointments.
  ///
  /// **Active Statuses:**
  /// - pending: Awaiting doctor confirmation
  /// - confirmed: Doctor confirmed the appointment
  ///
  /// Parameters:
  /// - [patientId]: ID of the patient (required)
  ///
  /// Returns:
  /// - `Right(List<AppointmentModel>)`: List of active appointments
  /// - `Left(ServerFailure)`: Query failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getActiveAppointmentsForPatient('patient_123');
  /// result.fold(
  ///   (failure) => showError('فشل تحميل المواعيد النشطة'),
  ///   (appointments) => displayUpcomingAppointments(appointments),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<AppointmentModel>>>
  getActiveAppointmentsForPatient(
    String patientId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.appointments)
          .where('patientId', isEqualTo: patientId)
          .where(
            'status',
            whereIn: [
              AppointmentStatus.pending.name,
              AppointmentStatus.confirmed.name,
            ],
          )
          .orderBy('appointmentDate', descending: true)
          .get();

      final appointments = query.docs
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();

      return Right(appointments);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieves all active appointments for a specific date.
  ///
  /// This method fetches all appointments scheduled for a given date with
  /// active statuses (pending, confirmed, scheduled, completed). Excludes
  /// cancelled and missed appointments.
  ///
  /// **Timezone Handling:**
  /// - Uses Asia/Riyadh timezone for day boundaries
  /// - Queries appointmentTimestamp field for accuracy
  /// - Includes appointments from start of day (00:00:00) to end of day (23:59:59)
  ///
  /// **Active Statuses:**
  /// - pending: Awaiting confirmation
  /// - confirmed: Confirmed by doctor
  /// - scheduled: Scheduled with specific time
  /// - completed: Appointment finished
  ///
  /// **Use Cases:**
  /// - Doctor's daily schedule view
  /// - Clinic capacity planning
  /// - Conflict detection for specific dates
  ///
  /// Parameters:
  /// - [date]: Date to query appointments for (required)
  ///
  /// Returns:
  /// - `Right(List<AppointmentModel>)`: List of appointments for the date
  /// - `Left(ServerFailure)`: Query failed
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime.now();
  /// final result = await repository.getActiveAppointmentsForDate(today);
  /// result.fold(
  ///   (failure) => showError('فشل تحميل مواعيد اليوم'),
  ///   (appointments) => displayDailySchedule(appointments),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<AppointmentModel>>> getActiveAppointmentsForDate(
    DateTime date,
  ) async {
    try {
      // ✅ تحديد بداية ونهاية اليوم بتوقيت الرياض
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');
      final startOfDay = tz.TZDateTime(
        riyadhTimezone,
        date.year,
        date.month,
        date.day,
      );
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // ✅ استعلام قاعدة البيانات
      // نستخدم appointmentTimestamp للدقة في الوقت
      // ونستثني المواعيد الملغية
      final query = await _firestore
          .collection(AppConstants.collections.appointments)
          .where(
            'appointmentTimestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'appointmentTimestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .where(
            'status',
            whereIn: [
              AppointmentStatus.pending.name,
              AppointmentStatus.confirmed.name,
              AppointmentStatus.scheduled.name,
              AppointmentStatus.completed.name,
            ],
          )
          .get();

      final appointments = query.docs
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();

      return Right(appointments);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Books an appointment using a Firestore transaction to prevent race conditions.
  ///
  /// This method uses a separate 'appointment_slots' collection to act as a lock
  /// for a specific doctor's time slot. The document ID is formatted as:
  /// `doctor_[doctorId]_[timestamp_ms]`.
  @override
  Future<Either<Failure, Unit>> bookAppointment(
    AppointmentModel appointment,
  ) async {
    try {
      final riyadhTimezone = tz.getLocation('Asia/Riyadh');
      final appointmentTimestamp = tz.TZDateTime.from(
        appointment.fullDateTime,
        riyadhTimezone,
      );

      // 1. Validation: Past date
      final now = tz.TZDateTime.now(riyadhTimezone);
      if (appointmentTimestamp.isBefore(
        now.subtract(const Duration(minutes: 5)),
      )) {
        return const Left(ServerFailure('لا يمكن حجز موعد في وقت سابق'));
      }

      // predictable slot ID for doctor locking
      final slotId =
          '${appointment.doctorId}_${appointmentTimestamp.millisecondsSinceEpoch}';
      final slotRef = _firestore.collection('appointment_slots').doc(slotId);
      final appointmentRef = _firestore
          .collection(AppConstants.collections.appointments)
          .doc(appointment.id);

      if (kDebugMode) {
        debugPrint(
          '🔄 [AppointmentRepository] Starting booking transaction...',
        );
        debugPrint('   • Slot ID: $slotId');
      }

      await _firestore.runTransaction<void>((transaction) async {
        // 2. Check if doctor's slot is already taken
        final slotDoc = await transaction.get(slotRef);
        if (slotDoc.exists) {
          throw Exception(
            'عذراً، هذا الموعد تم حجزه للتو. يرجى اختيار وقت آخر.',
          );
        }

        // 3. Mark slot as busy (Locking)
        transaction
          ..set(slotRef, {
            'appointmentId': appointment.id,
            'patientId': appointment.patientId,
            'doctorId': appointment.doctorId,
            'timestamp': Timestamp.fromDate(appointmentTimestamp),
            'createdAt': FieldValue.serverTimestamp(),
          })
          // 4. Save the actual appointment
          ..set(
            appointmentRef,
            appointment
                .copyWith(appointmentTimestamp: appointmentTimestamp)
                .toJson(),
          );
      });

      if (kDebugMode) {
        debugPrint('✅ [AppointmentRepository] Booking transaction completed');
      }

      return const Right(unit);
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AppointmentRepository] Booking failed: $e');
      }
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// مراقبة مواعيد المريض في الوقت الفعلي
  /// Real-time stream of all appointments for the patient.
  ///
  /// Uses Firestore [snapshots()] so the stream emits a new list whenever
  /// any appointment document changes — enabling the patient's UI to
  /// react immediately when the doctor starts a call.
  @override
  Stream<List<AppointmentModel>> watchAppointmentsForPatient(String patientId) {
    return _firestore
        .collection(AppConstants.collections.appointments)
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AppointmentModel.fromJson({
                ...data,
                'id': (data['id'] as String?)?.isNotEmpty ?? false
                    ? data['id']
                    : doc.id,
              });
            }).toList());
  }
}
