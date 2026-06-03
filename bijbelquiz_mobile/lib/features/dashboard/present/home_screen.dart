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

    final profile = profileAsync.asData?.value;
    final userName = profile?.name ?? 'Speler';
    final streak = profile?.streak ?? 0;
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final isPremiumUser = profile?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  _HomeHero(
                    name: userName,
                    streak: streak,
                    level: level,
                    xp: xp,
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(title: 'Hoe wil je spelen?'),
                  const SizedBox(height: 10),
                  _ModeSelector(
                    onSolo: () => context.go('/quizzes'),
                    onTogether: () => context.go('/play-together'),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Uitdaging van de dag'),
                  const SizedBox(height: 10),
                  if (featuredQuiz != null)
                    _DailyChallengeCard(
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
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Ontdek quizzen'),
                  const SizedBox(height: 10),
                  _HomeSearchField(controller: _searchController),
                  const SizedBox(height: 12),
                  _CategoryStrip(
                    categoriesAsync: categoriesAsync,
                    selectedCategory: _selectedCategory,
                    onSelect: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Populair',
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

/// Navy hero with greeting + a compact stats strip (level, reeks, punten).
class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.name,
    required this.streak,
    required this.level,
    required this.xp,
  });

  final String name;
  final int streak;
  final int level;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brand.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welkom terug',
                      style: TextStyle(
                        color: Color(0xFFC7D2F2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTheme.sansFontName,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isEmpty ? 'U' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroStat(
                icon: Icons.military_tech_rounded,
                value: 'Level $level',
                label: 'Niveau',
              ),
              _heroDivider,
              _HeroStat(
                icon: Icons.local_fire_department_rounded,
                value: streak == 1 ? '1 dag' : '$streak dagen',
                label: 'Reeks',
              ),
              _heroDivider,
              _HeroStat(
                icon: Icons.bolt_rounded,
                value: _formatNumber(xp),
                label: 'Punten',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static final Widget _heroDivider = Container(
    width: 1,
    height: 34,
    color: Colors.white.withValues(alpha: 0.16),
  );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFB9C8F2), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFADBBE6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Two clearly distinct entry points: Solo (singleplayer) vs Samen (multiplayer).
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.onSolo, required this.onTogether});

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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient ? null : Colors.white,
          gradient: gradient ? AppTheme.accentGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: gradient ? null : Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: gradient
                  ? AppTheme.accent.withValues(alpha: 0.30)
                  : AppTheme.ink.withValues(alpha: 0.05),
              blurRadius: gradient ? 18 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: gradient
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: gradient ? Colors.white : AppTheme.accent,
                size: 23,
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

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Zoek een quiz...',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppTheme.accent : AppTheme.border,
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

/// Featured "challenge of the day" card with an image header and CTA.
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({
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

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / gradient banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (quiz.image.isNotEmpty)
                      ServerImage(imagePath: quiz.image, fit: BoxFit.cover)
                    else
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                        ),
                      ),
                    // Dark scrim for legible badges
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _Badge(
                            label: 'Uitgelicht',
                            icon: Icons.star_rounded,
                          ),
                          if (quiz.isPremium) ...[
                            const SizedBox(width: 8),
                            _Badge(
                              label: 'Premium',
                              icon: Icons.workspace_premium_rounded,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTheme.sansFontName,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLockedPremium
                        ? 'Exclusief voor Premium. Ontgrendel om direct te spelen.'
                        : (quiz.description.isEmpty
                              ? 'Test vandaag je kennis in deze uitdaging.'
                              : quiz.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.help_outline_rounded,
                        text: '${quiz.questionCount} vragen',
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        text: '$minutes min',
                      ),
                      const Spacer(),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Text(
                              isLockedPremium ? 'Ontgrendel' : 'Start',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isLockedPremium
                                  ? Icons.lock_open_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.muted, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 78,
              height: 78,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  quiz.category?.name ?? 'Algemeen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                        color: AppTheme.canvas,
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
    );
  }
}

class _NoQuizState extends StatelessWidget {
  const _NoQuizState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Text(
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
        gradient: AppTheme.accentGradient,
      ),
      child: const Text(
        'Nieuwe uitdaging verschijnt zodra quizdata geladen is.',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatNumber(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}
