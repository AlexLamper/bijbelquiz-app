import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../profile/present/profile_provider.dart';
import '../../quiz/data/bible_chapter_repository.dart';
import '../../quiz/domain/quiz_passage.dart';
import '../data/multiplayer_api_exception.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';
import 'widgets/mp_ui.dart';

/// The live group question screen, in the visual language of the solo quiz:
/// segments on top, a white question card, 2x2 answer tiles and a white
/// feedback sheet - plus what only a live game has: the countdown, how many
/// players have answered and the running standings.
class MultiplayerGameScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerGameScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerGameScreen> createState() =>
      _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen> {
  bool _handledRoomMissing = false;

  MultiplayerSessionController get _controller => ref.read(
    multiplayerSessionControllerProvider(widget.roomCode).notifier,
  );

  bool _isHost(MultiplayerRoom room) {
    final userId = ref.read(profileProvider).asData?.value.id;
    return room.isHost(userId);
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      multiplayerSessionControllerProvider(widget.roomCode),
    );
    final currentUserId = ref.watch(profileProvider).asData?.value.id ?? '';

    ref.listen<
      AsyncValue<MultiplayerSessionState>
    >(multiplayerSessionControllerProvider(widget.roomCode), (previous, next) {
      final session = next.asData?.value;
      final room = session?.room;
      if (session == null || room == null || !mounted) return;

      if (_isRoomMissingError(session.lastError)) {
        if (_handledRoomMissing) return;
        _handledRoomMissing = true;
        AppNotice.error(
          context,
          const MultiplayerApiException(
            code: 'ROOM_NOT_FOUND',
            message: 'Kamer niet gevonden.',
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
      body: SafeArea(
        bottom: false,
        child: sessionAsync.when(
          data: (session) => _buildContent(context, session, currentUserId),
          loading: () => Column(
            children: [
              _TitleHeader(
                title: 'Samen spelen',
                closeLabel: 'Terug naar Samen spelen',
                onClose: () => context.go('/play-together'),
              ),
              const Expanded(child: AppLoader()),
            ],
          ),
          error: (error, _) => Column(
            children: [
              _TitleHeader(
                title: 'Samen spelen',
                closeLabel: 'Terug naar Samen spelen',
                onClose: () => context.go('/play-together'),
              ),
              Expanded(child: _buildError(context, AppError.from(error))),
            ],
          ),
        ),
      ),
    );
  }

  /// The close button: the host stops the quiz for everybody, a guest only
  /// leaves (their score is kept if they come back). Both ask first.
  VoidCallback _closeAction(MultiplayerRoom room, bool roomMissing) {
    if (roomMissing) return () => context.go('/play-together');
    if (_isHost(room) && room.status != MultiplayerRoomStatus.finished) {
      return _confirmAndStopMatch;
    }
    return _confirmAndLeave;
  }

  String _closeLabel(MultiplayerRoom room) =>
      _isHost(room) ? 'Quiz stoppen' : 'Spel verlaten';

  Widget _buildContent(
    BuildContext context,
    MultiplayerSessionState session,
    String currentUserId,
  ) {
    final room = session.room;
    final question = room.currentQuestion;
    final roomMissing = _isRoomMissingError(session.lastError);
    final quizTitle = room.quizTitle.trim().isEmpty
        ? 'Multiplayer quiz'
        : room.quizTitle;

    // The reading phase sits between the lobby and question 1: every device
    // shows the chapter, the host presses on when the room is ready.
    if (room.status == MultiplayerRoomStatus.reading) {
      return _ReadingView(
        room: room,
        isHost: _isHost(room),
        lastError: session.lastError,
        onStart: _controller.advance,
        closeLabel: _closeLabel(room),
        onClose: _closeAction(room, roomMissing),
      );
    }

    if (question == null) {
      return Column(
        children: [
          _TitleHeader(
            title: quizTitle,
            subtitle: 'Kamer ${room.code}',
            closeLabel: _closeLabel(room),
            onClose: _closeAction(room, roomMissing),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BqCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLoader(size: 22),
                      const SizedBox(height: 16),
                      const Text(
                        'Wachten op de volgende vraag…',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLead,
                      ),
                      if (session.lastError != null) ...[
                        const SizedBox(height: 12),
                        MpNotice(message: session.lastError!),
                      ],
                      if (roomMissing) ...[
                        const SizedBox(height: 12),
                        BqButton(
                          label: 'Terug naar Samen spelen',
                          onPressed: () => context.go('/play-together'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Only the server reveals. It withholds `correctAnswerId` while the room
    // is `in_progress` precisely so a client cannot show the answer early, and
    // guessing from "everyone has answered" produced a reveal card with
    // nothing to reveal for the beat before the next poll landed.
    final revealed = question.isRevealed;
    final correctAnswerId = question.correctAnswerId ?? '';
    final selectedAnswerId = session.selectedAnswerId;
    final canAnswer = !roomMissing && !session.hasAnswered && !revealed;
    final isHost = _isHost(room);
    final hostTempo = room.questionTimerSeconds == 0;

    final players = room.standings;
    final answeredCount = players.where((p) => p.hasAnswered).length;
    final correctCount = players.where((p) => p.answeredCorrectly == true).length;

    Widget? panel;
    if (revealed) {
      panel = _RevealPanel(
        question: question,
        selectedAnswerId: selectedAnswerId,
        correctAnswerId: correctAnswerId,
        gained: room.playerById(currentUserId)?.scoreGained ?? 0,
        // The host can cut the reveal pause short instead of everyone
        // waiting out the full twelve seconds.
        onNext:
            isHost && room.status == MultiplayerRoomStatus.questionResult
            ? _controller.advance
            : null,
        hostTempo: hostTempo,
      );
    } else if (session.hasAnswered || (hostTempo && isHost)) {
      // Host-tempo mode: no timer runs, so the host ends the question by
      // hand once the room has had long enough.
      final showReveal =
          hostTempo &&
          isHost &&
          room.status == MultiplayerRoomStatus.inProgress &&
          !roomMissing;
      panel = _WaitingPanel(
        answered: session.hasAnswered,
        onReveal: showReveal ? _controller.advance : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _ProgressHeader(
            number: question.questionNumber,
            total: question.totalQuestions,
            closeLabel: _closeLabel(room),
            onClose: _closeAction(room, roomMissing),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.lapis,
            backgroundColor: AppTheme.paperRaised,
            onRefresh: () => _controller.refreshRoom(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _QuestionCard(
                  label: question.bibleReference.trim().isNotEmpty
                      ? question.bibleReference
                      : quizTitle,
                  text: question.text,
                  // Host-tempo mode has no deadline on the wire, so there is
                  // nothing to count down: the host drives every step.
                  timer: room.questionTimerSeconds > 0 && !revealed
                      ? _CountdownPill(
                          remainingMs: () => session.questionRemainingMs,
                          fallbackSeconds: question.remainingSeconds,
                          urgent: true,
                        )
                      : session.resultPhaseRemainingMs != null
                      ? _CountdownPill(
                          remainingMs: () => session.resultPhaseRemainingMs,
                          fallbackSeconds: 0,
                          prefix: 'Volgende in ',
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                _AnswerGrid(
                  answers: question.answers,
                  selectedAnswerId: selectedAnswerId,
                  correctAnswerId: correctAnswerId,
                  revealed: revealed,
                  answered: session.hasAnswered,
                  onAnswer: canAnswer
                      ? (answer) => _controller.submitAnswer(
                          questionId: question.id,
                          answerId: answer.id,
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                _AnsweredLine(
                  text: revealed
                      ? '$correctCount van ${players.length} had het goed'
                      : '$answeredCount van ${players.length} '
                            '${players.length == 1 ? 'speler heeft' : 'spelers hebben'} '
                            'geantwoord',
                ),
                if (session.lastError != null) ...[
                  const SizedBox(height: 16),
                  MpNotice(message: session.lastError!),
                ],
                if (roomMissing) ...[
                  const SizedBox(height: 12),
                  BqButton(
                    label: 'Terug naar Samen spelen',
                    onPressed: () => context.go('/play-together'),
                  ),
                ],
                const SizedBox(height: 24),
                const MpSectionLabel('Stand'),
                const SizedBox(height: 8),
                _LiveStandings(
                  players: players,
                  revealed: revealed,
                  currentUserId: currentUserId,
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: panel ?? const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, AppError error) {
    return AppEmptyState(
      icon: error.icon,
      title: error.title,
      description: error.message,
      action: MpSecondaryButton(
        label: 'Opnieuw proberen',
        expand: false,
        height: 44,
        onPressed: () => _controller.refreshRoom(showLoading: true),
      ),
    );
  }

  bool _isRoomMissingError(String? error) {
    final normalized = error?.toLowerCase() ?? '';
    return normalized.contains('room_not_found') ||
        normalized.contains('room not found') ||
        normalized.contains('kamer bestaat niet meer');
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
                minimumSize: const Size(0, 44),
              ),
              child: const Text('Stop quiz'),
            ),
          ],
        );
      },
    );

    if (shouldStop != true || !mounted) return;

    await _controller.stopMatch();

    // Polling has stopped, so nothing would move this screen on by itself.
    if (!mounted) return;
    context.go('/play-together');
  }

  Future<void> _confirmAndLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Spel verlaten?'),
          content: const Text(
            'Je score blijft bewaard als je terugkomt via Samen spelen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Blijf'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text('Verlaat spel'),
            ),
          ],
        );
      },
    );

    if (leave != true || !mounted) return;
    await _controller.leaveRoom();
    if (!mounted) return;
    context.go('/play-together');
  }
}

// ---------------------------------------------------------------------------
// Headers
// ---------------------------------------------------------------------------

/// Close button, question segments and "4/10".
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.number,
    required this.total,
    required this.closeLabel,
    required this.onClose,
  });

  final int number;
  final int total;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final done = number.clamp(0, total);
    return Row(
      children: [
        BqCircleButton(
          icon: BqIcons.close,
          label: closeLabel,
          onTap: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            label: 'Vraag $number van $total',
            excludeSemantics: true,
            // Past twenty questions the segments get too thin to read.
            child: total > 0 && total <= 20
                ? BqSegments(total: total, done: done)
                : BqProgressBar(
                    value: total == 0 ? 0 : done / total,
                    color: AppTheme.lapis,
                    track: const Color(0xFFD9D6CE),
                    height: 6,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$number/$total',
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.inkSoft,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Close button with a 17/800 title and muted subtitle (reading, waiting).
class _TitleHeader extends StatelessWidget {
  const _TitleHeader({
    required this.title,
    required this.closeLabel,
    required this.onClose,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          BqCircleButton(
            icon: BqIcons.close,
            label: closeLabel,
            onTap: onClose,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 22 / 17,
                    color: AppTheme.ink,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Question
// ---------------------------------------------------------------------------

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.label,
    required this.text,
    required this.timer,
  });

  final String label;
  final String text;
  final Widget? timer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B1A18),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lapisTint,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.48,
                      color: AppTheme.lapisStrong,
                    ),
                  ),
                ),
              ),
              if (timer != null) ...[const SizedBox(width: 8), timer!],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: AppTheme.displayMedium.copyWith(height: 31 / 24),
          ),
        ],
      ),
    );
  }
}

/// Ticking countdown pill against a server deadline.
///
/// Reads the remaining time from the session on every tick rather than
/// animating a fixed duration: polls land at irregular moments, and a tween
/// restarted on each one visibly stutters. [fallbackSeconds] covers the case
/// where the server sent no absolute deadline.
class _CountdownPill extends StatefulWidget {
  const _CountdownPill({
    required this.remainingMs,
    required this.fallbackSeconds,
    this.prefix = '',
    this.urgent = false,
  });

  final int? Function() remainingMs;
  final int fallbackSeconds;
  final String prefix;

  /// Question timer (coral) rather than the pause before the next one (lapis).
  final bool urgent;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.remainingMs();
    final seconds =
        (remaining == null
                ? widget.fallbackSeconds
                : (remaining / 1000).ceil())
            .clamp(0, 600);

    final bg = widget.urgent ? AppTheme.coralTint : AppTheme.lapisTint;
    final fg = widget.urgent ? AppTheme.vermilion : AppTheme.lapisStrong;
    final icon = widget.urgent ? AppTheme.coral : AppTheme.lapis;

    return Semantics(
      label: widget.urgent
          ? 'Nog $seconds seconden'
          : 'Volgende vraag in $seconds seconden',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BqIcon(BqIcons.clock, size: 14, color: icon),
            const SizedBox(width: 4),
            Text(
              '${widget.prefix}${seconds}s',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Answers
// ---------------------------------------------------------------------------

enum _TileState { idle, picked, dimmed, correct, wrong, muted }

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.answers,
    required this.selectedAnswerId,
    required this.correctAnswerId,
    required this.revealed,
    required this.answered,
    required this.onAnswer,
  });

  final List<MultiplayerAnswerOption> answers;
  final String? selectedAnswerId;
  final String correctAnswerId;
  final bool revealed;
  final bool answered;
  final ValueChanged<MultiplayerAnswerOption>? onAnswer;

  _TileState _stateFor(MultiplayerAnswerOption answer) {
    final isSelected = selectedAnswerId == answer.id;
    final isCorrect =
        correctAnswerId.isNotEmpty && correctAnswerId == answer.id;
    if (revealed) {
      if (isCorrect) return _TileState.correct;
      if (isSelected) return _TileState.wrong;
      return _TileState.muted;
    }
    if (isSelected) return _TileState.picked;
    return answered ? _TileState.dimmed : _TileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    // Numbers and names read best big, as in the solo design; sentences
    // need the smaller size to fit two to a row.
    final short = answers.every((a) => a.text.trim().length <= 14);
    final fontSize = short ? 20.0 : 16.0;

    final rows = <Widget>[];
    for (var i = 0; i < answers.length; i += 2) {
      Widget tile(int index) {
        final answer = answers[index];
        return _AnswerTile(
          text: answer.text,
          state: _stateFor(answer),
          // How the room split. Only present after the reveal, which is also
          // the only moment the server sends it. Nobody = no badge.
          count: revealed && (answer.count ?? 0) > 0 ? answer.count : null,
          fontSize: fontSize,
          onTap: onAnswer == null ? null : () => onAnswer!(answer),
        );
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tile(i)),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < answers.length
                      ? tile(i + 1)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.text,
    required this.state,
    required this.count,
    required this.fontSize,
    required this.onTap,
  });

  final String text;
  final _TileState state;
  final int? count;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (face, border, edge, fg) = switch (state) {
      _TileState.idle => (
        AppTheme.paperRaised,
        AppTheme.rule,
        AppTheme.ruleStrong,
        AppTheme.ink,
      ),
      _TileState.picked => (
        AppTheme.lapisTint,
        AppTheme.lapis,
        AppTheme.lapis,
        AppTheme.lapisStrong,
      ),
      _TileState.dimmed || _TileState.muted => (
        AppTheme.paperRaised,
        AppTheme.rule,
        AppTheme.ruleStrong,
        mpTileMuted,
      ),
      _TileState.correct => (
        AppTheme.positive,
        AppTheme.positiveDeep,
        AppTheme.positiveDeep,
        AppTheme.inkInverted,
      ),
      _TileState.wrong => (
        AppTheme.coralTint,
        AppTheme.coral,
        AppTheme.coral,
        AppTheme.vermilion,
      ),
    };

    final icon = switch (state) {
      _TileState.correct => BqIcons.check,
      _TileState.wrong => BqIcons.close,
      _ => null,
    };

    final semantics = StringBuffer(text);
    if (state == _TileState.picked || state == _TileState.wrong) {
      semantics.write(', jouw antwoord');
    }
    if (state == _TileState.correct) semantics.write(', goed antwoord');
    if (state == _TileState.wrong) semantics.write(', fout');
    if (count != null) semantics.write(', $count keer gekozen');

    final radius = BorderRadius.circular(14);

    final tile = DecoratedBox(
      decoration: BoxDecoration(color: edge, borderRadius: radius),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Material(
          color: face,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 73),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        BqIcon(icon, size: 20, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semantics.toString(),
      excludeSemantics: true,
      // Always laid out with a tight size (IntrinsicHeight + stretch in
      // _AnswerGrid), so the tile fills it and the badge can overhang.
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          tile,
          if (count != null)
            Positioned(top: -9, right: -6, child: _CountBadge(count: count!)),
        ],
      ),
    );
  }
}

