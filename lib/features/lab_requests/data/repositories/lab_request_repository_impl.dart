import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart';
import 'package:elajtech/shared/models/lab_request_model.dart';
import 'package:injectable/injectable.dart';

/// Lab Request Repository implementation for the AndroCare360 system.
///
/// This repository implements the [LabRequestRepository] interface and handles
/// all Firestore operations for laboratory test requests management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.labRequests
/// - All operations include comprehensive error handling
/// - appointmentId is required for all save operations
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<LabRequestRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(Failure): Operation failed with specific failure type
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - ServerFailure: Firestore operation errors or unexpected exceptions
///
/// **Security Rules:**
/// - appointmentId validation (must not be empty)
/// - 24-hour edit window enforcement via Firestore security rules
/// - permission-denied error triggers Arabic error message
///
/// **Special Features:**
/// - Bilingual Error Messages: Arabic messages for user-facing errors
/// - 24-Hour Window: Lab requests can only be added/edited within 24 hours of appointment
/// - Multiple Query Options: By patient or appointment
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<LabRequestRepository>();
///
/// // Save lab request
/// final request = LabRequestModel(
///   id: 'lab_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   tests: ['CBC', 'Lipid Profile'],
///   // ... other fields
/// );
///
/// final result = await repository.saveLabRequest(request);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('طلب فحص مخبري محفوظ'),
/// );
/// ```
@LazySingleton(as: LabRequestRepository)
class LabRequestRepositoryImpl implements LabRequestRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  LabRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get Firestore collection reference for lab requests.
  ///
  /// Returns a collection reference to lab requests in the 'elajtech' database.
  ///
  /// Returns:
  /// - CollectionReference: Reference to lab requests collection
  CollectionReference<Map<String, dynamic>> get _labRequestsCollection =>
      _firestore.collection(AppConstants.collections.labRequests);

  /// Save or update a lab request.
  ///
  /// Persists a lab request to Firestore with validation and 24-hour window enforcement.
  ///
  /// **Validation:**
  /// - appointmentId must not be empty
  /// - Firestore security rules enforce 24-hour edit window
  ///
  /// Parameters:
  /// - request: LabRequestModel to save (required)
  ///
  /// Returns:
  /// - Right(void): Lab request saved successfully
  /// - Left(ServerFailure): Operation failed
  ///
  /// Example:
  /// ```dart
  /// final request = LabRequestModel(
  ///   id: 'lab_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   tests: ['CBC', 'Lipid Profile', 'HbA1c'],
  /// );
  ///
  /// final result = await repository.saveLabRequest(request);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Lab request saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveLabRequest(LabRequestModel request) async {
    try {
      // ✅ التحقق من أن appointmentId غير فارغ
      if (request.appointmentId.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الفحص المخبري'),
        );
      }

      await _labRequestsCollection.doc(request.id).set(request.toJson());
      return const Right(null);
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

  /// Retrieve all lab requests for a specific patient.
  ///
  /// Queries lab requests collection for all requests belonging to
  /// the specified patient, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - `Right(List<LabRequestModel>)`: List of lab requests (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getLabRequestsForPatient('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayLabRequestHistory(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsForPatient(
    String patientId,
  ) async {
    try {
      final query = await _labRequestsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = query.docs
          .map((doc) => LabRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all lab requests for a specific appointment.
  ///
  /// Queries lab requests collection for all requests associated with
  /// the specified appointment.
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - `Right(List<LabRequestModel>)`: List of lab requests (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getLabRequestsByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayAppointmentLabRequests(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<LabRequestModel>>> getLabRequestsByAppointmentId(
    String appointmentId,
  ) async {
    try {
      final query = await _labRequestsCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();
      final requests = query.docs
          .map((doc) => LabRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
