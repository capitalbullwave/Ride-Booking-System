import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:wavego_driver/core/utils/camera_log.dart';

import 'image_compressor_io.dart'
    if (dart.library.html) 'image_compressor_web.dart' as impl;

class ImageCompressor {
  ImageCompressor._();

  static const int defaultQuality = 85;
  static const int defaultMaxWidth = 1920;

  static Future<String> compressFromPath(
    String sourcePath, {
    int quality = defaultQuality,
    int maxWidth = defaultMaxWidth,
  }) async {
    if (kIsWeb) return sourcePath;

    final bytes = await impl.readImageBytes(sourcePath);
    final compressed = await compressBytes(
      bytes,
      quality: quality,
      maxWidth: maxWidth,
    );
    final outputPath = await impl.writeCompressedImage(compressed);
    CameraLog.compression(sourcePath, outputPath, compressed.length);
    return outputPath;
  }

  static Future<Uint8List> compressBytes(
    Uint8List bytes, {
    int quality = defaultQuality,
    int maxWidth = defaultMaxWidth,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
}
