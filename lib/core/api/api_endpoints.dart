class ApiEndpoints {
  ApiEndpoints._();

  // static const String baseUrl = 'http://10.0.2.2:5050';
  static const String baseUrl = 'http://192.168.137.1:5050/api/';

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userById = 'auth/user/';
  static const String userByEmail = 'auth/user/email/';
}
