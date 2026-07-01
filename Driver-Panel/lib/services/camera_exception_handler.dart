import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:wavego_driver/core/constants/camera_strings.dart';
import 'package:wavego_driver/models/camera_models.dart';

class CameraExceptionHandler {
  CameraExceptionHandler._();

  static CameraFailureReason from(Object error) {
    if (error is CameraException) {
      return fromCameraException(error);
    }
    if (error is PlatformException) {
      return fromPlatformException(error);
    }
    final message = error.toString().toLowerCase();
    if (message.contains('notfound') || message.contains('no camera')) {
      return CameraFailureReason.noCamera;
    }
    if (message.contains('in use') || message.contains('busy')) {
      return CameraFailureReason.cameraInUse;
    }
    if (message.contains('permission') || message.contains('denied')) {
      return CameraFailureReason.permissionDenied;
    }
    return CameraFailureReason.unknown;
  }

  static CameraFailureReason fromCameraException(CameraException error) {
    final code = error.code.toLowerCase();
    final description = (error.description ?? '').toLowerCase();

    if (code.contains('cameranotfound') || description.contains('no camera')) {
      return CameraFailureReason.noCamera;
    }
    if (code.contains('cameradisabled') ||
        code.contains('permission') ||
        description.contains('permission')) {
      return CameraFailureReason.permissionDenied;
    }
    if (description.contains('in use') || description.contains('busy')) {
      return CameraFailureReason.cameraInUse;
    }
    return CameraFailureReason.initializationFailed;
  }

  static CameraFailureReason fromPlatformException(PlatformException error) {
    final code = (error.code).toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code.contains('camera_access_denied') || message.contains('denied')) {
      return CameraFailureReason.permissionDenied;
    }
    if (message.contains('not found') || message.contains('no camera')) {
      return CameraFailureReason.noCamera;
    }
    if (message.contains('in use')) {
      return CameraFailureReason.cameraInUse;
    }
    return CameraFailureReason.initializationFailed;
  }

  static String messageFor(CameraFailureReason reason) {
    return switch (reason) {
      CameraFailureReason.noCamera => CameraStrings.noCameraDetected,
      CameraFailureReason.permissionDenied => CameraStrings.permissionDenied,
      CameraFailureReason.permissionPermanentlyDenied =>
        CameraStrings.permissionPermanentlyDenied,
      CameraFailureReason.permissionRestricted =>
        CameraStrings.permissionRestricted,
      CameraFailureReason.permissionLimited => CameraStrings.permissionLimited,
      CameraFailureReason.cameraInUse => CameraStrings.cameraInUse,
      CameraFailureReason.initializationFailed =>
        CameraStrings.initializationFailed,
      CameraFailureReason.captureFailed => CameraStrings.captureFailed,
      CameraFailureReason.unavailableOnPlatform =>
        CameraStrings.unavailableOnPlatform,
      CameraFailureReason.browserUnsupported =>
        CameraStrings.browserUnsupported,
      CameraFailureReason.unknown => CameraStrings.genericError,
    };
  }

  static bool canOpenSettings(CameraFailureReason reason) {
    return reason == CameraFailureReason.permissionDenied ||
        reason == CameraFailureReason.permissionPermanentlyDenied ||
        reason == CameraFailureReason.permissionLimited;
  }
}
