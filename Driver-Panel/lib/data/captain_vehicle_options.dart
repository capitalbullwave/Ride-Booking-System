import 'package:flutter/material.dart';

/// Captain onboarding vehicle categories (Rapido-style).
class CaptainVehicleOption {
  const CaptainVehicleOption({
    required this.id,
    required this.label,
    required this.registrationType,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String id;
  final String label;

  /// Stored in [DriverRegistration.vehicleType] for backend resolution.
  final String registrationType;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
}

class CaptainVehicleOptions {
  CaptainVehicleOptions._();

  static const List<CaptainVehicleOption> all = [
    CaptainVehicleOption(
      id: 'bike',
      label: 'Bike',
      registrationType: 'Bike',
      icon: Icons.two_wheeler_rounded,
      iconColor: Color(0xFF31526E),
      backgroundColor: Color(0xFFF3F6F9),
    ),
    CaptainVehicleOption(
      id: 'auto',
      label: 'Auto',
      registrationType: 'Auto',
      icon: Icons.electric_rickshaw_rounded,
      iconColor: Color(0xFF5FA87A),
      backgroundColor: Color(0xFFF2FAF5),
    ),
    CaptainVehicleOption(
      id: 'e_rickshaw',
      label: 'E-Rickshaw',
      registrationType: 'E-Rickshaw',
      icon: Icons.electric_moped_rounded,
      iconColor: Color(0xFF6086A8),
      backgroundColor: Color(0xFFF2F6FA),
    ),
    CaptainVehicleOption(
      id: 'cab',
      label: 'Cab',
      registrationType: 'Cab',
      icon: Icons.directions_car_filled_rounded,
      iconColor: Color(0xFF263F54),
      backgroundColor: Color(0xFFF5F5F5),
    ),
  ];

  static CaptainVehicleOption? byRegistrationType(String? type) {
    if (type == null || type.trim().isEmpty) return null;
    final normalized = type.trim().toLowerCase();
    for (final option in all) {
      if (option.registrationType.toLowerCase() == normalized ||
          option.id == normalized.replaceAll(' ', '_').replaceAll('-', '_')) {
        return option;
      }
    }
    return null;
  }
}
