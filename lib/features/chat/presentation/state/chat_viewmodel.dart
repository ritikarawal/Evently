import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';
import 'package:event_planner/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:event_planner/features/chat/domain/usecases/send_user_message_usecase.dart';
import 'package:event_planner/features/chat/presentation/state/chat_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  final GetChatHistoryUsecase _getChatHistory;
  final SendUserMessageUsecase _sendUserMessage;

  ChatViewModel(this._getChatHistory, this._sendUserMessage)
    : super(const ChatState());

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getChatHistory();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (messages) {
        final sorted = [...messages]
          ..sort(
            (a, b) => (a.timestamp ?? DateTime(0)).compareTo(
              b.timestamp ?? DateTime(0),
            ),
          );
        state = state.copyWith(
          isLoading: false,
          messages: sorted,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(isSending: true, errorMessage: null);

    final result = await _sendUserMessage(trimmed);
    result.fold(
      (failure) => state = state.copyWith(
        isSending: false,
        errorMessage: failure.message,
      ),
      (message) {
        final updated = List<ChatMessageEntity>.from(state.messages)
          ..add(message)
          ..sort(
            (a, b) => (a.timestamp ?? DateTime(0)).compareTo(
              b.timestamp ?? DateTime(0),
            ),
          );

        state = state.copyWith(isSending: false, messages: updated);
      },
    );
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  final getHistory = ref.read(getChatHistoryUsecaseProvider);
  final sendMessage = ref.read(sendUserMessageUsecaseProvider);
  return ChatViewModel(getHistory, sendMessage);
});
