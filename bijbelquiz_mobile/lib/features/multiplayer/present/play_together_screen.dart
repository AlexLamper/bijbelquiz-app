import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../groups/data/player_group_repository.dart';
import '../../groups/domain/player_group.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';
import '../data/multiplayer_api_exception.dart';
import '../domain/multiplayer_models.dart';
import 'multiplayer_action_controller.dart';

enum _PlayMode { create, join }

/// Room sizes offered, matching `PLAYER_OPTIONS` on the website. The last rung
/// is replaced by whatever ceiling the server reports for Premium.
const List<int> _basePlayerOptions = [2, 3, 4, 6, 8, 10, 12];

class PlayTogetherScreen extends ConsumerStatefulWidget {
  const PlayTogetherScreen({super.key});

  @override
  ConsumerState<PlayTogetherScreen> createState() => _PlayTogetherScreenState();
}

class _PlayTogetherScreenState extends ConsumerState<PlayTogetherScreen> {
  final TextEditingController _roomCodeController = TextEditingController();

  String? _selectedQuizId;
  _PlayMode _mode = _PlayMode.create;

  /// Room size the host picked. Starts at the free cap, so the first thing a
  /// new host sees is a number they can actually use.
  int _maxPlayers = 4;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
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

    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .createRoom(quizId: _selectedQuizId!, maxPlayers: _maxPlayers);
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
      _showError(error);
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

    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .joinRoom(roomCode: roomCode);
      if (!mounted) return;
      context.push('/play-together/room/${room.code}');
    } catch (error) {
      _showError(error);
    }
  }

  /// Routes to whichever screen matches the room's current phase, so resuming
  /// a game in progress does not drop the player back into the lobby.
  void _openRoom(MultiplayerRoom room) {
    final base = '/play-together/room/${room.code}';
    switch (room.status) {
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

  Future<void> _startRoomForQuiz(String quizId) async {
    setState(() {
      _mode = _PlayMode.create;
      _selectedQuizId = quizId;
    });

    await _createRoom();
  }

  /// Opens a room and hands the group's invite straight to the share sheet.
  ///
  /// The whole value of a saved group is not having to reassemble it: one tap
  /// makes the room and puts the link in front of the same chat that played
  /// last time. It still needs a quiz, because a room without one is nothing to
  /// invite anybody to.
  Future<void> _reinviteGroup(PlayerGroup group) async {
    final quizId = _selectedQuizId;
    if (quizId == null || quizId.isEmpty) {
      setState(() => _mode = _PlayMode.create);
      _showMessage('Kies eerst een quiz, dan nodigen we ${group.name} uit.');
      return;
    }

    if (_playerCapExceeded()) {
      _openPlayerCapPaywall();
      return;
    }

    try {
      final room = await ref
          .read(multiplayerActionControllerProvider.notifier)
          .createRoom(quizId: quizId, maxPlayers: _maxPlayers);
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
        // way and the lobby below shows the code.
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(const QuizQuery(limit: 25)));
    final actionState = ref.watch(multiplayerActionControllerProvider);
    final capability = ref.watch(multiplayerCapabilityProvider).asData?.value;

    // Unknown while the capability call is in flight: hosting stays open, and
    // the server refuses with its own message if the quota is actually spent.
    final hostingLocked = capability?.canCreateRoom == false;
    final freeGamesLeft = capability?.freeRoomsRemaining;
    final onMonthlyAllowance = capability?.onMonthlyAllowance ?? false;
    final isPremiumHost = capability?.isPremium ?? false;
    final maxPlayersFree = capability?.maxPlayersFree ?? 4;
    final maxPlayersPremium = capability?.maxPlayersPremium ?? 20;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            const GradientHeader(
              eyebrow: 'Samen spelen',
              title: 'Speciaal ontworpen voor groepen',
              subtitle:
                  'Van gezin tot jeugdvereniging - iedereen speelt mee. Geen '
                  'installatie, gewoon een code delen en direct beginnen.',
            ),
            const SizedBox(height: 28),
            // A game survives a crash, a reboot or an incoming call: the room
            // lives on the server, so the way back into it is offered here
            // rather than leaving the player to remember the code.
            ref
                .watch(activeMultiplayerRoomProvider)
                .maybeWhen(
                  data: (room) => room == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _ResumeRoomCard(
                            room: room,
                            onResume: () => _openRoom(room),
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
            // Mode toggle - same button pair as the site's filter row.
            Row(
              children: [
                _ModeButton(
                  label: 'Kamer maken',
                  active: _mode == _PlayMode.create,
                  locked: hostingLocked,
                  onTap: () => setState(() => _mode = _PlayMode.create),
                ),
                const SizedBox(width: 8),
                _ModeButton(
                  label: 'Deelnemen',
                  active: _mode == _PlayMode.join,
                  onTap: () => setState(() => _mode = _PlayMode.join),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _mode == _PlayMode.create
                  ? _CreateRoomForm(
                      key: const ValueKey('create-form'),
                      quizzesAsync: quizzesAsync,
                      selectedQuizId: _selectedQuizId,
                      isBusy: actionState.isLoading,
                      hasPremiumAccess: !hostingLocked,
                      freeGamesLeft: freeGamesLeft,
                      onMonthlyAllowance: onMonthlyAllowance,
                      isPremiumHost: isPremiumHost,
                      maxPlayers: _maxPlayers,
                      maxPlayersFree: maxPlayersFree,
                      maxPlayersPremium: maxPlayersPremium,
                      onSelectQuiz: (id) {
                        setState(() {
                          _selectedQuizId = id;
                        });
                      },
                      onSelectMaxPlayers: (count) {
                        if (count == null) return;
                        setState(() {
                          _maxPlayers = count;
                        });
                      },
                      onPlayerCapUpgrade: _openPlayerCapPaywall,
                      onCreateRoom: _createRoom,
                      onUpgrade: () {
                        context.push('/premium?reden=host_quota_exhausted');
                      },
                    )
                  : _JoinRoomForm(
                      key: const ValueKey('join-form'),
                      controller: _roomCodeController,
                      isBusy: actionState.isLoading,
                      onJoin: _joinRoom,
                    ),
            ),
            // Saved groups, if any. Placed above "Zo werkt het" because a
            // returning host is not reading the explainer again - they are
            // here to get the same eight people back in a room.
            ...(() {
              final groups =
                  ref.watch(playerGroupsProvider).asData?.value ??
                  const <PlayerGroup>[];
              if (groups.isEmpty) return const <Widget>[];

              return [
                const SizedBox(height: 44),
                const SectionHeader(
                  eyebrow: 'Je groepen',
                  title: 'Nodig ze zo weer uit',
                  description:
                      'Kies een quiz en stuur je groep in een tik een nieuwe '
                      'uitnodiging.',
                ),
                const SizedBox(height: 24),
                RuleGrid(
                  children: [
                    for (final group in groups)
                      _SavedGroupRow(
                        group: group,
                        isBusy: actionState.isLoading,
                        onReinvite: () => _reinviteGroup(group),
                      ),
                  ],
                ),
              ];
            })(),
            const SizedBox(height: 44),
            const SectionHeader(
              eyebrow: 'Zo werkt het',
              title: 'In drie stappen',
            ),
            const SizedBox(height: 24),
            const _HowItWorksGrid(),
            const SizedBox(height: 44),
            SectionHeader(
              eyebrow: 'Snelstart',
              title: 'Start direct een kamer',
              description:
                  'Kies een quiz en open meteen een nieuwe kamer voor je groep.',
            ),
            const SizedBox(height: 24),
            _QuickStartQuizzes(
              quizzesAsync: quizzesAsync,
              isBusy: actionState.isLoading,
              hasPremiumAccess: !hostingLocked,
              onStartRoom: _startRoomForQuiz,
              onUpgrade: () {
                context.push('/premium?reden=host_quota_exhausted');
              },
            ),
          ],
        ),
      ),
    );
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
}

/// `h-9 rounded-md border-rule bg-paper-raised px-4` / active `bg-ink`.
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
        ? 'JE SPEL VAN DEZE MAAND'
        : isLast
        ? 'LAATSTE GRATIS SPEL'
        : 'NOG $remaining GRATIS SPELLEN';

    final body = monthly
        ? 'Dit is je gratis spel voor deze maand. Volgende maand krijg je er '
              'weer een. Met Premium host je meteen zoveel je wilt.'
        : isLast
        ? 'Dit is je laatste gratis spel om te hosten. Daarna krijg je er elke '
              'maand een terug. Meedoen met andermans spel blijft gratis.'
        : 'Je hebt nog $remaining gratis spellen om te hosten. Een spel telt '
              'pas mee zodra je hem echt start.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.vermilionTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.vermilion.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.overline.copyWith(color: AppTheme.vermilion),
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTheme.bodyMuted),
          const SizedBox(height: 12),
          SiteOutlineButton(
            label: 'Bekijk Premium',
            expand: false,
            height: 38,
            onPressed: onUpgrade,
          ),
        ],
      ),
    );
  }
}

