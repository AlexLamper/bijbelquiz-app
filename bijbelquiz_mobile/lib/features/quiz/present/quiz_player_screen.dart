import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_repository.dart';
import '../domain/answer.dart';
import '../domain/question.dart';

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

  void _handleOptionSelected(Answer answer) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });
  }

  void _nextQuestion(int totalQuestions) {
    setState(() {
      if (_currentIndex < totalQuestions - 1) {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      } else {
        _currentIndex++;
      }
    });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: quizAsync.when(
          data: (quiz) {
            if (quiz.questions.isEmpty) {
              return _buildEmptyState();
            }

            if (_currentIndex >= quiz.questions.length) {
              return _buildFinishedScreen(quiz.xpReward);
            }

            final question = quiz.questions[_currentIndex];
            final totalQuestions = quiz.questions.length;
            final progress = (_currentIndex + 1) / totalQuestions;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Vraag ${_currentIndex + 1}/$totalQuestions',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTheme.sansFontName,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D2B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    question.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.15,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...question.answers.map(_buildAnswerButton),
                          if (_isAnswered)
                            _buildExplanationCard(question, isPremium),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isAnswered)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: SafeArea(
                      top: false,
                      child: _buildNextQuestionButton(totalQuestions),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF131D2B)),
          ),
          error: (e, st) => _buildErrorState(e.toString()),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(Answer answer) {
    final bool isSelected = _selectedAnswer == answer;

    Color backgroundColor = const Color(0xFFF4F4F6);
    Color textColor = Colors.black;
    Border? border;

    if (_isAnswered) {
      if (answer.isCorrect) {
        backgroundColor = const Color(0xFFE8F5E9);
        border = Border.all(color: const Color(0xFF4CAF50), width: 2);
      } else if (isSelected && !answer.isCorrect) {
        backgroundColor = const Color(0xFFFFEBEE);
        border = Border.all(color: const Color(0xFFE53935), width: 2);
      } else {
        textColor = const Color(0xFFAAAAAA);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () => _handleOptionSelected(answer),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: border,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer.text,
                  style: TextStyle(fontSize: 15, color: textColor, height: 1.3),
                ),
              ),
              if (_isAnswered && answer.isCorrect)
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              if (_isAnswered && isSelected && !answer.isCorrect)
                const Icon(Icons.cancel, color: Color(0xFFE53935)),
            ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: gotItRight
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: gotItRight
                  ? const Color(0xFF4CAF50).withOpacity(0.35)
                  : const Color(0xFFE53935).withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      gotItRight
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: gotItRight
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gotItRight ? 'Goed gedaan!' : 'Niet juist.',
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: gotItRight
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasExplanation || hasReference) ...[
                  const SizedBox(height: 10),
                  Container(height: 1, color: Colors.black.withOpacity(0.08)),
                  const SizedBox(height: 10),
                ],
                if (hasExplanation) ...[
                  const Text(
                    'Uitleg',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF131D2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isPremium)
                    Text(
                      question.explanation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    )
                  else
                    _buildFadedPreviewText(
                      teasedExplanation,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                ],
                if (hasReference) ...[
                  if (hasExplanation) const SizedBox(height: 10),
                  const Text(
                    'Referentie',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF131D2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isPremium)
                    Text(
                      question.bibleReference,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF131D2B),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    _buildFadedPreviewText(
                      teasedReference,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF131D2B),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
                if (!isPremium && (hasExplanation || hasReference)) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/premium');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ontgrendel premium voor uitleg',
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextQuestionButton(int totalQuestions) {
    final bool isLastQuestion = _currentIndex == totalQuestions - 1;

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _nextQuestion(totalQuestions),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isLastQuestion ? 'Rond quiz af' : 'Volgende vraag',
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
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

      final cutIndex =
          (normalized.length * 0.4).round().clamp(10, normalized.length - 1)
              as int;
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

      final cutIndex =
          (normalized.length * 0.6).round().clamp(6, normalized.length - 1)
              as int;
      return '${normalized.substring(0, cutIndex).trimRight()}...';
    }

    return '${normalized.substring(0, maxChars).trimRight()}...';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_late, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Deze quiz heeft nog geen vragen.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Ga terug',
              style: TextStyle(color: Color(0xFF131D2B), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Er ging iets mis.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Ga terug',
                style: TextStyle(color: Color(0xFF131D2B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedScreen(int xpReward) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Color(0xFFFFC107),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Quiz Voltooid!',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF131D2B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Je hebt $xpReward XP verdiend!',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Terug naar Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
