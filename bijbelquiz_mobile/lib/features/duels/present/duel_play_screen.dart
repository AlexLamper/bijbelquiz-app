import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/preview_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../quiz/data/bible_verse_repository.dart';
import '../data/duels_repository.dart';
import '../domain/duel.dart';
import 'widgets/duel_widgets.dart';

enum _Phase { loading, error, overview, question }

/// One duel - BijbelQuiz 2.0 (`R-Duelvraag`).
///
/// When it is the player's turn this plays the round: scoreboard with a box
/// per question for both players, the question card, answer tiles that show
/// "Jij" and the opponent on the picked answers once known, and a white
/// feedback sheet. Each answer is graded by the server the moment it is
/// tapped, so leaving halfway loses nothing. After the round - or whenever it
/// is not the player's turn - it shows the duel's overview: the score, every
/// round's boxes and what happens next.
class DuelPlayScreen extends ConsumerStatefulWidget {
  const DuelPlayScreen({super.key, required this.duelId});

  final String duelId;

  @override
  ConsumerState<DuelPlayScreen> createState() => _DuelPlayScreenState();
}

class _DuelPlayScreenState extends ConsumerState<DuelPlayScreen> {
  _Phase _phase = _Phase.loading;
  Duel? _duel;
  Object? _error;

  /// The question on screen.
  int _round = 0;
  int _question = 0;

  /// The graded answer to the question on screen, once it is in.
  DuelAnswerOutcome? _outcome;
  String? _pendingAnswerId;

