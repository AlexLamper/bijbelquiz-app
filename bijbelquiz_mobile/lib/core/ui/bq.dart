import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// BijbelQuiz 2.0 building blocks.
///
/// Every screen is built from these: white cards with a 1px border, chunky
/// buttons with a darker bottom edge, small tinted pills and icon tiles, and
/// the stroke icons from the approved designs.

// ---------------------------------------------------------------------------
// Icons
// ---------------------------------------------------------------------------

/// Stroke icons from the approved designs (24x24, `currentColor`).
class BqIcons {
  const BqIcons._();

  static const String _s =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">';

  static const String home =
      '$_s<path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/></svg>';
  static const String homeFilled =
      '<svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/></svg>';
  static const String book =
      '$_s<path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3z"/><path d="M5 17a3 3 0 0 1 3-3h11"/></svg>';
  static const String swords =
      '$_s<path d="M4 4l10 10"/><path d="M20 4L10 14"/><path d="M6 15l3 3"/><path d="M18 15l-3 3"/><path d="M4 20l3-3"/><path d="M20 20l-3-3"/></svg>';
  static const String trophy =
      '$_s<path d="M8 4h8v5a4 4 0 0 1-8 0z"/><path d="M8 6H5a3 3 0 0 0 3 4"/><path d="M16 6h3a3 3 0 0 1-3 4"/><path d="M12 13v4"/><path d="M8 20h8"/></svg>';
  static const String user =
      '$_s<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>';
  static const String users =
      '$_s<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0"/><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"/><path d="M18 14.2a6.5 6.5 0 0 1 3.5 5.8"/></svg>';
  static const String chevronRight = '$_s<path d="M9 6l6 6-6 6"/></svg>';
  static const String chevronLeft = '$_s<path d="M15 6l-6 6 6 6"/></svg>';
  static const String close = '$_s<path d="M6 6l12 12M18 6L6 18"/></svg>';
  static const String check = '$_s<path d="M5 12.5l4.5 4.5L19 7"/></svg>';
  static const String search =
      '$_s<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/></svg>';
  static const String clock =
      '$_s<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></svg>';
  static const String question =
      '$_s<circle cx="12" cy="12" r="8.5"/><path d="M9.6 9.5a2.5 2.5 0 0 1 4.8.8c0 1.7-2.4 2.2-2.4 3.7"/><path d="M12 17h.01"/></svg>';
  static const String lock =
      '$_s<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>';
  static const String plus = '$_s<path d="M12 5v14M5 12h14"/></svg>';
  static const String enter =
      '$_s<path d="M10 17l5-5-5-5"/><path d="M15 12H3"/><path d="M14 4h4a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-4"/></svg>';
  static const String share =
      '$_s<path d="M12 3v12"/><path d="M7 8l5-5 5 5"/><path d="M5 13v6a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-6"/></svg>';
  static const String copy =
      '$_s<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a1 1 0 0 1 1-1h10"/></svg>';
  static const String shuffle =
      '$_s<path d="M16 3h5v5"/><path d="M4 20L21 3"/><path d="M21 16v5h-5"/><path d="M15 15l6 6"/><path d="M4 4l5 5"/></svg>';
  static const String link =
      '$_s<path d="M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 0 0-5.66-5.66l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 0 0 5.66 5.66l1-1"/></svg>';
  static const String gear =
      '$_s<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>';
  static const String shield =
      '$_s<path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6z"/><path d="M9 12l2 2 4-4"/></svg>';
  static const String bell =
      '$_s<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>';
  static const String logout =
      '$_s<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>';
  static const String trash =
      '$_s<path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M6 6l1 14h10l1-14"/></svg>';
  static const String speaker =
      '$_s<path d="M11 5L6 9H3v6h3l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/><path d="M18.5 5.5a9 9 0 0 1 0 13"/></svg>';
  static const String edit =
      '$_s<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>';

  /// Filled flame (streak).
  static const String flame =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#D9734F" d="M12 2s5 4.5 5 10a5 5 0 0 1-10 0c0-2.5 1.5-4.2 2.5-5 0 2 1 3 2 3 0-3.5.5-6 .5-8z"/></svg>';

  /// Gold bolt (XP).
  static const String bolt =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#E9B12E" stroke="#8A6410" stroke-width="1.6" stroke-linejoin="round" d="M13 2L4 14h7l-1 8 9-12h-7z"/></svg>';

  /// Gold crown (Premium).
  static const String crown =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#E9B12E" stroke="#8A6410" stroke-width="1.8" stroke-linejoin="round" d="M3 18L5 7l5 5 2-7 2 7 5-5 2 11z"/></svg>';
}

/// Renders one of [BqIcons].
class BqIcon extends StatelessWidget {
  const BqIcon(this.svg, {super.key, this.size = 22, this.color});

  final String svg;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? AppTheme.inkSoft;
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: c),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo
// ---------------------------------------------------------------------------

class BqLogo extends StatelessWidget {
  const BqLogo({super.key, this.markSize = 34, this.fontSize = 22});

  final double markSize;
  final double fontSize;

