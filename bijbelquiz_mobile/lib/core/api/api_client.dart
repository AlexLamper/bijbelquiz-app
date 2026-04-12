import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/auth_local_storage.dart';

class ApiClient {
  late final Dio dio;
  final AuthLocalStorage _storage;

  static const String baseUrl = 'http://localhost:3000/api/mobile';

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
