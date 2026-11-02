import '../domain/quiz.dart';
import 'widgets/bible_books.dart';

/// Bible order for every quiz list in the app, the same order the website and
/// the catalogue API use (`src/lib/quiz-order.ts` in the web repo):
///
///  1. the books in the order of the canon (Genesis ... Openbaring),
///  2. inside a book, the chapters as numbers - Hoofdstuk 1, 2, 3 ... 10, 11,
///     never 1, 10, 100, 2 - a story quiz without a chapter in its title at
///     the chapter its questions cite, a quiz with neither first,
///  3. quizzes that are not about one book after the books, by title.
///
/// The chapter is read from the title ("Genesis bijbelquiz - Hoofdstuk 12"),
/// because that is what the card says; the book from the series slug
/// (`1-samuel-bijbelquiz-deel-3`), else from the passage the server sent.
int compareQuizzesInBibleOrder(Quiz a, Quiz b) {
  final book = _bookOrder(a).compareTo(_bookOrder(b));
  if (book != 0) return book;
  final part = _chapterPosition(a).compareTo(_chapterPosition(b));
  if (part != 0) return part;
  final title = compareNatural(a.title, b.title);
  if (title != 0) return title;
  return a.id.compareTo(b.id);
}

/// A sorted copy in Bible order.
List<Quiz> sortedInBibleOrder(Iterable<Quiz> quizzes) =>
    quizzes.toList()..sort(compareQuizzesInBibleOrder);

final RegExp _seriesSlug = RegExp(r'^(.+?)-bijbelquiz-deel-\d+$');

/// "Hoofdstuk 12", "Deel 12", "(12)" or a trailing "12" at the end of a title.
final RegExp _partPattern = RegExp(
  r'(?:\b(?:hoofdstuk|hfst\.?|deel|dl\.?|part)\s*(\d+)|\(\s*(\d+)\s*\)|\s-\s(\d+)|[^\s\d]\s+(\d+))\s*$',
  caseSensitive: false,
);

/// The book a quiz is about, 1..66 in canonical order; 999 for a quiz that is
/// not about one book (themes, people, general knowledge).
int bookOrderOf(Quiz quiz) => _bookOrder(quiz);

/// Most played first: the server's count of different players, then - for the
/// many quizzes nobody played yet - the longer and more rewarding ones, then
/// Bible order so ties never shuffle.
int compareByPopularity(Quiz a, Quiz b) {
  final players = b.players.compareTo(a.players);
  if (players != 0) return players;
  final questions = b.questionCount.compareTo(a.questionCount);
  if (questions != 0) return questions;
  final reward = b.xpReward.compareTo(a.xpReward);
  if (reward != 0) return reward;
  return compareQuizzesInBibleOrder(a, b);
}

/// The "Populair" picks for one player: the most played quizzes this player
/// has NOT played yet. A strip that keeps opening on quizzes you already
/// finished gets the same few replayed while the rest is never found. Only
/// when nearly everything is played does it top up with played ones, so the
/// strip is never empty.
List<Quiz> popularPicks(
  Iterable<Quiz> quizzes,
  Set<String> playedIds, {
  int count = 8,
}) {
  final ranked = quizzes.toList()..sort(compareByPopularity);
  final fresh = ranked
      .where((quiz) => !playedIds.contains(quiz.id))
      .take(count)
      .toList();
  if (fresh.length >= count) return fresh;
  return [
    ...fresh,
    ...ranked
        .where((quiz) => playedIds.contains(quiz.id))
        .take(count - fresh.length),
  ];
}

int _bookOrder(Quiz quiz) {
  final slug = _seriesSlug.firstMatch(quiz.slug.trim().toLowerCase());
  if (slug != null) {
    final order = BibleBooks.info(slug.group(1)!).order;
    if (order != 999) return order;
  }
  final book = quiz.passage?.book;
  if (book != null && book.trim().isNotEmpty) {
    return BibleBooks.info(book).order;
  }
  return 999;
}

/// The chapter in the title, else the one the server read off the questions.
int _chapterPosition(Quiz quiz) {
  final part = titlePart(quiz.title);
  if (part > 0) return part;
  return quiz.passage?.chapter ?? 0;
}

/// 12 for "Genesis bijbelquiz - Hoofdstuk 12"; 0 when the title names no part.
int titlePart(String title) {
  final match = _partPattern.firstMatch(title.trim());
  if (match == null) return 0;
  for (var i = 1; i <= match.groupCount; i++) {
    final digits = match.group(i);
    if (digits != null) return int.tryParse(digits) ?? 0;
  }
  return 0;
}

final RegExp _chunk = RegExp(r'\d+|\D+');

/// Case-insensitive compare that reads runs of digits as numbers, so
/// "Psalm 2" comes before "Psalm 10".
int compareNatural(String a, String b) {
  final left = _chunk.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
  final right = _chunk.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();
  for (var i = 0; i < left.length && i < right.length; i++) {
    final x = left[i];
    final y = right[i];
    final nx = int.tryParse(x);
    final ny = int.tryParse(y);
    final c = (nx != null && ny != null) ? nx.compareTo(ny) : x.compareTo(y);
    if (c != 0) return c;
  }
  return left.length.compareTo(right.length);
}
