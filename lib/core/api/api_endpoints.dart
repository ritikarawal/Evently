import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  static const String compIpAddress = "192.168.18.79";

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
  static const String userProfile = 'auth/profile';
  static const String updateProfilePicture = 'auth/user/profile-picture';

  // ----------------------- EVENTS ----------------------
  static const String events = 'events/';
  static const String createEvent = 'events';
  static const String getEvents = 'events';
  static const String getEventById = 'events/';
  static const String updateEvent = 'events/';
  static const String deleteEvent = 'events/';

  // ----------------------- VENUES ----------------------
  static const String venues = 'venues';
  static const String userVenues = 'venues/user/my-venues';

  // -------------------- NOTIFICATIONS ------------------
  static const String notifications = 'notifications';
  static const String notificationUnreadCount = 'notifications/unread-count';
  static const String notificationMarkAllRead = 'notifications/mark-all-read';

  // ----------------------- CHAT ------------------------
  static const String chatHistory = 'chat/history';
  static const String chatUnreadCount = 'chat/unread-count';
  static const String chatSendUser = 'chat/user/send';
  static const String adminChatUsers = 'chat/admin/users';
  static String adminChatUser(String userId) => 'chat/admin/user/$userId';
  static String adminChatSend(String userId) => 'chat/admin/user/$userId/send';

  // ----------------------- ADMIN -----------------------
  static const String adminUsers = 'admin/users';
  static String adminUserById(String userId) => 'admin/users/$userId';

  static const String adminEvents = 'admin/events';
  static String adminApproveEvent(String eventId) =>
      'admin/events/$eventId/approve';
  static String adminDeclineEvent(String eventId) =>
      'admin/events/$eventId/decline';
  static String adminEventById(String eventId) => 'admin/events/$eventId';

  // --------------------- PAYMENTS ----------------------
  static const String khaltiVerify = 'payments/khalti-verify';
  static const String paymentCreate = 'payments/create';
  static String paymentsByUser(String userId) => 'payments/user/$userId';
  static String paymentsByEvent(String eventId) => 'payments/event/$eventId';
}
