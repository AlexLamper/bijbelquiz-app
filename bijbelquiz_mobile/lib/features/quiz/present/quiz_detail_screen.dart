import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../profile/data/profile_model.dart';
import '../../profile/present/profile_provider.dart';
import '../../settings/data/quiz_preferences_controller.dart';
import '../../settings/domain/quiz_preferences.dart';
import '../data/free_quiz_limit.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';
import 'widgets/quiz_cover.dart';

/// "Quiz starten": cover, title, description, the three facts, the best score
/// so far, how the quiz is played (saved to the account), and the ways in -
/// start, challenge a friend, or read the chapter first.
class QuizDetailScreen extends ConsumerWidget {
  final String idOrSlug;

  const QuizDetailScreen({super.key, required this.idOrSlug});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quizzes');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: quizAsync.when(
          data: (quiz) => _DetailBody(quiz: quiz, onBack: () => _back(context)),
          loading: () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: BqTopBar(onBack: () => _back(context)),
              ),
              const Expanded(child: AppLoader()),
            ],
          ),
          error: (err, stack) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: BqTopBar(onBack: () => _back(context)),
              ),
              Expanded(
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Quiz kon niet laden',
                  description: '$err',
                  action: BqButton(
                    label: 'Opnieuw proberen',
                    style: BqButtonStyle.secondary,
                    height: 44,
                    expand: false,
                    onPressed: () =>
                        ref.invalidate(quizDetailProvider(idOrSlug)),
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

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.quiz, required this.onBack});

  final Quiz quiz;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(quizPreferencesProvider);
    final profile = ref.watch(profileProvider).asData?.value;
    final allowance = ref.watch(freeQuizAllowanceProvider).asData?.value;
    final isPremiumUser = profile?.isPremium ?? false;

    final questionCount = quiz.questions.isNotEmpty
        ? quiz.questions.length
        : quiz.questionCount;
    final minutes = (questionCount / 2).ceil().clamp(3, 25);
    final locked = quiz.isPremium && !isPremiumUser;
    final passage = quiz.passage;
    final pathId = quiz.slug.isNotEmpty ? quiz.slug : quiz.id;
    final readFirst = preferences.readPassageFirst && passage != null;
    final headerLabel = passage?.book ?? quiz.category?.name;

    final freeLeft = allowance != null && !allowance.isPremium && !locked
        ? allowance.remaining
        : 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: BqTopBar(title: headerLabel, onBack: onBack),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _scrollContent(
                  profile,
                  preferences,
                  questionCount,
                  minutes,
                ),
              ),
              // The settings scroll under the pinned actions; fade them out
              // rather than cutting them off on a hard line.
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 24,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00ECEAE4), AppTheme.paper],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _actions(
              context,
              ref,
              freeLeft: freeLeft,
              locked: locked,
              readFirst: readFirst,
              pathId: pathId,
            ),
          ),
        ),
      ],
    );
  }

  Widget _scrollContent(
    ProfileModel? profile,
    QuizPreferences preferences,
    int questionCount,
    int minutes,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CoverCard(
            quiz: quiz,
            questionCount: questionCount,
            minutes: minutes,
          ),
          ..._bestScore(profile),
          const SizedBox(height: 22),
          // This screen is also where the quiz is set up. The choices
          // are saved to the account, so they are made once rather than
          // before every quiz.
          const Text(
            'Hoe wil je spelen?',
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Wordt onthouden voor je volgende quizzen, ook op de website.',
            style: AppTheme.caption,
          ),
          const SizedBox(height: 10),
          _QuizSettings(quiz: quiz, preferences: preferences),
        ],
      ),
    );
  }

  /// "Nog N gratis quizzen", Start (or unlock), challenge a friend, read first.
  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref, {
    required int freeLeft,
    required bool locked,
    required bool readFirst,
    required String pathId,
  }) {
    final passage = quiz.passage;
    return [
      if (freeLeft > 0) ...[
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Nog '),
              TextSpan(
                text: '$freeLeft',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              TextSpan(
                text: freeLeft == 1 ? ' gratis quiz' : ' gratis quizzen',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.caption,
        ),
        const SizedBox(height: 12),
      ],
      if (locked)
        BqButton(
          label: 'Ontgrendel met Premium',
          icon: SvgPicture.string(BqIcons.crown, width: 20, height: 20),
          onPressed: () {
            ref
                .read(analyticsProvider)
                .track(
                  AnalyticsEvents.paywallShown,
                  props: {
                    'trigger': PaywallTrigger.premiumQuizLocked,
                    'surface': 'quiz_detail',
                  },
                );
            context.push(
              '/premium-intro?reden=${PaywallTrigger.premiumQuizLocked}',
            );
          },
        )
      else
        BqButton(
          label: readFirst && passage != null
              ? 'Lees ${passage.label} en start'
              : 'Start quiz',
          onPressed: () {
            // Over the free limit: straight to the locked paywall instead
            // of opening the player only to bounce. Reading stays free.
            final allowance = ref.read(freeQuizAllowanceProvider).asData?.value;
            if (!readFirst &&
                allowance != null &&
                !allowance.canPlay(quiz.id, slug: quiz.slug)) {
              ref
                  .read(analyticsProvider)
                  .track(
                    AnalyticsEvents.paywallShown,
                    props: {
                      'trigger': PaywallTrigger.freeLimit,
                      'surface': 'quiz_detail',
                    },
                  );
              context.push('/premium?reden=${PaywallTrigger.freeLimit}');
              return;
            }
            context.push(
              readFirst ? '/quiz/$pathId/lezen' : '/quiz/$pathId/play',
            );
          },
        ),
      const SizedBox(height: 12),
      BqButton(
        label: 'Daag een vriend uit',
        style: BqButtonStyle.secondary,
        icon: const BqIcon(BqIcons.swords, size: 18, color: AppTheme.vermilion),
        onPressed: () => context.push('/duels/new'),
      ),
      // Only offered when the questions agree on one chapter, and not
      // when "lees eerst" is already switched on for Start.
      if (passage != null && !readFirst && !locked)
        Semantics(
          button: true,
          child: InkWell(
            onTap: () => context.push('/quiz/$pathId/lezen'),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  'Lees eerst ${passage.label}',
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
    ];
  }

  /// "Jouw beste score" from the attempts the profile carries. Hidden for
  /// guests and for quizzes not played yet.
  List<Widget> _bestScore(ProfileModel? profile) {
    if (profile == null) return const [];
    final attempts = profile.recentProgress
        .where((p) => p.quizId == quiz.id && p.totalQuestions > 0)
        .toList();
    final playedBefore =
        attempts.isNotEmpty || profile.playedQuizIds.contains(quiz.id);
    if (!playedBefore) return const [];

    if (attempts.isEmpty) {
      return const [
        SizedBox(height: 16),
        _ScoreRow(
          title: 'Al gespeeld',
          subtitle: 'Speel opnieuw voor een betere score',
          trailing: _DoneBadge(),
        ),
      ];
    }

    var best = attempts.first;
    for (final a in attempts.skip(1)) {
      if (a.accuracy > best.accuracy) best = a;
    }
    DateTime? last;
    for (final a in attempts) {
      final at = a.completedAt;
      if (at != null && (last == null || at.isAfter(last))) last = at;
    }

    return [
      const SizedBox(height: 16),
      _ScoreRow(
        title: 'Jouw beste score',
        subtitle: last != null
            ? 'Laatst gespeeld ${_relativeDay(last)}'
            : 'Al gespeeld',
        trailing: Text(
          '${best.score}/${best.totalQuestions}',
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ];
  }
}

String _relativeDay(DateTime when) {
  const months = [
    'jan',
    'feb',
    'mrt',
    'apr',
    'mei',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];
  final local = when.toLocal();
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(local.year, local.month, local.day)).inDays;
  if (days <= 0) return 'vandaag';
  if (days == 1) return 'gisteren';
  if (days < 7) return '$days dagen geleden';
  return 'op ${local.day} ${months[local.month - 1]}';
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({
    required this.quiz,
    required this.questionCount,
    required this.minutes,
  });

  final Quiz quiz;
  final int questionCount;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final chip = quiz.passage?.label ?? quiz.category?.name;

    return BqCard(
      padding: EdgeInsets.zero,
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 136,
            child: Stack(
              fit: StackFit.expand,
              children: [
                QuizCover(
                  imagePath: quiz.imageOrFallback,
                  thumbnailPath: quiz.thumbnail,
                  background: AppTheme.lapisTint,
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  right: 14,
                  child: Row(
                    children: [
                      if (chip != null && chip.isNotEmpty) ...[
                        Flexible(
                          child: _CoverChip(label: chip, color: AppTheme.lapis),
                        ),
                        const SizedBox(width: 6),
                      ],
                      _CoverChip(
                        label: _difficultyLabel(quiz),
                        color: AppTheme.inkSoft,
                      ),
                      const Spacer(),
                      if (quiz.isPremium)
                        BqPill(
                          label: 'Premium',
                          icon: SvgPicture.string(
                            BqIcons.crown,
                            width: 13,
                            height: 13,
                          ),
                          background: AppTheme.paperRaised,
                          foreground: AppTheme.goldText,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 26,
                    height: 31 / 26,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.description.isNotEmpty
                      ? quiz.description
                      : 'Test je kennis over dit onderwerp.',
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 21 / 15,
                    color: AppTheme.inkSoft,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Over deze quiz',
                  container: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StatTile(
                          background: AppTheme.lapisTint,
                          icon: const BqIcon(
                            BqIcons.question,
                            size: 18,
                            color: AppTheme.lapis,
                          ),
                          value: '$questionCount',
                          label: 'vragen',
                          labelColor: AppTheme.lapisMutedText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          background: AppTheme.positiveTint,
                          icon: const BqIcon(
                            BqIcons.clock,
                            size: 18,
                            color: AppTheme.positive,
                          ),
                          value: '$minutes min',
                          label: 'ongeveer',
                          labelColor: AppTheme.positiveMutedText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          background: AppTheme.goldTint,
                          icon: SvgPicture.string(
                            BqIcons.bolt,
                            width: 18,
                            height: 18,
                          ),
                          value: '+${quiz.xpReward}',
                          label: 'XP',
                          labelColor: AppTheme.goldText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _difficultyLabel(Quiz quiz) {
  switch (quiz.difficultyBucket) {
    case 'easy':
      return 'Makkelijk';
    case 'hard':
      return 'Moeilijk';
    default:
      return 'Gemiddeld';
  }
}

class _CoverChip extends StatelessWidget {
  const _CoverChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.background,
    required this.icon,
    required this.value,
    required this.label,
    required this.labelColor,
  });

  final Color background;
  final Widget icon;
  final String value;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const BqIconTile(
            background: AppTheme.goldTint,
            child: BqIcon(BqIcons.trophy, size: 20, color: AppTheme.goldText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(subtitle, style: AppTheme.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Afgerond',
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppTheme.positive,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const BqIcon(
          BqIcons.check,
          size: 15,
          color: AppTheme.inkInverted,
        ),
      ),
    );
  }
}

/// The setup block: read the chapter first, and how long you get per question.
///
/// Both are written straight to the account by the controller, so this widget
/// only reflects state - there is no local copy to fall out of step.
class _QuizSettings extends ConsumerWidget {
  const _QuizSettings({required this.quiz, required this.preferences});

  final Quiz quiz;
  final QuizPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quizPreferencesProvider.notifier);
    final passage = quiz.passage;

    return BqListCard(
      children: [
        // Only offered when the questions actually agree on one chapter.
        if (passage != null)
          _SettingRow(
            icon: BqIcons.book,
            title: 'Lees eerst ${passage.label}',
            description:
                'Je leest het hoofdstuk waar deze quiz over gaat voordat de vragen beginnen.',
            trailing: Switch.adaptive(
              value: preferences.readPassageFirst,
              activeTrackColor: AppTheme.lapis,
              onChanged: controller.setReadPassageFirst,
            ),
          ),
        _SettingRow(
          icon: BqIcons.clock,
          title: 'Tijd per vraag',
          description:
              'Standaard uit. Zet een klok aan als je jezelf wilt uitdagen.',
          below: Row(
            children: [
              for (final choice in QuizPreferences.timerChoices) ...[
                if (choice != QuizPreferences.timerChoices.first)
                  const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceChip(
                    label: choice == 0 ? 'Uit' : '${choice}s',
                    selected: preferences.questionTimerSeconds == choice,
                    onTap: () => controller.setTimerSeconds(choice),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    this.below,
  });

  final String icon;
  final String title;
  final String description;
  final Widget? trailing;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BqIconTile(
                size: 36,
                child: BqIcon(icon, size: 18, color: AppTheme.lapis),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyStrong),
                    const SizedBox(height: 2),
                    Text(description, style: AppTheme.caption),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (below != null) ...[const SizedBox(height: 12), below!],
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppTheme.lapis : AppTheme.paperRaised,
        shape: StadiumBorder(
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppTheme.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: selected ? AppTheme.inkInverted : AppTheme.inkSoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
