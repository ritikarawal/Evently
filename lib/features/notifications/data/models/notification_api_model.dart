import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  final bool? isRead;
  final DateTime? createdAt;

  NotificationApiModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id ?? '',
      title: title ?? '',
      message: message ?? '',
      type: type ?? '',
      isRead: isRead ?? false,
      createdAt: createdAt,
    );
  }
}
