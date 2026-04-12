import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/present/auth_controller.dart';
import '../../../core/api/api_client.dart';
import '../domain/category.dart';
import '../domain/quiz.dart';

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

  const QuizQuery({this.limit, this.categoryId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuery &&
        other.limit == limit &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode => limit.hashCode ^ categoryId.hashCode;
}

// Added limit and category support to prevent overfetching
final quizzesProvider = FutureProvider.autoDispose
    .family<List<Quiz>, QuizQuery>((ref, query) async {
      final repository = ref.watch(quizRepositoryProvider);
      return repository.getQuizzes(
        limit: query.limit,
        categoryId: query.categoryId,
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

  Future<List<Quiz>> getQuizzes({int? limit, String? categoryId}) async {
    try {
      // Build query string based on params
      Map<String, dynamic> queryParameters = {};
      if (limit != null) queryParameters['limit'] = limit;
      if (categoryId != null && categoryId != 'all')
        queryParameters['category'] = categoryId;

      final response = await _apiClient.dio.get(
        '/quizzes',
        queryParameters: queryParameters,
      );
      final data = response.data;

      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data.containsKey('quizzes')) {
        items = data['quizzes'];
      }
      return items.map((json) => Quiz.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
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
