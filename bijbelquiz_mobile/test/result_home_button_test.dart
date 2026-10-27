import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/features/duels/data/duels_preview.dart';
import 'package:bijbelquiz_mobile/features/duels/data/duels_repository.dart';
import 'package:bijbelquiz_mobile/features/duels/domain/duel.dart';
import 'package:bijbelquiz_mobile/features/duels/present/duel_play_screen.dart';
import 'package:bijbelquiz_mobile/features/profile/data/profile_model.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_provider.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/answer.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/question.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/quiz.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/quiz_submission_result.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/player/quiz_result_view.dart';

import 'screen_render_test.dart' show expectNoLayoutError, loadAppFonts;

/// Serves one canned duel; nothing else is called on the overview of a
/// finished duel.
class _FakeDuels implements DuelsRepository {
  _FakeDuels(this.duel);

  final Duel duel;

  @override
  Future<Duel> get(String duelId) async => duel;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// "Terug naar home" at the bottom of the end screens: the quiz result and a
/// finished duel. It must land on the home tab with nothing left to go back
/// to (`go`, not `push`).
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  final quiz = Quiz(
    id: 'q1',
    title: 'Genesis',
    slug: 'genesis',
    description: 'Test je kennis over Genesis.',
    difficulty: 'medium',
    categoryId: 'c1',
    image: '',
    xpReward: 50,
    questionCount: 2,
    questions: [
      Question(
        id: 'qq1',
        text: 'Wie schreef het boek Genesis volgens de traditie?',
        explanation: 'De traditie noemt Mozes.',
        bibleReference: 'Exodus 24:4',
        answers: [
          Answer(text: 'Mozes', isCorrect: true),
          Answer(text: 'Jozua', isCorrect: false),
        ],
      ),
      Question(
        id: 'qq2',
        text: 'Op welke dag rustte God?',
        explanation: 'Op de zevende dag.',
        bibleReference: 'Genesis 2:2',
        answers: [
          Answer(text: 'De zesde dag', isCorrect: false),
          Answer(text: 'De zevende dag', isCorrect: true),
        ],
      ),
    ],
  );

  final profile = ProfileModel(
    id: 'u1',
    name: 'Alex',
    email: 'alex@voorbeeld.nl',
    xp: 1240,
    level: 2,
    levelTitle: 'Lezer',
    levelProgress: 74,
    nextLevelXp: 1500,
    isPremium: false,
    streak: 4,
    bestStreak: 9,
    badges: const [],
    quizzesPlayed: 12,
    averageScore: 80,
    recentProgress: const [],
  );

  /// `/home` underneath, the end screen pushed on top of it, as when a quiz
  /// is opened from the dashboard.
  Future<GoRouter> pumpEndScreen(
    WidgetTester tester,
    Widget endScreen, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('HOME TAB'))),
        ),
        GoRoute(
          path: '/end',
          builder: (context, state) =>
              Scaffold(body: SafeArea(child: endScreen)),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith((ref) async => profile),
          ...overrides,
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    router.push('/end');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return router;
  }

  Future<void> tapHomeAndExpectHomeTab(
    WidgetTester tester,
    GoRouter router,
    Finder button,
  ) async {
    expect(button, findsOneWidget);
    expect(find.text('Terug naar home'), findsOneWidget);

    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('HOME TAB'), findsOneWidget);
    expect(find.text('Terug naar home'), findsNothing);
    // Replaced, not stacked: back does not return to the end screen.
    expect(router.canPop(), isFalse);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/home');
  }

  testWidgets('quiz result ends with "Terug naar home" to the home tab', (
    tester,
  ) async {
    final router = await pumpEndScreen(
      tester,
      QuizResultView(
        quiz: quiz,
        correctCount: 1,
        picks: const {0: 0, 1: 0},
        parkedForAccount: false,
        submitting: false,
        submitFailed: false,
        result: const QuizSubmissionResult(
          xpEarned: 25,
          farmPrevented: false,
          score: 1,
          totalQuestions: 2,
          xp: 1265,
          level: 2,
          levelTitle: 'Lezer',
          streak: 4,
          badges: [],
          newBadges: [],
        ),
        isNewBest: false,
        onRetrySubmit: () {},
      ),
    );
    expectNoLayoutError(tester);

    // The last button on the page.
    final home = find.byKey(const ValueKey('quiz-result-home'));
    final next = find.text('Volgende quiz');
    expect(tester.getTopLeft(home).dy, greaterThan(tester.getTopLeft(next).dy));

    await tapHomeAndExpectHomeTab(tester, router, home);
  });

  testWidgets('signed-out result has "Terug naar home" too', (tester) async {
    final router = await pumpEndScreen(
      tester,
      QuizResultView(
        quiz: quiz,
        correctCount: 2,
        picks: const {0: 0, 1: 1},
        parkedForAccount: true,
        submitting: false,
        submitFailed: false,
        result: null,
        isNewBest: false,
        onRetrySubmit: () {},
      ),
    );
    expectNoLayoutError(tester);

    await tapHomeAndExpectHomeTab(
      tester,
      router,
      find.byKey(const ValueKey('quiz-result-home')),
    );
  });

  testWidgets('finished duel ends with "Terug naar home" to the home tab', (
    tester,
  ) async {
    final duel = Duel.fromJson(DuelsPreview.instance.duel('preview-ruben'));
    expect(duel.isFinished, isTrue);

    final router = await pumpEndScreen(
      tester,
      const DuelPlayScreen(duelId: 'preview-ruben'),
      overrides: [duelsRepositoryProvider.overrideWithValue(_FakeDuels(duel))],
    );
    expectNoLayoutError(tester);

    await tapHomeAndExpectHomeTab(
      tester,
      router,
      find.byKey(const ValueKey('duel-finished-home')),
    );
  });

  testWidgets('a duel still running has no home button', (tester) async {
    final duel = Duel.fromJson(DuelsPreview.instance.duel('preview-daan'));
    if (duel.isFinished) return;

    await pumpEndScreen(
      tester,
      const DuelPlayScreen(duelId: 'preview-daan'),
      overrides: [duelsRepositoryProvider.overrideWithValue(_FakeDuels(duel))],
    );
    expect(find.byKey(const ValueKey('duel-finished-home')), findsNothing);
  });
}
