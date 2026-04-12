import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget buildButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required bool isLoading,
}) {
  return SizedBox(
    height: 48,
    child: Center(
      child: web.renderButton(),
    ),
  );
}
