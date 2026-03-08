import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VenueEntity equality is value-based', () {
    const a = VenueEntity(
      id: 'v1',
      name: 'Venue',
      address: 'Addr',
      city: 'City',
      state: 'State',
      capacity: 100,
      isActive: true,
      creatorId: 'u1',
      recommendedCategory: 'wedding',
    );
    const b = VenueEntity(
      id: 'v1',
      name: 'Venue',
      address: 'Addr',
      city: 'City',
      state: 'State',
      capacity: 100,
      isActive: true,
      creatorId: 'u1',
      recommendedCategory: 'wedding',
    );

    expect(a, b);
  });
}