  static const String mark =
      '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><path d="M12 24Q31 13 50 23Q69 13 88 24L88 71Q69 63 50 73Q42 69 36 69L24 86L25 69.5Q18 70 12 72Z" fill="#263E69" stroke="#263E69" stroke-width="8" stroke-linejoin="round" transform="translate(0 5)"/><path d="M12 24Q31 13 50 23Q69 13 88 24L88 71Q69 63 50 73Q42 69 36 69L24 86L25 69.5Q18 70 12 72Z" fill="#35548C" stroke="#35548C" stroke-width="8" stroke-linejoin="round"/><path d="M18 30Q32 22 46 30L46 64Q32 59 18 63Z" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="3" stroke-linejoin="round"/><path d="M54 30Q68 22 82 30L82 63Q68 59 54 64Z" fill="#FFFFFF" stroke="#FFFFFF" stroke-width="3" stroke-linejoin="round"/><path d="M24 40Q32 36 40 40M24 50Q32 46 40 50" stroke="#35548C" stroke-width="5" stroke-linecap="round" fill="none"/><path d="M61.5 39Q61.5 31.5 68 31.5Q74.5 31.5 74.5 37.5Q74.5 41.5 70.5 43.5Q68 44.8 68 48" stroke="#35548C" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" fill="none"/><circle cx="68" cy="56" r="4.4" fill="#E9B12E"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'BijbelQuiz',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.string(mark, width: markSize, height: markSize),
          SizedBox(width: markSize * 0.2),
          Text.rich(
            TextSpan(
              children: const [
                TextSpan(text: 'Bijbel'),
                TextSpan(
                  text: 'Quiz',
                  style: TextStyle(color: AppTheme.lapis),
                ),
              ],
            ),
            style: TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              height: 1,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surfaces
// ---------------------------------------------------------------------------

/// White card with a 1px border. Never tinted, never a shadow.
class BqCard extends StatelessWidget {
  const BqCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppTheme.paperRaised,
    this.borderColor = AppTheme.rule,
    this.borderWidth = 1,
    this.radius = AppTheme.radiusLg,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor, width: borderWidth),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              highlightColor: AppTheme.ruleSoft.withValues(alpha: 0.6),
              splashColor: AppTheme.ruleSoft,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// A white card whose children are separated by soft dividers (list groups).
class BqListCard extends StatelessWidget {
  const BqListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft));
      }
      items.add(children[i]);
    }
    return BqCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }
}

