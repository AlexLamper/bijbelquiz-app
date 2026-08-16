import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/notifications/streak_reminder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/data/profile_model.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_repository.dart';
import '../domain/answer.dart';
import '../domain/question.dart';
import '../domain/quiz.dart';

class QuizPlayerScreen extends ConsumerStatefulWidget {
  final String idOrSlug;

  const QuizPlayerScreen({super.key, required this.idOrSlug});

  @override
  ConsumerState<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends ConsumerState<QuizPlayerScreen> {
  int _currentIndex = 0;
  Answer? _selectedAnswer;
  bool _isAnswered = false;
  int _correctCount = 0;

  /// Which option index was picked per question index, so the server can
  /// re-grade the attempt instead of trusting a client-side tally.
  final Map<int, int> _selectedIndexes = <int, int>{};

  /// XP the server actually awarded, once the attempt has been reported.
  int? _awardedXp;

  /// True once the server has answered, whatever the awarded amount was.
  bool _resultConfirmed = false;
  bool _resultSubmitted = false;

  void _handleOptionSelected(Answer answer, int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _selectedIndexes[_currentIndex] = index;
      if (answer.isCorrect) _correctCount++;
    });
  }

  void _nextQuestion(Quiz quiz) {
    final totalQuestions = quiz.questions.length;
    setState(() {
      if (_currentIndex < totalQuestions - 1) {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      } else {
        _currentIndex++;
      }
    });

    if (_currentIndex >= totalQuestions) {
      _submitResult(quiz);
    }
  }

  Future<void> _submitResult(Quiz quiz) async {
    if (_resultSubmitted) return;
    _resultSubmitted = true;

    final totalQuestions = quiz.questions.length;
    final answers = List<int?>.generate(
      totalQuestions,
      (index) => _selectedIndexes[index],
    );

    final result = await ref
        .read(quizRepositoryProvider)
        .submitQuizResult(
          quizId: quiz.id,
          correctAnswers: _correctCount,
          totalQuestions: totalQuestions,
          selectedAnswerIndexes: answers,
        );

    if (!mounted) return;
    setState(() {
      _awardedXp = result?.xpEarned;
      _resultConfirmed = result != null;
    });

    // The profile header, streak and badges all move on a finished quiz.
    ref.invalidate(profileProvider);

    await _handleStreakReminder();
  }

  /// The one place the streak reminder is offered.
  ///
  /// After a finished quiz, not on launch: the permission prompt then lands on
  /// somebody who has used the app, and the streak it protects actually
  /// exists. Asked once ever, and only from a streak of two, because a player
  /// on day one has nothing to lose tonight.
  Future<void> _handleStreakReminder() async {
    final ProfileModel profile;
    try {
      // The refreshed profile, so the streak read here is the one the quiz
      // just changed rather than the pre-submit value.
      profile = await ref.read(profileProvider.future);
    } catch (_) {
      // A profile that will not load is not worth a prompt about.
      return;
    }

    if (!mounted) return;

    final reminder = StreakReminder.instance;

    if (await reminder.isEnabled()) {
      await reminder.sync(
        streak: profile.streak,
        lastPlayedAt: profile.lastPlayedAt,
      );
      return;
    }

    if (profile.streak < 2 || await reminder.hasBeenOffered() || !mounted) {
      return;
    }

    await reminder.markOffered();
    if (!mounted) return;

    final wantsIt = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.paperRaised,
        title: const Text('Je reeks vasthouden?'),
        content: Text(
          'Je hebt ${profile.streak} dagen op rij gespeeld. Zullen we je om '
          '19:00 een seintje geven op een dag dat je nog niet gespeeld hebt?',
          style: AppTheme.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Nee, bedankt'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ja, graag'),
          ),
        ],
      ),
    );

    if (wantsIt != true) return;

    await reminder.setEnabled(
      true,
      streak: profile.streak,
      lastPlayedAt: profile.lastPlayedAt,
    );
    ref.invalidate(streakReminderEnabledProvider);
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizDetailProvider(widget.idOrSlug));
    final profileAsync = ref.watch(profileProvider);
    final isPremium = profileAsync.maybeWhen(
      data: (profile) => profile.isPremium,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: quizAsync.when(
          data: (quiz) {
            if (quiz.questions.isEmpty) {
              return _buildEmptyState();
            }

            if (_currentIndex >= quiz.questions.length) {
              return _buildFinishedScreen(quiz);
            }

            final question = quiz.questions[_currentIndex];
            final totalQuestions = quiz.questions.length;
            final progress = (_currentIndex + 1) / totalQuestions;

            return Column(
              children: [
                // Header rail - close button + `text-[10px] uppercase
                // tracking-[0.16em]` counter.
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.inkSoft,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'VRAAG ${_currentIndex + 1} / $totalQuestions',
                          style: AppTheme.overline.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Hairline progress track - the site keeps bars at 2px.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: AppTheme.rule,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(color: AppTheme.ink),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question.text,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFontName,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        height: 1.22,
                        letterSpacing: -0.36,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < question.answers.length; i++)
                            _buildAnswerButton(question.answers[i], i),
                          if (_isAnswered)
                            _buildExplanationCard(question, isPremium),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isAnswered)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.paperRaised,
                      border: Border(top: BorderSide(color: AppTheme.rule)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: SafeArea(
                      top: false,
                      child: _buildNextQuestionButton(quiz),
                    ),
                  ),
              ],
            );
          },
          loading: () => const AppLoader(),
          error: (e, st) => _buildErrorState(e.toString()),
        ),
      ),
    );
  }

  /// Answer option.
  ///
  /// Idle     : `rounded-md border border-rule bg-paper-raised text-ink`
  /// Correct  : `border-positive/35 bg-positive-tint text-positive`
  /// Incorrect: `border-destructive/35 bg-vermilion-tint text-destructive`
  Widget _buildAnswerButton(Answer answer, int index) {
    final bool isSelected = _selectedAnswer == answer;

    Color background = AppTheme.paperRaised;
    Color borderColor = AppTheme.rule;
    Color textColor = AppTheme.ink;
    Color markerColor = AppTheme.inkMuted;

    if (_isAnswered) {
      if (answer.isCorrect) {
        background = AppTheme.positiveTint;
        borderColor = AppTheme.positive.withValues(alpha: 0.35);
        textColor = AppTheme.positive;
        markerColor = AppTheme.positive;
      } else if (isSelected) {
        background = AppTheme.vermilionTint;
        borderColor = AppTheme.destructive.withValues(alpha: 0.35);
        textColor = AppTheme.destructive;
        markerColor = AppTheme.destructive;
      } else {
        background = AppTheme.paperRaised;
        textColor = AppTheme.inkMuted;
        markerColor = AppTheme.ruleStrong;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: () => _handleOptionSelected(answer, index),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          splashColor: AppTheme.paperSunken,
          highlightColor: AppTheme.paperSunken,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Serif letter marker, like the site's `01`/`02` list markers.
                SizedBox(
                  width: 22,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontFamily: AppTheme.displayFontName,
                      fontSize: 15,
                      color: markerColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    answer.text,
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      height: 1.45,
                      color: textColor,
                    ),
                  ),
                ),
                if (_isAnswered && answer.isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.positive,
                    ),
                  ),
                if (_isAnswered && isSelected && !answer.isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.destructive,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(Question question, bool isPremium) {
    final bool gotItRight = _selectedAnswer?.isCorrect ?? false;
    final bool hasExplanation = question.explanation.isNotEmpty;
    final bool hasReference =
        question.bibleReference.isNotEmpty && question.bibleReference != '-';
    final teasedExplanation = _teaseExplanation(question.explanation);
    final teasedReference = _teaseReference(question.bibleReference);

    final accent = gotItRight ? AppTheme.positive : AppTheme.destructive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(
                gotItRight ? 'Goed gedaan' : 'Onjuist',
                color: accent,
                ruleColor: accent,
              ),
              if (hasExplanation) ...[
                const SizedBox(height: 18),
                const RuleLine(),
                const SizedBox(height: 18),
                const Text('UITLEG', style: AppTheme.overline),
                const SizedBox(height: 8),
                if (isPremium)
                  Text(question.explanation, style: AppTheme.bodyMuted)
                else
                  _buildFadedPreviewText(
                    teasedExplanation,
                    maxLines: 3,
                    style: AppTheme.bodyMuted,
                  ),
              ],
              if (hasReference) ...[
                const SizedBox(height: 18),
                const RuleLine(),
                const SizedBox(height: 18),
                const Text('REFERENTIE', style: AppTheme.overline),
                const SizedBox(height: 8),
                if (isPremium)
                  Text(
                    question.bibleReference,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFontName,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  )
                else
                  _buildFadedPreviewText(
                    teasedReference,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFontName,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
              ],
              if (!isPremium && (hasExplanation || hasReference)) ...[
                const SizedBox(height: 18),
                SiteOutlineButton(
                  // A player who just got it wrong wants to know why more than
                  // at any other moment, so the ask names that instead of the
                  // product.
                  label: gotItRight
                      ? 'Ontgrendel Premium voor uitleg'
                      : 'Lees waarom dit fout was',
                  height: 40,
                  onPressed: () {
                    ref
                        .read(analyticsProvider)
                        .track(
                          AnalyticsEvents.paywallShown,
                          props: {
                            'trigger': PaywallTrigger.explanationLocked,
                            'surface': 'quiz_explanation',
                            'afterWrongAnswer': !gotItRight,
                          },
                        );
                    context.push('/premium?reden=explanation_locked');
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextQuestionButton(Quiz quiz) {
    final bool isLastQuestion = _currentIndex == quiz.questions.length - 1;

    return SiteButton(
      label: isLastQuestion ? 'Rond quiz af' : 'Volgende vraag',
      trailingIcon: Icons.arrow_forward,
      onPressed: () => _nextQuestion(quiz),
    );
  }

  Widget _buildFadedPreviewText(
    String text, {
    required TextStyle style,
    required int maxLines,
  }) {
    final gradient = maxLines == 1
        ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Colors.black, Colors.black, Colors.transparent],
            stops: <double>[0.0, 0.78, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.black, Colors.black, Colors.transparent],
            stops: <double>[0.0, 0.68, 1.0],
          );

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
        style: style,
      ),
    );
  }

  String _teaseExplanation(String explanation) {
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

  String _teaseReference(String reference) {
    final normalized = reference.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return '';
    }

    const maxChars = 26;
    if (normalized.length <= maxChars) {
      if (normalized.length <= 6) {
        return '${normalized.substring(0, 1)}...';
      }

      final cutIndex = (normalized.length * 0.6).round().clamp(
        6,
        normalized.length - 1,
      );
      return '${normalized.substring(0, cutIndex).trimRight()}...';
    }

    return '${normalized.substring(0, maxChars).trimRight()}...';
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Nog geen vragen',
      description: 'Deze quiz heeft nog geen vragen.',
      action: SiteOutlineButton(
        label: 'Ga terug',
        expand: false,
        height: 44,
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Er ging iets mis',
      description: error,
      action: SiteOutlineButton(
        label: 'Ga terug',
        expand: false,
        height: 44,
        onPressed: () => context.pop(),
      ),
    );
  }

  /// Result page, in the site's centred CTA-section layout:
  /// eyebrow -> `font-display text-[26px]` -> lead -> rule-divided stats.
  Widget _buildFinishedScreen(Quiz quiz) {
    final totalQuestions = quiz.questions.length;
    // Only the server awards XP, and a replay that beats no earlier attempt
    // awards none. Estimating here would promise XP the account never gets.
    final earnedXp = _awardedXp;
    final percentage = totalQuestions == 0
        ? 0
        : (_correctCount * 100 / totalQuestions).round();

    final xpSentence = _resultConfirmed
        ? (earnedXp == null || earnedXp == 0
              ? 'Je verdiende deze keer geen extra XP - een herhaling telt '
                    'alleen mee als je jezelf verbetert.'
              : 'Je verdiende $earnedXp XP.')
        : 'Je resultaat wordt opgeslagen zodra je weer verbinding hebt.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Eyebrow('Afgerond')),
            const SizedBox(height: 20),
            const Text(
              'Quiz voltooid',
              textAlign: TextAlign.center,
              style: AppTheme.displayMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Je had $_correctCount van de $totalQuestions vragen goed. '
              '$xpSentence Ga door om je reeks in stand te houden en verder '
              'te stijgen op de ranglijst.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyLead,
            ),
            const SizedBox(height: 32),
            StatStrip(
              stacked: true,
              items: [
                StatItem(
                  value: '$_correctCount/$totalQuestions',
                  label: 'Goed',
                ),
                StatItem(value: '$percentage%', label: 'Score'),
                StatItem(
                  value: earnedXp == null ? '-' : '$earnedXp',
                  label: 'XP',
                  ruleColor: AppTheme.positive,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SiteButton(
              label: 'Terug naar home',
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: 12),
            SiteOutlineButton(
              label: 'Bekijk ranglijst',
              onPressed: () => context.go('/leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
