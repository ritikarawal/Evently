import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 50,
  });
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, bool>> markAsRead(String notificationId);
  Future<Either<Failure, bool>> markAllAsRead();
  Future<Either<Failure, bool>> deleteNotification(String notificationId);
}
