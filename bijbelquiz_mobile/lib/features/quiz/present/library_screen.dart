import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_repository.dart';
import '../domain/category.dart';
import '../domain/quiz.dart';
import 'library_category_request.dart';
import 'quiz_order.dart';
import 'widgets/bible_books.dart';
import 'widgets/quiz_cover.dart';

String _routeKey(Quiz quiz) => quiz.slug.isNotEmpty ? quiz.slug : quiz.id;

int _minutesFor(int questionCount) => (questionCount / 2).ceil().clamp(3, 25);

BookTint _tintFor(Quiz quiz) => BibleBooks.tintForQuiz(
  book: quiz.passage?.book,
  category: quiz.category?.name,
);

/// "JOHANNES 6", or the category when the quiz spans several books.
String _referenceLabel(Quiz quiz) =>
    (quiz.passage?.label ?? quiz.category?.name ?? 'Algemeen').toUpperCase();

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allQuizzesKey = GlobalKey();

  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  /// Bible order by default: Genesis 1, 2, 3 ... - the way a reader looks
  /// for a chapter, and the order the website lists them in.
  String _selectedSort = 'bible';
  String _searchQuery = '';

  static const List<MapEntry<String, String>> _difficultyChips = [
    MapEntry('all', 'Elk niveau'),
    MapEntry('easy', 'Makkelijk'),
    MapEntry('medium', 'Gemiddeld'),
    MapEntry('hard', 'Moeilijk'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim().toLowerCase();
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });

    // A topic tile on Home may have asked for a category.
    final requested = ref.read(libraryCategoryRequestProvider);
    if (requested != null) {
      _selectedCategory = requested;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(libraryCategoryRequestProvider.notifier).clear();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(quizzesProvider(const QuizQuery()));
    // The "afgerond" marks and the order they impose come off the profile, so
    // a pull that leaves it stale refreshes everything except the one thing
    // the reader just played a quiz to change.
    ref.invalidate(profileProvider);
    await ref.read(quizzesProvider(const QuizQuery()).future);
  }

  bool _matchesCategory(Quiz quiz) =>
      _selectedCategory == 'all' ||
      quiz.categoryId == _selectedCategory ||
      quiz.category?.id == _selectedCategory ||
      quiz.category?.slug == _selectedCategory;

  bool _matchesSearch(Quiz quiz) {
    if (_searchQuery.isEmpty) return true;
    bool has(String? value) =>
        value != null && value.toLowerCase().contains(_searchQuery);
    return has(quiz.title) ||
        has(quiz.description) ||
        has(quiz.passage?.label) ||
        has(quiz.category?.name);
  }

  bool _matchesDifficulty(Quiz quiz) =>
      _selectedDifficulty == 'all' ||
      quiz.difficultyBucket == _selectedDifficulty;

  List<Quiz> _sorted(
    Iterable<Quiz> quizzes,
    Set<String> playedIds,
    String sort,
  ) {
    final list = quizzes.toList();
    // In Bible order a played chapter keeps its place (it is marked as played
    // instead): pulling it out would turn 1, 2, 3 into 2, 3, ... 1.
    if (sort == 'bible') return list..sort(compareQuizzesInBibleOrder);
    list.sort((a, b) {
      // Quizzes still to play always come first. A library that opens on the
      // ones you already finished gets the same few replayed while the rest is
      // never found.
      final aPlayed = playedIds.contains(a.id);
      final bPlayed = playedIds.contains(b.id);
      if (aPlayed != bPlayed) return aPlayed ? 1 : -1;

      switch (sort) {
        case 'newest':
          // ObjectId hex is time-ordered, so it is a fine tie-breaker / fallback
          // when the API did not send createdAt.
          final aKey = a.createdAt.isNotEmpty ? a.createdAt : a.id;
          final bKey = b.createdAt.isNotEmpty ? b.createdAt : b.id;
          return bKey.compareTo(aKey);
        case 'title':
          return compareNatural(a.title, b.title);
        case 'short':
          return a.questionCount.compareTo(b.questionCount);
        case 'reward':
          return b.xpReward.compareTo(a.xpReward);
        case 'popular':
        default:
          final questionCompare = b.questionCount.compareTo(a.questionCount);
          if (questionCompare != 0) return questionCompare;
          final rewardCompare = b.xpReward.compareTo(a.xpReward);
          if (rewardCompare != 0) return rewardCompare;
          // Ties (most quizzes have the same size) stay in Bible order rather
          // than in whatever order the sort happens to leave them.
          return compareQuizzesInBibleOrder(a, b);
      }
    });
    return list;
  }

  void _openQuiz(Quiz quiz) => context.push('/quiz/${_routeKey(quiz)}');

  void _showAllQuizzes() {
    setState(() => _selectedSort = 'popular');
    final target = _allQuizzesKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(libraryCategoryRequestProvider, (_, next) {
      if (next == null) return;
      setState(() => _selectedCategory = next);
      Future.microtask(
        () => ref.read(libraryCategoryRequestProvider.notifier).clear(),
      );
    });

    final categoriesAsync = ref.watch(categoriesProvider);
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery()));
    // Signed-out readers simply see no "afgerond" marks.
    final playedQuizIds = ref
        .watch(profileProvider)
        .maybeWhen(
          data: (profile) => profile.playedQuizIds,
          orElse: () => const <String>{},
        );

    final List<Widget> content = quizzesAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (quizzes) => _buildContent(quizzes, playedQuizIds),
      loading: () => const [
        SliverToBoxAdapter(
          child: Column(children: [SizedBox(height: 160), AppLoader()]),
        ),
      ],
      error: (err, _) => [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Quizzen konden niet laden',
                  description: '$err',
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.lapis,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: _refreshData,
          // Slivers, so the long list of quizzes builds only the rows that are
          // on screen (plus a little ahead) instead of all of them at once.
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Quizzen', style: AppTheme.displayLarge),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SearchField(
                        controller: _searchController,
                        hasText: _searchQuery.isNotEmpty,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CategoryChips(
                      categoriesAsync: categoriesAsync,
                      selectedCategory: _selectedCategory,
                      onSelect: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                  ],
                ),
              ),
              ...content,
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Quiz> quizzes, Set<String> playedIds) {
    final inCategory = quizzes.where(_matchesCategory).toList();
    final filtering = _searchQuery.isNotEmpty;

    final listed = _sorted(
      inCategory.where((q) => _matchesSearch(q) && _matchesDifficulty(q)),
      playedIds,
      _selectedSort,
    );

    final listSection = _AllQuizzesSection(
      key: _allQuizzesKey,
      title: filtering ? 'Resultaten' : 'Alle quizzen',
      quizzes: listed,
      playedIds: playedIds,
      difficultyChips: _difficultyChips,
      selectedDifficulty: _selectedDifficulty,
      onDifficulty: (value) => setState(() => _selectedDifficulty = value),
      selectedSort: _selectedSort,
      onSort: (value) => setState(() => _selectedSort = value),
      onOpen: _openQuiz,
    );

    final rows = _QuizRowsSliver(
      quizzes: listed,
      playedIds: playedIds,
      onOpen: _openQuiz,
    );

    if (filtering) {
      return [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const SizedBox(height: 18), listSection],
          ),
        ),
        rows,
      ];
    }

    final popular = _sorted(
      inCategory,
      const <String>{},
      'popular',
    ).take(8).toList();

    final head = <Widget>[
      if (popular.isNotEmpty) ...[
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionTitle(
            title: 'Populair',
            actionLabel: 'Alles',
            onAction: _showAllQuizzes,
          ),
        ),
        _PopularStrip(
          quizzes: popular,
          playedIds: playedIds,
          onOpen: _openQuiz,
        ),
      ],
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _PlayTogetherCard(onTap: () => context.go('/play-together')),
      ),
      const SizedBox(height: 22),
      listSection,
    ];

    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: head,
        ),
      ),
      rows,
    ];
  }
}

