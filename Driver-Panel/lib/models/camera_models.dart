import 'package:camera/camera.dart';

enum CameraLensPreference { front, back, any }

enum CameraFailureReason {
  noCamera,
  permissionDenied,
  permissionPermanentlyDenied,
  permissionRestricted,
  permissionLimited,
  cameraInUse,
  initializationFailed,
  captureFailed,
  unavailableOnPlatform,
  browserUnsupported,
  unknown,
}

class CameraPermissionResult {
  const CameraPermissionResult({
    required this.granted,
    this.reason,
  });

  final bool granted;
  final CameraFailureReason? reason;
}

class CameraInitResult {
  const CameraInitResult._({
    required this.success,
    this.controller,
    this.failureReason,
  });

  factory CameraInitResult.success(CameraController controller) {
    return CameraInitResult._(success: true, controller: controller);
  }

  factory CameraInitResult.failure(CameraFailureReason reason) {
    return CameraInitResult._(success: false, failureReason: reason);
  }

  final bool success;
  final CameraController? controller;
  final CameraFailureReason? failureReason;
}

class CameraCaptureResult {
  const CameraCaptureResult({required this.path});

  final String path;
}
