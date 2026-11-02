import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/features/quiz/domain/quiz.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/library_screen.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/quiz_order.dart';
import 'package:bijbelquiz_mobile/features/quiz/present/widgets/bible_books.dart';

Quiz _chapter(String book, String slugBook, int n, {int players = 0}) => Quiz(
  id: '$slugBook-$n',
  title: '$book bijbelquiz - Hoofdstuk $n',
  slug: '$slugBook-bijbelquiz-deel-$n',
  description: '',
  image: '',
  xpReward: 50,
  questionCount: 10,
  players: players,
);

void main() {
  test('Populair leaves out what the player already played', () {
    final quizzes = [
      _chapter('Genesis', 'genesis', 1, players: 90),
      _chapter('Genesis', 'genesis', 2, players: 80),
      _chapter('Johannes', 'johannes', 3, players: 70),
      _chapter('Ruth', 'ruth', 1, players: 5),
    ];
    final picks = popularPicks(quizzes, {'genesis-1', 'genesis-2'}, count: 2);
    expect(picks.map((q) => q.id), ['johannes-3', 'ruth-1']);
  });

  test('Populair tops up with played quizzes only when it runs out', () {
    final quizzes = [
      _chapter('Genesis', 'genesis', 1, players: 90),
      _chapter('Genesis', 'genesis', 2, players: 80),
      _chapter('Ruth', 'ruth', 1, players: 5),
    ];
    final picks = popularPicks(quizzes, {'genesis-1', 'genesis-2'}, count: 3);
    expect(picks.map((q) => q.id), ['ruth-1', 'genesis-1', 'genesis-2']);
  });

  test('books come in canon order with their chapters as numbers', () {
    final books = libraryBooks([
      _chapter('Johannes', 'johannes', 10),
      _chapter('Genesis', 'genesis', 10),
      _chapter('Genesis', 'genesis', 2),
      _chapter('1 Samuël', '1-samuel', 1),
      _chapter('Johannes', 'johannes', 1),
    ], {'genesis-2'});

    expect(books.map((b) => b.name), ['Genesis', '1 Samuël', 'Johannes']);
    expect(books.first.quizzes.map((q) => q.id), ['genesis-2', 'genesis-10']);
    expect(books.first.played, 1);
    expect(books.first.countLabel, '1 van 2 gespeeld');
    expect(books.last.countLabel, '2 quizzen');
  });

  test('a book key round-trips to its order', () {
    for (var order = 1; order <= 66; order++) {
      final key = BibleBooks.keyFor(order)!;
      expect(BibleBooks.orderForKey(key), order, reason: key);
      expect(BibleBooks.nameFor(order), isNotNull);
    }
  });
}
