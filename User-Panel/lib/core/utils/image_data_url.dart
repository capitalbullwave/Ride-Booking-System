import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<String?> imageXFileToDataUrl(XFile? file) async {
  if (file == null) return null;

  try {
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    final mime = _mimeFromPath(file.path);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  } catch (_) {
    return null;
  }
}

String _mimeFromPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}
