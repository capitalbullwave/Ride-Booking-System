import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wavego_driver/core/utils/camera_log.dart';
import 'package:wavego_driver/core/utils/image_compressor.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/services/camera_exception_handler.dart';
import 'package:wavego_driver/services/permission_service.dart';

class CameraService {
  CameraService(this._permissionService);

  final PermissionService _permissionService;

  static const Duration _initTimeout = Duration(seconds: 15);

  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get isLivePreviewSupported => _supportsLivePreview;

  bool get _supportsLivePreview {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<CameraInitResult> initialize({
    CameraLensPreference lens = CameraLensPreference.any,
    bool allowRetry = true,
  }) async {
    CameraLog.initStart(retry: !allowRetry);

    if (!_supportsLivePreview) {
      return CameraInitResult.failure(CameraFailureReason.unavailableOnPlatform);
    }

    final permission = await _permissionService.ensureCameraAccess();
    if (!permission.granted) {
      return CameraInitResult.failure(
        permission.reason ?? CameraFailureReason.permissionDenied,
      );
    }

    try {
      final cameras = await availableCameras().timeout(_initTimeout);
      if (cameras.isEmpty) {
        return CameraInitResult.failure(CameraFailureReason.noCamera);
      }

      final selected = _selectCamera(cameras, lens);
      await _controller?.dispose();
      _controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize().timeout(_initTimeout);
      CameraLog.initSuccess(selected.name);
      return CameraInitResult.success(_controller!);
    } on TimeoutException catch (error, stackTrace) {
      CameraLog.initFailure(error, stackTrace);
      if (allowRetry) {
        return initialize(lens: lens, allowRetry: false);
      }
      return CameraInitResult.failure(CameraFailureReason.initializationFailed);
    } on CameraException catch (error, stackTrace) {
      CameraLog.initFailure(error, stackTrace);
      if (allowRetry) {
        return initialize(lens: lens, allowRetry: false);
      }
      return CameraInitResult.failure(
        CameraExceptionHandler.fromCameraException(error),
      );
    } on PlatformException catch (error, stackTrace) {
      CameraLog.initFailure(error, stackTrace);
      if (allowRetry) {
        return initialize(lens: lens, allowRetry: false);
      }
      return CameraInitResult.failure(
        CameraExceptionHandler.fromPlatformException(error),
      );
    } catch (error, stackTrace) {
      CameraLog.initFailure(error, stackTrace);
      if (allowRetry) {
        return initialize(lens: lens, allowRetry: false);
      }
      return CameraInitResult.failure(CameraExceptionHandler.from(error));
    }
  }

  Future<CameraCaptureResult> capturePhoto() async {
    final active = _controller;
    if (active == null || !active.value.isInitialized) {
      throw StateError('Camera is not initialized');
    }

    try {
      final photo = await active.takePicture();
      final outputPath = await _processCapturedFile(photo);
      CameraLog.captureSuccess(outputPath);
      return CameraCaptureResult(path: outputPath);
    } on CameraException catch (error, stackTrace) {
      CameraLog.captureFailure(error, stackTrace);
      throw CameraFailureReason.captureFailed;
    } catch (error, stackTrace) {
      CameraLog.captureFailure(error, stackTrace);
      rethrow;
    }
  }

  Future<String> _processCapturedFile(XFile file) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final compressed = await ImageCompressor.compressBytes(bytes);
      if (compressed.length == bytes.length) {
        return file.path;
      }
      return file.path;
    }
    return ImageCompressor.compressFromPath(file.path);
  }

  Future<void> dispose() async {
    final active = _controller;
    _controller = null;
    if (active != null) {
      await active.dispose();
      CameraLog.disposeCamera();
    }
  }

  CameraDescription _selectCamera(
    List<CameraDescription> cameras,
    CameraLensPreference lens,
  ) {
    if (lens == CameraLensPreference.front) {
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    }
    if (lens == CameraLensPreference.back) {
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    }
    return cameras.first;
  }
}
