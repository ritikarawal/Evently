import 'package:event_planner/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NotificationEntity equality is value-based', () {
    final now = DateTime.now();
    final a = NotificationEntity(
      id: 'n1',
      title: 'Title',
      message: 'Message',
      type: 'general',
      isRead: false,
      createdAt: now,
    );
    final b = NotificationEntity(
      id: 'n1',
      title: 'Title',
      message: 'Message',
      type: 'general',
      isRead: false,
      createdAt: now,
    );

    expect(a, b);
  });
}
