import 'package:flutter/material.dart';
import '../../../../core/ui/primary_button.dart';
import 'google_logo_icon.dart';

Widget buildButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  return PrimaryButton(
    text: 'Inloggen met Google',
    isSecondary: true,
    isLoading: isLoading,
    onPressed: isLoading ? null : onPressed,
    leading: const GoogleLogoIcon(size: 20),
  );
}
