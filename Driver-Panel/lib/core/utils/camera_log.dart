import 'dart:developer' as developer;

/// Debug logging for camera flows.
class CameraLog {
  CameraLog._();

  static const _name = 'CameraModule';

  static void permissionRequest(String permission, String status) {
    developer.log('Permission request: $permission -> $status', name: _name);
  }

  static void initStart({required bool retry}) {
    developer.log('Camera initialization started (retry=$retry)', name: _name);
  }

  static void initSuccess(String cameraName) {
    developer.log('Camera initialized: $cameraName', name: _name);
  }

  static void initFailure(Object error, [StackTrace? stackTrace]) {
    developer.log(
      'Camera initialization failed: $error',
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void captureSuccess(String path) {
    developer.log('Capture success: $path', name: _name);
  }

  static void captureFailure(Object error, [StackTrace? stackTrace]) {
    developer.log(
      'Capture failed: $error',
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void disposeCamera() {
    developer.log('Camera controller disposed', name: _name);
  }

  static void compression(String source, String output, int bytes) {
    developer.log('Image compressed: $source -> $output ($bytes bytes)', name: _name);
  }
}
