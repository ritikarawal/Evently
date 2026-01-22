import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "172.25.6.219";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userById = 'auth/user/';
  static const String userByEmail = 'auth/user/email/';
}
