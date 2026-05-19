import 'package:flutter/foundation.dart';

/// RevenueCat **SDK (public) API keys** for the Purchases Flutter SDK.
///
/// These are **not** the same as server secrets. RevenueCat expects you to ship
/// the platform-specific public key inside the mobile app. Anyone can extract
/// them from the binary; security for purchases comes from Apple/Google +
/// RevenueCat validation, not from hiding this string.
///
/// To avoid committing real keys to git, pass them at **build/run time**:
///
/// ```bash
/// flutter run --dart-define=REVENUECAT_APPLE_KEY=appl_xxx --dart-define=REVENUECAT_GOOGLE_KEY=goog_xxx
/// ```
///
/// **Test Store** (no App Store / Play setup yet): use one key for both:
///
/// ```bash
/// flutter run --dart-define=REVENUECAT_TEST_KEY=test_xxx
/// ```
///
/// CI: prefer injecting keys with `--dart-define=...` (e.g. GitHub Actions secrets)
/// so you can rotate without a code change.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// Public RevenueCat **iOS** SDK key (`appl_...`) for this app.
  /// Safe to embed; override at build time with `--dart-define=REVENUECAT_APPLE_KEY=...`.
  static const String _defaultApplePublicKey =
      'appl_YqUIguFZVKmAqXdCYaRNThVjmiI';

  /// Public RevenueCat **Android** SDK key (`goog_...`) for this app.
  /// Safe to embed; override at build time with `--dart-define=REVENUECAT_GOOGLE_KEY=...`.
  static const String _defaultGooglePublicKey =
      'goog_PpgkHtnCyRmGavtvaqDGjZNHMFD';

  /// Optional: RevenueCat **Test Store** key (`test_...`) for early integration
  /// testing before iOS/Android store apps are linked.
  static const String testKey = String.fromEnvironment(
    'REVENUECAT_TEST_KEY',
    defaultValue: '',
  );

  static const String appleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: _defaultApplePublicKey,
  );

  static const String googleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: _defaultGooglePublicKey,
  );

  /// Set true only when you explicitly want to run against RevenueCat Test Store.
  static const bool useTestStore = bool.fromEnvironment(
    'REVENUECAT_USE_TEST_STORE',
    defaultValue: false,
  );

  static bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Human-readable source for diagnostics/logging.
  static String sdkKeySource() {
    if (kIsWeb) return 'none:web';
    if (useTestStore && testKey.isNotEmpty) return 'test_store';
    if (_isApplePlatform) return appleKey.isNotEmpty ? 'apple' : 'none:apple';
    return googleKey.isNotEmpty ? 'google' : 'none:google';
  }

  /// Key used by [Purchases.configure] in [main.dart].
  static String sdkPublicApiKey() {
    if (kIsWeb) return '';

    // Test Store should be opt-in; avoid accidental usage in TestFlight/release.
    if (useTestStore && testKey.isNotEmpty) return testKey;

    if (_isApplePlatform) {
      return appleKey;
    }

    return googleKey;
  }
}
