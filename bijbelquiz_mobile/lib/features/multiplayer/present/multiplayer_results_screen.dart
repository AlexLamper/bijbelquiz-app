import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/avatar/avatar_catalog.dart';
import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../groups/data/player_group_repository.dart';
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
  bool _savingGroup = false;
  bool _groupDismissed = false;
  String? _savedGroupName;

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
          error: (error, _) => _buildError(context, AppError.from(error)),
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
              value: winner == null ? '-' : '${winner.score}',
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
                _ResultRow(
                  entry: sorted[i],
                  rank: i + 1,
                  // The results payload carries no mascot, so it is read off
                  // the room snapshot, which still holds every player.
                  avatar: session.room
                      .playerById(sorted[i].playerId)
                      ?.avatar,
                ),
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
        _buildSaveGroupPrompt(session),
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

  /// Offers to keep the people who just played.
  ///
  /// Shown here and nowhere else. This is the one moment the group provably
  /// exists, everybody's name is on screen, and nobody has walked off yet; a
  /// prompt buried in settings a week later reaches no one.
  Widget _buildSaveGroupPrompt(MultiplayerSessionState session) {
    if (session.room.players.length < 2 || _groupDismissed) {
      return const SizedBox.shrink();
    }

    if (_savedGroupName != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('"$_savedGroupName" is bewaard.', style: AppTheme.bodyStrong),
              const SizedBox(height: 6),
              Text(
                'Je vindt de stand van deze groep op de ranglijst.',
                style: AppTheme.bodyMuted,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lapisTint,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deze groep bewaren?', style: AppTheme.bodyStrong),
            const SizedBox(height: 6),
            Text(
              'Dan houd je een eigen ranglijst bij met deze '
              '${session.room.players.length} spelers, en nodig je ze de '
              'volgende keer met een tik weer uit.',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 16),
            SiteButton(
              label: 'Groep bewaren',
              loading: _savingGroup,
              onPressed: _savingGroup ? null : _saveGroup,
            ),
            const SizedBox(height: 8),
            SiteOutlineButton(
              label: 'Nee, bedankt',
              height: 40,
              onPressed: () => setState(() => _groupDismissed = true),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGroup() async {
    setState(() => _savingGroup = true);

    try {
      final group = await ref
          .read(playerGroupRepositoryProvider)
          .createFromRoom(widget.roomCode);

      // The leaderboard screen reads this list, and it is not auto-disposed,
      // so a stale copy would hide the group the user just made.
      ref.invalidate(playerGroupsProvider);

      if (!mounted) return;
      setState(() {
        _savedGroupName = group.name;
        _savingGroup = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _savingGroup = false);
      AppNotice.error(context, AppError.messageOf(error));
    }
  }

  Widget _buildError(BuildContext context, AppError error) {
    return AppEmptyState(
      icon: error.icon,
      title: error.title,
      description: error.message,
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

}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.entry,
    required this.rank,
    required this.avatar,
  });

  final MultiplayerLeaderboardEntry entry;
  final int rank;
  final AvatarConfig? avatar;

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
          const SizedBox(width: 12),
          MascotAvatar(
            avatar: avatar ?? AvatarConfig.fromSeed(entry.playerId),
            size: 36,
            bordered: true,
          ),
          const SizedBox(width: 12),
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
