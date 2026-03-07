import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';
import 'package:event_planner/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetNotificationsUsecase {
  final NotificationRepository _repository;

  GetNotificationsUsecase(this._repository);

  Future<Either<Failure, List<NotificationEntity>>> call({int limit = 50}) {
    return _repository.getNotifications(limit: limit);
  }
}

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((
  ref,
) {
  final repo = ref.read(notificationRepositoryProvider);
  return GetNotificationsUsecase(repo);
});
