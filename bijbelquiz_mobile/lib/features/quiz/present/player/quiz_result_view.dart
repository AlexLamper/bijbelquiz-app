import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../../core/ui/bq.dart';
import '../../../profile/data/profile_model.dart';
import '../../../profile/present/profile_provider.dart';
import '../../domain/quiz.dart';
import '../../domain/quiz_submission_result.dart';
import 'player_widgets.dart';
import 'quiz_review_sheet.dart';

/// The result page after the last question.
///
/// Every number on it is the server's: XP from the submission, level progress
/// from the profile it refreshed. While the attempt is still being saved, or
/// when it could not be, the progress card says so instead of guessing.
class QuizResultView extends ConsumerWidget {
  const QuizResultView({
    super.key,
    required this.quiz,
    required this.correctCount,
    required this.picks,
    required this.parkedForAccount,
    required this.submitting,
    required this.submitFailed,
    required this.result,
    required this.isNewBest,
    required this.onRetrySubmit,
  });

  final Quiz quiz;
  final int correctCount;

  /// Question index -> the answer index the player picked.
  final Map<int, int> picks;

  /// Played signed out: the attempt is parked on this device.
  final bool parkedForAccount;
  final bool submitting;
  final bool submitFailed;
  final QuizSubmissionResult? result;
  final bool isNewBest;
  final VoidCallback onRetrySubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = quiz.questions.length;
    final profileAsync = ref.watch(profileProvider);
    final profile = parkedForAccount ? null : profileAsync.asData?.value;

    // Signed out: what a new account would get for this attempt, by the same
    // rule the server applies (the quiz's reward scaled by the share correct).
    // A first attempt has no earlier best to beat, so unlike the signed-in
    // case this is not a promise the account cannot keep.
    final previewXp = total == 0
        ? 0
        : (quiz.xpReward * correctCount / total).round();

