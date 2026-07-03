import 'package:dio/dio.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);

  final AuthTokenStore _tokenStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _tokenStore.accessToken ?? await _tokenStore.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Retries failed requests once after refreshing the access token on 401.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(
    this._tokenStore,
    this._dio, {
    this.onSessionExpired,
  });

  final AuthTokenStore _tokenStore;
  final Dio _dio;
  final void Function()? onSessionExpired;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;
    if (path.contains(ApiEndpoints.refreshToken) ||
        path.contains(ApiEndpoints.verifyOtp)) {
      return handler.next(err);
    }

    try {
      final refreshToken = await _tokenStore.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        onSessionExpired?.call();
        return handler.next(err);
      }

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final data = response.data;
      final access = data?['access_token'] as String? ?? data?['data']?['access_token'] as String?;
      final refresh = data?['refresh_token'] as String? ?? data?['data']?['refresh_token'] as String? ?? refreshToken;

      if (access == null || access.isEmpty) {
        onSessionExpired?.call();
        return handler.next(err);
      }

      await _tokenStore.setTokens(accessToken: access, refreshToken: refresh);

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $access';
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      onSessionExpired?.call();
      return handler.next(err);
    }
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException();
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
      message = data['message'] as String? ??
          data['error'] as String? ??
          (data['detail'] is String ? data['detail'] as String : null) ??
          message;

      final details = data['details'];
      if (details is List && details.isNotEmpty) {
        final messages = <String>[];
        for (final item in details) {
          if (item is! Map<String, dynamic>) continue;
          final field = item['field'] as String?;
          final detailMessage = item['message'] as String?;
          if (detailMessage == null || detailMessage.isEmpty) continue;
          messages.add(
            field != null && field.isNotEmpty
                ? '$field: $detailMessage'
                : detailMessage,
          );
        }
        if (messages.isNotEmpty) {
          message = messages.take(3).join('\n');
        }
      }
    } else if (data is String && data.isNotEmpty) {
      message = data.length > 120 ? 'Server error. Please try again.' : data;
    }

    if (statusCode == 401) return UnauthorizedException(message);
    if (statusCode == 422) return ValidationException(message);
    if (statusCode >= 500) {
      return ServerException(
        message == 'Something went wrong'
            ? 'Server error. Check that the backend and database are running.'
            : message,
      );
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
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
