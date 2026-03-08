import 'package:json_annotation/json_annotation.dart';

part 'event_dto.g.dart';

@JsonSerializable()
class EventDto {
  @JsonKey(name: '_id')
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final String? location;
  @JsonKey(name: 'startDate')
  final DateTime? startDate;
  @JsonKey(name: 'endDate')
  final DateTime? endDate;
  final int? capacity;
  final List<String>? attendeeIds;
  @JsonKey(name: 'organizer')
  final String? organizerId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventDto({
    this.id,
    this.title,
    this.description,
    this.category,
    this.location,
    this.startDate,
    this.endDate,
    this.capacity,
    this.attendeeIds,
    this.organizerId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) =>
      _$EventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventDtoToJson(this);
}
