import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String from;
  final String text;
  final DateTime? timestamp;
  final bool isRead;
  final String? senderName;

  const ChatMessageEntity({
    this.from = '',
    this.text = '',
    this.timestamp,
    this.isRead = false,
    this.senderName,
  });

  @override
  List<Object?> get props => [from, text, timestamp, isRead, senderName];
}
