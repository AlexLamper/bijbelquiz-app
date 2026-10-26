import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import '../../domain/duel.dart';

/// Small pieces shared by the three duel screens (`R-Duels`, `R-Uitdagen`,
/// `R-Duelvraag`).

/// Neutral score box and empty round dot, straight from the designs.
const Color duelNeutralFill = Color(0xFFF1EFEA);
const Color duelDotEmpty = Color(0xFFE0DDD5);
const Color duelWrongFill = Color(0xFFB4502B); // coralDeep: a wrong answer must read as wrong, not as "not played"
const Color duelRecordDivider = Color(0xFFC9C5BC);

/// The player's own avatar: solid lapis with a white letter.
class DuelMeAvatar extends StatelessWidget {
  const DuelMeAvatar({super.key, required this.name, this.size = 46});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BqAvatar(
      name: name,
      size: size,
      background: AppTheme.lapis,
      foreground: AppTheme.inkInverted,
    );
  }
}

/// The opponent's avatar, or a placeholder while nobody joined yet.
class DuelOpponentAvatar extends StatelessWidget {
  const DuelOpponentAvatar({super.key, required this.duel, this.size = 46});

  final Duel duel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final opponent = duel.opponent;
    if (opponent != null) return BqAvatar(name: opponent.name, size: size);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.lapisTint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: BqIcon(
        duel.mode == 'invite' ? BqIcons.link : BqIcons.shuffle,
        size: size * 0.42,
        color: AppTheme.lapis,
      ),
    );
  }
}

/// One question box: green check, grey cross, or empty.
class DuelMarkBox extends StatelessWidget {
  const DuelMarkBox({super.key, required this.mark, this.size = 18});

  final DuelMark mark;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (mark) {
      case DuelMark.correct:
        return _filled(AppTheme.positive, BqIcons.check, size * 0.61);
      case DuelMark.wrong:
        return _filled(duelWrongFill, BqIcons.close, size * 0.56);
      case DuelMark.pending:
      case DuelMark.hidden:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.paperRaised,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppTheme.rule, width: 2),
          ),
        );
    }
  }

  Widget _filled(Color color, String icon, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: BqIcon(icon, size: iconSize, color: AppTheme.inkInverted),
    );
  }
}

/// A row of [DuelMarkBox]es for one round.
class DuelMarkRow extends StatelessWidget {
  const DuelMarkRow({super.key, required this.marks, this.size = 18});

  final List<DuelMark> marks;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < marks.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            DuelMarkBox(mark: marks[i], size: size),
          ],
        ],
      ),
    );
  }
}

/// "Jij 2 goed, Lotte 1 goed en 1 fout" for screen readers.
String duelMarksLabel(String who, List<DuelMark> marks) {
  final good = marks.where((m) => m == DuelMark.correct).length;
  final bad = marks.where((m) => m == DuelMark.wrong).length;
  if (good == 0 && bad == 0) return '$who nog niet gespeeld';
  final parts = <String>[
    if (good > 0) '$good goed',
    if (bad > 0) '$bad fout',
  ];
  return '$who ${parts.join(' en ')}';
}

/// Round progress dots next to "Ronde 2 van 3".
class DuelRoundDots extends StatelessWidget {
  const DuelRoundDots({super.key, required this.total, required this.filled});

  final int total;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: i < filled ? AppTheme.coralDeep : duelDotEmpty,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "7 - 4" box at the end of a list row; green for a win.
class DuelScoreBox extends StatelessWidget {
  const DuelScoreBox({super.key, required this.label, this.won = false});

  final String label;
  final bool won;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: won ? AppTheme.positiveTint : duelNeutralFill,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontFamily: AppTheme.displayFontName,
          fontWeight: FontWeight.w600,
          fontSize: 17,
          height: 1,
          color: won ? AppTheme.positiveText : AppTheme.inkSoft,
        ),
      ),
    );
  }
}

/// "9 gewonnen | 4 verloren" in the Duels header.
class DuelRecordPill extends StatelessWidget {
  const DuelRecordPill({super.key, required this.record});