    final firstName = (profile?.name ?? '').trim().split(RegExp(r'\s+')).first;
    final doingWell = total == 0 || correctCount * 2 >= total;
    final praise = doingWell ? 'Mooi gespeeld' : 'Goed geprobeerd';
    final greeting = firstName.isEmpty ? '$praise!' : '$praise, $firstName';

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.maxHeight - 34),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(-2, 0),
                      child: PlayerCloseButton(
                        label: 'Sluiten',
                        onTap: () => context.go('/home'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quiz.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ScoreCard(
                  correct: correctCount,
                  total: total,
                  greeting: greeting,
                  isNewBest: isNewBest && !parkedForAccount,
                ),
                const SizedBox(height: 16),
                if (parkedForAccount)
                  _SaveScoreCard(previewXp: previewXp)
                else
                  _ProgressCard(
                    submitting: submitting,
                    submitFailed: submitFailed,
                    result: result,
                    // Only once the refetch the submission triggered has
                    // landed - the cached profile still shows the old totals.
                    profile: profileAsync.isLoading ? null : profile,
                    onRetry: onRetrySubmit,
                  ),
                const Spacer(),
                const SizedBox(height: 20),
                BqButton(
                  label: 'Volgende quiz',
                  onPressed: () => context.go('/quizzes'),
                ),
                const SizedBox(height: 12),
                BqButton(
                  label: 'Daag een vriend uit',
                  style: BqButtonStyle.secondary,
                  icon: const BqIcon(
                    PlayerIcons.swords,
                    size: 18,
                    color: AppTheme.vermilion,
                  ),
                  onPressed: () => context.push('/duels/new'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TextLink(
                      label: 'Bekijk antwoorden',
                      onTap: () => showQuizReviewSheet(
                        context,
                        quiz: quiz,
                        picks: Map.of(picks),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _TextLink(
                      label: 'Ranglijst',
                      onTap: () => context.go('/leaderboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Big green ring, the greeting and the "Nieuwe beste score" badge.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.correct,
    required this.total,
    required this.greeting,
    required this.isNewBest,
  });

  final int correct;
  final int total;
  final String greeting;
  final bool isNewBest;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Semantics(
            label: 'Score $correct van $total',
            excludeSemantics: true,
            child: SizedBox(
              width: 148,
              height: 148,
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  value: total == 0 ? 0 : correct / total,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$correct/$total',
                            style: const TextStyle(
                              fontFamily: AppTheme.sansFontName,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 44 / 40,
                              color: AppTheme.ink,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            'goed',
                            style: TextStyle(
                              fontFamily: AppTheme.sansFontName,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: AppTheme.displayLarge,
          ),
          if (isNewBest) ...[
            const SizedBox(height: 10),
            const PlayerChip(
              label: 'Nieuwe beste score',
              icon: PlayerIcons.trophy,
              height: 28,
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.value});

  final double value;

  static const double _stroke = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // r=64 in a 148 box, as in the design's SVG.
    final radius = size.shortestSide / 2 - 4 - _stroke / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = AppTheme.ruleSoft;
    canvas.drawCircle(center, radius, track);

    final v = value.clamp(0.0, 1.0);
    if (v <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.positive;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * v,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) =>
      oldDelegate.value != value;
}

/// XP earned, the way to the next level, and the streak.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.submitting,
    required this.submitFailed,
    required this.result,
    required this.profile,
    required this.onRetry,
  });

  final bool submitting;
  final bool submitFailed;
  final QuizSubmissionResult? result;
  final ProfileModel? profile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final result = this.result;

    if (result == null) {
      // Saving, or saving failed: say which, and offer another go.
      final failed = submitFailed && !submitting;
      return BqCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const BqIconTile(
              background: AppTheme.goldTint,
              child: BqIcon(BqIcons.bolt, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TwoLines(
                title: failed
                    ? 'Je score is nog niet opgeslagen'
                    : 'Je score wordt opgeslagen',
                subtitle: failed
                    ? 'Controleer je verbinding en probeer het opnieuw.'
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            if (failed)
              _TextLink(label: 'Opnieuw', onTap: onRetry)
            else
              const AppLoader(size: 18),
          ],
        ),
      );
    }

    final profile = this.profile;
    final earned = result.xpEarned;
    final title = earned > 0
        ? '+${formatPlayerNumber(earned)} XP verdiend'
        : 'Geen extra XP deze keer';

    String? subtitle;
    double? levelFraction;
    var levelLabel = '';
    if (earned <= 0) {
      // Only the server awards XP, and a replay that beats no earlier attempt
      // awards none.
      subtitle = 'Een herhaling telt alleen mee als je jezelf verbetert.';
    }
    if (profile != null) {
      final atTop = profile.xpToNextLevel <= 0;
      levelFraction = atTop ? 1 : profile.levelFraction;
      levelLabel = atTop
          ? 'Level ${profile.level}'
          : 'Voortgang naar level ${profile.level + 1}';
      subtitle ??= atTop
          ? 'Level ${profile.level} - ${profile.levelTitle}'
          : 'Nog ${formatPlayerNumber(profile.xpToNextLevel)} XP tot level '
                '${profile.level + 1}';
    }

    final streak = result.streak > 0 ? result.streak : (profile?.streak ?? 0);

    return BqCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const BqIconTile(
                      background: AppTheme.goldTint,
                      child: BqIcon(BqIcons.bolt, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TwoLines(title: title, subtitle: subtitle),
                    ),
                  ],
                ),
                if (levelFraction != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    label: levelLabel,
                    value: '${(levelFraction * 100).round()}%',
                    excludeSemantics: true,
                    child: BqProgressBar(value: levelFraction),
                  ),
                ],
              ],
            ),
          ),
          if (streak > 0) ...[
            const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const BqIconTile(
                    background: AppTheme.coralTint,
                    child: BqIcon(BqIcons.flame, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TwoLines(
                      title: 'Reeks van $streak ${streak == 1 ? 'dag' : 'dagen'}',
                      subtitle: 'Speel morgen om je reeks te houden',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The offer to keep a signed-out score.
///
/// Both actions lead to the auth screens, which land on the profile tab on
/// success; the parked attempt is written on the way (see
/// `PendingAttemptClaimer`), so the XP named here is what appears there.
class _SaveScoreCard extends StatelessWidget {
  const _SaveScoreCard({required this.previewXp});

  final int previewXp;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BqIconTile(
                background: AppTheme.goldTint,
                child: BqIcon(BqIcons.bolt, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TwoLines(
                  title:
                      'Bewaar je score, ${formatPlayerNumber(previewXp)} XP en '
                      'je reeks',
                  subtitle:
                      'Log in of maak een gratis account, dan wordt deze '
                      'score direct bijgeschreven. Je quizzen tellen dan mee '
                      'voor je niveau en de ranglijst.',
                  subtitleLines: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BqButton(
            label: 'Gratis account aanmaken',
            style: BqButtonStyle.tint,
            height: 46,
            onPressed: () => context.push('/register'),
          ),
          Center(
            child: _TextLink(
              label: 'Inloggen',
              onTap: () => context.push('/login'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoLines extends StatelessWidget {
  const _TwoLines({
    required this.title,
    this.subtitle,
    this.subtitleLines = 2,
  });

  final String title;
  final String? subtitle;
  final int subtitleLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 20 / 15,
            color: AppTheme.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            maxLines: subtitleLines,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.caption,
          ),
        ],
      ],
    );
  }
}

/// Lapis text link with a 44px tap target.
class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lapis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
