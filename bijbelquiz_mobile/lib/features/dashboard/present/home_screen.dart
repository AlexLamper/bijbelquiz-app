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
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.ink,
          backgroundColor: AppTheme.paperRaised,
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  _HomeHero(
                    name: userName,
                    streak: streak,
                    level: level,
                    xp: xp,
                  ),
                  const SizedBox(height: 40),
                  const SectionHeader(
                    eyebrow: 'Spelen',
                    title: 'Hoe wil je spelen?',
                  ),
                  const SizedBox(height: 24),
                  _ModeSelector(
                    onSolo: () => context.go('/quizzes'),
                    onTogether: () => context.go('/play-together'),
                  ),
                  const SizedBox(height: 44),
                  const SectionHeader(
                    eyebrow: 'Vandaag',
                    title: 'Uitdaging van de dag',
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 44),
                  const SectionHeader(
                    eyebrow: 'Bibliotheek',
                    title: 'Ontdek quizzen',
                    description:
                        'Zoek op titel of filter op categorie om iets nieuws '
                        'te vinden.',
                  ),
                  const SizedBox(height: 20),
                  _HomeSearchField(controller: _searchController),
                  const SizedBox(height: 14),
                  _CategoryStrip(
                    categoriesAsync: categoriesAsync,
                    selectedCategory: _selectedCategory,
                    onSelect: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  SectionHeader(
                    eyebrow: 'Quizzen',
                    title: 'Populair',
                    actionLabel: 'Bekijk alles',
                    onAction: () => context.go('/quizzes'),
                  ),
                  const SizedBox(height: 24),
                  if (filteredQuizzes.isEmpty)
                    const _NoQuizState()
                  else
                    RuleGrid(
                      children: [
                        for (final quiz in filteredQuizzes.take(5))
                          _PopularQuizTile(
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
                      ],
                    ),
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [SizedBox(height: 200), AppLoader()],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 100),
                AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Home kon niet laden',
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

/// Editorial page intro: eyebrow rule + serif greeting + rule-divided stats.
///
/// Mirrors the site hero:
/// `<span class="eyebrow"><span class="h-px w-6 bg-lapis"/>…</span>`
/// `<h1 class="font-display text-[34px] tracking-[-0.03em]">…</h1>`
/// `<div class="border-y border-rule … divide-x divide-rule">…</div>`
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Welkom terug'),
        const SizedBox(height: 22),
        // `font-display text-[34px] font-semibold leading-[1.06]
        //  tracking-[-0.03em]` with the accent word in lapis.
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 34,
              fontWeight: FontWeight.w600,
              height: 1.06,
              letterSpacing: -1.02,
              color: AppTheme.ink,
            ),
            children: [
              const TextSpan(text: 'Goed je te zien, '),
              TextSpan(
                text: name,
                style: const TextStyle(color: AppTheme.lapis),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Kies een quiz, daag anderen uit op de ranglijst en leer elke dag '
          'iets nieuws over de Bijbel.',
          style: AppTheme.bodyLead,
        ),
        const SizedBox(height: 28),
        StatStrip(
          items: [
            StatItem(value: '$level', label: 'Niveau'),
            StatItem(
              value: '$streak',
              label: streak == 1 ? 'Dag reeks' : 'Dagen reeks',
            ),
            StatItem(value: _formatNumber(xp), label: 'Punten'),
          ],
        ),
      ],
    );
  }
}

/// Two entry points rendered as the site's numbered hairline grid:
/// `grid gap-px overflow-hidden rounded-lg border border-rule bg-rule`.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.onSolo, required this.onTogether});

  final VoidCallback onSolo;
  final VoidCallback onTogether;

  @override
  Widget build(BuildContext context) {
    return RuleGrid(
      children: [
        _ModeTile(
          onTap: onSolo,
          index: '01',
          title: 'Speel alleen',
          subtitle: 'Test je kennis in je eigen tempo',
          indexColor: AppTheme.inkMuted,
        ),
        _ModeTile(
          onTap: onTogether,
          index: '02',
          title: 'Speel samen',
          subtitle: 'Live tegen vrienden, tot 20 spelers',
          indexColor: AppTheme.lapis,
        ),
      ],
    );
  }
}

