import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/present/profile_provider.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';

class MultiplayerGameScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerGameScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen> {
  bool _handledRoomMissing = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      multiplayerSessionControllerProvider(widget.roomCode),
    );
    final room = sessionAsync.asData?.value.room;
    final roomMissing = _isRoomMissingError(sessionAsync.asData?.value.lastError);
    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.maybeWhen(
      data: (profile) => profile.id,
      orElse: () => '',
    );
    final isHost =
        room != null &&
        currentUserId.isNotEmpty &&
        currentUserId == room.hostUserId;

    ref.listen<AsyncValue<MultiplayerSessionState>>(
      multiplayerSessionControllerProvider(widget.roomCode),
      (previous, next) {
        final session = next.asData?.value;
        final room = session?.room;
        if (session == null || room == null || !mounted) return;

        if (_isRoomMissingError(session.lastError)) {
          if (_handledRoomMissing) return;
          _handledRoomMissing = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Deze kamer lijkt niet meer beschikbaar. Controleer de status of ga terug.',
              ),
            ),
          );
          return;
        }

        _handledRoomMissing = false;

        if (room.status == MultiplayerRoomStatus.finished) {
          context.go('/play-together/room/${room.code}/results');
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: _buildAppBarTitle(room),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        actions: [
          if (isHost && !roomMissing && room.status != MultiplayerRoomStatus.finished)
            IconButton(
              tooltip: 'Stop quiz',
              onPressed: _confirmAndStopMatch,
              icon: const Icon(
                Icons.stop_circle_outlined,
                color: Color(0xFFB42318),
              ),
            ),
          IconButton(
            tooltip: 'Ververs',
            onPressed: () {
              ref
                  .read(
                    multiplayerSessionControllerProvider(widget.roomCode).notifier,
                  )
                  .refreshRoom();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: sessionAsync.when(
          data: (session) => _buildContent(context, session),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(context, _toMessage(error)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MultiplayerSessionState session) {
    final room = session.room;
    final question = room.currentQuestion;
    final roomMissing = _isRoomMissingError(session.lastError);
    final sortedPlayers = _sortPlayersByScore(room.players);
    final allPlayersAnswered =
        sortedPlayers.isNotEmpty &&
        sortedPlayers.every((player) => player.hasAnswered);
    final showAnswerReveal =
        room.status == MultiplayerRoomStatus.questionResult ||
        allPlayersAnswered;
    final correctAnswerId = question?.resolvedCorrectAnswerId ?? '';
    final selectedAnswerId =
      (session.selectedAnswerId != null && session.selectedAnswerId!.isNotEmpty)
      ? session.selectedAnswerId
      : ((question?.selectedAnswerId.isNotEmpty ?? false)
          ? question?.selectedAnswerId
          : null);

    if (question == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Wachten op de volgende vraag...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (session.lastError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    session.lastError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final controller = ref.read(
      multiplayerSessionControllerProvider(widget.roomCode).notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestionHeader(question),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...question.answers.map((answer) {
            final isSelected = selectedAnswerId == answer.id;
            final isCorrect =
                correctAnswerId.isNotEmpty && correctAnswerId == answer.id;
            final canAnswer =
                !roomMissing &&
                !session.hasSubmittedCurrentAnswer &&
                !showAnswerReveal;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: canAnswer
                    ? () {
                        controller.submitAnswer(
                          questionId: question.id,
                          answerId: answer.id,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: _answerTextColor(
                    reveal: showAnswerReveal,
                    isCorrect: isCorrect,
                    isSelected: isSelected,
                  ),
                  disabledForegroundColor: _answerTextColor(
                    reveal: showAnswerReveal,
                    isCorrect: isCorrect,
                    isSelected: isSelected,
                  ),
                  backgroundColor: _answerBackgroundColor(
                    reveal: showAnswerReveal,
                    isCorrect: isCorrect,
                    isSelected: isSelected,
                  ),
                  disabledBackgroundColor: _answerBackgroundColor(
                    reveal: showAnswerReveal,
                    isCorrect: isCorrect,
                    isSelected: isSelected,
                  ),
                  side: BorderSide(
                    color: _answerBorderColor(
                      reveal: showAnswerReveal,
                      isCorrect: isCorrect,
                      isSelected: isSelected,
                    ),
                    width: 1.4,
                  ),
                  elevation: 0,
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        answer.text,
                        style: const TextStyle(fontSize: 16, height: 1.3),
                      ),
                    ),
                    if (showAnswerReveal)
                      _buildAnswerBadge(
                        isCorrect: isCorrect,
                        isSelected: isSelected,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (showAnswerReveal)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildAnswerOutcomeCard(
                hasCorrectAnswer: correctAnswerId.isNotEmpty,
                selectedAnswerId: selectedAnswerId,
                correctAnswerId: correctAnswerId,
              ),
            )
          else if (session.hasSubmittedCurrentAnswer)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFE7D0)),
                ),
                child: const Text(
                  'Antwoord ingestuurd. Wachten op andere spelers...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (session.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                session.lastError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB42318)),
              ),
            ),
          if (roomMissing)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/play-together');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF131D2B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Terug naar Play Together'),
              ),
            ),
          const SizedBox(height: 20),
          _buildProgress(sortedPlayers),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(MultiplayerQuestionState question) {
    final seconds = question.remainingSeconds.clamp(0, 600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Vraag ${question.questionNumber}/${question.totalQuestions}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent,
              ),
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            key: ValueKey('${question.id}-${question.remainingSeconds}'),
            tween: Tween<double>(begin: seconds.toDouble(), end: 0),
            duration: Duration(seconds: seconds),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${value.ceil()}s',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB42318),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(List<MultiplayerPlayer> players) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live voortgang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 10),
          ...players.map((player) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name.isEmpty ? 'Speler' : player.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    player.hasAnswered
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: player.hasAnswered
                        ? const Color(0xFF1E7A4E)
                        : const Color(0xFFA3AAB7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${player.score} pt',
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<MultiplayerPlayer> _sortPlayersByScore(List<MultiplayerPlayer> players) {
    final sorted = [...players];
    sorted.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;

      final correctCompare = b.correctAnswers.compareTo(a.correctAnswers);
      if (correctCompare != 0) return correctCompare;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  Color _answerBackgroundColor({
    required bool reveal,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (reveal) {
      if (isCorrect) return const Color(0xFFEAF8F1);
      if (isSelected) return const Color(0xFFFFEEF0);
      return Colors.white;
    }

    if (isSelected) {
      return AppTheme.accentSoft;
    }

    return Colors.white;
  }

  Color _answerBorderColor({
    required bool reveal,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (reveal) {
      if (isCorrect) return const Color(0xFF1E7A4E);
      if (isSelected) return const Color(0xFFD14B63);
      return AppTheme.border;
    }

    if (isSelected) return AppTheme.accent;
    return AppTheme.border;
  }

  Color _answerTextColor({
    required bool reveal,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (reveal) {
      if (isCorrect) return const Color(0xFF14532D);
      if (isSelected) return const Color(0xFF7F1D1D);
      return AppTheme.ink;
    }

    if (isSelected) return AppTheme.accent;
    return AppTheme.ink;
  }

  Widget _buildAnswerBadge({
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (!isCorrect && !isSelected) {
      return const SizedBox.shrink();
    }

    late final String label;
    late final Color background;
    late final Color foreground;
    late final IconData icon;

    if (isCorrect) {
      label = isSelected ? 'Juiste keuze' : 'Correct';
      background = const Color(0xFF1E7A4E);
      foreground = Colors.white;
      icon = Icons.check_circle_rounded;
    } else {
      label = 'Jouw keuze';
      background = const Color(0xFFB42318);
      foreground = Colors.white;
      icon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOutcomeCard({
    required bool hasCorrectAnswer,
    required String? selectedAnswerId,
    required String correctAnswerId,
  }) {
    if (!hasCorrectAnswer) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: AppTheme.muted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Alle antwoorden zijn binnen. Correct antwoord wordt verwerkt...',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (selectedAnswerId == null || selectedAnswerId.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8F1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFE7D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.visibility_rounded, color: Color(0xFF166534)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Correct antwoord is groen gemarkeerd.',
                style: TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isCorrect = selectedAnswerId == correctAnswerId;
    final background = isCorrect
        ? const Color(0xFFEAF8F1)
        : const Color(0xFFFFEEF0);
    final border = isCorrect
        ? const Color(0xFFBFE7D0)
        : const Color(0xFFF2C7CE);
    final textColor = isCorrect
        ? const Color(0xFF166534)
        : const Color(0xFFB42318);
    final icon = isCorrect
        ? Icons.verified_rounded
        : Icons.warning_amber_rounded;
    final title = isCorrect ? 'Goed gedaan' : 'Bijna';
    final subtitle = isCorrect
        ? 'Je antwoord is correct. Mooie score!'
        : 'Jouw keuze is rood en het juiste antwoord is groen.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF2C7CE)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(
                        multiplayerSessionControllerProvider(widget.roomCode)
                            .notifier,
                      )
                      .refreshRoom(showLoading: true);
                },
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _toMessage(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.replaceFirst('Exception: ', '')
        : text;
  }

  bool _isRoomMissingError(String? error) {
    final normalized = error?.toLowerCase() ?? '';
    return normalized.contains('room_not_found') ||
        normalized.contains('room not found') ||
        normalized.contains('kamer bestaat niet meer');
  }

  Widget _buildAppBarTitle(MultiplayerRoom? room) {
    if (room == null) {
      return const Text('Play Together');
    }

    final quizTitle = room.quizTitle.trim().isEmpty
        ? 'Multiplayer quiz'
        : room.quizTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Kamer ${room.code}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        Text(
          quizTitle,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndStopMatch() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quiz stoppen?'),
          content: const Text(
            'Wil je deze multiplayer-quiz stoppen voor alle spelers?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop quiz'),
            ),
          ],
        );
      },
    );

    if (shouldStop != true || !mounted) return;

    await ref
        .read(multiplayerSessionControllerProvider(widget.roomCode).notifier)
        .stopMatch();
  }
}
