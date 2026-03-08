import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EventRepositoryImpl(apiClient);
});

class EventRepositoryImpl implements EventRepository {
  final ApiClient _apiClient;

  EventRepositoryImpl(this._apiClient);

  @override
  Future<Event> createEvent(Event event) async {
    try {
      final eventData = {
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'location': event.location,
        'startDate': event.startDate?.toIso8601String(),
        'endDate': event.endDate?.toIso8601String(),
        'capacity': event.capacity,
        'eventType': event.eventType,
        'ticketPrice': event.ticketPrice,
        'isPublic': event.isPublic,
      };

      final response = await _apiClient.post('events', data: eventData);
      return _mapEventFromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<List<Event>> getAllEvents({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiClient.get('events', queryParameters: filters);
      final List<dynamic> data = _extractEventList(response.data);
      return data.map(_mapEventFromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    if (userId.isEmpty) {
      return getAllEvents();
    }

    try {
      final response = await _apiClient.get('events/user/my-events');
      final List<dynamic> data = _extractEventList(response.data);
      return data.map(_mapEventFromJson).toList();
    } catch (e) {
      if (_isNetworkError(e)) {
        throw Exception('Failed to fetch events: $e');
      }
      try {
        return getAllEvents();
      } catch (fallbackError) {
        throw Exception('Failed to fetch events: $fallbackError');
      }
    }
  }

  bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('timeout') ||
        msg.contains('no internet connection') ||
        msg.contains('connection');
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _apiClient.get('events/$eventId');
      return _mapEventFromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  @override
  Future<Event> joinEvent(String eventId) async {
    try {
      final response = await _apiClient.post('events/$eventId/join');
      return _mapEventFromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }

  @override
  Future<Event> leaveEvent(String eventId) async {
    try {
      final response = await _apiClient.post('events/$eventId/leave');
      return _mapEventFromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to leave event: $e');
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      final eventData = {
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'location': event.location,
        'startDate': event.startDate?.toIso8601String(),
        'endDate': event.endDate?.toIso8601String(),
        'capacity': event.capacity,
      };

      await _apiClient.put('events/${event.id}', data: eventData);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _apiClient.delete('events/$eventId');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Event _mapEventFromJson(dynamic raw) {
    final json = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);

    final attendeesRaw = json['attendeeIds'] ?? json['attendees'];
    final attendeeIds = <String>[];

    if (attendeesRaw is List) {
      for (final attendee in attendeesRaw) {
        if (attendee is String) {
          attendeeIds.add(attendee);
        } else if (attendee is Map && attendee['_id'] != null) {
          attendeeIds.add(attendee['_id'].toString());
        }
      }
    }

    final organizerRaw = json['organizer'];
    final organizerId = organizerRaw is String
        ? organizerRaw
        : (organizerRaw is Map && organizerRaw['_id'] != null)
        ? organizerRaw['_id'].toString()
        : (json['organizerId']?.toString() ?? '');

    final imageUrl = (json['eventImage'] ?? json['imageUrl'] ?? json['image'])
        ?.toString();
    final eventType = (json['eventType'] ?? 'free').toString().toLowerCase();

    return Event(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      capacity: _parseInt(json['capacity']),
      attendeeIds: attendeeIds,
      organizerId: organizerId,
      status: (json['status'] ?? 'draft').toString(),
      imageUrl: imageUrl,
      eventType: eventType,
      ticketPrice: _parseDouble(json['ticketPrice']),
      isPublic: _parseBool(json['isPublic'], fallback: true),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  List<dynamic> _extractEventList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data;
      }

      final events = responseData['events'];
      if (events is List) {
        return events;
      }
    }

    if (responseData is List) {
      return responseData;
    }

    return const [];
  }
}
