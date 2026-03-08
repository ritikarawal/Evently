import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';
import 'package:event_planner/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetChatHistoryUsecase {
  final ChatRepository _repository;

  GetChatHistoryUsecase(this._repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call() {
    return _repository.getChatHistory();
  }
}

final getChatHistoryUsecaseProvider = Provider<GetChatHistoryUsecase>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return GetChatHistoryUsecase(repo);
});
