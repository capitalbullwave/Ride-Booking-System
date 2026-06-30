import 'package:flutter/material.dart';

/// WaveGo brand color tokens — rides + ambulance mobility.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF31526E);
  static const Color primaryDark = Color(0xFF263F54);
  static const Color primaryLight = Color(0xFF4A6B87);
  static const Color secondary = Color(0xFFD8B39F);
  static const Color secondaryDark = Color(0xFFC49A82);
  static const Color accent = Color(0xFFD8B39F);

  // Semantic
  static const Color success = Color(0xFF5FA87A);
  static const Color warning = Color(0xFFE8A95A);
  static const Color error = Color(0xFFD66B6B);
  static const Color info = Color(0xFF6086A8);

  // Status
  static const Color online = Color(0xFF5FA87A);
  static const Color offline = Color(0xFF6086A8);

  // Surfaces (light)
  static const Color background = Color(0xFFFAF8F4);
  static const Color foreground = Color(0xFF20242C);
  static const Color lightBackground = background;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Muted
  static const Color muted = Color(0xFFE8E4DD);
  static const Color mutedForeground = Color(0xFF6086A8);

  // Text
  static const Color textPrimary = foreground;
  static const Color textSecondary = Color(0xFF6086A8);
  static const Color textLight = Color(0xFF8FA3B8);

  // Borders
  static const Color border = Color(0xFFE8E4DD);
  static const Color divider = Color(0xFFE8E4DD);

  // Dark mode (WaveGo-tinted)
  static const Color darkBackground = Color(0xFF1A2229);
  static const Color darkSurface = Color(0xFF243038);
  static const Color darkCard = Color(0xFF2C3A45);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.35),
      secondary.withValues(alpha: 0.12),
    ],
  );
}
