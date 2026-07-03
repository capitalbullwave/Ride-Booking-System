import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';

class BaseApiService {
  BaseApiService(this._dio, this._tokenStore);

  final Dio _dio;
  final AuthTokenStore _tokenStore;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      parser,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.post(path, data: data, options: options),
      parser,
    );
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.put(path, data: data, options: options),
      parser,
    );
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.patch(path, data: data, options: options),
      parser,
    );
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.delete(path, options: options),
      parser,
    );
  }

  Future<T> upload<T>(
    String path, {
    required FormData formData,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      (options) => _dio.post(path, data: formData, options: options),
      parser,
    );
  }

  Future<Options> _authOptions() async {
    final token = _tokenStore.accessToken ?? await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) {
      return Options();
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function(Options options) request,
    T Function(dynamic data)? parser,
  ) async {
    try {
      final response = await request(await _authOptions());
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
