import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../profile/present/profile_provider.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerLobbyScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() =>
      _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState
    extends ConsumerState<MultiplayerLobbyScreen> {
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

        if (room.status == MultiplayerRoomStatus.inProgress ||
            room.status == MultiplayerRoomStatus.questionResult) {
          context.go('/play-together/room/${room.code}/play');
          return;
        }

        if (room.status == MultiplayerRoomStatus.finished) {
          context.go('/play-together/room/${room.code}/results');
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/play-together'),
        ),
        title: const Text('WACHTKAMER', style: AppTheme.overline),
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
    final controller = ref.read(
      multiplayerSessionControllerProvider(widget.roomCode).notifier,
    );

    final profileAsync = ref.watch(profileProvider);
    final currentUserId = profileAsync.maybeWhen(
      data: (profile) => profile.id,
      orElse: () => '',
    );

    final isHost = currentUserId.isNotEmpty && currentUserId == room.hostUserId;
    final canStart = isHost && room.players.length >= 2;

    return RefreshIndicator(
      color: AppTheme.ink,
      backgroundColor: AppTheme.paperRaised,
      onRefresh: () => controller.refreshRoom(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _buildRoomInfo(room),
          const SizedBox(height: 40),
          SectionHeader(
            eyebrow: 'Deelnemers',
            title: '${room.players.length} in de kamer',
          ),
          const SizedBox(height: 24),
          _buildPlayerList(room),
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
          const SizedBox(height: 28),
          if (isHost)
            SiteButton(
              label: canStart ? 'Start quiz' : 'Minimaal 2 spelers nodig',
              trailingIcon: canStart ? Icons.arrow_forward : null,
              onPressed: canStart ? () => controller.startMatch() : null,
            )
          else
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: AppTheme.inkMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Wacht tot de host de quiz start.',
                      style: AppTheme.bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SiteOutlineButton(
            label: 'Verlaat kamer',
            onPressed: () async {
              await controller.leaveRoom();
              if (!context.mounted) return;
              context.go('/play-together');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(MultiplayerRoom room) {
    final questionCount = room.totalQuestions > 0
        ? '${room.totalQuestions}'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Kamer'),
        const SizedBox(height: 16),
        Text(
          room.quizTitle.isEmpty ? 'Multiplayer quiz' : room.quizTitle,
          style: AppTheme.displayLarge,
        ),
        const SizedBox(height: 24),
        StatStrip(
          stacked: true,
          items: [
            StatItem(value: questionCount, label: 'Vragen'),
            StatItem(value: '${room.xpReward}', label: 'XP'),
            StatItem(
              value: '${room.players.length}/${room.maxPlayers}',
              label: 'Spelers',
              ruleColor: AppTheme.positive,
            ),
          ],
        ),
        const SizedBox(height: 28),
        // The room code is the page's data centrepiece — serif, tracked out.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lapisTint,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KAMERCODE',
                style: AppTheme.overline.copyWith(color: AppTheme.lapis),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.code,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFontName,
                        fontSize: 32,
                        letterSpacing: 7,
                        height: 1,
                        color: AppTheme.ink,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  SiteOutlineButton(
                    label: 'Kopieer',
                    icon: Icons.copy,
                    expand: false,
                    height: 36,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: room.code));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kamercode gekopieerd.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerList(MultiplayerRoom room) {
    return RuleGrid(
      children: [
        for (var i = 0; i < room.players.length; i++)
          _PlayerRow(player: room.players[i], rank: i + 1),
      ],
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
}

/// Player row, matching the leaderboard row: square rank badge, hairline rule.
class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.rank});

  final MultiplayerPlayer player;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isOffline = !player.isConnected;

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
              color: AppTheme.paperSunken,
              border: Border.all(color: AppTheme.rule),
            ),
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontSize: 14,
                color: AppTheme.inkSoft,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name.isEmpty ? 'Speler' : player.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStrong.copyWith(
                          color: isOffline ? AppTheme.inkMuted : AppTheme.ink,
                        ),
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 10),
                      SiteBadge.lapis('Host'),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  isOffline ? 'OFFLINE' : 'VERBONDEN',
                  style: AppTheme.overline.copyWith(
                    color: isOffline ? AppTheme.inkMuted : AppTheme.positive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${player.score}',
            style: AppTheme.statNumber.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
