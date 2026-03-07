import 'package:equatable/equatable.dart';

class AdminChatUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profilePicture;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const AdminChatUserEntity({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.email = '',
    this.profilePicture,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    profilePicture,
    lastMessage,
    lastMessageTime,
    unreadCount,
  ];
}
