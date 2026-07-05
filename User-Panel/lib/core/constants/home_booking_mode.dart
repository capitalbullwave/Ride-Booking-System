enum HomeBookingMode {
  ride,
  rental,
  parcel;

  String get label {
    switch (this) {
      case HomeBookingMode.ride:
        return 'Ride';
      case HomeBookingMode.rental:
        return 'Rental';
      case HomeBookingMode.parcel:
        return 'Parcel';
    }
  }

  String get actionLabel {
    switch (this) {
      case HomeBookingMode.ride:
        return 'Find a ride';
      case HomeBookingMode.rental:
        return 'Start rental';
      case HomeBookingMode.parcel:
        return 'Send parcel';
    }
  }

  String get dropPlaceholder {
    switch (this) {
      case HomeBookingMode.ride:
        return 'Where are you going?';
      case HomeBookingMode.rental:
        return 'Return location';
      case HomeBookingMode.parcel:
        return 'Delivery address';
    }
  }

  String get dropFieldLabel {
    switch (this) {
      case HomeBookingMode.ride:
        return 'Drop';
      case HomeBookingMode.rental:
        return 'Return';
      case HomeBookingMode.parcel:
        return 'Delivery';
    }
  }
}
