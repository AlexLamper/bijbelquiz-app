import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/api/api_client.dart';

import 'admin/admin_fakes.dart';

class _CaptureAdapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The server records where an account signed up and was last seen from the
/// `X-Client-Platform` header (docs/setup/admin-api.md in the web repo).
void main() {
  test('platform value per target', () {
    expect(
      ApiClient.clientPlatformFor(isWeb: false, platform: TargetPlatform.iOS),
      'ios',
    );
    expect(
      ApiClient.clientPlatformFor(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      'android',
    );
    // The web build lets the server read the user agent instead.
    expect(
      ApiClient.clientPlatformFor(isWeb: true, platform: TargetPlatform.iOS),
      isNull,
    );
    expect(
      ApiClient.clientPlatformFor(isWeb: false, platform: TargetPlatform.macOS),
      isNull,
    );
  });

  for (final (platform, value) in [
    (TargetPlatform.iOS, 'ios'),
    (TargetPlatform.android, 'android'),
  ]) {
    test('every request carries X-Client-Platform: $value', () async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final client = ApiClient(FakeAuthStorage('token'));
      final adapter = _CaptureAdapter();
      client.dio.httpClientAdapter = adapter;

      for (final path in ['/login', '/register', '/google-login', '/profile']) {
        await client.dio.post(path, data: const {});
        expect(adapter.last!.headers['X-Client-Platform'], value, reason: path);
      }
      await client.dio.get('/profile');
      expect(adapter.last!.headers['X-Client-Platform'], value);
      expect(adapter.last!.headers['Authorization'], 'Bearer token');
    });
  }

  test('no header on an unknown platform', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final client = ApiClient(FakeAuthStorage());
    final adapter = _CaptureAdapter();
    client.dio.httpClientAdapter = adapter;
    await client.dio.get('/profile');
    expect(adapter.last!.headers.containsKey('X-Client-Platform'), isFalse);
  });
}
