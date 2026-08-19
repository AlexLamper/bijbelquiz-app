import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/bible_chapter_repository.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_passage.dart';

/// The chapter a quiz is about, read before the first question.
///
/// The point of the "lees eerst" option: answering about Daniël 2 having just
/// read Daniël 2 turns a memory test into a reading exercise, which is what
/// most people opened a Bible quiz for. Set as one column with the verse
/// numbers in the margin - a page, not a list of items.
class QuizPassageScreen extends ConsumerWidget {
  const QuizPassageScreen({super.key, required this.idOrSlug});

  final String idOrSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(idOrSlug));
    final passage = quizAsync.asData?.value.passage;

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
        title: Text(passage?.label ?? 'Lees eerst', style: AppTheme.overline),
        centerTitle: true,
      ),
      body: passage == null
          ? const AppLoader()
          : _PassageBody(idOrSlug: idOrSlug, passage: passage),
    );
  }
}

class _PassageBody extends ConsumerWidget {
  const _PassageBody({required this.idOrSlug, required this.passage});

  final String idOrSlug;
  final QuizPassage passage;

  void _startQuiz(BuildContext context) {
    // Replaces rather than pushes: coming back out of a quiz should land on the
    // quiz overview, not drop the reader back into the chapter they just read.
    context.pushReplacement('/quiz/$idOrSlug/play');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(chapterVersesProvider(passage));

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: versesAsync.when(
              data: (verses) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                itemCount: verses.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Lees eerst'),
                          const SizedBox(height: 14),
                          Text(passage.label, style: AppTheme.displayLarge),
                          const SizedBox(height: 12),
                          Text(
                            'Neem dit hoofdstuk rustig door. De vragen hierna '
                            'gaan hierover, dus lezen helpt echt.',
                            style: AppTheme.bodyLead,
                          ),
                          const SizedBox(height: 20),
                          const RuleLine(),
                        ],
                      ),
                    );
                  }

                  if (index == verses.length + 1) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('STATENVERTALING', style: AppTheme.overline),
                    );
                  }

                  final verse = verses[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 26,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, right: 10),
                            child: Text(
                              '${verse.verse}',
                              textAlign: TextAlign.right,
                              style: AppTheme.caption.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            verse.text,
                            style: const TextStyle(
                              fontFamily: AppTheme.displayFontName,
                              fontSize: 17,
                              height: 1.7,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const AppLoader(),
              // A chapter that will not load must never block the quiz.
              error: (error, _) => AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Hoofdstuk niet geladen',
                description:
                    'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.',
                action: SiteOutlineButton(
                  label: 'Opnieuw proberen',
                  expand: false,
                  height: 44,
                  onPressed: () => ref.invalidate(chapterVersesProvider(passage)),
                ),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: SiteButton(
              label: 'Start de quiz',
              trailingIcon: Icons.arrow_forward,
              onPressed: () => _startQuiz(context),
            ),
          ),
        ],
      ),
    );
  }
}
