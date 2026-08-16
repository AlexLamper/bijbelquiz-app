import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/server_image.dart';

class QuizDetailScreen extends ConsumerWidget {
  final String idOrSlug;

  const QuizDetailScreen({super.key, required this.idOrSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: quizAsync.when(
          data: (quiz) {
            final questionCount = quiz.questions.isNotEmpty
                ? quiz.questions.length
                : quiz.questionCount;
            final minutes = (questionCount / 2).ceil().clamp(3, 25);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      // `aspect-16/9 rounded-md bg-paper-sunken ring-1
                      //  ring-rule ring-inset`
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppTheme.paperSunken,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(color: AppTheme.rule),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (quiz.image.isNotEmpty)
                                ServerImage(
                                  imagePath: quiz.image,
                                  fit: BoxFit.cover,
                                )
                              else
                                const Center(
                                  child: Icon(
                                    Icons.menu_book_outlined,
                                    size: 28,
                                    color: AppTheme.inkMuted,
                                  ),
                                ),
                              if (quiz.isPremium)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.paperRaised.withValues(
                                        alpha: 0.95,
                                      ),
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
                      const SizedBox(height: 24),
                      Text.rich(
                        TextSpan(
                          style: AppTheme.metaLabel,
                          children: [
                            TextSpan(
                              text: (quiz.category?.name ?? 'Algemeen')
                                  .toUpperCase(),
                            ),
                            const TextSpan(
                              text: '   /   ',
                              style: TextStyle(color: AppTheme.ruleStrong),
                            ),
                            TextSpan(
                              text: quiz.difficultyLabelNl.toUpperCase(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // `font-display text-[32px] leading-[1.08]
                      //  tracking-[-0.025em]`
                      Text(quiz.title, style: AppTheme.displayLarge),
                      const SizedBox(height: 16),
                      Text(
                        quiz.description.isNotEmpty
                            ? quiz.description
                            : 'Test je kennis over dit onderwerp.',
                        style: AppTheme.bodyLead,
                      ),
                      const SizedBox(height: 28),
                      StatStrip(
                        stacked: true,
                        items: [
                          StatItem(value: '$questionCount', label: 'Vragen'),
                          StatItem(value: '$minutes min', label: 'Duur'),
                          StatItem(
                            value: '${quiz.xpReward}',
                            label: 'XP',
                            ruleColor: AppTheme.positive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sticky CTA bar - `border-t border-rule bg-paper-raised`.
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.paperRaised,
                    border: Border(top: BorderSide(color: AppTheme.rule)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: SiteButton(
                    label: 'Start quiz',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: () {
                      final pathId = quiz.slug.isNotEmpty ? quiz.slug : quiz.id;
                      context.push('/quiz/$pathId/play');
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const AppLoader(),
          error: (err, stack) => AppEmptyState(
            icon: Icons.error_outline,
            title: 'Quiz kon niet laden',
            description: '$err',
            action: SiteOutlineButton(
              label: 'Opnieuw proberen',
              expand: false,
              height: 44,
              onPressed: () => ref.invalidate(quizDetailProvider(idOrSlug)),
            ),
          ),
        ),
      ),
    );
  }
}
