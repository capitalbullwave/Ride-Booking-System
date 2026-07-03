import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';

class RentalBookingState {
  const RentalBookingState({
    this.selectedHours,
    this.minHours = 4,
    this.selectedCategory,
    this.pickup,
    this.dropoff,
  });

  final double? selectedHours;
  final double minHours;
  final VehicleCategory? selectedCategory;
  final SelectedPlace? pickup;
  final SelectedPlace? dropoff;

  RentalBookingState copyWith({
    double? selectedHours,
    double? minHours,
    VehicleCategory? selectedCategory,
    SelectedPlace? pickup,
    SelectedPlace? dropoff,
    bool clearCategory = false,
    bool clearPickup = false,
    bool clearDropoff = false,
  }) =>
      RentalBookingState(
        selectedHours: selectedHours ?? this.selectedHours,
        minHours: minHours ?? this.minHours,
        selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
        pickup: clearPickup ? null : (pickup ?? this.pickup),
        dropoff: clearDropoff ? null : (dropoff ?? this.dropoff),
      );
}

class RentalBookingNotifier extends StateNotifier<RentalBookingState> {
  RentalBookingNotifier() : super(const RentalBookingState());

  void reset({double minHours = 4}) {
    state = RentalBookingState(minHours: minHours);
  }

  void setMinHours(double minHours) {
    state = state.copyWith(minHours: minHours);
  }

  void setHours(double hours) {
    state = state.copyWith(selectedHours: hours);
  }

  void setCategory(VehicleCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setPickup(SelectedPlace place) {
    state = state.copyWith(pickup: place);
  }

  void setDropoff(SelectedPlace place) {
    state = state.copyWith(dropoff: place);
  }
}

final rentalBookingProvider =
    StateNotifierProvider<RentalBookingNotifier, RentalBookingState>((ref) {
  return RentalBookingNotifier();
});
