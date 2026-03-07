import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/venues/data/repositories/venue_repository_impl.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:event_planner/features/venues/domain/repositories/venue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetVenuesParams {
  final String? city;
  final String? state;
  final String? search;
  final String? recommendedCategory;

  const GetVenuesParams({
    this.city,
    this.state,
    this.search,
    this.recommendedCategory,
  });
}

class GetVenuesUsecase {
  final VenueRepository _repository;

  GetVenuesUsecase(this._repository);

  Future<Either<Failure, List<VenueEntity>>> call(GetVenuesParams params) {
    return _repository.getVenues(
      city: params.city,
      state: params.state,
      search: params.search,
      recommendedCategory: params.recommendedCategory,
    );
  }
}

final getVenuesUsecaseProvider = Provider<GetVenuesUsecase>((ref) {
  final repo = ref.read(venueRepositoryProvider);
  return GetVenuesUsecase(repo);
});
