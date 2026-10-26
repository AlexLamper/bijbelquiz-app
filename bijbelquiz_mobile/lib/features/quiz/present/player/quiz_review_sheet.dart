import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../../profile/present/profile_provider.dart';
import '../../domain/question.dart';
import '../../domain/quiz.dart';
import 'player_widgets.dart';

/// "Bekijk antwoorden": the post-quiz review in a tall sheet.
///
/// Premium: per question your answer, the correct one and the explanation.
/// Free: the same right/wrong list with the explanations faded behind one
/// Premium ask - a deliberate, late-in-the-loop paywall: the player just spent
/// five minutes and wants to know which ones they missed.
Future<void> showQuizReviewSheet(
  BuildContext context, {
  required Quiz quiz,
  required Map<int, int> picks,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _QuizReviewSheet(
        quiz: quiz,
        picks: picks,
        scrollController: scrollController,
      ),
    ),
  );
}

class _QuizReviewSheet extends ConsumerWidget {
  const _QuizReviewSheet({
    required this.quiz,
    required this.picks,
    required this.scrollController,
  });

  final Quiz quiz;

  /// Question index -> the answer index the player picked.
  final Map<int, int> picks;
  final ScrollController scrollController;

  void _unlock(BuildContext context, WidgetRef ref) {
    ref
        .read(analyticsProvider)
        .track(
          AnalyticsEvents.paywallShown,
          props: {
            'trigger': PaywallTrigger.reviewLocked,
            'surface': 'quiz_review',
          },
        );
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/premium-intro?reden=${PaywallTrigger.reviewLocked}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref
        .watch(profileProvider)
        .maybeWhen(data: (p) => p.isPremium, orElse: () => false);
    final questions = quiz.questions;

    var wrongCount = 0;
    for (var i = 0; i < questions.length; i++) {
      if (!_pickedCorrectly(questions[i], picks[i])) wrongCount++;
    }

    final rows = <Widget>[
      for (var i = 0; i < questions.length; i++)
        _ReviewRow(
          number: i + 1,
          question: questions[i],
          pickedIndex: picks[i],
          showExplanation: isPremium,
        ),
    ];

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.ruleStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text('Jouw antwoorden', style: AppTheme.displayLarge),
            ),
            PlayerCloseButton(
              label: 'Sluiten',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          wrongCount == 0
              ? 'Alles goed. Bekijk de uitleg bij elke vraag.'
              : '$wrongCount van de ${questions.length} vragen fout.',
          style: AppTheme.bodyMuted,
        ),
        const SizedBox(height: 16),
        BqListCard(children: rows),
        if (!isPremium) ...[
          const SizedBox(height: 16),
          BqCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'De volledige uitleg bij elke vraag is onderdeel van Premium.',
                  style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                ),
                const SizedBox(height: 12),
                BqButton(
                  label: 'Ontgrendel de volledige review',
                  icon: const BqIcon(BqIcons.lock, size: 18),
                  onPressed: () => _unlock(context, ref),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

bool _pickedCorrectly(Question question, int? picked) {
  return picked != null &&
      picked >= 0 &&
      picked < question.answers.length &&
      question.answers[picked].isCorrect;
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.number,
    required this.question,
    required this.pickedIndex,
    required this.showExplanation,
  });

  final int number;
  final Question question;
  final int? pickedIndex;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    final answers = question.answers;
    final picked =
        (pickedIndex != null &&
            pickedIndex! >= 0 &&
            pickedIndex! < answers.length)
        ? answers[pickedIndex!]
        : null;
    final wasCorrect = picked?.isCorrect ?? false;
    final correctAnswers = answers.where((a) => a.isCorrect);
    final correctAnswer = correctAnswers.isEmpty ? null : correctAnswers.first;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: wasCorrect ? 'Goed' : 'Fout',
            excludeSemantics: true,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: wasCorrect ? AppTheme.positive : AppTheme.coralTint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: BqIcon(
                wasCorrect ? PlayerIcons.check : PlayerIcons.cross,
                size: 14,
                color: wasCorrect ? AppTheme.inkInverted : AppTheme.vermilion,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number. ${question.text}', style: AppTheme.bodyStrong),
                const SizedBox(height: 6),
                Text(
                  'Jouw antwoord: ${picked?.text ?? 'geen'}',
                  style: AppTheme.caption.copyWith(
                    color: wasCorrect
                        ? AppTheme.positiveText
                        : AppTheme.vermilion,
                  ),
                ),
                if (!wasCorrect && correctAnswer != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Goed antwoord: ${correctAnswer.text}',
                    style: AppTheme.caption.copyWith(color: AppTheme.inkSoft),
                  ),
                ],
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  if (showExplanation)
                    Text(question.explanation, style: AppTheme.bodyMuted)
                  else
                    _BlurredLine(text: question.explanation),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A teaser of locked text - the first two lines, faded out.
class _BlurredLine extends StatelessWidget {
  const _BlurredLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.ink, Color(0x11000000)],
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.bodyMuted,
      ),
    );
  }
}
