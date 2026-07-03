import 'package:wavego_user/core/config/app_config.dart';

bool isMediaUrl(String? value) {
  if (value == null || value.isEmpty) return false;
  return value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('/uploads/');
}

String? resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  final base = AppConfig.baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}
