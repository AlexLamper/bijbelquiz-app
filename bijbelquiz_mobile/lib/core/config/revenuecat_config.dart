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
/// CI (Codemagic, GitHub Actions): store keys as **secrets** and inject via
/// `--dart-define=...` — still not a `.env` file in the repo.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// Optional: RevenueCat **Test Store** key (`test_...`) for early integration
  /// testing before iOS/Android store apps are linked.
  static const String testKey = String.fromEnvironment(
    'REVENUECAT_TEST_KEY',
    defaultValue: '',
  );

  static const String appleKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: '',
  );

  static const String googleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: '',
  );

  /// Key used by [Purchases.configure] in [main.dart].
  static String sdkPublicApiKey() {
    if (kIsWeb) return '';

    // Prefer Test Store when provided (handy while wiring the SDK before store linking).
    if (testKey.isNotEmpty) return testKey;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return appleKey;
    }

    return googleKey;
  }
}
