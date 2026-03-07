import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/venues/data/repositories/venue_repository_impl.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:event_planner/features/venues/domain/repositories/venue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUserVenuesUsecase {
  final VenueRepository _repository;

  GetUserVenuesUsecase(this._repository);

  Future<Either<Failure, List<VenueEntity>>> call() {
    return _repository.getUserVenues();
  }
}

final getUserVenuesUsecaseProvider = Provider<GetUserVenuesUsecase>((ref) {
  final repo = ref.read(venueRepositoryProvider);
  return GetUserVenuesUsecase(repo);
});
