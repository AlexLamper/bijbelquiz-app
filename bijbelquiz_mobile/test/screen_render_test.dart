import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/theme/app_theme.dart';
import 'package:bijbelquiz_mobile/features/dashboard/present/home_screen.dart';
import 'package:bijbelquiz_mobile/features/leaderboard/data/leaderboard_repository.dart';
import 'package:bijbelquiz_mobile/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:bijbelquiz_mobile/features/leaderboard/present/leaderboard_screen.dart';
import 'package:bijbelquiz_mobile/features/onboarding/present/onboarding_screen.dart';
import 'package:bijbelquiz_mobile/features/premium/present/premium_screen.dart';
import 'package:bijbelquiz_mobile/features/profile/data/profile_model.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_achievements_screen.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_provider.dart';
import 'package:bijbelquiz_mobile/features/profile/present/profile_screen.dart';
import 'package:bijbelquiz_mobile/features/quiz/data/quiz_repository.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/answer.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/category.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/question.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/quiz.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/library_screen.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/quiz_detail_screen.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/quiz_player_screen.dart';

/// Fails with the full error text (including the offending widget chain)
/// instead of the one-line summary `expect` would print.
void expectNoLayoutError(WidgetTester tester) {
  final error = tester.takeException();
  if (error == null) return;

  // Walk the element tree to name the widget whose Flex overflowed - the bare
  // FlutterError only carries the pixel count.
  final culprits = <String>[];
  for (final element in tester.allElements) {
    final render = element.renderObject;
    if (render is! RenderFlex) continue;
    if (!render.toStringShort().contains('OVERFLOWING')) continue;
    culprits.add(element.debugGetCreatorChain(10));
  }

  fail(
    'Layout error:\n$error\n\nOverflowing widget(s):\n'
    '${culprits.join('\n\n')}',
  );
}

/// Registers the real Inter / Newsreader files with the test engine.
///
/// Without this the test engine substitutes a placeholder font whose glyphs are
/// all one em wide, which makes every string roughly twice its real width and
/// produces overflow errors that never happen on a device.
Future<void> loadAppFonts() async {
  for (final entry in const {
    'Inter': [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ],
    'Newsreader': [
      'assets/fonts/Newsreader-Regular.ttf',
      'assets/fonts/Newsreader-Medium.ttf',
      'assets/fonts/Newsreader-SemiBold.ttf',
    ],
  }.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
  }
}

