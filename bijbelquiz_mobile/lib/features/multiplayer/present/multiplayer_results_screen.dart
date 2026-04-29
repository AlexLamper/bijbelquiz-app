import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Eindranglijst'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: sessionAsync.when(
          data: (session) {
            if (!_requestedResults && session.leaderboard.isEmpty) {
              _requestedResults = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(
                      multiplayerSessionControllerProvider(widget.roomCode)
                          .notifier,
                    )
                    .loadResults();
              });
            }
            return _buildResults(context, session);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 36,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 10),
              Text(
                session.room.quizTitle.isEmpty
                    ? 'Quiz voltooid'
                    : session.room.quizTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (sorted.isEmpty)
          const Text(
            'Resultaten worden geladen...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          )
        else
          ...sorted.asMap().entries.map((sortedEntry) {
            final rank = sortedEntry.key + 1;
            final entry = sortedEntry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF131D2B),
                  child: Text(
                    '$rank',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  entry.playerName.isEmpty ? 'Speler' : entry.playerName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${entry.correctAnswers} goed',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  '${entry.score} pt',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            );
          }),
        if (session.lastError != null) ...[
          const SizedBox(height: 12),
          Text(
            session.lastError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB42318)),
          ),
        ],
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () async {
            await ref
                .read(
                  multiplayerSessionControllerProvider(widget.roomCode).notifier,
                )
                .leaveRoom();
            if (!context.mounted) return;
            context.go('/home');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF131D2B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Terug naar home'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            context.go('/play-together');
          },
          child: const Text('Nieuwe kamer starten'),
        ),
      ],
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
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(
                      multiplayerSessionControllerProvider(widget.roomCode)
                          .notifier,
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
