import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/badge_catalog.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';

class ProfileAchievementsScreen extends ConsumerWidget {
  const ProfileAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final catalog =
        ref.watch(badgeCatalogProvider).asData?.value ?? kFallbackBadgeCatalog;

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
          ref.invalidate(badgeCatalogProvider);
          await ref.read(profileProvider.future);
        },
        child: profileAsync.when(
          data: (profile) =>
              _AchievementsContent(profile: profile, catalog: catalog),
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
  const _AchievementsContent({required this.profile, required this.catalog});

  final ProfileModel profile;
  final List<BadgeDefinition> catalog;

  @override
  Widget build(BuildContext context) {
    final earned = profile.badges
        .map((badge) => badge.trim())
        .where((badge) => badge.isNotEmpty)
        .toList();

    // A badge the profile carries but the catalogue does not describe still
    // belongs on the screen, so the overview is the catalogue plus whatever
    // extra the account holds.
    final overview = <BadgeDefinition>[
      ...catalog,
      ...earned
          .where((badge) => !catalog.any((entry) => entry.matches(badge)))
          .map((badge) => resolveBadge(badge, catalog)),
    ];

    final unlockedCount = overview
        .where((definition) => definition.isUnlockedBy(earned))
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
            StatItem(value: '${overview.length}', label: 'Totaal'),
            StatItem(
              value: '${earned.length}',
              label: 'Badges',
              ruleColor: AppTheme.positive,
            ),
          ],
        ),
        const SizedBox(height: 40),
        const SectionHeader(eyebrow: 'Account', title: 'Badges uit je account'),
        const SizedBox(height: 24),
        if (earned.isEmpty)
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
            children: earned
                .map(
                  (badge) => SiteBadge.lapis(resolveBadge(badge, catalog).label),
                )
                .toList(),
          ),
        const SizedBox(height: 40),
        const SectionHeader(eyebrow: 'Overzicht', title: 'Alle prestaties'),
        const SizedBox(height: 24),
        RuleGrid(
          children: [
            for (final definition in overview)
              _AchievementTile(
                definition: definition,
                unlocked: definition.isUnlockedBy(earned),
              ),
          ],
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.definition, required this.unlocked});

  final BadgeDefinition definition;
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
                if (definition.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    definition.description,
                    style: AppTheme.bodyMuted,
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  unlocked ? 'ONTGRENDELD' : 'NOG NIET BEHAALD',
                  style: AppTheme.overline.copyWith(color: accent),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

