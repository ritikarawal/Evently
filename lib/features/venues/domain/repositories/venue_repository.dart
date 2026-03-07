import 'package:dartz/dartz.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';

abstract class VenueRepository {
  Future<Either<Failure, List<VenueEntity>>> getVenues({
    String? city,
    String? state,
    String? search,
    String? recommendedCategory,
  });

  Future<Either<Failure, List<VenueEntity>>> getUserVenues();

  Future<Either<Failure, VenueEntity>> createVenue(VenueEntity venue);
}
