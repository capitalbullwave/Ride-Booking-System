import 'dart:typed_data';

Future<Uint8List> readImageBytes(String path) {
  throw UnsupportedError('readImageBytes is unavailable on web');
}

Future<String> writeCompressedImage(Uint8List bytes) {
  throw UnsupportedError('writeCompressedImage is unavailable on web');
}