/// `<a class="group flex items-center gap-4 bg-paper-raised p-5
///    hover:bg-paper-sunken"><span class="font-display text-sm tabular-nums
///    text-ink-muted">01</span>…</a>`
class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.onTap,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.indexColor,
  });

  final VoidCallback onTap;
  final String index;
  final String title;
  final String subtitle;
  final Color indexColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.paperRaised,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                index,
                style: TextStyle(
                  fontFamily: AppTheme.displayFontName,
                  fontSize: 14,
                  color: indexColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.displayBase),
                    const SizedBox(height: 5),
                    Text(subtitle.toUpperCase(), style: AppTheme.overline),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward,
                size: 15,
                color: AppTheme.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `h-10 rounded-md border border-rule bg-paper-raised pl-9 text-sm
///  placeholder:text-ink-muted focus-visible:border-lapis`
class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        cursorColor: AppTheme.ink,
        cursorWidth: 1.4,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 14,
          color: AppTheme.ink,
        ),
        decoration: InputDecoration(
          hintText: 'Zoek een quiz…',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(
            Icons.search,
            size: 17,
            color: AppTheme.inkMuted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clear,
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppTheme.inkMuted,
                  ),
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

        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _CategoryChip(
              label: items[i].value,
              active: selectedCategory == items[i].key,
              onTap: () => onSelect(items[i].key),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 36, child: AppLoader(size: 18)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Site filter button.
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

/// Featured quiz, styled exactly like the site's quiz card:
/// 16:9 image with an inset rule, uppercase meta line, serif title, lead copy
/// and a `border-t border-rule pt-3.5` footer row.
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
                  if (quiz.image.isNotEmpty)
                    ServerImage(imagePath: quiz.image, fit: BoxFit.cover)
                  else
                    const Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 26,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  // `absolute left-3 top-3 rounded-sm bg-paper-raised/95 px-2
                  //  py-1 text-[10px] uppercase tracking-[0.16em] text-lapis`
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Row(
                      children: [
                        const _ImageBadge(
                          label: 'Uitgelicht',
                          color: AppTheme.lapis,
                        ),
                        if (quiz.isPremium) ...[
                          const SizedBox(width: 8),
                          const _ImageBadge(
                            label: 'Premium',
                            color: AppTheme.vermilion,
                          ),
                        ],
                      ],
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
            isLockedPremium
                ? 'Exclusief voor Premium. Ontgrendel om direct te spelen.'
                : (quiz.description.isEmpty
                      ? 'Test vandaag je kennis in deze uitdaging.'
                      : quiz.description),
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
                Expanded(
                  child: Text(
                    '${quiz.questionCount} vragen  ·  $minutes min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isLockedPremium ? 'Ontgrendel' : 'Start',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.inkSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isLockedPremium ? Icons.lock_outline : Icons.arrow_forward,
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

/// `rounded-sm bg-paper-raised/95 px-2 py-1 text-[10px] font-medium uppercase
///  tracking-[0.16em] backdrop-blur-sm`
class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.overline.copyWith(color: color),
      ),
    );
  }
}

/// Row inside the hairline list — mirrors the site's rule-separated rows.
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

    return Material(
      color: AppTheme.paperRaised,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 76,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppTheme.paperSunken,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.rule),
                ),
                child: quiz.image.isEmpty
                    ? const Icon(
                        Icons.menu_book_outlined,
                        color: AppTheme.inkMuted,
                        size: 20,
                      )
                    : ServerImage(imagePath: quiz.image, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (quiz.category?.name ?? 'Algemeen').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.metaLabel,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quiz.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.displayBase,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quiz.questionCount} vragen  ·  $minutes min  ·  '
                      '${quiz.difficultyLabelNl.toLowerCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.caption.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (quiz.isPremium) ...[
                      const SizedBox(height: 10),
                      SiteBadge.vermilion(
                        isLockedPremium ? 'Premium vereist' : 'Premium',
                      ),
                    ],
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

class _NoQuizState extends StatelessWidget {
  const _NoQuizState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Text(
        'Geen quizzen gevonden voor deze filters.',
        style: AppTheme.bodyMuted,
      ),
    );
  }
}

class _EmptyFeaturedCard extends StatelessWidget {
  const _EmptyFeaturedCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Text(
        'Nieuwe uitdaging verschijnt zodra quizdata geladen is.',
        style: AppTheme.bodyMuted,
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
