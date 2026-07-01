/// User-facing copy for camera and media capture flows.
class CameraStrings {
  CameraStrings._();

  static const String takeSelfieTitle = 'Take Selfie';
  static const String capturePhotoTitle = 'Capture Photo';
  static const String captureDocumentTitle = 'Capture Document';

  static const String initializingCamera = 'Initializing camera...';
  static const String positionFaceHint = 'Position your face in the frame';
  static const String alignDocumentHint = 'Align the document within the frame';

  static const String capturePhoto = 'Capture Photo';
  static const String capturing = 'Capturing...';
  static const String retake = 'Retake';
  static const String usePhoto = 'Use Photo';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String openSettings = 'Open Settings';

  static const String chooseSourceTitle = 'Add Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';

  static const String noCameraDetected = 'No camera detected on this device.';
  static const String permissionDenied =
      'Camera permission denied. Allow camera access to continue.';
  static const String permissionPermanentlyDenied =
      'Camera permission is permanently denied. Open settings to enable it.';
  static const String permissionRestricted =
      'Camera access is restricted on this device.';
  static const String permissionLimited =
      'Limited photo access granted. Full camera access may be required.';
  static const String cameraInUse =
      'Camera is already in use by another application.';
  static const String initializationFailed =
      'Camera initialization failed. Please try again.';
  static const String captureFailed =
      'Failed to capture photo. Please try again.';
  static const String unavailableOnPlatform =
      'Live camera preview is not supported on this platform. Use gallery instead.';
  static const String browserUnsupported =
      'This browser does not support camera access. Try Chrome or Edge on HTTPS/localhost.';
  static const String genericError =
      'Camera is unavailable right now. Please try again.';

  static const String compressingImage = 'Processing image...';
}
