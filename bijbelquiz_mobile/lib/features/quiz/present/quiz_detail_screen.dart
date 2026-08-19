import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/server_image.dart';
import '../../settings/data/quiz_preferences_controller.dart';
import '../../settings/domain/quiz_preferences.dart';

class QuizDetailScreen extends ConsumerWidget {
  final String idOrSlug;

  const QuizDetailScreen({super.key, required this.idOrSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));
    final preferences = ref.watch(quizPreferencesProvider);

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
                      const SizedBox(height: 32),

                      // This screen is also where the quiz is set up. The
                      // choices are saved to the account, so they are made once
                      // rather than before every quiz.
                      const SectionHeader(
                        eyebrow: 'Instellingen',
                        title: 'Hoe wil je spelen?',
                        description:
                            'Wordt onthouden voor je volgende quizzen, ook op de website.',
                      ),
                      const SizedBox(height: 20),
                      _QuizSettings(quiz: quiz, preferences: preferences),
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
                    label: preferences.readPassageFirst && quiz.passage != null
                        ? 'Lees ${quiz.passage!.label} en start'
                        : 'Start quiz',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: () {
                      final pathId = quiz.slug.isNotEmpty ? quiz.slug : quiz.id;
                      final readFirst =
                          preferences.readPassageFirst && quiz.passage != null;
                      context.push(
                        readFirst
                            ? '/quiz/$pathId/lezen'
                            : '/quiz/$pathId/play',
                      );
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

/// The setup block on the quiz overview: read the chapter first, and how long
/// you get per question.
///
/// Both are written straight to the account by the controller, so this widget
/// only reflects state - there is no local copy to fall out of step.
class _QuizSettings extends ConsumerWidget {
  const _QuizSettings({required this.quiz, required this.preferences});

  final Quiz quiz;
  final QuizPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quizPreferencesProvider.notifier);
    final passage = quiz.passage;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        border: Border.all(color: AppTheme.rule),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Only offered when the questions actually agree on one chapter.
          if (passage != null) ...[
            _SettingRow(
              icon: Icons.menu_book_outlined,
              title: 'Lees eerst ${passage.label}',
              description:
                  'Je leest het hoofdstuk waar deze quiz over gaat voordat de vragen beginnen.',
              trailing: Switch.adaptive(
                value: preferences.readPassageFirst,
                activeTrackColor: AppTheme.ink,
                onChanged: controller.setReadPassageFirst,
              ),
            ),
            const Divider(height: 1, color: AppTheme.rule),
          ],

          _SettingRow(
            icon: Icons.timer_outlined,
            title: 'Tijd per vraag',
            description: 'Standaard uit. Zet een klok aan als je jezelf wilt uitdagen.',
            below: Row(
              children: [
                for (final choice in QuizPreferences.timerChoices)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: choice == QuizPreferences.timerChoices.last ? 0 : 8,
                      ),
                      child: _ChoiceChip(
                        label: choice == 0 ? 'Uit' : '${choice}s',
                        selected: preferences.questionTimerSeconds == choice,
                        onTap: () => controller.setTimerSeconds(choice),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    this.below,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.paperSunken,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, size: 18, color: AppTheme.inkSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.displayBase),
                    const SizedBox(height: 4),
                    Text(description, style: AppTheme.caption),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (below != null) ...[const SizedBox(height: 14), below!],
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.ink : AppTheme.paper,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? AppTheme.ink : AppTheme.rule,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppTheme.inkInverted : AppTheme.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
