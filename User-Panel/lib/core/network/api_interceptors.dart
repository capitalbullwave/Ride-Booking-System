import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wavego_user/core/auth/session_manager.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/network/api_exception.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// On 401, exchanges the refresh token for a new access token and retries once.
class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required SecureStorageService storage,
    required Dio dio,
    required SessionManager sessionManager,
  })  : _storage = storage,
        _dio = dio,
        _sessionManager = sessionManager;

  final SecureStorageService _storage;
  final Dio _dio;
  final SessionManager _sessionManager;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  static const _skipRefreshPaths = [
    '/auth/refresh-token',
    '/auth/verify-otp',
    '/auth/send-otp',
    '/auth/login',
    '/auth/register',
    '/auth/logout',
  ];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    if (status != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (_skipRefreshPaths.any(path.contains) ||
        err.requestOptions.extra['skip_session_expire'] == true) {
      handler.next(err);
      return;
    }

    if (err.requestOptions.extra['retried_after_refresh'] == true) {
      await _handleSessionExpired(handler, err);
      return;
    }

    try {
      final refreshed = await _refreshTokens();
      if (!refreshed) {
        await _handleSessionExpired(handler, err);
        return;
      }

      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  Future<bool> _refreshTokens() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future ?? Future.value(false);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skip_refresh': true}),
      );

      final data = response.data;
      final access = data?['access_token'] as String?;
      final refresh = data?['refresh_token'] as String?;

      if (access == null || access.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      await _storage.write(AppConstants.accessTokenKey, access);
      if (refresh != null && refresh.isNotEmpty) {
        await _storage.write(AppConstants.refreshTokenKey, refresh);
      }

      _refreshCompleter!.complete(true);
      return true;
    } catch (_) {
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      extra: {...requestOptions.extra, 'retried_after_refresh': true},
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  Future<void> _handleSessionExpired(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    await _storage.delete(AppConstants.accessTokenKey);
    await _storage.delete(AppConstants.refreshTokenKey);
    _sessionManager.notifySessionExpired();

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: const UnauthorizedException(),
      ),
    );
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _mapDioError(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Cannot reach server. Start backend on PC (0.0.0.0:8000) and use HOST_IP for real phone.',
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      default:
        return ApiException(message: error.message ?? 'Something went wrong');
    }
  }

  ApiException _handleResponseError(Response<dynamic>? response) {
    if (response == null) {
      return const ServerException();
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    String message = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      message = data['message'] as String? ??
          data['error'] as String? ??
          (detail is String ? detail : message);
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    if (statusCode == 401) return UnauthorizedException(message);
    if (statusCode == 422) return ValidationException(message);
    if (statusCode >= 500) return ServerException(message);

    return ApiException(message: message, statusCode: statusCode);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.baseUrl = AppConfig.baseUrl;
    assert(() {
      debugPrint('API ${options.method} ${options.baseUrl}${options.path}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
