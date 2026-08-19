import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/quiz_preferences.dart';

/// Reads and writes the study preferences that live on the account.
///
/// Both endpoints are the website's own: `/api/user/me` and
/// `/api/user/settings` accept this app's bearer token, so there is no separate
/// mobile copy of the settings contract to drift out of step.
class QuizPreferencesRepository {
  QuizPreferencesRepository(this._apiClient);

  final ApiClient _apiClient;

  String get _webBase => AppConfig.baseUrl;

  Future<QuizPreferences> fetch() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '$_webBase/api/user/me',
    );

    final settings = response.data?['settings'];
    return QuizPreferences.fromJson(
      settings is Map<String, dynamic> ? settings : null,
    );
  }

  Future<void> save(QuizPreferences preferences) async {
    await _apiClient.dio.put(
      '$_webBase/api/user/settings',
      data: {'settings': preferences.toSettingsPatch()},
    );
  }
}

final quizPreferencesRepositoryProvider = Provider<QuizPreferencesRepository>(
  (ref) => QuizPreferencesRepository(ref.watch(apiClientProvider)),
);

/// The preferences, applied locally the instant they change and written to the
/// account in the background.
///
/// A study preference is not worth a spinner: the reader toggled a switch on
/// the way into a quiz, and blocking that on a round trip would be felt on
/// every quiz. A failed write costs persistence, nothing else.
class QuizPreferencesController extends Notifier<QuizPreferences> {
  Timer? _debounce;

  @override
  QuizPreferences build() {
    ref.onDispose(() => _debounce?.cancel());
    unawaited(_load());
    return const QuizPreferences();
  }

  Future<void> _load() async {
    try {
      final loaded = await ref.read(quizPreferencesRepositoryProvider).fetch();
      state = loaded;
    } catch (error) {
      // Signed out, offline, or the server is unhappy - the defaults are a
      // perfectly good quiz.
      assert(() {
        debugPrint('[QuizPreferences] load failed: $error');
        return true;
      }());
    }
  }

  /// Re-read from the account, e.g. after signing in.
  Future<void> refresh() => _load();

  void setTimerSeconds(int seconds) {
    _update(state.copyWith(questionTimerSeconds: QuizPreferences.normalizeTimer(seconds)));
  }

  void setReadPassageFirst(bool value) {
    _update(state.copyWith(readPassageFirst: value));
  }

  void setShowBibleReferences(bool value) {
    _update(state.copyWith(showBibleReferences: value));
  }

  void setLargeQuestionText(bool value) {
    _update(state.copyWith(largeQuestionText: value));
  }

  void _update(QuizPreferences next) {
    state = next;

    // Coalesced: tapping through the timer choices should not fire four writes.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(_persist(next));
    });
  }

  Future<void> _persist(QuizPreferences preferences) async {
    try {
      await ref.read(quizPreferencesRepositoryProvider).save(preferences);
    } catch (error) {
      assert(() {
        debugPrint('[QuizPreferences] save failed: $error');
        return true;
      }());
    }
  }
}

final quizPreferencesProvider =
    NotifierProvider<QuizPreferencesController, QuizPreferences>(
      QuizPreferencesController.new,
    );
