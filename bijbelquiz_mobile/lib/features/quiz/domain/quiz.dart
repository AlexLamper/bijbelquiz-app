import 'category.dart';
import 'question.dart';
import 'quiz_passage.dart';

class Quiz {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String difficulty;
  final String? categoryId;
  final Category? category;
  final String image;
  final int xpReward;
  final int questionCount;
  final bool isPremium;

  /// ISO-8601 creation timestamp from the API, empty when the server did not
  /// send one. Used only to offer a "nieuwste eerst" sort.
  final String createdAt;

  final List<Question> questions;

  /// The chapter this quiz is about, when the server could work one out from
  /// the question references. Null for quizzes that span several books.
  final QuizPassage? passage;

  Quiz({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.difficulty = 'medium',
    this.categoryId,
    this.category,
    required this.image,
    required this.xpReward,
    this.questionCount = 0,
    this.isPremium = false,
    this.createdAt = '',
    this.questions = const [],
    this.passage,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    List<Question> parsedQuestions = rawQuestions
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    // Try to grab the image from any possible key your backend might be using
    String parsedImage =
        json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['coverImage']?.toString() ??
        '';

    return Quiz(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Quiz',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      categoryId: json['categoryId']?.toString(),
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      image: parsedImage,
      xpReward:
          (json['xpReward'] as num?)?.toInt() ??
          (json['rewardXp'] as num?)?.toInt() ??
          0,
      questionCount:
          (json['questionCount'] as num?)?.toInt() ?? parsedQuestions.length,
      isPremium:
          json['isPremium'] == true ||
          json['premiumOnly'] == true ||
          json['requiresPremium'] == true ||
          json['premium'] == true,
      createdAt:
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          '',
      questions: parsedQuestions,
      passage: QuizPassage.fromJson(json['passage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'difficulty': difficulty,
      'categoryId': categoryId,
      'category': category?.toJson(),
      'imageUrl': image,
      'xpReward': xpReward,
      'questionCount': questionCount,
      'isPremium': isPremium,
      'createdAt': createdAt,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

extension QuizImageFallback on Quiz {
  /// A cover image that always resolves. The API now fills `image` for every
  /// quiz, but offline cache and older payloads can still arrive blank - in
  /// that case derive a stable file from the id so the card is never empty.
  /// Mirrors the server's `resolveQuizImageUrl` fallback (img1..img12).
  String get imageOrFallback {
    if (image.trim().isNotEmpty) return image;
    var hash = 0;
    final source = id.isNotEmpty ? id : 'quiz';
    for (final unit in source.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return '/images/quizzes/img${(hash % 12) + 1}.png';
  }
}

extension QuizDifficultyLocalization on Quiz {
  /// Collapses every legacy spelling to one of `easy` / `medium` / `hard` so a
  /// filter chip can match. Older seeds used `beginner/intermediate/advanced`.
  String get difficultyBucket {
    switch (difficulty.trim().toLowerCase()) {
      case 'easy':
      case 'beginner':
      case 'makkelijk':
        return 'easy';
      case 'hard':
      case 'advanced':
      case 'moeilijk':
        return 'hard';
      case 'medium':
      case 'intermediate':
      case 'gemiddeld':
        return 'medium';
      default:
        return 'medium';
    }
  }

  String get difficultyLabelNl {
    switch (difficultyBucket) {
      case 'easy':
        return 'MAKKELIJK';
      case 'hard':
        return 'MOEILIJK';
      default:
        return 'GEMIDDELD';
    }
  }
}
