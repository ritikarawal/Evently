import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/venues/data/datasources/venue_remote_datasource.dart';
import 'package:event_planner/features/venues/data/models/venue_api_model.dart';
import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';
import 'package:event_planner/features/venues/domain/repositories/venue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final venueRemoteDataSourceProvider = Provider<IVenueRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return VenueRemoteDataSource(dio);
});

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  final remote = ref.read(venueRemoteDataSourceProvider);
  return VenueRepositoryImpl(remote);
});

class VenueRepositoryImpl implements VenueRepository {
  final IVenueRemoteDataSource _remote;

  VenueRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, VenueEntity>> createVenue(VenueEntity venue) async {
    try {
      final result = await _remote.createVenue(VenueApiModel.fromEntity(venue));
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to create venue'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VenueEntity>>> getUserVenues() async {
    try {
      final result = await _remote.getUserVenues();
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch user venues'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VenueEntity>>> getVenues({
    String? city,
    String? state,
    String? search,
    String? recommendedCategory,
  }) async {
    try {
      final result = await _remote.getVenues(
        city: city,
        state: state,
        search: search,
        recommendedCategory: recommendedCategory,
      );
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch venues'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