  final DuelRecord record;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppTheme.inkSoft,
      height: 1.1,
    );
    return Semantics(
      label: '${record.wins} gewonnen, ${record.losses} verloren',
      excludeSemantics: true,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.paperRaised,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: AppTheme.rule),
        ),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            style: base,
            children: [
              TextSpan(
                text: '${record.wins}',
                style: const TextStyle(
                  color: AppTheme.positive,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: '  gewonnen  '),
              const TextSpan(
                text: '|',
                style: TextStyle(color: duelRecordDivider),
              ),
              TextSpan(
                text: '  ${record.losses}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: '  verloren'),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small "A Jij" / "L Lotte" chip on a chosen answer tile.
class DuelPickMarker extends StatelessWidget {
  const DuelPickMarker({super.key, required this.name, required this.isMe});

  final String name;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final tint = BqAvatar.tintFor(name);
    final color = isMe ? AppTheme.lapis : tint.$2;
    return Container(
      height: 22,
      padding: const EdgeInsets.fromLTRB(3, 0, 8, 0),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BqAvatar(
            name: name,
            size: 16,
            background: isMe ? AppTheme.lapis : null,
            foreground: isMe ? AppTheme.inkInverted : null,
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 72),
            child: Text(
              isMe ? 'Jij' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One line of state for a duel row: "Daan speelt ronde 2", "Gewonnen"...
({String text, Color color}) duelStatusLine(Duel duel) {
  final name = duel.opponentName;
  if (!duel.isFinished) {
    switch (duel.turn) {
      case DuelTurn.me:
        return (text: 'Jij speelt ronde ${duel.currentRound}', color: AppTheme.inkMuted);
      case DuelTurn.matching:
        return (
          text: duel.mode == 'invite'
              ? 'Wacht tot je vriend meedoet'
              : 'We zoeken een tegenstander',
          color: AppTheme.inkMuted,
        );
      case DuelTurn.opponent:
      case DuelTurn.none:
        return (text: '$name speelt ronde ${duel.currentRound}', color: AppTheme.inkMuted);
    }
  }

  switch (duel.endReason) {
    case 'declined':
      return (
        text: duel.isChallenger ? 'Afgewezen door $name' : 'Afgewezen',
        color: AppTheme.inkMuted,
      );
    case 'cancelled':
      return (text: 'Geannuleerd', color: AppTheme.inkMuted);
    case 'expired':
      return (text: 'Verlopen', color: AppTheme.inkMuted);
    default:
      break;
  }

  final suffix = switch (duel.endReason) {
    'forfeit' => duel.outcome == DuelOutcome.won
        ? ' - $name gaf op'
        : ' - opgegeven',
    'timeout' => ' - tijd verstreken',
    _ => '',
  };
  switch (duel.outcome) {
    case DuelOutcome.won:
      return (text: 'Gewonnen$suffix', color: AppTheme.positive);
    case DuelOutcome.lost:
      return (text: 'Verloren$suffix', color: AppTheme.inkMuted);
    case DuelOutcome.tie:
      return (text: 'Gelijkspel', color: AppTheme.inkMuted);
    case null:
      return (text: 'Afgelopen', color: AppTheme.inkMuted);
  }
}

/// Section title with an optional coral count badge ("Jouw beurt 1").
class DuelSectionTitle extends StatelessWidget {
  const DuelSectionTitle({super.key, required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
              height: 1.3,
            ),
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppTheme.coralDeep,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.inkInverted,
                height: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The big "Jij 3 - 2 Lotte" block from the Duels card, reused as the header
/// of a duel's overview.
class DuelVersus extends StatelessWidget {
  const DuelVersus({super.key, required this.duel});

  final Duel duel;

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: AppTheme.ink,
      height: 1.2,
    );
    final finished = duel.isFinished;
    final roundLabel = finished
        ? 'Afgelopen'
        : 'Ronde ${duel.currentRound} van ${duel.totalRounds}';
    final dotsFilled = finished ? duel.totalRounds : duel.currentRound;

    return Semantics(
      label: 'Duel met ${duel.opponentName}, jij ${duel.myScore}, '
          '${duel.opponentName} ${duel.opponentScore}. $roundLabel',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DuelMeAvatar(name: duel.me.name),
                const SizedBox(height: 4),
                const Text('Jij', style: nameStyle),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                duel.scoreLabel,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 34,
                  height: 1,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DuelRoundDots(total: duel.totalRounds, filled: dotsFilled),
                  const SizedBox(width: 6),
                  Text(
                    roundLabel,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DuelOpponentAvatar(duel: duel),
                const SizedBox(height: 4),
                Text(
                  duel.opponentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The guest state of the duel screens: "Log in om tegen anderen te spelen".
class DuelLoginCard extends StatelessWidget {
  const DuelLoginCard({super.key, required this.onLogin, this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BqIconTile(
            background: AppTheme.coralTint,
            size: 48,
            radius: 14,
            child: BqIcon(BqIcons.swords, size: 24, color: AppTheme.coralDeep),
          ),
          const SizedBox(height: 14),
          const Text(
            'Log in om tegen anderen te spelen',
            style: AppTheme.displayTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'Daag vrienden of een willekeurige speler uit: 1 tegen 1, 3 rondes '
            'van 3 vragen, om de beurt. Met een account blijven je duels en '
            'je stand bewaard.',
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: 16),
          BqButton(label: 'Inloggen', onPressed: onLogin),
          if (onRegister != null) ...[
            const SizedBox(height: 8),
            BqButton(
              label: 'Account maken',
              style: BqButtonStyle.secondary,
              onPressed: onRegister,
            ),
          ],
        ],
      ),
    );
  }
}
