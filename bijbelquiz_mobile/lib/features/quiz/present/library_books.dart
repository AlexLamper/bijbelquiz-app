part of 'library_screen.dart';

// ---------------------------------------------------------------------------
// Per bijbelboek
//
// The library can be browsed by book: a strip of books on Quizzen, a page
// with every book (Oude and Nieuwe Testament), and one page per book with its
// quizzes in chapter order - Hoofdstuk 1, 2, 3 ... - and "Ga verder met" on
// the first one this player has not played yet.
// ---------------------------------------------------------------------------

/// One Bible book with the quizzes about it.
class LibraryBook {
  const LibraryBook({
    required this.order,
    required this.name,
    required this.quizzes,
    required this.played,
  });

  /// 1..66 in canonical order.
  final int order;
  final String name;

  /// In chapter order.
  final List<Quiz> quizzes;

  /// How many of [quizzes] this player finished.
  final int played;

  bool get oldTestament => order <= BibleBooks.otCount;
  bool get done => quizzes.isNotEmpty && played == quizzes.length;
  BookTint get tint =>
      oldTestament ? BookTint.oldTestament : BookTint.newTestament;
  String get abbreviation => BibleBooks.info(name).abbreviation;

  /// "12 quizzen", or "3 van 12 gespeeld" once the player started the book.
  String get countLabel {
    final total = quizzes.length;
    if (played == 0) return total == 1 ? '1 quiz' : '$total quizzen';
    return '$played van $total gespeeld';
  }
}

/// The books that have quizzes, in canonical order. Quizzes that are not
/// about one book (themes, people) are left out: they have the categories.
List<LibraryBook> libraryBooks(Iterable<Quiz> quizzes, Set<String> playedIds) {
  final byBook = <int, List<Quiz>>{};
  for (final quiz in quizzes) {
    final order = bookOrderOf(quiz);
    if (order < 1 || order > 66) continue;
    (byBook[order] ??= <Quiz>[]).add(quiz);
  }
  final orders = byBook.keys.toList()..sort();
  return [
    for (final order in orders)
      LibraryBook(
        order: order,
        name: BibleBooks.nameFor(order) ?? '',
        quizzes: sortedInBibleOrder(byBook[order]!),
        played: byBook[order]!.where((q) => playedIds.contains(q.id)).length,
      ),
  ];
}

/// Horizontal strip of books on Quizzen.
class _BookStrip extends StatelessWidget {
  const _BookStrip({required this.books, required this.onOpen});

  final List<LibraryBook> books;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context);
    final height = 12 + 40 + 10 + s.scale(19) + s.scale(16) + 12 + 2;
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _BookTile(
          book: books[i],
          onTap: () => onOpen(books[i].order),
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, required this.onTap});

  final LibraryBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Semantics(
        button: true,
        onTap: onTap,
        label: '${book.name}, ${book.countLabel}',
        excludeSemantics: true,
        child: BqCard(
          padding: const EdgeInsets.all(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BookBadge(book: book, size: 40),
              const SizedBox(height: 10),
              Text(
                book.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              Text(
                book.played == 0
                    ? book.countLabel
                    : '${book.played}/${book.quizzes.length} gespeeld',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: book.played == 0
                      ? AppTheme.inkMuted
                      : AppTheme.positiveText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The book's short name on its testament's tint; a check once every quiz in
/// it is played.
class _BookBadge extends StatelessWidget {
  const _BookBadge({required this.book, required this.size});

  final LibraryBook book;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = book.tint;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: book.done ? AppTheme.positive : tint.background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: book.done
          ? BqIcon(BqIcons.check, size: size * 0.5, color: AppTheme.inkInverted)
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  book.abbreviation,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w900,
                    color: tint.foreground,
                  ),
                ),
              ),
            ),
    );
  }
}

/// Back to wherever the page was opened from, or to Quizzen after a deep link.
void _backToLibrary(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/quizzes');
  }
}

Set<String> _playedIdsOf(WidgetRef ref) => ref
    .watch(profileProvider)
    .maybeWhen(
      data: (profile) => profile.playedQuizIds,
      orElse: () => const <String>{},
    );

