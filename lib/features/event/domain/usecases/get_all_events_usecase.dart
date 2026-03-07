import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllEventsUsecaseProvider = Provider<GetAllEventsUsecase>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return GetAllEventsUsecase(repository);
});

class GetAllEventsUsecase {
  final EventRepository _repository;

  GetAllEventsUsecase(this._repository);

  Future<List<Event>> call({Map<String, dynamic>? filters}) {
    return _repository.getAllEvents(filters: filters);
  }
}
