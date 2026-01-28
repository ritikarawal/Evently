import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "10.1.6.170";

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

  // Get full URL for uploaded images
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    // Remove leading slash if present
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/$cleanPath';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/$cleanPath';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/$cleanPath';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/$cleanPath';
    } else {
      return 'http://localhost:5050/$cleanPath';
    }
  }

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userById = 'auth/user/';
  static const String userByEmail = 'auth/user/email/';
  static const String updateProfilePicture = 'auth/user/profile-picture';
}
