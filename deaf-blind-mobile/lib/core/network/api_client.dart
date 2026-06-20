import 'package:dio/dio.dart';

import '../../config/env.dart';

/// Thin Dio wrapper for all backend calls (mirrors cistech core/network).
class ApiClient {
  ApiClient() : _dio = Dio(BaseOptions(baseUrl: '${Env.baseUrl}${Env.apiPrefix}'));

  final Dio _dio;

  Dio get dio => _dio;
}
