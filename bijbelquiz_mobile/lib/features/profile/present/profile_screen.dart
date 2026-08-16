import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/notifications/streak_reminder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../leaderboard/data/leaderboard_repository.dart';
import '../../leaderboard/domain/leaderboard_entry.dart';
import '../../auth/present/auth_controller.dart';
import '../data/badge_catalog.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: RefreshIndicator(
        color: AppTheme.ink,
        backgroundColor: AppTheme.paperRaised,
        onRefresh: () async {
          ref.invalidate(profileProvider);
          await ref.read(profileProvider.future);
        },
        child: profileAsync.when(
          data: (profile) => _ProfileContent(
            profile: profile,
            rank: _findLeaderboardRank(
              profile: profile,
              entries: leaderboardAsync.asData?.value,
            ),
            onOpenSettings: () => _openSettingsSheet(context, ref, profile),
            onViewAllAchievements: () {
              context.push('/profile/achievements');
            },
            onEditIdentity: () {
              context.push('/profile/edit');
            },
          ),
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 260), AppLoader()],
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 100),
              AppEmptyState(
                icon: Icons.error_outline,
                title: 'Profiel kon niet laden',
                description: '$err',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _findLeaderboardRank({
    required ProfileModel profile,
    required List<LeaderboardEntry>? entries,
  }) {
    if (entries == null || entries.isEmpty) {
      return null;
    }

    final sorted = [...entries]..sort((a, b) => b.xp.compareTo(a.xp));

    var index = sorted.indexWhere((entry) => entry.id == profile.id);

    if (index < 0) {
      final normalizedName = profile.name.trim().toLowerCase();
      if (normalizedName.isNotEmpty) {
        index = sorted.indexWhere(
          (entry) => entry.name.trim().toLowerCase() == normalizedName,
        );
      }
    }

    return index >= 0 ? index + 1 : null;
  }

  /// Sheet styled like the site's dropdown menu:
  /// `rounded-lg border border-rule bg-paper-raised p-1.5`.
  Future<void> _openSettingsSheet(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.paperRaised,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(width: 36, height: 3, color: AppTheme.rule),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('INSTELLINGEN', style: AppTheme.overline),
              ),
              const SizedBox(height: 14),
              const RuleLine(),
              if (!profile.isPremium)
                _SheetTile(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Ontdek Premium',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/premium');
                  },
                ),
              _StreakReminderTile(profile: profile),
              _SheetTile(
                icon: Icons.refresh,
                label: 'Profiel vernieuwen',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.invalidate(profileProvider);
                },
              ),
              _SheetTile(
                icon: Icons.logout,
                label: 'Uitloggen',
                color: AppTheme.destructive,
                showRule: false,
                onTap: () async {
                  Navigator.of(sheetContext).pop();

                  final storage = ref.read(authStorageProvider);
                  await storage.deleteToken();
                  ref.invalidate(profileProvider);
                  ref.invalidate(authControllerProvider);

                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

/// The evening reminder switch.
///
/// Off until switched on here or accepted in the prompt after a quiz. Flipping
/// it on is what triggers the OS permission dialog, and a refusal there puts
/// the switch straight back to off rather than pretending it worked.
class _StreakReminderTile extends ConsumerWidget {
  const _StreakReminderTile({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(streakReminderEnabledProvider).asData?.value ?? false;

    Future<void> toggle(bool value) async {
      final result = await StreakReminder.instance.setEnabled(
        value,
        streak: profile.streak,
        lastPlayedAt: profile.lastPlayedAt,
      );

      ref.invalidate(streakReminderEnabledProvider);

      if (!context.mounted) return;
      if (value && !result) {
        AppNotice.info(
          context,
          'Meldingen staan uit voor BijbelQuiz. Zet ze aan in de '
          'instellingen van je telefoon.',
        );
      }
    }

    return RuleListTile(
      onTap: () => toggle(!enabled),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_none,
            size: 18,
            color: AppTheme.ink,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reeksherinnering', style: AppTheme.bodyStrong),
                const SizedBox(height: 2),
                Text('Elke avond om 19:00, alleen als je nog niet '
                    'gespeeld hebt.', style: AppTheme.bodyMuted),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppTheme.paper,
            activeTrackColor: AppTheme.ink,
            onChanged: toggle,
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.ink,
    this.showRule = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    return RuleListTile(
      onTap: onTap,
      showRule: showRule,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyStrong.copyWith(color: color),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 13, color: AppTheme.inkMuted),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.rank,
    required this.onOpenSettings,
    required this.onViewAllAchievements,
    required this.onEditIdentity,
  });

  final ProfileModel profile;
  final int? rank;
  final VoidCallback onOpenSettings;
  final VoidCallback onViewAllAchievements;
  final VoidCallback onEditIdentity;

  @override
  Widget build(BuildContext context) {
    // Every figure below is the server's, not ours. The XP ladder is not
    // linear (500, 1000, 1500, ... per level), so any local band arithmetic
    // would disagree with both the website and the level shown right here.
    final averageScore = profile.averageScore;
    final progress = profile.levelFraction;
    final xpRemaining = profile.xpToNextLevel;
    final isMaxLevel = xpRemaining == 0;

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Profiel'),
                    const SizedBox(height: 14),
                    Text(profile.name, style: AppTheme.displayLarge),
                    const SizedBox(height: 10),
                    Text(profile.email, style: AppTheme.bodyLead),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Tapping the mascot is the primary way into the customiser;
              // the pencil below it is there for anyone who does not read a
              // picture as a button.
              GestureDetector(
                onTap: onEditIdentity,
                child: Column(
                  children: [
                    MascotAvatar(
                      avatar: profile.avatar,
                      size: 72,
                      bordered: true,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: AppTheme.inkMuted,
                        ),
                        SizedBox(width: 4),
                        Text('Bewerken', style: AppTheme.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // `h-9 w-9 rounded-md border-rule bg-paper-raised text-ink`
              Material(
                color: AppTheme.paperRaised,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  onTap: onOpenSettings,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.rule),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppTheme.inkSoft,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SiteBadge.neutral('Level ${profile.level}'),
              SiteBadge.lapis(rank == null ? 'Rang -' : 'Rang #$rank'),
              if (profile.isPremium) SiteBadge.vermilion('Premium'),
            ],
          ),
          const SizedBox(height: 28),
          StatStrip(
            stacked: true,
            items: [
              StatItem(
                value: '${profile.quizzesPlayed}',
                label: 'Quizzen',
              ),
              StatItem(
                value: '$averageScore%',
                label: 'Score',
                ruleColor: AppTheme.positive,
              ),
              StatItem(value: _formatNumber(profile.xp), label: 'Punten'),
            ],
          ),
          const SizedBox(height: 40),
          const SectionHeader(
            eyebrow: 'Voortgang',
            title: 'Naar het volgende level',
          ),
          const SizedBox(height: 24),
          _ProgressCard(
            level: profile.level,
            levelTitle: profile.levelTitle,
            xp: profile.xp,
            nextLevelXp: profile.nextLevelXp,
            xpRemaining: xpRemaining,
            progress: progress,
            isMaxLevel: isMaxLevel,
          ),
          const SizedBox(height: 40),
          const SectionHeader(eyebrow: 'Statistieken', title: 'Jouw cijfers'),
          const SizedBox(height: 24),
          RuleGrid(
            children: [
              _StatRow(
                label: 'Quizzen gespeeld',
                value: '${profile.quizzesPlayed}',
              ),
              _StatRow(label: 'Nauwkeurigheid', value: '$averageScore%'),
              _StatRow(
                label: 'Reeks',
                value:
                    '${profile.streak} ${profile.streak == 1 ? 'dag' : 'dagen'}',
              ),
              _StatRow(label: 'Punten', value: _formatNumber(profile.xp)),
            ],
          ),
          const SizedBox(height: 40),
          SectionHeader(
            eyebrow: 'Prestaties',
            title: 'Behaalde badges',
            actionLabel: 'Bekijk alles',
            onAction: onViewAllAchievements,
          ),
          const SizedBox(height: 24),
          _AchievementsRow(badges: profile.badges),
          const SizedBox(height: 40),
          const SectionHeader(eyebrow: 'Activiteit', title: 'Recent gespeeld'),
          const SizedBox(height: 24),
          _RecentActivityList(recentProgress: profile.recentProgress),
        ],
      ),
    );
  }

}

/// `rounded-lg border border-rule bg-paper-raised p-5` with a 2px progress
/// rule - the site never rounds or thickens its bars.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.level,
    required this.levelTitle,
    required this.xp,
    required this.nextLevelXp,
    required this.xpRemaining,
    required this.progress,
    required this.isMaxLevel,
  });

  final int level;
  final String levelTitle;
  final int xp;
  final int nextLevelXp;
  final int xpRemaining;
  final double progress;
  final bool isMaxLevel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Level $level - $levelTitle',
                  style: AppTheme.displayBase,
                ),
              ),
              Text(
                isMaxLevel
                    ? '${_formatNumber(xp)} XP'
                    : '${_formatNumber(xp)} / ${_formatNumber(nextLevelXp)} XP',
                style: AppTheme.caption.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 2,
            width: double.infinity,
            color: AppTheme.paperSunken,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: AppTheme.ink),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isMaxLevel
                ? 'Hoogste level bereikt.'
                : '${_formatNumber(xpRemaining)} XP tot level ${level + 1}',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}

