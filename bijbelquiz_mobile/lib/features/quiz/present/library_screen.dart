import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/server_image.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_repository.dart';
import '../domain/category.dart';
import '../domain/quiz.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'all';
  String _selectedSort = 'popular';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(quizzesProvider(const QuizQuery()));
    await ref.read(quizzesProvider(const QuizQuery()).future);
  }

  List<Quiz> _buildVisibleQuizzes(List<Quiz> quizzes, Set<String> playedIds) {
    final filtered = quizzes.where((quiz) {
      final matchesCategory =
          _selectedCategory == 'all' ||
          quiz.categoryId == _selectedCategory ||
          quiz.category?.id == _selectedCategory ||
          quiz.category?.slug == _selectedCategory;

      final matchesSearch =
          _searchQuery.isEmpty ||
          quiz.title.toLowerCase().contains(_searchQuery) ||
          quiz.description.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      // Quizzes still to play always come first. A library that opens on the
      // ones you already finished gets the same few replayed while the rest is
      // never found.
      final aPlayed = playedIds.contains(a.id);
      final bPlayed = playedIds.contains(b.id);
      if (aPlayed != bPlayed) return aPlayed ? 1 : -1;

      switch (_selectedSort) {
        case 'short':
          return a.questionCount.compareTo(b.questionCount);
        case 'reward':
          return b.xpReward.compareTo(a.xpReward);
        case 'popular':
        default:
          final questionCompare = b.questionCount.compareTo(a.questionCount);
          if (questionCompare != 0) return questionCompare;
          return b.xpReward.compareTo(a.xpReward);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery()));
    // Signed-out readers simply see no "afgerond" marks.
    final playedQuizIds = ref
        .watch(profileProvider)
        .maybeWhen(data: (profile) => profile.playedQuizIds, orElse: () => const <String>{});

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.ink,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: _refreshData,
          child: quizzesAsync.when(
            data: (quizzes) {
              final visibleQuizzes = _buildVisibleQuizzes(
                quizzes,
                playedQuizIds,
              );

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const GradientHeader(
                    eyebrow: 'Quizzen',
                    title: 'Alle quizzen',
                    subtitle:
                        'Speel solo en test je kennis op je eigen tempo. Kies '
                        'een categorie of zoek op titel.',
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      cursorColor: AppTheme.ink,
                      cursorWidth: 1.4,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 14,
                        color: AppTheme.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Zoek quizzen…',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 17,
                          color: AppTheme.inkMuted,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _searchController.clear,
                                splashRadius: 18,
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CategoryChips(
                    categoriesAsync: categoriesAsync,
                    selectedCategory: _selectedCategory,
                    onSelect: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // `border-y border-rule` result bar with the sort control.
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.rule),
                        bottom: BorderSide(color: AppTheme.rule),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${visibleQuizzes.length} quizzen'.toUpperCase(),
                            style: AppTheme.overline,
                          ),
                        ),
                        _SortSelector(
                          selectedSort: _selectedSort,
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (visibleQuizzes.isEmpty)
                    const _NoQuizCard()
                  else
                    for (var i = 0; i < visibleQuizzes.length; i++) ...[
                      if (i > 0) const SizedBox(height: 36),
                      _QuizListCard(
                        quiz: visibleQuizzes[i],
                        played: playedQuizIds.contains(visibleQuizzes[i].id),
                        onTap: () => context.push(
                          '/quiz/${visibleQuizzes[i].slug.isNotEmpty ? visibleQuizzes[i].slug : visibleQuizzes[i].id}',
                        ),
                      ),
                    ],
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 260), AppLoader()],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 100),
                AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Quizzen konden niet laden',
                  description: '$err',
                ),
              ],
            ),
          ),
        ),
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
            itemCount: chipItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _CategoryChip(
              label: chipItems[i].value,
              active: chipItems[i].key == selectedCategory,
              onTap: () => onSelect(chipItems[i].key),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 36, child: AppLoader(size: 18)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Inactive: `h-9 rounded-md border-rule bg-paper-raised px-4 text-ink`
/// Active  : `h-9 rounded-md bg-ink px-4 text-ink-inverted`
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.ink : AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: active ? AppTheme.ink : AppTheme.rule),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              color: active ? AppTheme.inkInverted : AppTheme.ink,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dropdown trigger - `h-9 w-full justify-start rounded-md border-rule px-3`.
class _SortSelector extends StatelessWidget {
  const _SortSelector({required this.selectedSort, required this.onChanged});

  final String selectedSort;
  final ValueChanged<String> onChanged;

  static const Map<String, String> _labels = {
    'popular': 'Meest populair',
    'short': 'Kortste',
    'reward': 'Hoogste XP',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: AppTheme.paperRaised,
      elevation: 0,
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return _labels.entries
            .map(
              (entry) => PopupMenuItem<String>(
                value: entry.key,
                height: 40,
                child: Text(
                  entry.value,
                  style: AppTheme.bodyStrong.copyWith(
                    color: entry.key == selectedSort
                        ? AppTheme.ink
                        : AppTheme.inkSoft,
                  ),
                ),
              ),
            )
            .toList();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.rule),
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.paperRaised,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.rule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labels[selectedSort] ?? _labels['popular']!,
              style: AppTheme.caption.copyWith(
                color: AppTheme.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 15,
              color: AppTheme.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// The site's quiz card, one per row on mobile.
class _QuizListCard extends StatelessWidget {
  const _QuizListCard({
    required this.quiz,
    required this.onTap,
    this.played = false,
  });

  final Quiz quiz;
  final VoidCallback onTap;

  /// Already finished at least once by this account.
  final bool played;

  @override
  Widget build(BuildContext context) {
    final minutes = (quiz.questionCount / 2).ceil().clamp(3, 25);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      splashColor: AppTheme.paperSunken,
      highlightColor: AppTheme.paperSunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.paperSunken,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.rule),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (quiz.image.isEmpty)
                    const Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: AppTheme.inkMuted,
                        size: 24,
                      ),
                    )
                  else
                    ServerImage(imagePath: quiz.image, fit: BoxFit.cover),
                  // A finished quiz says so at full strength: somebody
                  // scanning the list should never have to open a quiz to find
                  // out they already did it.
                  if (played)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.positive,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 12,
                              color: AppTheme.inkInverted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'AFGEROND',
                              style: AppTheme.overline.copyWith(
                                color: AppTheme.inkInverted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (quiz.isPremium)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.paperRaised.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTheme.overline.copyWith(
                            color: AppTheme.vermilion,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: AppTheme.metaLabel,
              children: [
                TextSpan(
                  text: (quiz.category?.name ?? 'Algemeen').toUpperCase(),
                ),
                const TextSpan(
                  text: '   /   ',
                  style: TextStyle(color: AppTheme.ruleStrong),
                ),
                TextSpan(text: quiz.difficultyLabelNl.toUpperCase()),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            quiz.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.displayTitle,
          ),
          const SizedBox(height: 8),
          Text(
            quiz.description.isEmpty
                ? 'Bekijk quizdetails op de volgende pagina.'
                : quiz.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.rule)),
            ),
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                // Single flexible run so narrow phones ellipsize the meta line
                // instead of overflowing the row.
                Expanded(
                  child: Text(
                    '${quiz.questionCount} vragen  ·  $minutes min  ·  ${quiz.xpReward} XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Start',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.inkSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: AppTheme.inkSoft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoQuizCard extends StatelessWidget {
  const _NoQuizCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Text(
        'Geen quizzen gevonden met de huidige filters.',
        style: AppTheme.bodyMuted,
      ),
    );
  }
}
