import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:event_planner/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetChatUnreadCountUsecase {
  final ChatRepository _repository;

  GetChatUnreadCountUsecase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getUnreadCount();
  }
}

final getChatUnreadCountUsecaseProvider = Provider<GetChatUnreadCountUsecase>((
  ref,
) {
  final repo = ref.read(chatRepositoryProvider);
  return GetChatUnreadCountUsecase(repo);
});
