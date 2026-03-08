import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';

class VenueApiModel {
  final String? id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final int? capacity;
  final bool? isActive;
  final String? creatorId;
  final String? recommendedCategory;

  VenueApiModel({
    this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.capacity,
    this.isActive,
    this.creatorId,
    this.recommendedCategory,
  });

  factory VenueApiModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    final creatorId = creator is String
        ? creator
        : (creator is Map && creator['_id'] != null)
        ? creator['_id'].toString()
        : (json['creatorId']?.toString());

    return VenueApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: (json['name'] ?? '').toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      capacity: json['capacity'] is num
          ? (json['capacity'] as num).toInt()
          : int.tryParse('${json['capacity'] ?? ''}'),
      isActive: json['isActive'] as bool?,
      creatorId: creatorId,
      recommendedCategory: json['recommendedCategory']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (capacity != null) 'capacity': capacity,
      if (recommendedCategory != null)
        'recommendedCategory': recommendedCategory,
    };
  }

  VenueEntity toEntity() {
    return VenueEntity(
      id: id ?? '',
      name: name,
      address: address ?? '',
      city: city ?? '',
      state: state ?? '',
      capacity: capacity,
      isActive: isActive ?? true,
      creatorId: creatorId ?? '',
      recommendedCategory: recommendedCategory,
    );
  }

  factory VenueApiModel.fromEntity(VenueEntity entity) {
    return VenueApiModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      capacity: entity.capacity,
      isActive: entity.isActive,
      creatorId: entity.creatorId,
      recommendedCategory: entity.recommendedCategory,
    );
  }
}
