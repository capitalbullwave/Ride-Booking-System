import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Auto-detects blink / smile / head-turn from the live camera stream (mobile).
class LivenessFaceTracker {
  LivenessFaceTracker();

  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );

  bool _busy = false;
  bool _sawEyesClosed = false;
  bool _blinkDone = false;
  bool _smileDone = false;
  bool _sawTurned = false;
  bool _headTurnDone = false;

  bool get supportsAutoDetect =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void reset() {
    _sawEyesClosed = false;
    _blinkDone = false;
    _smileDone = false;
    _sawTurned = false;
    _headTurnDone = false;
  }

  Future<void> dispose() => _detector.close();

  Future<String?> processCameraImage(
    CameraImage image,
    CameraDescription camera, {
    required String expectedAction,
  }) async {
    if (!supportsAutoDetect || _busy) return null;
    _busy = true;
    try {
      final input = _toInputImage(image, camera);
      if (input == null) return null;
      final faces = await _detector.processImage(input);
      if (faces.isEmpty || faces.length > 1) return null;

      final face = faces.first;
      switch (expectedAction) {
        case 'blink':
          return _trackBlink(face) ? 'blink' : null;
        case 'smile':
          return _trackSmile(face) ? 'smile' : null;
        case 'head_turn':
          return _trackHeadTurn(face) ? 'head_turn' : null;
        default:
          return null;
      }
    } catch (_) {
      return null;
    } finally {
      _busy = false;
    }
  }

  bool _trackBlink(Face face) {
    if (_blinkDone) return false;
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) return false;

    final closed = left < 0.35 && right < 0.35;
    final open = left > 0.65 && right > 0.65;
    if (closed) {
      _sawEyesClosed = true;
      return false;
    }
    if (_sawEyesClosed && open) {
      _blinkDone = true;
      return true;
    }
    return false;
  }

  bool _trackSmile(Face face) {
    if (_smileDone) return false;
    final smile = face.smilingProbability;
    if (smile != null && smile > 0.55) {
      _smileDone = true;
      return true;
    }
    return false;
  }

  bool _trackHeadTurn(Face face) {
    if (_headTurnDone) return false;
    final y = face.headEulerAngleY;
    if (y == null) return false;
    if (y.abs() > 16) {
      _sawTurned = true;
      return false;
    }
    if (_sawTurned && y.abs() < 8) {
      _headTurnDone = true;
      return true;
    }
    return false;
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.isEmpty) return null;

    final plane = image.planes.first;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    if (image.planes.length == 1 || isAndroid) {
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }

    final WriteBuffer allBytes = WriteBuffer();
    for (final p in image.planes) {
      allBytes.putUint8List(p.bytes);
    }
    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