/// One saved group, with its re-invite action.
class _SavedGroupRow extends StatelessWidget {
  const _SavedGroupRow({
    required this.group,
    required this.isBusy,
    required this.onReinvite,
  });

  final PlayerGroup group;
  final bool isBusy;
  final VoidCallback onReinvite;

  @override
  Widget build(BuildContext context) {
    final memberLabel = group.memberCount == 1
        ? '1 speler'
        : '${group.memberCount} spelers';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
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
                const SizedBox(height: 5),
                Text(memberLabel.toUpperCase(), style: AppTheme.overline),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SiteOutlineButton(
            label: 'Uitnodigen',
            icon: Icons.ios_share,
            expand: false,
            height: 36,
            onPressed: isBusy ? null : onReinvite,
          ),
        ],
      ),
    );
  }
}

/// "You still have a game running" banner.
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lapisTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'HERVATTEN',
            style: AppTheme.overline.copyWith(color: AppTheme.lapis),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            '${room.quizTitle.isEmpty ? 'Multiplayer quiz' : room.quizTitle} '
            '- kamer ${room.code}',
            style: AppTheme.bodyMuted,
          ),
          const SizedBox(height: 18),
          SiteButton(
            label: 'Ga verder',
            trailingIcon: Icons.arrow_forward,
            onPressed: onResume,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.ink : AppTheme.paperRaised,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: active ? AppTheme.ink : AppTheme.rule),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked) ...[
                Icon(
                  Icons.lock_outline,
                  size: 13,
                  color: active ? AppTheme.inkInverted : AppTheme.inkMuted,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  color: active ? AppTheme.inkInverted : AppTheme.ink,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRoomForm extends StatelessWidget {
  const _CreateRoomForm({
    super.key,
    required this.quizzesAsync,
    required this.selectedQuizId,
    required this.isBusy,
    required this.hasPremiumAccess,
    required this.freeGamesLeft,
    required this.onMonthlyAllowance,
    required this.isPremiumHost,
    required this.maxPlayers,
    required this.maxPlayersFree,
    required this.maxPlayersPremium,
    required this.onSelectQuiz,
    required this.onSelectMaxPlayers,
    required this.onPlayerCapUpgrade,
    required this.onCreateRoom,
    required this.onUpgrade,
  });

  final AsyncValue<List<Quiz>> quizzesAsync;
  final String? selectedQuizId;
  final bool isBusy;
  final bool hasPremiumAccess;

  /// Free hosted games left, or null for Premium (unlimited) and while the
  /// capability call is still in flight.
  final int? freeGamesLeft;

  /// True once the discovery pack is spent: the number above then counts this
  /// month rather than a lifetime allowance.
  final bool onMonthlyAllowance;

  /// Whether this account may host at the premium ceiling. Separate from
  /// [hasPremiumAccess], which is about the free-game quota: an account with
  /// games left still only gets four seats.
  final bool isPremiumHost;

  /// Room size the host picked, and the two ceilings it is judged against.
  final int maxPlayers;
  final int maxPlayersFree;
  final int maxPlayersPremium;

  final ValueChanged<String?> onSelectQuiz;
  final ValueChanged<int?> onSelectMaxPlayers;
  final VoidCallback onPlayerCapUpgrade;
  final Future<void> Function() onCreateRoom;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    // The premium ceiling replaces the last rung rather than being appended,
    // so a server that lowers it never leaves an unreachable option behind.
    final playerOptions =
        <int>{
          ..._basePlayerOptions.where((count) => count < maxPlayersPremium),
          maxPlayersPremium,
        }.toList()..sort();
    final playerCapExceeded = !isPremiumHost && maxPlayers > maxPlayersFree;

    if (!hasPremiumAccess) {
      // `dark:bg-lapis/10 border-lapis/35` - the site's accent notice block.
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lapisTint,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.lapis.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Gratis spellen op'),
            const SizedBox(height: 16),
            const Text('Je gratis spellen zijn op', style: AppTheme.displaySmall),
            const SizedBox(height: 10),
            const Text(
              'Met Premium host je onbeperkt kamers, tot 20 spelers tegelijk. '
              'Deelnemen met een kamercode blijft altijd gratis.',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),
            SiteButton(
              label: 'Bekijk Premium',
              trailingIcon: Icons.arrow_forward,
              onPressed: onUpgrade,
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('NIEUWE KAMER', style: AppTheme.overline),
          const SizedBox(height: 8),
          Text(
            isPremiumHost
                ? 'Jij bent spelleider en kunt tot $maxPlayersPremium spelers '
                      'uitnodigen.'
                : 'Gratis tot $maxPlayersFree spelers. Een gratis spel telt '
                      'pas mee als je het spel echt start.',
            style: AppTheme.caption,
          ),
          const SizedBox(height: 16),
          // Two games out, the counter stops being a footnote and becomes a
          // notice. Meeting the wall for the first time in a lobby full of
          // waiting people is the one experience this has to prevent.
          ...switch (freeGamesLeft) {
            null => const <Widget>[],
            final int left when left <= 2 => <Widget>[
              _FreeGamesWarning(
                remaining: left,
                monthly: onMonthlyAllowance,
                onUpgrade: onUpgrade,
              ),
              const SizedBox(height: 16),
            ],
            final int left => <Widget>[
              Text(
                'Je hebt nog $left gratis spellen om te hosten.',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 16),
            ],
          },
          quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return const Text(
                  'Geen quizzen gevonden om een kamer te starten.',
                  style: AppTheme.bodyMuted,
                );
              }

              final effectiveValue =
                  (selectedQuizId == null ||
                      quizzes.every((quiz) => quiz.id != selectedQuizId))
                  ? quizzes.first.id
                  : selectedQuizId;

              if (effectiveValue != selectedQuizId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onSelectQuiz(effectiveValue);
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('KIES EEN QUIZ', style: AppTheme.overline),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: effectiveValue,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.inkMuted,
                    ),
                    dropdownColor: AppTheme.paperRaised,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    items: quizzes
                        .map(
                          (quiz) => DropdownMenuItem<String>(
                            value: quiz.id,
                            child: Text(
                              quiz.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return quizzes
                          .map(
                            (quiz) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                quiz.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList();
                    },
                    onChanged: isBusy ? null : onSelectQuiz,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MAXIMAAL AANTAL SPELERS',
                    style: AppTheme.overline,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: playerOptions.contains(maxPlayers)
                        ? maxPlayers
                        : maxPlayersFree,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.inkMuted,
                    ),
                    dropdownColor: AppTheme.paperRaised,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    items: [
                      for (final count in playerOptions)
                        DropdownMenuItem<int>(
                          value: count,
                          child: Row(
                            children: [
                              Text('$count spelers'),
                              if (!isPremiumHost && count > maxPlayersFree) ...[
                                const SizedBox(width: 10),
                                const SiteBadge.lapis('PREMIUM'),
                              ],
                            ],
                          ),
                        ),
                    ],
                    // The closed field never carries the badge: it would sit
                    // there claiming the account has Premium.
                    selectedItemBuilder: (context) => [
                      for (final count in playerOptions)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('$count spelers'),
                        ),
                    ],
                    onChanged: isBusy ? null : onSelectMaxPlayers,
                  ),
                  // One line, not a second paywall block: the host only needs
                  // to know this number is out of reach and what buys it.
                  if (playerCapExceeded) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: onPlayerCapUpgrade,
                      child: Text(
                        '$maxPlayers spelers vraagt om Premium. Gratis speel '
                        'je tot $maxPlayersFree spelers.',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.lapis,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.lapis,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SiteButton(
                    label: 'Start kamer',
                    trailingIcon: Icons.arrow_forward,
                    loading: isBusy,
                    onPressed: isBusy ? null : onCreateRoom,
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoader(size: 20),
            ),
            error: (err, _) => Text(
              'Fout bij laden quizzen: $err',
              style: AppTheme.bodyMuted.copyWith(color: AppTheme.destructive),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinRoomForm extends StatelessWidget {
  const _JoinRoomForm({
    super.key,
    required this.controller,
    required this.isBusy,
    required this.onJoin,
  });

  final TextEditingController controller;
  final bool isBusy;
  final Future<void> Function() onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('DEELNEMEN MET CODE', style: AppTheme.overline),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            enabled: !isBusy,
            textCapitalization: TextCapitalization.characters,
            cursorColor: AppTheme.ink,
            cursorWidth: 1.4,
            textAlign: TextAlign.center,
            // Room codes read as data - serif, tabular, wide tracking.
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 26,
              letterSpacing: 6,
              color: AppTheme.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            decoration: const InputDecoration(
              hintText: 'AB12CD',
              hintStyle: TextStyle(
                fontFamily: AppTheme.displayFontName,
                fontSize: 26,
                letterSpacing: 6,
                color: AppTheme.ruleStrong,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 20),
          SiteButton(
            label: 'Deelnemen',
            trailingIcon: Icons.arrow_forward,
            loading: isBusy,
            onPressed: isBusy ? null : onJoin,
          ),
        ],
      ),
    );
  }
}

/// The site's numbered `01 / 02 / 03` process grid.
class _HowItWorksGrid extends StatelessWidget {
  const _HowItWorksGrid();

  @override
  Widget build(BuildContext context) {
    return const RuleGrid(
      children: [
        _StepTile(
          index: '01',
          title: 'Maak of join een kamer',
          subtitle: 'De host kiest een quiz en deelt de code',
        ),
        _StepTile(
          index: '02',
          title: 'Speel live tegelijk',
          subtitle: 'Iedereen krijgt dezelfde vragen en timer',
        ),
        _StepTile(
          index: '03',
          title: 'Bekijk de eindranglijst',
          subtitle: 'Vergelijk scores en daag elkaar opnieuw uit',
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 14,
              color: AppTheme.lapis,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.displayBase),
                const SizedBox(height: 5),
                Text(subtitle.toUpperCase(), style: AppTheme.overline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartQuizzes extends StatelessWidget {
  const _QuickStartQuizzes({
    required this.quizzesAsync,
    required this.isBusy,
    required this.hasPremiumAccess,
    required this.onStartRoom,
    required this.onUpgrade,
  });

  final AsyncValue<List<Quiz>> quizzesAsync;
  final bool isBusy;
  final bool hasPremiumAccess;
  final Future<void> Function(String quizId) onStartRoom;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const AppCard(
            child: Text(
              'Geen quizzen beschikbaar om een kamer te starten.',
              style: AppTheme.bodyMuted,
            ),
          );
        }

        final visible = quizzes.take(4).toList();

        return RuleGrid(
          children: [
            for (final quiz in visible)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.displayBase,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${quiz.questionCount} VRAGEN  ·  ${quiz.difficultyLabelNl}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.overline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SiteOutlineButton(
                      label: hasPremiumAccess ? 'Start' : 'Premium',
                      icon: hasPremiumAccess ? null : Icons.lock_outline,
                      expand: false,
                      height: 36,
                      onPressed: isBusy
                          ? null
                          : hasPremiumAccess
                          ? () => onStartRoom(quiz.id)
                          : onUpgrade,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: AppLoader(size: 20),
      ),
      error: (err, _) => AppCard(
        child: Text(
          'Kan quizzen niet laden: $err',
          style: AppTheme.bodyMuted.copyWith(color: AppTheme.destructive),
        ),
      ),
    );
  }
}
