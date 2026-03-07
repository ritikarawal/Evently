import 'package:event_planner/features/admin/domain/entities/admin_chat_message_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';
import 'package:event_planner/features/admin/domain/usecases/admin_usecases.dart';
import 'package:event_planner/features/admin/presentation/state/admin_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminViewModel extends Notifier<AdminState> {
  late final GetAdminUsersUseCase _getAdminUsers;
  late final CreateAdminUserUseCase _createAdminUser;
  late final UpdateAdminUserUseCase _updateAdminUser;
  late final DeleteAdminUserUseCase _deleteAdminUser;
  late final GetAdminEventsUseCase _getAdminEvents;
  late final ApproveAdminEventUseCase _approveAdminEvent;
  late final DeclineAdminEventUseCase _declineAdminEvent;
  late final DeleteAdminEventUseCase _deleteAdminEvent;
  late final GetAdminVenuesUseCase _getAdminVenues;
  late final CreateAdminVenueUseCase _createAdminVenue;
  late final GetAdminChatUsersUseCase _getAdminChatUsers;
  late final GetAdminUserChatUseCase _getAdminUserChat;
  late final SendAdminMessageUseCase _sendAdminMessage;

  @override
  AdminState build() {
    _getAdminUsers = ref.read(getAdminUsersUseCaseProvider);
    _createAdminUser = ref.read(createAdminUserUseCaseProvider);
    _updateAdminUser = ref.read(updateAdminUserUseCaseProvider);
    _deleteAdminUser = ref.read(deleteAdminUserUseCaseProvider);
    _getAdminEvents = ref.read(getAdminEventsUseCaseProvider);
    _approveAdminEvent = ref.read(approveAdminEventUseCaseProvider);
    _declineAdminEvent = ref.read(declineAdminEventUseCaseProvider);
    _deleteAdminEvent = ref.read(deleteAdminEventUseCaseProvider);
    _getAdminVenues = ref.read(getAdminVenuesUseCaseProvider);
    _createAdminVenue = ref.read(createAdminVenueUseCaseProvider);
    _getAdminChatUsers = ref.read(getAdminChatUsersUseCaseProvider);
    _getAdminUserChat = ref.read(getAdminUserChatUseCaseProvider);
    _sendAdminMessage = ref.read(sendAdminMessageUseCaseProvider);
    return const AdminState();
  }

  void setSection(AdminSection section) {
    state = state.copyWith(section: section, clearError: true);

    if (section == AdminSection.users) {
      loadUsers();
    } else if (section == AdminSection.events) {
      loadEvents();
    } else if (section == AdminSection.venues) {
      loadVenues();
    } else if (section == AdminSection.chats) {
      loadChatUsers();
    }
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAdminUsers(page: 1, limit: 50);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (users) => state = state.copyWith(
        isLoading: false,
        users: users,
        clearError: true,
      ),
    );
  }

  Future<void> createUser({
    required AdminUserEntity user,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _createAdminUser(user: user, password: password);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadUsers();
      },
    );
  }

  Future<void> updateUser(AdminUserEntity user) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _updateAdminUser(user);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadUsers();
      },
    );
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _deleteAdminUser(userId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadUsers();
      },
    );
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAdminEvents();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (events) => state = state.copyWith(
        isLoading: false,
        events: events,
        clearError: true,
      ),
    );
  }

  Future<void> approveEvent(String eventId, {String? adminNotes}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _approveAdminEvent(eventId, adminNotes: adminNotes);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadEvents();
      },
    );
  }

  Future<void> declineEvent(String eventId, {String? adminNotes}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _declineAdminEvent(eventId, adminNotes: adminNotes);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadEvents();
      },
    );
  }

  Future<void> deleteEvent(String eventId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _deleteAdminEvent(eventId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadEvents();
      },
    );
  }

  Future<void> loadVenues() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAdminVenues();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (venues) => state = state.copyWith(
        isLoading: false,
        venues: venues,
        clearError: true,
      ),
    );
  }

  Future<void> createVenue(AdminVenueEntity venue) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _createAdminVenue(venue);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(isLoading: false, clearError: true);
        await loadVenues();
      },
    );
  }

  Future<void> loadChatUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAdminChatUsers();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (users) {
        String? selectedUserId = state.selectedChatUserId;
        if (selectedUserId == null && users.isNotEmpty) {
          selectedUserId = users.first.id;
        }

        state = state.copyWith(
          isLoading: false,
          chatUsers: users,
          selectedChatUserId: selectedUserId,
          clearError: true,
        );

        if (selectedUserId != null) {
          loadUserChat(selectedUserId);
        }
      },
    );
  }

  Future<void> selectChatUser(AdminChatUserEntity user) async {
    state = state.copyWith(
      selectedChatUserId: user.id,
      chatMessages: const [],
      clearError: true,
    );
    await loadUserChat(user.id);
  }

  Future<void> loadUserChat(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAdminUserChat(userId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (messages) => state = state.copyWith(
        isLoading: false,
        chatMessages: messages,
        selectedChatUserId: userId,
        clearError: true,
      ),
    );
  }

  Future<void> sendMessage({
    required String userId,
    required String text,
    String? adminName,
  }) async {
    if (text.trim().isEmpty) return;

    final result = await _sendAdminMessage(
      userId: userId,
      text: text.trim(),
      adminName: adminName,
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (message) {
        final updatedMessages = <AdminChatMessageEntity>[
          ...state.chatMessages,
          message,
        ].whereType<AdminChatMessageEntity>().toList();
        state = state.copyWith(chatMessages: updatedMessages, clearError: true);
      },
    );

    await loadChatUsers();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final adminViewModelProvider = NotifierProvider<AdminViewModel, AdminState>(
  AdminViewModel.new,
);
