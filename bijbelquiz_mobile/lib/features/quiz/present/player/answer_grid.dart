import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../domain/answer.dart';
import 'player_widgets.dart';

/// Text on tiles that were neither picked nor correct, once answered.
const Color _dimmedText = Color(0xFF8A877F);

enum AnswerTileState { idle, correctPicked, correctRevealed, wrongPicked, dimmed }

/// The answers as chunky tiles, two per row.
///
/// Short answers ("5", "Mozes") get the design's 20px; longer ones step down
/// so they still fit two to a row, and very long answers fall back to one
/// full-width tile per row instead of wrapping into slivers.
class AnswerGrid extends StatelessWidget {
  const AnswerGrid({
    super.key,
    required this.answers,
    required this.isAnswered,
    required this.selected,
    required this.onSelect,
  });

  final List<Answer> answers;
  final bool isAnswered;

  /// The picked answer, null before answering and after a timeout.
  final Answer? selected;
  final void Function(Answer answer, int index) onSelect;

  AnswerTileState _stateFor(Answer answer) {
    if (!isAnswered) return AnswerTileState.idle;
    final picked = identical(answer, selected);
    if (answer.isCorrect) {
      return picked
          ? AnswerTileState.correctPicked
          : AnswerTileState.correctRevealed;
    }
    return picked ? AnswerTileState.wrongPicked : AnswerTileState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final longest = answers.fold<int>(
      0,
      (m, a) => math.max(m, a.text.trim().length),
    );
    final singleColumn = longest > 40;
    final fontSize = longest <= 10 ? 20.0 : (longest <= 24 ? 17.0 : 16.0);

    Widget tile(int i) => AnswerTile(
      text: answers[i].text,
      state: _stateFor(answers[i]),
      fontSize: fontSize,
      onTap: isAnswered ? null : () => onSelect(answers[i], i),
    );

    final rows = <Widget>[];
    if (singleColumn) {
      for (var i = 0; i < answers.length; i++) {
        rows.add(tile(i));
      }
    } else {
      for (var i = 0; i < answers.length; i += 2) {
        if (i + 1 >= answers.length) {
          // An odd one out spans the row rather than sitting half-empty.
          rows.add(tile(i));
          continue;
        }
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tile(i)),
                const SizedBox(width: 12),
                Expanded(child: tile(i + 1)),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 12),
          rows[r],
        ],
      ],
    );
  }
}

/// One answer: white with a border and a 3px darker bottom edge that sinks
/// when pressed; green, coral or dimmed once the question is answered.
///
/// Drawn as two layers (edge colour behind, face on top) because Flutter
/// cannot paint a rounded border whose bottom differs in colour.
class AnswerTile extends StatefulWidget {
  const AnswerTile({
    super.key,
    required this.text,
    required this.state,
    required this.fontSize,
    this.onTap,
  });

  final String text;
  final AnswerTileState state;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile> {
  bool _down = false;

  static const double _minHeight = 76;
  static const double _radius = 14;

  ({Color face, Color border, Color edge, Color fg, String? icon}) get _look {
    switch (widget.state) {
      case AnswerTileState.idle:
        return (
          face: AppTheme.paperRaised,
          border: AppTheme.rule,
          edge: AppTheme.ruleStrong,
          fg: AppTheme.ink,
          icon: null,
        );
      case AnswerTileState.dimmed:
        return (
          face: AppTheme.paperRaised,
          border: AppTheme.rule,
          edge: AppTheme.ruleStrong,
          fg: _dimmedText,
          icon: null,
        );
      case AnswerTileState.correctPicked:
        return (
          face: AppTheme.positive,
          border: AppTheme.positiveDeep,
          edge: AppTheme.positiveDeep,
          fg: AppTheme.inkInverted,
          icon: PlayerIcons.check,
        );
      case AnswerTileState.correctRevealed:
        return (
          face: AppTheme.positiveTint,
          border: AppTheme.positive,
          edge: AppTheme.positive,
          fg: AppTheme.positiveText,
          icon: PlayerIcons.check,
        );
      case AnswerTileState.wrongPicked:
        return (
          face: AppTheme.coralTint,
          border: AppTheme.coralLine,
          edge: AppTheme.coral,
          fg: AppTheme.vermilion,
          icon: PlayerIcons.cross,
        );
    }
  }

  String get _semanticSuffix {
    switch (widget.state) {
      case AnswerTileState.correctPicked:
        return ', jouw antwoord, goed';
      case AnswerTileState.correctRevealed:
        return ', het goede antwoord';
      case AnswerTileState.wrongPicked:
        return ', jouw antwoord, fout';
      case AnswerTileState.idle:
      case AnswerTileState.dimmed:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final pressed = _down && enabled;
    final edge = pressed ? 1.0 : 3.0;
    final sink = 3.0 - edge;
    final look = _look;

    final face = Container(
      decoration: BoxDecoration(
        color: look.face,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: look.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (look.icon != null) ...[
            BqIcon(look.icon!, size: widget.fontSize, color: look.fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: look.fg,
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: '${widget.text}$_semanticSuffix',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.only(top: sink),
          child: Container(
            constraints: BoxConstraints(minHeight: _minHeight - sink),
            decoration: BoxDecoration(
              color: look.edge,
              borderRadius: BorderRadius.circular(_radius),
            ),
            padding: EdgeInsets.only(bottom: edge),
            child: face,
          ),
        ),
      ),
    );
  }
}
