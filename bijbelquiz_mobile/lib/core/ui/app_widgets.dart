import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ---------------------------------------------------------------------------
/// Editorial building blocks copied from www.bijbelquiz.com.
///
/// The site never uses shadows or gradients: structure comes from hairline
/// rules (`border-rule`), a warm paper background and a serif display face.
/// ---------------------------------------------------------------------------

/// `<span class="inline-flex items-center gap-2.5 text-[11px] font-medium
///  uppercase tracking-[0.18em] text-ink-muted">
///    <span class="h-px w-6 bg-lapis"></span>Label</span>`
class Eyebrow extends StatelessWidget {
  const Eyebrow(
    this.label, {
    super.key,
    this.color,
    this.ruleColor,
    this.compact = false,
  });

  final String label;
  final Color? color;
  final Color? ruleColor;

  /// The 10px / 0.16em variant used above stat numbers.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = (compact ? AppTheme.overline : AppTheme.eyebrow).copyWith(
      color: color ?? AppTheme.inkMuted,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 14 : 24,
          height: 1,
          color: ruleColor ?? AppTheme.lapis,
        ),
        SizedBox(width: compact ? 8 : 10),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Full-bleed page header used at the top of a screen.
///
/// Mirrors the site's page intro:
/// eyebrow -> `font-display text-[32px] tracking-[-0.025em]` -> lead paragraph.
///
/// The old API (title / subtitle / icon / trailing / accent) is preserved so
/// existing screens keep working; `accent` now only tints the eyebrow rule.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.accent = false,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool accent;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(
                eyebrow ?? title,
                ruleColor: accent ? AppTheme.vermilion : AppTheme.lapis,
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTheme.displayLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(subtitle!, style: AppTheme.bodyLead),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}

/// Section heading with the site's `border-b border-rule pb-3.5` underline.
///
/// ```html
/// <div class="flex items-end justify-between border-b border-rule pb-3.5">
///   <div>
///     <span class="eyebrow">Quizzen</span>
///     <h2 class="mt-2.5 font-display text-xl">Populaire Quizzen</h2>
///     <p class="mt-2.5 text-sm text-ink-muted">…</p>
///   </div>
///   <a class="text-sm font-medium text-ink-soft">Bekijk alle quizzen →</a>
/// </div>
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.description,
    this.actionLabel,
    this.onAction,
    this.showRule = true,
  });

  final String title;
  final String? eyebrow;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Eyebrow(eyebrow!),
                    const SizedBox(height: 10),
                  ],
                  Text(title, style: AppTheme.displaySmall),
                  if (description != null) ...[
                    const SizedBox(height: 10),
                    Text(description!, style: AppTheme.bodyMuted),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 16),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel!,
                        style: AppTheme.bodyStrong.copyWith(
                          color: AppTheme.inkSoft,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppTheme.inkSoft,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showRule) ...[const SizedBox(height: 14), const RuleLine()],
      ],
    );
  }
}

/// A 1px hairline - `border-rule`.
class RuleLine extends StatelessWidget {
  const RuleLine({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color ?? AppTheme.rule);
  }
}

/// `bg-paper-raised rounded-lg border border-rule` - no shadow, ever.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppTheme.radiusLg,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color ?? AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppTheme.rule),
    );

    if (onTap == null) {
      return Container(
        padding: padding,
        decoration: decoration,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: child,
      );
    }

    return Material(
      color: color ?? AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? AppTheme.rule),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The site's "hairline grid": a bordered container whose children are
/// separated by 1px rules - `grid gap-px rounded-lg border border-rule bg-rule`.
class RuleGrid extends StatelessWidget {
  const RuleGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const RuleLine());
      items.add(children[i]);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }
}

/// One value in a [StatStrip].
class StatItem {
  const StatItem({required this.value, required this.label, this.ruleColor});

  final String value;
  final String label;
  final Color? ruleColor;
}

