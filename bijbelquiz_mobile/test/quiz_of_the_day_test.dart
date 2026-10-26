import 'package:bijbelquiz_mobile/features/quiz/data/quiz_of_the_day.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

Quiz _quiz(String id, {bool premium = false}) => Quiz(
  id: id,
  title: 'Quiz $id',
  slug: id,
  description: '',
  image: '',
  xpReward: 50,
  isPremium: premium,
);

void main() {
  test('day number counts whole UTC days since the epoch', () {
    expect(QuizOfTheDayRepository.dayNumber(DateTime.utc(1970, 1, 1)), 0);
    expect(
      QuizOfTheDayRepository.dayNumber(DateTime.utc(2026, 10, 26, 23, 59)),
      20752,
    );
  });

  test('the catalogue fallback picks a free quiz, stable within a day', () {
    final quizzes = [_quiz('c', premium: true), _quiz('b'), _quiz('a')];
    final morning = pickFromCatalogue(quizzes, DateTime.utc(2026, 10, 26, 1));
    final night = pickFromCatalogue(quizzes, DateTime.utc(2026, 10, 26, 23));
    expect(morning!.id, night!.id);
    expect(morning.isPremium, isFalse);
  });

  test('an empty catalogue has no quiz of the day', () {
    expect(pickFromCatalogue(const []), isNull);
  });
}