/// A tappable list row: leading tile, title + subtitle, optional trailing,
/// chevron when it navigates.
class BqListRow extends StatelessWidget {
  const BqListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? showChevron;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final chevron = showChevron ?? onTap != null;
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStrong,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      color: subtitleColor ?? AppTheme.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          if (chevron) ...[
            const SizedBox(width: 8),
            const BqIcon(BqIcons.chevronRight, size: 18, color: AppTheme.inkFaint),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// Rounded square with a tint, holding an icon or short text.
class BqIconTile extends StatelessWidget {
  const BqIconTile({
    super.key,
    required this.child,
    this.background = AppTheme.lapisTint,
    this.size = 40,
    this.radius = 10,
  });

  final Widget child;
  final Color background;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Round avatar with a letter, tinted per person.
class BqAvatar extends StatelessWidget {
  const BqAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.background,
    this.foreground,
  });

  final String name;
  final double size;
  final Color? background;
  final Color? foreground;

  static const List<(Color, Color)> _tints = [
    (AppTheme.coralTint, AppTheme.vermilion),
    (AppTheme.positiveTint, AppTheme.positive),
    (AppTheme.lapisTint, AppTheme.lapis),
    (AppTheme.goldTint, AppTheme.goldText),
  ];

  /// Stable tint per name, so a friend keeps their colour everywhere.
  static (Color, Color) tintFor(String name) {
    if (name.isEmpty) return _tints[2];
    final code = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return _tints[code % _tints.length];
  }

  @override
  Widget build(BuildContext context) {
    final t = tintFor(name);
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? t.$1,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: AppTheme.displayFontName,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.42,
          height: 1,
          color: foreground ?? t.$2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pills, chips, progress
// ---------------------------------------------------------------------------

/// Small rounded label. `outlined` = white with border (header stats).
class BqPill extends StatelessWidget {
  const BqPill({
    super.key,
    required this.label,
    this.icon,
    this.background = AppTheme.lapisTint,
    this.foreground = AppTheme.lapis,
    this.outlined = false,
    this.height = 26,
    this.fontSize = 12,
    this.uppercase = false,
  });

  /// White pill with a border and ink text, as in the Home header.
  const BqPill.outline({
    super.key,
    required this.label,
    this.icon,
    this.height = 36,
    this.fontSize = 15,
  }) : background = AppTheme.paperRaised,
       foreground = AppTheme.ink,
       outlined = true,
       uppercase = false;

  final String label;
  final Widget? icon;
  final Color background;
  final Color foreground;
  final bool outlined;
  final double height;
  final double fontSize;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height > 30 ? 12 : 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: outlined ? Border.all(color: AppTheme.rule) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 5)],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: uppercase ? 0.5 : 0,
              color: foreground,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal progress bar with a rounded track.
class BqProgressBar extends StatelessWidget {
  const BqProgressBar({
    super.key,
    required this.value,
    this.color = AppTheme.gold,
    this.track = AppTheme.ruleSoft,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small progress ring (Verder spelen cards, book rows).
class BqRing extends StatelessWidget {
  const BqRing({
    super.key,
    required this.value,
    this.color = AppTheme.lapis,
    this.track = AppTheme.ruleSoft,
    this.size = 30,
    this.stroke = 4,
    this.center,
  });

  final double value;
  final Color color;
  final Color track;
  final double size;
  final double stroke;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: stroke,
              color: color,
              backgroundColor: track,
              strokeCap: StrokeCap.round,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

/// Segmented progress (quiz question 4/10).
class BqSegments extends StatelessWidget {
  const BqSegments({
    super.key,
    required this.total,
    required this.done,
    this.color = AppTheme.lapis,
    this.track = const Color(0xFFD9D6CE),
  });

  final int total;
  final int done;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i < done ? color : track,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

enum BqButtonStyle { primary, secondary, coral, tint, white }

/// Chunky button with a darker bottom edge that sinks when pressed.
class BqButton extends StatefulWidget {
  const BqButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = BqButtonStyle.primary,
    this.icon,
    this.height = 52,
    this.expand = true,
    this.loading = false,
    this.fontSize = 16,
    this.radius = AppTheme.radiusMd,
  });

  final String label;
  final VoidCallback? onPressed;
  final BqButtonStyle style;
  final Widget? icon;
  final double height;
  final bool expand;
  final bool loading;
  final double fontSize;
  final double radius;

  @override
  State<BqButton> createState() => _BqButtonState();
}

class _BqButtonState extends State<BqButton> {
  bool _down = false;

  (Color bg, Color edge, Color fg, Color? border) get _colors {
    switch (widget.style) {
      case BqButtonStyle.primary:
        return (AppTheme.lapis, AppTheme.lapisStrong, AppTheme.inkInverted, null);
      case BqButtonStyle.coral:
        return (AppTheme.coralDeep, AppTheme.coralEdge, AppTheme.inkInverted, null);
      case BqButtonStyle.tint:
        return (AppTheme.lapisTint, const Color(0xFFC3CEE6), AppTheme.lapisStrong, null);
      case BqButtonStyle.white:
        return (AppTheme.paperRaised, const Color(0xFFC9D2E6), AppTheme.lapisStrong, null);
      case BqButtonStyle.secondary:
        return (AppTheme.paperRaised, AppTheme.ruleStrong, AppTheme.ink, AppTheme.rule);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final (bg, edge, fg, border) = _colors;
    final pressed = _down && enabled;
    final edgeH = pressed ? 1.0 : 3.0;

    final label = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 20),
                  child: widget.icon!,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.buttonLabel.copyWith(
                    color: fg,
                    fontSize: widget.fontSize,
                  ),
                ),
              ),
            ],
          );

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      height: widget.height,
      width: widget.expand ? double.infinity : null,
      margin: EdgeInsets.only(top: 3 - edgeH),
      padding: EdgeInsets.symmetric(horizontal: widget.expand ? 16 : 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border(
          top: border != null ? BorderSide(color: border) : BorderSide.none,
          left: border != null ? BorderSide(color: border) : BorderSide.none,
          right: border != null ? BorderSide(color: border) : BorderSide.none,
          bottom: BorderSide(color: edge, width: edgeH),
        ),
      ),
      alignment: Alignment.center,
      child: label,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
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
            height: widget.height + 3,
            child: Align(alignment: Alignment.bottomCenter, child: body),
          ),
        ),
      ),
    );
  }
}

/// 40px round white button (back, close, settings).
class BqCircleButton extends StatelessWidget {
  const BqCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.size = 40,
    this.iconColor = AppTheme.inkSoft,
  });

  final String icon;
  final VoidCallback? onTap;
  final String label;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppTheme.paperRaised,
        shape: const CircleBorder(side: BorderSide(color: AppTheme.rule)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: BqIcon(icon, size: 18, color: iconColor)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

/// "Verder spelen ........ Alles"
class BqSectionHeader extends StatelessWidget {
  const BqSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: AppTheme.displaySmall)),
        if (trailing != null) trailing!,
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lapis,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Page title row used by the tab screens (Quizzen, Duels, Ranglijst...).
class BqPageTitle extends StatelessWidget {
  const BqPageTitle(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTheme.displayLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTheme.bodyMuted),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Back/close button + title, for pushed screens.
class BqTopBar extends StatelessWidget {
  const BqTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
    this.close = false,
    this.trailing,
    this.large = false,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool close;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BqCircleButton(
          icon: close ? BqIcons.close : BqIcons.chevronLeft,
          label: close ? 'Sluiten' : 'Terug',
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        if (title != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: large
                      ? AppTheme.displayLarge
                      : const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.inkSoft,
                        ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption,
                  ),
              ],
            ),
          ),
        ] else
          const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Standard page padding for the redesigned screens.
const EdgeInsets bqPagePadding = EdgeInsets.fromLTRB(20, 16, 20, 24);
