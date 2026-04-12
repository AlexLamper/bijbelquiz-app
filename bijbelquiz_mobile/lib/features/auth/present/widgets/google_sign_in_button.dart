import 'package:flutter/material.dart';

import 'google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart'
    as platform;

/// Renders either a custom Google Sign In Button (Mobile)
/// or the official Google Identity Services button (Web).
Widget buildGoogleSignInButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  return platform.buildButton(
    context: context,
    onPressed: onPressed,
    isLoading: isLoading,
  );
}
