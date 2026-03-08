import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChatMessageEntity equality is value-based', () {
    final now = DateTime.now();
    final a = ChatMessageEntity(
      from: 'user',
      text: 'hello',
      timestamp: now,
      isRead: true,
      senderName: 'John',
    );
    final b = ChatMessageEntity(
      from: 'user',
      text: 'hello',
      timestamp: now,
      isRead: true,
      senderName: 'John',
    );

    expect(a, b);
  });
}
