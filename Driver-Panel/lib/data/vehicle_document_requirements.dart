import 'package:wavego_driver/data/captain_vehicle_options.dart';
import 'package:wavego_driver/models/registration_model.dart';

class VehicleDocumentSpec {
  const VehicleDocumentSpec({
    required this.type,
    required this.label,
    required this.fieldGetter,
    required this.fieldSetter,
  });

  final String type;
  final String label;
  final String? Function(DriverRegistration r) fieldGetter;
  final DriverRegistration Function(DriverRegistration r, String? url) fieldSetter;
}

class VehicleDocumentRequirements {
  VehicleDocumentRequirements._();

  static const insurance = 'INSURANCE';
  static const pollution = 'POLLUTION';
  static const permit = 'PERMIT';
  static const fitness = 'FITNESS';
  static const vehicleFront = 'VEHICLE_FRONT';
  static const vehicleBack = 'VEHICLE_BACK';
  static const vehicleSide = 'VEHICLE_SIDE';

  static String normalizeCategory(String? vehicleType) {
    final option = CaptainVehicleOptions.byRegistrationType(vehicleType);
    return option?.id ?? 'bike';
  }

  static List<VehicleDocumentSpec> specsFor(String? vehicleType) {
    final category = normalizeCategory(vehicleType);
    final requiredTypes = _requiredTypes[category] ?? _requiredTypes['bike']!;
    return requiredTypes
        .map((type) => _allSpecs.firstWhere((s) => s.type == type))
        .toList();
  }

  static bool isSatisfied(DriverRegistration registration) {
    for (final spec in specsFor(registration.vehicleType)) {
      if ((spec.fieldGetter(registration) ?? '').trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  static const Map<String, List<String>> _requiredTypes = {
    'bike': [insurance, vehicleFront],
    'auto': [insurance, pollution, permit, vehicleFront, vehicleBack],
    'e_rickshaw': [insurance, pollution, permit, vehicleFront, vehicleBack],
    'cab': [
      insurance,
      pollution,
      permit,
      fitness,
      vehicleFront,
      vehicleBack,
      vehicleSide,
    ],
  };

  static final List<VehicleDocumentSpec> _allSpecs = [
    VehicleDocumentSpec(
      type: insurance,
      label: 'Vehicle Insurance',
      fieldGetter: (r) => r.insuranceUrl,
      fieldSetter: (r, url) => r.copyWith(insuranceUrl: url),
    ),
    VehicleDocumentSpec(
      type: pollution,
      label: 'Pollution Certificate',
      fieldGetter: (r) => r.pollutionUrl,
      fieldSetter: (r, url) => r.copyWith(pollutionUrl: url),
    ),
    VehicleDocumentSpec(
      type: permit,
      label: 'Commercial Permit',
      fieldGetter: (r) => r.permitUrl,
      fieldSetter: (r, url) => r.copyWith(permitUrl: url),
    ),
    VehicleDocumentSpec(
      type: fitness,
      label: 'Fitness Certificate',
      fieldGetter: (r) => r.fitnessUrl,
      fieldSetter: (r, url) => r.copyWith(fitnessUrl: url),
    ),
    VehicleDocumentSpec(
      type: vehicleFront,
      label: 'Vehicle Front Photo',
      fieldGetter: (r) => r.vehicleFrontUrl,
      fieldSetter: (r, url) => r.copyWith(vehicleFrontUrl: url),
    ),
    VehicleDocumentSpec(
      type: vehicleBack,
      label: 'Vehicle Back Photo',
      fieldGetter: (r) => r.vehicleBackUrl,
      fieldSetter: (r, url) => r.copyWith(vehicleBackUrl: url),
    ),
    VehicleDocumentSpec(
      type: vehicleSide,
      label: 'Vehicle Side Photo',
      fieldGetter: (r) => r.vehicleSideUrl,
      fieldSetter: (r, url) => r.copyWith(vehicleSideUrl: url),
    ),
  ];
}
