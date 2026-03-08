/// Failure types for the AndroCare360 application.
///
/// This file defines Freezed-based failure types that are returned from
/// repository methods using the `Either<Failure, T>` pattern. Failures represent
/// domain-level errors that can be handled by the presentation layer.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base class for all failure types in the application.
///
/// Failures are used in the repository layer to represent errors in a
/// type-safe manner. They are returned as the Left side of `Either<Failure, T>`.
///
/// **Usage Example:**
/// ```dart
/// Future<Either<Failure, UserModel>> getUser(String userId) async {
///   try {
///     final doc = await firestore.collection('users').doc(userId).get();
///     return Right(UserModel.fromFirestore(doc));
///   } on firebase_core.FirebaseException catch (e) {
///     return Left(Failure.firestore(e.message ?? 'Failed to fetch user'));
///   } on SocketException catch (e) {
///     return Left(Failure.network('No internet connection'));
///   } catch (e) {
///     return Left(Failure.unexpected('An unexpected error occurred'));
///   }
/// }
/// ```
///
/// **Handling Failures in UI:**
/// ```dart
/// final result = await ref.read(userRepositoryProvider).getUser(userId);
/// result.fold(
///   (failure) => failure.when(
///     firestore: (msg) => showError('Database error: $msg'),
///     network: (msg) => showError('Network error: $msg'),
///     agora: (msg) => showError('Video call error: $msg'),
///     voip: (msg) => showError('Call error: $msg'),
///     app: (msg) => showError(msg),
///     unexpected: (msg) => showError('Something went wrong'),
///   ),
///   (user) => displayUser(user),
/// );
/// ```
@freezed
sealed class Failure with _$Failure {
  /// Firestore operation failure.
  ///
  /// Used when Firebase Firestore operations fail, including:
  /// - Document read/write errors
  /// - Query execution failures
  /// - Permission denied errors
  /// - Collection access issues
  const factory Failure.firestore(String message) = FirestoreFailure;

  /// Network connectivity failure.
  ///
  /// Used when network-related operations fail, including:
  /// - No internet connection
  /// - Connection timeouts
  /// - DNS resolution failures
  /// - Socket exceptions
  const factory Failure.network(String message) = NetworkFailure;

  /// Agora video call failure.
  ///
  /// Used when Agora RTC Engine operations fail, including:
  /// - Engine initialization errors
  /// - Channel join/leave failures
  /// - Token validation errors
  /// - Video/audio device issues
  const factory Failure.agora(String message) = AgoraFailure;

  /// VoIP call failure.
  ///
  /// Used when VoIP call operations fail, including:
  /// - Incoming call notification errors
  /// - Call acceptance/decline failures
  /// - CallKit/ConnectionService integration issues
  const factory Failure.voip(String message) = VoIPFailure;

  /// Application-level failure.
  ///
  /// Used for general application errors that don't fit into
  /// specific categories, including:
  /// - Validation errors
  /// - Business logic violations
  /// - Configuration issues
  const factory Failure.app(String message) = AppFailure;

  /// Unexpected failure.
  ///
  /// Used as a fallback for errors that don't match any specific
  /// category. This should be the last catch block in error handling.
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}
