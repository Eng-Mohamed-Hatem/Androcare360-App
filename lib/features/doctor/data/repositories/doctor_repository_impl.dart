import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// Doctor Repository implementation for the AndroCare360 system.
///
/// This repository implements the [DoctorRepository] interface and handles
/// all Firestore operations for doctor profile management and queries.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.users
/// - All operations include comprehensive error handling
/// - Filters by userType = 'doctor' for all queries
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<DoctorRepository>();
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
/// **Special Features:**
/// - Real-time Streaming: Watch doctor list changes with Firestore snapshots
/// - Error Resilience: Stream parsing errors are caught and skipped
/// - User Type Filtering: All queries filter by userType = 'doctor'
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<DoctorRepository>();
///
/// // Get all doctors
/// final result = await repository.getDoctors();
/// result.fold(
///   (failure) => showError(failure.message),
///   (doctors) => displayDoctorList(doctors),
/// );
///
/// // Get doctor by ID
/// final doctorResult = await repository.getDoctorById('doctor_123');
/// doctorResult.fold(
///   (failure) => handleError(failure),
///   (doctor) => displayDoctorProfile(doctor),
/// );
///
/// // Watch doctors stream
/// repository.getDoctorsStream().listen(
///   (doctors) => updateDoctorList(doctors),
/// );
/// ```
@LazySingleton(as: DoctorRepository)
class DoctorRepositoryImpl implements DoctorRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  DoctorRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Retrieve all doctors from the system.
  ///
  /// Queries the users collection for all documents with userType = 'doctor'.
  /// Returns a list of doctor profiles as UserModel instances.
  ///
  /// **Query Strategy:**
  /// - Uses Firestore where clause on 'userType' field
  /// - Returns all matching documents
  /// - Empty list if no doctors found
  ///
  /// Parameters: None
  ///
  /// Returns:
  /// - Right(List<UserModel>): List of doctor profiles (may be empty)
  /// - Left(ServerFailure): Firestore operation failed
  ///
  /// Possible Failures:
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Query or parsing exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getDoctors();
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (doctors) {
  ///     if (doctors.isEmpty) {
  ///       showMessage('No doctors available');
  ///     } else {
  ///       displayDoctorList(doctors); // Shows ${doctors.length} doctors
  ///     }
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, List<UserModel>>> getDoctors() async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.users)
          .where('userType', isEqualTo: 'doctor')
          .get();

      final doctors = query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      return Right(doctors);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Watch real-time changes to the doctors list.
  ///
  /// Creates a Firestore snapshot stream that emits updates whenever doctors
  /// are added, modified, or removed from the system.
  ///
  /// **Stream Behavior:**
  /// - Emits initial list immediately
  /// - Emits new list on every change to doctors collection
  /// - Filters by userType = 'doctor'
  /// - Parsing errors are caught and skipped (null entries removed)
  /// - Stream continues until cancelled by caller
  ///
  /// **Error Resilience:**
  /// - Individual document parsing errors are caught
  /// - Failed documents are skipped (returned as null, then filtered out)
  /// - Stream continues even if some documents fail to parse
  ///
  /// Parameters: None
  ///
  /// Returns:
  /// - Stream<List<UserModel>>: Real-time doctor list stream
  ///
  /// Example:
  /// ```dart
  /// final stream = repository.getDoctorsStream();
  /// stream.listen(
  ///   (doctors) => updateDoctorList(doctors),
  ///   onError: (error) => handleStreamError(error),
  /// );
  /// ```
  @override
  Stream<List<UserModel>> getDoctorsStream() => _firestore
      .collection(AppConstants.collections.users)
      .where('userType', isEqualTo: 'doctor')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) {
              try {
                return UserModel.fromJson(doc.data());
              } on Exception catch (_) {
                return null;
              }
            })
            .where((user) => user != null)
            .cast<UserModel>()
            .toList(),
      );

  /// Retrieve a specific doctor by ID.
  ///
  /// Queries the users collection for a doctor document with the specified ID.
  /// Returns the doctor profile if found and userType is 'doctor'.
  ///
  /// **Query Strategy:**
  /// - Direct document lookup by ID
  /// - Validates document exists and has data
  /// - Returns failure if doctor not found
  ///
  /// Parameters:
  /// - id: Unique doctor identifier (required)
  ///
  /// Returns:
  /// - Right(UserModel): Doctor profile found and parsed successfully
  /// - Left(ServerFailure): Doctor not found or operation failed
  ///   - 'Doctor not found': Document doesn't exist or has no data
  ///   - '[Exception details]': Firestore or parsing exception
  ///
  /// Possible Failures:
  /// - 'Doctor not found': Document doesn't exist in Firestore
  /// - 'Firebase error: permission-denied': Insufficient Firestore permissions
  /// - 'Firebase error: unavailable': Network connectivity issue
  /// - 'Unexpected error: [details]': Parsing or runtime exception
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getDoctorById('doctor_123');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (doctor) {
  ///     displayDoctorProfile(doctor);
  ///     print('Doctor: ${doctor.fullName}');
  ///     print('Specialization: ${doctor.specializations.first}');
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, UserModel>> getDoctorById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collections.users)
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return Right(UserModel.fromJson(doc.data()!));
      } else {
        return const Left(ServerFailure('Doctor not found'));
      }
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
