import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/core/models/paginated_result.dart';
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart';
import 'package:elajtech/shared/models/device_request_model.dart';
import 'package:injectable/injectable.dart';

/// Device Request Repository implementation for the AndroCare360 system.
///
/// This repository implements the [DeviceRequestRepository] interface and handles
/// all Firestore operations for medical device requests management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.deviceRequests
/// - All operations include comprehensive error handling
/// - appointmentId is required for all save operations
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<DeviceRequestRepository>();
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
/// - 24-Hour Window: Device requests can only be added/edited within 24 hours of appointment
/// - Multiple Query Options: By patient or appointment
/// - Device Tracking: Track medical device requests and delivery status
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<DeviceRequestRepository>();
///
/// // Save device request
/// final request = DeviceRequestModel(
///   id: 'dev_123',
///   appointmentId: 'apt_456',
///   patientId: 'patient_789',
///   deviceType: 'Blood Pressure Monitor',
///   quantity: 1,
///   // ... other fields
/// );
///
/// final result = await repository.saveDeviceRequest(request);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('طلب جهاز طبي محفوظ'),
/// );
/// ```
@LazySingleton(as: DeviceRequestRepository)
class DeviceRequestRepositoryImpl implements DeviceRequestRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  DeviceRequestRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get Firestore collection reference for device requests.
  ///
  /// Returns a collection reference to device requests in the 'elajtech' database.
  ///
  /// Returns:
  /// - CollectionReference: Reference to device requests collection
  CollectionReference<Map<String, dynamic>> get _deviceRequestsCollection =>
      _firestore.collection(AppConstants.collections.deviceRequests);

  /// Save or update a device request.
  ///
  /// Persists a device request to Firestore with validation and 24-hour window enforcement.
  ///
  /// **Validation:**
  /// - appointmentId must not be empty
  /// - Firestore security rules enforce 24-hour edit window
  ///
  /// Parameters:
  /// - request: DeviceRequestModel to save (required)
  ///
  /// Returns:
  /// - Right(void): Device request saved successfully
  /// - Left(ServerFailure): Operation failed
  ///
  /// Example:
  /// ```dart
  /// final request = DeviceRequestModel(
  ///   id: 'dev_123',
  ///   appointmentId: 'apt_456',
  ///   patientId: 'patient_789',
  ///   deviceType: 'Glucose Meter',
  ///   quantity: 1,
  ///   urgency: 'Standard',
  /// );
  ///
  /// final result = await repository.saveDeviceRequest(request);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Device request saved'),
  /// );
  /// ```
  @override
  Future<Either<Failure, void>> saveDeviceRequest(
    DeviceRequestModel request,
  ) async {
    try {
      // ✅ التحقق من أن appointmentId غير فارغ
      if (request.appointmentId.isEmpty) {
        return const Left(
          ServerFailure('appointmentId مطلوب لحفظ طلب الجهاز الطبي'),
        );
      }

      await _deviceRequestsCollection.doc(request.id).set(request.toJson());
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

  /// Retrieve all device requests for a specific patient.
  ///
  /// Queries device requests collection for all requests belonging to
  /// the specified patient, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - patientId: Unique patient identifier (required)
  ///
  /// Returns:
  /// - `Right(List<DeviceRequestModel>)`: List of device requests (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getDeviceRequestsForPatient('patient_789');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayDeviceRequestHistory(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<DeviceRequestModel>>> getDeviceRequestsForPatient(
    String patientId,
  ) async {
    try {
      final query = await _deviceRequestsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = query.docs
          .map((doc) => DeviceRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceRequestModel>>>
  getDeviceRequestsForPatientPage(
    String patientId, {
    int limit = 10,
  }) async {
    try {
      final query = await _deviceRequestsCollection
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1)
          .get();

      final hasMore = query.docs.length > limit;
      final requests = query.docs
          .take(limit)
          .map((doc) => DeviceRequestModel.fromJson(doc.data()))
          .toList();
      return Right(PaginatedResult(items: requests, hasMore: hasMore));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all device requests for a specific appointment.
  ///
  /// Queries device requests collection for all requests associated with
  /// the specified appointment.
  ///
  /// Parameters:
  /// - appointmentId: Unique appointment identifier (required)
  ///
  /// Returns:
  /// - `Right(List<DeviceRequestModel>)`: List of device requests (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getDeviceRequestsByAppointmentId('apt_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (requests) => displayAppointmentDeviceRequests(requests),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<DeviceRequestModel>>>
  getDeviceRequestsByAppointmentId(String appointmentId) async {
    try {
      final query = await _deviceRequestsCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();
      final requests = query.docs
          .map((doc) => DeviceRequestModel.fromJson(doc.data()))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
