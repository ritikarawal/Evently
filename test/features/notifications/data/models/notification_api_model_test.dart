import 'package:event_planner/features/notifications/data/models/notification_api_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationApiModel', () {
    test('fromJson maps id from _id', () {
      final model = NotificationApiModel.fromJson({'_id': 'abc', 'title': 'T'});
      expect(model.id, 'abc');
    });

    test('fromJson falls back to safe defaults', () {
      final model = NotificationApiModel.fromJson({});
      expect(model.title, '');
      expect(model.message, '');
      expect(model.type, '');
      expect(model.isRead, isFalse);
    });

    test('toEntity maps fields correctly', () {
      final model = NotificationApiModel.fromJson({
        '_id': 'id1',
        'title': 'Welcome',
        'message': 'Hello',
        'type': 'general',
        'isRead': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });

      final entity = model.toEntity();
      expect(entity.id, 'id1');
      expect(entity.title, 'Welcome');
      expect(entity.message, 'Hello');
      expect(entity.type, 'general');
      expect(entity.isRead, isTrue);
      expect(entity.createdAt, isNotNull);
    });
  });
}
