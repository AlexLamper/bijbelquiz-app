import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';

/// Small building blocks shared by the Samen spelen screens (play together,
/// lobby, live game, results). Everything else comes from `core/ui/bq.dart`.

/// Empty code box and other inset fields in the designs.
const Color mpSunken = Color(0xFFF7F7F5);

/// Answer text on tiles that were not picked.
const Color mpTileMuted = Color(0xFF8A877F);

/// Three-letter tile label for a quiz ("Johannes 6" -> "Joh",
/// "1 Samuel 3" -> "1Sa"), as in the lobby design.
String quizAbbreviation(String title) {
  final words = title
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'Quiz';

  String take(String word, int count) =>
      word.length <= count ? word : word.substring(0, count);

  final first = words.first;
  if (RegExp(r'^\d+$').hasMatch(first) && words.length > 1) {
    final rest = take(words[1], 2);
    return '$first${rest[0].toUpperCase()}${rest.substring(1)}';
  }
  final short = take(first, 3);
  return '${short[0].toUpperCase()}${short.substring(1)}';
}

/// "Quiz ........ Wijzig" - a 16/800 label with an optional trailing widget.
class MpSectionLabel extends StatelessWidget {
  const MpSectionLabel(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 22 / 16,
              color: AppTheme.ink,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Lapis text link with a 44px tall tap area ("Wijzig").
class MpTextLink extends StatelessWidget {
  const MpTextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: onTap == null ? AppTheme.inkFaint : AppTheme.lapis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White button with a 1px border and a 3px bottom edge in the same colour,
/// as the designs draw it (`border: 1px solid #DEDBD3; border-bottom-width:
/// 3px`). Kept local because a border with one colour can be rounded safely.
class MpSecondaryButton extends StatefulWidget {
  const MpSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.loading = false,
    this.expand = true,
    this.fontSize = 16,
    this.face,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final bool loading;
  final bool expand;
  final double fontSize;

  /// Replaces the icon + label row (icon-only buttons).
  final Widget? face;
  final EdgeInsetsGeometry padding;

  @override
  State<MpSecondaryButton> createState() => _MpSecondaryButtonState();
}

class _MpSecondaryButtonState extends State<MpSecondaryButton> {
  bool _down = false;

  Widget _label() => Text(
    widget.label,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTheme.buttonLabel.copyWith(
      color: AppTheme.ink,
      fontSize: widget.fontSize,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final pressed = _down && enabled;
    final edge = pressed ? 1.0 : 3.0;

    final content = widget.loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppTheme.lapis,
            ),
          )
        : widget.face ??
              Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              // A shrink-wrapped button may sit in a Row (unbounded width),
              // where a Flexible child is not allowed.
              if (widget.expand)
                Flexible(child: _label())
              else
                _label(),
            ],
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
            height: widget.height,
            child: Align(
              alignment: Alignment.bottomCenter,
              widthFactor: widget.expand ? null : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 70),
                height: widget.height - (3 - edge),
                width: widget.expand ? double.infinity : null,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: AppTheme.paperRaised,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border(
                    top: const BorderSide(color: AppTheme.rule),
                    left: const BorderSide(color: AppTheme.rule),
                    right: const BorderSide(color: AppTheme.rule),
                    bottom: BorderSide(color: AppTheme.rule, width: edge),
                  ),
                ),
                alignment: Alignment.center,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48px square white icon button with the same edge ("Code kopiëren").
class MpSquareIconButton extends StatelessWidget {
  const MpSquareIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 48,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: MpSecondaryButton(
        // Read out by screen readers; the face only shows the icon.
        label: label,
        height: size,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        face: BqIcon(icon, size: 18, color: AppTheme.inkSoft),
      ),
    );
  }
}

/// Tinted inset notice for errors and warnings inside a screen or card.
enum MpNoticeTone { error, info, success }

class MpNotice extends StatelessWidget {
  const MpNotice({
    super.key,
    required this.message,
    this.title,
    this.tone = MpNoticeTone.error,
    this.action,
  });

  final String message;
  final String? title;
  final MpNoticeTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (tone) {
      MpNoticeTone.error => (
        AppTheme.coralTint,
        AppTheme.coralLine,
        AppTheme.vermilion,
      ),
      MpNoticeTone.info => (
        AppTheme.lapisTint,
        AppTheme.lapisSoft,
        AppTheme.lapisStrong,
      ),
      MpNoticeTone.success => (
        AppTheme.positiveTint,
        const Color(0xFFCFE0D3),
        AppTheme.positiveText,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTheme.bodyStrong.copyWith(color: fg, fontSize: 14),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            message,
            style: AppTheme.caption.copyWith(
              color: title == null ? fg : AppTheme.inkSoft,
              fontWeight: title == null ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 10), action!],
        ],
      ),
    );
  }
}

/// White card row for a quiz: abbreviation tile, title, subtitle.
class MpQuizRow extends StatelessWidget {
  const MpQuizRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          MpQuizTile(title: title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStrong,
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// 40px lapis tile with the quiz abbreviation.
class MpQuizTile extends StatelessWidget {
  const MpQuizTile({super.key, required this.title, this.size = 40});

  final String title;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BqIconTile(
      size: size,
      child: Text(
        quizAbbreviation(title),
        maxLines: 1,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppTheme.lapis,
        ),
      ),
    );
  }
}

/// Close/back circle + page title, as in the Samen spelen designs.
class MpHeader extends StatelessWidget {
  const MpHeader({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onButton,
    this.close = false,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onButton;
  final bool close;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BqCircleButton(
          icon: close ? BqIcons.close : BqIcons.chevronLeft,
          label: buttonLabel,
          onTap: onButton,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.displayLarge,
          ),
        ),
      ],
    );
  }
}

/// White sheet pinned to the bottom of a screen (feedback, waiting state).
class MpBottomPanel extends StatelessWidget {
  const MpBottomPanel({super.key, required this.child, this.rounded = true});

  final Widget child;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.5;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: rounded
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : null,
        border: const Border(top: BorderSide(color: AppTheme.rule)),
        boxShadow: rounded
            ? const [
                BoxShadow(
                  color: Color(0x0F1B1A18),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 22),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, rounded ? 18 : 12, 20, 0),
            child: child,
          ),
        ),
      ),
    );
  }
}
