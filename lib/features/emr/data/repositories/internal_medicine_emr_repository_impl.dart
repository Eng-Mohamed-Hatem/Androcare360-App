import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/emr/domain/repositories/internal_medicine_emr_repository.dart';
import 'package:elajtech/shared/models/internal_medicine_emr_model.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Internal Medicine EMR Repository implementation for the AndroCare360 system.
///
/// This repository implements the [InternalMedicineEMRRepository] interface and handles
/// all Firestore operations for Internal Medicine Electronic Medical Records (EMR).
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'internal_medicine_emrs'
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - Server timestamps used for accuracy
///
/// **CLINIC ISOLATION PRINCIPLE:**
/// This repository is specific to the Internal Medicine clinic and must remain
/// completely independent from other specialty clinics (Nutrition, Physiotherapy, etc.)
/// to maintain the Single Responsibility Principle (SRP) and ensure project scalability.
/// Each clinic has its own dedicated Model and Repository.
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<InternalMedicineEMRRepository>();
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
/// **Special Features:**
/// - System Review: Comprehensive multi-system assessment
/// - Chronic Disease Management: Track ongoing conditions
/// - ICD-10 Code Integration: Standard diagnosis coding
/// - Vital Signs Tracking: Monitor patient vitals over time
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<InternalMedicineEMRRepository>();
///
/// // Save EMR with system review
/// final emr = InternalMedicineEMRModel(
///   id: 'emr_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   chiefComplaint: 'Chest pain',
///   systemReview: {...}, // Multi-system assessment
///   // ... other fields
/// );
///
/// final result = await repository.saveEMR(emr);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('Internal Medicine EMR saved'),
/// );
/// ```
@LazySingleton(as: InternalMedicineEMRRepository)
class InternalMedicineEMRRepositoryImpl
    implements InternalMedicineEMRRepository {
  /// Constructor with dependency injection.
  ///
  /// The [firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - firestore: Configured FirebaseFirestore instance (injected, required)
  InternalMedicineEMRRepositoryImpl({required this.firestore});

  /// Firestore instance configured with 'elajtech' database.
  final FirebaseFirestore firestore;

  /// Collection name constant for internal medicine EMRs.
  ///
  /// Used consistently across all Firestore operations to ensure correct
  /// collection targeting.
  static const String collectionName = 'internal_medicine_emrs';

  /// Save or update an Internal Medicine EMR record.
  ///
  /// Persists an internal medicine EMR to Firestore with comprehensive medical
  /// data including system review, chronic diseases, vital signs, and ICD-10 codes.
  ///
  /// **Data Structure:**
  /// - Chief complaint and history of present illness
  /// - System review (cardiovascular, respiratory, gastrointestinal, etc.)
  /// - Chronic disease management
  /// - Physical examination findings
  /// - Vital signs (BP, HR, temperature, etc.)
  /// - Diagnosis with ICD-10 codes
  /// - Treatment plan and medications
  ///
  /// Parameters:
  /// - emr: InternalMedicineEMRModel to save (required)
  ///   - Must include all required fields per model definition
  ///   - System review data structure
  ///   - ICD-10 codes for diagnoses
  ///
  /// Returns:
  /// - Right(void): EMR saved successfully
  /// - Left(Failure.firestore): Firestore operation failed
  ///   - `Firebase error: code - message`: Firestore exception
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - `Unexpected error: ...`: Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final emr = InternalMedicineEMRModel(
  ///   id: 'emr_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   chiefComplaint: 'Chest pain and shortness of breath',
  ///   systemReview: {
  ///     'cardiovascular': 'Chest pain on exertion',
  ///     'respiratory': 'Shortness of breath',
  ///   },
  ///   vitalSigns: {
  ///     'bloodPressure': '140/90',
  ///     'heartRate': 88,
  ///   },
  ///   diagnosis: 'Hypertension',
  ///   icd10Code: 'I10',
  ///   // ... other fields
  /// );
  ///
  /// final result = await repository.saveEMR(emr);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Internal Medicine EMR saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveEMR(InternalMedicineEMRModel emr) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: saveEMR | Status: started',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] DatabaseId: ${firestore.databaseId}',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] EMR ID: ${emr.id} | Appointment ID: ${emr.appointmentId}',
        );
        debugPrint('[InternalMedicineEMRRepo] Patient ID: ${emr.patientId}');
      }

      await firestore.collection(collectionName).doc(emr.id).set(emr.toJson());

      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: saveEMR | Status: success',
        );
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: saveEMR | Status: error',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: saveEMR | Status: error',
        );
        debugPrint('[InternalMedicineEMRRepo] Exception: $e');
        debugPrint('[InternalMedicineEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve an Internal Medicine EMR by appointment ID.
  ///
  /// Queries the 'internal_medicine_emrs' collection for an EMR associated with
  /// the specified appointment. Returns null if no EMR exists for the appointment.
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'appointmentId' field
  /// - Limits result to 1 document for efficiency
  /// - Returns null if no documents found
  ///
  /// **Retrieved Data:**
  /// - Complete system review
  /// - Chronic disease history
  /// - Physical examination findings
  /// - Vital signs
  /// - Diagnosis with ICD-10 codes
  /// - Treatment plan
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - Right(InternalMedicineEMRModel): EMR found and parsed successfully
  /// - Right(null): No EMR exists for this appointment
  /// - Left(Failure.firestore): Firestore operation failed
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - `Unexpected error: ...`: Parsing or runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getEMRByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emr) {
  ///     if (emr != null) {
  ///       displayInternalMedicineEMR(emr);
  ///       showSystemReview(emr.systemReview);
  ///       showVitalSigns(emr.vitalSigns);
  ///     } else {
  ///       showMessage('No EMR found for this appointment');
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, InternalMedicineEMRModel?>> getEMRByAppointmentId(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByAppointmentId | Status: started',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] DatabaseId: ${firestore.databaseId}',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] Appointment ID: $appointmentId',
        );
      }

      final querySnapshot = await firestore
          .collection(collectionName)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[InternalMedicineEMRRepo] Operation: getEMRByAppointmentId | Status: success | Result: null (not found)',
          );
        }
        return const Right(null);
      }

      final emr = InternalMedicineEMRModel.fromJson(
        querySnapshot.docs.first.data(),
      );

      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByAppointmentId | Status: success',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] EMR ID: ${emr.id} | Patient ID: ${emr.patientId}',
        );
      }

      return Right(emr);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[InternalMedicineEMRRepo] Exception: $e');
        debugPrint('[InternalMedicineEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve all Internal Medicine EMRs for a specific patient.
  ///
  /// Queries the 'internal_medicine_emrs' collection for all EMR records associated
  /// with the specified patient, ordered by creation date (newest first).
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'patientId' field
  /// - Orders by 'createdAt' descending (newest first)
  /// - Returns empty list if no EMRs found
  ///
  /// **Use Cases:**
  /// - Display patient's complete medical history
  /// - Track chronic disease progression over time
  /// - Review past diagnoses and treatments
  /// - Monitor vital signs trends
  /// - Analyze system review patterns
  ///
  /// **Retrieved Data:**
  /// - All EMRs with complete system reviews
  /// - Chronic disease history across visits
  /// - Vital signs trends
  /// - Diagnosis history with ICD-10 codes
  /// - Treatment plans and medications
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - `Right(List<InternalMedicineEMRModel>)`: List of EMRs (may be empty)
  /// - `Left(Failure.firestore)`: Firestore operation failed
  /// - `Left(Failure.unexpected)`: Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - `Unexpected error: ...`: Query or runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getEMRByPatientId('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emrs) {
  ///     if (emrs.isEmpty) {
  ///       showMessage('No internal medicine records found');
  ///     } else {
  ///       displayMedicalHistory(emrs); // Shows ${emrs.length} visits
  ///       analyzeChronicDiseases(emrs);
  ///       showVitalSignsTrends(emrs);
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, List<InternalMedicineEMRModel>>> getEMRByPatientId(
    String patientId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByPatientId | Status: started',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] DatabaseId: ${firestore.databaseId}',
        );
        debugPrint('[InternalMedicineEMRRepo] Patient ID: $patientId');
      }

      final querySnapshot = await firestore
          .collection(collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map((doc) => InternalMedicineEMRModel.fromJson(doc.data()))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByPatientId | Status: success',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] Found ${emrs.length} EMR records',
        );
      }

      return Right(emrs);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint(
          '[InternalMedicineEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[InternalMedicineEMRRepo] Operation: getEMRByPatientId | Status: error',
        );
        debugPrint('[InternalMedicineEMRRepo] Exception: $e');
        debugPrint('[InternalMedicineEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
