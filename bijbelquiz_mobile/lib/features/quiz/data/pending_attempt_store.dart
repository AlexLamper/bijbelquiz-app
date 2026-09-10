import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A quiz finished without an account, parked on this device.
///
/// The app can be played signed out. The result screen offers to keep the
/// score, and for that offer to mean anything the attempt has to survive
/// until an account exists. `PendingAttemptClaimer` then writes every parked
/// attempt through the ordinary `/progress` route, which re-grades the
/// answers itself, so nothing here is trusted by the server.
class PendingAttempt {
  const PendingAttempt({
    required this.quizId,
    required this.quizTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.selectedAnswerIndexes,
    required this.completedAt,
  });

  final String quizId;
  final String quizTitle;
  final int correctAnswers;
  final int totalQuestions;

  /// Option index picked per question, `null` where none was.
  final List<int?> selectedAnswerIndexes;

  /// Also the attempt's key in the store.
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'quizTitle': quizTitle,
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
    'selectedAnswerIndexes': selectedAnswerIndexes,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  static PendingAttempt? fromJson(Map<String, dynamic> json) {
    final quizId = json['quizId'];
    final completedAt = json['completedAt'];
    if (quizId is! String || quizId.isEmpty || completedAt is! num) {
      return null;
    }

    final rawIndexes = json['selectedAnswerIndexes'];
    final indexes = rawIndexes is List
        ? rawIndexes
              .map((value) => value is num ? value.toInt() : null)
              .toList()
        : const <int?>[];

    return PendingAttempt(
      quizId: quizId,
      quizTitle: json['quizTitle'] as String? ?? '',
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      selectedAnswerIndexes: indexes,
      completedAt: DateTime.fromMillisecondsSinceEpoch(completedAt.toInt()),
    );
  }
}

class PendingAttemptStore {
  PendingAttemptStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _key = 'pending_attempts_v1';

  /// More than this is farming, not saving. The oldest go first.
  static const int maxAttempts = 5;

  /// Long enough to come back tomorrow, short enough not to be a surprise.
  static const Duration maxAge = Duration(days: 7);

  /// Every attempt still waiting for an account, oldest first.
  Future<List<PendingAttempt>> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final cutoff = DateTime.now().subtract(maxAge);
      final attempts = <PendingAttempt>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final attempt = PendingAttempt.fromJson(
          Map<String, dynamic>.from(entry),
        );
        if (attempt == null || attempt.completedAt.isBefore(cutoff)) continue;
        attempts.add(attempt);
      }

      attempts.sort((a, b) => a.completedAt.compareTo(b.completedAt));
      return attempts;
    } catch (error) {
      // A value some earlier build wrote differently, or storage that will
      // not open: the player still gets their result screen.
      assert(() {
        debugPrint('[PendingAttempts] read failed: $error');
        return true;
      }());
      return const [];
    }
  }

  Future<void> add(PendingAttempt attempt) async {
    final next = [...await read(), attempt];
    await _write(
      next.length > maxAttempts
          ? next.sublist(next.length - maxAttempts)
          : next,
    );
  }

  Future<void> remove(DateTime completedAt) async {
    final remaining = (await read())
        .where((attempt) => attempt.completedAt != completedAt)
        .toList();
    await _write(remaining);
  }

  Future<void> clear() => _write(const []);

  Future<void> _write(List<PendingAttempt> attempts) async {
    try {
      if (attempts.isEmpty) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(
          key: _key,
          value: jsonEncode(attempts.map((a) => a.toJson()).toList()),
        );
      }
    } catch (error) {
      assert(() {
        debugPrint('[PendingAttempts] write failed: $error');
        return true;
      }());
    }
  }
}

final pendingAttemptStoreProvider = Provider<PendingAttemptStore>(
  (ref) => PendingAttemptStore(),
);

/// The parked attempts, for the screens that mention them. Invalidate after
/// every add or claim.
final pendingAttemptsProvider = FutureProvider<List<PendingAttempt>>(
  (ref) => ref.watch(pendingAttemptStoreProvider).read(),
);
