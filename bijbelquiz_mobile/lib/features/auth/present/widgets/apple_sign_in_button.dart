import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/config/apple_sign_in_config.dart';

/// Renders an Apple-approved "Sign in with Apple" button.
/// Returns an empty widget on non-Apple platforms (Android, web).
Widget buildAppleSignInButton({
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  // This app's Apple auth flow is intended for iOS only.
  if (kIsWeb || !Platform.isIOS) {
    return const SizedBox.shrink();
  }

  return FutureBuilder<bool>(
    future: SignInWithApple.isAvailable(),
    builder: (context, snapshot) {
      final appleAvailable =
          (snapshot.data == true) || AppleSignInConfig.hasWebFallbackConfig;
      if (!appleAvailable) {
        return const SizedBox.shrink();
      }

      return AbsorbPointer(
        absorbing: isLoading || onPressed == null,
        child: Opacity(
          opacity: (isLoading || onPressed == null) ? 0.5 : 1.0,
          child: SignInWithAppleButton(
            onPressed: onPressed ?? () {},
          ),
        ),
      );
    },
  );
}
