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
