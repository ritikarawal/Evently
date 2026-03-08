import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // 🔧 YOUR PC'S WIFI IP ADDRESS (from ipconfig - WiFi adapter)
  // Change this if your IP changes
  static const String backendHost = "10.1.6.169";
  static const int backendPort = 5050;

  static String get baseUrl {
    // Same backend for ALL platforms (web and mobile)
    if (kIsWeb) {
      // Web: Use localhost when running on same machine
      return 'http://localhost:$backendPort/api/';
    } else if (Platform.isAndroid) {
      // Android: Use localhost with ADB port forwarding
      // Run: adb reverse tcp:5050 tcp:5050
      return 'http://localhost:$backendPort/api/';
    } else if (Platform.isIOS) {
      // iOS physical device: Use PC's WiFi IP
      return 'http://$backendHost:$backendPort/api/';
    } else {
      // Desktop (Windows/Mac/Linux): Use localhost
      return 'http://localhost:$backendPort/api/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Get full URL for uploaded images
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    // Remove leading slash if present
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    // Use same base URL logic for images
    if (kIsWeb) {
      return 'http://localhost:$backendPort/$cleanPath';
    } else if (Platform.isAndroid) {
      // Android with ADB port forwarding
      return 'http://localhost:$backendPort/$cleanPath';
    } else {
      return 'http://$backendHost:$backendPort/$cleanPath';
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
