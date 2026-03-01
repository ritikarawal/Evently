import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Optional full override:
  // flutter run --dart-define=API_BASE_URL=http://10.1.6.169:5050/api/
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Optional host override, useful for Android physical devices on LAN.
  // flutter run --dart-define=API_HOST=10.1.6.169
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  // Set true when using `adb reverse tcp:5050 tcp:5050` on Android.
  static const bool useAdbReverse = bool.fromEnvironment(
    'USE_ADB_REVERSE',
    defaultValue: true,
  );

  // Backend port.
  static const String apiPort = '5050';

  static String get baseUrl {
    if (apiBaseUrl.isNotEmpty) {
      return normalizeApiBase(apiBaseUrl);
    }

    if (apiHost.isNotEmpty) {
      return 'http://$apiHost:$apiPort/api/';
    }

    if (kIsWeb) {
      return 'http://localhost:$apiPort/api/';
    }

    if (Platform.isAndroid) {
      if (useAdbReverse) {
        return 'http://127.0.0.1:$apiPort/api/';
      }

      if (apiHost.isNotEmpty) {
        return 'http://$apiHost:$apiPort/api/';
      }

      return 'http://10.0.2.2:$apiPort/api/';
    }

    if (Platform.isIOS) {
      return 'http://localhost:$apiPort/api/';
    }

    return 'http://localhost:$apiPort/api/';
  }

  static List<String> get baseUrlCandidates => [baseUrl];

  static const Duration connectionTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static String normalizeApiBase(String value) {
    var v = value.trim();
    if (!v.endsWith('/')) v = '$v/';
    if (!v.endsWith('api/')) v = '${v}api/';
    return v;
  }

  // Get full URL for uploaded images
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    // Remove leading slash if present
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    final root = baseUrl.replaceFirst('/api/', '/');
    return '$root$cleanPath';
  }

  // -------------------------- AUTH -------------------------
  static const String user = 'auth/user';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String userById = 'auth/user/';
  static const String userByEmail = 'auth/user/email/';
  static const String userProfile = 'auth/profile';
  static const String updateProfilePicture = 'auth/user/profile-picture';

  // ----------------------- EVENTS ----------------------
  static const String events = 'events/';
  static const String createEvent = 'events';
  static const String getEvents = 'events';
  static const String getEventById = 'events/';
  static const String updateEvent = 'events/';
  static const String deleteEvent = 'events/';
}