// ---------------------------------------------------------------------------
// Header pieces
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hasText});

  final TextEditingController controller;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      cursorColor: AppTheme.lapis,
      style: const TextStyle(
        fontFamily: AppTheme.sansFontName,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.ink,
      ),
      decoration: InputDecoration(
        hintText: 'Zoek een bijbelboek of onderwerp',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 10),
          child: BqIcon(BqIcons.search, size: 20, color: AppTheme.inkFaint),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Wissen',
                onPressed: controller.clear,
                icon: const BqIcon(
                  BqIcons.close,
                  size: 16,
                  color: AppTheme.inkMuted,
                ),
              )
            : null,
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categoriesAsync,
    required this.selectedCategory,
    required this.onSelect,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) {
        final chipItems = <MapEntry<String, String>>[
          const MapEntry('all', 'Alles'),
          ...categories.map((category) => MapEntry(category.id, category.name)),
        ];

        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chipItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _Chip(
              label: chipItems[i].value,
              active: chipItems[i].key == selectedCategory,
              onTap: () => onSelect(chipItems[i].key),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 36, child: AppLoader(size: 18)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Filter pill: lapis when active, white with a border otherwise.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.height = 36,
    this.fontSize = 14,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? AppTheme.lapis : AppTheme.paperRaised,
        shape: StadiumBorder(
          side: active
              ? BorderSide.none
              : const BorderSide(color: AppTheme.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                color: active ? AppTheme.inkInverted : AppTheme.inkSoft,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Populair ........ Alles" - 16px titles on this screen.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Always 44 tall (the action's tap target), so the gaps around it are the
  /// design's gaps minus the 11px this adds above and below the text.
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: _row(),
    );
  }

  Widget _row() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          Semantics(
            button: true,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 1,
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lapis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Populair
// ---------------------------------------------------------------------------

class _PopularStrip extends StatelessWidget {
  const _PopularStrip({
    required this.quizzes,
    required this.playedIds,
    required this.onOpen,
  });

  final List<Quiz> quizzes;
  final Set<String> playedIds;
  final ValueChanged<Quiz> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.textScalerOf(context);
    // Cover + paddings + border, then the three text lines at the reader's
    // text size, so a larger font never overflows the card.
    final height = 86 + 30 + s.scale(15.5) + s.scale(20) + s.scale(16.5);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: quizzes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _PopularCard(
          quiz: quizzes[i],
          played: playedIds.contains(quizzes[i].id),
          onTap: () => onOpen(quizzes[i]),
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.quiz,
    required this.played,
    required this.onTap,
  });

  final Quiz quiz;
  final bool played;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = _tintFor(quiz);

    return SizedBox(
      width: 196,
      child: Semantics(
        button: true,
        onTap: onTap,
        label: [
          quiz.title,
          if (quiz.isPremium) 'Premium',
          if (played) 'afgerond',
        ].join(', '),
        excludeSemantics: true,
        child: BqCard(
          padding: EdgeInsets.zero,
          onTap: onTap,
          color: played ? AppTheme.positiveTint : AppTheme.paperRaised,
          borderColor: played ? _playedBorder : AppTheme.rule,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 86,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    QuizCover(
                      imagePath: quiz.imageOrFallback,
                      thumbnailPath: quiz.thumbnail,
                      background: tint.background,
                    ),
                    if (played) const _PlayedCoverOverlay(checkSize: 34),
                    if (quiz.isPremium)
                      const Positioned(left: 8, top: 8, child: _PremiumBadge()),
                    if (played)
                      const Positioned(
                        right: 8,
                        top: 8,
                        child: _PlayedPill(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _referenceLabel(quiz),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.44,
                        color: played ? AppTheme.positiveText : tint.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quiz.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: played
                          ? AppTheme.displayBase.copyWith(color: AppTheme.inkSoft)
                          : AppTheme.displayBase,
                    ),
                    const SizedBox(height: 2),
                    if (played)
                      const _PlayedMeta(fontSize: 12)
                    else
                      Text(
                        '${quiz.questionCount} vragen · ${_minutesFor(quiz.questionCount)} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return BqPill(
      label: 'Premium',
      icon: SvgPicture.string(BqIcons.crown, width: 12, height: 12),
      background: AppTheme.paperRaised,
      foreground: AppTheme.goldText,
      height: 22,
      fontSize: 11,
    );
  }
}

/// Border of a played card: the green of the check, softened.
const Color _playedBorder = Color(0x593F6B4F);

/// Laid over the cover of a quiz the reader already finished: the art steps
/// back under a green wash and a check sits in the middle, so a played
/// chapter reads as done from a glance down the list - not only from a dot in
/// the corner.
class _PlayedCoverOverlay extends StatelessWidget {
  const _PlayedCoverOverlay({required this.checkSize});

  final double checkSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.paper.withValues(alpha: 0.42),
      child: ColoredBox(
        color: AppTheme.positive.withValues(alpha: 0.28),
        child: Center(
          child: Container(
            width: checkSize,
            height: checkSize,
            decoration: const BoxDecoration(
              color: AppTheme.positive,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.positiveDeep, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: BqIcon(
              BqIcons.check,
              size: checkSize * 0.56,
              color: AppTheme.inkInverted,
            ),
          ),
        ),
      ),
    );
  }
}

/// "GESPEELD" on a white pill, on the cover of a played quiz.
class _PlayedPill extends StatelessWidget {
  const _PlayedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: const Text(
        'GESPEELD',
        style: TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: AppTheme.positiveText,
        ),
      ),
    );
  }
}

/// "✓ Gespeeld" in place of the length line on a played quiz.
class _PlayedMeta extends StatelessWidget {
  const _PlayedMeta({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BqIcon(BqIcons.check, size: fontSize + 1, color: AppTheme.positiveText),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Gespeeld',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppTheme.positiveText,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Samen spelen
// ---------------------------------------------------------------------------

class _PlayTogetherCard extends StatelessWidget {
  const _PlayTogetherCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onTap,
      label: 'Samen spelen, speel met je groep of klas',
      excludeSemantics: true,
      child: BqCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: const Row(
          children: [
            BqIconTile(
              size: 42,
              radius: 12,
              background: AppTheme.positiveTint,
              child: BqIcon(BqIcons.users, size: 22, color: AppTheme.positive),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Samen spelen',
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  Text(
                    'Speel met je groep of klas',
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            BqIcon(BqIcons.chevronRight, size: 18, color: AppTheme.inkFaint),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Alle quizzen
// ---------------------------------------------------------------------------

class _AllQuizzesSection extends StatelessWidget {
  const _AllQuizzesSection({
    super.key,
    required this.title,
    required this.quizzes,
    required this.playedIds,
    required this.difficultyChips,
    required this.selectedDifficulty,
    required this.onDifficulty,
    required this.selectedSort,
    required this.onSort,
    required this.onOpen,
  });

  final String title;
  final List<Quiz> quizzes;
  final Set<String> playedIds;
  final List<MapEntry<String, String>> difficultyChips;
  final String selectedDifficulty;
  final ValueChanged<String> onDifficulty;
  final String selectedSort;
  final ValueChanged<String> onSort;
  final ValueChanged<Quiz> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: difficultyChips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _Chip(
              label: difficultyChips[i].value,
              active: difficultyChips[i].key == selectedDifficulty,
              height: 32,
              fontSize: 13,
              onTap: () => onDifficulty(difficultyChips[i].key),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  quizzes.length == 1 ? '1 quiz' : '${quizzes.length} quizzen',
                  style: AppTheme.caption,
                ),
              ),
              _SortSelector(selectedSort: selectedSort, onChanged: onSort),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (quizzes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: BqCard(
              child: Text(
                'Geen quizzen gevonden met de huidige filters.',
                style: AppTheme.bodyMuted,
              ),
            ),
          ),
      ],
    );
  }
}

/// The rows under "Alle quizzen", as a lazy sliver: with hundreds of quizzes,
/// only the ones near the screen are built, and only those fetch a cover.
class _QuizRowsSliver extends StatelessWidget {
  const _QuizRowsSliver({
    required this.quizzes,
    required this.playedIds,
    required this.onOpen,
  });

  final List<Quiz> quizzes;
  final Set<String> playedIds;
  final ValueChanged<Quiz> onOpen;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: quizzes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _QuizRow(
          key: ValueKey<String>(quizzes[i].id),
          quiz: quizzes[i],
          played: playedIds.contains(quizzes[i].id),
          onTap: () => onOpen(quizzes[i]),
        ),
      ),
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({required this.selectedSort, required this.onChanged});

  final String selectedSort;
  final ValueChanged<String> onChanged;

  static const Map<String, String> _labels = {
    'bible': 'Bijbelvolgorde',
    'popular': 'Meest populair',
    'newest': 'Nieuwste eerst',
    'title': 'Titel (A-Z)',
    'short': 'Kortste',
    'reward': 'Hoogste XP',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Sorteren',
      onSelected: onChanged,
      color: AppTheme.paperRaised,
      elevation: 0,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.rule),
      ),
      itemBuilder: (context) => _labels.entries
          .map(
            (entry) => PopupMenuItem<String>(
              value: entry.key,
              height: 44,
              child: Text(
                entry.value,
                style: AppTheme.bodyStrong.copyWith(
                  color: entry.key == selectedSort
                      ? AppTheme.lapis
                      : AppTheme.inkSoft,
                ),
              ),
            ),
          )
          .toList(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Center(
          widthFactor: 1,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.paperRaised,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: AppTheme.rule),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _labels[selectedSort] ?? _labels['bible']!,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppTheme.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One quiz in the full list: cover thumbnail, reference, title, meta.
class _QuizRow extends StatelessWidget {
  const _QuizRow({
    super.key,
    required this.quiz,
    required this.played,
    required this.onTap,
  });

  final Quiz quiz;
  final bool played;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = _tintFor(quiz);
    final meta = [
      '${quiz.questionCount} vragen',
      '${_minutesFor(quiz.questionCount)} min',
      _difficultyLabel(quiz),
      if (quiz.xpReward > 0) '${quiz.xpReward} XP',
    ].join(' · ');

    return Semantics(
      button: true,
      onTap: onTap,
      label: [
        quiz.title,
        meta,
        if (quiz.isPremium) 'Premium',
        if (played) 'afgerond',
      ].join(', '),
      excludeSemantics: true,
      child: BqCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        color: played ? AppTheme.positiveTint : AppTheme.paperRaised,
        borderColor: played ? _playedBorder : AppTheme.rule,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    QuizCover(
                      imagePath: quiz.imageOrFallback,
                      thumbnailPath: quiz.thumbnail,
                      background: tint.background,
                    ),
                    if (played) const _PlayedCoverOverlay(checkSize: 30),
                  ],
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
                    _referenceLabel(quiz),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.44,
                      color: played ? AppTheme.positiveText : tint.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quiz.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: played
                        ? AppTheme.displayBase.copyWith(color: AppTheme.inkSoft)
                        : AppTheme.displayBase,
                  ),
                  const SizedBox(height: 3),
                  if (played) ...[
                    const _PlayedMeta(fontSize: 12.5),
                    const SizedBox(height: 1),
                  ],
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (quiz.isPremium) ...[
              const SizedBox(width: 8),
              SvgPicture.string(BqIcons.crown, width: 20, height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

String _difficultyLabel(Quiz quiz) {
  switch (quiz.difficultyBucket) {
    case 'easy':
      return 'Makkelijk';
    case 'hard':
      return 'Moeilijk';
    default:
      return 'Gemiddeld';
  }
}
