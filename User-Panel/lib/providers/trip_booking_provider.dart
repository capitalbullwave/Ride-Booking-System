import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/home_booking_mode.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/services/location_service.dart';

class TripBookingNotifier extends StateNotifier<TripBookingState> {
  TripBookingNotifier() : super(const TripBookingState());

  static const int maxStops = 3;

  void setPickup(SelectedPlace place) {
    state = state.copyWith(pickup: place, clearRoute: true);
  }

  void setDropoff(SelectedPlace place) {
    state = state.copyWith(dropoff: place, clearRoute: true);
  }

  void addStop(SelectedPlace place) {
    if (state.stops.length >= maxStops) return;
    state = state.copyWith(
      stops: [...state.stops, place],
      clearRoute: true,
    );
  }

  /// Inserts an empty stop slot above drop (user fills it next).
  void addEmptyStop() {
    if (state.stops.length >= maxStops) return;
    state = state.copyWith(
      stops: [...state.stops, const SelectedPlace(label: '')],
      clearRoute: true,
    );
  }

  void updateStopAt(int index, SelectedPlace place) {
    if (index < 0 || index >= state.stops.length) return;
    final next = [...state.stops];
    next[index] = place;
    state = state.copyWith(stops: next, clearRoute: true);
  }

  void removeStopAt(int index) {
    if (index < 0 || index >= state.stops.length) return;
    final next = [...state.stops]..removeAt(index);
    state = state.copyWith(stops: next, clearRoute: true);
  }

  void clearStops() {
    state = state.copyWith(clearStops: true, clearRoute: true);
  }

  void setMode(HomeBookingMode mode) {
    state = state.copyWith(mode: mode, clearRoute: true);
  }

  void setScheduledAt(DateTime? scheduledAt) {
    state = state.copyWith(
      scheduledAt: scheduledAt,
      clearScheduledAt: scheduledAt == null,
    );
  }

  void swapLocations() {
    state = TripBookingState(
      pickup: state.dropoff,
      dropoff: state.pickup,
      stops: state.stops,
      activeRideId: state.activeRideId,
      mode: state.mode,
      scheduledAt: state.scheduledAt,
    );
  }

  void setRoute(DirectionsResult route) {
    state = state.copyWith(route: route);
  }

  void setActiveRideId(String rideId) {
    state = state.copyWith(activeRideId: rideId);
  }

  void setBookedVehicleSlug(String? slug) {
    state = state.copyWith(bookedVehicleSlug: slug);
  }

  void clearActiveRideId() {
    state = TripBookingState(
      pickup: state.pickup,
      dropoff: state.dropoff,
      stops: state.stops,
      route: state.route,
      bookedVehicleSlug: state.bookedVehicleSlug,
      mode: state.mode,
      scheduledAt: state.scheduledAt,
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
