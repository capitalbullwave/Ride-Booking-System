import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<Uint8List> readImageBytes(String path) async {
  return File(path).readAsBytes();
}

Future<String> writeCompressedImage(Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final path =
      '${dir.path}/capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(path).writeAsBytes(bytes, flush: true);
  return path;
}
