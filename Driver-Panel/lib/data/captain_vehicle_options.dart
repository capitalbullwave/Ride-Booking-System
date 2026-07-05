import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

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
      iconColor: AppColors.primary,
      backgroundColor: Color(0xFFF5F0FF),
    ),
    CaptainVehicleOption(
      id: 'auto',
      label: 'Auto',
      registrationType: 'Auto',
      icon: Icons.electric_rickshaw_rounded,
      iconColor: AppColors.success,
      backgroundColor: Color(0xFFF2FAF5),
    ),
    CaptainVehicleOption(
      id: 'e_rickshaw',
      label: 'E-Rickshaw',
      registrationType: 'E-Rickshaw',
      icon: Icons.electric_moped_rounded,
      iconColor: AppColors.info,
      backgroundColor: Color(0xFFF5F0FF),
    ),
    CaptainVehicleOption(
      id: 'cab',
      label: 'Cab',
      registrationType: 'Cab',
      icon: Icons.directions_car_filled_rounded,
      iconColor: AppColors.primaryDark,
      backgroundColor: Color(0xFFF5F0FF),
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
