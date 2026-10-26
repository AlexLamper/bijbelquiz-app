import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/preview_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../data/duels_repository.dart';
import '../domain/duel.dart';
import 'widgets/duel_widgets.dart';

/// Number of duels waiting for the player's turn - drives the tab badge.
///
/// 0 for guests, while loading and when the list failed: a badge is a nudge,
/// never an error surface.
final duelsTurnCountProvider = Provider<int>((ref) {
  return ref.watch(duelListProvider).asData?.value.turnCount ?? 0;
});

/// Duels tab - BijbelQuiz 2.0 (`R-Duels`).
///
/// Title with the win/loss record, "Nieuw duel", then the three sections:
/// Jouw beurt (a scoreboard card per duel), Wachten op tegenstander and
/// Afgelopen (list rows with a score box).
class DuelsScreen extends ConsumerStatefulWidget {
  const DuelsScreen({super.key});

  @override
  ConsumerState<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends ConsumerState<DuelsScreen> {
  @override
  void initState() {
    super.initState();
    // The list is kept alive for the tab badge, so it can be minutes old by
    // the time the tab opens. Refresh quietly; the old list stays on screen.
    Future.microtask(() {
      if (!mounted) return;
      final current = ref.read(duelListProvider);
      if (current.hasValue && !current.isLoading) ref.invalidate(duelListProvider);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(duelListProvider);
    try {
      await ref.read(duelListProvider.future);
    } catch (_) {
      // The error state below already says so.
    }
  }

  void _openDuel(Duel duel) => context.push('/duels/${duel.id}');

  @override
  Widget build(BuildContext context) {
    final signedIn =
        PreviewConfig.enabled ||
        (ref.watch(hasSessionProvider).asData?.value ?? true);

    if (!signedIn) {
      return SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const BqPageTitle('Duels'),
            const SizedBox(height: 16),
            DuelLoginCard(
              onLogin: () => context.push('/login'),
              onRegister: () => context.push('/register'),
            ),
          ],
        ),
      );
    }

    final listAsync = ref.watch(duelListProvider);
    final list = listAsync.asData?.value;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppTheme.lapis,
        backgroundColor: AppTheme.paperRaised,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            BqPageTitle(
              'Duels',
              trailing: list == null ? null : DuelRecordPill(record: list.record),
            ),
            const SizedBox(height: 16),
            BqButton(
              label: 'Nieuw duel',
              icon: const BqIcon(BqIcons.swords, size: 20),
              onPressed: () => context.push('/duels/new'),
            ),
            const SizedBox(height: 16),
            ...listAsync.when(
              skipLoadingOnRefresh: true,
              data: _sections,
              loading: () => const [SizedBox(height: 120), AppLoader()],
              error: (error, _) => [
                AppEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Duels konden niet laden',
                  description: error.toString(),
                  action: BqButton(
                    label: 'Opnieuw proberen',
                    style: BqButtonStyle.secondary,
                    expand: false,
                    onPressed: _refresh,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(DuelList list) {
    if (list.isEmpty) return const [_EmptyDuels()];

    final children = <Widget>[];
    void gap() {
      if (children.isNotEmpty) children.add(const SizedBox(height: 16));
    }

    if (list.myTurn.isNotEmpty) {
      gap();
      children.add(DuelSectionTitle(title: 'Jouw beurt', count: list.myTurn.length));
      for (final duel in list.myTurn) {
        children
          ..add(const SizedBox(height: 8))
          ..add(_TurnCard(duel: duel, onPlay: () => _openDuel(duel)));
      }
    }

    if (list.waiting.isNotEmpty) {
      gap();
      children
        ..add(const DuelSectionTitle(title: 'Wachten op tegenstander'))
        ..add(const SizedBox(height: 8))
        ..add(
          BqListCard(
            children: [
              for (final duel in list.waiting)
                _DuelRow(duel: duel, onTap: () => _openDuel(duel)),
            ],
          ),
        );
    }

    if (list.finished.isNotEmpty) {
      gap();
      children
        ..add(const DuelSectionTitle(title: 'Afgelopen'))
        ..add(const SizedBox(height: 8))
        ..add(
          BqListCard(
            children: [
              for (final duel in list.finished)
                _DuelRow(duel: duel, onTap: () => _openDuel(duel)),
            ],
          ),
        );
    }

    return children;
  }
}

/// "Jouw beurt" card: Jij vs opponent, the big score, round dots and the
/// coral "Speel ronde N" button.
class _TurnCard extends StatelessWidget {
  const _TurnCard({required this.duel, required this.onPlay});

  final Duel duel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      radius: 18,
      borderColor: AppTheme.coralLine,
      borderWidth: 1.5,
      onTap: onPlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DuelVersus(duel: duel),
          const SizedBox(height: 14),
          BqButton(
            label: 'Speel ronde ${duel.currentRound}',
            style: BqButtonStyle.coral,
            height: 48,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

/// A row under "Wachten op tegenstander" or "Afgelopen".
class _DuelRow extends StatelessWidget {
  const _DuelRow({required this.duel, required this.onTap});

  final Duel duel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = duelStatusLine(duel);
    final showScore = duel.opponent != null &&
        !(duel.isFinished &&
            (duel.endReason == 'declined' ||
                duel.endReason == 'cancelled' ||
                duel.endReason == 'expired'));

    return BqListRow(
      leading: DuelOpponentAvatar(duel: duel, size: 40),
      title: duel.opponentName,
      subtitle: status.text,
      subtitleColor: status.color,
      trailing: showScore
          ? DuelScoreBox(
              label: duel.scoreLabel,
              won: duel.outcome == DuelOutcome.won,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _EmptyDuels extends StatelessWidget {
  const _EmptyDuels();

  @override
  Widget build(BuildContext context) {
    return const BqCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BqIconTile(
            background: AppTheme.coralTint,
            size: 48,
            radius: 14,
            child: BqIcon(BqIcons.swords, size: 24, color: AppTheme.coralDeep),
          ),
          SizedBox(height: 14),
          Text('Nog geen duels', style: AppTheme.displayTitle),
          SizedBox(height: 6),
          Text(
            'Daag een vriend uit of speel tegen een willekeurige speler. Jullie '
            'spelen om de beurt, dus je hoeft niet tegelijk online te zijn.',
            style: AppTheme.bodyMuted,
          ),
        ],
      ),
    );
  }
}