  /// Set right after the player finishes a round, for the summary headline.
  int? _justFinishedRound;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });
    try {
      final duel = await ref.read(duelsRepositoryProvider).get(widget.duelId);
      if (!mounted) return;
      _enter(duel);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _phase = _Phase.error;
      });
    }
  }

  /// Straight into the question when it is the player's turn - unless they
  /// were just challenged and may still say no.
  void _enter(Duel duel) {
    setState(() {
      _duel = duel;
      _outcome = null;
      _pendingAnswerId = null;
      if (duel.isMyTurn && duel.nextQuestionIndex != null && !duel.canDecline) {
        _round = duel.currentRoundIndex;
        _question = duel.nextQuestionIndex!;
        _phase = _Phase.question;
      } else {
        _phase = _Phase.overview;
      }
    });
  }

  void _startRound() {
    final duel = _duel;
    if (duel == null || !duel.isMyTurn || duel.nextQuestionIndex == null) return;
    setState(() {
      _round = duel.currentRoundIndex;
      _question = duel.nextQuestionIndex!;
      _outcome = null;
      _pendingAnswerId = null;
      _justFinishedRound = null;
      _phase = _Phase.question;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/duels');
    }
  }

  Future<void> _answer(DuelAnswerOption option) async {
    final duel = _duel;
    if (duel == null || _pendingAnswerId != null || _outcome != null) return;
    setState(() => _pendingAnswerId = option.id);

    try {
      final outcome = await ref
          .read(duelsRepositoryProvider)
          .answer(
            duelId: duel.id,
            roundIndex: _round,
            questionIndex: _question,
            answerId: option.id,
          );
      ref.invalidate(duelListProvider);
      if (!mounted) return;
      setState(() {
        _duel = outcome.duel;
        _outcome = outcome;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _pendingAnswerId = null);
      AppNotice.error(context, error);
      // The duel moved on elsewhere (another device, a timeout): start over
      // from what the server says.
      if (error is DuelApiException &&
          const {
            'QUESTION_MISMATCH',
            'NOT_YOUR_TURN',
            'ANSWER_ALREADY_SUBMITTED',
            'CONCURRENCY_CONFLICT',
            'DUEL_FINISHED',
          }.contains(error.code)) {
        _load();
      }
    }
  }

  void _next() {
    final duel = _duel;
    final outcome = _outcome;
    if (duel == null || outcome == null) return;

    final sameRound = duel.isMyTurn &&
        duel.nextQuestionIndex != null &&
        duel.currentRoundIndex == _round;
    if (!outcome.roundComplete && sameRound) {
      setState(() {
        _question = duel.nextQuestionIndex!;
        _outcome = null;
        _pendingAnswerId = null;
      });
      return;
    }

    setState(() {
      _justFinishedRound = outcome.roundComplete ? _round : null;
      _outcome = null;
      _pendingAnswerId = null;
      _phase = _Phase.overview;
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.vermilion),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _runAction(Future<Duel> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final duel = await action();
      ref.invalidate(duelListProvider);
      if (!mounted) return;
      setState(() {
        _duel = duel;
        _justFinishedRound = null;
        _phase = _Phase.overview;
      });
    } catch (error) {
      if (mounted) AppNotice.error(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    final duel = _duel;
    if (duel == null) return;
    final ok = await _confirm(
      title: 'Duel afwijzen?',
      message: '${duel.opponentName} ziet dat je dit duel niet speelt.',
      confirmLabel: 'Afwijzen',
    );
    if (!ok || !mounted) return;
    await _runAction(() => ref.read(duelsRepositoryProvider).decline(duel.id));
  }

  Future<void> _forfeit() async {
    final duel = _duel;
    if (duel == null) return;
    final waiting = duel.opponent == null;
    final ok = await _confirm(
      title: waiting ? 'Duel annuleren?' : 'Opgeven?',
      message: waiting
          ? 'Er doet nog niemand mee. Het duel verdwijnt uit je lijst.'
          : 'Als je opgeeft, wint ${duel.opponentName} dit duel.',
      confirmLabel: waiting ? 'Annuleren' : 'Opgeven',
    );
    if (!ok || !mounted) return;
    await _runAction(() => ref.read(duelsRepositoryProvider).forfeit(duel.id));
  }

  Future<void> _rematch() async {
    final opponent = _duel?.opponent;
    if (opponent == null || _busy) return;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(duelsRepositoryProvider)
          .challengePlayer(opponent.id, name: opponent.name);
      ref.invalidate(duelListProvider);
      if (!mounted) return;
      context.pushReplacement('/duels/${result.duel.id}');
    } catch (error) {
      if (mounted) AppNotice.error(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareInvite() async {
    final duel = _duel;
    final token = duel?.inviteToken;
    if (duel == null || token == null || PreviewConfig.enabled) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: duelInviteMessage(token, duel.me.name),
          subject: 'Speel een duel met mij op BijbelQuiz',
        ),
      );
    } catch (_) {
      // Dismissed or no share target; nothing to do.
    }
  }

  @override
  Widget build(BuildContext context) {
    final duel = _duel;
    Widget body;
    switch (_phase) {
      case _Phase.loading:
        body = const AppLoader();
      case _Phase.error:
        body = _ErrorView(error: _error, onRetry: _load, onClose: _close);
      case _Phase.question:
        body = duel == null
            ? const AppLoader()
            : _QuestionView(
                duel: duel,
                roundIndex: _round,
                questionIndex: _question,
                outcome: _outcome,
                pendingAnswerId: _pendingAnswerId,
                onAnswer: _answer,
                onNext: _next,
                onClose: _close,
              );
      case _Phase.overview:
        body = duel == null
            ? const AppLoader()
            : _OverviewView(
                duel: duel,
                justFinishedRound: _justFinishedRound,
                busy: _busy,
                onClose: _close,
                onPlay: _startRound,
                onDecline: _decline,
                onForfeit: _forfeit,
                onRematch: _rematch,
                onShareInvite: _shareInvite,
                onNewDuel: () => context.pushReplacement('/duels/new'),
              );
    }

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(bottom: false, child: body),
    );
  }
}

// ---------------------------------------------------------------------------
// Playing a question
// ---------------------------------------------------------------------------

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.duel,
    required this.roundIndex,
    required this.questionIndex,
    required this.outcome,
    required this.pendingAnswerId,
    required this.onAnswer,
    required this.onNext,
    required this.onClose,
  });

  final Duel duel;
  final int roundIndex;
  final int questionIndex;
  final DuelAnswerOutcome? outcome;
  final String? pendingAnswerId;
  final ValueChanged<DuelAnswerOption> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final round = roundIndex < duel.rounds.length ? duel.rounds[roundIndex] : null;
    final question = outcome?.question ??
        ((round != null && questionIndex < round.questions.length)
            ? round.questions[questionIndex]
            : null);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (round == null || question == null) {
      return _ErrorView(
        error: 'Deze vraag kon niet laden.',
        onRetry: onClose,
        onClose: onClose,
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              outcome == null ? 24 + bottomInset : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BqCircleButton(
                      icon: BqIcons.close,
                      label: 'Duel verlaten',
                      onTap: onClose,
                    ),
                    const Spacer(),
                    _RoundPill(
                      label: 'Ronde ${round.number} van ${duel.totalRounds} · '
                          'vraag ${questionIndex + 1}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PlayScoreboard(duel: duel, round: round),
                const SizedBox(height: 14),
                _QuestionCard(topic: round.topic, text: question.text),
                const SizedBox(height: 14),
                _AnswerTiles(
                  question: question,
                  answered: outcome != null,
                  pendingAnswerId: pendingAnswerId,
                  meName: duel.me.name,
                  opponentName: duel.opponentName,
                  onAnswer: onAnswer,
                ),
              ],
            ),
          ),
        ),
        if (outcome != null)
          _FeedbackSheet(
            outcome: outcome!,
            bottomInset: bottomInset,
            onNext: onNext,
          ),
      ],
    );
  }
}

