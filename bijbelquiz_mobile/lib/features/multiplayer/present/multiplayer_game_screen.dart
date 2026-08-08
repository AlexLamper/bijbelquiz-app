import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/present/profile_provider.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';

class MultiplayerGameScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerGameScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerGameScreen> createState() =>
      _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen> {
  bool _handledRoomMissing = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      multiplayerSessionControllerProvider(widget.roomCode),
    );
    final room = sessionAsync.asData?.value.room;
    final roomMissing = _isRoomMissingError(
      sessionAsync.asData?.value.lastError,
    );
    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.maybeWhen(
      data: (profile) => profile.id,
      orElse: () => '',
    );
    final isHost =
        room != null &&
        currentUserId.isNotEmpty &&
        currentUserId == room.hostUserId;

    ref.listen<
      AsyncValue<MultiplayerSessionState>
    >(multiplayerSessionControllerProvider(widget.roomCode), (previous, next) {
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
    });

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: _buildAppBarTitle(room),
        backgroundColor: AppTheme.paper,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        actions: [
          if (isHost &&
              !roomMissing &&
              room.status != MultiplayerRoomStatus.finished)
            IconButton(
              tooltip: 'Stop quiz',
              onPressed: _confirmAndStopMatch,
              icon: const Icon(
                Icons.stop_circle_outlined,
                size: 20,
                color: AppTheme.destructive,
              ),
            ),
          IconButton(
            tooltip: 'Ververs',
            onPressed: () {
              ref
                  .read(
                    multiplayerSessionControllerProvider(
                      widget.roomCode,
                    ).notifier,
                  )
                  .refreshRoom();
            },
            icon: const Icon(Icons.refresh, size: 20, color: AppTheme.inkSoft),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: sessionAsync.when(
          data: (session) => _buildContent(context, session),
          loading: () => const AppLoader(),
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
        (session.selectedAnswerId != null &&
            session.selectedAnswerId!.isNotEmpty)
        ? session.selectedAnswerId
        : ((question?.selectedAnswerId.isNotEmpty ?? false)
              ? question?.selectedAnswerId
              : null);

    if (question == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoader(size: 22),
                const SizedBox(height: 20),
                const Text(
                  'Wachten op de volgende vraag…',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMuted,
                ),
                if (session.lastError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    session.lastError!,
                    textAlign: TextAlign.center,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.destructive,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestionHeader(question),
          const SizedBox(height: 28),
          Text(
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
          const SizedBox(height: 24),
          for (var i = 0; i < question.answers.length; i++)
            _buildAnswerOption(
              answer: question.answers[i],
              index: i,
              question: question,
              controller: controller,
              session: session,
              roomMissing: roomMissing,
              showAnswerReveal: showAnswerReveal,
              correctAnswerId: correctAnswerId,
              selectedAnswerId: selectedAnswerId,
            ),
          if (showAnswerReveal)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildAnswerOutcomeCard(
                hasCorrectAnswer: correctAnswerId.isNotEmpty,
                selectedAnswerId: selectedAnswerId,
                correctAnswerId: correctAnswerId,
              ),
            )
          else if (session.hasSubmittedCurrentAnswer)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _NoticeBlock(
                accent: AppTheme.positive,
                label: 'Ingestuurd',
                message: 'Wachten op de andere spelers…',
              ),
            ),
          if (session.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _NoticeBlock(
                accent: AppTheme.destructive,
                label: 'Foutmelding',
                message: session.lastError!,
              ),
            ),
          if (roomMissing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SiteButton(
                label: 'Terug naar Samen spelen',
                icon: Icons.arrow_back,
                onPressed: () => context.go('/play-together'),
              ),
            ),
          const SizedBox(height: 40),
          const SectionHeader(eyebrow: 'Live', title: 'Voortgang'),
          const SizedBox(height: 24),
          _buildProgress(sortedPlayers),
        ],
      ),
    );
  }

  /// Answer option — identical treatment to the single-player quiz:
  /// `rounded-md border border-rule bg-paper-raised`, revealed states use
  /// `bg-positive-tint / border-positive/35` and the vermilion equivalents.
  Widget _buildAnswerOption({
    required MultiplayerAnswerOption answer,
    required int index,
    required MultiplayerQuestionState question,
    required MultiplayerSessionController controller,
    required MultiplayerSessionState session,
    required bool roomMissing,
    required bool showAnswerReveal,
    required String correctAnswerId,
    required String? selectedAnswerId,
  }) {
    final isSelected = selectedAnswerId == answer.id;
    final isCorrect =
        correctAnswerId.isNotEmpty && correctAnswerId == answer.id;
    final canAnswer =
        !roomMissing && !session.hasSubmittedCurrentAnswer && !showAnswerReveal;

    Color background = AppTheme.paperRaised;
    Color borderColor = AppTheme.rule;
    Color textColor = AppTheme.ink;
    Color markerColor = AppTheme.inkMuted;

    if (showAnswerReveal) {
      if (isCorrect) {
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
        textColor = AppTheme.inkMuted;
        markerColor = AppTheme.ruleStrong;
      }
    } else if (isSelected) {
      background = AppTheme.lapisTint;
      borderColor = AppTheme.lapis.withValues(alpha: 0.35);
      markerColor = AppTheme.lapis;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: canAnswer
              ? () => controller.submitAnswer(
                  questionId: question.id,
                  answerId: answer.id,
                )
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          splashColor: AppTheme.paperSunken,
          highlightColor: AppTheme.paperSunken,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                if (showAnswerReveal && isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.positive,
                    ),
                  )
                else if (showAnswerReveal && isSelected)
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

  /// `border-y border-rule` rail: question counter left, countdown right.
  Widget _buildQuestionHeader(MultiplayerQuestionState question) {
    final seconds = question.remainingSeconds.clamp(0, 600);
    final progress = question.totalQuestions == 0
        ? 0.0
        : question.questionNumber / question.totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'VRAAG ${question.questionNumber} / ${question.totalQuestions}',
                style: AppTheme.overline.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              key: ValueKey('${question.id}-${question.remainingSeconds}'),
              tween: Tween<double>(begin: seconds.toDouble(), end: 0),
              duration: Duration(seconds: seconds),
              builder: (context, value, child) {
                return Text(
                  '${value.ceil()}s',
                  style: AppTheme.overline.copyWith(
                    color: AppTheme.vermilion,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          color: AppTheme.rule,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(color: AppTheme.ink),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(List<MultiplayerPlayer> players) {
    return RuleGrid(
      children: [
        for (final player in players)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(
                  player.hasAnswered
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: player.hasAnswered
                      ? AppTheme.positive
                      : AppTheme.ruleStrong,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    player.name.isEmpty ? 'Speler' : player.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong,
                  ),
                ),
                Text(
                  '${player.score}',
                  style: AppTheme.statNumber.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
      ],
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

  Widget _buildAnswerOutcomeCard({
    required bool hasCorrectAnswer,
    required String? selectedAnswerId,
    required String correctAnswerId,
  }) {
    if (!hasCorrectAnswer) {
      return const _NoticeBlock(
        accent: AppTheme.inkMuted,
        label: 'Verwerken',
        message: 'Alle antwoorden zijn binnen. Correct antwoord volgt…',
      );
    }

    if (selectedAnswerId == null || selectedAnswerId.isEmpty) {
      return const _NoticeBlock(
        accent: AppTheme.positive,
        label: 'Antwoord',
        message: 'Het juiste antwoord is gemarkeerd.',
      );
    }

    final isCorrect = selectedAnswerId == correctAnswerId;

    return _NoticeBlock(
      accent: isCorrect ? AppTheme.positive : AppTheme.destructive,
      label: isCorrect ? 'Goed gedaan' : 'Bijna',
      message: isCorrect
          ? 'Je antwoord is correct.'
          : 'Jouw keuze staat gemarkeerd naast het juiste antwoord.',
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Kamer niet beschikbaar',
      description: message,
      action: SiteOutlineButton(
        label: 'Opnieuw proberen',
        expand: false,
        height: 44,
        onPressed: () {
          ref
              .read(
                multiplayerSessionControllerProvider(widget.roomCode).notifier,
              )
              .refreshRoom(showLoading: true);
        },
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
      return const Text('SAMEN SPELEN', style: AppTheme.overline);
    }

    final quizTitle = room.quizTitle.trim().isEmpty
        ? 'Multiplayer quiz'
        : room.quizTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('KAMER ${room.code}', style: AppTheme.overline),
        const SizedBox(height: 3),
        Text(
          quizTitle,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.displayBase.copyWith(fontSize: 15),
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
                backgroundColor: AppTheme.destructive,
                foregroundColor: AppTheme.inkInverted,
                minimumSize: const Size(0, 40),
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

/// Tinted notice block — `bg-<accent>-tint border-<accent>/35 rounded-lg`.
class _NoticeBlock extends StatelessWidget {
  const _NoticeBlock({
    required this.accent,
    required this.label,
    required this.message,
  });

  final Color accent;
  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tint = accent == AppTheme.positive
        ? AppTheme.positiveTint
        : accent == AppTheme.destructive
        ? AppTheme.vermilionTint
        : AppTheme.paperSunken;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.overline.copyWith(color: accent),
          ),
          const SizedBox(height: 8),
          Text(message, style: AppTheme.bodyMuted),
        ],
      ),
    );
  }
}
