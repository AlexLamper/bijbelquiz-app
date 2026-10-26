import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';
import 'player_widgets.dart';

/// Empty segment colour from the quiz design (`#D9D6CE`).
const Color _segmentTrack = Color(0xFFD9D6CE);

/// Close button, segmented progress and "4/10".
class PlayerHeader extends StatelessWidget {
  const PlayerHeader({
    super.key,
    required this.current,
    required this.total,
    required this.onClose,
  });

  /// 1-based number of the question on screen.
  final int current;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Segments stop reading as segments past twenty or so; a long quiz gets
    // the same bar as one continuous track.
    final Widget progress = total <= 20
        ? BqSegments(total: total, done: current, track: _segmentTrack)
        : BqProgressBar(
            value: total == 0 ? 0 : current / total,
            color: AppTheme.lapis,
            track: _segmentTrack,
            height: 6,
          );

    return Row(
      children: [
        // The 44px tap target sits 2px outside the 40px circle on each side;
        // shifting it keeps the circle on the 20px page margin.
        Transform.translate(
          offset: const Offset(-2, 0),
          child: PlayerCloseButton(label: 'Quiz stoppen', onTap: onClose),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            label: 'Vraag $current van $total',
            excludeSemantics: true,
            child: progress,
          ),
        ),
        const SizedBox(width: 12),
        ExcludeSemantics(
          child: Text(
            '$current/$total',
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkSoft,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// The white question card: passage or category chip, optional countdown
/// pill, and the question in Fredoka 24.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.text,
    this.chipLabel,
    this.timer,
  });

  final String text;

  /// "Johannes 6" or the category name; hidden when the quiz has neither.
  final String? chipLabel;

  /// The countdown pill, only while the per-question timer is switched on.
  final Widget? timer;

  @override
  Widget build(BuildContext context) {
    final hasTopRow = chipLabel != null || timer != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
        boxShadow: playerCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTopRow) ...[
            Row(
              children: [
                if (chipLabel != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lapisTint,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusPill,
                        ),
                      ),
                      child: Text(
                        chipLabel!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.48,
                          height: 1.2,
                          color: AppTheme.lapisStrong,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (timer != null) ...[const SizedBox(width: 8), timer!],
              ],
            ),
            const SizedBox(height: 10),
          ],
          Semantics(
            header: true,
            child: Text(
              text,
              style: AppTheme.displayMedium.copyWith(height: 31 / 24),
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown pill in the question card's top row: one number, turning coral
/// in the last five seconds and when time is up.
class QuestionTimerPill extends StatelessWidget {
  const QuestionTimerPill({
    super.key,
    required this.label,
    required this.secondsLeft,
    required this.urgent,
    required this.timedOut,
  });

  final String label;
  final int secondsLeft;
  final bool urgent;
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final fg = urgent ? AppTheme.vermilion : AppTheme.inkSoft;
    return Semantics(
      label: timedOut ? 'Tijd om' : 'Nog $secondsLeft seconden',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: urgent ? AppTheme.coralTint : AppTheme.ruleSoft,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BqIcon(BqIcons.clock, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
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
