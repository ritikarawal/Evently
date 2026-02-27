import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

// Event repository provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EventRepositoryImpl(apiClient);
});

// Event creation state
class EventState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final Event? createdEvent;

  EventState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.createdEvent,
  });

  EventState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    Event? createdEvent,
  }) {
    return EventState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdEvent: createdEvent ?? this.createdEvent,
    );
  }
}

class EventViewModel extends StateNotifier<EventState> {
  final EventRepository _eventRepository;

  EventViewModel(this._eventRepository) : super(EventState());

  Future<void> createEvent(Event event) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      final createdEvent = await _eventRepository.createEvent(event);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdEvent: createdEvent,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = EventState();
  }
}

// Event creation provider
final eventViewModelProvider =
    StateNotifierProvider<EventViewModel, EventState>((ref) {
      final repository = ref.read(eventRepositoryProvider);
      return EventViewModel(repository);
    });
