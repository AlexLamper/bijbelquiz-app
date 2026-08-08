import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';

class MultiplayerResultsScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerResultsScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerResultsScreen> createState() =>
      _MultiplayerResultsScreenState();
}

class _MultiplayerResultsScreenState
    extends ConsumerState<MultiplayerResultsScreen> {
  bool _requestedResults = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      multiplayerSessionControllerProvider(widget.roomCode),
    );

    ref.listen<AsyncValue<MultiplayerSessionState>>(
      multiplayerSessionControllerProvider(widget.roomCode),
      (previous, next) {
        final room = next.asData?.value.room;
        if (room == null || !mounted) return;

        if (room.status == MultiplayerRoomStatus.lobby) {
          context.go('/play-together/room/${room.code}');
          return;
        }

        if (room.status == MultiplayerRoomStatus.inProgress ||
            room.status == MultiplayerRoomStatus.questionResult) {
          context.go('/play-together/room/${room.code}/play');
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('EINDRANGLIJST', style: AppTheme.overline),
      ),
      body: SafeArea(
        top: false,
        child: sessionAsync.when(
          data: (session) {
            if (!_requestedResults && session.leaderboard.isEmpty) {
              _requestedResults = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(
                      multiplayerSessionControllerProvider(
                        widget.roomCode,
                      ).notifier,
                    )
                    .loadResults();
              });
            }
            return _buildResults(context, session);
          },
          loading: () => const AppLoader(),
          error: (error, _) => _buildError(context, _toMessage(error)),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, MultiplayerSessionState session) {
    final sorted = [...session.leaderboard]
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;

        final correctCompare = b.correctAnswers.compareTo(a.correctAnswers);
        if (correctCompare != 0) return correctCompare;

        return a.playerName.toLowerCase().compareTo(b.playerName.toLowerCase());
      });

    final winner = sorted.isEmpty ? null : sorted.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        const Eyebrow('Afgerond'),
        const SizedBox(height: 16),
        Text(
          session.room.quizTitle.isEmpty
              ? 'Quiz voltooid'
              : session.room.quizTitle,
          style: AppTheme.displayLarge,
        ),
        if (winner != null) ...[
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              style: AppTheme.bodyLead,
              children: [
                const TextSpan(text: 'Winnaar: '),
                TextSpan(
                  text: winner.playerName.isEmpty
                      ? 'Speler'
                      : winner.playerName,
                  style: const TextStyle(
                    color: AppTheme.lapis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        StatStrip(
          stacked: true,
          items: [
            StatItem(value: '${sorted.length}', label: 'Spelers'),
            StatItem(
              value: winner == null ? '—' : '${winner.score}',
              label: 'Topscore',
              ruleColor: AppTheme.positive,
            ),
          ],
        ),
        const SizedBox(height: 36),
        const SectionHeader(eyebrow: 'Ranglijst', title: 'Eindstand'),
        const SizedBox(height: 24),
        if (sorted.isEmpty)
          const AppCard(
            child: Text(
              'Resultaten worden geladen…',
              style: AppTheme.bodyMuted,
            ),
          )
        else
          RuleGrid(
            children: [
              for (var i = 0; i < sorted.length; i++)
                _ResultRow(entry: sorted[i], rank: i + 1),
            ],
          ),
        if (session.lastError != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.vermilionTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.destructive.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              session.lastError!,
              style: AppTheme.bodyMuted.copyWith(color: AppTheme.destructive),
            ),
          ),
        ],
        const SizedBox(height: 32),
        SiteButton(
          label: 'Terug naar home',
          onPressed: () async {
            await ref
                .read(
                  multiplayerSessionControllerProvider(
                    widget.roomCode,
                  ).notifier,
                )
                .leaveRoom();
            if (!context.mounted) return;
            context.go('/home');
          },
        ),
        const SizedBox(height: 12),
        SiteOutlineButton(
          label: 'Nieuwe kamer starten',
          onPressed: () => context.go('/play-together'),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Resultaten niet beschikbaar',
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
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.entry, required this.rank});

  final MultiplayerLeaderboardEntry entry;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isLeader = rank == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            height: 32,
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isLeader ? AppTheme.lapisTint : AppTheme.paperSunken,
              border: Border.all(
                color: isLeader
                    ? AppTheme.lapis.withValues(alpha: 0.35)
                    : AppTheme.rule,
              ),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLeader ? AppTheme.lapis : AppTheme.inkSoft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName.isEmpty ? 'Speler' : entry.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStrong,
                ),
                const SizedBox(height: 5),
                Text('${entry.correctAnswers} GOED', style: AppTheme.overline),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.score}',
            style: AppTheme.statNumber.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
