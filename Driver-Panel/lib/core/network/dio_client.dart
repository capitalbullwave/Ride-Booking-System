import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/network/api_interceptors.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/providers/auth_session_provider.dart';

class DioClient {
  DioClient(
    this._tokenStore, {
    void Function()? onSessionExpired,
  }) {
    assert(() {
      debugPrint('Driver API base URL: ${AppConfig.baseUrl}');
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
      AuthInterceptor(_tokenStore),
      TokenRefreshInterceptor(
        _tokenStore,
        _dio,
        onSessionExpired: onSessionExpired,
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;
  final AuthTokenStore _tokenStore;

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  ref.keepAlive();
  return DioClient(
    ref.watch(authTokenStoreProvider),
    onSessionExpired: () {
      ref.read(authSessionProvider.notifier).expireSession();
    },
  );
});
