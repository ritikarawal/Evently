import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profilePicture;

  const AdminUserEntity({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.email = '',
    this.phoneNumber = '',
    this.role = 'user',
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    phoneNumber,
    role,
    profilePicture,
  ];
}
