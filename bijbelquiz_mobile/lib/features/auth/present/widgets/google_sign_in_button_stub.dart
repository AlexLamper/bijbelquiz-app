import 'package:flutter/material.dart';
import '../../../../core/ui/primary_button.dart';

Widget buildButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  return PrimaryButton(
    text: 'Continue with Google',
    isSecondary: true,
    isLoading: isLoading,
    onPressed: isLoading ? null : onPressed,
  );
}
