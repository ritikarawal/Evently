import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? confirmPassword;
  final String? token;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.username,
    this.phoneNumber,
    this.password,
    this.confirmPassword,
    this.token,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['_id'] ?? json['id']) as String?,
      fullName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim(),
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final nameParts = fullName.trim().split(' ');
    // Ensure we have at least first and last name
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : 'LastName';

    return {
      'firstName': firstName,
      'lastName': lastName.isNotEmpty ? lastName : 'LastName',
      'email': email,
      'username': username ?? email.split('@')[0],
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword ?? password,
    };
  }

  AuthEntity toEntity() => AuthEntity(
    authId: id,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    username: username ?? email.split('@')[0],
    password: password,
  );
}
