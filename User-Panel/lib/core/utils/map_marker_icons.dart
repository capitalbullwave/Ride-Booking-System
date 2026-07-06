import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';

class MapMarkerIcons {
  MapMarkerIcons._();

  static final _cache = <String, BitmapDescriptor>{};

  static Future<BitmapDescriptor> vehicleMarker(String? slug) async {
    final key = (slug ?? 'cab').toLowerCase();
    final cached = _cache[key];
    if (cached != null) return cached;

    BitmapDescriptor? icon;
    try {
      icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(72, 72)),
        vehicleImageAssetForSlug(key),
      );
    } catch (_) {}

    icon ??= await _iconMarker(vehicleIconForSlug(key));
    _cache[key] = icon;
    return icon;
  }

  static Future<BitmapDescriptor> _iconMarker(IconData iconData) async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(48, 48), 38, shadowPaint);

    canvas.drawCircle(const Offset(48, 48), 34, Paint()..color = Colors.white);
    canvas.drawCircle(
      const Offset(48, 48),
      34,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 34,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: AppColors.primary,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(48 - textPainter.width / 2, 48 - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
