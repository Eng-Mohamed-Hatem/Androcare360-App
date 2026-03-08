import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/errors/failures.dart';
import 'package:elajtech/features/nutrition/data/models/nutrition_emr_model.dart';
import 'package:elajtech/features/nutrition/domain/entities/nutrition_emr_entity.dart';
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Nutrition EMR Repository implementation for the AndroCare360 system.
///
/// This repository implements the [NutritionEMRRepository] interface and handles
/// all Firestore operations for Nutrition Electronic Medical Records (EMR).
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'nutrition_emrs'
/// - All operations include comprehensive error handling
/// - All write operations are logged for debugging
/// - Server timestamps used for accuracy
///
/// **CLINIC ISOLATION PRINCIPLE:**
/// This repository is specific to the Nutrition clinic and must remain completely
/// independent from other specialty clinics (Physiotherapy, Internal Medicine, etc.)
/// to maintain the Single Responsibility Principle (SRP) and ensure project scalability.
/// Each clinic has its own dedicated Model and Repository.
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<NutritionEMRRepository>();
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
/// - Smart Upsert Logic: Automatically detects create vs update operations
/// - Record Locking: Prevents editing after 24-hour window expires
/// - Audit Logging: Tracks all changes with user, timestamp, and action
/// - Version Control: Maintains edit count and last editor information
/// - Real-time Streaming: Watch EMR changes with Firestore snapshots
/// - Completion Tracking: Calculates EMR completion percentage
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<NutritionEMRRepository>();
///
/// // Save EMR
/// final result = await repository.saveEMR(emrEntity);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('EMR saved successfully'),
/// );
///
/// // Get EMR by appointment
/// final emrResult = await repository.getEMRByAppointmentId(appointmentId);
/// emrResult.fold(
///   (failure) => handleError(failure),
///   (emr) => emr != null ? displayEMR(emr) : showNotFound(),
/// );
/// ```
@LazySingleton(as: NutritionEMRRepository)
class NutritionEMRRepositoryImpl implements NutritionEMRRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  NutritionEMRRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get Firestore collection reference for nutrition EMRs.
  ///
  /// Returns a collection reference to 'nutrition_emrs' in the 'elajtech' database.
  /// This ensures all operations use the correct named database instance.
  ///
  /// Returns:
  /// - CollectionReference: Reference to 'nutrition_emrs' collection
  CollectionReference get _collection =>
      _firestore.collection('nutrition_emrs');

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE & UPDATE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save or update a Nutrition EMR record with smart upsert logic.
  ///
  /// This method implements intelligent create/update detection by checking if an
  /// EMR already exists for the appointment. It automatically handles audit logging,
  /// version control, and edit tracking.
  ///
  /// **Smart Upsert Logic:**
  /// - Queries existing EMR by appointmentId
  /// - If found: Updates with incremented editCount and lastEditedBy tracking
  /// - If not found: Creates new EMR with initial audit log entry
  ///
  /// **Record Locking:**
  /// - Validates EMR is not locked before saving
  /// - Locked records cannot be modified (24-hour edit window expired)
  ///
  /// **Audit Logging:**
  /// - Creates audit log entry with timestamp, user, action, and changes
  /// - Appends to existing audit log array
  /// - Tracks 'created' vs 'updated' actions
  ///
  /// **Version Control:**
  /// - Increments editCount on updates (starts at 0 for new records)
  /// - Tracks lastEditedBy user ID and name
  /// - Updates updatedAt timestamp
  ///
  /// Parameters:
  /// - emr: NutritionEMREntity to save (required)
  ///   - Must have non-empty appointmentId
  ///   - Must not be locked (isCurrentlyLocked = false)
  ///
  /// Returns:
  /// - Right(void): EMR saved successfully
  /// - Left(Failure.firestore): Firestore operation failed
  ///   - 'Appointment ID is required': appointmentId is empty
  ///   - 'Cannot save locked EMR record': EMR is locked
  ///   - 'Firebase error: [code] - [message]': Firestore exception
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Appointment ID is required': appointmentId validation failed
  /// - 'Cannot save locked EMR record': Record is locked (24h expired)
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final emr = NutritionEMREntity(
  ///   id: 'emr_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   nutritionistId: 'doctor_101',
  ///   nutritionistName: 'Dr. Ahmed',
  ///   // ... other fields
  /// );
  ///
  /// final result = await repository.saveEMR(emr);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('EMR saved successfully'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveEMR(NutritionEMREntity emr) async {
    try {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: started');
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint(
          '[NutritionEMRRepo] EMR ID: ${emr.id} | Appointment ID: ${emr.appointmentId}',
        );
        debugPrint(
          '[NutritionEMRRepo] Patient ID: ${emr.patientId} | Nutritionist ID: ${emr.nutritionistId}',
        );
      }

      // Validate required fields
      if (emr.appointmentId.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRRepo] Operation: saveEMR | Status: failed | Reason: Empty appointment ID',
          );
        }
        return const Left(Failure.firestore('Appointment ID is required'));
      }

      // Check if record is locked
      if (emr.isCurrentlyLocked) {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRRepo] Operation: saveEMR | Status: failed | Reason: Record is locked',
          );
        }
        return const Left(Failure.firestore('Cannot save locked EMR record'));
      }

      // ✅ SMART UPSERT LOGIC: Check if record exists
      final existingEmrResult = await getEMRByAppointmentId(
        emr.appointmentId,
      );
      final isUpdate = existingEmrResult.fold(
        (failure) => false,
        (existingEmr) => existingEmr != null,
      );

      final now = DateTime.now();

      // Create audit log entry
      final auditEntry = AuditLogEntry(
        timestamp: now,
        userId: emr.nutritionistId,
        userName: emr.nutritionistName,
        action: isUpdate ? 'updated' : 'created',
        fieldChanged: isUpdate ? 'multiple_fields' : 'record',
        previousValue: '',
        newValue: 'EMR ${isUpdate ? "updated" : "created"}',
      );

      // ✅ FIX: Create updated entity with tracking fields
      final updatedEmr = emr.copyWith(
        auditLog: [...emr.auditLog, auditEntry],
        updatedAt: now,
        // Increment editCount only on updates (not on creation)
        editCount: isUpdate ? emr.editCount + 1 : 0,
        lastEditedBy: isUpdate ? emr.nutritionistId : null,
        lastEditedByName: isUpdate ? emr.nutritionistName : null,
      );

      // Convert entity to Firestore JSON
      final jsonData = NutritionEMRModel.entityToFirestore(updatedEmr);

      // Save to Firestore with merge option
      await _collection
          .doc(emr.id)
          .set(
            jsonData,
            SetOptions(merge: true),
          );

      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: success');
        debugPrint(
          '[NutritionEMRRepo] Action: ${auditEntry.action} ${isUpdate ? "(Update)" : "(Create)"}',
        );
        debugPrint(
          '[NutritionEMRRepo] Audit log entries: ${updatedEmr.auditLog.length}',
        );
        if (isUpdate) {
          debugPrint(
            '[NutritionEMRRepo] Edit count: ${updatedEmr.editCount} | Last edited by: ${updatedEmr.lastEditedByName}',
          );
        }
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: error');
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: saveEMR | Status: error');
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // READ OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Retrieve a Nutrition EMR by appointment ID.
  ///
  /// Queries the 'nutrition_emrs' collection for an EMR associated with the
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
  /// - Right(NutritionEMREntity): EMR found and parsed successfully
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
  ///     } else {
  ///       showMessage('No EMR found for this appointment');
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, NutritionEMREntity?>> getEMRByAppointmentId(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: started',
        );
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[NutritionEMRRepo] Appointment ID: $appointmentId');
      }

      final querySnapshot = await _collection
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: success | Result: null (not found)',
          );
        }
        return const Right(null);
      }

      final doc = querySnapshot.docs.first;
      if (!doc.exists) {
        return const Right(null);
      }

      final data = doc.data()! as Map<String, dynamic>;
      final entity = NutritionEMRModel.firestoreToEntity(data);

      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: success',
        );
        debugPrint(
          '[NutritionEMRRepo] EMR ID: ${entity.id} | Patient ID: ${entity.patientId}',
        );
        debugPrint(
          '[NutritionEMRRepo] Completion: ${entity.completionPercentage.toStringAsFixed(1)}%',
        );
      }

      return Right(entity);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRByAppointmentId | Status: error',
        );
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Retrieve all Nutrition EMRs for a specific patient.
  ///
  /// Queries the 'nutrition_emrs' collection for all EMR records associated with
  /// the specified patient, ordered by creation date (newest first).
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'patientId' field
  /// - Orders by 'createdAt' descending (newest first)
  /// - Returns empty list if no EMRs found
  /// - Skips documents that fail to parse (logs error)
  ///
  /// **Error Resilience:**
  /// - Individual document parsing errors are caught and logged
  /// - Failed documents are skipped, not causing entire operation to fail
  /// - Returns successfully parsed EMRs even if some documents are malformed
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - Right(List<NutritionEMREntity>): List of EMRs (may be empty)
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
  /// final result = await repository.getEMRsByPatientId('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (emrs) {
  ///     if (emrs.isEmpty) {
  ///       showMessage('No EMRs found for this patient');
  ///     } else {
  ///       displayEMRList(emrs); // Shows ${emrs.length} records
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, List<NutritionEMREntity>>> getEMRsByPatientId(
    String patientId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRsByPatientId | Status: started',
        );
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[NutritionEMRRepo] Patient ID: $patientId');
      }

      final querySnapshot = await _collection
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final emrs = querySnapshot.docs
          .map((doc) {
            try {
              return NutritionEMRModel.firestoreToEntity(
                doc.data()! as Map<String, dynamic>,
              );
            } on Exception catch (e) {
              if (kDebugMode) {
                debugPrint(
                  '[NutritionEMRRepo] Error parsing document ${doc.id}: $e',
                );
              }
              return null;
            }
          })
          .whereType<NutritionEMREntity>()
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRsByPatientId | Status: success',
        );
        debugPrint('[NutritionEMRRepo] Found ${emrs.length} EMR records');
      }

      return Right(emrs);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRsByPatientId | Status: error',
        );
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: getEMRsByPatientId | Status: error',
        );
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCK & EXPIRATION OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lock a Nutrition EMR record to prevent further editing.
  ///
  /// Sets the 'isLocked' flag to true, preventing any future modifications to the
  /// EMR. This is typically used when the 24-hour edit window expires or when a
  /// record needs to be finalized.
  ///
  /// **Lock Behavior:**
  /// - Sets isLocked = true in Firestore
  /// - Updates updatedAt timestamp
  /// - Locked records cannot be saved (saveEMR will fail)
  ///
  /// Parameters:
  /// - emrId: Unique EMR document identifier (required)
  ///
  /// Returns:
  /// - Right(void): EMR locked successfully
  /// - Left(Failure.firestore): Firestore operation failed
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: not-found': EMR document does not exist
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.lockEMR('emr_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('EMR locked successfully'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> lockEMR(String emrId) async {
    try {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: lockEMR | Status: started');
        debugPrint('[NutritionEMRRepo] DatabaseId: ${_firestore.databaseId}');
        debugPrint('[NutritionEMRRepo] EMR ID: $emrId');
      }

      await _collection.doc(emrId).update({
        'isLocked': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: lockEMR | Status: success');
      }

      return const Right(null);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: lockEMR | Status: error');
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: lockEMR | Status: error');
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  /// Check if an appointment's EMR edit window has expired.
  ///
  /// Determines if the 24-hour edit window for an appointment's EMR has expired
  /// by checking the EMR's lock status. Returns false if no EMR exists for the
  /// appointment.
  ///
  /// **Expiration Logic:**
  /// - Retrieves EMR by appointmentId
  /// - Checks isCurrentlyLocked property (computed from createdAt + 24 hours)
  /// - Returns false if no EMR found (not expired, can create new)
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - Right(true): EMR exists and edit window has expired (locked)
  /// - Right(false): No EMR exists OR edit window still active
  /// - Left(Failure): Error occurred during retrieval
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.isAppointmentExpired('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (isExpired) {
  ///     if (isExpired) {
  ///       showMessage('Cannot edit: 24-hour window expired');
  ///     } else {
  ///       allowEditing();
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, bool>> isAppointmentExpired(
    String appointmentId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: isAppointmentExpired | Status: started',
        );
        debugPrint('[NutritionEMRRepo] Appointment ID: $appointmentId');
      }

      final emrResult = await getEMRByAppointmentId(appointmentId);

      return emrResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '[NutritionEMRRepo] Operation: isAppointmentExpired | Status: error',
            );
          }
          return Left(failure);
        },
        (emr) {
          if (emr == null) {
            if (kDebugMode) {
              debugPrint(
                '[NutritionEMRRepo] Operation: isAppointmentExpired | Status: success | Result: false (no EMR found)',
              );
            }
            return const Right(false);
          }

          final isExpired = emr.isCurrentlyLocked;

          if (kDebugMode) {
            debugPrint(
              '[NutritionEMRRepo] Operation: isAppointmentExpired | Status: success',
            );
            debugPrint(
              '[NutritionEMRRepo] Is Locked: ${emr.isLocked} | Is Expired: $isExpired',
            );
            debugPrint(
              '[NutritionEMRRepo] Remaining Hours: ${emr.remainingEditHours}',
            );
          }

          return Right(isExpired);
        },
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: isAppointmentExpired | Status: error',
        );
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAM OPERATIONS (OPTIONAL)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Watch real-time changes to a Nutrition EMR record.
  ///
  /// Creates a Firestore snapshot stream that emits updates whenever the EMR
  /// document changes. Useful for real-time UI updates when multiple users
  /// might be viewing the same EMR.
  ///
  /// **Stream Behavior:**
  /// - Emits initial EMR state immediately
  /// - Emits new state on every Firestore document update
  /// - Throws exception if document doesn't exist or is deleted
  /// - Stream continues until cancelled by caller
  ///
  /// **Error Handling:**
  /// - Stream throws Exception if EMR not found
  /// - Caller should handle stream errors with onError callback
  ///
  /// Parameters:
  /// - emrId: Unique EMR document identifier (required)
  ///
  /// Returns:
  /// - Right(Stream<NutritionEMREntity>): Real-time EMR stream
  /// - Left(Failure.firestore): Firestore operation failed
  /// - Left(Failure.unexpected): Unexpected runtime error
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Stream setup exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.watchEMR('emr_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (stream) {
  ///     stream.listen(
  ///       (emr) => updateUI(emr),
  ///       onError: (error) => handleStreamError(error),
  ///     );
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, Stream<NutritionEMREntity>>> watchEMR(
    String emrId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: watchEMR | Status: started',
        );
        debugPrint('[NutritionEMRRepo] EMR ID: $emrId');
      }

      final stream = _collection.doc(emrId).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception('EMR not found');
        }
        return NutritionEMRModel.firestoreToEntity(
          snapshot.data()! as Map<String, dynamic>,
        );
      });

      if (kDebugMode) {
        debugPrint(
          '[NutritionEMRRepo] Operation: watchEMR | Status: success',
        );
      }

      return Right(stream);
    } on firebase_core.FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: watchEMR | Status: error');
        debugPrint(
          '[NutritionEMRRepo] FirebaseException: ${e.code} - ${e.message}',
        );
      }
      return Left(
        Failure.firestore('Firebase error: ${e.code} - ${e.message}'),
      );
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[NutritionEMRRepo] Operation: watchEMR | Status: error');
        debugPrint('[NutritionEMRRepo] Exception: $e');
        debugPrint('[NutritionEMRRepo] StackTrace: $stackTrace');
      }
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
