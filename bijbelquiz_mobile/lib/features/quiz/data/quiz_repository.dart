import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
        // A stale list is shown at once while a fresh one loads; when the
        // fresh one differs, this provider runs again and picks it up.
        onRefreshed: () {
          if (ref.mounted) ref.invalidateSelf();
        },
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

  static const _catalogueCacheKey = 'quiz_catalogue_v1';
  static const _catalogueFreshFor = Duration(minutes: 2);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Quiz>? _catalogue;
  String? _catalogueSignature;
  DateTime? _catalogueAt;
  Future<List<Quiz>>? _refreshing;

  /// Catalogue used by the library, the home screen and the multiplayer
  /// quickstart.
  ///
  /// It is the same list for every caller, so it is fetched once and filtered
  /// here. Reads are served from memory while fresh and, after a restart, from
  /// the copy kept on the device: the list shows on the first frame and a fresh
  /// one is fetched behind it. [onRefreshed] fires only when that fresh copy
  /// differs from what was shown.
  Future<List<Quiz>> getQuizzes({
    int? limit,
    String? categoryId,
    bool? includePremium,
    void Function()? onRefreshed,
  }) async {
    var quizzes = await _loadCatalogue(onRefreshed);

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

  Future<List<Quiz>> _loadCatalogue(void Function()? onRefreshed) async {
    final at = _catalogueAt;
    final memory = _catalogue;
    if (memory != null &&
        at != null &&
        DateTime.now().difference(at) < _catalogueFreshFor) {
      return memory;
    }

    if (memory == null) {
      final stored = await _readCatalogueCache();
      if (stored != null) {
        _catalogue = stored.quizzes;
        _catalogueSignature = stored.signature;
        // Epoch: shown now, but never counted as fresh.
        _catalogueAt = DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    final stale = _catalogue;
    if (stale == null) return _refreshCatalogue();

    final shown = _catalogueSignature;
    unawaited(
      _refreshCatalogue()
          .then((_) {
            if (_catalogueSignature != shown) onRefreshed?.call();
          })
          .catchError((_) {}),
    );
    return stale;
  }

  Future<List<Quiz>> _refreshCatalogue() {
    return _refreshing ??= _fetchCatalogue().whenComplete(
      () => _refreshing = null,
    );
  }

  Future<List<Quiz>> _fetchCatalogue() async {
    List<dynamic> items;
    var light = true;
    try {
      items = await _getCatalogueFromMobileApi();
    } catch (_) {
      light = false;
      items = await _getCatalogueFromSite();
    }

    final quizzes = items
        .whereType<Map<String, dynamic>>()
        .map(Quiz.fromJson)
        .toList();
    final signature = quizzes.map((q) => '${q.id}:${q.title}:${q.isPremium}')
        .join('|');

    _catalogue = quizzes;
    _catalogueSignature = signature;
    _catalogueAt = DateTime.now();

    // Only the light list is kept on the device; the site's full documents
    // carry every question and are not worth storing.
    if (light) unawaited(_writeCatalogueCache(items));
    return quizzes;
  }

  /// `/api/mobile/quizzes`: cards only, with the chapter and difficulty worked
  /// out on the server. A server that predates those fields is treated as
  /// unavailable, so the fallback keeps difficulty filters working.
  Future<List<dynamic>> _getCatalogueFromMobileApi() async {
    final response = await _apiClient.dio.get<dynamic>(
      '/quizzes',
      options: Options(
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    final items = _extractQuizList(response.data);
    if (items.isEmpty) throw Exception('Empty quiz catalogue');
    final first = items.first;
    if (first is! Map || !first.containsKey('difficulty')) {
      throw Exception('Catalogue without difficulty');
    }
    return items.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  /// `/api/quizzes`: the complete documents the website reads. Heavy; only a
  /// fallback now.
  Future<List<dynamic>> _getCatalogueFromSite() async {
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
        .toList();
  }

  Future<({List<Quiz> quizzes, String signature})?>
  _readCatalogueCache() async {
    try {
      final stored = await _storage.read(key: _catalogueCacheKey);
      if (stored == null) return null;
      final decoded = jsonDecode(stored);
      if (decoded is! List || decoded.isEmpty) return null;
      final quizzes = decoded
          .whereType<Map>()
          .map((json) => Quiz.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      final signature = quizzes
          .map((q) => '${q.id}:${q.title}:${q.isPremium}')
          .join('|');
      return (quizzes: quizzes, signature: signature);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCatalogueCache(List<dynamic> items) async {
    try {
      await _storage.write(key: _catalogueCacheKey, value: jsonEncode(items));
    } catch (_) {
      // Only costs the next launch a network wait.
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

    /// Played before signing in and written now that there is an account.
    /// Recorded on the server's funnel event only.
    bool claimed = false,
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
          if (claimed) 'claimed': true,
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
