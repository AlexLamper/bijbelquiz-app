import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../data/badge_catalog.dart';

/// Round achievement medal from the Profiel design: a tinted disc with a 3px
/// coloured ring and an icon, or a grey lock when the badge is not earned yet.
class BadgeMedal extends StatelessWidget {
  const BadgeMedal({
    super.key,
    required this.definition,
    required this.unlocked,
    this.size = 58,
  });

  final BadgeDefinition definition;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = unlocked ? badgeStyleFor(definition) : _lockedStyle;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        shape: BoxShape.circle,
        border: Border.all(color: style.ring, width: 3),
      ),
      alignment: Alignment.center,
      child: BqIcon(
        style.icon,
        size: unlocked ? size * 0.45 : size * 0.41,
        color: style.iconColor,
      ),
    );
  }
}

/// A medal with its label underneath, dimmed when locked.
class BadgeMedalTile extends StatelessWidget {
  const BadgeMedalTile({
    super.key,
    required this.definition,
    required this.unlocked,
    this.size = 58,
    this.caption,
  });

  final BadgeDefinition definition;
  final bool unlocked;
  final double size;

  /// Optional second line (e.g. "Behaald").
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${definition.label}, ${unlocked ? 'behaald' : 'nog niet behaald'}',
      excludeSemantics: true,
      child: Opacity(
        opacity: unlocked ? 1 : 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeMedal(definition: definition, unlocked: unlocked, size: size),
            const SizedBox(height: 6),
            Text(
              definition.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                height: 15 / 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.inkSoft,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.caption.copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Colours and icon for one achievement.
class BadgeStyle {
  const BadgeStyle({
    required this.icon,
    required this.ring,
    required this.background,
    required this.iconColor,
  });

  final String icon;
  final Color ring;
  final Color background;
  final Color iconColor;
}

const BadgeStyle _lockedStyle = BadgeStyle(
  icon: BqIcons.lock,
  ring: AppTheme.rule,
  background: Color(0xFFF1EFEA),
  iconColor: AppTheme.inkMuted,
);

/// Stroke star for achievements that have no more specific picture.
const String _starIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8-5.2-2.7-5.2 2.7 1-5.8-4.3-4.1 5.9-.9z"/></svg>';

/// Picks the medal colours from the badge code and label, using the same
/// accents as the rest of the app: coral for streaks, gold for rewards,
/// green for accuracy, lapis for knowledge and duels.
BadgeStyle badgeStyleFor(BadgeDefinition definition) {
  final key = normalizeBadge('${definition.code} ${definition.label}');

  bool has(List<String> words) => words.any(key.contains);

  if (has(const ['streak', 'reeks', 'dagen', 'dreef', 'toegewijd'])) {
    return const BadgeStyle(
      icon: BqIcons.flame,
      ring: AppTheme.coral,
      background: AppTheme.coralTint,
      iconColor: AppTheme.coral,
    );
  }
  if (has(const ['perfect', 'score', 'foutloos'])) {
    return const BadgeStyle(
      icon: BqIcons.check,
      ring: AppTheme.positive,
      background: AppTheme.positiveTint,
      iconColor: AppTheme.positive,
    );
  }
  if (has(const ['master', 'meester'])) {
    return const BadgeStyle(
      icon: BqIcons.crown,
      ring: AppTheme.gold,
      background: AppTheme.goldTint,
      iconColor: AppTheme.goldText,
    );
  }
  if (has(const ['first', 'eerste'])) {
    return const BadgeStyle(
      icon: BqIcons.trophy,
      ring: AppTheme.gold,
      background: AppTheme.goldTint,
      iconColor: AppTheme.goldText,
    );
  }
  if (has(const ['duel'])) {
    return const BadgeStyle(
      icon: BqIcons.swords,
      ring: AppTheme.lapis,
      background: AppTheme.lapisTint,
      iconColor: AppTheme.lapis,
    );
  }
  if (has(const ['knowledge', 'kennis', 'seeker', 'zoeker'])) {
    return const BadgeStyle(
      icon: BqIcons.search,
      ring: AppTheme.positive,
      background: AppTheme.positiveTint,
      iconColor: AppTheme.positive,
    );
  }
  if (has(const ['scholar', 'geleerde', 'level', 'niveau'])) {
    return const BadgeStyle(
      icon: BqIcons.book,
      ring: AppTheme.lapis,
      background: AppTheme.lapisTint,
      iconColor: AppTheme.lapis,
    );
  }
  return const BadgeStyle(
    icon: _starIcon,
    ring: AppTheme.lapis,
    background: AppTheme.lapisTint,
    iconColor: AppTheme.lapis,
  );
}

/// The catalogue plus any badge the account holds that the catalogue does not
/// describe, so nothing earned goes missing.
List<BadgeDefinition> badgeOverview(
  List<String> earned,
  List<BadgeDefinition> catalog,
) {
  return <BadgeDefinition>[
    ...catalog,
    ...earned
        .where((badge) => !catalog.any((entry) => entry.matches(badge)))
        .map((badge) => resolveBadge(badge, catalog)),
  ];
}
