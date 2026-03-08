import 'package:equatable/equatable.dart';

class AdminChatMessageEntity extends Equatable {
  final String id;
  final String from;
  final String text;
  final DateTime? timestamp;
  final bool isRead;
  final String? senderName;

  const AdminChatMessageEntity({
    this.id = '',
    this.from = '',
    this.text = '',
    this.timestamp,
    this.isRead = false,
    this.senderName,
  });

  @override
  List<Object?> get props => [id, from, text, timestamp, isRead, senderName];
}