class _RoundPill extends StatelessWidget {
  const _RoundPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.rule),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppTheme.inkSoft,
          height: 1.1,
        ),
      ),
    );
  }
}

const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0x0F1B1A18), blurRadius: 2, offset: Offset(0, 1)),
];

/// Jij  3 - 2  Lotte - only names and the score; the per-question boxes
/// were too much information while answering (client feedback).
class _PlayScoreboard extends StatelessWidget {
  const _PlayScoreboard({required this.duel, required this.round});

  final Duel duel;
  final DuelRound round;

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: AppTheme.ink,
      height: 1.1,
    );
    final name = duel.opponentName;

    return Semantics(
      container: true,
      label: 'Stand: jij ${duel.myScore}, $name ${duel.opponentScore}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.paperRaised,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.rule),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  DuelMeAvatar(name: duel.me.name, size: 36),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Jij', style: nameStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              duel.scoreLabel,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontWeight: FontWeight.w600,
                fontSize: 26,
                height: 1,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nameStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  DuelOpponentAvatar(duel: duel, size: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.topic, required this.text});

  final String topic;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.positiveTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Text(
              topic.toUpperCase(),
              style: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.48,
                color: AppTheme.positive,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontWeight: FontWeight.w600,
              fontSize: 23,
              height: 30 / 23,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

enum _TileState { idle, pending, correct, wrongPick, faded }

/// The answers: a 2x2 grid of big tiles for short answers (as designed), one
/// tile per row when an answer is too long to sit in half the width.
class _AnswerTiles extends StatelessWidget {
  const _AnswerTiles({
    required this.question,
    required this.answered,
    required this.pendingAnswerId,
    required this.meName,
    required this.opponentName,
    required this.onAnswer,
  });

  final DuelQuestion question;
  final bool answered;
  final String? pendingAnswerId;
  final String meName;
  final String opponentName;
  final ValueChanged<DuelAnswerOption> onAnswer;

  _TileState _stateOf(DuelAnswerOption option) {
    if (!answered) {
      return option.id == pendingAnswerId ? _TileState.pending : _TileState.idle;
    }
    if (option.id == question.correctAnswerId) return _TileState.correct;
    if (option.id == question.myAnswerId) return _TileState.wrongPick;
    return _TileState.faded;
  }

  @override
  Widget build(BuildContext context) {
    final answers = question.answers;
    final compact = answers.length <= 4 &&
        answers.every((answer) => answer.text.length <= 14);

    Widget tile(DuelAnswerOption option) => _AnswerTile(
      option: option,
      state: _stateOf(option),
      compact: compact,
      mine: answered && option.id == question.myAnswerId,
      theirs: answered && option.id == question.opponentAnswerId,
      meName: meName,
      opponentName: opponentName,
      onTap: (answered || pendingAnswerId != null) ? null : () => onAnswer(option),
    );

    if (!compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < answers.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            tile(answers[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < answers.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tile(answers[i])),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < answers.length
                    ? tile(answers[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.option,
    required this.state,
    required this.compact,
    required this.mine,
    required this.theirs,
    required this.meName,
    required this.opponentName,
    required this.onTap,
  });

  final DuelAnswerOption option;
  final _TileState state;
  final bool compact;
  final bool mine;
  final bool theirs;
  final String meName;
  final String opponentName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color edge, Color fg) = switch (state) {
      _TileState.idle => (
        AppTheme.paperRaised,
        AppTheme.rule,
        AppTheme.ruleStrong,
        AppTheme.ink,
      ),
      _TileState.pending => (
        AppTheme.lapisTint,
        AppTheme.lapis,
        AppTheme.lapis,
        AppTheme.lapisStrong,
      ),
      _TileState.correct => (
        AppTheme.positive,
        AppTheme.positiveDeep,
        AppTheme.positiveDeep,
        AppTheme.inkInverted,
      ),
      _TileState.wrongPick => (
        AppTheme.coralTint,
        AppTheme.coralLine,
        AppTheme.coral,
        AppTheme.vermilion,
      ),
      _TileState.faded => (
        AppTheme.paperRaised,
        AppTheme.rule,
        AppTheme.ruleStrong,
        duelWrongFill,
      ),
    };

    final icon = switch (state) {
      _TileState.correct => BqIcons.check,
      _TileState.wrongPick => BqIcons.close,
      _ => null,
    };

    final textStyle = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontWeight: FontWeight.w800,
      fontSize: compact ? 20 : 16,
      height: compact ? 1.15 : 1.3,
      color: fg,
    );

    final content = Row(
      mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          BqIcon(icon, size: compact ? 20 : 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            option.text,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: textStyle,
          ),
        ),
      ],
    );

    final semanticParts = <String>[
      option.text,
      if (mine) 'jouw antwoord',
      if (theirs) 'gekozen door $opponentName',
      if (state == _TileState.correct) 'goed',
      if (state == _TileState.wrongPick) 'fout',
    ];

    final tile = Semantics(
      button: onTap != null,
      label: semanticParts.join(', '),
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 76 : 56),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 16,
              vertical: compact ? 10 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border(
                top: BorderSide(color: border),
                left: BorderSide(color: border),
                right: BorderSide(color: border),
                bottom: BorderSide(color: edge, width: 3),
              ),
            ),
            alignment: compact ? Alignment.center : Alignment.centerLeft,
            child: content,
          ),
        ),
      ),
    );

    if (!mine && !theirs) return tile;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        if (mine)
          Positioned(
            top: -9,
            right: -6,
            child: DuelPickMarker(name: meName, isMe: true),
          ),
        if (theirs)
          Positioned(
            top: -9,
            right: mine ? null : -6,
            left: mine ? -6 : null,
            child: DuelPickMarker(name: opponentName, isMe: false),
          ),
      ],
    );
  }
}

