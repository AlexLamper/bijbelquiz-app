/// The Bible chapter a quiz is about.
///
/// Worked out on the server from the references the questions already carry
/// (`src/lib/quiz-passage.ts`), so the app and the website always offer the
/// reader the same passage and the Dutch book abbreviation table exists once.
/// Null when a quiz spans several books - there is then no single chapter to
/// read first, and offering one would be a lie.
class QuizPassage {
  const QuizPassage({
    required this.book,
    required this.chapter,
    required this.label,
  });

  final String book;
  final int chapter;

  /// "Daniël 2" - what the reader is offered.
  final String label;

  static QuizPassage? fromJson(Object? json) {
    if (json is! Map) return null;

    final book = json['book']?.toString() ?? '';
    final chapter = (json['chapter'] as num?)?.toInt() ?? 0;
    if (book.isEmpty || chapter < 1) return null;

    final label = json['label']?.toString();
    return QuizPassage(
      book: book,
      chapter: chapter,
      label: label != null && label.isNotEmpty ? label : '$book $chapter',
    );
  }

  // Value equality: this is used as a Riverpod family key, and without it every
  // rebuild would look like a different passage and refetch the chapter.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizPassage && other.book == book && other.chapter == chapter);

  @override
  int get hashCode => Object.hash(book, chapter);
}
