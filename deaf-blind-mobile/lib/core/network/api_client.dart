import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env.dart';

/// Thin Dio wrapper for all backend calls (mirrors cistech core/network).
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${Env.baseUrl}${Env.apiPrefix}',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint('[API] $o'),
        ),
      );
    }
  }

  late final Dio _dio;
  String? _authToken;

  Dio get dio => _dio;

  void setAuthToken(String? token) => _authToken = token;

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }
}
