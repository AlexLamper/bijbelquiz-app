import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/category.dart';
import '../domain/quiz.dart';
import '../domain/quiz_submission_result.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuizRepository(apiClient);
});

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getCategories();
});

class QuizQuery {
  final int? limit;
  final String? categoryId;
  final bool? includePremium;

  const QuizQuery({this.limit, this.categoryId, this.includePremium});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuery &&
        other.limit == limit &&
        other.categoryId == categoryId &&
        other.includePremium == includePremium;
  }

  @override
  int get hashCode =>
      limit.hashCode ^ categoryId.hashCode ^ includePremium.hashCode;
}

// Added limit and category support to prevent overfetching
final quizzesProvider = FutureProvider.autoDispose
    .family<List<Quiz>, QuizQuery>((ref, query) async {
      final repository = ref.watch(quizRepositoryProvider);
      return repository.getQuizzes(
        limit: query.limit,
        categoryId: query.categoryId,
        includePremium: query.includePremium,
      );
    });

final quizDetailProvider = FutureProvider.autoDispose.family<Quiz, String>((
  ref,
  idOrSlug,
) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuiz(idOrSlug);
});

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository(this._apiClient);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final data = response.data;
      if (data is List) {
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Catalogue used by the library, the home screen and the multiplayer
  /// quickstart.
  ///
  /// `/api/mobile/quizzes` now reports the real `rewardXp` and `isPremium`,
  /// but still omits `difficulty`. `/api/quizzes` - the endpoint the website
  /// itself reads - carries the full document, so it stays the primary source
  /// and the mobile route is the fallback. Both are parsed by [Quiz.fromJson],
  /// which already understands either field spelling.
  Future<List<Quiz>> getQuizzes({
    int? limit,
    String? categoryId,
    bool? includePremium,
  }) async {
    List<Quiz> quizzes;
    try {
      quizzes = await _getQuizzesFromSite();
    } catch (_) {
      quizzes = await _getQuizzesFromMobileApi(
        limit: limit,
        categoryId: categoryId,
        includePremium: includePremium,
      );
    }

    // Neither endpoint honours the query parameters reliably, so narrowing
    // happens here for both sources.
    if (categoryId != null && categoryId != 'all') {
      quizzes = quizzes
          .where(
            (quiz) =>
                quiz.categoryId == categoryId ||
                quiz.category?.id == categoryId ||
                quiz.category?.slug == categoryId,
          )
          .toList();
    }
    if (includePremium == false) {
      quizzes = quizzes.where((quiz) => !quiz.isPremium).toList();
    }
    if (limit != null && quizzes.length > limit) {
      quizzes = quizzes.take(limit).toList();
    }

    return quizzes;
  }

  Future<List<Quiz>> _getQuizzesFromSite() async {
    final response = await _apiClient.dio.get<dynamic>(
      '${AppConfig.baseUrl}/api/quizzes',
    );

    final items = _extractQuizList(response.data);
    if (items.isEmpty) {
      throw Exception('Empty quiz catalogue');
    }

    return items
        .whereType<Map<String, dynamic>>()
        // Drafts and rejected submissions are not playable.
        .where((json) {
          final status = json['status']?.toString();
          return status == null || status == 'approved';
        })
        .map(Quiz.fromJson)
        .toList();
  }

  Future<List<Quiz>> _getQuizzesFromMobileApi({
    int? limit,
    String? categoryId,
    bool? includePremium,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (limit != null) queryParameters['limit'] = limit;
      if (categoryId != null && categoryId != 'all') {
        queryParameters['category'] = categoryId;
      }
      if (includePremium != null) {
        queryParameters['includePremium'] = includePremium;
      }

      final response = await _apiClient.dio.get(
        '/quizzes',
        queryParameters: queryParameters,
      );

      return _extractQuizList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(Quiz.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  /// Reports a finished solo attempt so the server can award XP, update the
  /// streak and unlock badges.
  ///
  /// `POST /api/mobile/progress` runs the same submission logic as the
  /// website, so the answers are re-graded server-side and the returned totals
  /// are authoritative. A failure is swallowed on purpose - the player still
  /// gets their result screen - and returns null, which the UI shows as an
  /// unconfirmed result rather than inventing an XP number.
  Future<QuizSubmissionResult?> submitQuizResult({
    required String quizId,
    required int correctAnswers,
    required int totalQuestions,
    List<int?> selectedAnswerIndexes = const <int?>[],
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/progress',
        data: {
          'quizId': quizId,
          'correctAnswers': correctAnswers,
          'score': correctAnswers,
          'totalQuestions': totalQuestions,
          'answers': selectedAnswerIndexes
              .map((index) => {'selectedAnswerIndex': index})
              .toList(),
        },
      );

      final data = response.data?['data'] ?? response.data;
      if (data is Map) {
        return QuizSubmissionResult.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static List<dynamic> _extractQuizList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['quizzes'] is List) return data['quizzes'] as List;
    return const [];
  }

  Future<Quiz> getQuiz(String idOrSlug) async {
    try {
      final response = await _apiClient.dio.get('/quizzes/$idOrSlug');

      var data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('quiz')) {
        data = data['quiz'];
      }

      return Quiz.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load quiz details: $e');
    }
  }
}
