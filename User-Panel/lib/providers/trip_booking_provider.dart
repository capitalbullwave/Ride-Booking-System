import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/services/location_service.dart';

class TripBookingNotifier extends StateNotifier<TripBookingState> {
  TripBookingNotifier() : super(const TripBookingState());

  void setPickup(SelectedPlace place) {
    state = state.copyWith(pickup: place, clearRoute: true);
  }

  void setDropoff(SelectedPlace place) {
    state = state.copyWith(dropoff: place, clearRoute: true);
  }

  void swapLocations() {
    state = TripBookingState(
      pickup: state.dropoff,
      dropoff: state.pickup,
      activeRideId: state.activeRideId,
    );
  }

  void setRoute(DirectionsResult route) {
    state = state.copyWith(route: route);
  }

  void setActiveRideId(String rideId) {
    state = state.copyWith(activeRideId: rideId);
  }

  void clearActiveRideId() {
    state = TripBookingState(
      pickup: state.pickup,
      dropoff: state.dropoff,
      route: state.route,
    );
  }

  void clear() => state = const TripBookingState();
}

final tripBookingProvider =
    StateNotifierProvider<TripBookingNotifier, TripBookingState>((ref) {
  return TripBookingNotifier();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