/// "3" with a people icon, pinned to a tile's corner after the reveal.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BqIcon(BqIcons.users, size: 12, color: AppTheme.lapis),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.lapis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnsweredLine extends StatelessWidget {
  const _AnsweredLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const BqIcon(BqIcons.users, size: 16, color: AppTheme.inkMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTheme.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Standings
// ---------------------------------------------------------------------------

class _LiveStandings extends StatelessWidget {
  const _LiveStandings({
    required this.players,
    required this.revealed,
    required this.currentUserId,
  });

  final List<MultiplayerPlayer> players;
  final bool revealed;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < players.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
            _StandingRow(
              rank: i + 1,
              player: players[i],
              revealed: revealed,
              isMe:
                  currentUserId.isNotEmpty && players[i].id == currentUserId,
            ),
          ],
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.rank,
    required this.player,
    required this.revealed,
    required this.isMe,
  });

  final int rank;
  final MultiplayerPlayer player;
  final bool revealed;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final name = player.name.isEmpty ? 'Speler' : player.name;
    final offline = !player.isConnected;
    final gained = player.scoreGained ?? 0;
    final strong = isMe ? AppTheme.lapisStrong : AppTheme.inkSoft;

    // During the reveal the server says who was right; while answering it
    // only says who has responded.
    final status = revealed
        ? switch (player.answeredCorrectly) {
            true => 'goed',
            false => 'fout',
            null => 'geen antwoord',
          }
        : player.hasAnswered
        ? 'heeft geantwoord'
        : 'denkt nog na';

    return Semantics(
      label:
          '$rank. ${isMe ? 'Jij' : name}, ${player.score} punten, $status'
          '${offline ? ', offline' : ''}',
      excludeSemantics: true,
      child: Container(
        color: isMe ? AppTheme.lapisTint : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: strong,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: offline ? 0.45 : 1,
              child: BqAvatar(
                name: name,
                size: 36,
                background: isMe ? AppTheme.paperRaised : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isMe ? 'Jij' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyStrong.copyWith(
                  color: offline ? AppTheme.inkMuted : AppTheme.ink,
                ),
              ),
            ),
            _StatusMark(revealed: revealed, player: player),
            if (revealed && gained > 0) ...[
              const SizedBox(width: 8),
              Text(
                '+$gained',
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.positiveText,
                ),
              ),
            ],
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: Text(
                '${player.score}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: strong,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small round mark: answered / still thinking, then right / wrong / none.
class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.revealed, required this.player});

  final bool revealed;
  final MultiplayerPlayer player;

  @override
  Widget build(BuildContext context) {
    final (Color? bg, Color? ring, String? icon, Color fg) = revealed
        ? switch (player.answeredCorrectly) {
            true => (
              AppTheme.positive,
              null,
              BqIcons.check,
              AppTheme.inkInverted,
            ),
            false => (
              AppTheme.coralDeep,
              null,
              BqIcons.close,
              AppTheme.inkInverted,
            ),
            null => (null, AppTheme.ruleStrong, null, AppTheme.inkMuted),
          }
        : player.hasAnswered
        ? (AppTheme.positiveTint, null, BqIcons.check, AppTheme.positive)
        : (null, AppTheme.ruleStrong, null, AppTheme.inkMuted);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring != null ? Border.all(color: ring, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: icon != null ? BqIcon(icon, size: 12, color: fg) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom panels
// ---------------------------------------------------------------------------

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.circle,
    required this.iconColor,
    required this.title,
    required this.titleColor,
  });

  final String icon;
  final Color circle;
  final Color iconColor;
  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: BqIcon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: titleColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// White feedback sheet after the reveal, as in the solo quiz.
