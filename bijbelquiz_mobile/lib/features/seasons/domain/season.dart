/// One quiz inside a seasonal pack.
class SeasonQuiz {
  final String id;
  final String title;
  final String slug;
  final int questionCount;
  final bool isPremium;

  const SeasonQuiz({
    required this.id,
    required this.title,
    required this.slug,
    this.questionCount = 0,
    this.isPremium = false,
  });

  factory SeasonQuiz.fromJson(Map<String, dynamic> json) {
    return SeasonQuiz(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Quiz',
      slug: json['slug'] as String? ?? '',
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      isPremium: json['isPremium'] == true,
    );
  }

  /// The route segment: slug where there is one, id otherwise.
  String get routeKey => slug.isNotEmpty ? slug : id;
}

/// A seasonal quiz pack - Advent, Veertigdagentijd, the September opening.
///
/// Mirrors the payload of `/api/mobile/seasons/current`.
class SeasonPack {
  final String slug;
  final String title;
  final String description;

  /// Whole days left, computed by the server.
  final int daysRemaining;

  final String? categorySlug;
  final List<SeasonQuiz> quizzes;

  const SeasonPack({
    required this.slug,
    required this.title,
    required this.description,
    required this.daysRemaining,
    this.categorySlug,
    this.quizzes = const [],
  });

  /// A pack with nothing tagged behind it yet is not worth a card.
  bool get hasQuizzes => quizzes.isNotEmpty;

  String get countdownLabel {
    if (daysRemaining <= 0) return 'Loopt vandaag af';
    if (daysRemaining == 1) return 'Nog 1 dag';
    return 'Nog $daysRemaining dagen';
  }

  factory SeasonPack.fromJson(Map<String, dynamic> json, List<dynamic> quizzes) {
    return SeasonPack(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? 'Seizoen',
      description: json['description'] as String? ?? '',
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      categorySlug: json['categorySlug'] as String?,
      quizzes: quizzes
          .whereType<Map>()
          .map((row) => SeasonQuiz.fromJson(Map<String, dynamic>.from(row)))
          .toList(),
    );
  }
}
