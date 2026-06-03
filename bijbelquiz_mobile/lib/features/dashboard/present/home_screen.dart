import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/server_image.dart';
import '../../profile/present/profile_provider.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/category.dart';
import '../../quiz/domain/quiz.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
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
    ref.invalidate(profileProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(quizzesProvider(const QuizQuery(includePremium: true)));
    await ref.read(
      quizzesProvider(const QuizQuery(includePremium: true)).future,
    );
  }

  List<Quiz> _filterQuizzes(List<Quiz> quizzes) {
    return quizzes.where((quiz) {
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
  }

  List<Quiz> _sortForHome(List<Quiz> quizzes, {required bool isPremiumUser}) {
    final sorted = [...quizzes];
    if (!isPremiumUser) {
      sorted.sort((a, b) {
        if (a.isPremium == b.isPremium) return 0;
        return a.isPremium ? -1 : 1;
      });
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final quizzesAsync = ref.watch(
      quizzesProvider(const QuizQuery(includePremium: true)),
    );

    final userName = profileAsync.asData?.value.name ?? 'Speler';
    final streak = profileAsync.asData?.value.streak ?? 0;
    final isPremiumUser = profileAsync.asData?.value.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: quizzesAsync.when(
            data: (quizzes) {
              final filteredQuizzes = _sortForHome(
                _filterQuizzes(quizzes),
                isPremiumUser: isPremiumUser,
              );
              final featuredQuiz = filteredQuizzes.isNotEmpty
                  ? filteredQuizzes.first
                  : (quizzes.isNotEmpty ? quizzes.first : null);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  GradientHeader(
                    title: 'Hallo, $userName',
                    subtitle: 'Klaar voor een nieuwe uitdaging vandaag?',
                    trailing: _StreakPill(streak: streak),
                  ),
                  const SizedBox(height: 16),
                  _HomeSearchField(controller: _searchController),
                  const SizedBox(height: 14),
                  _CategoryStrip(
                    categoriesAsync: categoriesAsync,
                    selectedCategory: _selectedCategory,
                    onSelect: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Uitgelicht'),
                  const SizedBox(height: 10),
                  if (featuredQuiz != null)
                    _FeaturedChallengeCard(
                      quiz: featuredQuiz,
                      isLockedPremium: featuredQuiz.isPremium && !isPremiumUser,
                      onTap: () {
                        if (featuredQuiz.isPremium && !isPremiumUser) {
                          context.push('/premium');
                          return;
                        }
                        context.push(
                          '/quiz/${featuredQuiz.slug.isNotEmpty ? featuredQuiz.slug : featuredQuiz.id}/play',
                        );
                      },
                    )
                  else
                    const _EmptyFeaturedCard(),
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Kies je speelmodus'),
                  const SizedBox(height: 10),
                  _GameModeSelector(
                    onSolo: () => context.go('/quizzes'),
                    onTogether: () => context.go('/play-together'),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Populaire Quizzen',
                    actionLabel: 'Bekijk alles',
                    onAction: () => context.go('/quizzes'),
                  ),
                  const SizedBox(height: 10),
                  if (filteredQuizzes.isEmpty)
                    const _NoQuizState()
                  else
                    ...filteredQuizzes
                        .take(5)
                        .map(
                          (quiz) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PopularQuizTile(
                              quiz: quiz,
                              isLockedPremium: quiz.isPremium && !isPremiumUser,
                              onTap: () {
                                if (quiz.isPremium && !isPremiumUser) {
                                  context.push('/premium');
                                  return;
                                }
                                context.push(
                                  '/quiz/${quiz.slug.isNotEmpty ? quiz.slug : quiz.id}',
                                );
                              },
                            ),
                          ),
                        ),
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 200),
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
                  'Fout bij laden van home: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFFC773),
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(
            streak == 1 ? 'dag' : 'dagen',
            style: const TextStyle(
              color: Color(0xFFC7D2F2),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF131D2B).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Zoek quizen...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.muted),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
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
        final items = <MapEntry<String, String>>[
          const MapEntry('all', 'Alles'),
          ...categories.map((category) => MapEntry(category.id, category.name)),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryChip(
                      label: item.value,
                      active: selectedCategory == item.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FeaturedChallengeCard extends StatelessWidget {
  const _FeaturedChallengeCard({
    required this.quiz,
    required this.onTap,
    required this.isLockedPremium,
  });

  final Quiz quiz;
  final VoidCallback onTap;
  final bool isLockedPremium;

  @override
  Widget build(BuildContext context) {
    final minutes = (quiz.questionCount / 2).ceil().clamp(3, 25);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D86DB).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6D86DB), Color(0xFF89A4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6D86DB).withValues(alpha: 0.82),
                      const Color(0xFF89A4FF).withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: -64,
              right: -34,
              child: _BackgroundOrb(size: 168, alpha: 0.14),
            ),
            const Positioned(
              bottom: -72,
              left: -28,
              child: _BackgroundOrb(size: 138, alpha: 0.11),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Uitgelicht',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (quiz.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quiz.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTheme.sansFontName,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLockedPremium
                        ? 'Deze quiz is exclusief voor Premium. Ontgrendel om direct te spelen.'
                        : (quiz.description.isEmpty
                              ? 'Test vandaag je kennis in deze uitdaging.'
                              : quiz.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFEAF0FF),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MetaInfo(
                        icon: Icons.help_outline_rounded,
                        text: '${quiz.questionCount} Vragen',
                      ),
                      const SizedBox(width: 14),
                      _MetaInfo(
                        icon: Icons.schedule_rounded,
                        text: '$minutes min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.ink,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLockedPremium
                            ? 'Ontgrendel Premium'
                            : 'Start Uitdaging',
                      ),
                    ),
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

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 15),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Two clearly distinct entry points so it is obvious which is singleplayer
/// (Solo) and which is multiplayer (Samen / live met vrienden).
class _GameModeSelector extends StatelessWidget {
  const _GameModeSelector({required this.onSolo, required this.onTogether});

  final VoidCallback onSolo;
  final VoidCallback onTogether;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ModeTile(
            onTap: onSolo,
            icon: Icons.person_rounded,
            tag: 'SOLO',
            title: 'Speel Alleen',
            subtitle: 'Test je kennis in je eigen tempo.',
            gradient: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeTile(
            onTap: onTogether,
            icon: Icons.groups_2_rounded,
            tag: 'MULTIPLAYER',
            title: 'Speel Samen',
            subtitle: 'Live tegen vrienden, tot 20 spelers.',
            gradient: true,
          ),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.onTap,
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final onColor = gradient ? Colors.white : AppTheme.ink;
    final subColor = gradient ? const Color(0xFFEAF0FF) : AppTheme.muted;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient ? null : Colors.white,
          gradient: gradient ? AppTheme.accentGradient : null,
          borderRadius: BorderRadius.circular(18),
          border: gradient ? null : Border.all(color: AppTheme.border),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: gradient
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: gradient ? Colors.white : AppTheme.accent,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: gradient
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: gradient ? Colors.white : AppTheme.accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: onColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.sansFontName,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: subColor,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularQuizTile extends StatelessWidget {
  const _PopularQuizTile({
    required this.quiz,
    required this.onTap,
    required this.isLockedPremium,
  });

  final Quiz quiz;
  final VoidCallback onTap;
  final bool isLockedPremium;

  @override
  Widget build(BuildContext context) {
    final minutes = (quiz.questionCount / 2).ceil().clamp(3, 25);
    final difficultyLabel = quiz.difficultyLabelNl;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 84,
                height: 84,
                color: const Color(0xFFEFF2FA),
                child: quiz.image.isEmpty
                    ? const Icon(Icons.menu_book_rounded, color: AppTheme.muted)
                    : ServerImage(imagePath: quiz.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.category?.name ?? 'Algemeen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        size: 14,
                        color: AppTheme.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questionCount}',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
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
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (quiz.isPremium) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Color(0xFF8C6500),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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
                          difficultyLabel,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLockedPremium)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Alleen beschikbaar met Premium',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _NoQuizState extends StatelessWidget {
  const _NoQuizState();

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
        'Geen quizzen gevonden voor deze filters.',
        style: TextStyle(color: AppTheme.muted),
      ),
    );
  }
}

class _EmptyFeaturedCard extends StatelessWidget {
  const _EmptyFeaturedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.accent,
      ),
      child: const Text(
        'Nieuwe uitdaging verschijnt zodra quizdata geladen is.',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
