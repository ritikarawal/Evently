import '../entities/event.dart';

abstract class EventRepository {
  Future<Event> createEvent(Event event);
  Future<List<Event>> getUserEvents(String userId);
  Future<Event> getEventById(String eventId);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
}
