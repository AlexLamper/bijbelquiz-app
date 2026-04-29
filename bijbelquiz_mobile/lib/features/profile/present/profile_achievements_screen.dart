import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';

class ProfileAchievementsScreen extends ConsumerWidget {
  const ProfileAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(title: const Text('Prestaties')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          await ref.read(profileProvider.future);
        },
        child: profileAsync.when(
          data: (profile) => _AchievementsContent(profile: profile),
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 280),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Fout bij laden van prestaties: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final normalizedBadges = profile.badges
        .map((badge) => badge.trim().toLowerCase())
        .where((badge) => badge.isNotEmpty)
        .toSet();

    final unlockedCount = _definitions
        .where((definition) => definition.isUnlocked(normalizedBadges))
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jouw voortgang',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unlockedCount van ${_definitions.length} prestaties ontgrendeld',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Badges uit je account',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontFamily: AppTheme.sansFontName,
          ),
        ),
        const SizedBox(height: 8),
        if (profile.badges.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'Nog geen badges behaald. Speel quizzen om je eerste badge vrij te spelen.',
              style: TextStyle(color: AppTheme.muted),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.badges
                .map(
                  (badge) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 18),
        const Text(
          'Achievement overzicht',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontFamily: AppTheme.sansFontName,
          ),
        ),
        const SizedBox(height: 8),
        ..._definitions.map(
          (definition) => _AchievementTile(
            definition: definition,
            unlocked: definition.isUnlocked(normalizedBadges),
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.definition, required this.unlocked});

  final _AchievementDefinition definition;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: unlocked ? definition.tint : const Color(0xFFEBEEF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              definition.icon,
              color: unlocked ? definition.color : const Color(0xFF9AA6BC),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.label,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked ? 'Ontgrendeld' : 'Nog niet behaald',
                  style: TextStyle(
                    color: unlocked ? AppTheme.success : AppTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? AppTheme.success : AppTheme.muted,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _AchievementDefinition {
  const _AchievementDefinition(
    this.label,
    this.icon, {
    required this.color,
    required this.tint,
    this.aliases = const [],
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final List<String> aliases;

  bool isUnlocked(Set<String> normalizedBadges) {
    return normalizedBadges.any((badge) {
      if (badge.contains(matchKey)) {
        return true;
      }

      return aliases.any((alias) => badge.contains(alias));
    });
  }

  String get matchKey {
    return label.replaceAll('-', ' ').toLowerCase();
  }
}

const List<_AchievementDefinition> _definitions = [
  _AchievementDefinition(
    'Eerste Quiz',
    Icons.star_border_rounded,
    color: Color(0xFFE3A623),
    tint: Color(0xFFFFF2D5),
    aliases: ['eerste quiz'],
  ),
  _AchievementDefinition(
    '7-Dagen Reeks',
    Icons.local_fire_department_outlined,
    color: Color(0xFFE87E2F),
    tint: Color(0xFFFFE8D6),
    aliases: ['7 dagen', 'streak'],
  ),
  _AchievementDefinition(
    'Quiz Meester',
    Icons.emoji_events_outlined,
    color: Color(0xFF8A6CE0),
    tint: Color(0xFFEDE7FF),
    aliases: ['meester'],
  ),
  _AchievementDefinition(
    'Perfecte Score',
    Icons.gps_fixed_rounded,
    color: Color(0xFF2EAA7F),
    tint: Color(0xFFDFF5EC),
    aliases: ['perfect', '100%'],
  ),
  _AchievementDefinition(
    '100 Quizzen',
    Icons.auto_awesome_rounded,
    color: Color(0xFF4C8BF3),
    tint: Color(0xFFE4EEFF),
    aliases: ['100 quiz'],
  ),
];
