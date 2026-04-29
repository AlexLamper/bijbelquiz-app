import 'package:flutter/foundation.dart';

/// Environment-based configuration for API endpoints
/// Automatically switches between development and production based on build mode
class AppConfig {
  // Production API endpoints
  static const String _productionBaseUrl =
      'https://www.bijbelquiz.com/api/mobile';

  // Development API endpoints (localhost)
  static const String _developmentBaseUrl = 'http://localhost:3000/api/mobile';

  // Optional dart-define overrides:
  // --dart-define=API_BASE_URL=https://www.bijbelquiz.com/api/mobile
  static const String _apiBaseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Optional convenience toggle:
  // --dart-define=USE_PRODUCTION_API=true
  static const bool _useProductionApiFromDefine = bool.fromEnvironment(
    'USE_PRODUCTION_API',
    defaultValue: false,
  );

  /// Get the appropriate API base URL based on build mode
  /// Debug builds use localhost for local development
  /// Release builds use production URL
  static String get apiBaseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) {
      return _apiBaseUrlFromDefine;
    }

    if (kDebugMode) {
      if (_useProductionApiFromDefine) {
        return _productionBaseUrl;
      }

      // Development mode - use localhost by default
      return _developmentBaseUrl;
    } else {
      // Production/Release mode - use production URL
      return _productionBaseUrl;
    }
  }

  /// Get the base URL without /api/mobile suffix
  /// Used for constructing image URLs and other resources
  static String get baseUrl {
    final apiUri = Uri.parse(effectiveApiBaseUrl);
    final authority = apiUri.hasPort
        ? '${apiUri.host}:${apiUri.port}'
        : apiUri.host;
    return '${apiUri.scheme}://$authority';
  }

  /// Returns whether app is in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Returns whether app is in production/release mode
  static bool get isProduction => !kDebugMode;

  /// For testing purposes: override the API URL
  static String? _customApiBaseUrl;

  /// Set a custom API base URL (useful for testing against different servers)
  static void setCustomApiBaseUrl(String? url) {
    _customApiBaseUrl = url;
  }

  /// Get the actual API URL to use (respects custom override)
  static String get effectiveApiBaseUrl => _customApiBaseUrl ?? apiBaseUrl;
}
