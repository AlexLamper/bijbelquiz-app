import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/features/quiz/data/free_quiz_limit.dart';

void main() {
  test('a new player has every free quiz left', () {
    const allowance = FreeQuizAllowance(isPremium: false, playedQuizIds: {});
    expect(allowance.remaining, kFreeQuizLimit);
    expect(allowance.limitReached, isFalse);
    expect(allowance.canPlay('q1'), isTrue);
  });

  test('after the free quizzes a new quiz is blocked, replays are not', () {
    const allowance = FreeQuizAllowance(
      isPremium: false,
      playedQuizIds: {'q1', 'q2', 'genesis'},
    );
    expect(allowance.remaining, 0);
    expect(allowance.limitReached, isTrue);
    expect(allowance.canPlay('q9'), isFalse);
    expect(allowance.canPlay('q1'), isTrue);
    // Played by slug (deep link) still counts as played.
    expect(allowance.canPlay('q3', slug: 'genesis'), isTrue);
  });

  test('premium is never limited', () {
    const allowance = FreeQuizAllowance(
      isPremium: true,
      playedQuizIds: {'q1', 'q2', 'q3', 'q4'},
    );
    expect(allowance.limitReached, isFalse);
    expect(allowance.canPlay('q9'), isTrue);
  });
}
