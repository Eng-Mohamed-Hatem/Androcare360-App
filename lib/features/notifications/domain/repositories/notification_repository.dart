import 'package:dartz/dartz.dart';
import 'package:elajtech/core/error/failures.dart';
import 'package:elajtech/shared/models/notification_model.dart';

/// Notification Repository Interface
abstract class NotificationRepository {
  /// Save Notification
  Future<Either<Failure, Unit>> saveNotification(
    NotificationModel notification,
  );

  /// Get Notifications for User
  Future<Either<Failure, List<NotificationModel>>> getNotificationsForUser(
    String userId,
  );

  /// Get Notifications Stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId);

  /// Mark all notifications as read
  Future<Either<Failure, Unit>> markAllNotificationsAsRead(String userId);
}
