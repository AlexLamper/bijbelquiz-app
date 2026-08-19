import '../../../core/avatar/avatar_catalog.dart';

/// Reads an int that the API may send as int, double, or numeric string.
int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class RecentProgressModel {
  final String quizId;
  final String quizTitle;
  final String? quizImage;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final DateTime? completedAt;

  RecentProgressModel({
    required this.quizId,
    required this.quizTitle,
    this.quizImage,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    this.completedAt,
  });

  /// Every stored attempt is a finished attempt; the app never writes partials.
  bool get isCompleted => true;

  /// Fraction correct, 0..1. Zero when the server did not send a question count.
  double get accuracy => totalQuestions > 0 ? score / totalQuestions : 0;

  factory RecentProgressModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['completedAt'];

    return RecentProgressModel(
      quizId: json['quizId'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? 'Quiz',
      quizImage: json['quizImage'] as String?,
      score: _asInt(json['score']),
      totalQuestions: _asInt(json['totalQuestions']),
      xpEarned: _asInt(json['xpEarned']),
      completedAt: rawDate is String ? DateTime.tryParse(rawDate) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizImage': quizImage,
      'score': score,
      'totalQuestions': totalQuestions,
      'xpEarned': xpEarned,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// The player's gamification state exactly as the server computed it.
///
/// Nothing in here is derived locally: level, progress, streak, badges, and
/// lifetime totals all come from `GET /api/mobile/profile`, which shares its
/// formulas with the website. Recomputing any of it on the client is what made
/// the app and the site disagree.
class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? image;

  /// The player mascot shown on the profile, the ranking and in multiplayer.
  final AvatarConfig avatar;

  /// Days before the display name may be changed again; 0 when it may now.
  final int nameChangeAllowedInDays;

  final int xp;
  final int level;
  final String levelTitle;

  /// Percentage (0-100) towards the next level, on the server's XP ladder.
  final int levelProgress;

  /// Absolute XP total at which the next level starts.
  final int nextLevelXp;

  final bool isPremium;
  final int streak;
  final int bestStreak;

  /// When this account last finished a quiz, on any platform. Used by the
  /// evening streak reminder to decide today is already covered.
  final DateTime? lastPlayedAt;
  final List<String> badges;

  /// Lifetime attempt count, not the length of [recentProgress].
  final int quizzesPlayed;

  /// Lifetime accuracy as a percentage (0-100).
  final int averageScore;

  final List<RecentProgressModel> recentProgress;

  /// Ids of every quiz this account has finished at least once.
  ///
  /// Ids rather than attempts: the library only needs "done or not", and a full
  /// attempt history would grow without bound on an account that plays a lot.
  final Set<String> playedQuizIds;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.avatar = AvatarConfig.fallback,
    this.nameChangeAllowedInDays = 0,
    required this.xp,
    required this.level,
    required this.levelTitle,
    required this.levelProgress,
    required this.nextLevelXp,
    required this.isPremium,
    required this.streak,
    required this.bestStreak,
    this.lastPlayedAt,
    required this.badges,
    required this.quizzesPlayed,
    required this.averageScore,
    required this.recentProgress,
    this.playedQuizIds = const {},
  });

  /// XP still needed to reach the next level. Zero at max level.
  int get xpToNextLevel => nextLevelXp > xp ? nextLevelXp - xp : 0;

  /// Level bar fill, 0..1.
  double get levelFraction => (levelProgress / 100).clamp(0.0, 1.0);

  ProfileModel copyWith({String? name, AvatarConfig? avatar, int? nameChangeAllowedInDays}) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      image: image,
      avatar: avatar ?? this.avatar,
      nameChangeAllowedInDays:
          nameChangeAllowedInDays ?? this.nameChangeAllowedInDays,
      xp: xp,
      level: level,
      levelTitle: levelTitle,
      levelProgress: levelProgress,
      nextLevelXp: nextLevelXp,
      isPremium: isPremium,
      streak: streak,
      bestStreak: bestStreak,
      lastPlayedAt: lastPlayedAt,
      badges: badges,
      quizzesPlayed: quizzesPlayed,
      averageScore: averageScore,
      recentProgress: recentProgress,
      playedQuizIds: playedQuizIds,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final xp = _asInt(json['xp']);
    final id = json['id'] as String? ?? '';

    return ProfileModel(
      id: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String?,
      avatar: AvatarConfig.resolve(
        json['avatar'] is Map
            ? Map<String, dynamic>.from(json['avatar'] as Map)
            : null,
        id,
      ),
      nameChangeAllowedInDays: _asInt(json['nameChangeAllowedInDays']),
      xp: xp,
      level: _asInt(json['level'], 1),
      levelTitle: json['levelTitle'] as String? ?? 'Zoeker',
      levelProgress: _asInt(json['levelProgress']).clamp(0, 100),
      nextLevelXp: _asInt(json['nextLevelXp'], xp),
      isPremium: json['isPremium'] as bool? ?? false,
      streak: _asInt(json['streak']),
      bestStreak: _asInt(json['bestStreak']),
      lastPlayedAt: DateTime.tryParse(json['lastPlayedAt']?.toString() ?? ''),
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      quizzesPlayed: _asInt(json['quizzesPlayed']),
      averageScore: _asInt(json['averageScore']).clamp(0, 100),
      recentProgress:
          (json['recentProgress'] as List<dynamic>?)
              ?.map(
                (e) => RecentProgressModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      playedQuizIds:
          (json['playedQuizIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((id) => id.isNotEmpty)
              .toSet() ??
          const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'avatar': avatar.toJson(),
      'nameChangeAllowedInDays': nameChangeAllowedInDays,
      'xp': xp,
      'level': level,
      'levelTitle': levelTitle,
      'levelProgress': levelProgress,
      'nextLevelXp': nextLevelXp,
      'isPremium': isPremium,
      'streak': streak,
      'bestStreak': bestStreak,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'badges': badges,
      'quizzesPlayed': quizzesPlayed,
      'averageScore': averageScore,
      'recentProgress': recentProgress.map((e) => e.toJson()).toList(),
    };
  }
}
