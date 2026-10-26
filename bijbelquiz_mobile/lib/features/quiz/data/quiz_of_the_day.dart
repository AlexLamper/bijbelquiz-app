import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/quiz.dart';
import 'quiz_repository.dart';

/// The quiz on the home screen's daily card.
///
/// The card used to wait for the whole catalogue - every quiz with all of its
/// questions - just to pick one. It now asks `GET /api/mobile/quiz-of-the-day`
/// for the single quiz it shows, and remembers the answer on the device: the
/// pick is the same all day, so opening the app again shows the card on the
/// first frame while a fresh copy is fetched in the background.
final quizOfTheDayProvider = StreamProvider<Quiz?>((ref) async* {
  final repository = QuizOfTheDayRepository(ref.watch(apiClientProvider));
  final today = QuizOfTheDayRepository.dayNumber(DateTime.now());

  // Today's cached pick first, so the card is there before any network.
  final cached = await repository.readCache(today);
  if (cached != null) yield cached;

  try {
    final fresh = await repository.fetch();
    unawaited(repository.writeCache(today, fresh.raw));
    // Skip a redundant rebuild when the cache already showed the same quiz.
    if (cached == null || cached.id != fresh.quiz.id) yield fresh.quiz;
    return;
  } catch (_) {
    // Offline, or a server that does not have the endpoint yet.
    if (cached != null) return;
  }

  // Last resort: the old way, from the full catalogue.
  final catalogue = await ref.read(
    quizzesProvider(const QuizQuery(includePremium: true)).future,
  );
  yield pickFromCatalogue(catalogue);
});

class QuizOfTheDayRepository {
  QuizOfTheDayRepository(this._apiClient, [FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  static const _cacheKey = 'quiz_of_the_day_v1';

  /// Whole days since the Unix epoch in UTC - the server's day, so the card
  /// never keeps showing yesterday's quiz past the server's midnight.
  static int dayNumber(DateTime now) {
    final utc = now.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  Future<({Quiz quiz, Map<String, dynamic> raw})> fetch() async {
    final response = await _apiClient.dio.get<dynamic>(
      '/quiz-of-the-day',
      // A tiny payload: if it is not here quickly, the fallback is better
      // than waiting out the default ten seconds.
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    final data = response.data;
    if (data is! Map) throw const FormatException('Unexpected response');
    final raw = Map<String, dynamic>.from(data);
    final quiz = Quiz.fromJson(raw);
    if (quiz.id.isEmpty) throw const FormatException('Quiz without id');
    return (quiz: quiz, raw: raw);
  }

  Future<Quiz?> readCache(int today) async {
    try {
      final stored = await _storage.read(key: _cacheKey);
      if (stored == null) return null;
      final decoded = jsonDecode(stored);
      if (decoded is! Map || decoded['day'] != today) return null;
      final quiz = decoded['quiz'];
      if (quiz is! Map) return null;
      return Quiz.fromJson(Map<String, dynamic>.from(quiz));
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCache(int today, Map<String, dynamic> raw) async {
    try {
      await _storage.write(
        key: _cacheKey,
        value: jsonEncode({'day': today, 'quiz': raw}),
      );
    } catch (_) {
      // A cache that cannot be written only costs the next open a fetch.
    }
  }
}

/// One quiz a day, the same for everybody: a stable pick from the free
/// catalogue, so nobody is offered a quiz of the day they cannot play.
/// Mirrors `quizOfTheDayIndex` on the server; used only when the dedicated
/// endpoint is unreachable.
Quiz? pickFromCatalogue(List<Quiz> quizzes, [DateTime? now]) {
  if (quizzes.isEmpty) return null;
  final free = quizzes.where((q) => !q.isPremium).toList();
  final pool = [...(free.isEmpty ? quizzes : free)]
    ..sort((a, b) => a.id.compareTo(b.id));
  return pool[QuizOfTheDayRepository.dayNumber(now ?? DateTime.now()) %
      pool.length];
}
