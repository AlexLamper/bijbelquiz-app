import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../avatar/avatar_catalog.dart';
import '../../features/leaderboard/data/leaderboard_repository.dart';
import '../../features/leaderboard/domain/leaderboard_entry.dart';
import '../../features/profile/data/profile_model.dart';
import '../../features/profile/present/profile_provider.dart';
import '../../features/quiz/data/quiz_repository.dart';
import '../../features/quiz/domain/answer.dart';
import '../../features/quiz/domain/category.dart';
import '../../features/quiz/domain/question.dart';
import '../../features/quiz/domain/quiz.dart';

/// Canned content used by design-preview mode (see [PreviewConfig]).
///
/// Everything here is fabricated sample data. It never reaches the API and is
/// excluded from release builds by the preview flag.
class PreviewData {
  const PreviewData._();

  static final List<Category> categories = [
    Category(id: 'c1', name: 'Oude Testament', slug: 'oude-testament'),
    Category(id: 'c2', name: 'Nieuwe Testament', slug: 'nieuwe-testament'),
    Category(id: 'c3', name: 'Bijbelse figuren', slug: 'bijbelse-figuren'),
    Category(id: 'c4', name: 'Psalmen', slug: 'psalmen'),
  ];

  static final List<Quiz> quizzes = [
    Quiz(
      id: 'q1',
      title: 'Genesis',
      slug: 'genesis',
      description:
          'Van de schepping tot Jozef in Egypte - test je kennis van het '
          'eerste bijbelboek.',
      difficulty: 'medium',
      categoryId: 'c1',
      category: categories[0],
      image: '/images/quizzes/img1.png',
      xpReward: 50,
      questionCount: 15,
      questions: _genesisQuestions,
    ),
    Quiz(
      id: 'q2',
      title: 'Het boek Spreuken',
      slug: 'het-boek-spreuken',
      description: 'Wijsheid, dwaasheid en de vreze des HEEREN.',
      difficulty: 'hard',
      categoryId: 'c1',
      category: categories[0],
      image: '/images/quizzes/img9.png',
      xpReward: 80,
      questionCount: 20,
      isPremium: true,
      questions: _genesisQuestions,
    ),
    Quiz(
      id: 'q3',
      title: 'De evangeliën',
      slug: 'de-evangelien',
      description: 'Mattheüs, Markus, Lukas en Johannes naast elkaar.',
      difficulty: 'easy',
      categoryId: 'c2',
      category: categories[1],
      image: '/images/quizzes/img3.png',
      xpReward: 30,
      questionCount: 10,
      questions: _genesisQuestions,
    ),
    Quiz(
      id: 'q4',
      title: 'Prediker',
      slug: 'prediker',
      description: 'IJdelheid der ijdelheden - alles is ijdelheid.',
      difficulty: 'medium',
      categoryId: 'c1',
      category: categories[0],
      image: '/images/quizzes/img7.png',
      xpReward: 45,
      questionCount: 14,
      questions: _genesisQuestions,
    ),
    Quiz(
      id: 'q5',
      title: 'Koningen van Israël',
      slug: 'koningen-van-israel',
      description: 'Van Saul tot de ballingschap.',
      difficulty: 'hard',
      categoryId: 'c3',
      category: categories[2],
      image: '/images/quizzes/img5.png',
      xpReward: 70,
      questionCount: 18,
      questions: _genesisQuestions,
    ),
    Quiz(
      id: 'q6',
      title: 'Psalm 23',
      slug: 'psalm-23',
      description: 'De HEERE is mijn Herder - regel voor regel.',
      difficulty: 'easy',
      categoryId: 'c4',
      category: categories[3],
      image: '/images/quizzes/img2.png',
      xpReward: 25,
      questionCount: 8,
      questions: _genesisQuestions,
    ),
  ];

  static final List<Question> _genesisQuestions = [
    Question(
      id: 'qq1',
      text: 'Wie schreef het boek Genesis volgens de overlevering?',
      explanation:
          'De overlevering schrijft de eerste vijf boeken van de Bijbel toe '
          'aan Mozes. Samen worden zij de Pentateuch of de Thora genoemd.',
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
      explanation:
          'God voltooide Zijn werk op de zesde dag en rustte op de zevende, '
          'die Hij zegende en heiligde.',
      bibleReference: 'Genesis 2:2-3',
      answers: [
        Answer(text: 'De zesde dag', isCorrect: false),
        Answer(text: 'De zevende dag', isCorrect: true),
        Answer(text: 'De achtste dag', isCorrect: false),
      ],
    ),
    Question(
      id: 'qq3',
      text: 'Hoeveel jaar leefde Methusalem?',
      explanation:
          'Methusalem werd 969 jaar oud en is daarmee de oudste mens die in de '
          'Bijbel genoemd wordt.',
      bibleReference: 'Genesis 5:27',
      answers: [
        Answer(text: '777 jaar', isCorrect: false),
        Answer(text: '930 jaar', isCorrect: false),
        Answer(text: '969 jaar', isCorrect: true),
        Answer(text: '1000 jaar', isCorrect: false),
      ],
    ),
  ];

