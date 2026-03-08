import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntity({
    this.id = '',
    this.title = '',
    this.message = '',
    this.type = '',
    this.isRead = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt];
}
