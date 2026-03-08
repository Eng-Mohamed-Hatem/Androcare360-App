import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart';
import 'package:elajtech/shared/models/radiology_request_model.dart';
import 'package:injectable/injectable.dart';

/// Radiology Request Repository implementation for the AndroCare360 system.
///
/// This repository implements the [RadiologyRequestRepository] interface and handles
/// all Firestore operations for radiology/imaging requests management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.radiologyRequests
/// - All operations include comprehensive error handling
/// - appointmentId is required for all save operations
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<RadiologyRequestRepository>();
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
/// - 24-Hour Window: Radiology requests can only be added/edited within 24 hours of appointment
/// - Multiple Query Options: By patient or appointment
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<RadiologyRequestRepository>();
///
/// // Save radiology request
/// final request = RadiologyRequestModel(
///   id: 'rad_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   imagingType: 'X-Ray',
///   bodyPart: 'Chest',
///   // ... other fields
/// );
///
/// final result = await repository.saveRadiologyRequest(request);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('طلب أشعة محفوظ'),
/// );
/// ```
@LazySingleton(as: RadiologyRequestRepository)
class RadiologyRequestRepositoryImpl implements RadiologyRequestRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  RadiologyRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get Firestore collection reference for radiology requests.
  ///
  /// Returns a collection reference to radiology requests in the 'elajtech' database.
  ///
  /// Returns:
  /// - CollectionReference: Reference to radiology requests collection
  CollectionReference<Map<String, dynamic>> get _radiologyRequestsCollection =>
      _firestore.collection(AppConstants.collections.radiologyRequests);

  /// Save or update a radiology request.
  ///
  /// Persists a radiology request to Firestore with validation and 24-hour window enforcement.
  ///
  /// **Validation:**
  /// - appointmentId must not be empty
  /// - Firestore security rules enforce 24-hour edit window
  ///
  /// Parameters:
  /// - request: RadiologyRequestModel to save (required)
  ///
  /// Returns:
  /// - Right(void): Radiology request saved successfully
  /// - Left(ServerFailure): Operation failed
  ///
  /// Example:
  /// ```dart
  /// final request = RadiologyRequestModel(
  ///   id: 'rad_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   imagingType: 'CT Scan',
  ///   bodyPart: 'Abdomen',
  ///   urgency: 'Routine',
  /// );
  ///
  /// final result = await repository.saveRadiologyRequest(request);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Radiology request saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveRadiologyRequest(
    RadiologyRequestModel request,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId غير فارغ
      if (request.appointmentId.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الأشعة'),
        );
      }

      await _radiologyRequestsCollection.doc(request.id).set(request.toJson());
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

  /// Retrieve all radiology requests for a specific patient.
  ///
  /// Queries radiology requests collection for all requests belonging to
  /// the specified patient, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - Right(List<RadiologyRequestModel>): List of radiology requests (may be empty)
  /// - Left(ServerFailure): Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getRadiologyRequestsForPatient('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayRadiologyRequestHistory(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsForPatient(String patientId) async {
    try {
      final query = await _radiologyRequestsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = query.docs
          .map((doc) => RadiologyRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all radiology requests for a specific appointment.
  ///
  /// Queries radiology requests collection for all requests associated with
  /// the specified appointment.
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - Right(List<RadiologyRequestModel>): List of radiology requests (may be empty)
  /// - Left(ServerFailure): Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getRadiologyRequestsByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayAppointmentRadiologyRequests(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<RadiologyRequestModel>>>
  getRadiologyRequestsByAppointmentId(String appointmentId) async {
    try {
      final query = await _radiologyRequestsCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();
      final requests = query.docs
          .map((doc) => RadiologyRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
