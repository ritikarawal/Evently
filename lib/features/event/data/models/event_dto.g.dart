// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDto _$EventDtoFromJson(Map<String, dynamic> json) => EventDto(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      location: json['location'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      capacity: (json['capacity'] as num?)?.toInt(),
      attendeeIds: (json['attendeeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      organizerId: json['organizer'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EventDtoToJson(EventDto instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'location': instance.location,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'capacity': instance.capacity,
      'attendeeIds': instance.attendeeIds,
      'organizer': instance.organizerId,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
