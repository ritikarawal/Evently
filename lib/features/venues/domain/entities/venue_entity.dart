import 'package:equatable/equatable.dart';

class VenueEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final int? capacity;
  final bool isActive;
  final String creatorId;

  const VenueEntity({
    this.id = '',
    this.name = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.capacity,
    this.isActive = true,
    this.creatorId = '',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    city,
    state,
    capacity,
    isActive,
    creatorId,
  ];
}
