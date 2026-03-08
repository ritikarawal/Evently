import 'package:equatable/equatable.dart';

class AdminEventEntity extends Equatable {
  final String id;
  final String title;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String organizerName;

  const AdminEventEntity({
    this.id = '',
    this.title = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.status = 'pending',
    this.organizerName = '',
  });

  @override
  List<Object?> get props => [
    id,
    title,
    location,
    startDate,
    endDate,
    status,
    organizerName,
  ];
}
