import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/config/apple_sign_in_config.dart';
import 'social_auth_button.dart';

/// Whether "Doorgaan met Apple" can be offered on this device.
///
/// The Apple flow is meant for iOS only. Elsewhere, and on an iPhone without
/// Sign in with Apple and without the web fallback configured, the button is
/// left out entirely.
final appleSignInAvailableProvider = FutureProvider<bool>(
  (ref) => _appleAvailable,
);

/// Asked once per launch: a new future per build would reset the
/// [FutureBuilder] below and make the button blink on every rebuild.
final Future<bool> _appleAvailable = _checkAppleAvailable();

Future<bool> _checkAppleAvailable() async {
  if (kIsWeb || !Platform.isIOS) return false;
  try {
    return await SignInWithApple.isAvailable() ||
        AppleSignInConfig.hasWebFallbackConfig;
  } catch (_) {
    return AppleSignInConfig.hasWebFallbackConfig;
  }
}

/// Renders the "Doorgaan met Apple" button.
/// Returns an empty widget on non-Apple platforms (Android, web).
///
/// Screens that need to know up front whether the button shows (to place a
/// divider, say) watch [appleSignInAvailableProvider] and build
/// [SocialAuthButton.apple] themselves.
Widget buildAppleSignInButton({
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  // This app's Apple auth flow is intended for iOS only.
  if (kIsWeb || !Platform.isIOS) {
    return const SizedBox.shrink();
  }

  return FutureBuilder<bool>(
    future: _appleAvailable,
    builder: (context, snapshot) {
      if (snapshot.data != true) return const SizedBox.shrink();
      return SocialAuthButton.apple(
        onPressed: isLoading ? null : onPressed,
        loading: isLoading,
      );
    },
  );
}
