import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_repository.dart';

/// One achievement, as the backend defines it.
///
/// `/api/mobile/profile` hands back a plain list of badge codes such as
/// `FIRST_STEPS`. Those codes are storage keys, never labels, so every screen
/// resolves them through this catalogue before showing them.
@immutable
class BadgeDefinition {
  const BadgeDefinition({
    required this.code,
    required this.label,
    required this.icon,
    this.description = '',
    this.aliases = const <String>[],
  });

  /// Storage key, e.g. `FIRST_STEPS`.
  final String code;

  /// Dutch label shown to the player, e.g. `Eerste quiz`.
  final String label;

  final IconData icon;
  final String description;

  /// Extra spellings that refer to the same achievement, so a profile that
  /// stores `Eerste quiz` matches the same definition as one storing
  /// `FIRST_STEPS`.
  final List<String> aliases;

  factory BadgeDefinition.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['key'] ?? json['id'] ?? '').toString();
    final label = (json['label'] ?? json['name'] ?? json['title'] ?? '')
        .toString();

    return BadgeDefinition(
      code: code,
      label: label.isNotEmpty ? label : prettifyBadgeCode(code),
      icon: iconForBadge(code.isNotEmpty ? code : label),
      description: (json['description'] ?? json['descriptionNl'] ?? '')
          .toString(),
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((alias) => alias.toString())
              .toList() ??
          const <String>[],
    );
  }

  /// Whether [badge], as stored on the profile, is this achievement.
  bool matches(String badge) {
    final normalized = normalizeBadge(badge);
    if (normalized.isEmpty) return false;

    return normalized == normalizeBadge(code) ||
        normalized == normalizeBadge(label) ||
        aliases.any((alias) => normalizeBadge(alias) == normalized);
  }

  bool isUnlockedBy(Iterable<String> badges) => badges.any(matches);
}

/// Folds `FIRST_STEPS`, `first-steps` and `First steps` onto one another.
String normalizeBadge(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

/// Last-resort label for a code this build does not know yet: `FIRST_STEPS`
/// becomes `First steps` rather than leaking the raw constant into the UI.
String prettifyBadgeCode(String code) {
  final words = normalizeBadge(code);
  if (words.isEmpty) return code;
  return words[0].toUpperCase() + words.substring(1);
}

IconData iconForBadge(String codeOrLabel) {
  final normalized = normalizeBadge(codeOrLabel);
  if (normalized.contains('streak') || normalized.contains('reeks')) {
    return Icons.local_fire_department_outlined;
  }
  if (normalized.contains('perfect') || normalized.contains('score')) {
    return Icons.gps_fixed;
  }
  if (normalized.contains('master') || normalized.contains('meester')) {
    return Icons.emoji_events_outlined;
  }
  if (normalized.contains('first') || normalized.contains('eerste')) {
    return Icons.star_border;
  }
  return Icons.auto_awesome_outlined;
}

/// Used until `GET /api/mobile/badges` exists. `FIRST_STEPS` is the one code
/// confirmed against live profile data; the rest carry both a code and a Dutch
/// alias so they match whichever spelling the backend settles on.
const List<BadgeDefinition> kFallbackBadgeCatalog = <BadgeDefinition>[
  BadgeDefinition(
    code: 'FIRST_STEPS',
    label: 'Eerste quiz',
    icon: Icons.star_border,
    description: 'Rond je eerste quiz af.',
    aliases: <String>['first quiz', 'eerste quiz', 'eerste stappen'],
  ),
  BadgeDefinition(
    code: 'STREAK_7',
    label: '7-dagen reeks',
    icon: Icons.local_fire_department_outlined,
    description: 'Speel zeven dagen achter elkaar.',
    aliases: <String>['seven day streak', '7 dagen reeks', 'week streak'],
  ),
  BadgeDefinition(
    code: 'QUIZ_MASTER',
    label: 'Quiz meester',
    icon: Icons.emoji_events_outlined,
    description: 'Sluit tien quizzen succesvol af.',
    aliases: <String>['quiz meester', 'master'],
  ),
  BadgeDefinition(
    code: 'PERFECT_SCORE',
    label: 'Perfecte score',
    icon: Icons.gps_fixed,
    description: 'Beantwoord elke vraag van een quiz goed.',
    aliases: <String>['perfecte score', 'perfectionist'],
  ),
  BadgeDefinition(
    code: 'HUNDRED_QUIZZES',
    label: '100 quizzen',
    icon: Icons.auto_awesome_outlined,
    description: 'Speel honderd quizzen.',
    aliases: <String>['100 quizzen', '100 quizzes'],
  ),
];

/// The achievement catalogue, read from the database when the backend serves
/// it and falling back to [kFallbackBadgeCatalog] otherwise.
final badgeCatalogProvider = FutureProvider<List<BadgeDefinition>>((ref) async {
  final definitions = await ref
      .watch(profileRepositoryProvider)
      .getBadgeDefinitions();

  return definitions.isEmpty ? kFallbackBadgeCatalog : definitions;
});

/// Resolves a stored badge code to its definition, synthesising one for codes
/// the catalogue does not describe so nothing renders as `FIRST_STEPS`.
BadgeDefinition resolveBadge(String badge, List<BadgeDefinition> catalog) {
  for (final definition in catalog) {
    if (definition.matches(badge)) return definition;
  }

  return BadgeDefinition(
    code: badge,
    label: prettifyBadgeCode(badge),
    icon: iconForBadge(badge),
  );
}
