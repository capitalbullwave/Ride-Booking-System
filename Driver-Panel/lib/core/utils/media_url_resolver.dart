import 'package:wavego_driver/core/config/app_config.dart';

/// Resolves backend-relative upload paths to a full URL for image widgets.
String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('data:')) {
    return path;
  }
  final origin = AppConfig.baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
  if (path.startsWith('/')) return '$origin$path';
  return '$origin/$path';
}

bool isLocalFilePath(String? path) {
  if (path == null || path.isEmpty) return false;
  return !path.startsWith('http://') &&
      !path.startsWith('https://') &&
      !path.startsWith('/uploads/') &&
      !path.startsWith('data:');
}

bool hasUploadedMedia(String? path) => path != null && path.isNotEmpty;