/// The white sheet after an answer: Goed!/Helaas!, XP, the explanation, the
/// reference (tap to read it) and "Volgende vraag".
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({
    required this.outcome,
    required this.bottomInset,
    required this.onNext,
  });

  final DuelAnswerOutcome outcome;
  final double bottomInset;
  final VoidCallback onNext;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  bool _verseOpen = false;

  @override
  void didUpdateWidget(covariant _FeedbackSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outcome.questionIndex != widget.outcome.questionIndex ||
        oldWidget.outcome.roundIndex != widget.outcome.roundIndex) {
      _verseOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outcome = widget.outcome;
    final question = outcome.question;
    final correct = outcome.isCorrect;
    final reference = question.bibleReference;
    final explanation = question.explanation;
    final xp = question.xpEarned;

    String? rightAnswer;
    if (!correct) {
      for (final option in question.answers) {
        if (option.id == question.correctAnswerId) rightAnswer = option.text;
      }
    }

    const bodyStyle = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      height: 22 / 15,
      color: Color(0xFF3E3C37),
    );

    return Semantics(
      container: true,
      label: correct ? 'Goed antwoord' : 'Fout antwoord',
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.paperRaised,
          border: Border(top: BorderSide(color: AppTheme.rule)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F1B1A18),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 22 + widget.bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: correct ? AppTheme.positive : AppTheme.coralDeep,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: BqIcon(
                    correct ? BqIcons.check : BqIcons.close,
                    size: 18,
                    color: AppTheme.inkInverted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    correct ? 'Goed!' : 'Helaas!',
                    style: TextStyle(
                      fontFamily: AppTheme.displayFontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      height: 1.1,
                      color: correct ? AppTheme.positiveText : AppTheme.vermilion,
                    ),
                  ),
                ),
                if (xp > 0) _XpPill(xp: xp),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rightAnswer != null) ...[
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Het goede antwoord is '),
                            TextSpan(
                              text: rightAnswer,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        style: bodyStyle,
                      ),
                      if (explanation != null) const SizedBox(height: 6),
                    ],
                    if (explanation != null) Text(explanation, style: bodyStyle),
                    if (reference != null) ...[
                      const SizedBox(height: 12),
                      _ReferenceChip(
                        reference: reference,
                        open: _verseOpen,
                        onTap: () => setState(() => _verseOpen = !_verseOpen),
                      ),
                      if (_verseOpen) ...[
                        const SizedBox(height: 10),
                        _VerseBox(reference: reference),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            BqButton(
              label: outcome.roundComplete ? 'Bekijk de stand' : 'Volgende vraag',
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
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
            '+$xp XP',
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.goldText,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Lees Richteren 7:7" - opens the verse text right below.
class _ReferenceChip extends StatelessWidget {
  const _ReferenceChip({
    required this.reference,
    required this.open,
    required this.onTap,
  });

  final String reference;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: open ? 'Verberg $reference' : 'Lees $reference',
      excludeSemantics: true,
      child: Material(
        color: AppTheme.lapisTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: ConstrainedBox(
            // The chip is 30 high in the design; the tap area is not.
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BqIcon(BqIcons.book, size: 14, color: AppTheme.lapis),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      open ? 'Verberg $reference' : 'Lees $reference',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.lapis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerseBox extends ConsumerWidget {
  const _VerseBox({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(bibleVerseProvider(reference));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.paperSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.rule),
      ),
      child: verse.when(
        loading: () => const AppLoader(size: 18),
        error: (_, _) => const Text(
          'De tekst kon niet worden opgehaald.',
          style: AppTheme.caption,
        ),
        data: (value) {
          if (value == null) {
            return const Text(
              'De tekst kon niet worden opgehaald.',
              style: AppTheme.caption,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${value.text}”',
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${value.reference} - Statenvertaling',
                style: AppTheme.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview: after a round, while waiting, and once it is over
// ---------------------------------------------------------------------------

class _OverviewView extends StatelessWidget {
  const _OverviewView({
    required this.duel,
    required this.justFinishedRound,
    required this.busy,
    required this.onClose,
    required this.onPlay,
    required this.onDecline,
    required this.onForfeit,
    required this.onRematch,
    required this.onShareInvite,
    required this.onNewDuel,
  });

  final Duel duel;
  final int? justFinishedRound;
  final bool busy;
  final VoidCallback onClose;
  final VoidCallback onPlay;
  final VoidCallback onDecline;
  final VoidCallback onForfeit;
  final VoidCallback onRematch;
  final VoidCallback onShareInvite;
  final VoidCallback onNewDuel;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      children: [
        Row(
          children: [
            BqCircleButton(
              icon: BqIcons.chevronLeft,
              label: 'Terug naar duels',
              onTap: onClose,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                duel.opponent == null
                    ? 'Nieuw duel'
                    : 'Duel met ${duel.opponentName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.displayTitle.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BqCard(
          radius: 18,
          borderColor: duel.isMyTurn ? AppTheme.coralLine : AppTheme.rule,
          borderWidth: duel.isMyTurn ? 1.5 : 1,
          child: DuelVersus(duel: duel),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          duel: duel,
          justFinishedRound: justFinishedRound,
          busy: busy,
          onPlay: onPlay,
          onClose: onClose,
          onDecline: onDecline,
          onRematch: onRematch,
          onShareInvite: onShareInvite,
          onNewDuel: onNewDuel,
        ),
        const SizedBox(height: 16),
        const DuelSectionTitle(title: 'Rondes'),
        const SizedBox(height: 8),
        BqListCard(
          children: [
            for (final round in duel.rounds)
              _RoundRow(
                round: round,
                opponentName: duel.opponentName,
                current: !duel.isFinished && round.index == duel.currentRoundIndex,
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Een leeg vakje is nog niet gespeeld. De antwoorden van je '
          'tegenstander zie je zodra jij dezelfde vraag hebt gespeeld.',
          style: AppTheme.caption,
        ),
        if (duel.canForfeit) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: busy ? null : onForfeit,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.vermilion,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                duel.opponent == null ? 'Duel annuleren' : 'Opgeven',
              ),
            ),
          ),
        ],
        if (duel.isFinished) ...[
          const SizedBox(height: 20),
          // The duel is over: the home tab replaces this screen (`go`), so
          // back does not return to it.
          BqButton(
            key: const ValueKey('duel-finished-home'),
            label: 'Terug naar home',
            style: BqButtonStyle.secondary,
            icon: const BqIcon(BqIcons.home, size: 18),
            onPressed: () => context.go('/home'),
          ),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.duel,
    required this.justFinishedRound,
    required this.busy,
    required this.onPlay,
    required this.onClose,
    required this.onDecline,
    required this.onRematch,
    required this.onShareInvite,
    required this.onNewDuel,
  });

  final Duel duel;
  final int? justFinishedRound;
  final bool busy;
  final VoidCallback onPlay;
  final VoidCallback onClose;
  final VoidCallback onDecline;
  final VoidCallback onRematch;
  final VoidCallback onShareInvite;
  final VoidCallback onNewDuel;

  @override
  Widget build(BuildContext context) {
    final name = duel.opponentName;
    String title;
    String body;
    final actions = <Widget>[];

    void addButton(Widget button) {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 8));
      actions.add(button);
    }

    final finishedRound = justFinishedRound;
    String? roundLine;
    if (finishedRound != null && finishedRound < duel.rounds.length) {
      final round = duel.rounds[finishedRound];
      roundLine = 'Ronde ${round.number} klaar: ${round.myScore} van '
          '${round.myResults.length} goed';
    }

    if (duel.isFinished) {
      switch (duel.endReason) {
        case 'declined':
          title = duel.isChallenger ? '$name wees het duel af' : 'Je wees dit duel af';
          body = 'Dit duel telt niet mee voor je stand.';
        case 'cancelled':
          title = 'Duel geannuleerd';
          body = 'Er deed niemand mee, dus dit duel telt niet mee.';
        case 'expired':
          title = 'Duel verlopen';
          body = 'Er is een week niet gespeeld. Dit duel telt niet mee.';
        default:
          switch (duel.outcome) {
            case DuelOutcome.won:
              title = 'Gewonnen!';
            case DuelOutcome.lost:
              title = 'Verloren';
            case DuelOutcome.tie:
              title = 'Gelijkspel';
            case null:
              title = 'Afgelopen';
          }
          final reason = switch (duel.endReason) {
            'forfeit' => duel.outcome == DuelOutcome.won
                ? '$name gaf op. '
                : 'Je gaf op. ',
            'timeout' => duel.outcome == DuelOutcome.won
                ? '$name speelde een week niet. '
                : 'Je speelde een week niet. ',
            _ => '',
          };
          body = '${reason}Eindstand ${duel.scoreLabel}.'
              '${duel.xpEarned > 0 ? ' Je verdiende ${duel.xpEarned} XP in dit duel.' : ''}';
      }
      if (roundLine != null) body = '$roundLine. $body';
      if (duel.opponent != null) {
        addButton(
          BqButton(
            label: 'Revanche',
            style: BqButtonStyle.coral,
            height: 48,
            loading: busy,
            onPressed: busy ? null : onRematch,
          ),
        );
      }
      addButton(
        BqButton(
          label: 'Nieuw duel',
          style: duel.opponent == null ? BqButtonStyle.primary : BqButtonStyle.secondary,
          height: 48,
          onPressed: busy ? null : onNewDuel,
        ),
      );
    } else if (duel.isMyTurn) {
      final round = duel.currentRoundData;
      if (duel.canDecline) {
        title = '$name daagt je uit';
        body = '3 rondes van 3 vragen, om de beurt. '
            'Ronde ${duel.currentRound} gaat over ${round?.topic ?? 'de Bijbel'}.';
      } else {
        title = roundLine ?? 'Jij bent aan de beurt';
        body = roundLine != null
            ? 'Je speelt ook ronde ${duel.currentRound}'
                '${round != null ? ', over ${round.topic}' : ''}.'
            : 'Ronde ${duel.currentRound} van ${duel.totalRounds}'
                '${round != null ? ' gaat over ${round.topic}' : ''}.';
      }
      addButton(
        BqButton(
          label: 'Speel ronde ${duel.currentRound}',
          style: BqButtonStyle.coral,
          height: 48,
          onPressed: busy ? null : onPlay,
        ),
      );
      if (duel.canDecline) {
        addButton(
          BqButton(
            label: 'Afwijzen',
            style: BqButtonStyle.secondary,
            height: 48,
            loading: busy,
            onPressed: busy ? null : onDecline,
          ),
        );
      }
    } else if (duel.turn == DuelTurn.matching) {
      final invite = duel.mode == 'invite';
      title = roundLine ?? (invite ? 'Wacht tot je vriend meedoet' : 'We zoeken een tegenstander');
      body = invite
          ? 'Zodra iemand je link opent en meedoet, speelt die dezelfde '
                'vragen. Je vriend speelt dit duel gratis.'
          : 'Zodra iemand anders een willekeurig duel start, spelen jullie '
                'tegen elkaar. Kijk later in Duels hoe het staat.';
      if (roundLine != null) {
        body = (invite ? 'Nu is het wachten tot je vriend meedoet. ' : 'Nu zoeken we een tegenstander. ') + body;
      }
      if (invite && duel.inviteToken != null) {
        addButton(
          BqButton(
            label: 'Deel de link opnieuw',
            style: BqButtonStyle.tint,
            height: 48,
            icon: const BqIcon(BqIcons.share, size: 18),
            onPressed: onShareInvite,
          ),
        );
      }
      addButton(
        BqButton(
          label: 'Terug naar duels',
          style: BqButtonStyle.secondary,
          height: 48,
          onPressed: onClose,
        ),
      );
    } else {
      title = roundLine ?? '$name is aan de beurt';
      body = roundLine != null
          ? 'Nu is $name aan de beurt voor ronde ${duel.currentRound}. '
                'Kijk later in Duels hoe het staat.'
          : '$name speelt ronde ${duel.currentRound}. Jullie spelen om de '
                'beurt, dus je hoeft niet tegelijk online te zijn.';
      addButton(
        BqButton(
          label: 'Terug naar duels',
          height: 48,
          onPressed: onClose,
        ),
      );
    }

    return BqCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTheme.displayTitle),
          const SizedBox(height: 6),
          Text(body, style: AppTheme.bodyMuted),
          if (actions.isNotEmpty) ...[const SizedBox(height: 14), ...actions],
        ],
      ),
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({
    required this.round,
    required this.opponentName,
    required this.current,
  });

  final DuelRound round;
  final String opponentName;
  final bool current;

  @override
  Widget build(BuildContext context) {
    const whoStyle = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppTheme.inkMuted,
    );

    return Semantics(
      container: true,
      label: 'Ronde ${round.number}, ${round.topic}: '
          '${duelMarksLabel('jij', round.myResults)}, '
          '${duelMarksLabel(opponentName, round.opponentResults)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ronde ${round.number}',
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: current ? AppTheme.coralDeep : AppTheme.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    round.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Jij', style: whoStyle),
                    const SizedBox(width: 6),
                    DuelMarkRow(marks: round.myResults),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 90),
                      child: Text(
                        opponentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: whoStyle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    DuelMarkRow(marks: round.opponentResults),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onClose,
  });

  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BqCircleButton(
            icon: BqIcons.chevronLeft,
            label: 'Terug naar duels',
            onTap: onClose,
          ),
        ),
        const SizedBox(height: 60),
        AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Duel kon niet laden',
          description: error?.toString(),
          action: BqButton(
            label: 'Opnieuw proberen',
            style: BqButtonStyle.secondary,
            expand: false,
            onPressed: onRetry,
          ),
        ),
      ],
    );
  }
}
