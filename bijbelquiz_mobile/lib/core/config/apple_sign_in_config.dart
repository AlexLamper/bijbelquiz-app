class AppleSignInConfig {
  // Apple Services ID (Identifier type: Services ID), e.g. com.bijbelquiz.app.signin
  // Pass via: --dart-define=APPLE_SERVICE_ID=...
  static const String serviceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
    defaultValue: '',
  );

  // Redirect URI configured on the Apple Services ID, e.g.
  // https://www.bijbelquiz.com/api/mobile/apple/callback
  // Pass via: --dart-define=APPLE_REDIRECT_URI=...
  static const String redirectUriRaw = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: '',
  );

  static Uri? get redirectUri {
    if (redirectUriRaw.isEmpty) return null;
    return Uri.tryParse(redirectUriRaw);
  }

  static bool get hasWebFallbackConfig {
    return serviceId.isNotEmpty && redirectUri != null;
  }
}
