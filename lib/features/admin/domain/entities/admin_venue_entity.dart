import 'package:equatable/equatable.dart';

class AdminVenueEntity extends Equatable {
  final String id;
  final String name;
  final String city;
  final String state;
  final String address;
  final int? capacity;
  final bool isActive;

  const AdminVenueEntity({
    this.id = '',
    this.name = '',
    this.city = '',
    this.state = '',
    this.address = '',
    this.capacity,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    city,
    state,
    address,
    capacity,
    isActive,
  ];
}
