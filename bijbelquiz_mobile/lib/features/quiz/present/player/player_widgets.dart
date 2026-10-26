import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';

/// Heavier strokes than [BqIcons], as the quiz designs draw them.
class PlayerIcons {
  const PlayerIcons._();

  static const String close =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" xmlns="http://www.w3.org/2000/svg"><path d="M6 6l12 12M18 6L6 18"/></svg>';

  static const String check =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M5 12.5l4.5 4.5L19 7"/></svg>';

  static const String cross =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" xmlns="http://www.w3.org/2000/svg"><path d="M6 6l12 12M18 6L6 18"/></svg>';

  static const String book =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3z"/><path d="M5 17a3 3 0 0 1 3-3h11"/></svg>';

  static const String trophy =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M8 4h8v5a4 4 0 0 1-8 0z"/><path d="M8 6H5a3 3 0 0 0 3 4"/><path d="M16 6h3a3 3 0 0 1-3 4"/><path d="M12 13v4"/><path d="M8 20h8"/></svg>';

  static const String swords =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M4 4l10 10"/><path d="M20 4L10 14"/><path d="M6 15l3 3"/><path d="M18 15l-3 3"/><path d="M4 20l3-3"/><path d="M20 20l-3-3"/></svg>';
}

/// Soft card shadow from the quiz designs: `0 1px 2px rgba(27,26,24,.06)`.
const List<BoxShadow> playerCardShadow = [
  BoxShadow(color: Color(0x0F1B1A18), blurRadius: 2, offset: Offset(0, 1)),
];

/// The 40px round white close button, inside a 44px tap target.
class PlayerCloseButton extends StatelessWidget {
  const PlayerCloseButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.paperRaised,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.rule),
              ),
              alignment: Alignment.center,
              child: const BqIcon(
                PlayerIcons.close,
                size: 18,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small tinted pill ("Lees Johannes 6:9", "Nieuwe beste score").
///
/// When tappable it gets a transparent band above and below, so the tap
/// target is 44px tall while the pill itself stays at the designed height.
class PlayerChip extends StatelessWidget {
  const PlayerChip({
    super.key,
    required this.label,
    this.icon,
    this.background = AppTheme.lapisTint,
    this.foreground = AppTheme.lapis,
    this.height = 30,
    this.fontSize = 13,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final String? icon;
  final Color background;
  final Color foreground;
  final double height;
  final double fontSize;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            BqIcon(icon!, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(
        label: semanticLabel ?? label,
        excludeSemantics: true,
        child: chip,
      );
    }

    final band = ((44 - height) / 2).clamp(0.0, 22.0);
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: band),
          child: chip,
        ),
      ),
    );
  }
}

/// "1.240" - Dutch thousands separator.
String formatPlayerNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
