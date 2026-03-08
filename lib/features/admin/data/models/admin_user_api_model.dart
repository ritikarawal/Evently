import 'package:event_planner/features/admin/domain/entities/admin_user_entity.dart';

class AdminUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profilePicture;

  const AdminUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePicture,
  });

  factory AdminUserApiModel.fromJson(Map<String, dynamic> json) {
    return AdminUserApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  AdminUserEntity toEntity() {
    return AdminUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      profilePicture: profilePicture,
    );
  }
}
