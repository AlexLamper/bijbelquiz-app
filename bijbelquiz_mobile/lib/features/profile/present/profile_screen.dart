import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../leaderboard/data/leaderboard_repository.dart';
import '../../leaderboard/domain/leaderboard_entry.dart';
import '../../quiz/data/pending_attempt_store.dart';
import '../data/badge_catalog.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';
import 'widgets/badge_medal.dart';

/// Profiel - BijbelQuiz 2.0 (`R-Profiel`).
///
/// Profile card with level bar, four stat tiles, the achievements row and the
/// Premium entry. Everything that used to live in the settings sheet here
/// (reminder, admin, logout) moved to the Instellingen screen behind the gear.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Signed out is not an error here. The app can be played without an
    // account, and this tab is where one is offered.
    final hasSession = ref.watch(hasSessionProvider).asData?.value;
    if (hasSession == false) {
      final pending =
          ref.watch(pendingAttemptsProvider).asData?.value ??
          const <PendingAttempt>[];
      return Scaffold(
        backgroundColor: AppTheme.paper,
        body: _GuestProfileContent(pending: pending),
      );
    }

    final profileAsync = ref.watch(profileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

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
          child: profileAsync.when(
            data: (profile) => _ProfileContent(
              profile: profile,
              rank: _findLeaderboardRank(
                profile: profile,
                entries: leaderboardAsync.asData?.value,
              ),
            ),
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: const [
                _PageHeader(),
                SizedBox(height: 200),
                AppLoader(),
              ],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                const _PageHeader(),
                const SizedBox(height: 60),
                AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Profiel kon niet laden',
                  description: '$err',
                ),
              ],
            ),
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
}

/// "Profiel" + the gear that opens Instellingen.
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: const Text('Profiel', style: AppTheme.displayLarge),
          ),
        ),
        _RoundIconButton(
          icon: BqIcons.gear,
          label: 'Instellingen',
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

/// 40px white round button with a 44px tap area.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.paperRaised,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppTheme.rule),
                  ),
                ),
                alignment: Alignment.center,
                child: BqIcon(icon, size: 20, color: AppTheme.lapis),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile, required this.rank});

  final ProfileModel profile;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const _PageHeader(),
        const SizedBox(height: 14),
        _ProfileCard(profile: profile, rank: rank),
        const SizedBox(height: 16),
        const _SectionTitle('Statistieken'),
        const SizedBox(height: 8),
        _StatsGrid(profile: profile),
        // The "Alle N van M" link is 44 high to tap, which adds its own
        // breathing room around the section title.
        const SizedBox(height: 6),
        _AchievementsSection(
          badges: profile.badges,
          onViewAll: () => context.push('/profile/achievements'),
        ),
        const SizedBox(height: 16),
        _PremiumRow(isPremium: profile.isPremium),
        if (profile.recentProgress.isNotEmpty) ...[
          const SizedBox(height: 16),
          const _SectionTitle('Recent gespeeld'),
          const SizedBox(height: 8),
          _RecentActivityList(recentProgress: profile.recentProgress),
        ],
      ],
    );
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

