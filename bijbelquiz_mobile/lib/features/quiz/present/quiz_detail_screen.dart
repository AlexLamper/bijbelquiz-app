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
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
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
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    children: [
                      // Hero banner
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: 190,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (quiz.image.isNotEmpty)
                                ServerImage(
                                  imagePath: quiz.image,
                                  fit: BoxFit.cover,
                                )
                              else
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.accentGradient,
                                  ),
                                ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                              ),
                              if (quiz.isPremium)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF4D6),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                        color: Color(0xFF8C6500),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.category?.name ?? 'Algemeen',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        quiz.description.isNotEmpty
                            ? quiz.description
                            : 'Test je kennis over dit onderwerp!',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(
                                value: '$questionCount',
                                label: 'Vragen',
                              ),
                              _divider,
                              _StatColumn(
                                value: '$minutes min',
                                label: 'Duur',
                              ),
                              _divider,
                              _StatColumn(
                                value: '${quiz.xpReward}',
                                label: 'XP beloning',
                              ),
                              _divider,
                              _StatColumn(
                                value: quiz.difficultyLabelNl,
                                label: 'Niveau',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final pathId = quiz.slug.isNotEmpty
                            ? quiz.slug
                            : quiz.id;
                        context.push('/quiz/$pathId/play');
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Quiz'),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text('Fout: $err', textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => ref.invalidate(quizDetailProvider(idOrSlug)),
                  child: const Text('Opnieuw proberen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final Widget _divider = const VerticalDivider(
    color: AppTheme.border,
    thickness: 1,
    width: 20,
  );
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
