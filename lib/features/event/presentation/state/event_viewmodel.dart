import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';

// Event repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EventRepositoryImpl(apiClient);
});

// Event creation state
class EventCreationState {
  final bool isLoading;
  final Event? createdEvent;
  final String? error;

  EventCreationState({this.isLoading = false, this.createdEvent, this.error});

  bool get isSuccess => createdEvent != null;
  String? get errorMessage => error;
}

// Event Notifier
class EventNotifier extends Notifier<EventCreationState> {
  @override
  EventCreationState build() {
    return EventCreationState();
  }

  Future<void> createEvent(Event event) async {
    state = EventCreationState(isLoading: true);
    try {
      final repository = ref.read(eventRepositoryProvider);
      final createdEvent = await repository.createEvent(event);
      state = EventCreationState(createdEvent: createdEvent);
    } catch (e) {
      state = EventCreationState(error: e.toString());
    }
  }
}

// Event notifier provider
final eventViewModelProvider =
    NotifierProvider<EventNotifier, EventCreationState>(() {
      return EventNotifier();
    });
