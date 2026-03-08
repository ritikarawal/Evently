import 'package:event_planner/features/admin/domain/entities/admin_event_entity.dart';

class AdminEventApiModel {
  final String id;
  final String title;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String organizerName;

  const AdminEventApiModel({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.organizerName,
  });

  factory AdminEventApiModel.fromJson(Map<String, dynamic> json) {
    final organizer = json['organizer'];
    String organizerName = '';
    if (organizer is Map<String, dynamic>) {
      final first = (organizer['firstName'] ?? '').toString();
      final last = (organizer['lastName'] ?? '').toString();
      organizerName = '$first $last'.trim();
    }

    return AdminEventApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()),
      endDate: DateTime.tryParse((json['endDate'] ?? '').toString()),
      status: (json['status'] ?? 'pending').toString(),
      organizerName: organizerName,
    );
  }

  AdminEventEntity toEntity() {
    return AdminEventEntity(
      id: id,
      title: title,
      location: location,
      startDate: startDate,
      endDate: endDate,
      status: status,
      organizerName: organizerName,
    );
  }
}
