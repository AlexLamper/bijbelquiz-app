import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_repository.dart';

/// One achievement, as the backend defines it.
///
/// `/api/mobile/profile` hands back a plain list of badge codes such as
/// `first_steps`. Those codes are storage keys, never labels, so every screen
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

  /// Storage key, e.g. `first_steps`.
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

/// Last-resort label for a code this build does not know yet: `first_steps`
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

/// Offline mirror of the server catalogue in `src/lib/gamification.ts`.
///
/// `GET /api/mobile/badges` is the source of truth; this list only covers the
/// case where that call fails. Codes, labels, and descriptions are copied from
/// the server verbatim - an entry the server never awards would be a badge the
/// player can never unlock, so nothing is invented here.
const List<BadgeDefinition> kFallbackBadgeCatalog = <BadgeDefinition>[
  BadgeDefinition(
    code: 'first_steps',
    label: 'Eerste Stappen',
    icon: Icons.star_border,
    description: 'Voltooi je eerste quiz.',
    aliases: <String>['eerste quiz', 'first quiz'],
  ),
  BadgeDefinition(
    code: 'knowledge_seeker',
    label: 'Kenniszoeker',
    icon: Icons.search,
    description: 'Speel 10 verschillende quizzen.',
  ),
  BadgeDefinition(
    code: 'perfect_score',
    label: 'Foutloos',
    icon: Icons.gps_fixed,
    description: 'Haal een 100% score op een quiz.',
    aliases: <String>['perfecte score'],
  ),
  BadgeDefinition(
    code: 'streak_3',
    label: 'Op Dreef',
    icon: Icons.local_fire_department_outlined,
    description: 'Bouw een streak van 3 dagen op.',
  ),
  BadgeDefinition(
    code: 'streak_7',
    label: 'Toegewijd',
    icon: Icons.local_fire_department_outlined,
    description: 'Speel 7 dagen op rij.',
    aliases: <String>['7 dagen reeks', 'week streak'],
  ),
  BadgeDefinition(
    code: 'scholar',
    label: 'Geleerde',
    icon: Icons.school_outlined,
    description: 'Behaal niveau 5.',
  ),
  BadgeDefinition(
    code: 'master',
    label: 'Meester',
    icon: Icons.emoji_events_outlined,
    description: 'Behaal niveau 10.',
    aliases: <String>['quiz meester'],
  ),
  BadgeDefinition(
    code: 'all_rounder',
    label: 'Allrounder',
    icon: Icons.public,
    description: 'Speel een brede selectie quizzen.',
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