  // Mirrors what the server would return for this XP total: 1240 XP sits in
  // level 2 (500-1500), so the bar is 74% of the way to "Leerling".
  static final ProfileModel profile = ProfileModel(
    id: 'preview-user',
    name: 'Testspeler',
    email: 'preview@bijbelquiz.com',
    avatar: const AvatarConfig(
      character: 'uil',
      color: 'lapis',
      background: 'perkament',
      accessory: 'bril',
    ),
    xp: 1240,
    level: 2,
    levelTitle: 'Lezer',
    levelProgress: 74,
    nextLevelXp: 1500,
    isPremium: false,
    streak: 4,
    bestStreak: 11,
    badges: ['first_steps', 'streak_3', 'perfect_score'],
    quizzesPlayed: 23,
    averageScore: 78,
    recentProgress: [
      RecentProgressModel(
        quizId: 'q1',
        quizTitle: 'Genesis',
        score: 9,
        totalQuestions: 10,
        xpEarned: 45,
      ),
      RecentProgressModel(
        quizId: 'q6',
        quizTitle: 'Psalm 23',
        score: 8,
        totalQuestions: 8,
        xpEarned: 50,
      ),
      RecentProgressModel(
        quizId: 'q4',
        quizTitle: 'Prediker',
        score: 5,
        totalQuestions: 8,
        xpEarned: 31,
      ),
    ],
  );

  // Mascots are seeded from the id, exactly as the server does for an account
  // that has not opened the customiser, so the preview shows the same spread
  // of creatures a real ranking does.
  static final List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(
      id: 'u2',
      name: 'Bas Graveland',
      xp: 2690,
      streak: 12,
      avatar: AvatarConfig.fromSeed('u2'),
    ),
    LeaderboardEntry(
      id: 'u3',
      name: 'Neline Schinkel',
      xp: 2508,
      streak: 7,
      avatar: AvatarConfig.fromSeed('u3'),
    ),
    LeaderboardEntry(
      id: 'u4',
      name: 'Arja Swart',
      xp: 1390,
      streak: 3,
      avatar: AvatarConfig.fromSeed('u4'),
    ),
    LeaderboardEntry(
      id: 'preview-user',
      name: 'Testspeler',
      xp: 1240,
      streak: 4,
      avatar: const AvatarConfig(
        character: 'uil',
        color: 'lapis',
        background: 'perkament',
        accessory: 'bril',
      ),
    ),
    LeaderboardEntry(
      id: 'u5',
      name: 'Sandra Timmerman',
      xp: 1290,
      streak: 2,
      avatar: AvatarConfig.fromSeed('u5'),
    ),
    LeaderboardEntry(
      id: 'u6',
      name: 'Jedidja Regterschot',
      xp: 988,
      avatar: AvatarConfig.fromSeed('u6'),
    ),
    LeaderboardEntry(
      id: 'u7',
      name: 'Ruben Van Asselt',
      xp: 877,
      avatar: AvatarConfig.fromSeed('u7'),
    ),
    LeaderboardEntry(
      id: 'u8',
      name: 'Timon van der Wal',
      xp: 705,
      avatar: AvatarConfig.fromSeed('u8'),
    ),
  ];

  /// Wraps [child] in a scope where every network-backed provider is swapped
  /// for the canned data above, so no API call is ever made.
  static Widget scope(Widget child) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => categories),
        quizzesProvider.overrideWith((ref, query) async {
          if (query.limit != null && query.limit! < quizzes.length) {
            return quizzes.take(query.limit!).toList();
          }
          return quizzes;
        }),
        quizDetailProvider.overrideWith((ref, idOrSlug) async {
          return quizzes.firstWhere(
            (quiz) => quiz.slug == idOrSlug || quiz.id == idOrSlug,
            orElse: () => quizzes.first,
          );
        }),
        profileProvider.overrideWith((ref) async => profile),
        leaderboardProvider.overrideWith((ref) async => leaderboard),
        leaderboardByPeriodProvider.overrideWith(
          (ref, period) async => leaderboard,
        ),
      ],
      child: child,
    );
  }
}
