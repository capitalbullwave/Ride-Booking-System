import 'package:flutter/material.dart';

/// Bull Wave Rides brand color tokens — aligned with User-Panel-website.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF73398F);
  static const Color primaryDark = Color(0xFF5C2D72);
  static const Color primaryLight = Color(0xFF7346F4);
  static const Color secondary = Color(0xFFC45CF7);
  static const Color secondaryDark = Color(0xFF7346F4);
  static const Color accent = Color(0xFFC45CF7);

  // Semantic
  static const Color success = Color(0xFF5FA87A);
  static const Color warning = Color(0xFFE8A95A);
  static const Color error = Color(0xFFD66B6B);
  static const Color info = Color(0xFFA47EB6);

  // Status
  static const Color online = Color(0xFF5FA87A);
  static const Color offline = Color(0xFFA47EB6);

  // Surfaces (light)
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF73398F);
  static const Color lightBackground = background;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Muted
  static const Color muted = Color(0xFFF5F0FF);
  static const Color mutedForeground = Color(0xFFA47EB6);

  // Text
  static const Color textPrimary = foreground;
  static const Color textSecondary = Color(0xFFA47EB6);
  static const Color textLight = Color(0xFFC4A8D4);

  // Borders
  static const Color border = Color(0xFFEBE4F7);
  static const Color divider = Color(0xFFEBE4F7);

  // Dark mode
  static const Color darkBackground = Color(0xFF060D24);
  static const Color darkSurface = Color(0xFF0A1538);
  static const Color darkCard = Color(0xFF0D1A42);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primaryLight],
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
