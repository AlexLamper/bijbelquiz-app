import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../data/badge_catalog.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';
import 'widgets/badge_medal.dart';

/// Prestaties: every achievement, earned ones as medals, the rest as a list
/// that says what to do for them.
class ProfileAchievementsScreen extends ConsumerWidget {
  const ProfileAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final catalog =
        ref.watch(badgeCatalogProvider).asData?.value ?? kFallbackBadgeCatalog;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.lapis,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: () async {
            ref.invalidate(profileProvider);
            ref.invalidate(badgeCatalogProvider);
            await ref.read(profileProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              BqTopBar(
                title: 'Prestaties',
                large: true,
                onBack: () =>
                    context.canPop() ? context.pop() : context.go('/profile'),
              ),
              const SizedBox(height: 16),
              ...profileAsync.when(
                data: (profile) => _content(profile, catalog),
                loading: () => const [SizedBox(height: 200), AppLoader()],
                error: (err, _) => [
                  const SizedBox(height: 60),
                  AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'Prestaties konden niet laden',
                    description: '$err',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(ProfileModel profile, List<BadgeDefinition> catalog) {
    final earned = profile.badges
        .map((badge) => badge.trim())
        .where((badge) => badge.isNotEmpty)
        .toList();

    // A badge the profile carries but the catalogue does not describe still
    // belongs on the screen.
    final overview = badgeOverview(earned, catalog);
    final unlocked = overview.where((d) => d.isUnlockedBy(earned)).toList();
    final locked = overview.where((d) => !d.isUnlockedBy(earned)).toList();

    return [
      _SummaryCard(unlocked: unlocked.length, total: overview.length),
      const SizedBox(height: 16),
      _SectionTitle('Behaald · ${unlocked.length}'),
      const SizedBox(height: 8),
      if (unlocked.isEmpty)
        const BqCard(
          child: Text(
            'Nog geen badges behaald. Speel quizzen om je eerste badge vrij '
            'te spelen.',
            style: AppTheme.bodyMuted,
          ),
        )
      else
        _MedalGrid(badges: unlocked),
      if (locked.isNotEmpty) ...[
        const SizedBox(height: 16),
        _SectionTitle('Nog te halen · ${locked.length}'),
        const SizedBox(height: 8),
        BqListCard(
          children: [
            for (final definition in locked) _LockedRow(definition: definition),
          ],
        ),
      ],
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w800,
          color: AppTheme.ink,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final left = total - unlocked;
    return Semantics(
      label: '$unlocked van $total badges behaald',
      excludeSemantics: true,
      child: BqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const BqIconTile(
                  background: AppTheme.goldTint,
                  child: BqIcon(
                    BqIcons.trophy,
                    size: 22,
                    color: AppTheme.goldText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$unlocked van $total badges',
                    style: AppTheme.displayTitle,
                  ),
                ),
                Text(
                  left == 0 ? 'Alles behaald' : 'Nog $left te halen',
                  style: AppTheme.metaLabel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (total > 0 && total <= 12)
              BqSegments(
                total: total,
                done: unlocked,
                color: AppTheme.gold,
                track: AppTheme.ruleSoft,
              )
            else
              BqProgressBar(value: total == 0 ? 0 : unlocked / total),
          ],
        ),
      ),
    );
  }
}

/// Earned medals, three to a row.
class _MedalGrid extends StatelessWidget {
  const _MedalGrid({required this.badges});

  final List<BadgeDefinition> badges;

  static const int _perRow = 3;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < badges.length; start += _perRow) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = start; i < start + _perRow; i++) ...[
              if (i > start) const SizedBox(width: 8),
              Expanded(
                child: i < badges.length
                    ? BadgeMedalTile(
                        definition: badges[i],
                        unlocked: true,
                        size: 64,
                      )
                    : const SizedBox(),
              ),
            ],
          ],
        ),
      );
    }

    return BqCard(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
      child: Column(children: rows),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.definition});

  final BadgeDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${definition.label}, nog niet behaald'
          '${definition.description.isEmpty ? '' : '. ${definition.description}'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Opacity(
              opacity: 0.7,
              child: BadgeMedal(
                definition: definition,
                unlocked: false,
                size: 44,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(definition.label, style: AppTheme.bodyStrong),
                  if (definition.description.isNotEmpty)
                    Text(definition.description, style: AppTheme.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