/// `border-y border-rule py-5 … divide-x divide-rule` - the stat band under
/// the hero and above the leaderboard table.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items, this.stacked = false});

  final List<StatItem> items;

  /// Stack value under label (leaderboard variant) instead of inline (hero).
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.rule),
          bottom: BorderSide(color: AppTheme.rule),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Container(width: 1, height: 34, color: AppTheme.rule),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: i == 0 ? 0 : 14),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(
                            items[i].label,
                            compact: true,
                            ruleColor: items[i].ruleColor ?? AppTheme.lapis,
                          ),
                          const SizedBox(height: 6),
                          Text(items[i].value, style: AppTheme.statNumber),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(items[i].value, style: AppTheme.statNumber),
                          const SizedBox(height: 6),
                          Text(
                            items[i].label.toUpperCase(),
                            style: AppTheme.overline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `inline-flex items-center rounded-sm border px-2 py-1 text-[10px]
///  font-medium uppercase tracking-[0.16em]`
class SiteBadge extends StatelessWidget {
  const SiteBadge(
    this.label, {
    super.key,
    this.background,
    this.foreground,
    this.borderColor,
    this.icon,
    this.solid = false,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;
  final IconData? icon;

  /// `border-transparent bg-ink text-ink-inverted`
  final bool solid;

  const SiteBadge.lapis(String label, {Key? key, IconData? icon})
    : this(
        label,
        key: key,
        background: AppTheme.lapisTint,
        foreground: AppTheme.lapis,
        borderColor: AppTheme.lapis,
        icon: icon,
      );

  const SiteBadge.positive(String label, {Key? key, IconData? icon})
    : this(
        label,
        key: key,
        background: AppTheme.positiveTint,
        foreground: AppTheme.positive,
        borderColor: AppTheme.positive,
        icon: icon,
      );

  const SiteBadge.vermilion(String label, {Key? key, IconData? icon})
    : this(
        label,
        key: key,
        background: AppTheme.vermilionTint,
        foreground: AppTheme.vermilion,
        borderColor: AppTheme.vermilion,
        icon: icon,
      );

  const SiteBadge.neutral(String label, {Key? key, IconData? icon})
    : this(
        label,
        key: key,
        background: AppTheme.paperSunken,
        foreground: AppTheme.inkSoft,
        borderColor: AppTheme.rule,
        icon: icon,
      );

  @override
  Widget build(BuildContext context) {
    final fg = solid ? AppTheme.inkInverted : (foreground ?? AppTheme.inkSoft);
    final bg = solid ? AppTheme.ink : (background ?? AppTheme.paperSunken);
    // Tinted badges on the site use a 35% alpha border of their accent.
    final bc = solid
        ? Colors.transparent
        : (borderColor == null
              ? AppTheme.rule
              : (borderColor == AppTheme.rule
                    ? AppTheme.rule
                    : borderColor!.withValues(alpha: 0.35)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: bc),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: AppTheme.overline.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

/// Primary action - `bg-ink text-ink-inverted rounded-md`.
class SiteButton extends StatelessWidget {
  const SiteButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.height = 48,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final double height;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        // The theme sets `minimumSize: Size.fromHeight(48)`, i.e. an *infinite*
        // minimum width. Inside a Row that swallows the whole line and starves
        // the flexible siblings, so a non-expanding button must drop it.
        style: expand ? null : _compactStyle(height),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.inkInverted,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 16),
                  ],
                ],
              ),
      ),
    );
    return button;
  }
}

/// Secondary action - `border border-rule bg-paper-raised text-ink`.
class SiteOutlineButton extends StatelessWidget {
  const SiteOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 48,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        // See [SiteButton.build]: the theme's infinite minimum width has to go
        // when the button shares a Row with flexible content.
        style: expand ? null : _compactStyle(height),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Style override for buttons that must size to their label instead of to the
/// full line. Only the properties that need to differ are set, so everything
/// else still comes from the theme.
ButtonStyle _compactStyle(double height) {
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(Size(0, height)),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: 14),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

/// A rule-separated list row, as used by the leaderboard and settings lists.
class RuleListTile extends StatelessWidget {
  const RuleListTile({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.showRule = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: showRule
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.rule)),
            )
          : null,
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: content,
      ),
    );
  }
}

/// Loading spinner matching `text-primary` on the site.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.ink,
        ),
      ),
    );
  }
}

/// Empty / error state - centred serif title with a muted lead paragraph.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: AppTheme.inkMuted),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.displaySmall,
            ),
            if (description != null) ...[
              const SizedBox(height: 10),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMuted,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
