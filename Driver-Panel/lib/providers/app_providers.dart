import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/storage/secure_storage_service.dart';
import 'package:wavego_driver/services/location_service.dart';

export 'package:wavego_driver/core/storage/local_storage_service.dart';
export 'package:wavego_driver/core/storage/secure_storage_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