/// White card: mascot, name, level pill and the gold XP bar.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.rank});

  final ProfileModel profile;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    // Every figure below is the server's, not ours. The XP ladder is not
    // linear (500, 1000, 1500, ... per level), so any local band arithmetic
    // would disagree with both the website and the level shown right here.
    final xpRemaining = profile.xpToNextLevel;
    final isMaxLevel = xpRemaining == 0;
    final subtitle = rank == null
        ? profile.levelTitle
        : '${profile.levelTitle} - plek $rank';

    return Semantics(
      container: true,
      label: '${profile.name}, level ${profile.level}',
      child: BqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _EditableAvatar(
                  profile: profile,
                  onTap: () => context.push('/profile/edit'),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.displayFontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 26 / 22,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Top-aligned like the design, while avatar and name stay
                // vertically centred.
                SizedBox(
                  height: 68,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: BqPill(label: 'Level ${profile.level}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Semantics(
              label: isMaxLevel
                  ? 'Hoogste level bereikt'
                  : 'Voortgang naar level ${profile.level + 1}',
              child: BqProgressBar(
                value: isMaxLevel ? 1 : profile.levelFraction,
                height: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isMaxLevel
                  ? 'Hoogste level bereikt'
                  : 'Nog ${_formatNumber(xpRemaining)} XP tot level '
                        '${profile.level + 1}',
              style: AppTheme.metaLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// The mascot is the way into the customiser; a small pencil makes that
/// visible for anyone who does not read a picture as a button.
class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({required this.profile, required this.onTap});

  final ProfileModel profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Profiel bewerken',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.lapisTint, width: 3),
                ),
                child: ClipOval(
                  child: MascotAvatar(avatar: profile.avatar, size: 62),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.paperRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.rule),
                  ),
                  alignment: Alignment.center,
                  child: const BqIcon(
                    BqIcons.edit,
                    size: 12,
                    color: AppTheme.lapis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});

  final ProfileModel profile;

  static const String _check =
      '<svg viewBox="0 0 24 24" fill="none" stroke="#3F6B4F" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="8.5"/><path d="M8.5 12.3l2.4 2.4 4.6-4.9"/></svg>';

  @override
  Widget build(BuildContext context) {
    // Duels are not tracked on the profile yet, so the fourth tile shows the
    // lifetime accuracy the server does report.
    final tiles = [
      _StatTile(
        icon: const BqIcon(BqIcons.flame, size: 22),
        value: '${profile.streak}',
        label: 'Dagen op rij',
      ),
      _StatTile(
        icon: const BqIcon(BqIcons.bolt, size: 22),
        value: _formatNumber(profile.xp),
        label: 'Totaal XP',
      ),
      _StatTile(
        icon: const BqIcon(BqIcons.book, size: 22, color: AppTheme.lapis),
        value: _formatNumber(profile.quizzesPlayed),
        label: 'Quizzen gespeeld',
      ),
      _StatTile(
        icon: const BqIcon(_check, size: 22),
        value: '${profile.averageScore}%',
        label: 'Gemiddelde score',
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: 10),
            Expanded(child: tiles[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: tiles[2]),
            const SizedBox(width: 10),
            Expanded(child: tiles[3]),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: BqCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.statNumber,
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.metaLabel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Prestaties  Alle N van M" and four round medals, earned ones first.
class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection({required this.badges, required this.onViewAll});

  final List<String> badges;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog =
        ref.watch(badgeCatalogProvider).asData?.value ?? kFallbackBadgeCatalog;
    final overview = badgeOverview(badges, catalog);
    final unlocked = overview.where((d) => d.isUnlockedBy(badges)).toList();
    final locked = overview.where((d) => !d.isUnlockedBy(badges)).toList();
    final shown = [...unlocked, ...locked].take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Prestaties')),
            Semantics(
              button: true,
              label: 'Alle prestaties bekijken, ${unlocked.length} van '
                  '${overview.length} behaald',
              excludeSemantics: true,
              onTap: onViewAll,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onViewAll,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'Alle ${unlocked.length} van ${overview.length}',
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lapis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        BqCard(
          onTap: onViewAll,
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: i < shown.length
                      ? BadgeMedalTile(
                          definition: shown[i],
                          unlocked: shown[i].isUnlockedBy(badges),
                        )
                      : const SizedBox(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumRow extends StatelessWidget {
  const _PremiumRow({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: EdgeInsets.zero,
      child: BqListRow(
        leading: const BqIconTile(
          background: AppTheme.goldTint,
          child: BqIcon(BqIcons.crown, size: 22),
        ),
        title: 'Premium',
        subtitle: isPremium ? 'Je hebt Premium' : 'Je speelt gratis',
        // Premium players have nothing to buy, so the row is informational.
        onTap: isPremium ? null : () => context.push('/premium-intro'),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.recentProgress});

  final List<RecentProgressModel> recentProgress;

  @override
  Widget build(BuildContext context) {
    final visible = recentProgress.take(5).toList();

    return BqListCard(
      children: [
        for (final item in visible)
          BqListRow(
            leading: const BqIconTile(
              child: BqIcon(BqIcons.book, size: 20, color: AppTheme.lapis),
            ),
            title: item.quizTitle,
            subtitle: item.totalQuestions > 0
                ? '${item.score} van ${item.totalQuestions} goed'
                : 'Voltooid',
            trailing: Text(
              // `score` is a correct-answer count, not a percentage.
              '${(item.accuracy * 100).round()}%',
              style: AppTheme.statNumber.copyWith(fontSize: 15),
            ),
          ),
      ],
    );
  }
}

/// The profile tab for somebody playing without an account.
///
/// Not an error state: playing signed out is allowed, and this is the one
/// place the app explains what an account adds and offers one. Any quizzes
/// parked on the device are named, so the offer is about something concrete
/// rather than a feature list.
class _GuestProfileContent extends StatelessWidget {
  const _GuestProfileContent({required this.pending});

  final List<PendingAttempt> pending;

  static const String _sync =
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M20 11a8 8 0 0 0-14.3-4.9L4 8"/><path d="M4 4v4h4"/><path d="M4 13a8 8 0 0 0 14.3 4.9L20 16"/><path d="M20 20v-4h-4"/></svg>';

  static const List<(String, Color, Color, String)> _benefits = [
    (BqIcons.bolt, AppTheme.goldTint, AppTheme.goldText,
        'Punten, niveau en reeks die blijven staan'),
    (BqIcons.trophy, AppTheme.lapisTint, AppTheme.lapis,
        'Een plek op de ranglijst'),
    (BqIcons.shield, AppTheme.positiveTint, AppTheme.positive,
        'Badges voor je prestaties'),
    (_sync, AppTheme.lapisTint, AppTheme.lapis,
        'Dezelfde voortgang op bijbelquiz.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const _PageHeader(),
          const SizedBox(height: 14),
          BqCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bewaar je voortgang', style: AppTheme.displayTitle),
                const SizedBox(height: 6),
                const Text(
                  'Je speelt zonder account. Dat kan gewoon, maar je score, '
                  'punten en reeks blijven alleen bewaard met een gratis '
                  'account.',
                  style: AppTheme.bodyMuted,
                ),
                const SizedBox(height: 16),
                BqButton(
                  label: 'Gratis account aanmaken',
                  onPressed: () => context.push('/register'),
                ),
                const SizedBox(height: 10),
                BqButton(
                  label: 'Inloggen',
                  style: BqButtonStyle.tint,
                  onPressed: () => context.push('/login'),
                ),
              ],
            ),
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            BqCard(
              color: AppTheme.lapisTint,
              borderColor: AppTheme.lapisSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pending.length == 1
                        ? 'Eén quiz wacht op je account'
                        : '${pending.length} quizzen wachten op je account',
                    style: AppTheme.bodyStrong.copyWith(
                      color: AppTheme.lapisStrong,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pending
                        .map(
                          (attempt) =>
                              '${attempt.quizTitle} '
                              '(${attempt.correctAnswers}/${attempt.totalQuestions})',
                        )
                        .join(', '),
                    style: AppTheme.bodyMuted.copyWith(
                      color: AppTheme.lapisMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const _SectionTitle('Met een account'),
          const SizedBox(height: 8),
          BqListCard(
            children: [
              for (final benefit in _benefits)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      BqIconTile(
                        background: benefit.$2,
                        child: BqIcon(benefit.$1, size: 20, color: benefit.$3),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(benefit.$4, style: AppTheme.bodyStrong),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
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
