import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../leaderboard/data/leaderboard_repository.dart';
import '../../leaderboard/domain/leaderboard_entry.dart';
import '../../auth/present/auth_controller.dart';
import '../data/profile_model.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF4),
      body: RefreshIndicator(
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
          ),
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 260),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(
                Icons.error_outline,
                size: 52,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Fout bij laden van profiel: $err',
                textAlign: TextAlign.center,
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

  Future<void> _openSettingsSheet(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              if (!profile.isPremium)
                ListTile(
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: const Text('Ontdek Premium'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/premium');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Profiel vernieuwen'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.invalidate(profileProvider);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Uitloggen',
                  style: TextStyle(color: Colors.redAccent),
                ),
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
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.rank,
    required this.onOpenSettings,
    required this.onViewAllAchievements,
  });

  final ProfileModel profile;
  final int? rank;
  final VoidCallback onOpenSettings;
  final VoidCallback onViewAllAchievements;

  @override
  Widget build(BuildContext context) {
    final averageScore = _calculateAverageScore(profile.recentProgress);

    const levelSpan = 1000;
    final currentXpInLevel = profile.xp % levelSpan;
    final progress = (currentXpInLevel / levelSpan).clamp(0.0, 1.0);
    final xpRemaining = (levelSpan - currentXpInLevel).clamp(0, levelSpan);

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profiel',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.sansFontName,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onOpenSettings,
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: AppTheme.ink,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProfileHeaderCard(profile: profile, rank: rank),
          const SizedBox(height: 12),
          _ProgressCard(
            level: profile.level,
            currentXpInLevel: currentXpInLevel,
            levelSpan: levelSpan,
            xpRemaining: xpRemaining,
            progress: progress,
          ),
          const SizedBox(height: 18),
          const Text(
            'Jouw Statistieken',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.sansFontName,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2,
            children: [
              _StatCard(
                title: 'Quizzen',
                value: '${profile.recentProgress.length}',
                icon: Icons.quiz_outlined,
                iconColor: const Color(0xFF6D86DB),
              ),
              _StatCard(
                title: 'Nauwkeurigheid',
                value: '$averageScore%',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFF18A96B),
              ),
              _StatCard(
                title: 'Reeks',
                value: '${profile.streak}',
                unit: profile.streak == 1 ? 'dag' : 'dagen',
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFFF17A31),
              ),
              _StatCard(
                title: 'Punten',
                value: _formatNumber(profile.xp),
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFE9A522),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Prestaties',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.sansFontName,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAllAchievements,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Bekijk alles',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AchievementsRow(badges: profile.badges),
          const SizedBox(height: 18),
          const Text(
            'Recente Activiteit',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.sansFontName,
            ),
          ),
          const SizedBox(height: 10),
          _RecentActivityList(recentProgress: profile.recentProgress),
        ],
      ),
    );
  }

  int _calculateAverageScore(List<RecentProgressModel> recentProgress) {
    if (recentProgress.isEmpty) return 0;

    final totalScore = recentProgress.fold<int>(
      0,
      (sum, item) => sum + item.score,
    );

    return (totalScore / recentProgress.length).round().clamp(0, 100);
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.rank});

  final ProfileModel profile;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.isEmpty ? 'U' : profile.name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC5D0E7), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.sansFontName,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.sansFontName,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(label: 'Level ${profile.level}'),
                    _InfoPill(
                      label: rank == null ? 'Rang onbekend' : 'Rang #$rank',
                    ),
                    if (profile.isPremium)
                      const _InfoPill(
                        label: 'Premium',
                        tint: Color(0xFFFFF3D6),
                        textColor: Color(0xFFB07B00),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    this.tint = AppTheme.accentSoft,
    this.textColor = AppTheme.accent,
  });

  final String label;
  final Color tint;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD2DAEB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.level,
    required this.currentXpInLevel,
    required this.levelSpan,
    required this.xpRemaining,
    required this.progress,
  });

  final int level;
  final int currentXpInLevel;
  final int levelSpan;
  final int xpRemaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2DAEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.sansFontName,
                  ),
                ),
              ),
              Text(
                '${_formatNumber(currentXpInLevel)}/${_formatNumber(levelSpan)} XP',
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFEFF3FC),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(xpRemaining)} XP tot Level ${level + 1}',
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.iconColor = AppTheme.accent,
  });

  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD2DAEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 15),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.sansFontName,
                    height: 1,
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  const _AchievementsRow({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final defaults = <_AchievementItem>[
      const _AchievementItem(
        'Eerste Quiz',
        Icons.star_border_rounded,
        color: Color(0xFFE3A623),
        tint: Color(0xFFFFF2D5),
      ),
      const _AchievementItem(
        '7-Dagen\nReeks',
        Icons.local_fire_department_outlined,
        color: Color(0xFFE87E2F),
        tint: Color(0xFFFFE8D6),
      ),
      const _AchievementItem(
        'Quiz Meester',
        Icons.emoji_events_outlined,
        color: Color(0xFF8A6CE0),
        tint: Color(0xFFEDE7FF),
      ),
      const _AchievementItem(
        'Perfecte\nScore',
        Icons.gps_fixed_rounded,
        color: Color(0xFF2EAA7F),
        tint: Color(0xFFDFF5EC),
      ),
      const _AchievementItem(
        '100 Quizzen',
        Icons.auto_awesome_rounded,
        color: Color(0xFF4C8BF3),
        tint: Color(0xFFE4EEFF),
      ),
    ];

    final normalizedBadges = badges.map((badge) => badge.toLowerCase()).toSet();

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = defaults[index];
          final active =
              index < badges.length ||
              normalizedBadges.any((badge) => badge.contains(item.matchKey));

          return SizedBox(
            width: 74,
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: active ? item.tint : const Color(0xFFDCE2EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: active ? item.color : const Color(0xFF9AA6BC),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? AppTheme.ink : const Color(0xFF9AA6BC),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.16,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: defaults.length,
      ),
    );
  }
}

class _AchievementItem {
  const _AchievementItem(
    this.label,
    this.icon, {
    required this.color,
    required this.tint,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;

  String get matchKey {
    return label.replaceAll('\n', ' ').replaceAll('-', ' ').toLowerCase();
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.recentProgress});

  final List<RecentProgressModel> recentProgress;

  @override
  Widget build(BuildContext context) {
    if (recentProgress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD2DAEB)),
        ),
        child: const Text(
          'Nog geen recente activiteit gevonden.',
          style: TextStyle(color: AppTheme.muted),
        ),
      );
    }

    final visible = recentProgress.take(5).toList();

    return Column(
      children: visible.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD2DAEB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.quizTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.isCompleted ? 'Voltooid' : 'In voortgang',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${item.score}%',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
      buffer.write(',');
    }
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}
