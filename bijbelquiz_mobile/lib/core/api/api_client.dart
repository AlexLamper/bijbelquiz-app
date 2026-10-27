import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/auth_local_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio dio;
  final AuthLocalStorage _storage;

  static String get baseUrl => AppConfig.effectiveApiBaseUrl;

  /// Header the server reads to record where an account was created and
  /// last seen (see docs/setup/admin-api.md in the web repo).
  static const String platformHeader = 'X-Client-Platform';

  /// `ios` / `android` for the native apps. Null on the web build and on
  /// desktop: the server then falls back to the browser's user agent, and an
  /// extra custom header would only add a CORS preflight to every request.
  static String? clientPlatformFor({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb) return null;
    return switch (platform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => null,
    };
  }

  static String? get clientPlatform =>
      clientPlatformFor(isWeb: kIsWeb, platform: defaultTargetPlatform);

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (clientPlatform != null) platformHeader: clientPlatform,
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
