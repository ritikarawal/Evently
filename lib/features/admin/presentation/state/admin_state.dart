import 'package:equatable/equatable.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_message_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_event_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';
import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';

enum AdminSection { dashboard, users, events, venues, chats }

class AdminState extends Equatable {
  final AdminSection section;
  final bool isLoading;
  final String? errorMessage;
  final List<AdminUserEntity> users;
  final List<AdminEventEntity> events;
  final List<AdminVenueEntity> venues;
  final List<AdminChatUserEntity> chatUsers;
  final List<AdminChatMessageEntity> chatMessages;
  final String? selectedChatUserId;

  const AdminState({
    this.section = AdminSection.dashboard,
    this.isLoading = false,
    this.errorMessage,
    this.users = const [],
    this.events = const [],
    this.venues = const [],
    this.chatUsers = const [],
    this.chatMessages = const [],
    this.selectedChatUserId,
  });

  AdminState copyWith({
    AdminSection? section,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<AdminUserEntity>? users,
    List<AdminEventEntity>? events,
    List<AdminVenueEntity>? venues,
    List<AdminChatUserEntity>? chatUsers,
    List<AdminChatMessageEntity>? chatMessages,
    String? selectedChatUserId,
    bool clearSelectedChatUser = false,
  }) {
    return AdminState(
      section: section ?? this.section,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      users: users ?? this.users,
      events: events ?? this.events,
      venues: venues ?? this.venues,
      chatUsers: chatUsers ?? this.chatUsers,
      chatMessages: chatMessages ?? this.chatMessages,
      selectedChatUserId: clearSelectedChatUser
          ? null
          : (selectedChatUserId ?? this.selectedChatUserId),
    );
  }

  @override
  List<Object?> get props => [
    section,
    isLoading,
    errorMessage,
    users,
    events,
    venues,
    chatUsers,
    chatMessages,
    selectedChatUserId,
  ];
}
