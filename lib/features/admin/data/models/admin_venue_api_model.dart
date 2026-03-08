import 'package:event_planner/features/admin/domain/entities/admin_venue_entity.dart';

class AdminVenueApiModel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String address;
  final int? capacity;
  final bool isActive;

  const AdminVenueApiModel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.address,
    required this.capacity,
    required this.isActive,
  });

  factory AdminVenueApiModel.fromJson(Map<String, dynamic> json) {
    return AdminVenueApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      capacity: int.tryParse((json['capacity'] ?? '').toString()),
      isActive: (json['isActive'] ?? true) == true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'city': city,
      'state': state,
      'address': address,
      if (capacity != null) 'capacity': capacity,
    };
  }

  AdminVenueEntity toEntity() {
    return AdminVenueEntity(
      id: id,
      name: name,
      city: city,
      state: state,
      address: address,
      capacity: capacity,
      isActive: isActive,
    );
  }
}
