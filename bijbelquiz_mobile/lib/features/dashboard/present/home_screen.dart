import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../duels/present/home_duel_provider.dart';
import '../../profile/data/profile_model.dart';
import '../../profile/present/profile_provider.dart';
import '../../quiz/data/quiz_of_the_day.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/category.dart';
import '../../quiz/domain/quiz.dart';
import '../../quiz/present/library_category_request.dart';
import '../../quiz/present/widgets/bible_books.dart';
import '../../seasons/data/season_repository.dart';
import '../../seasons/domain/season.dart';

const QuizQuery _homeQuery = QuizQuery(includePremium: true);

String _routeKey(Quiz quiz) => quiz.slug.isNotEmpty ? quiz.slug : quiz.id;

int _minutesFor(int questionCount) => (questionCount / 2).ceil().clamp(3, 25);

/// Home: header with streak and XP, the quiz of the day, the last quizzes
/// played, the four topics, the duel waiting for the player and - when one is
/// running - the seasonal pack.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(profileProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(currentSeasonProvider);
    ref.invalidate(homeDuelProvider);
    ref.invalidate(quizzesProvider(_homeQuery));
    ref.invalidate(quizOfTheDayProvider);
    await ref.read(quizOfTheDayProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).asData?.value;
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? const <Category>[];
    final quizOfTheDayAsync = ref.watch(quizOfTheDayProvider);
    final duel = ref.watch(homeDuelProvider).asData?.value;
    final season = ref.watch(currentSeasonProvider).asData?.value;
    final isPremiumUser = profile?.isPremium ?? false;
    // Unknown for the first frame reads as signed in: the returning player is
    // the common case, and a guest card flashing at them would be wrong more
    // often than the reverse.
    final signedIn = ref.watch(hasSessionProvider).asData?.value ?? true;

    // The catalogue only supplies titles for "Verder spelen", and it is by far
    // the heaviest request on this screen. It starts once the daily card is
    // settled, and only for a player who has something to continue, so it
    // never competes with the card for the connection.
    final needsCatalogue =
        signedIn &&
        (profile?.recentProgress.isNotEmpty ?? false) &&
        !quizOfTheDayAsync.isLoading;
    final quizzes = needsCatalogue
        ? ref.watch(quizzesProvider(_homeQuery)).asData?.value ?? const <Quiz>[]
        : const <Quiz>[];

    final recent = signedIn
        ? _recentEntries(profile, quizzes)
        : const <_RecentEntry>[];

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.lapis,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _HomeHeader(profile: signedIn ? profile : null),
              const SizedBox(height: 20),
              quizOfTheDayAsync.when(
                data: (quiz) {
                  if (quiz == null) return const _EmptyDailyCard();
                  final locked = quiz.isPremium && !isPremiumUser;
                  return _DailyQuizCard(
                    quiz: quiz,
                    locked: locked,
                    onPlay: () {
                      if (locked) {
                        context.push('/premium');
                        return;
                      }
                      context.push('/quiz/${_routeKey(quiz)}/play');
                    },
                  );
                },
                loading: () => const _DailyLoadingCard(),
                error: (_, _) => _HomeErrorCard(
                  onRetry: () {
                    ref.invalidate(quizzesProvider(_homeQuery));
                    ref.invalidate(quizOfTheDayProvider);
                  },
                ),
              ),
              if (!signedIn) ...[
                const SizedBox(height: 20),
                const _GuestCard(),
              ] else if (recent.isNotEmpty) ...[
                const SizedBox(height: 20),
                BqSectionHeader(
                  title: 'Verder spelen',
                  actionLabel: 'Alles',
                  onAction: () => context.go('/profile'),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < recent.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _ContinueCard(
                          entry: recent[i],
                          onTap: () =>
                              context.push('/quiz/${recent[i].routeKey}'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text('Kies een onderwerp', style: AppTheme.displaySmall),
              const SizedBox(height: 10),
              _TopicGrid(
                onOpen: (topic) {
                  final match = topic.matchCategory(categories);
                  ref
                      .read(libraryCategoryRequestProvider.notifier)
                      .request(match?.id ?? 'all');
                  context.go('/quizzes');
                },
              ),
              if (duel != null) ...[
                const SizedBox(height: 20),
                _DuelCard(
                  duel: duel,
                  onPlay: () => context.push('/duels/${duel.duelId}'),
                ),
              ],
              // The seasonal pack, when one is running. Absent for most of the
              // year, so it renders nothing rather than an empty section.
              if (season != null && season.hasQuizzes) ...[
                const SizedBox(height: 24),
                _SeasonSection(
                  season: season,
                  onOpenQuiz: (quiz) {
                    if (quiz.isPremium && !isPremiumUser) {
                      context.push('/premium');
                      return;
                    }
                    context.push('/quiz/${quiz.routeKey}/play');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEntry {
  const _RecentEntry({required this.progress, this.quiz});

  final RecentProgressModel progress;
  final Quiz? quiz;

  String get routeKey {
    final q = quiz;
    if (q != null) return _routeKey(q);
    return progress.quizId;
  }
}

/// The two most recent different quizzes this account finished.
List<_RecentEntry> _recentEntries(ProfileModel? profile, List<Quiz> quizzes) {
  if (profile == null) return const [];
  final byId = {for (final q in quizzes) q.id: q};
  final seen = <String>{};
  final entries = <_RecentEntry>[];
  for (final progress in profile.recentProgress) {
    if (progress.quizId.isEmpty || !seen.add(progress.quizId)) continue;
    entries.add(_RecentEntry(progress: progress, quiz: byId[progress.quizId]));
    if (entries.length == 2) break;
  }
  return entries;
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profile});

  /// Null for guests and while loading: a reeks of 0 is not this person's
  /// number, it is the absence of one, so the pills are left out.
  final ProfileModel? profile;

  static const String _flame =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#D9734F" d="M12 2s5 4.5 5 10a5 5 0 0 1-10 0c0-2.5 1.5-4.2 2.5-5 0 2 1 3 2 3 0-3.5.5-6 .5-8z"/></svg>';

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: BqLogo(),
              ),
            ),
          ),
          if (p != null) ...[
            const SizedBox(width: 10),
            Semantics(
              label: p.streak == 1
                  ? 'Reeks van 1 dag'
                  : 'Reeks van ${p.streak} dagen',
              excludeSemantics: true,
              child: BqPill.outline(
                label: '${p.streak}',
                icon: SvgPicture.string(_flame, width: 16, height: 16),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: '${_formatNumber(p.xp)} XP',
              excludeSemantics: true,
              child: BqPill.outline(
                label: _formatNumber(p.xp),
                icon: SvgPicture.string(BqIcons.bolt, width: 16, height: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz van de dag
// ---------------------------------------------------------------------------

class _DailyQuizCard extends StatelessWidget {
  const _DailyQuizCard({
    required this.quiz,
    required this.locked,
    required this.onPlay,
  });

  final Quiz quiz;
  final bool locked;
  final VoidCallback onPlay;

  static const String _bookOutline =
      '<svg viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-opacity="0.12" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M2 5c3-1 6-1 10 1 4-2 7-2 10-1v14c-3-1-6-1-10 1-4-2-7-2-10-1z"/><path d="M12 6v14"/></svg>';

  static const String _boltInk =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#3D2C05" d="M13 2L4 14h7l-1 8 9-12h-7z"/></svg>';

  @override
  Widget build(BuildContext context) {
    final count = quiz.questions.isNotEmpty
        ? quiz.questions.length
        : quiz.questionCount;
    final reference = quiz.passage?.label ?? quiz.category?.name;
    final meta = [
      if (reference != null && reference.isNotEmpty) reference,
      '$count vragen',
      '${_minutesFor(count)} min',
    ].join(' · ');

    return Semantics(
      container: true,
      label: 'Quiz van de dag: ${quiz.title}',
      child: Material(
        color: AppTheme.lapis,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPlay,
          splashColor: AppTheme.lapisStrong.withValues(alpha: 0.4),
          highlightColor: AppTheme.lapisStrong.withValues(alpha: 0.25),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                top: -10,
                child: SvgPicture.string(_bookOutline, width: 120, height: 120),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUIZ VAN DE DAG',
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.72,
                        color: Color(0xFFC9D4EC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        height: 30 / 25,
                        color: AppTheme.inkInverted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDCE3F1),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        BqButton(
                          label: locked ? 'Ontgrendel' : 'Speel nu',
                          style: BqButtonStyle.white,
                          height: 48,
                          expand: false,
                          onPressed: onPlay,
                        ),
                        if (quiz.xpReward > 0) ...[
                          const SizedBox(width: 12),
                          BqPill(
                            label: '+${quiz.xpReward} XP',
                            icon: SvgPicture.string(
                              _boltInk,
                              width: 14,
                              height: 14,
                            ),
                            background: AppTheme.gold,
                            foreground: AppTheme.goldInk,
                            height: 30,
                            fontSize: 13,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyLoadingCard extends StatelessWidget {
  const _DailyLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: AppTheme.lapis,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          color: AppTheme.inkInverted,
        ),
      ),
    );
  }
}

class _EmptyDailyCard extends StatelessWidget {
  const _EmptyDailyCard();

  @override
  Widget build(BuildContext context) {
    return const BqCard(
      child: Text(
        'Nieuwe uitdaging verschijnt zodra quizdata geladen is.',
        style: AppTheme.bodyMuted,
      ),
    );
  }
}

class _HomeErrorCard extends StatelessWidget {
  const _HomeErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Home kon niet laden', style: AppTheme.bodyStrong),
          const SizedBox(height: 2),
          const Text(
            'Controleer je verbinding en probeer het opnieuw.',
            style: AppTheme.caption,
          ),
          const SizedBox(height: 12),
          BqButton(
            label: 'Opnieuw proberen',
            style: BqButtonStyle.secondary,
            height: 44,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Guest
// ---------------------------------------------------------------------------

/// Guests play without an account; this is the one place Home asks them to
/// make one so their score, XP and streak are kept.
class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              BqIconTile(
                size: 42,
                radius: 12,
                child: BqIcon(BqIcons.user, size: 22, color: AppTheme.lapis),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speel gratis, zonder account',
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    Text(
                      'Maak er een aan om je score, punten en reeks te bewaren.',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BqButton(
            label: 'Voortgang bewaren',
            style: BqButtonStyle.tint,
            height: 44,
            onPressed: () => context.push('/register'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verder spelen
// ---------------------------------------------------------------------------

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.entry, required this.onTap});

  final _RecentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quiz = entry.quiz;
    final progress = entry.progress;
    final passage = quiz?.passage;
    final categoryName = quiz?.category?.name;

    final tint = BibleBooks.tintForQuiz(
      book: passage?.book,
      category: categoryName,
    );

    final label = passage?.book ?? categoryName ?? 'Quiz';
    final total = progress.totalQuestions;
    final score = progress.score;
    final scoreText = total > 0 ? '$score/$total' : null;
    final line = passage != null
        ? [
            'Hoofdstuk ${passage.chapter}',
            if (scoreText != null) scoreText,
          ].join(' · ')
        : (scoreText != null ? '$scoreText goed' : 'Gespeeld');
    final title = progress.quizTitle.isNotEmpty
        ? progress.quizTitle
        : (quiz?.title ?? 'Quiz');

    return Semantics(
      button: true,
      onTap: onTap,
      label: total > 0 ? '$title, $score van $total goed' : title,
      excludeSemantics: true,
      child: BqCard(
        radius: 18,
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tint.background,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusPill,
                        ),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: tint.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BqRing(
                  value: total > 0 ? score / total : 0,
                  color: tint.foreground,
                  track: const Color(0xFFE6E4DF),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 21 / 17,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tint.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kies een onderwerp
// ---------------------------------------------------------------------------

class _Topic {
  const _Topic({
    required this.title,
    required this.subtitle,
    required this.circle,
    required this.subtitleColor,
    required this.svg,
    required this.svgSize,
    required this.svgRight,
    required this.svgBottom,
    required this.keyword,
  });

  final String title;
  final String subtitle;
  final Color circle;
  final Color subtitleColor;
  final String svg;
  final double svgSize;
  final double svgRight;
  final double svgBottom;

  /// Matched against the category names and slugs the API returns.
  final String keyword;

  Category? matchCategory(List<Category> categories) {
    for (final c in categories) {
      if (c.name.toLowerCase().contains(keyword) ||
          c.slug.toLowerCase().contains(keyword)) {
        return c;
      }
    }
    return null;
  }
}

const List<_Topic> _topics = [
  _Topic(
    title: 'Oude Testament',
    subtitle: '39 boeken',
    circle: Color(0xFFDCE9DF),
    subtitleColor: AppTheme.positiveMutedText,
    svgSize: 66,
    svgRight: -2,
    svgBottom: -8,
    keyword: 'oude',
    svg:
        '<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8 60V24a12 12 0 0 1 24 0v36z" fill="#D8D2C4" stroke="#6F6758" stroke-width="2.5" stroke-linejoin="round"/><path d="M32 60V24a12 12 0 0 1 24 0v36z" fill="#E6E1D5" stroke="#6F6758" stroke-width="2.5" stroke-linejoin="round"/><path d="M14 29h12M14 35h12M14 41h12M14 47h8M38 29h12M38 35h12M38 41h12M38 47h8" stroke="#8E8676" stroke-width="2.2" stroke-linecap="round"/></svg>',
  ),
  _Topic(
    title: 'Nieuwe Testament',
    subtitle: '27 boeken',
    circle: Color(0xFFDCE4F3),
    subtitleColor: AppTheme.lapisMutedText,
    svgSize: 68,
    svgRight: -4,
    svgBottom: -6,
    keyword: 'nieuwe',
    svg:
        '<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="42" cy="22" r="15" fill="#F3D27A"/><path d="M0 64Q30 44 64 58V64Z" fill="#B9C7E3"/><path d="M28 8h8v13h11v8H36v31h-8V29H17v-8h11z" fill="#35548C" stroke="#263E69" stroke-width="2" stroke-linejoin="round"/></svg>',
  ),
  _Topic(
    title: 'Algemeen',
    subtitle: 'Hele Bijbel',
    circle: Color(0xFFF8E7B8),
    subtitleColor: AppTheme.goldText,
    svgSize: 70,
    svgRight: -6,
    svgBottom: -10,
    keyword: 'algemeen',
    svg:
        '<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 30c9-5 19-5 28 1 9-6 19-6 28-1v28c-9-5-19-5-28 1-9-6-19-6-28-1z" fill="#FFFFFF" stroke="#8A6410" stroke-width="2.5" stroke-linejoin="round"/><path d="M32 31v28" stroke="#8A6410" stroke-width="2.5"/><path d="M10 39q6-3 16 0M10 46q6-3 16 0M38 39q6-3 16 0M38 46q6-3 16 0" stroke="#D6B565" stroke-width="2.2" stroke-linecap="round"/><circle cx="32" cy="16" r="11" fill="#E9B12E" stroke="#A87C14" stroke-width="2"/><path d="M28.5 13.5q0-3.5 3.5-3.5t3.5 3.2q0 2.3-2.2 3.3-1.3.6-1.3 2.2" stroke="#3D2C05" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/><circle cx="32" cy="22.4" r="1.5" fill="#3D2C05"/></svg>',
  ),
  _Topic(
    title: "Thema's",
    subtitle: 'Per thema',
    circle: Color(0xFFF4DCD0),
    subtitleColor: AppTheme.vermilion,
    svgSize: 64,
    svgRight: -2,
    svgBottom: -4,
    keyword: 'thema',
    svg:
        '<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 46L14 20 25 32 32 14 39 32 50 20 54 46z" fill="#E9B12E" stroke="#A87C14" stroke-width="2.5" stroke-linejoin="round"/><path d="M10 46h44v9H10z" fill="#D9A11F" stroke="#A87C14" stroke-width="2.5" stroke-linejoin="round"/><circle cx="14" cy="18" r="3.5" fill="#FFFFFF" stroke="#A87C14" stroke-width="2"/><circle cx="32" cy="12" r="3.5" fill="#FFFFFF" stroke="#A87C14" stroke-width="2"/><circle cx="50" cy="18" r="3.5" fill="#FFFFFF" stroke="#A87C14" stroke-width="2"/><circle cx="22" cy="50.5" r="2.6" fill="#D9734F"/><circle cx="32" cy="50.5" r="2.6" fill="#35548C"/><circle cx="42" cy="50.5" r="2.6" fill="#3F6B4F"/></svg>',
  ),
];

class _TopicGrid extends StatelessWidget {
  const _TopicGrid({required this.onOpen});

  final ValueChanged<_Topic> onOpen;

  @override
  Widget build(BuildContext context) {
    // 76 in the design: two title lines and the subtitle. Grows with the
    // reader's text size so a larger font never clips the subtitle.
    final s = MediaQuery.textScalerOf(context);
    final height = math.max(76.0, 26 + s.scale(36) + s.scale(14.4));

    Widget row(_Topic a, _Topic b) => SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _TopicTile(topic: a, onTap: () => onOpen(a)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TopicTile(topic: b, onTap: () => onOpen(b)),
          ),
        ],
      ),
    );

    return Column(
      children: [
        row(_topics[0], _topics[1]),
        const SizedBox(height: 10),
        row(_topics[2], _topics[3]),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic, required this.onTap});

  final _Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onTap,
      label: '${topic.title}, ${topic.subtitle}',
      excludeSemantics: true,
      child: BqCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -18,
                bottom: -22,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: topic.circle,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: topic.svgRight,
                bottom: topic.svgBottom,
                child: SvgPicture.string(
                  topic.svg,
                  width: topic.svgSize,
                  height: topic.svgSize,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flexible + ellipsis: with large system text the tile
                    // clips the title instead of overflowing.
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 92),
                        child: Text(
                          topic.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 18 / 15,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      topic.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: topic.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Duel
// ---------------------------------------------------------------------------

class _DuelCard extends StatelessWidget {
  const _DuelCard({required this.duel, required this.onPlay});

  final DuelCardData duel;
  final VoidCallback onPlay;

  static const String _swords =
      '<svg viewBox="0 0 24 24" fill="none" stroke="#B4502B" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M4 4l10 10"/><path d="M20 4L10 14"/><path d="M6 15l3 3"/><path d="M18 15l-3 3"/><path d="M4 20l3-3"/><path d="M20 20l-3-3"/></svg>';

  @override
  Widget build(BuildContext context) {
    final name = duel.opponentName.trim().isEmpty
        ? 'Je tegenstander'
        : duel.opponentName.trim();
    final letter = name[0].toUpperCase();

    return Semantics(
      container: true,
      label: 'Duel met $name, jouw beurt',
      child: BqCard(
        borderColor: AppTheme.coralLine,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onPlay,
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppTheme.coralTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        height: 1,
                        color: AppTheme.vermilion,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 27,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.paperRaised,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.coralLine),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.string(_swords, width: 12, height: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: AppTheme.coral,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF3D5C8),
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'JOUW BEURT',
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.66,
                          color: AppTheme.vermilion,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$name wacht op jou',
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
                    'Duel · ${duel.myScore} - ${duel.opponentScore} · ronde ${duel.round}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            BqButton(
              label: 'Speel',
              style: BqButtonStyle.coral,
              height: 44,
              fontSize: 15,
              expand: false,
              onPressed: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Season
// ---------------------------------------------------------------------------

/// The seasonal pack, with a real countdown to its last day.
///
/// The countdown is the point: "Nog 9 dagen" is a reason to open a quiz
/// tonight in a way that a permanent category never is.
class _SeasonSection extends StatelessWidget {
  const _SeasonSection({required this.season, required this.onOpenQuiz});

  final SeasonPack season;
  final ValueChanged<SeasonQuiz> onOpenQuiz;

  @override
  Widget build(BuildContext context) {
    final quizzes = season.quizzes.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BqSectionHeader(
          title: season.title,
          trailing: BqPill(
            label: season.countdownLabel,
            background: AppTheme.coralTint,
            foreground: AppTheme.vermilion,
          ),
        ),
        if (season.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(season.description, style: AppTheme.bodyMuted),
        ],
        const SizedBox(height: 10),
        BqListCard(
          children: [
            for (final quiz in quizzes)
              BqListRow(
                leading: const BqIconTile(
                  size: 36,
                  child: BqIcon(BqIcons.book, size: 18, color: AppTheme.lapis),
                ),
                title: quiz.title,
                subtitle: '${quiz.questionCount} vragen',
                trailing: quiz.isPremium
                    ? SvgPicture.string(BqIcons.crown, width: 18, height: 18)
                    : null,
                onTap: () => onOpenQuiz(quiz),
              ),
          ],
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
