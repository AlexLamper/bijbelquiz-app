import 'package:bijbelquiz_mobile/features/quiz/domain/quiz.dart';
import 'package:bijbelquiz_mobile/features/quiz/domain/quiz_passage.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/quiz_order.dart';
import 'package:flutter_test/flutter_test.dart';

Quiz _quiz(String slug, String title, {String? book}) => Quiz(
  id: slug,
  title: title,
  slug: slug,
  description: '',
  image: '',
  xpReward: 100,
  passage: book == null
      ? null
      : QuizPassage(book: book, chapter: 1, label: '$book 1'),
);

Quiz _quizAt(String slug, String title, String book, int chapter) => Quiz(
  id: slug,
  title: title,
  slug: slug,
  description: '',
  image: '',
  xpReward: 100,
  passage: QuizPassage(book: book, chapter: chapter, label: '$book $chapter'),
);

Quiz _chapter(String bookSlug, String bookTitle, int n) =>
    _quiz('$bookSlug-bijbelquiz-deel-$n', '$bookTitle bijbelquiz - Hoofdstuk $n');

void main() {
  test('chapters sort as numbers: 1, 2, 3 ... 10, never 1, 10, 2', () {
    final shuffled = [100, 2, 10, 1, 23, 3, 150, 11]
        .map((n) => _chapter('psalmen', 'Psalmen', n));
    final order = sortedInBibleOrder(shuffled).map((q) => titlePart(q.title));
    expect(order, [1, 2, 3, 10, 11, 23, 100, 150]);
  });

  test('books follow the canon; themes come last', () {
    final sorted = sortedInBibleOrder([
      _quiz('wie-zei-het', 'Wie zei het?'),
      _chapter('openbaring', 'Openbaring', 1),
      _chapter('johannes', 'Johannes', 3),
      _chapter('1-korinthe', '1 Korinthe', 13),
      _chapter('zefanja', 'Zefanja', 2),
      _chapter('genesis', 'Genesis', 2),
      _chapter('genesis', 'Genesis', 1),
    ]).map((q) => q.slug);
    expect(sorted, [
      'genesis-bijbelquiz-deel-1',
      'genesis-bijbelquiz-deel-2',
      'zefanja-bijbelquiz-deel-2',
      'johannes-bijbelquiz-deel-3',
      '1-korinthe-bijbelquiz-deel-13',
      'openbaring-bijbelquiz-deel-1',
      'wie-zei-het',
    ]);
  });

  test('a story quiz sits at the chapter its questions cite', () {
    final sorted = sortedInBibleOrder([
      _chapter('genesis', 'Genesis', 10),
      _quizAt('genesis-6-de-ark-van-noach', 'De ark van Noach', 'Genesis', 6),
      _chapter('genesis', 'Genesis', 2),
    ]).map((q) => q.slug);
    expect(sorted, [
      'genesis-bijbelquiz-deel-2',
      'genesis-6-de-ark-van-noach',
      'genesis-bijbelquiz-deel-10',
    ]);
  });

  test('a whole-book quiz comes before its chapters', () {
    final sorted = sortedInBibleOrder([
      _chapter('genesis', 'Genesis', 1),
      _quiz('genesis', 'Genesis', book: 'Genesis'),
    ]).map((q) => q.slug);
    expect(sorted, ['genesis', 'genesis-bijbelquiz-deel-1']);
  });

  test('natural compare reads numbers as numbers', () {
    expect(compareNatural('Psalm 2', 'Psalm 10'), lessThan(0));
    expect(compareNatural('psalm 10', 'Psalm 10'), 0);
  });
}
