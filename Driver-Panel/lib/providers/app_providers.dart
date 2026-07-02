import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wavego_driver/services/location_service.dart';
import 'package:wavego_driver/services/permission_service.dart';

export 'package:wavego_driver/core/storage/auth_token_store.dart';
export 'package:wavego_driver/core/storage/local_storage_service.dart';
export 'package:wavego_driver/core/storage/secure_storage_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
