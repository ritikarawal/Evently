import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory();
  Future<Either<Failure, ChatMessageEntity>> sendUserMessage(String text);
}
