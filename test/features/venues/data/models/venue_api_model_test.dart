import 'package:event_planner/features/venues/data/models/venue_api_model.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VenueApiModel', () {
    test('fromJson parses creator id from nested creator object', () {
      final model = VenueApiModel.fromJson({
        '_id': 'v1',
        'name': 'Venue',
        'creator': {'_id': 'u1'},
      });

      expect(model.id, 'v1');
      expect(model.creatorId, 'u1');
    });

    test('toJson includes non-null fields only', () {
      final model = VenueApiModel(name: 'Venue', city: 'Kathmandu');
      final json = model.toJson();

      expect(json['name'], 'Venue');
      expect(json['city'], 'Kathmandu');
      expect(json.containsKey('address'), isFalse);
    });

    test('fromEntity and toEntity preserve values', () {
      const entity = VenueEntity(
        id: '1',
        name: 'Hall',
        address: 'A',
        city: 'C',
        state: 'S',
        capacity: 50,
        isActive: false,
        creatorId: 'u1',
        recommendedCategory: 'wedding',
      );

      final model = VenueApiModel.fromEntity(entity);
      final mappedBack = model.toEntity();

      expect(mappedBack.id, '1');
      expect(mappedBack.name, 'Hall');
      expect(mappedBack.capacity, 50);
      expect(mappedBack.isActive, isFalse);
      expect(mappedBack.recommendedCategory, 'wedding');
    });
  });
}
