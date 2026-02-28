class UpdateProfileParams {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      if (password != null && password!.isNotEmpty) 'password': password,
    };
  }
}
