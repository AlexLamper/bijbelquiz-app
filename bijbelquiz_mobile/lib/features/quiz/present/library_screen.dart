import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/server_image.dart';
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

  List<Quiz> _buildVisibleQuizzes(List<Quiz> quizzes) {
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

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: quizzesAsync.when(
            data: (quizzes) {
              final visibleQuizzes = _buildVisibleQuizzes(quizzes);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const Text(
                    'Alle Quizzen',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTheme.sansFontName,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Zoek quizen...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.muted,
                      ),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.close_rounded),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${visibleQuizzes.length} quizzen gevonden',
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w700,
                          ),
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
                  const SizedBox(height: 12),
                  if (visibleQuizzes.isEmpty)
                    const _NoQuizCard()
                  else
                    ...visibleQuizzes.map(
                      (quiz) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _QuizListCard(
                          quiz: quiz,
                          onTap: () => context.push(
                            '/quiz/${quiz.slug.isNotEmpty ? quiz.slug : quiz.id}',
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 260),
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 120),
                const Icon(
                  Icons.error_outline,
                  size: 52,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Fout bij laden quizzen: $err',
                  textAlign: TextAlign.center,
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chipItems
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryChip(
                      label: item.value,
                      active: item.key == selectedCategory,
                      onTap: () => onSelect(item.key),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

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
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.filterActive : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? Colors.transparent : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
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
    'popular': 'Meest Populair',
    'short': 'Kortste',
    'reward': 'Hoogste XP',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) {
        return _labels.entries
            .map(
              (entry) => PopupMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labels[selectedSort] ?? _labels['popular']!,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _QuizListCard extends StatelessWidget {
  const _QuizListCard({required this.quiz, required this.onTap});

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minutes = (quiz.questionCount / 2).ceil().clamp(3, 25);
    final difficulty = quiz.difficulty.isEmpty ? 'Gemiddeld' : quiz.difficulty;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 72,
                height: 72,
                color: const Color(0xFFEEF2FA),
                child: quiz.image.isEmpty
                    ? const Icon(Icons.menu_book_rounded, color: AppTheme.muted)
                    : ServerImage(imagePath: quiz.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          quiz.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTheme.sansFontName,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficulty,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    quiz.description.isEmpty
                        ? 'Bekijk quizdetails op de volgende pagina.'
                        : quiz.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        size: 14,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questionCount} vragen',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$minutes min',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.xpReward} XP',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoQuizCard extends StatelessWidget {
  const _NoQuizCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Text(
        'Geen quizzen gevonden met de huidige filters.',
        style: TextStyle(color: AppTheme.muted),
      ),
    );
  }
}
