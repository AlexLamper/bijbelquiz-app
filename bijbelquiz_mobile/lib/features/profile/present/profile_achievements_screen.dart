import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';

class ProfileAchievementsScreen extends ConsumerWidget {
  const ProfileAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.ink,
        backgroundColor: AppTheme.paperRaised,
        onRefresh: () async {
          ref.invalidate(profileProvider);
          await ref.read(profileProvider.future);
        },
        child: profileAsync.when(
          data: (profile) => _AchievementsContent(profile: profile),
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 280), AppLoader()],
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 100),
              AppEmptyState(
                icon: Icons.error_outline,
                title: 'Prestaties konden niet laden',
                description: '$err',
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        const GradientHeader(
          eyebrow: 'Prestaties',
          title: 'Jouw badges',
          subtitle:
              'Speel quizzen, houd je reeks vast en ontgrendel elke prestatie.',
        ),
        const SizedBox(height: 28),
        StatStrip(
          stacked: true,
          items: [
            StatItem(value: '$unlockedCount', label: 'Ontgrendeld'),
            StatItem(value: '${_definitions.length}', label: 'Totaal'),
            StatItem(
              value: '${profile.badges.length}',
              label: 'Badges',
              ruleColor: AppTheme.positive,
            ),
          ],
        ),
        const SizedBox(height: 40),
        const SectionHeader(eyebrow: 'Account', title: 'Badges uit je account'),
        const SizedBox(height: 24),
        if (profile.badges.isEmpty)
          const AppCard(
            child: Text(
              'Nog geen badges behaald. Speel quizzen om je eerste badge vrij '
              'te spelen.',
              style: AppTheme.bodyMuted,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.badges
                .map((badge) => SiteBadge.lapis(badge))
                .toList(),
          ),
        const SizedBox(height: 40),
        const SectionHeader(eyebrow: 'Overzicht', title: 'Alle prestaties'),
        const SizedBox(height: 24),
        RuleGrid(
          children: [
            for (final definition in _definitions)
              _AchievementTile(
                definition: definition,
                unlocked: definition.isUnlocked(normalizedBadges),
              ),
          ],
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
    final accent = unlocked ? AppTheme.positive : AppTheme.inkMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            definition.icon,
            size: 20,
            color: unlocked ? AppTheme.ink : AppTheme.ruleStrong,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition.label,
                  style: AppTheme.displayBase.copyWith(
                    color: unlocked ? AppTheme.ink : AppTheme.inkMuted,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unlocked ? 'ONTGRENDELD' : 'NOG NIET BEHAALD',
                  style: AppTheme.overline.copyWith(color: accent),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check : Icons.lock_outline,
            color: accent,
            size: 16,
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
    this.aliases = const [],
  });

  final String label;
  final IconData icon;
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
    'Eerste quiz',
    Icons.star_border,
    aliases: ['eerste quiz'],
  ),
  _AchievementDefinition(
    '7-dagen reeks',
    Icons.local_fire_department_outlined,
    aliases: ['7 dagen', 'streak'],
  ),
  _AchievementDefinition(
    'Quiz meester',
    Icons.emoji_events_outlined,
    aliases: ['meester'],
  ),
  _AchievementDefinition(
    'Perfecte score',
    Icons.gps_fixed,
    aliases: ['perfect', '100%'],
  ),
  _AchievementDefinition(
    '100 quizzen',
    Icons.auto_awesome_outlined,
    aliases: ['100 quiz'],
  ),
];
