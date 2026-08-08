import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Site button.
///
/// Primary  : `h-12 rounded-md bg-ink px-5 text-ink-inverted hover:bg-ink-soft`
/// Secondary: `h-12 rounded-md border border-rule bg-paper-raised text-ink
///             hover:bg-paper-sunken`
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
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSecondary ? AppTheme.paperRaised : AppTheme.ink;
    final fgColor = isSecondary ? AppTheme.ink : AppTheme.inkInverted;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: isSecondary
              ? AppTheme.paperSunken
              : AppTheme.ink.withValues(alpha: 0.45),
          disabledForegroundColor: isSecondary
              ? AppTheme.inkMuted
              : AppTheme.inkInverted.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: isSecondary
                ? const BorderSide(color: AppTheme.rule)
                : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTheme.buttonLabel,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