/// Loading and error states shared by the two book pages.
Widget _catalogueState(
  BuildContext context,
  AsyncValue<List<Quiz>> async,
  Widget Function(List<Quiz> quizzes) data,
) {
  return async.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: data,
    loading: () => const Padding(
      padding: EdgeInsets.only(top: 120),
      child: AppLoader(),
    ),
    error: (err, _) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: AppEmptyState(
        icon: Icons.error_outline,
        title: 'Quizzen konden niet laden',
        description: '$err',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Alle boeken
// ---------------------------------------------------------------------------

/// Every book with quizzes, grouped by testament.
class LibraryBooksScreen extends ConsumerWidget {
  const LibraryBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery()));
    final playedIds = _playedIdsOf(ref);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.lapis,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: () async {
            ref.invalidate(quizzesProvider(const QuizQuery()));
            ref.invalidate(profileProvider);
            await ref.read(quizzesProvider(const QuizQuery()).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              BqTopBar(
                title: 'Per bijbelboek',
                onBack: () => _backToLibrary(context),
              ),
              const SizedBox(height: 8),
              _catalogueState(context, quizzesAsync, (quizzes) {
                final books = libraryBooks(quizzes, playedIds);
                final oldT = books.where((b) => b.oldTestament).toList();
                final newT = books.where((b) => !b.oldTestament).toList();
                void open(LibraryBook book) {
                  final key = BibleBooks.keyFor(book.order);
                  if (key != null) context.push('/quizzes/boek/$key');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (oldT.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TestamentHeader(
                        title: 'Oude Testament',
                        books: oldT,
                      ),
                      const SizedBox(height: 10),
                      BqListCard(
                        children: [
                          for (final book in oldT)
                            _BookRow(book: book, onTap: () => open(book)),
                        ],
                      ),
                    ],
                    if (newT.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _TestamentHeader(
                        title: 'Nieuwe Testament',
                        books: newT,
                      ),
                      const SizedBox(height: 10),
                      BqListCard(
                        children: [
                          for (final book in newT)
                            _BookRow(book: book, onTap: () => open(book)),
                        ],
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestamentHeader extends StatelessWidget {
  const _TestamentHeader({required this.title, required this.books});

  final String title;
  final List<LibraryBook> books;

  @override
  Widget build(BuildContext context) {
    final quizzes = books.fold<int>(0, (sum, b) => sum + b.quizzes.length);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppTheme.displaySmall)),
        Text(
          '${books.length} boeken · $quizzes quizzen',
          style: AppTheme.caption,
        ),
      ],
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.book, required this.onTap});

  final LibraryBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = book.quizzes.isEmpty
        ? 0.0
        : book.played / book.quizzes.length;
    return Semantics(
      button: true,
      onTap: onTap,
      label: '${book.name}, ${book.countLabel}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _BookBadge(book: book, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      book.countLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: book.played == 0
                            ? AppTheme.inkMuted
                            : AppTheme.positiveText,
                      ),
                    ),
                    if (book.played > 0) ...[
                      const SizedBox(height: 6),
                      BqProgressBar(
                        value: progress,
                        color: AppTheme.positive,
                        height: 5,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const BqIcon(
                BqIcons.chevronRight,
                size: 18,
                color: AppTheme.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Eén boek
// ---------------------------------------------------------------------------

/// One book: its quizzes in chapter order, played ones marked where they are
/// (pulling them out would turn 1, 2, 3 into 2, 3, ... 1), and the next one
/// to play on top.
class LibraryBookScreen extends ConsumerWidget {
  const LibraryBookScreen({super.key, required this.bookKey});

  /// [BibleBooks.keyFor] of the book ("genesis", "1samuel").
  final String bookKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = BibleBooks.orderForKey(bookKey);
    final name = BibleBooks.nameFor(order) ?? 'Bijbelboek';
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery()));
    final playedIds = _playedIdsOf(ref);
    void openQuiz(Quiz quiz) => context.push('/quiz/${_routeKey(quiz)}');

    final book = quizzesAsync.asData?.value
        .where((q) => bookOrderOf(q) == order)
        .toList();
    final quizzes = book == null ? const <Quiz>[] : sortedInBibleOrder(book);
    final played = quizzes.where((q) => playedIds.contains(q.id)).length;
    final next = quizzes.where((q) => !playedIds.contains(q.id)).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BqTopBar(
                      title: name,
                      subtitle: book == null
                          ? null
                          : played == 0
                          ? '${quizzes.length} quizzen'
                          : '$played van ${quizzes.length} gespeeld',
                      onBack: () => _backToLibrary(context),
                    ),
                    if (book == null)
                      _catalogueState(
                        context,
                        quizzesAsync,
                        (_) => const SizedBox.shrink(),
                      )
                    else if (quizzes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: BqCard(
                          child: Text(
                            'Over dit boek zijn nog geen quizzen.',
                            style: AppTheme.bodyMuted,
                          ),
                        ),
                      )
                    else ...[
                      if (played > 0) ...[
                        const SizedBox(height: 14),
                        BqProgressBar(
                          value: played / quizzes.length,
                          color: AppTheme.positive,
                        ),
                      ],
                      if (next != null) ...[
                        const SizedBox(height: 16),
                        _NextInBookCard(
                          quiz: next,
                          first: played == 0,
                          onTap: () => openQuiz(next),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Text(
                        'Alle quizzen over $name',
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            if (quizzes.isNotEmpty)
              _QuizRowsSliver(
                quizzes: quizzes,
                playedIds: playedIds,
                onOpen: openQuiz,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

/// "Begin met" / "Ga verder met" the first quiz of the book not played yet.
class _NextInBookCard extends StatelessWidget {
  const _NextInBookCard({
    required this.quiz,
    required this.first,
    required this.onTap,
  });

  final Quiz quiz;
  final bool first;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = first ? 'BEGIN MET' : 'GA VERDER MET';
    return Semantics(
      button: true,
      onTap: onTap,
      label: '${first ? 'Begin met' : 'Ga verder met'} ${quiz.title}',
      excludeSemantics: true,
      child: Material(
        color: AppTheme.lapis,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: QuizCover(
                      imagePath: quiz.imageOrFallback,
                      thumbnailPath: quiz.thumbnail,
                      background: _tintFor(quiz).background,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppTheme.inkInverted.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        quiz.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.displayBase.copyWith(
                          color: AppTheme.inkInverted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppTheme.paperRaised,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const BqIcon(
                    BqIcons.chevronRight,
                    size: 18,
                    color: AppTheme.lapis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
