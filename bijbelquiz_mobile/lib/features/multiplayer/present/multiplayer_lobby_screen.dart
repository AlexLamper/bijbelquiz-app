import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../premium/present/premium_upgrade_sheet.dart';
import '../../profile/present/profile_provider.dart';
import '../data/multiplayer_repository.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_action_controller.dart';
import 'multiplayer_session_controller.dart';
import 'widgets/host_setup_sheet.dart';
import 'widgets/mp_ui.dart';

/// Wachtkamer: the room code to share, the chosen quiz, who is in, and the
/// host's "Start de quiz". Polls through [multiplayerSessionControllerProvider]
/// and moves everybody on as soon as the room leaves the lobby.
class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const MultiplayerLobbyScreen({super.key, required this.roomCode});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() =>
      _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState
    extends ConsumerState<MultiplayerLobbyScreen> {
  bool _starting = false;
  bool _changingQuiz = false;

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

        if (room.status == MultiplayerRoomStatus.reading ||
            room.status == MultiplayerRoomStatus.inProgress ||
            room.status == MultiplayerRoomStatus.questionResult) {
          context.go('/play-together/room/${room.code}/play');
          return;
        }

        if (room.status == MultiplayerRoomStatus.finished) {
          context.go('/play-together/room/${room.code}/results');
        }
      },
    );

    final currentUserId =
        ref.watch(profileProvider).asData?.value.id ?? '';
    final room = sessionAsync.asData?.value.room;
    final isHost = room?.isHost(currentUserId) ?? false;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: sessionAsync.when(
          data: (session) => _buildContent(context, session, currentUserId),
          loading: () => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _header(isHost: isHost, leaveOnClose: false),
              ),
              const Expanded(child: AppLoader()),
            ],
          ),
          error: (error, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _header(isHost: isHost, leaveOnClose: false),
              ),
              Expanded(child: _buildError(context, AppError.from(error))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header({required bool isHost, required bool leaveOnClose}) {
    return MpHeader(
      title: 'Wachtkamer',
      close: true,
      buttonLabel: isHost ? 'Kamer sluiten' : 'Kamer verlaten',
      onButton: leaveOnClose
          ? () => _confirmLeave(isHost: isHost)
          : () => context.go('/play-together'),
    );
  }

  /// The close button leaves the room, so it asks first: one stray tap would
  /// otherwise hand the host role away or empty the room.
  Future<void> _confirmLeave({required bool isHost}) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isHost ? 'Kamer sluiten?' : 'Kamer verlaten?'),
        content: Text(
          isHost
              ? 'Ben je de enige, dan sluit de kamer. Zijn er al spelers, dan '
                    'wordt iemand anders host.'
              : 'Je kunt later opnieuw meedoen met dezelfde code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Blijf'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: Text(isHost ? 'Sluit kamer' : 'Verlaat kamer'),
          ),
        ],
      ),
    );

    if (leave != true || !mounted) return;
    await _controller.leaveRoom();
    if (!mounted) return;
    context.go('/play-together');
  }

  /// Starts the game, and on a spent quota offers the upgrade right here.
  ///
  /// The host is standing in front of the group at this point. Navigating them
  /// out to a paywall - and then back through the lobby list to find their own
  /// room again - is where the evening, and the sale, is lost.
  Future<void> _startMatch() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final errorCode = await _controller.startMatch();
      if (errorCode != 'PREMIUM_REQUIRED' || !mounted) return;

      final upgraded = await showPremiumUpgradeSheet(
        context,
        trigger: PaywallTrigger.hostQuotaExhausted,
        title: 'Je gratis spellen zijn op',
        message:
            'Met Premium host je onbeperkt spellen, met tot 20 spelers '
            'tegelijk. Je groep blijft gewoon in de kamer wachten.',
      );

      if (!upgraded || !mounted) return;

      // Straight back into the same room, which is still open and still full.
      ref.invalidate(multiplayerCapabilityProvider);
      await _controller.startMatch();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// "Wijzig": the server has no way to swap the quiz of an open room, so the
  /// host gets a fresh room with the new quiz and the same settings. Offered
  /// only while nobody else has joined, so no guest is left behind.
  Future<void> _changeQuiz(MultiplayerRoom room) async {
    final setup = await showHostSetupSheet(
      context,
      initialQuizId: room.quizId,
      initialMaxPlayers: room.maxPlayers,
      initialReadChapterFirst: room.readChapterFirst,
      initialQuestionTimerSeconds: room.questionTimerSeconds,
      capability: ref.read(multiplayerCapabilityProvider).asData?.value,
      showOptions: false,
      hint: 'Je krijgt een nieuwe kamercode.',
    );
    if (setup == null || !mounted || setup.quiz.id == room.quizId) return;

    setState(() => _changingQuiz = true);
    try {
      await _controller.leaveRoom();
      final fresh = await ref
          .read(multiplayerRepositoryProvider)
          .createRoom(
            quizId: setup.quiz.id,
            maxPlayers: room.maxPlayers,
            readChapterFirst: room.readChapterFirst,
            questionTimerSeconds: room.questionTimerSeconds,
          );
      ref.invalidate(multiplayerCapabilityProvider);
      if (!mounted) return;
      context.go('/play-together/room/${fresh.code}');
    } catch (error) {
      if (!mounted) return;
      AppNotice.error(context, error);
      // The old room is gone by now, so there is nothing to stay in.
      context.go('/play-together');
    } finally {
      if (mounted) setState(() => _changingQuiz = false);
    }
  }

  Widget _buildContent(
    BuildContext context,
    MultiplayerSessionState session,
    String currentUserId,
  ) {
    final room = session.room;
    final isHost = room.isHost(currentUserId);
    final minPlayers =
        ref.watch(multiplayerConfigProvider).asData?.value.minPlayersToStart ??
        MultiplayerConfig.fallback.minPlayersToStart;
    final canStart = isHost && room.players.length >= minPlayers;
    final canChangeQuiz = isHost && room.players.length <= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.lapis,
            backgroundColor: AppTheme.paperRaised,
            onRefresh: () => _controller.refreshRoom(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                _header(isHost: isHost, leaveOnClose: true),
                const SizedBox(height: 8),
                Text(
                  isHost
                      ? 'Start de quiz zodra iedereen er is.'
                      : 'De host start de quiz zodra iedereen er is.',
                  style: AppTheme.bodyLead,
                ),
                const SizedBox(height: 16),
                _RoomCodeCard(
                  code: room.code,
                  onShare: () => _shareInvite(room),
                  onCopy: () async {
                    await Clipboard.setData(ClipboardData(text: room.code));
                    if (!context.mounted) return;
                    AppNotice.success(context, 'Kamercode gekopieerd.');
                  },
                ),
                // A 44px "Wijzig" link makes the label row taller, so the
                // gaps around it shrink to keep the design's rhythm.
                SizedBox(height: canChangeQuiz ? 5 : 16),
                MpSectionLabel(
                  'Quiz',
                  trailing: canChangeQuiz
                      ? MpTextLink(
                          label: 'Wijzig',
                          onTap: _changingQuiz ? null : () => _changeQuiz(room),
                        )
                      : null,
                ),
                SizedBox(height: canChangeQuiz ? 0 : 8),
                MpQuizRow(
                  title: room.quizTitle.isEmpty
                      ? 'Multiplayer quiz'
                      : room.quizTitle,
                  subtitle: _roomSubtitle(room),
                  trailing: _changingQuiz
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                MpSectionLabel(
                  'Spelers',
                  trailing: Text(
                    '${room.players.length} van ${room.maxPlayers}',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _PlayersCard(room: room, currentUserId: currentUserId),
                if (session.lastError != null) ...[
                  const SizedBox(height: 16),
                  MpNotice(message: session.lastError!),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: isHost
              ? BqButton(
                  label: canStart
                      ? 'Start de quiz'
                      : 'Minimaal $minPlayers spelers nodig',
                  loading: _starting,
                  onPressed: canStart && !_changingQuiz ? _startMatch : null,
                )
              : const _WaitingForHost(),
        ),
      ],
    );
  }

  String _roomSubtitle(MultiplayerRoom room) {
    // The room snapshot carries no XP figure - multiplayer scores are points
    // per question, not the quiz's solo reward - so none is shown here.
    final parts = <String>[
      if (room.totalQuestions > 0)
        room.totalQuestions == 1 ? '1 vraag' : '${room.totalQuestions} vragen',
      room.questionTimerSeconds > 0
          ? '${room.questionTimerSeconds}s per vraag'
          : 'Host bepaalt het tempo',
      if (room.readChapterFirst) 'Eerst lezen',
    ];
    return parts.join(' · ');
  }

  Future<void> _shareInvite(MultiplayerRoom room) async {
    ref
        .read(analyticsProvider)
        .track(
          AnalyticsEvents.roomInviteShared,
          props: {'roomCode': room.code, 'method': 'share_sheet'},
        );

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: AppConfig.roomInviteMessage(room.code, room.quizTitle),
          subject: 'Doe mee met mijn BijbelQuiz',
        ),
      );
    } catch (_) {
      // No share target, or the sheet was killed mid-flight. The code is still
      // on screen, so there is nothing to recover from and nothing worth
      // interrupting the host with.
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

/// The big room code with "Deel code" and copy.
class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({
    required this.code,
    required this.onShare,
    required this.onCopy,
  });

  final String code;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        children: [
          const Text(
            'KAMERCODE',
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.48,
              height: 16 / 12,
              color: AppTheme.lapis,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: 'Kamercode ${code.split('').join(' ')}',
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                // Balances the trailing letter-spacing so the code centres.
                padding: const EdgeInsets.only(left: 5.6),
                child: Text(
                  code,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 48 / 40,
                    letterSpacing: 5.6,
                    color: AppTheme.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Spelers vullen deze code in bij Samen spelen',
            textAlign: TextAlign.center,
            style: AppTheme.caption,
          ),
          const SizedBox(height: 14),
          // The share sheet, not the code, is what actually fills a room: the
          // host taps once and the whole group chat gets a link. The code stays
          // above it for the people sitting in the same room.
          Row(
            children: [
              Expanded(
                child: MpSecondaryButton(
                  label: 'Deel code',
                  icon: const BqIcon(
                    BqIcons.share,
                    size: 18,
                    color: AppTheme.lapis,
                  ),
                  onPressed: onShare,
                ),
              ),
              const SizedBox(width: 8),
              MpSquareIconButton(
                icon: BqIcons.copy,
                label: 'Code kopiëren',
                onPressed: onCopy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Four-column grid of tinted letter avatars, with the "vanzelf" footnote.
class _PlayersCard extends StatelessWidget {
  const _PlayersCard({required this.room, required this.currentUserId});

  final MultiplayerRoom room;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = (constraints.maxWidth - gap * 3) / 4;
              return Wrap(
                spacing: gap,
                runSpacing: 14,
                children: [
                  for (final player in room.players)
                    SizedBox(
                      width: width,
                      child: _PlayerTile(
                        player: player,
                        isMe:
                            currentUserId.isNotEmpty &&
                            player.id == currentUserId,
                        // The room's host id is the source of truth; the
                        // per-player flag only covers a snapshot without it.
                        isHost: room.hostUserId.isNotEmpty
                            ? player.id == room.hostUserId
                            : player.isHost,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppTheme.ruleSoft),
          const SizedBox(height: 12),
          const Text(
            'Nieuwe spelers verschijnen hier vanzelf.',
            textAlign: TextAlign.center,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.isMe,
    required this.isHost,
  });

  final MultiplayerPlayer player;
  final bool isMe;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    final offline = !player.isConnected;
    final name = player.name.isEmpty ? 'Speler' : player.name;
    final shown = isMe ? 'Jij' : name;
    final label = isHost ? '$shown (host)' : shown;

    return Semantics(
      label: '$label${offline ? ', offline' : ''}',
      excludeSemantics: true,
      child: Column(
        children: [
          Opacity(
            opacity: offline ? 0.45 : 1,
            child: BqAvatar(name: name),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 18 / 13,
              color: offline ? AppTheme.inkMuted : AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// What a guest sees where the host has "Start de quiz".
class _WaitingForHost extends StatelessWidget {
  const _WaitingForHost();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.rule),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.lapis,
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Wacht tot de host de quiz start.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}
