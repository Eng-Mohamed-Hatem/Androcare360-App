import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/emr/domain/repositories/physiotherapy_emr_repository.dart';
import 'package:elajtech/shared/models/physiotherapy_emr_model.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Physiotherapy EMR Repository implementation for the AndroCare360 system.
///
/// This repository implements the [PhysiotherapyEMRRepository] interface and handles
/// all Firestore operations for Physiotherapy Electronic Medical Records (EMR).
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'physiotherapy_emrs'
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - Server timestamps used for accuracy
///
/// **CLINIC ISOLATION PRINCIPLE:**
/// This repository is specific to the Physiotherapy clinic and must remain completely
/// independent from other specialty clinics (Nutrition, Internal Medicine, etc.)
/// to maintain the Single Responsibility Principle (SRP) and ensure project scalability.
/// Each clinic has its own dedicated Model and Repository.
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<PhysiotherapyEMRRepository>();
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
/// - Firestore security rules enforce same-day appointment editing
/// - Empty appointmentId will cause operation to fail
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<PhysiotherapyEMRRepository>();
///
/// // Save EMR
/// final emr = PhysiotherapyEMRModel(
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
/// ```
@LazySingleton(as: PhysiotherapyEMRRepository)
class PhysiotherapyEMRRepositoryImpl implements PhysiotherapyEMRRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  PhysiotherapyEMRRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Collection name constant for physiotherapy EMRs.
  ///
  /// Used consistently across all Firestore operations to ensure correct
  /// collection targeting.
  static const String collectionName = 'physiotherapy_emrs';

  /// Save or update a Physiotherapy EMR record.
  ///
  /// Persists a physiotherapy EMR to Firestore with validation and security checks.
  /// The appointmentId is required for Firestore security rules that enforce
  /// same-day appointment editing restrictions.
  ///
  /// **Validation:**
  /// - Validates appointmentId is not empty before saving
  /// - Empty appointmentId causes operation to fail immediately
  ///
  /// **Security Rules:**
  /// - Firestore security rules use appointmentId to enforce same-day editing
  /// - Only EMRs for appointments on the current day can be modified
  /// - This prevents editing old appointment records
  ///
  /// Parameters:
  /// - emr: PhysiotherapyEMRModel to save (required)
  ///   - Must have non-empty appointmentId
  ///   - All other fields as per model definition
  ///
  /// Returns:
  /// - Right(void): EMR saved successfully
  /// - Left(Failure.firestore): Firestore operation failed
  ///   - 'appointmentId is required to save Physiotherapy EMR': appointmentId is empty
  ///   - 'Firebase error: [code] - [message]': Firestore exception
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'appointmentId is required to save Physiotherapy EMR': Validation failed
  /// - 'Firebase error: permission-denied': Security rules rejected (not same day)
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final emr = PhysiotherapyEMRModel(
  ///   id: 'emr_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   chiefComplaint: 'Lower back pain',
  ///   // ... other fields
  /// );
  ///
  /// final result = await repository.saveEMR(emr);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Physiotherapy EMR saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveEMR(PhysiotherapyEMRModel emr) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: saveEMR | Status: started',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] DatabaseId: ${_firestore.databaseId}',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] EMR ID: ${emr.id} | Appointment ID: ${emr.appointmentId}',
        );
        debugPrint('[PhysiotherapyEMRRepo] Patient ID: ${emr.patientId}');
      }

      // Validate appointmentId for security rules (same appointment day rule)
      if (emr.appointmentId.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[PhysiotherapyEMRRepo] Operation: saveEMR | Status: failed | Reason: Empty appointment ID',
          );
        }
        return const Left(
          Failure.firestore(
            'appointmentId is required to save Physiotherapy EMR',
          ),
        );
      }

      await _firestore.collection(collectionName).doc(emr.id).set(emr.toJson());

      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: saveEMR | Status: success',
        );
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: saveEMR | Status: error',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: saveEMR | Status: error',
        );
        debugPrint('[PhysiotherapyEMRRepo] Exception: $e');
        debugPrint('[PhysiotherapyEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve a Physiotherapy EMR by appointment ID.
  ///
  /// Queries the 'physiotherapy_emrs' collection for an EMR associated with the
  /// specified appointment. Returns null if no EMR exists for the appointment.
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'appointmentId' field
  /// - Limits result to 1 document for efficiency
  /// - Returns null if no documents found
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - Right(PhysiotherapyEMRModel): EMR found and parsed successfully
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
  ///       displayPhysiotherapyEMR(emr);
  ///     } else {
  ///       showMessage('No EMR found for this appointment');
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, PhysiotherapyEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByAppointmentId | Status: started',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] DatabaseId: ${_firestore.databaseId}',
        );
        debugPrint('[PhysiotherapyEMRRepo] Appointment ID: $appointmentId');
      }

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[PhysiotherapyEMRRepo] Operation: getEMRByAppointmentId | Status: success | Result: null (not found)',
          );
        }
        return const Right(null);
      }

      final emr = PhysiotherapyEMRModel.fromJson(
        querySnapshot.docs.first.data(),
      );

      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByAppointmentId | Status: success',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] EMR ID: ${emr.id} | Patient ID: ${emr.patientId}',
        );
      }

      return Right(emr);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[PhysiotherapyEMRRepo] Exception: $e');
        debugPrint('[PhysiotherapyEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve all Physiotherapy EMRs for a specific patient.
  ///
  /// Queries the 'physiotherapy_emrs' collection for all EMR records associated
  /// with the specified patient, ordered by creation date (newest first).
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'patientId' field
  /// - Orders by 'createdAt' descending (newest first)
  /// - Returns empty list if no EMRs found
  ///
  /// **Use Cases:**
  /// - Display patient's physiotherapy treatment history
  /// - Track progress across multiple sessions
  /// - Review past assessments and treatment plans
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - Right(List<PhysiotherapyEMRModel>): List of EMRs (may be empty)
  /// - Left(Failure.firestore): Firestore operation failed
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Query or runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getEMRByPatientId('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emrs) {
  ///     if (emrs.isEmpty) {
  ///       showMessage('No physiotherapy records found');
  ///     } else {
  ///       displayTreatmentHistory(emrs); // Shows ${emrs.length} sessions
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, List<PhysiotherapyEMRModel>>> getEMRByPatientId(
    String patientId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByPatientId | Status: started',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] DatabaseId: ${_firestore.databaseId}',
        );
        debugPrint('[PhysiotherapyEMRRepo] Patient ID: $patientId');
      }

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map((doc) => PhysiotherapyEMRModel.fromJson(doc.data()))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByPatientId | Status: success',
        );
        debugPrint('[PhysiotherapyEMRRepo] Found ${emrs.length} EMR records');
      }

      return Right(emrs);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint(
          '[PhysiotherapyEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[PhysiotherapyEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint('[PhysiotherapyEMRRepo] Exception: $e');
        debugPrint('[PhysiotherapyEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
