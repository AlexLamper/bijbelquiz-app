import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../../core/ui/bq.dart';
import '../../data/bible_verse_repository.dart';
import '../../domain/question.dart';
import 'player_widgets.dart';

enum AnswerOutcome { correct, wrong, timedOut }

/// The white sheet docked under an answered question: verdict, explanation,
/// the verse one tap away, and "Volgende vraag".
///
/// The written uitleg is Premium (free players get a faded teaser and the
/// ask); looking up the verse is free for everyone, as on the website.
class AnswerFeedbackSheet extends ConsumerStatefulWidget {
  const AnswerFeedbackSheet({
    super.key,
    required this.question,
    required this.outcome,
    required this.isPremium,
    required this.isLastQuestion,
    required this.onNext,
  });

  final Question question;
  final AnswerOutcome outcome;
  final bool isPremium;
  final bool isLastQuestion;
  final VoidCallback onNext;

  @override
  ConsumerState<AnswerFeedbackSheet> createState() =>
      _AnswerFeedbackSheetState();
}

class _AnswerFeedbackSheetState extends ConsumerState<AnswerFeedbackSheet> {
  /// Collapsed by default: a reader who knows the passage should not have to
  /// get past it to reach the next question, and the lookup is a network call
  /// that only pays for itself when somebody actually wants to read.
  bool _verseExpanded = false;

  bool get _gotItRight => widget.outcome == AnswerOutcome.correct;

  void _openExplanationPaywall() {
    ref
        .read(analyticsProvider)
        .track(
          AnalyticsEvents.paywallShown,
          props: {
            'trigger': PaywallTrigger.explanationLocked,
            'surface': 'quiz_explanation',
            'afterWrongAnswer': !_gotItRight,
          },
        );
    context.push('/premium?reden=explanation_locked');
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final hasExplanation = question.explanation.trim().isNotEmpty;
    final reference = question.bibleReference.trim();
    final hasReference = reference.isNotEmpty && reference != '-';
    final media = MediaQuery.of(context);

    final details = <Widget>[
      if (hasExplanation) ...[
        const SizedBox(height: 12),
        if (widget.isPremium)
          Text(question.explanation.trim(), style: _explanationStyle)
        else
          _FadedTeaser(text: teaseExplanation(question.explanation)),
      ],
      if (hasReference || (!widget.isPremium && hasExplanation)) ...[
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          children: [
            if (hasReference)
              PlayerChip(
                label: _verseExpanded ? 'Verberg tekst' : 'Lees $reference',
                semanticLabel: _verseExpanded
                    ? 'Verberg de tekst van $reference'
                    : 'Lees $reference',
                icon: PlayerIcons.book,
                onTap: () => setState(() => _verseExpanded = !_verseExpanded),
              ),
            if (!widget.isPremium && hasExplanation)
              PlayerChip(
                // A player who just got it wrong wants to know why more than
                // at any other moment, so the ask names that instead of the
                // product.
                label: _gotItRight
                    ? 'Ontgrendel Premium voor uitleg'
                    : 'Lees waarom dit fout was',
                icon: BqIcons.lock,
                background: AppTheme.goldTint,
                foreground: AppTheme.goldText,
                onTap: _openExplanationPaywall,
              ),
          ],
        ),
      ],
      if (hasReference && _verseExpanded) ...[
        const SizedBox(height: 2),
        _VerseText(reference: reference),
      ],
    ];

    return Semantics(
      container: true,
      liveRegion: true,
      label: switch (widget.outcome) {
        AnswerOutcome.correct => 'Goed antwoord',
        AnswerOutcome.wrong => 'Fout antwoord',
        AnswerOutcome.timedOut => 'Tijd om',
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: media.size.height * 0.62),
        decoration: const BoxDecoration(
          color: AppTheme.paperRaised,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.rule)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F1B1A18),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 22 + media.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Verdict(outcome: widget.outcome),
            if (details.isNotEmpty)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details,
                  ),
                ),
              ),
            SizedBox(height: details.isEmpty ? 14 : 5),
            BqButton(
              label: widget.isLastQuestion ? 'Rond quiz af' : 'Volgende vraag',
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _explanationStyle = TextStyle(
  fontFamily: AppTheme.sansFontName,
  fontSize: 15,
  fontWeight: FontWeight.w600,
  height: 22 / 15,
  color: AppTheme.inkSoft,
);

/// Round icon + "Goed!" / "Helaas" / "Tijd om".
class _Verdict extends StatelessWidget {
  const _Verdict({required this.outcome});

  final AnswerOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (String label, String icon, Color disc, Color text) = switch (
      outcome
    ) {
      AnswerOutcome.correct => (
        'Goed!',
        PlayerIcons.check,
        AppTheme.positive,
        AppTheme.positiveText,
      ),
      AnswerOutcome.wrong => (
        'Helaas',
        PlayerIcons.cross,
        AppTheme.coral,
        AppTheme.vermilion,
      ),
      AnswerOutcome.timedOut => (
        'Tijd om',
        BqIcons.clock,
        AppTheme.coral,
        AppTheme.vermilion,
      ),
    };

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: disc, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: BqIcon(icon, size: 18, color: AppTheme.inkInverted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: text,
            ),
          ),
        ),
      ],
    );
  }
}

/// The start of a locked explanation, fading out over three lines.
class _FadedTeaser extends StatelessWidget {
  const _FadedTeaser({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.black, Colors.black, Colors.transparent],
        stops: <double>[0.0, 0.68, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.clip,
        style: _explanationStyle,
      ),
    );
  }
}

/// Enough of a locked explanation to show there is one, never all of it.
String teaseExplanation(String explanation) {
  final normalized = explanation.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) {
    return '';
  }

  const maxChars = 90;
  if (normalized.length <= maxChars) {
    if (normalized.length <= 10) {
      return '${normalized.substring(0, 1)}...';
    }

    final cutIndex = (normalized.length * 0.4).round().clamp(
      10,
      normalized.length - 1,
    );
    return '${normalized.substring(0, cutIndex).trimRight()}...';
  }

  return '${normalized.substring(0, maxChars).trimRight()}...';
}

/// The looked-up verse, or a quiet line saying it could not be fetched.
///
/// A failed lookup is never an error state here: the reference itself is
/// already on the chip above, which is the part the reader came for.
class _VerseText extends ConsumerWidget {
  const _VerseText({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const failed = Text(
      'De tekst kon niet worden opgehaald.',
      style: AppTheme.caption,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.paperSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.rule),
      ),
      child: ref
          .watch(bibleVerseProvider(reference))
          .when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: AppLoader(size: 18)),
            ),
            error: (_, _) => failed,
            data: (verse) {
              if (verse == null) return failed;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '“${verse.text}”',
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 22 / 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${verse.reference} - Statenvertaling',
                    style: AppTheme.caption,
                  ),
                ],
              );
            },
          ),
    );
  }
}
