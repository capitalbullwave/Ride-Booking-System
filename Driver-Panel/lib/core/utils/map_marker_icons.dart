import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Custom map markers — web-safe (defaultMarkerWithHue often stays red on web).
class MapMarkerIcons {
  MapMarkerIcons._();

  static final _cache = <String, BitmapDescriptor>{};

  static Future<BitmapDescriptor> pickupLabeledMarker() =>
      _compactSpotMarker(
        cacheKey: 'driver_pickup_v1',
        label: 'Pickup',
        accent: const Color(0xFF16A34A),
      );

  static Future<BitmapDescriptor> dropoffLabeledMarker() =>
      _compactSpotMarker(
        cacheKey: 'driver_drop_v1',
        label: 'Drop',
        accent: const Color(0xFFEF4444),
      );

  /// Blue "you are here" dot — web-safe alternative to defaultMarkerWithHue.
  static Future<BitmapDescriptor> selfMarker() async {
    const key = 'driver_self_v1';
    final cached = _cache[key];
    if (cached != null) return cached;

    const pixelRatio = 3.0;
    const logical = 28.0;
    final size = (logical * pixelRatio).toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);

    final center = const Offset(logical / 2, logical / 2);
    canvas.drawCircle(
      center,
      11,
      Paint()..color = const Color(0x401A73E8),
    );
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5.2, Paint()..color = const Color(0xFF1A73E8));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
      width: logical,
      height: logical,
    );
    _cache[key] = icon;
    return icon;
  }

  static Future<BitmapDescriptor> _compactSpotMarker({
    required String cacheKey,
    required String label,
    required Color accent,
  }) async {
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    const pixelRatio = 3.0;
    const logicalW = 52.0;
    const logicalH = 62.0;
    final w = (logicalW * pixelRatio).toInt();
    final h = (logicalH * pixelRatio).toInt();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);

    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      )
      ..layout();

    final chipW = tp.width + 12;
    final chipH = tp.height + 7;
    final chipLeft = (logicalW - chipW) / 2;
    const chipTop = 1.0;
    final chip = RRect.fromRectAndRadius(
      Rect.fromLTWH(chipLeft, chipTop, chipW, chipH),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      chip.shift(const Offset(0, 1)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawRRect(chip, Paint()..color = accent);
    tp.paint(
      canvas,
      Offset(chipLeft + 6, chipTop + (chipH - tp.height) / 2),
    );

    final midX = logicalW / 2;
    final tipY = chipTop + chipH;
    final pointer = Path()
      ..moveTo(midX - 4, tipY)
      ..lineTo(midX + 4, tipY)
      ..lineTo(midX, tipY + 4.5)
      ..close();
    canvas.drawPath(pointer, Paint()..color = accent);

    const spotY = 56.0;
    final spot = Offset(midX, spotY);
    canvas.drawCircle(
      spot.translate(0, 1),
      6,
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawCircle(spot, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(spot, 4.2, Paint()..color = accent);
    canvas.drawCircle(spot, 1.6, Paint()..color = Colors.white);

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
      width: logicalW,
      height: logicalH,
    );
    _cache[cacheKey] = icon;
    return icon;
  }
}
