import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:wavego_driver/core/utils/camera_log.dart';
import 'package:wavego_driver/models/camera_models.dart';

class PermissionService {
  Future<CameraPermissionResult> ensureCameraAccess() async {
    if (kIsWeb) {
      CameraLog.permissionRequest('camera', 'web-browser-prompt');
      return const CameraPermissionResult(granted: true);
    }

    final status = await _requestCameraPermission();
    CameraLog.permissionRequest('camera', status.name);

    if (status.isGranted) {
      return const CameraPermissionResult(granted: true);
    }
    if (status.isPermanentlyDenied) {
      return const CameraPermissionResult(
        granted: false,
        reason: CameraFailureReason.permissionPermanentlyDenied,
      );
    }
    if (status.isRestricted) {
      return const CameraPermissionResult(
        granted: false,
        reason: CameraFailureReason.permissionRestricted,
      );
    }
    if (status.isLimited) {
      return const CameraPermissionResult(
        granted: false,
        reason: CameraFailureReason.permissionLimited,
      );
    }
    return const CameraPermissionResult(
      granted: false,
      reason: CameraFailureReason.permissionDenied,
    );
  }

  Future<CameraPermissionResult> ensureGalleryAccess() async {
    if (kIsWeb) {
      return const CameraPermissionResult(granted: true);
    }

    permission_handler.Permission permission =
        permission_handler.Permission.photos;
    var status = await permission.status;
    if (!status.isGranted && !status.isLimited) {
      status = await permission.request();
    }

    if (status.isGranted || status.isLimited) {
      CameraLog.permissionRequest('photos', status.name);
      return const CameraPermissionResult(granted: true);
    }

    final storageStatus = await permission_handler.Permission.storage.request();
    CameraLog.permissionRequest('storage', storageStatus.name);
    if (storageStatus.isGranted) {
      return const CameraPermissionResult(granted: true);
    }

    if (status.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
      return const CameraPermissionResult(
        granted: false,
        reason: CameraFailureReason.permissionPermanentlyDenied,
      );
    }

    return const CameraPermissionResult(
      granted: false,
      reason: CameraFailureReason.permissionDenied,
    );
  }

  Future<bool> openSettings() => permission_handler.openAppSettings();

  Future<bool> requestLocation() async {
    final status = await permission_handler.Permission.location.request();
    return status.isGranted;
  }

  Future<permission_handler.PermissionStatus> _requestCameraPermission() async {
    var status = await permission_handler.Permission.camera.status;
    if (status.isGranted) return status;
    return permission_handler.Permission.camera.request();
  }
}
