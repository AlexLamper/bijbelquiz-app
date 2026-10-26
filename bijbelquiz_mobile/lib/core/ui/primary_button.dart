import 'package:flutter/material.dart';

import 'bq.dart';

/// Full-width action button in the BijbelQuiz 2.0 style.
///
/// Primary: lapis with a darker bottom edge. Secondary: white with a border.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Widget? leading;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.leading,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return BqButton(
      label: text,
      onPressed: onPressed,
      loading: isLoading,
      style: isSecondary ? BqButtonStyle.secondary : BqButtonStyle.primary,
      icon: leading,
      height: height < 52 ? 52 : height,
    );
  }
}
