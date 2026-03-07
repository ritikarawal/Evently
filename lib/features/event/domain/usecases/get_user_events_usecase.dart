import 'package:event_planner/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_planner/features/event/domain/entities/event.dart';
import 'package:event_planner/features/event/domain/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUserEventsUsecaseProvider = Provider<GetUserEventsUsecase>((ref) {
  final repository = ref.read(eventRepositoryProvider);
  return GetUserEventsUsecase(repository);
});

class GetUserEventsUsecase {
  final EventRepository _repository;

  GetUserEventsUsecase(this._repository);

  Future<List<Event>> call(String userId) {
    return _repository.getUserEvents(userId);
  }
}
