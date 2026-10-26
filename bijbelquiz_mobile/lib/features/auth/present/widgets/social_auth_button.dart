import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';

const String _appleLogoSvg =
    '<svg viewBox="0 0 24 24" fill="#FFFFFF" xmlns="http://www.w3.org/2000/svg"><path d="M12.152 6.896c-.948 0-2.415-1.078-3.96-1.04-2.04.027-3.91 1.183-4.961 3.014-2.117 3.675-.546 9.103 1.519 12.09 1.013 1.454 2.208 3.09 3.792 3.039 1.52-.065 2.09-.987 3.935-.987 1.831 0 2.35.987 3.96.948 1.637-.026 2.676-1.48 3.676-2.948 1.156-1.688 1.636-3.325 1.662-3.415-.039-.013-3.182-1.221-3.22-4.857-.026-3.04 2.48-4.494 2.597-4.559-1.429-2.09-3.623-2.324-4.39-2.376-2-.156-3.675 1.09-4.61 1.09zM15.53 3.83c.843-1.012 1.4-2.427 1.245-3.83-1.207.052-2.662.805-3.532 1.818-.78.896-1.454 2.338-1.273 3.714 1.338.104 2.715-.688 3.559-1.701"/></svg>';

/// "Doorgaan met Apple" (black) and "Doorgaan met Google" (white): 52px
/// chunky buttons with a darker bottom edge that sinks when pressed, like
/// [BqButton] but in the sign-in providers' own colours.
class SocialAuthButton extends StatefulWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.dark = false,
    this.loading = false,
  });

  /// Black Sign in with Apple button with the white Apple logo.
  SocialAuthButton.apple({
    super.key,
    required this.onPressed,
    this.loading = false,
  }) : label = 'Doorgaan met Apple',
       icon = SvgPicture.string(_appleLogoSvg, width: 18, height: 18),
       dark = true;

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool dark;
  final bool loading;

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  static const double _height = 52;

  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final pressed = _down && enabled;

    final background = widget.dark ? AppTheme.ink : AppTheme.paperRaised;
    final edge = widget.dark ? Colors.black : AppTheme.rule;
    final foreground = widget.dark ? AppTheme.inkInverted : AppTheme.ink;
    final side = widget.dark
        ? BorderSide.none
        : const BorderSide(color: AppTheme.rule);

    final content = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.buttonLabel.copyWith(color: foreground),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled || widget.loading ? 1 : 0.5,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapCancel: enabled ? () => setState(() => _down = false) : null,
          onTapUp: enabled
              ? (_) {
                  setState(() => _down = false);
                  HapticFeedback.selectionClick();
                  widget.onPressed!();
                }
              : null,
          child: SizedBox(
            height: _height,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              margin: EdgeInsets.only(top: pressed ? 2 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border(
                  top: side,
                  left: side,
                  right: side,
                  bottom: BorderSide(color: edge, width: pressed ? 1 : 3),
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
