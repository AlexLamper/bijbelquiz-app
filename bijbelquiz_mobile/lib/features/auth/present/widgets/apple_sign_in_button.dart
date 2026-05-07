import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Shows the Sign in with Apple button only on iOS/macOS (and web if configured).
/// Returns null widget on Android where Apple Sign-In is not required.
Widget buildAppleSignInButton({
  required BuildContext context,
  required bool isLoading,
  required VoidCallback? onPressed,
}) {
  // Apple Sign-In is mandatory on iOS/macOS per App Store guideline 4.8.
  // On Android/web it is optional — hide to keep the UI clean.
  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.macOS) {
    return const SizedBox.shrink();
  }

  return Opacity(
    opacity: isLoading ? 0.5 : 1.0,
    child: SignInWithAppleButton(
      onPressed: isLoading ? () {} : (onPressed ?? () {}),
      style: SignInWithAppleButtonStyle.black,
      text: 'Inloggen met Apple',
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
