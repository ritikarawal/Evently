import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:event_planner/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUnreadCountUsecase {
  final NotificationRepository _repository;

  GetUnreadCountUsecase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getUnreadCount();
  }
}

final getUnreadCountUsecaseProvider = Provider<GetUnreadCountUsecase>((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return GetUnreadCountUsecase(repo);
});
