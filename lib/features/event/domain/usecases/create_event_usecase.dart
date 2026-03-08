import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createEventUsecaseProvider = Provider<CreateEventUsecase>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return CreateEventUsecase(repository);
});

class CreateEventUsecase {
  final EventRepository _repository;

  CreateEventUsecase(this._repository);

  Future<Event> call(Event event) {
    return _repository.createEvent(event);
  }
}
