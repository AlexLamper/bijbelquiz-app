import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../profile/present/profile_provider.dart';
import '../data/quiz_repository.dart';
import '../domain/question.dart';
import '../domain/answer.dart';

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
                // Header Row (Close Button & Progress Text)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
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
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 48,
                      ), // Balances the Row to keep text perfectly centered
                    ],
                  ),
                ),

                // Progress Bar Track
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA), // Light grey track
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D2B), // Dark filled state
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Question Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    question.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Geist Mono',
                      fontSize: 21,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Options List
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          ...question.answers.map(
                            (answer) => _buildAnswerButton(answer),
                          ),
                          if (_isAnswered)
                            _buildExplanationAndNext(
                              question,
                              totalQuestions,
                              isPremium,
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
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

    // Default styling (Unanswered)
    Color backgroundColor = const Color(
      0xFFF4F4F6,
    ); // Subtle light grey background
    Color textColor = Colors.black;
    Border? border;

    // Styling after an answer is selected
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _handleOptionSelected(answer),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer.text,
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.3),
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

  Widget _buildExplanationAndNext(
    Question question,
    int totalQuestions,
    bool isPremium,
  ) {
    final bool isLastQuestion = _currentIndex == totalQuestions - 1;
    final bool gotItRight = _selectedAnswer?.isCorrect ?? false;
    final teasedExplanation = _teaseExplanation(question.explanation);
    final teasedReference = _teaseReference(question.bibleReference);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        // Unified Card Design
        Container(
          decoration: BoxDecoration(
            color: gotItRight
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gotItRight
                    ? const Color(0xFF4CAF50).withOpacity(0.12)
                    : const Color(0xFFE53935).withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: gotItRight
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : const Color(0xFFE53935).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Background gradient accent
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gotItRight
                          ? const Color(0xFF4CAF50).withOpacity(0.08)
                          : const Color(0xFFE53935).withOpacity(0.08),
                      gotItRight
                          ? const Color(0xFF4CAF50).withOpacity(0.02)
                          : const Color(0xFFE53935).withOpacity(0.02),
                    ],
                  ),
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: gotItRight
                                ? const Color(0xFF4CAF50).withOpacity(0.15)
                                : const Color(0xFFE53935).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            gotItRight
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: gotItRight
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gotItRight
                                    ? 'Goed gedaan!'
                                    : 'Helaas, dat is niet juist.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: gotItRight
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFE53935),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gotItRight
                                    ? 'Uitstekend antwoord gegeven!'
                                    : 'Bekijk de uitleg hieronder',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Divider
                    const SizedBox(height: 20),
                    Container(height: 1, color: Colors.black.withOpacity(0.08)),
                    // Explanation and Reference Section
                    if (question.explanation.isNotEmpty ||
                        (question.bibleReference.isNotEmpty &&
                            question.bibleReference != '-')) ...[
                      const SizedBox(height: 20),
                      if (isPremium) ...[
                        // Premium Content
                        if (question.explanation.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uitleg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF131D2B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                question.explanation,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        if (question.bibleReference.isNotEmpty &&
                            question.bibleReference != '-') ...[
                          if (question.explanation.isNotEmpty)
                            const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bijbelreferentie',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF131D2B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF131D2B,
                                  ).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF131D2B,
                                    ).withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  question.bibleReference,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF131D2B),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        // Teaser + lock for non-premium users.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (question.explanation.isNotEmpty) ...[
                              const Text(
                                'Uitleg preview',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF131D2B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      color: const Color(0xFF131D2B).withOpacity(
                                        0.04,
                                      ),
                                      child: Text(
                                        teasedExplanation,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.15),
                                                Colors.white.withOpacity(0.88),
                                              ],
                                              stops: const [0.35, 0.62, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (question.bibleReference.isNotEmpty &&
                                question.bibleReference != '-') ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131D2B).withOpacity(
                                    0.06,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      size: 16,
                                      color: Color(0xFF131D2B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Referentie preview: $teasedReference',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF131D2B),
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock_rounded,
                                      color: Color(0xFF131D2B),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Volledige Uitleg = Premium',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF131D2B),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ontgrendel alle uitleg en complete bijbelreferenties na elke vraag.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.65),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.push('/premium');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF131D2B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Ontgrendel Premium',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => _nextQuestion(totalQuestions),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF131D2B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isLastQuestion ? 'Rond Quiz Af' : 'Volgende Vraag',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _teaseExplanation(String explanation) {
    final normalized = explanation.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return '';
    }

    const maxChars = 160;
    if (normalized.length <= maxChars) {
      if (normalized.length <= 8) {
        return '${normalized.substring(0, 1)}...';
      }

      final cutIndex =
          (normalized.length * 0.6).round().clamp(8, normalized.length - 1)
              as int;
      return '${normalized.substring(0, cutIndex).trimRight()}...';
    }

    return '${normalized.substring(0, maxChars).trimRight()}...';
  }

  String _teaseReference(String reference) {
    final trimmed = reference.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return '';
    }

    final colonIndex = trimmed.indexOf(':');
    if (colonIndex > 0) {
      return '${trimmed.substring(0, colonIndex)}:...';
    }

    if (trimmed.length <= 6) {
      return '${trimmed.substring(0, 1)}...';
    }

    return '${trimmed.substring(0, 6)}...';
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
                fontFamily: 'Geist Mono',
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
                  backgroundColor: const Color(0xFF131D2B),
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
