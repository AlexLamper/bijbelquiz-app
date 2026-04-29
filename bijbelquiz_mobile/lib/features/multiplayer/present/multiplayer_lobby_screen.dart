import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text(
          'Wachtkamer',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: sessionAsync.when(
          data: (session) => _buildContent(context, session),
          loading: () => const Center(child: CircularProgressIndicator()),
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
      onRefresh: () => controller.refreshRoom(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          _buildRoomInfo(room),
          const SizedBox(height: 14),
          _buildPlayerList(room),
          if (session.lastError != null) ...[
            const SizedBox(height: 14),
            Text(
              session.lastError!,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (isHost)
            ElevatedButton.icon(
              onPressed: canStart ? () => controller.startMatch() : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                canStart
                    ? 'Start quiz'
                    : 'Minimaal 2 spelers nodig om te starten',
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: AppTheme.muted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wacht tot de host de quiz start.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await controller.leaveRoom();
              if (!context.mounted) return;
              context.go('/play-together');
            },
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Verlaat kamer'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(MultiplayerRoom room) {
    final questionCount = room.totalQuestions > 0 ? room.totalQuestions : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.quizTitle.isEmpty ? 'Multiplayer Quiz' : room.quizTitle,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.sansFontName,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: Icons.help_outline_rounded,
                text: '$questionCount vragen',
              ),
              _MetaPill(
                icon: Icons.bolt_rounded,
                text: '${room.xpReward} XP beloning',
              ),
              _MetaPill(
                icon: Icons.groups_2_rounded,
                text: '${room.players.length}/${room.maxPlayers} spelers',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCDD9F6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kamercode',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        room.code,
                        style: AppTheme.monoTextStyle(
                          const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: room.code));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kamercode gekopieerd.')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Kopieer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(MultiplayerRoom room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              'Spelers in de kamer',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...room.players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final isOffline = !player.isConnected;

            return Container(
              decoration: BoxDecoration(
                border: index == room.players.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppTheme.border),
                      ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOffline
                      ? const Color(0xFFD1D5DB)
                      : AppTheme.accent,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name.isEmpty ? 'Speler' : player.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (player.isHost)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: AppTheme.warning,
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  isOffline ? 'Offline' : 'Verbonden',
                  style: TextStyle(
                    color: isOffline ? const Color(0xFF9CA3AF) : AppTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  '${player.score} pt',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(
                      multiplayerSessionControllerProvider(
                        widget.roomCode,
                      ).notifier,
                    )
                    .refreshRoom(showLoading: true);
              },
              child: const Text('Opnieuw proberen'),
            ),
          ],
        ),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}