/// Renders the main screens at iPhone size with fake data so layout overflows
/// and render exceptions surface in CI instead of on a device.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  final categories = [
    Category(id: 'c1', name: 'Oude Testament', slug: 'oude-testament'),
    Category(id: 'c2', name: 'Nieuwe Testament', slug: 'nieuwe-testament'),
  ];

  List<Quiz> quizzes() => [
    Quiz(
      id: 'q1',
      title: 'Genesis',
      slug: 'genesis',
      description:
          'Test je kennis over het bijbelboek Genesis en de schepping.',
      difficulty: 'medium',
      categoryId: 'c1',
      category: categories[0],
      image: '/images/quizzes/img1.png',
      xpReward: 50,
      questionCount: 15,
    ),
    Quiz(
      id: 'q2',
      title: 'Het boek Spreuken',
      slug: 'het-boek-spreuken',
      description: 'Wijsheid uit Spreuken.',
      difficulty: 'hard',
      categoryId: 'c1',
      category: categories[0],
      image: '',
      xpReward: 80,
      questionCount: 20,
      isPremium: true,
    ),
    Quiz(
      id: 'q3',
      title: 'Algemene Bijbelkennis',
      slug: 'algemene-bijbelkennis',
      description: '',
      difficulty: 'easy',
      categoryId: 'c2',
      category: categories[1],
      image: '',
      xpReward: 30,
      questionCount: 10,
    ),
  ];

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
    badges: ['first_steps'],
    quizzesPlayed: 12,
    averageScore: 80,
    recentProgress: [
      RecentProgressModel(
        quizId: 'q1',
        quizTitle: 'Genesis',
        score: 8,
        totalQuestions: 10,
        xpEarned: 40,
      ),
    ],
  );

  final leaderboard = [
    LeaderboardEntry(id: 'u9', name: 'Bas Graveland', xp: 690),
    LeaderboardEntry(id: 'u1', name: 'Alex', xp: 1240),
  ];

  /// Genesis with real questions, for the detail + player screens.
  Quiz quizWithQuestions() => Quiz(
    id: 'q1',
    title: 'Genesis',
    slug: 'genesis',
    description: 'Test je kennis over het bijbelboek Genesis en de schepping.',
    difficulty: 'medium',
    categoryId: 'c1',
    category: categories[0],
    image: '/images/quizzes/img1.png',
    xpReward: 50,
    questionCount: 2,
    questions: [
      Question(
        id: 'qq1',
        text: 'Wie schreef het boek Genesis volgens de traditie?',
        explanation:
            'De traditie schrijft de eerste vijf boeken van de Bijbel toe aan '
            'Mozes; samen heten zij de Pentateuch of de Thora.',
        bibleReference: 'Exodus 24:4',
        answers: [
          Answer(text: 'Mozes', isCorrect: true),
          Answer(text: 'Jozua', isCorrect: false),
          Answer(text: 'Abraham', isCorrect: false),
          Answer(text: 'David', isCorrect: false),
        ],
      ),
      Question(
        id: 'qq2',
        text: 'Op welke dag rustte God van al Zijn werk?',
        explanation: 'God rustte op de zevende dag en heiligde die.',
        bibleReference: 'Genesis 2:2',
        answers: [
          Answer(text: 'De zesde dag', isCorrect: false),
          Answer(text: 'De zevende dag', isCorrect: true),
        ],
      ),
    ],
  );

  Widget host(Widget child) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => categories),
        quizzesProvider.overrideWith((ref, query) async => quizzes()),
        quizDetailProvider.overrideWith((ref, id) async => quizWithQuestions()),
        profileProvider.overrideWith((ref) async => profile),
        leaderboardProvider.overrideWith((ref) async => leaderboard),
        leaderboardByPeriodProvider.overrideWith(
          (ref, period) async => leaderboard,
        ),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: child),
    );
  }

  /// iPhone 14/15 logical size.
  Future<void> pumpAtPhoneSize(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(screen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Scrolls the page to the bottom so lazily-built slivers are laid out too -
  /// an overflow further down the list stays invisible otherwise.
  Future<void> scrollThrough(WidgetTester tester) async {
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout error after scroll step $i',
      );
    }
  }

  testWidgets('home renders quizzes without layout errors', (tester) async {
    await pumpAtPhoneSize(tester, const HomeScreen());

    expect(tester.takeException(), isNull);
    expect(find.text('Uitdaging van de dag'), findsOneWidget);

    await scrollThrough(tester);
    expect(find.text('Populair'), findsOneWidget);
    expect(find.text('Genesis'), findsWidgets);
  });

  testWidgets('library renders quiz cards without layout errors', (
    tester,
  ) async {
    await pumpAtPhoneSize(tester, const LibraryScreen());

    expect(tester.takeException(), isNull);
    expect(find.text('Alle quizzen'), findsOneWidget);

    await scrollThrough(tester);
    expect(find.text('Genesis'), findsWidgets);
  });

  testWidgets('profile renders without layout errors', (tester) async {
    await pumpAtPhoneSize(tester, const ProfileScreen());

    expect(tester.takeException(), isNull);
    expect(find.text('Alex'), findsWidgets);

    await scrollThrough(tester);
  });

  testWidgets('achievements renders without layout errors', (tester) async {
    await pumpAtPhoneSize(tester, const ProfileAchievementsScreen());

    expectNoLayoutError(tester);
    expect(find.text('Jouw badges'), findsOneWidget);
    await scrollThrough(tester);
  });

  testWidgets('leaderboard renders without layout errors', (tester) async {
    await pumpAtPhoneSize(tester, const LeaderboardScreen());

    expect(tester.takeException(), isNull);
    expect(find.text('Top spelers'), findsOneWidget);

    await scrollThrough(tester);
    expect(find.text('Bas Graveland'), findsOneWidget);
  });

  testWidgets('premium paywall renders the plan ladder', (tester) async {
    // No store in a test, so every price falls back to its hardcoded label -
    // which is exactly the state the per-week figures have to survive.
    await pumpAtPhoneSize(tester, const PremiumScreen());

    expectNoLayoutError(tester);
    expect(find.text('Kies je plan'), findsOneWidget);
    // 39,99 / (12 * 4.345), quoted next to the amount actually charged.
    expect(find.text('€0,77'), findsWidgets);
    // Once on the plan row, once in the order summary underneath it.
    expect(find.text('€39,99 per jaar'), findsWidgets);

    await scrollThrough(tester);
    expect(find.text('JOUW KEUZE'), findsOneWidget);
  });

  testWidgets('quiz detail renders without layout errors', (tester) async {
    await pumpAtPhoneSize(tester, const QuizDetailScreen(idOrSlug: 'genesis'));

    expect(tester.takeException(), isNull);
    expect(find.text('Genesis'), findsWidgets);
    expect(find.text('Start quiz'), findsOneWidget);

    await scrollThrough(tester);
  });

  testWidgets('quiz player renders question and answers', (tester) async {
    await pumpAtPhoneSize(tester, const QuizPlayerScreen(idOrSlug: 'genesis'));

    expectNoLayoutError(tester);
    expect(
      find.text('Wie schreef het boek Genesis volgens de traditie?'),
      findsOneWidget,
    );

    // Answer, then check the reveal + explanation layout.
    await tester.tap(find.text('Mozes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expectNoLayoutError(tester);

    await scrollThrough(tester);
  });

  testWidgets('onboarding renders all pages without layout errors', (
    tester,
  ) async {
    await pumpAtPhoneSize(tester, const OnboardingScreen());
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Volgende'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'onboarding page $i');
    }
    expect(find.text('Aan de slag'), findsOneWidget);
  });
}
