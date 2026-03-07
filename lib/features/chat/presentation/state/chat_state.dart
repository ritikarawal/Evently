import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';

class ChatState {
  final bool isLoading;
  final bool isSending;
  final List<ChatMessageEntity> messages;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    List<ChatMessageEntity>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}
