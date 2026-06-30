import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

/// Forces a mobile-phone viewport. On desktop/web, renders inside a centered
/// phone frame so the UI always matches a real device.
class PhoneModeShell extends StatelessWidget {
  const PhoneModeShell({super.key, required this.child});

  final Widget child;

  static const double phoneWidth = 390;
  static const double phoneMaxHeight = 844;

  static bool get isPhonePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    if (isPhonePlatform) return child;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final frameHeight = (screenHeight * 0.92).clamp(640.0, phoneMaxHeight);

    return ColoredBox(
      color: AppColors.foreground,
      child: Center(
        child: Container(
          width: phoneWidth,
          height: frameHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(phoneWidth, frameHeight),
              padding: EdgeInsets.zero,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
