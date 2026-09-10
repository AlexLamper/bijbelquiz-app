import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pending_attempt_store.dart';
import 'quiz_repository.dart';

/// What a claim run achieved, for the one notice it produces.
class PendingAttemptClaimSummary {
  const PendingAttemptClaimSummary({
    required this.saved,
    required this.xpEarned,
    this.firstTitle,
  });

  final int saved;
  final int xpEarned;
  final String? firstTitle;

  bool get isEmpty => saved == 0;
}

/// Writes the attempts parked by `PendingAttemptStore` to the account that
/// has just signed in.
///
/// Run from one place - the app root listens to `authControllerProvider` -
/// so it does not matter whether the sign-in came from the profile tab, the
/// result screen, Google or Apple. Each attempt goes through the ordinary
/// `/progress` route with `claimed: true`, which the server records on the
/// funnel event and otherwise treats like any other attempt.
class PendingAttemptClaimer {
  const PendingAttemptClaimer(this._repository, this._store);

  final QuizRepository _repository;
  final PendingAttemptStore _store;

  Future<PendingAttemptClaimSummary> claim() async {
    final pending = await _store.read();
    if (pending.isEmpty) {
      return const PendingAttemptClaimSummary(saved: 0, xpEarned: 0);
    }

    var saved = 0;
    var xpEarned = 0;
    String? firstTitle;

    for (final attempt in pending) {
      final result = await _repository.submitQuizResult(
        quizId: attempt.quizId,
        correctAnswers: attempt.correctAnswers,
        totalQuestions: attempt.totalQuestions,
        selectedAnswerIndexes: attempt.selectedAnswerIndexes,
        claimed: true,
      );

      // Offline, or the server refused: the attempt stays parked for the
      // next sign-in, and the store's own age limit disposes of one that
      // can never be written (a quiz that has since been removed).
      if (result == null) continue;

      saved += 1;
      xpEarned += result.xpEarned;
      firstTitle ??= attempt.quizTitle;
      await _store.remove(attempt.completedAt);
    }

    return PendingAttemptClaimSummary(
      saved: saved,
      xpEarned: xpEarned,
      firstTitle: firstTitle,
    );
  }
}

final pendingAttemptClaimerProvider = Provider<PendingAttemptClaimer>(
  (ref) => PendingAttemptClaimer(
    ref.watch(quizRepositoryProvider),
    ref.watch(pendingAttemptStoreProvider),
  ),
);
