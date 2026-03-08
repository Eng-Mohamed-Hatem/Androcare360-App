import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/user/domain/repositories/user_repository.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// User Repository implementation for the AndroCare360 system.
///
/// This repository implements the [UserRepository] interface and handles
/// all Firestore operations for user profile management including retrieval
/// and querying of user data.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: 'users' (from AppConstants.collections.users)
/// - All operations include comprehensive error handling
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final userRepository = getIt<UserRepository>();
/// ```
///
/// **Error Handling:**
/// All methods return `Either<Failure, T>` from dartz package:
/// - Left(ServerFailure): Operation failed with error message
/// - Right(T): Operation succeeded with result
///
/// **Failure Types:**
/// - ServerFailure: Database operation errors, user not found, network issues
///
/// **Usage Example:**
/// ```dart
/// final result = await userRepository.getUser('user_123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => displayUserProfile(user),
/// );
/// ```
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  /// Creates a UserRepositoryImpl instance with injected Firestore.
  ///
  /// The [_firestore] instance is configured with databaseId: 'elajtech'
  /// in firebase_module.dart and injected by GetIt.
  UserRepositoryImpl(this._firestore);

  /// Firestore instance configured for 'elajtech' database
  final FirebaseFirestore _firestore;

  /// Returns a reference to the users collection in Firestore.
  ///
  /// This getter provides a typed collection reference for all user operations.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConstants.collections.users);

  /// Retrieves a user's profile data by user ID.
  ///
  /// This method fetches a complete user profile from Firestore using the
  /// user's unique identifier. It validates that the document exists and
  /// contains data before parsing.
  ///
  /// Parameters:
  /// - [userId]: Unique identifier of the user (required)
  ///
  /// Returns:
  /// - Right(UserModel): User profile data
  /// - Left(ServerFailure): User not found or query failed
  ///
  /// Possible Failures:
  /// - 'المستخدم غير موجود': User document doesn't exist
  /// - Generic error message: Other database or network errors
  ///
  /// Example:
  /// ```dart
  /// final result = await userRepository.getUser('user_123');
  /// result.fold(
  ///   (failure) => showError('لم يتم العثور على المستخدم'),
  ///   (user) {
  ///     print('User: ${user.fullName}');
  ///     print('Type: ${user.userType}');
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, UserModel>> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return Right(UserModel.fromJson(doc.data()!));
      }
      return const Left(ServerFailure('المستخدم غير موجود'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieves all patient users from the system.
  ///
  /// This method queries Firestore for all users with userType = 'patient'.
  /// Useful for admin dashboards, patient lists, and reporting.
  ///
  /// **Query Details:**
  /// - Filters by userType field
  /// - Returns all matching documents
  /// - No ordering applied
  ///
  /// Returns:
  /// - Right(List<UserModel>): List of all patient users
  /// - Left(ServerFailure): Query failed
  ///
  /// **Note:** This query may return a large dataset. Consider implementing
  /// pagination for production use with many patients.
  ///
  /// Example:
  /// ```dart
  /// final result = await userRepository.getAllPatients();
  /// result.fold(
  ///   (failure) => showError('فشل تحميل قائمة المرضى'),
  ///   (patients) {
  ///     print('Total patients: ${patients.length}');
  ///     displayPatientList(patients);
  ///   },
  /// );
  /// ```
  @override
  Future<Either<Failure, List<UserModel>>> getAllPatients() async {
    try {
      final query = await _usersCollection
          .where('userType', isEqualTo: 'patient')
          .get();

      final patients = query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
      return Right(patients);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
