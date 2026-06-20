import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env.dart';

/// Thin Dio wrapper for all backend calls (mirrors cistech core/network).
class ApiClient {
  ApiClient() : _dio = _buildDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Env.baseUrl}${Env.apiPrefix}',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint('[API] $o'),
        ),
      );
    }

    return dio;
  }
}
