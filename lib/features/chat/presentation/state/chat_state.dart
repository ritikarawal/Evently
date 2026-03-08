import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';

class ChatState {
  final bool isLoading;
  final bool isSending;
  final List<ChatMessageEntity> messages;
  final int unreadCount;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.messages = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    List<ChatMessageEntity>? messages,
    int? unreadCount,
    String? errorMessage,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }
}
