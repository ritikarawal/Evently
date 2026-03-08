import 'package:event_planner/features/venues/domain/usecases/get_venues_usecase.dart';
import 'package:event_planner/features/venues/presentation/state/venue_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class VenueViewModel extends StateNotifier<VenueState> {
  final GetVenuesUsecase _getVenues;

  VenueViewModel(this._getVenues) : super(const VenueState());

  Future<void> loadVenues({
    String? city,
    String? stateName,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getVenues(
      GetVenuesParams(city: city, state: stateName, search: search),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (venues) => state = state.copyWith(
        isLoading: false,
        venues: venues,
        errorMessage: null,
      ),
    );
  }
}

final venueViewModelProvider =
    StateNotifierProvider<VenueViewModel, VenueState>((ref) {
      final usecase = ref.read(getVenuesUsecaseProvider);
      return VenueViewModel(usecase);
    });
