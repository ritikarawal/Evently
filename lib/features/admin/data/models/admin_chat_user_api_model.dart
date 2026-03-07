import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';

class AdminChatUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profilePicture;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const AdminChatUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.profilePicture,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory AdminChatUserApiModel.fromJson(Map<String, dynamic> json) {
    return AdminChatUserApiModel(
      id: (json['_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePicture: json['profilePicture']?.toString(),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      lastMessageTime: DateTime.tryParse(
        (json['lastMessageTime'] ?? '').toString(),
      ),
      unreadCount: int.tryParse((json['unreadCount'] ?? 0).toString()) ?? 0,
    );
  }

  AdminChatUserEntity toEntity() {
    return AdminChatUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profilePicture: profilePicture,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
    );
  }
}
