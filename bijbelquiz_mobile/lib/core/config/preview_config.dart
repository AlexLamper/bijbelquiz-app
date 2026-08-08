import 'package:flutter/foundation.dart';

/// Design-preview mode.
///
/// Enable with:
/// ```
/// flutter run -d chrome --dart-define=PREVIEW=true
/// ```
///
/// When on, the app boots straight to the dashboard with canned data instead
/// of hitting the API, so the UI can be reviewed without a login or a running
/// backend. It is hard-disabled in release builds, so it can never ship.
class PreviewConfig {
  const PreviewConfig._();

  static const bool _flag = bool.fromEnvironment(
    'PREVIEW',
    defaultValue: false,
  );

  /// True only in a debug/profile build that was started with the flag.
  static bool get enabled => _flag && !kReleaseMode;
}
