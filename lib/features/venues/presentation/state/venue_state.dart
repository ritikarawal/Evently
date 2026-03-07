import 'package:event_planner/features/venues/domain/entities/venue_entity.dart';

class VenueState {
  final bool isLoading;
  final List<VenueEntity> venues;
  final String? errorMessage;

  const VenueState({
    this.isLoading = false,
    this.venues = const [],
    this.errorMessage,
  });

  VenueState copyWith({
    bool? isLoading,
    List<VenueEntity>? venues,
    String? errorMessage,
  }) {
    return VenueState(
      isLoading: isLoading ?? this.isLoading,
      venues: venues ?? this.venues,
      errorMessage: errorMessage,
    );
  }
}