class _RevealPanel extends StatelessWidget {
  const _RevealPanel({
    required this.question,
    required this.selectedAnswerId,
    required this.correctAnswerId,
    required this.gained,
    required this.onNext,
    required this.hostTempo,
  });

  final MultiplayerQuestionState question;
  final String? selectedAnswerId;
  final String correctAnswerId;
  final int gained;
  final VoidCallback? onNext;
  final bool hostTempo;

  @override
  Widget build(BuildContext context) {
    final noAnswer = selectedAnswerId == null || selectedAnswerId!.isEmpty;
    final isCorrect = !noAnswer && selectedAnswerId == correctAnswerId;

    final title = noAnswer
        ? const _PanelTitle(
            icon: BqIcons.clock,
            circle: AppTheme.ruleSoft,
            iconColor: AppTheme.inkSoft,
            title: 'Geen antwoord',
            titleColor: AppTheme.inkSoft,
          )
        : isCorrect
        ? const _PanelTitle(
            icon: BqIcons.check,
            circle: AppTheme.positive,
            iconColor: AppTheme.inkInverted,
            title: 'Goed!',
            titleColor: AppTheme.positiveText,
          )
        : const _PanelTitle(
            icon: BqIcons.close,
            circle: AppTheme.coralDeep,
            iconColor: AppTheme.inkInverted,
            title: 'Helaas',
            titleColor: AppTheme.vermilion,
          );

    final body =
        question.explanation ??
        (noAnswer
            ? 'Het juiste antwoord is groen gemarkeerd.'
            : isCorrect
            ? 'Je antwoord is correct.'
            : 'Jouw keuze staat gemarkeerd naast het juiste antwoord.');

    final reference = question.bibleReference.trim();

    return Semantics(
      container: true,
      liveRegion: true,
      child: MpBottomPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: title),
                ),
                if (gained > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.goldTint,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BqIcon(BqIcons.bolt, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+$gained punten',
                          style: const TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.goldText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: AppTheme.bodyLead.copyWith(color: const Color(0xFF3E3C37)),
            ),
            if (reference.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lapisTint,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BqIcon(
                        BqIcons.book,
                        size: 14,
                        color: AppTheme.lapis,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reference,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.lapis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (onNext != null) ...[
              const SizedBox(height: 12),
              BqButton(label: 'Volgende vraag', onPressed: onNext),
            ] else if (hostTempo) ...[
              const SizedBox(height: 12),
              const Text(
                'De host gaat zo door naar de volgende vraag.',
                style: AppTheme.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// After answering (or, for the host in host-tempo mode, before the reveal).
class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel({required this.answered, required this.onReveal});

  final bool answered;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context) {
    return MpBottomPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (answered) ...[
            const _PanelTitle(
              icon: BqIcons.check,
              circle: AppTheme.lapisTint,
              iconColor: AppTheme.lapis,
              title: 'Ingestuurd',
              titleColor: AppTheme.lapisStrong,
            ),
            const SizedBox(height: 12),
            const Text(
              'Wachten op de andere spelers…',
              style: AppTheme.bodyLead,
            ),
          ] else
            const Text(
              'Jij bepaalt het tempo. Toon de antwoorden zodra iedereen klaar '
              'is.',
              style: AppTheme.bodyLead,
            ),
          if (onReveal != null) ...[
            const SizedBox(height: 12),
            BqButton(label: 'Toon antwoorden', onPressed: onReveal),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reading phase
// ---------------------------------------------------------------------------

/// The chapter every device reads before question 1, shown while the room is
/// in the `reading` phase. Laid out like the solo "Lezen" screen.
class _ReadingView extends ConsumerWidget {
  const _ReadingView({
    required this.room,
    required this.isHost,
    required this.lastError,
    required this.onStart,
    required this.closeLabel,
    required this.onClose,
  });

  final MultiplayerRoom room;
  final bool isHost;
  final String? lastError;
  final VoidCallback onStart;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passage = room.passage;
    final quizTitle = room.quizTitle.trim().isEmpty
        ? 'Multiplayer quiz'
        : room.quizTitle;

    final footer = MpBottomPanel(
      rounded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lastError != null) ...[
            MpNotice(message: lastError!),
            const SizedBox(height: 12),
          ],
          if (isHost)
            BqButton(label: 'Start de vragen', onPressed: onStart)
          else
            const _WaitingRow(text: 'Wacht tot de host de vragen start.'),
        ],
      ),
    );

    if (passage == null) {
      return Column(
        children: [
          _TitleHeader(
            title: quizTitle,
            subtitle: 'Kamer ${room.code}',
            closeLabel: closeLabel,
            onClose: onClose,
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: BqCard(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Wachten tot de host de vragen start…',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyLead,
                  ),
                ),
              ),
            ),
          ),
          footer,
        ],
      );
    }

    final quizPassage = QuizPassage(
      book: passage.book,
      chapter: passage.chapter,
      label: passage.label,
    );
    final versesAsync = ref.watch(chapterVersesProvider(quizPassage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TitleHeader(
          title: passage.label,
          subtitle: 'Lees voor de quiz $quizTitle',
          closeLabel: closeLabel,
          onClose: onClose,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: versesAsync.when(
            data: (verses) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Neem dit hoofdstuk rustig door. De vragen hierna gaan '
                    'hierover, dus lezen helpt echt.',
                    style: AppTheme.bodyMuted,
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        for (final verse in verses) ...[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Transform.translate(
                              offset: const Offset(0, -3),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Text(
                                  '${verse.verse}',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.sansFontName,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                    color: AppTheme.lapis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Word joiner: a verse number never ends a line
                          // on its own.
                          TextSpan(text: '⁠${verse.text} '),
                        ],
                      ],
                    ),
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 25 / 16,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('STATENVERTALING', style: AppTheme.eyebrow),
                ],
              ),
            ),
            loading: () => const AppLoader(),
            // A chapter that will not load must never block the game.
            error: (error, _) => AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Hoofdstuk niet geladen',
              description:
                  'Dit hoofdstuk kon nu niet opgehaald worden. De host kan '
                  'gewoon met de vragen beginnen.',
              action: MpSecondaryButton(
                label: 'Opnieuw proberen',
                expand: false,
                height: 44,
                onPressed: () =>
                    ref.invalidate(chapterVersesProvider(quizPassage)),
              ),
            ),
          ),
        ),
        footer,
      ],
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.lapis,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: AppTheme.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