/// Label / value row inside a hairline grid.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label.toUpperCase(), style: AppTheme.overline)),
          Text(value, style: AppTheme.statNumber.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}

class _AchievementsRow extends ConsumerWidget {
  const _AchievementsRow({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog =
        ref.watch(badgeCatalogProvider).asData?.value ?? kFallbackBadgeCatalog;

    // Badges the account holds that the catalogue does not describe still get
    // a tile, so nothing earned goes missing here.
    final items = <BadgeDefinition>[
      ...catalog,
      ...badges
          .where((badge) => !catalog.any((entry) => entry.matches(badge)))
          .map((badge) => resolveBadge(badge, catalog)),
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final active = item.isUnlockedBy(badges);

          // Unlocked badges carry the lapis tint the site uses for accents.
          return Container(
            width: 104,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? AppTheme.lapisTint : AppTheme.paperRaised,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: active
                    ? AppTheme.lapis.withValues(alpha: 0.35)
                    : AppTheme.rule,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: active ? AppTheme.lapis : AppTheme.ruleStrong,
                ),
                const Spacer(),
                Text(
                  item.label.toUpperCase(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.overline.copyWith(
                    color: active ? AppTheme.lapis : AppTheme.inkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.recentProgress});

  final List<RecentProgressModel> recentProgress;

  @override
  Widget build(BuildContext context) {
    if (recentProgress.isEmpty) {
      return const AppCard(
        child: Text(
          'Nog geen recente activiteit gevonden.',
          style: AppTheme.bodyMuted,
        ),
      );
    }

    final visible = recentProgress.take(5).toList();

    return RuleGrid(
      children: [
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.totalQuestions > 0
                            ? '${item.score}/${item.totalQuestions} GOED'
                            : 'VOLTOOID',
                        style: AppTheme.overline,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.quizTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.displayBase,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  // `score` is a correct-answer count, not a percentage.
                  '${(item.accuracy * 100).round()}%',
                  style: AppTheme.statNumber.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _formatNumber(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}
