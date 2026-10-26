import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../data/bible_chapter_repository.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_passage.dart';

/// The chapter a quiz is about, read before the first question.
///
/// The point of the "lees eerst" option: answering about Daniël 2 having just
/// read Daniël 2 turns a memory test into a reading exercise, which is what
/// most people opened a Bible quiz for. Full-screen running text with the
/// verse numbers inline, one verse per line - and the way on pinned
/// to the bottom.
class QuizPassageScreen extends ConsumerWidget {
  const QuizPassageScreen({super.key, required this.idOrSlug});

  final String idOrSlug;

  void _startQuiz(BuildContext context) {
    // Replaces rather than pushes: coming back out of a quiz should land on the
    // quiz overview, not drop the reader back into the chapter they just read.
    context.pushReplacement('/quiz/$idOrSlug/play');
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz/$idOrSlug');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));
    final quiz = quizAsync.asData?.value;
    final passage = quiz?.passage;

    final Widget body = quizAsync.when(
      data: (quiz) => quiz.passage == null
          // Quizzes spanning several books have no single chapter. Never a
          // dead end: the quiz can still be started below.
          ? const AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Geen hoofdstuk om te lezen',
              description:
                  'Deze quiz gaat over meer dan een hoofdstuk. Je kunt gewoon met de quiz beginnen.',
            )
          : _PassageText(passage: quiz.passage!),
      loading: () => const AppLoader(),
      error: (err, _) => AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Hoofdstuk niet geladen',
        description:
            'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.',
        action: BqButton(
          label: 'Opnieuw proberen',
          style: BqButtonStyle.secondary,
          height: 44,
          expand: false,
          onPressed: () => ref.invalidate(quizDetailProvider(idOrSlug)),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    // 18 rather than 20: the 44px tap area around the 40px
                    // circle, so the circle itself lines up with the text.
                    padding: const EdgeInsets.fromLTRB(18, 18, 20, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: BqCircleButton(
                              icon: BqIcons.chevronLeft,
                              label: 'Terug',
                              onTap: () => _back(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                passage?.label ?? 'Lees eerst',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTheme.sansFontName,
                                  fontSize: 17,
                                  height: 22 / 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                ),
                              ),
                              if (quiz != null)
                                Text(
                                  'Lees voor de quiz ${quiz.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.sansFontName,
                                    fontSize: 13,
                                    height: 18 / 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.inkMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: body),
                ],
              ),
            ),
          ),

          // Sticky action: a chapter is long, and the way on should never be
          // something you have to scroll to find.
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.paperRaised,
              border: Border(top: BorderSide(color: AppTheme.rule)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BqButton(
                  label: 'Start de quiz',
                  onPressed: () => _startQuiz(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassageText extends ConsumerWidget {
  const _PassageText({required this.passage});

  final QuizPassage passage;

  static const TextStyle _textStyle = TextStyle(
    fontFamily: AppTheme.sansFontName,
    fontSize: 16,
    height: 25 / 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.ink,
  );

  static const TextStyle _numberStyle = TextStyle(
    fontFamily: AppTheme.sansFontName,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
    color: AppTheme.lapis,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(chapterVersesProvider(passage));

    return versesAsync.when(
      data: (verses) {
        if (verses.isEmpty) {
          return const AppEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Hoofdstuk niet geladen',
            description:
                'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.',
          );
        }
        // One verse per line, each starting at the left edge.
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: verses.length + 1,
          itemBuilder: (context, index) {
            if (index == verses.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Statenvertaling',
                  style: AppTheme.caption.copyWith(color: AppTheme.inkFaint),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Verse(verse: verses[index]),
            );
          },
        );
      },
      loading: () => const AppLoader(),
      // A chapter that will not load must never block the quiz.
      error: (error, _) => AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Hoofdstuk niet geladen',
        description:
            'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.',
        action: BqButton(
          label: 'Opnieuw proberen',
          style: BqButtonStyle.secondary,
          height: 44,
          expand: false,
          onPressed: () => ref.invalidate(chapterVersesProvider(passage)),
        ),
      ),
    );
  }
}

class _Verse extends StatelessWidget {
  const _Verse({required this.verse});

  final ChapterVerse verse;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${verse.verse} ${verse.text}',
      excludeSemantics: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            style: _PassageText._textStyle,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.translate(
                  offset: const Offset(0, -3),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Text(
                      '${verse.verse}',
                      style: _PassageText._numberStyle,
                    ),
                  ),
                ),
              ),
              // U+2060 (word joiner) keeps the verse number on the same line
              // as the first word of its verse.
              TextSpan(text: '\u2060${verse.text.trim()}'),
            ],
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
