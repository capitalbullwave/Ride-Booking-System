import 'package:dio/dio.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/storage/secure_storage_service.dart';

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
          data['detail'] as String? ??
          message;
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
