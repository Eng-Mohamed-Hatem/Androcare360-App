import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:elajtech/core/constants/app_constants.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:injectable/injectable.dart';

/// Notification Repository implementation for the AndroCare360 system.
///
/// This repository implements the [NotificationRepository] interface and handles
/// all Firestore operations for user notifications management.
///
/// **CRITICAL DATABASE RULES:**
/// - Must use `databaseId: 'elajtech'` for ALL Firestore operations
/// - Never use FirebaseFirestore.instance directly
/// - Collection name: Defined in AppConstants.collections.notifications
/// - All operations include comprehensive error handling
/// - Notifications ordered by createdAt descending (newest first)
///
/// **Dependency Injection:**
/// Registered as @LazySingleton with injectable package. Access via:
/// ```dart
/// final repository = getIt<NotificationRepository>();
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
/// - Real-time Streaming: Watch user notifications with Firestore snapshots
/// - Batch Operations: Mark all notifications as read in single transaction
/// - Ordered Results: All queries return newest notifications first
///
/// **Usage Example:**
/// ```dart
/// final repository = getIt<NotificationRepository>();
///
/// // Save notification
/// final notification = NotificationModel(
///   id: 'notif_123',
///   userId: 'user_456',
///   title: 'Appointment Reminder',
///   body: 'Your appointment is tomorrow',
///   // ... other fields
/// );
///
/// final result = await repository.saveNotification(notification);
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('Notification saved'),
/// );
///
/// // Watch notifications stream
/// repository.getNotificationsStream('user_456').listen(
///   (notifications) => updateNotificationList(notifications),
/// );
/// ```
@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  /// Constructor with dependency injection.
  ///
  /// The [_firestore] instance is injected by GetIt and configured with
  /// `databaseId: 'elajtech'` in firebase_module.dart.
  ///
  /// Parameters:
  /// - _firestore: Configured FirebaseFirestore instance (injected)
  NotificationRepositoryImpl(this._firestore);
  final FirebaseFirestore _firestore;

  /// Save a notification to Firestore.
  ///
  /// Persists a notification document to the notifications collection.
  ///
  /// Parameters:
  /// - notification: NotificationModel to save (required)
  ///
  /// Returns:
  /// - Right(Unit): Notification saved successfully
  /// - Left(ServerFailure): Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final notification = NotificationModel(
  ///   id: 'notif_123',
  ///   userId: 'user_456',
  ///   title: 'New Message',
  ///   body: 'You have a new message',
  ///   isRead: false,
  ///   createdAt: DateTime.now(),
  /// );
  ///
  /// final result = await repository.saveNotification(notification);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => showSuccess('Notification sent'),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> saveNotification(
    NotificationModel notification,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.collections.notifications)
          .doc(notification.id)
          .set(notification.toJson());
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Retrieve all notifications for a specific user.
  ///
  /// Queries the notifications collection for all notifications belonging to
  /// the specified user, ordered by creation date (newest first).
  ///
  /// Parameters:
  /// - userId: Unique user identifier (required)
  ///
  /// Returns:
  /// - `Right(List<NotificationModel>)`: List of notifications (may be empty)
  /// - `Left(ServerFailure)`: Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getNotificationsForUser('user_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (notifications) => displayNotifications(notifications),
  /// );
  /// ```
  @override
  Future<Either<Failure, List<NotificationModel>>> getNotificationsForUser(
    String userId,
  ) async {
    try {
      final query = await _firestore
          .collection(AppConstants.collections.notifications)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = query.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();

      return Right(notifications);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Watch real-time changes to user notifications.
  ///
  /// Creates a Firestore snapshot stream that emits updates whenever
  /// notifications are added, modified, or removed for the user.
  ///
  /// Parameters:
  /// - userId: Unique user identifier (required)
  ///
  /// Returns:
  /// - `Stream<List<NotificationModel>>`: Real-time notifications stream
  ///
  /// Example:
  /// ```dart
  /// repository.getNotificationsStream('user_456').listen(
  ///   (notifications) => updateNotificationBadge(notifications.length),
  /// );
  /// ```
  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) =>
      _firestore
          .collection(AppConstants.collections.notifications)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => NotificationModel.fromJson(doc.data()))
                .toList(),
          );

  /// Mark all unread notifications as read for a user.
  ///
  /// Uses a Firestore batch operation to update all unread notifications
  /// (isRead = false) to read status (isRead = true) in a single transaction.
  ///
  /// **Batch Operation:**
  /// - Queries all unread notifications for user
  /// - Updates all in single batch commit
  /// - Returns immediately if no unread notifications
  ///
  /// Parameters:
  /// - userId: Unique user identifier (required)
  ///
  /// Returns:
  /// - Right(Unit): All notifications marked as read successfully
  /// - Left(ServerFailure): Firestore operation failed
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.markAllNotificationsAsRead('user_456');
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (_) => clearNotificationBadge(),
  /// );
  /// ```
  @override
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(
    String userId,
  ) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection(AppConstants.collections.notifications)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (notifications.docs.isEmpty) return const Right(unit);

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
