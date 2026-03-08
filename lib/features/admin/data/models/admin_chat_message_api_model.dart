import 'package:event_planner/features/admin/domain/entities/admin_chat_message_entity.dart';

class AdminChatMessageApiModel {
  final String id;
  final String from;
  final String text;
  final DateTime? timestamp;
  final bool isRead;
  final String? senderName;

  const AdminChatMessageApiModel({
    required this.id,
    required this.from,
    required this.text,
    required this.timestamp,
    required this.isRead,
    this.senderName,
  });

  factory AdminChatMessageApiModel.fromJson(Map<String, dynamic> json) {
    return AdminChatMessageApiModel(
      id: (json['_id'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      timestamp: DateTime.tryParse((json['timestamp'] ?? '').toString()),
      isRead: (json['isRead'] ?? false) == true,
      senderName: json['senderName']?.toString(),
    );
  }

  AdminChatMessageEntity toEntity() {
    return AdminChatMessageEntity(
      id: id,
      from: from,
      text: text,
      timestamp: timestamp,
      isRead: isRead,
      senderName: senderName,
    );
  }
}
