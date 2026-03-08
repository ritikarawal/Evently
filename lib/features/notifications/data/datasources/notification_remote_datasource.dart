import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/notifications/data/models/notification_api_model.dart';

abstract class INotificationRemoteDataSource {
  Future<List<NotificationApiModel>> getNotifications({int limit = 50});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSource(this._dio);

  @override
  Future<List<NotificationApiModel>> getNotifications({int limit = 50}) async {
    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'limit': limit},
    );

    final data = response.data;
    final list = data is Map<String, dynamic> ? data['data'] : data;
    if (list is! List) return const [];

    return list
        .map(
          (e) => NotificationApiModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.notificationUnreadCount);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        final raw = payload['unreadCount'];
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        return int.tryParse('$raw') ?? 0;
      }
    }
    return 0;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dio.put('${ApiEndpoints.notifications}/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.put(ApiEndpoints.notificationMarkAllRead);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete('${ApiEndpoints.notifications}/$notificationId');
  }
}
