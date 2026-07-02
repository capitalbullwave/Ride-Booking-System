import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:wavego_driver/core/utils/image_compressor.dart';

/// Converts a local file path or blob URL into a base64 data URL for the API.
Future<String?> imagePathToDataUrl(String? path) async {
  if (path == null || path.trim().isEmpty) return null;

  final value = path.trim();
  if (value.startsWith('data:image')) return value;
  if (value.startsWith('http') && !value.startsWith('blob:')) return value;

  try {
    final bytes = await XFile(value).readAsBytes();
    if (bytes.isEmpty) return null;
    final compressed = await ImageCompressor.compressBytes(bytes);
    return 'data:image/jpeg;base64,${base64Encode(compressed)}';
  } catch (_) {
    return null;
  }
}
