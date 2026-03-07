import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/venues/data/models/venue_api_model.dart';

abstract class IVenueRemoteDataSource {
  Future<List<VenueApiModel>> getVenues({
    String? city,
    String? state,
    String? search,
  });

  Future<List<VenueApiModel>> getUserVenues();
  Future<VenueApiModel> createVenue(VenueApiModel venue);
}

class VenueRemoteDataSource implements IVenueRemoteDataSource {
  final Dio _dio;

  VenueRemoteDataSource(this._dio);

  @override
  Future<List<VenueApiModel>> getVenues({
    String? city,
    String? state,
    String? search,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.venues,
      queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final data = response.data;
    final list = data is Map<String, dynamic> ? data['data'] : data;
    if (list is! List) return const [];

    return list
        .map((e) => VenueApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<VenueApiModel>> getUserVenues() async {
    final response = await _dio.get(ApiEndpoints.userVenues);
    final data = response.data;
    final list = data is Map<String, dynamic> ? data['data'] : data;
    if (list is! List) return const [];

    return list
        .map((e) => VenueApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<VenueApiModel> createVenue(VenueApiModel venue) async {
    final response = await _dio.post(ApiEndpoints.venues, data: venue.toJson());
    final data = response.data;
    final payload = data is Map<String, dynamic> ? data['data'] : data;
    return VenueApiModel.fromJson(Map<String, dynamic>.from(payload as Map));
  }
}
