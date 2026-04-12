class RecentProgressModel {
  final String quizId;
  final String quizTitle;
  final String? quizImage;
  final int score;
  final bool isCompleted;

  RecentProgressModel({
    required this.quizId,
    required this.quizTitle,
    this.quizImage,
    required this.score,
    required this.isCompleted,
  });

  factory RecentProgressModel.fromJson(Map<String, dynamic> json) {
    return RecentProgressModel(
      quizId: json['quizId'] as String? ?? '',
      quizTitle: json['quizTitle'] as String? ?? 'Quiz',
      quizImage: json['quizImage'] as String?,
      score: json['score'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizImage': quizImage,
      'score': score,
      'isCompleted': isCompleted,
    };
  }
}

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final int xp;
  final int level;
  final String levelTitle;
  final bool isPremium;
  final int streak;
  final int bestStreak;
  final List<String> badges;
  final List<RecentProgressModel> recentProgress;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.xp,
    required this.level,
    required this.levelTitle,
    required this.isPremium,
    required this.streak,
    required this.bestStreak,
    required this.badges,
    required this.recentProgress,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      levelTitle: json['levelTitle'] as String? ?? 'Nieuweling',
      isPremium: json['isPremium'] as bool? ?? false,
      streak: json['streak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recentProgress: (json['recentProgress'] as List<dynamic>?)
              ?.map((e) => RecentProgressModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'xp': xp,
      'level': level,
      'levelTitle': levelTitle,
      'isPremium': isPremium,
      'streak': streak,
      'bestStreak': bestStreak,
      'badges': badges,
      'recentProgress': recentProgress.map((e) => e.toJson()).toList(),
    };
  }
}
