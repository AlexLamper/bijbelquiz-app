import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../groups/data/player_group_repository.dart';
import '../../groups/domain/player_group.dart';
import '../data/multiplayer_api_exception.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_action_controller.dart';
import 'widgets/host_setup_sheet.dart';
import 'widgets/mp_ui.dart';

/// Which button is waiting on the server, so only that one shows a spinner.
enum _Pending { create, join, invite }

/// Samen spelen: make a room as host, or join one with a code.
///
/// Reached from Quizzen and still inside the tab shell, so the Quizzen tab
/// stays lit and the back button returns there. The quiz picker and the host
/// options (room size, read the chapter first, tempo) live in a bottom sheet
/// behind "Kies een quiz".
class PlayTogetherScreen extends ConsumerStatefulWidget {
  const PlayTogetherScreen({super.key});

  @override
  ConsumerState<PlayTogetherScreen> createState() => _PlayTogetherScreenState();
}

class _PlayTogetherScreenState extends ConsumerState<PlayTogetherScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();

  /// The last host setup, so reopening the sheet starts where the host was.
  String? _selectedQuizId;

  /// Room size the host picked. Starts at the free cap, so the first thing a
  /// new host sees is a number they can actually use.
  int _maxPlayers = 4;

  /// Show the Bible chapter before the first question. The server ignores this
  /// when the quiz has no single resolvable chapter.
  bool _readChapterFirst = false;

  /// Seconds per question. `0` = the host advances every step by hand.
  int _questionTimerSeconds = 0;

  _Pending? _pending;
  String? _pendingGroupId;

  @override
  void dispose() {
    _roomCodeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  /// Opens the quiz picker + host options. With a [group], the room that comes
  /// out of it is shared with that group straight away.
  Future<void> _openHostSetup({PlayerGroup? group}) async {
    final capability = ref.read(multiplayerCapabilityProvider).asData?.value;
    final setup = await showHostSetupSheet(
      context,
      initialQuizId: _selectedQuizId,
      initialMaxPlayers: _maxPlayers,
      initialReadChapterFirst: _readChapterFirst,
      initialQuestionTimerSeconds: _questionTimerSeconds,
      capability: capability,
      confirmLabel: group == null ? 'Kamer maken' : 'Maak kamer en nodig uit',
      hint: group == null ? null : 'Daarna nodigen we ${group.name} uit.',
    );
    if (setup == null || !mounted) return;

    setState(() {
      _selectedQuizId = setup.quiz.id;
      _maxPlayers = setup.maxPlayers;
      _readChapterFirst = setup.readChapterFirst;
      _questionTimerSeconds = setup.questionTimerSeconds;
    });

    if (setup.upgradeRequested) {
      _openPlayerCapPaywall();
      return;
    }

    if (group == null) {
      await _createRoom();
    } else {
      await _reinviteGroup(group);
    }
  }

  Future<void> _createRoom() async {
    if (_selectedQuizId == null || _selectedQuizId!.isEmpty) {
      _showMessage('Selecteer eerst een quiz.');
      return;
    }

    if (_playerCapExceeded()) {
      _openPlayerCapPaywall();
      return;
    }

    setState(() => _pending = _Pending.create);
    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .createRoom(
            quizId: _selectedQuizId!,
            maxPlayers: _maxPlayers,
            readChapterFirst: _readChapterFirst,
            questionTimerSeconds: _questionTimerSeconds,
          );
      if (!mounted) return;

      // Starting the game spends a credit, so the remaining count on this
      // screen is stale the moment a room opens.
      ref.invalidate(multiplayerCapabilityProvider);
      context.push('/play-together/room/${room.code}');
    } on MultiplayerApiException catch (error) {
      if (!mounted) return;
      _showError(error);

      if (error.code == 'PREMIUM_REQUIRED') {
        ref.invalidate(multiplayerCapabilityProvider);
        context.push('/premium?reden=host_quota_exhausted');
      }
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text
        .trim()
        .replaceAll(' ', '')
        .toUpperCase();

    if (roomCode.isEmpty) {
      _showMessage('Voer een kamercode in.');
      return;
    }

    if (roomCode.length < 4) {
      _showMessage('Kamercode lijkt te kort. Controleer de code.');
      return;
    }

    _codeFocus.unfocus();
    setState(() => _pending = _Pending.join);
    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .joinRoom(roomCode: roomCode);
      if (!mounted) return;
      context.push('/play-together/room/${room.code}');
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  /// Routes to whichever screen matches the room's current phase, so resuming
  /// a game in progress does not drop the player back into the lobby.
  void _openRoom(MultiplayerRoom room) {
    final base = '/play-together/room/${room.code}';
    switch (room.status) {
      case MultiplayerRoomStatus.reading:
      case MultiplayerRoomStatus.inProgress:
      case MultiplayerRoomStatus.questionResult:
        context.push('$base/play');
      case MultiplayerRoomStatus.finished:
        context.push('$base/results');
      case MultiplayerRoomStatus.lobby:
      case MultiplayerRoomStatus.unknown:
        context.push(base);
    }
  }

  /// Opens a room and hands the group's invite straight to the share sheet.
  ///
  /// The whole value of a saved group is not having to reassemble it: one tap
  /// makes the room and puts the link in front of the same chat that played
  /// last time. It still needs a quiz, because a room without one is nothing to
  /// invite anybody to - the setup sheet asks for it first.
  Future<void> _reinviteGroup(PlayerGroup group) async {
    final quizId = _selectedQuizId;
    if (quizId == null || quizId.isEmpty) {
      _showMessage('Kies eerst een quiz, dan nodigen we ${group.name} uit.');
      return;
    }

    if (_playerCapExceeded()) {
      _openPlayerCapPaywall();
      return;
    }

    setState(() {
      _pending = _Pending.invite;
      _pendingGroupId = group.id;
    });
    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .createRoom(
            quizId: quizId,
            maxPlayers: _maxPlayers,
            readChapterFirst: _readChapterFirst,
            questionTimerSeconds: _questionTimerSeconds,
          );
      if (!mounted) return;

      ref.invalidate(multiplayerCapabilityProvider);

      ref
          .read(analyticsProvider)
          .track(
            AnalyticsEvents.roomInviteShared,
            props: {
              'roomCode': room.code,
              'method': 'share_sheet',
              'groupId': group.id,
            },
          );

      try {
        await SharePlus.instance.share(
          ShareParams(
            text: AppConfig.roomInviteMessage(room.code, room.quizTitle),
            subject: 'Doe mee met mijn BijbelQuiz',
          ),
        );
      } catch (_) {
        // No share target, or the sheet was dismissed. The room exists either
        // way and the lobby shows the code.
      }

      if (!mounted) return;
      context.push('/play-together/room/${room.code}');
    } on MultiplayerApiException catch (error) {
      if (!mounted) return;
      _showError(error);

      if (error.code == 'PREMIUM_REQUIRED') {
        ref.invalidate(multiplayerCapabilityProvider);
        context.push('/premium?reden=host_quota_exhausted');
      }
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _pending = null;
          _pendingGroupId = null;
        });
      }
    }
  }

  /// Whether the picked room size is above what this account may host.
  ///
  /// The server refuses it anyway with its own Dutch message; checking here
  /// means the host meets the wall while choosing rather than after tapping.
  bool _playerCapExceeded() {
    final capability = ref.read(multiplayerCapabilityProvider).asData?.value;
    if (capability == null || capability.isPremium) return false;
    return _maxPlayers > capability.maxPlayersFree;
  }

  void _openPlayerCapPaywall() {
    ref
        .read(analyticsProvider)
        .track(
          AnalyticsEvents.paywallShown,
          props: {
            'trigger': PaywallTrigger.hostPlayerCap,
            'surface': 'play_together',
            'requestedPlayers': _maxPlayers,
          },
        );
    context.push('/premium?reden=host_player_cap');
  }

  void _showMessage(String message) {
    AppNotice.info(context, message);
  }

  void _showError(Object error) {
    AppNotice.error(context, error);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  void _back() => context.go('/quizzes');

  @override
  Widget build(BuildContext context) {
    final hasSession = ref.watch(hasSessionProvider).asData?.value ?? true;
    if (!hasSession) return _buildSignedOut(context);

    final actionState = ref.watch(multiplayerActionControllerProvider);
    final capability = ref.watch(multiplayerCapabilityProvider).asData?.value;
    final busy = actionState.isLoading || _pending != null;

    // Unknown while the capability call is in flight: hosting stays open, and
    // the server refuses with its own message if the quota is actually spent.
    final hostingLocked = capability?.canCreateRoom == false;
    final maxPlayersPremium = capability?.maxPlayersPremium ?? 20;

    // A game survives a crash, a reboot or an incoming call: the room lives on
    // the server, so the way back into it is offered here rather than leaving
    // the player to remember the code.
    final activeRoom = ref.watch(activeMultiplayerRoomProvider).asData?.value;

    final groups =
        ref.watch(playerGroupsProvider).asData?.value ?? const <PlayerGroup>[];

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            MpHeader(
              title: 'Samen spelen',
              buttonLabel: 'Terug',
              onButton: _back,
            ),
            const SizedBox(height: 16),
            _Intro(maxPlayers: maxPlayersPremium),
            const SizedBox(height: 16),
            if (activeRoom != null) ...[
              _ResumeRoomCard(
                room: activeRoom,
                onResume: () => _openRoom(activeRoom),
              ),
              const SizedBox(height: 16),
            ],
            _CreateRoomCard(
              hostingLocked: hostingLocked,
              capability: capability,
              busy: busy,
              loading: _pending == _Pending.create,
              onChooseQuiz: () => _openHostSetup(),
              onUpgrade: () =>
                  context.push('/premium?reden=host_quota_exhausted'),
            ),
            const SizedBox(height: 16),
            _JoinRoomCard(
              controller: _roomCodeController,
              focusNode: _codeFocus,
              busy: busy,
              loading: _pending == _Pending.join,
              onJoin: _joinRoom,
            ),
            // Saved groups, if any: a returning host is here to get the same
            // eight people back in a room.
            if (groups.isNotEmpty) ...[
              const SizedBox(height: 28),
              const BqSectionHeader(title: 'Je groepen'),
              const SizedBox(height: 2),
              const Text(
                'Kies een quiz en stuur je groep in een tik een nieuwe '
                'uitnodiging.',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 10),
              BqListCard(
                children: [
                  for (final group in groups)
                    _SavedGroupRow(
                      group: group,
                      busy: busy,
                      loading:
                          _pending == _Pending.invite &&
                          _pendingGroupId == group.id,
                      onReinvite: () => _openHostSetup(group: group),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Hosting and joining both need an account: the room keeps a player by
  /// their account, and the host's free games are counted on it. The rest of
  /// the app plays signed out, so this is said here rather than as a 401.
  Widget _buildSignedOut(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            MpHeader(
              title: 'Samen spelen',
              buttonLabel: 'Terug',
              onButton: _back,
            ),
            const SizedBox(height: 16),
            const _Intro(maxPlayers: 20),
            const SizedBox(height: 16),
            BqCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CardHeading(
                    icon: BqIcons.user,
                    title: 'Log in om samen te spelen',
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Een kamer maken of meedoen kan met een gratis account, '
                    'zodat je naam en score in de kamer kloppen.',
                    style: AppTheme.bodyLead,
                  ),
                  const SizedBox(height: 14),
                  BqButton(
                    label: 'Inloggen',
                    onPressed: () => context.push('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Intro extends StatelessWidget {
  const _Intro({required this.maxPlayers});

  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iedereen speelt tegelijk dezelfde quiz, ieder op een eigen telefoon.',
          style: AppTheme.bodyLead,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const BqIcon(BqIcons.users, size: 18, color: AppTheme.lapis),
            const SizedBox(width: 8),
            Text(
              'Tot $maxPlayers spelers per kamer',
              style: AppTheme.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

/// Icon tile + Fredoka title (+ optional muted subtitle) at the top of a card.
class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.icon, required this.title, this.subtitle});

  final String icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BqIconTile(child: BqIcon(icon, size: 22, color: AppTheme.lapis)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTheme.displayTitle.copyWith(
                  fontSize: 20,
                  height: 26 / 20,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTheme.caption),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateRoomCard extends StatelessWidget {
  const _CreateRoomCard({
    required this.hostingLocked,
    required this.capability,
    required this.busy,
    required this.loading,
    required this.onChooseQuiz,
    required this.onUpgrade,
  });

  final bool hostingLocked;
  final MultiplayerCapability? capability;
  final bool busy;
  final bool loading;
  final VoidCallback onChooseQuiz;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final freeGamesLeft = capability?.freeRoomsRemaining;
    final maxPlayersPremium = capability?.maxPlayersPremium ?? 20;

    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardHeading(
            icon: BqIcons.plus,
            title: 'Kamer maken',
            subtitle: 'Jij bent de host',
          ),
          const SizedBox(height: 14),
          if (hostingLocked) ...[
            MpNotice(
              tone: MpNoticeTone.info,
              title: 'Je gratis spellen zijn op',
              message:
                  'Met Premium host je onbeperkt kamers, tot '
                  '$maxPlayersPremium spelers tegelijk. Deelnemen met een '
                  'kamercode blijft altijd gratis.',
            ),
            const SizedBox(height: 14),
            BqButton(label: 'Bekijk Premium', onPressed: onUpgrade),
          ] else ...[
            const Text(
              'Kies een quiz, deel de code met je groep en start als iedereen '
              'er is.',
              style: AppTheme.bodyLead,
            ),
            // Two games out, the counter stops being a footnote and becomes a
            // notice. Meeting the wall for the first time in a lobby full of
            // waiting people is the one experience this has to prevent.
            if (freeGamesLeft != null && freeGamesLeft <= 2) ...[
              const SizedBox(height: 14),
              _FreeGamesWarning(
                remaining: freeGamesLeft,
                monthly: capability?.onMonthlyAllowance ?? false,
                onUpgrade: onUpgrade,
              ),
            ],
            const SizedBox(height: 14),
            BqButton(
              label: 'Kies een quiz',
              loading: loading,
              onPressed: busy ? null : onChooseQuiz,
            ),
          ],
        ],
      ),
    );
  }
}

/// The last-two-games notice.
///
/// Deliberately states a fact rather than pressuring: the number is real, the
/// consequence is real, and the player still gets to host tonight either way.
class _FreeGamesWarning extends StatelessWidget {
  const _FreeGamesWarning({
    required this.remaining,
    required this.monthly,
    required this.onUpgrade,
  });

  final int remaining;

  /// Whether this is the recurring monthly allowance rather than the one-off
  /// discovery pack. "Laatste gratis spel" would be a lie on a game that comes
  /// back in a fortnight.
  final bool monthly;

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isLast = remaining <= 1;

    final label = monthly
        ? 'Je spel van deze maand'
        : isLast
        ? 'Laatste gratis spel'
        : 'Nog $remaining gratis spellen';

    final body = monthly
        ? 'Dit is je gratis spel voor deze maand. Volgende maand krijg je er '
              'weer een. Met Premium host je meteen zoveel je wilt.'
        : isLast
        ? 'Dit is je laatste gratis spel om te hosten. Daarna krijg je er elke '
              'maand een terug. Meedoen met andermans spel blijft gratis.'
        : 'Je hebt nog $remaining gratis spellen om te hosten. Een spel telt '
              'pas mee zodra je hem echt start.';

    return MpNotice(
      tone: MpNoticeTone.info,
      title: label,
      message: body,
      action: MpSecondaryButton(
        label: 'Bekijk Premium',
        height: 44,
        expand: false,
        fontSize: 14,
        onPressed: onUpgrade,
      ),
    );
  }
}

class _JoinRoomCard extends StatelessWidget {
  const _JoinRoomCard({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.loading,
    required this.onJoin,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final bool loading;
  final Future<void> Function() onJoin;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardHeading(
            icon: BqIcons.enter,
            title: 'Meedoen met code',
            subtitle: 'De host deelt een code van 6 tekens',
          ),
          const SizedBox(height: 14),
          _CodeBoxes(
            controller: controller,
            focusNode: focusNode,
            enabled: !busy,
            onSubmitted: onJoin,
          ),
          const SizedBox(height: 14),
          MpSecondaryButton(
            label: 'Meedoen',
            loading: loading,
            onPressed: busy ? null : onJoin,
          ),
        ],
      ),
    );
  }
}

/// Six code boxes over one invisible text field, so typing, pasting and the
/// keyboard's "go" key all work like a normal input.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
  });

  static const int length = 6;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    const none = OutlineInputBorder(borderSide: BorderSide.none);

    return Semantics(
      container: true,
      label: 'Kamercode, $length tekens',
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: ListenableBuilder(
                  listenable: Listenable.merge([controller, focusNode]),
                  builder: (context, _) {
                    final text = controller.text;
                    final focused = focusNode.hasFocus;
                    return Row(
                      children: [
                        for (var i = 0; i < length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _CodeBox(
                              char: i < text.length ? text[i] : '',
                              filled: i < text.length,
                              active: focused && i == text.length,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                autocorrect: false,
                enableSuggestions: false,
                showCursor: false,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onSubmitted(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  const _UpperCaseFormatter(),
                  LengthLimitingTextInputFormatter(length),
                ],
                cursorColor: Colors.transparent,
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 1,
                  height: 1,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: none,
                  enabledBorder: none,
                  focusedBorder: none,
                  disabledBorder: none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.char,
    required this.filled,
    required this.active,
  });

  final String char;
  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: filled || active ? AppTheme.paperRaised : mpSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: active
            ? Border.all(color: AppTheme.lapis, width: 2)
            : const Border(
                top: BorderSide(color: AppTheme.rule),
                left: BorderSide(color: AppTheme.rule),
                right: BorderSide(color: AppTheme.rule),
                bottom: BorderSide(color: AppTheme.rule, width: 3),
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppTheme.ink,
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// "You still have a game running" card.
class _ResumeRoomCard extends StatelessWidget {
  const _ResumeRoomCard({required this.room, required this.onResume});

  final MultiplayerRoom room;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final label = switch (room.status) {
      MultiplayerRoomStatus.lobby => 'Je wachtkamer staat nog open',
      MultiplayerRoomStatus.finished => 'Je laatste spel is afgelopen',
      _ => 'Je spel loopt nog',
    };
    final quizTitle = room.quizTitle.isEmpty
        ? 'Multiplayer quiz'
        : room.quizTitle;

    return Semantics(
      button: true,
      label: '$label. $quizTitle, kamer ${room.code}. Ga verder',
      excludeSemantics: true,
      child: BqCard(
        onTap: onResume,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            const BqIconTile(
              child: BqIcon(BqIcons.enter, size: 20, color: AppTheme.lapis),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HERVATTEN',
                    style: AppTheme.eyebrow.copyWith(color: AppTheme.lapis),
                  ),
                  Text(label, style: AppTheme.bodyStrong),
                  Text(
                    '$quizTitle - kamer ${room.code}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const BqIcon(
              BqIcons.chevronRight,
              size: 18,
              color: AppTheme.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}

/// One saved group, with its re-invite action.
class _SavedGroupRow extends StatelessWidget {
  const _SavedGroupRow({
    required this.group,
    required this.busy,
    required this.loading,
    required this.onReinvite,
  });

  final PlayerGroup group;
  final bool busy;
  final bool loading;
  final VoidCallback onReinvite;

  @override
  Widget build(BuildContext context) {
    final memberLabel = group.memberCount == 1
        ? '1 speler'
        : '${group.memberCount} spelers';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          const BqIconTile(
            child: BqIcon(BqIcons.users, size: 20, color: AppTheme.lapis),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStrong,
                ),
                Text(memberLabel, style: AppTheme.caption),
              ],
            ),
          ),
          const SizedBox(width: 10),
          MpSecondaryButton(
            label: 'Uitnodigen',
            icon: const BqIcon(BqIcons.share, size: 16, color: AppTheme.lapis),
            height: 44,
            expand: false,
            fontSize: 14,
            loading: loading,
            onPressed: busy ? null : onReinvite,
          ),
        ],
      ),
    );
  }
}
