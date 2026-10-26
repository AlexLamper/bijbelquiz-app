import 'package:flutter/material.dart';

import 'google_logo_icon.dart';
import 'social_auth_button.dart';

Widget buildButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  return SocialAuthButton(
    label: 'Doorgaan met Google',
    icon: const GoogleLogoIcon(size: 18),
    loading: isLoading,
    onPressed: isLoading ? null : onPressed,
  );
}
