import 'package:wavego_user/models/user_models.dart';

/// Minimum rental hours from admin-configured categories (defaults to 4).
double rentalMinHours(List<VehicleCategory> categories) {
  if (categories.isEmpty) return 4;
  final values = categories
      .map((c) => c.includedHours ?? 4)
      .where((h) => h > 0)
      .toList();
  if (values.isEmpty) return 4;
  return values.reduce((a, b) => a < b ? a : b);
}

/// Fare for selected hours — base package + extra hour charges (no KM).
double rentalFareForHours(VehicleCategory category, double hours) {
  final included = category.includedHours ?? 4;
  final base = category.baseFare;
  final extraHourRate = category.perHourRate ?? 0;
  if (hours <= included) return base;
  return base + (hours - included) * extraHourRate;
}

String rentalFareLabel(VehicleCategory category, double hours) {
  return '₹${rentalFareForHours(category, hours).round()}';
}
