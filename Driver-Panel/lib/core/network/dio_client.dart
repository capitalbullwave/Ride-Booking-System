import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/network/api_interceptors.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';

class DioClient {
  DioClient(this._tokenStore) {
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
      TokenRefreshInterceptor(_tokenStore, _dio),
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
  return DioClient(ref.watch(authTokenStoreProvider));
});
