import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../groups/data/player_group_repository.dart';
import '../../profile/present/profile_provider.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_session_controller.dart';
import 'widgets/mp_ui.dart';

/// Eindstand of a group game: a podium for the top three in the style of the
/// Ranglijst tab, the full ranking below it, the offer to keep the group, and
/// the way out.
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
  bool _leaving = false;
  String? _savedGroupName;

  MultiplayerSessionController get _controller => ref.read(
    multiplayerSessionControllerProvider(widget.roomCode).notifier,
  );

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
      body: SafeArea(
        bottom: false,
        child: sessionAsync.when(
          data: (session) {
            if (!_requestedResults && session.leaderboard.isEmpty) {
              _requestedResults = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _controller.loadResults();
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

    final room = session.room;
    final currentUserId = ref.watch(profileProvider).asData?.value.id ?? '';
    final quizTitle = room.quizTitle.isEmpty ? 'Quiz voltooid' : room.quizTitle;
    final playerCount = sorted.isNotEmpty ? sorted.length : room.players.length;
    final winner = sorted.isEmpty ? null : sorted.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        const Text('Eindstand', style: AppTheme.displayLarge),
        const SizedBox(height: 2),
        Row(
          children: [
            const BqIcon(BqIcons.trophy, size: 16, color: AppTheme.goldText),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                playerCount > 0
                    ? '$quizTitle · $playerCount '
                          '${playerCount == 1 ? 'speler' : 'spelers'}'
                    : quizTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sorted.isEmpty)
          const BqCard(
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppTheme.lapis,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resultaten worden geladen…',
                    style: AppTheme.bodyLead,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Semantics(
            label: winner == null
                ? null
                : 'Winnaar: ${_nameOf(winner)} met ${winner.score} punten',
            child: _Podium(top: sorted.take(3).toList()),
          ),
          // The podium blocks stand directly on the list card, as on the
          // Ranglijst tab.
          _RankingCard(
            entries: sorted,
            totalQuestions: room.totalQuestions,
            currentUserId: currentUserId,
          ),
        ],
        if (session.lastError != null) ...[
          const SizedBox(height: 16),
          MpNotice(message: session.lastError!),
        ],
        const SizedBox(height: 24),
        _buildSaveGroupPrompt(session),
        BqButton(
          label: 'Terug naar home',
          loading: _leaving,
          onPressed: () async {
            setState(() => _leaving = true);
            await _controller.leaveRoom();
            if (!context.mounted) return;
            context.go('/home');
          },
        ),
        const SizedBox(height: 12),
        MpSecondaryButton(
          label: 'Nieuwe kamer starten',
          height: 52,
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
        padding: const EdgeInsets.only(bottom: 16),
        child: BqCard(
          child: Row(
            children: [
              const BqIconTile(
                background: AppTheme.positiveTint,
                child: BqIcon(
                  BqIcons.check,
                  size: 20,
                  color: AppTheme.positive,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"$_savedGroupName" is bewaard.',
                      style: AppTheme.bodyStrong,
                    ),
                    const Text(
                      'Je vindt de stand van deze groep op de ranglijst.',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BqCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const BqIconTile(
                  child: BqIcon(BqIcons.users, size: 22, color: AppTheme.lapis),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deze groep bewaren?',
                    style: AppTheme.displayTitle.copyWith(
                      fontSize: 20,
                      height: 26 / 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dan houd je een eigen ranglijst bij met deze '
              '${session.room.players.length} spelers, en nodig je ze de '
              'volgende keer met een tik weer uit.',
              style: AppTheme.bodyLead,
            ),
            const SizedBox(height: 14),
            BqButton(
              label: 'Groep bewaren',
              style: BqButtonStyle.tint,
              height: 48,
              loading: _savingGroup,
              onPressed: _savingGroup ? null : _saveGroup,
            ),
            const SizedBox(height: 8),
            MpSecondaryButton(
              label: 'Nee, bedankt',
              height: 44,
              fontSize: 15,
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
      action: MpSecondaryButton(
        label: 'Opnieuw proberen',
        expand: false,
        height: 44,
        onPressed: () => _controller.refreshRoom(showLoading: true),
      ),
    );
  }
}

String _nameOf(MultiplayerLeaderboardEntry entry) =>
    entry.playerName.isEmpty ? 'Speler' : entry.playerName;

// ---------------------------------------------------------------------------
// Podium
// ---------------------------------------------------------------------------

class _PlaceStyle {
  const _PlaceStyle({
    required this.avatarSize,
    required this.letterSize,
    required this.medal,
    required this.text,
    required this.block,
    required this.blockHeight,
  });

  final double avatarSize;
  final double letterSize;

  /// Avatar ring and rank badge.
  final Color medal;

  /// Score and block number.
  final Color text;
  final Color block;
  final double blockHeight;

  static const gold = _PlaceStyle(
    avatarSize: 66,
    letterSize: 27,
    medal: AppTheme.gold,
    text: AppTheme.goldText,
    block: Color(0xFFF0D48A),
    blockHeight: 70,
  );

  static const silver = _PlaceStyle(
    avatarSize: 54,
    letterSize: 21,
    medal: Color(0xFFA9AFBB),
    text: Color(0xFF5C6370),
    block: Color(0xFFD5D9E1),
    blockHeight: 46,
  );

  static const bronze = _PlaceStyle(
    avatarSize: 54,
    letterSize: 21,
    medal: Color(0xFFC98A5A),
    text: Color(0xFF8A5530),
    block: Color(0xFFE6C9B1),
    blockHeight: 32,
  );
}

const String _crownSvg =
    '<svg viewBox="0 0 30 22" xmlns="http://www.w3.org/2000/svg"><path d="M3 18L5 5l6 6 4-9 4 9 6-6 2 13z" fill="#E9B12E" stroke="#A87C14" stroke-width="2" stroke-linejoin="round"/></svg>';

/// Second, first, third - first in the middle and tallest.
class _Podium extends StatelessWidget {
  const _Podium({required this.top});

  final List<MultiplayerLeaderboardEntry> top;

  @override
  Widget build(BuildContext context) {
    Widget slot(int index, int place, _PlaceStyle style) {
      if (index >= top.length) return const SizedBox.shrink();
      return _PodiumPlace(entry: top[index], place: place, style: style);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: slot(1, 2, _PlaceStyle.silver)),
          const SizedBox(width: 10),
          Expanded(child: slot(0, 1, _PlaceStyle.gold)),
          const SizedBox(width: 10),
          Expanded(child: slot(2, 3, _PlaceStyle.bronze)),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.place,
    required this.style,
  });

  final MultiplayerLeaderboardEntry entry;
  final int place;
  final _PlaceStyle style;

  @override
  Widget build(BuildContext context) {
    final name = _nameOf(entry);
    final tint = BqAvatar.tintFor(name);
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Semantics(
      label: '$place. $name, ${entry.score} punten',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (place == 1) ...[
            SvgPicture.string(_crownSvg, width: 30, height: 22),
            const SizedBox(height: 2),
          ],
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: style.avatarSize,
                height: style.avatarSize,
                decoration: BoxDecoration(
                  color: tint.$1,
                  shape: BoxShape.circle,
                  border: Border.all(color: style.medal, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFontName,
                    fontWeight: FontWeight.w600,
                    fontSize: style.letterSize,
                    height: 1,
                    color: tint.$2,
                  ),
                ),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: style.medal,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.paperRaised, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$place',
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: AppTheme.inkInverted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${entry.score} punten',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: style.text,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: style.blockHeight,
            padding: const EdgeInsets.only(top: 6),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: style.block,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              '$place',
              style: TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontWeight: FontWeight.w600,
                fontSize: 22,
                height: 1.1,
                color: style.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full ranking
// ---------------------------------------------------------------------------

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.entries,
    required this.totalQuestions,
    required this.currentUserId,
  });

  final List<MultiplayerLeaderboardEntry> entries;
  final int totalQuestions;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
            _RankingRow(
              rank: i + 1,
              entry: entries[i],
              totalQuestions: totalQuestions,
              isMe:
                  currentUserId.isNotEmpty &&
                  entries[i].playerId == currentUserId,
            ),
          ],
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.entry,
    required this.totalQuestions,
    required this.isMe,
  });

  final int rank;
  final MultiplayerLeaderboardEntry entry;
  final int totalQuestions;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final name = _nameOf(entry);
    final correct = totalQuestions > 0
        ? '${entry.correctAnswers} van $totalQuestions goed'
        : '${entry.correctAnswers} goed';
    final strong = isMe ? AppTheme.lapisStrong : AppTheme.inkSoft;

    return Semantics(
      label:
          '$rank. ${isMe ? '$name (jij)' : name}, ${entry.score} punten, '
          '$correct',
      excludeSemantics: true,
      child: Container(
        color: isMe ? AppTheme.lapisTint : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: strong,
                ),
              ),
            ),
            const SizedBox(width: 12),
            BqAvatar(
              name: name,
              background: isMe ? AppTheme.paperRaised : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong,
                  ),
                  Text(
                    correct,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isMe ? AppTheme.lapis : AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${entry.score} punten',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: strong,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
