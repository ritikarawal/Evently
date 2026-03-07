import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageApiModel {
  final String? from;
  final String? text;
  final DateTime? timestamp;
  final bool? isRead;
  final String? senderName;

  ChatMessageApiModel({
    this.from,
    this.text,
    this.timestamp,
    this.isRead,
    this.senderName,
  });

  factory ChatMessageApiModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageApiModel(
      from: json['from']?.toString(),
      text: json['text']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      isRead: json['isRead'] as bool?,
      senderName: json['senderName']?.toString(),
    );
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      from: from ?? '',
      text: text ?? '',
      timestamp: timestamp,
      isRead: isRead ?? false,
      senderName: senderName,
    );
  }
}
