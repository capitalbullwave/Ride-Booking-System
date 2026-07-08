import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

/// Bull Wave Rides typography — Satoshi headings, Inter body.
class AppTypography {
  AppTypography._();

  static const String headingFamily = 'Satoshi';
  static const String bodyFamily = 'Inter';

  static TextTheme waveGoTextTheme(TextTheme base, {required bool isDark}) {
    final bodyColor = isDark ? Colors.white : AppColors.foreground;
    final mutedColor = isDark ? AppColors.textLight : AppColors.mutedForeground;

    TextStyle heading(TextStyle? style) => (style ?? const TextStyle()).copyWith(
          fontFamily: headingFamily,
          fontWeight: FontWeight.w700,
          color: bodyColor,
          letterSpacing: -0.3,
        );

    TextStyle body(TextStyle? style) => (style ?? const TextStyle()).copyWith(
          fontFamily: bodyFamily,
          color: bodyColor,
        );

    return base.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
      titleLarge: heading(base.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      titleMedium: body(base.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      titleSmall: body(base.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: body(base.bodySmall?.copyWith(color: mutedColor)),
      labelLarge: body(base.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      labelMedium: body(base.labelMedium?.copyWith(color: mutedColor)),
      labelSmall: body(base.labelSmall?.copyWith(color: mutedColor)),
    );
  }
}
