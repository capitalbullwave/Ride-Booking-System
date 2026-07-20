import 'package:camera/camera.dart';

/// Web / unsupported platforms — no ML Kit. Manual Continue is used.
class LivenessFaceTracker {
  bool get supportsAutoDetect => false;

  void reset() {}

  Future<void> dispose() async {}

  Future<String?> processCameraImage(
    CameraImage image,
    CameraDescription camera, {
    required String expectedAction,
  }) async {
    return null;
  }
}
