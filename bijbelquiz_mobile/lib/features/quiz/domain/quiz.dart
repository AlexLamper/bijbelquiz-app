import 'category.dart';
import 'question.dart';

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
  final List<Question> questions;

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
    this.questions = const [],
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List? ?? [];
    List<Question> parsedQuestions = rawQuestions
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    // Try to grab the image from any possible key your backend might be using
    String parsedImage = json['imageUrl']?.toString() ?? 
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
      xpReward: (json['xpReward'] as num?)?.toInt() ?? (json['rewardXp'] as num?)?.toInt() ?? 0,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? parsedQuestions.length,
      questions: parsedQuestions,
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
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}