import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart';
import 'package:elajtech/shared/models/emr_model.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Base EMR Repository implementation for the AndroCare360 system.
///
/// This repository implements the [EMRRepository] interface and handles
/// all Firestore operations for general Electronic Medical Records (EMR).
/// This serves as a base repository for common EMR functionality across
/// all specialty clinics.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.emrRecords
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - Server timestamps used for accuracy
///
/// **Repository Pattern:**
/// This is the base EMR repository that provides common functionality.
/// Specialized repositories (Nutrition, Physiotherapy, Internal Medicine)
/// extend or complement this base functionality with clinic-specific features.
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<EMRRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(Failure): Operation failed with specific failure type
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - Failure.firestore: Firestore operation errors
/// - Failure.unexpected: Unexpected runtime errors
///
/// **Security Rules:**
/// - appointmentId is required for all save operations
/// - Empty appointmentId will cause operation to fail
/// - Firestore security rules enforce appointment-based access control
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<EMRRepository>();
///
/// // Save general EMR
/// final emr = EMRModel(
///   id: 'emr_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   // ... other fields
/// );
///
/// final result = await repository.saveEMR(emr);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('EMR saved successfully'),
/// );
///
/// // Retrieve EMR by appointment
/// final emrResult = await repository.getEMRByAppointmentId('apt_456');
/// emrResult.fold(
///   (failure) => handleError(failure),
///   (emr) => emr != null ? displayEMR(emr) : showNotFound(),
/// );
/// ```
@LazySingleton(as: EMRRepository)
class EMRRepositoryImpl implements EMRRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  EMRRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Save or update a general EMR record.
  ///
  /// Persists a general EMR to Firestore with validation and security checks.
  /// The appointmentId is required for Firestore security rules that enforce
  /// appointment-based access control.
  ///
  /// **Validation:**
  /// - Validates appointmentId is not empty before saving
  /// - Empty appointmentId causes operation to fail immediately
  /// - Error message provided in Arabic for user-facing display
  ///
  /// **Security Rules:**
  /// - Firestore security rules use appointmentId for access control
  /// - Only authorized users can access EMRs for their appointments
  /// - This prevents unauthorized access to medical records
  ///
  /// **Collection Reference:**
  /// - Uses AppConstants.collections.emrRecords for collection name
  /// - Ensures consistent collection naming across the application
  ///
  /// Parameters:
  /// - emr: EMRModel to save (required)
  ///   - Must have non-empty appointmentId
  ///   - All other fields as per model definition
  ///
  /// Returns:
  /// - Right(Unit): EMR saved successfully (Unit from dartz)
  /// - Left(Failure.firestore): Firestore operation failed
  ///   - 'appointmentId مطلوب لحفظ السجل الطبي (EMR)': appointmentId is empty
  ///   - 'Firebase error: [code] - [message]': Firestore exception
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'appointmentId مطلوب لحفظ السجل الطبي (EMR)': Validation failed (Arabic message)
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final emr = EMRModel(
  ///   id: 'emr_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   doctorId: 'doctor_101',
  ///   // ... other fields
  /// );
  ///
  /// final result = await repository.saveEMR(emr);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('تم حفظ السجل الطبي بنجاح'),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> saveEMR(EMRModel emr) async {
    try {
      if (kDebugMode) {
        debugPrint('[EMRRepo] Operation: saveEMR | Status: started');
        debugPrint('[EMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint(
          '[EMRRepo] EMR ID: ${emr.id} | Appointment ID: ${emr.appointmentId}',
        );
        debugPrint('[EMRRepo] Patient ID: ${emr.patientId}');
      }

      // ✅ التحقق من أن appointmentId غير فارغ
      if (emr.appointmentId.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[EMRRepo] Operation: saveEMR | Status: failed | Reason: Empty appointment ID',
          );
        }
        return const Left(
          Failure.firestore('appointmentId مطلوب لحفظ السجل الطبي (EMR)'),
        );
      }

      await _firestore
          .collection(AppConstants.collections.emrRecords)
          .doc(emr.id)
          .set(emr.toJson());

      if (kDebugMode) {
        debugPrint('[EMRRepo] Operation: saveEMR | Status: success');
      }

      return const Right(unit);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('[EMRRepo] Operation: saveEMR | Status: error');
        debugPrint('[EMRRepo] FirebaseException: ${e.code} - ${e.message}');
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[EMRRepo] Operation: saveEMR | Status: error');
        debugPrint('[EMRRepo] Exception: $e');
        debugPrint('[EMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve a general EMR by appointment ID.
  ///
  /// Queries the EMR collection for a record associated with the specified
  /// appointment. Returns null if no EMR exists for the appointment.
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'appointmentId' field
  /// - Limits result to 1 document for efficiency
  /// - Returns null if no documents found
  ///
  /// **Collection Reference:**
  /// - Uses AppConstants.collections.emrRecords for collection name
  /// - Ensures consistent collection naming across the application
  ///
  /// **Use Cases:**
  /// - Check if EMR exists for an appointment
  /// - Retrieve EMR for viewing or editing
  /// - Validate EMR completion status
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - Right(EMRModel): EMR found and parsed successfully
  /// - Right(null): No EMR exists for this appointment
  /// - Left(Failure.firestore): Firestore operation failed
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Parsing or runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getEMRByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emr) {
  ///     if (emr != null) {
  ///       displayEMR(emr);
  ///       print('EMR found for patient: ${emr.patientId}');
  ///     } else {
  ///       showMessage('لا يوجد سجل طبي لهذا الموعد');
  ///       allowCreateNewEMR();
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, EMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[EMRRepo] Operation: getEMRByAppointmentId | Status: started',
        );
        debugPrint('[EMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[EMRRepo] Appointment ID: $appointmentId');
      }

      final query = await _firestore
          .collection(AppConstants.collections.emrRecords)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final emr = EMRModel.fromJson(query.docs.first.data());

        if (kDebugMode) {
          debugPrint(
            '[EMRRepo] Operation: getEMRByAppointmentId | Status: success',
          );
          debugPrint(
            '[EMRRepo] EMR ID: ${emr.id} | Patient ID: ${emr.patientId}',
          );
        }

        return Right(emr);
      }

      if (kDebugMode) {
        debugPrint(
          '[EMRRepo] Operation: getEMRByAppointmentId | Status: success | Result: null (not found)',
        );
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[EMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[EMRRepo] FirebaseException: ${e.code} - ${e.message}');
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[EMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[EMRRepo] Exception: $e');
        debugPrint('[EMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
