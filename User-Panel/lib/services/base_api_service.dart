import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/network/api_exception.dart';

class BaseApiService {
  BaseApiService(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters), parser);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    return _request(
      () => _dio.post(
        path,
        data: data,
        options: Options(
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
      ),
      parser,
    );
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(() => _dio.put(path, data: data), parser);
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic data)? parser,
  }) async {
    return _request(() => _dio.delete(path), parser);
  }

  Future<T> upload<T>(
    String path, {
    required FormData formData,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.post(path, data: formData),
      parser,
    );
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data)? parser,
  ) async {
    try {
      final response = await request();
      final data = response.data;

      if (parser != null) {
        return parser(data);
      }
      return data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadMockJson(String fileName) async {
    final jsonString = await rootBundle.loadString('assets/mock/$fileName');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<List<dynamic>> loadMockJsonList(String fileName) async {
    final jsonString = await rootBundle.loadString('assets/mock/$fileName');
    return jsonDecode(jsonString) as List<dynamic>;
  }

  bool get useMock => AppConfig.enableMockApi;
}
