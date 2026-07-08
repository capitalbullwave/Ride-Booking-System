import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/auth/session_manager.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/network/api_interceptors.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._storage, this._sessionManager) {
    assert(() {
      debugPrint('User API base URL: ${AppConfig.baseUrl}');
      return true;
    }());

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      RefreshTokenInterceptor(
        storage: _storage,
        dio: _dio,
        sessionManager: _sessionManager,
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;
  final SecureStorageService _storage;
  final SessionManager _sessionManager;

  Dio get dio => _dio;
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    ref.watch(secureStorageProvider),
    ref.watch(sessionManagerProvider),
  );
});
