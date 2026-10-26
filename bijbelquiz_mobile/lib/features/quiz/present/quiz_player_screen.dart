import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/notifications/streak_reminder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../profile/data/profile_model.dart';
import '../../profile/present/profile_provider.dart';
import '../../settings/data/quiz_preferences_controller.dart';
import '../data/pending_attempt_store.dart';
import '../data/quiz_repository.dart';
import '../domain/answer.dart';
import '../domain/quiz.dart';
import '../domain/quiz_submission_result.dart';
import 'player/answer_feedback_sheet.dart';
import 'player/answer_grid.dart';
import 'player/question_view.dart';
import 'player/quiz_result_view.dart';

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

  /// Set once we have bounced a non-premium player off a premium quiz, so the
  /// redirect fires exactly once even though `build` runs many times.
  bool _paywallRedirected = false;

  /// Which option index was picked per question index, so the server can
  /// re-grade the attempt instead of trusting a client-side tally.
  final Map<int, int> _selectedIndexes = <int, int>{};

  /// What the server made of the attempt, once it has answered.
  QuizSubmissionResult? _result;

  /// The attempt is on its way to the server.
  bool _submitting = false;

  /// The server could not be reached or sent nothing usable; the result page
  /// offers to try again.
  bool _submitFailed = false;
  bool _resultSubmitted = false;

  /// Whether this account had finished the quiz before, read from the profile
  /// before the submission refreshes it. A replay only earns XP by beating the
  /// earlier best, so a replay that earns XP is a new best score.
  bool? _playedBefore;
  bool _isNewBest = false;

  /// Played signed out: the attempt is parked on the device rather than
  /// reported, and the result screen offers an account to keep it.
  bool _parkedForAccount = false;

  /// After reading an explanation the reader may have scrolled; without a
  /// reset the next question would open halfway down itself.
  final ScrollController _scrollController = ScrollController();

  // ── Per-question timer ──────────────────────────────────────────────────
  // Off unless the reader switched it on from the quiz overview. Shown as one
  // small pill in the question card: a Bible quiz should not feel like an
  // exam unless somebody asked for that.
  Timer? _ticker;
  int _secondsLeft = 0;
  int _timerSeconds = 0;
  bool _timedOut = false;

  void _syncTimer(int seconds) {
    if (_timerSeconds == seconds) return;
    _timerSeconds = seconds;
    _restartTimer();
  }

  void _restartTimer() {
    _ticker?.cancel();
    _timedOut = false;
    _secondsLeft = _timerSeconds;

    if (_timerSeconds <= 0 || _isAnswered) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
          return;
        }

        // Running out locks the question in as unanswered rather than skipping
        // it: the correct answer and its explanation still appear, which is the
        // whole point of getting one wrong.
        _secondsLeft = 0;
        _timedOut = true;
        _isAnswered = true;
        _selectedAnswer = null;
        timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(0);
  }

  /// "1:05" / "0:24" - minutes only appear once there are any.
  String _formatSeconds(int total) {
    final safe = total < 0 ? 0 : total;
    final minutes = safe ~/ 60;
    final seconds = safe % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleOptionSelected(Answer answer, int index) {
    if (_isAnswered) return;

    // The clock stops the moment the question is answered: what follows is the
    // explanation, and that is the part worth lingering on.
    _ticker?.cancel();

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
        _submitting = true;
      }
    });

    if (_currentIndex < totalQuestions) {
      _scrollToTop();
      _restartTimer();
    } else {
      _ticker?.cancel();
    }

    if (_currentIndex >= totalQuestions) {
      _submitResult(quiz);
    }
  }

  void _retrySubmit(Quiz quiz) {
    if (_submitting) return;
    _resultSubmitted = false;
    _submitResult(quiz);
  }

  Future<void> _submitResult(Quiz quiz) async {
    if (_resultSubmitted) return;
    _resultSubmitted = true;

    if (mounted) {
      setState(() {
        _submitting = true;
        _submitFailed = false;
      });
    }

    final totalQuestions = quiz.questions.length;
    final answers = List<int?>.generate(
      totalQuestions,
      (index) => _selectedIndexes[index],
    );

    // Without an account the attempt is parked on this device. The result
    // screen offers to keep it, and `PendingAttemptClaimer` writes it to
    // whichever account signs in next, from wherever that happens.
    final hasSession = await ref.read(hasSessionProvider.future);
    if (!hasSession) {
      await ref
          .read(pendingAttemptStoreProvider)
          .add(
            PendingAttempt(
              quizId: quiz.id,
              quizTitle: quiz.title,
              correctAnswers: _correctCount,
              totalQuestions: totalQuestions,
              selectedAnswerIndexes: answers,
              completedAt: DateTime.now(),
            ),
          );
      ref.invalidate(pendingAttemptsProvider);

      if (!mounted) return;
      setState(() {
        _parkedForAccount = true;
        _submitting = false;
      });
      return;
    }

    // Read before the refresh below replaces it with the post-quiz profile.
    _playedBefore ??=
        ref
            .read(profileProvider)
            .asData
            ?.value
            .playedQuizIds
            .contains(quiz.id) ??
        false;

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
      _submitting = false;
      _result = result;
      _submitFailed = result == null;
      _isNewBest =
          result != null && _playedBefore == true && result.xpEarned > 0;
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
    final preferences = ref.watch(quizPreferencesProvider);
    final profileAsync = ref.watch(profileProvider);
    final isPremium = profileAsync.maybeWhen(
      data: (profile) => profile.isPremium,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: quizAsync.when(
        data: (quiz) {
          // Hard gate: a premium quiz reached by deep link, the library, or
          // the multiplayer picker must not simply play. Bounce to the
          // paywall the same way the website redirects.
          if (quiz.isPremium && !isPremium) {
            if (!_paywallRedirected) {
              _paywallRedirected = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref
                    .read(analyticsProvider)
                    .track(
                      AnalyticsEvents.paywallShown,
                      props: {
                        'trigger': PaywallTrigger.premiumQuizLocked,
                        'surface': 'quiz_player',
                      },
                    );
                context.pushReplacement(
                  '/premium?reden=${PaywallTrigger.premiumQuizLocked}',
                );
              });
            }
            return const SafeArea(child: AppLoader());
          }

          if (quiz.questions.isEmpty) {
            return SafeArea(child: _buildEmptyState());
          }

          if (_currentIndex >= quiz.questions.length) {
            return SafeArea(
              child: QuizResultView(
                quiz: quiz,
                correctCount: _correctCount,
                picks: _selectedIndexes,
                parkedForAccount: _parkedForAccount,
                submitting: _submitting,
                submitFailed: _submitFailed,
                result: _result,
                isNewBest: _isNewBest,
                onRetrySubmit: () => _retrySubmit(quiz),
              ),
            );
          }

          // Adopting during build rather than in initState: the preference
          // arrives from the account a beat after the first frame, and
          // starting a clock the reader switched off would be worse than
          // starting one a moment late.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _syncTimer(preferences.questionTimerSeconds);
          });

          return _buildQuestion(quiz, isPremium);
        },
        loading: () => const SafeArea(child: AppLoader()),
        error: (e, st) => SafeArea(child: _buildErrorState(e.toString())),
      ),
    );
  }

  Widget _buildQuestion(Quiz quiz, bool isPremium) {
    final question = quiz.questions[_currentIndex];
    final totalQuestions = quiz.questions.length;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // The chapter the quiz is about ("Johannes 6"), else its category.
    final passageLabel = quiz.passage?.label.trim() ?? '';
    final categoryName = quiz.category?.name.trim() ?? '';
    final chipLabel = passageLabel.isNotEmpty
        ? passageLabel
        : (categoryName.isNotEmpty ? categoryName : null);

    final urgent = _timedOut || (_timerSeconds > 0 && _secondsLeft <= 5);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: PlayerHeader(
              current: _currentIndex + 1,
              total: totalQuestions,
              onClose: () => context.pop(),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              20 + (_isAnswered ? 0 : bottomInset),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuestionCard(
                  text: question.text,
                  chipLabel: chipLabel,
                  timer: _timerSeconds > 0
                      ? QuestionTimerPill(
                          label: _timedOut
                              ? 'Tijd om'
                              : _formatSeconds(_secondsLeft),
                          secondsLeft: _secondsLeft,
                          urgent: urgent,
                          timedOut: _timedOut,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                AnswerGrid(
                  answers: question.answers,
                  isAnswered: _isAnswered,
                  selected: _selectedAnswer,
                  onSelect: _handleOptionSelected,
                ),
              ],
            ),
          ),
        ),
        if (_isAnswered)
          TweenAnimationBuilder<double>(
            key: ValueKey<int>(_currentIndex),
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => FractionalTranslation(
              translation: Offset(0, 1 - t),
              child: child,
            ),
            child: AnswerFeedbackSheet(
              key: ValueKey<String>('feedback-$_currentIndex'),
              question: question,
              outcome: _timedOut
                  ? AnswerOutcome.timedOut
                  : ((_selectedAnswer?.isCorrect ?? false)
                        ? AnswerOutcome.correct
                        : AnswerOutcome.wrong),
              isPremium: isPremium,
              isLastQuestion: _currentIndex == totalQuestions - 1,
              onNext: () => _nextQuestion(quiz),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.menu_book_outlined,
      title: 'Nog geen vragen',
      description: 'Deze quiz heeft nog geen vragen.',
      action: BqButton(
        label: 'Ga terug',
        style: BqButtonStyle.tint,
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
      action: BqButton(
        label: 'Ga terug',
        style: BqButtonStyle.tint,
        expand: false,
        height: 44,
        onPressed: () => context.pop(),
      ),
    );
  }
}
