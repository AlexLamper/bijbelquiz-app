import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/preview_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../data/duels_repository.dart';
import '../domain/duel.dart';
import 'widgets/duel_widgets.dart';

/// "Nieuw duel" - BijbelQuiz 2.0 (`R-Uitdagen`).
///
/// The rules line, a big "Willekeurige speler" card, search by name, the
/// Vrienden list and an invite link. Also the landing spot for a shared duel
/// link: `/duels/new?invite=<token>` shows who sent it and lets the player
/// accept, for free.
class NewDuelScreen extends ConsumerStatefulWidget {
  const NewDuelScreen({super.key});

  @override
  ConsumerState<NewDuelScreen> createState() => _NewDuelScreenState();
}

class _NewDuelScreenState extends ConsumerState<NewDuelScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  /// What is in flight: `random`, `invite`, `join` or a player id.
  String? _busy;

  String? _inviteToken;
  bool _inviteRead = false;
  Future<DuelInvitePreview>? _invitePreview;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inviteRead) return;
    _inviteRead = true;
    final token = GoRouterState.of(context).uri.queryParameters['invite']?.trim();
    if (token != null && token.isNotEmpty) {
      _inviteToken = token;
      _invitePreview = ref.read(duelsRepositoryProvider).invitePreview(token);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  /// Opens the duel in place of this screen, so "back" returns to the list.
  void _openDuel(Duel duel) {
    ref.invalidate(duelListProvider);
    context.pushReplacement('/duels/${duel.id}');
  }

  Future<void> _run(String key, Future<void> Function() action) async {
    if (_busy != null) return;
    setState(() => _busy = key);
    try {
      await action();
    } catch (error) {
      if (mounted) AppNotice.error(context, error);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _challengeRandom() => _run('random', () async {
    final result = await ref.read(duelsRepositoryProvider).challengeRandom();
    if (!mounted) return;
    if (result.matched) {
      AppNotice.info(
        context,
        'Je speelt tegen ${result.duel.opponentName}.',
        title: 'Tegenstander gevonden',
      );
    }
    _openDuel(result.duel);
  });

  Future<void> _challengePlayer(DuelPlayer player) => _run(player.id, () async {
    final result = await ref
        .read(duelsRepositoryProvider)
        .challengePlayer(player.id, name: player.name);
    if (!mounted) return;
    if (!result.created) {
      AppNotice.info(
        context,
        'Je hebt al een duel met ${player.name}. Daar ga je nu verder.',
      );
    }
    _openDuel(result.duel);
  });

  Future<void> _invite() => _run('invite', () async {
    final result = await ref.read(duelsRepositoryProvider).createInvite();
    final token = result.inviteToken ?? result.duel.inviteToken;
    if (token != null && !PreviewConfig.enabled) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: duelInviteMessage(token, result.duel.me.name),
            subject: 'Speel een duel met mij op BijbelQuiz',
          ),
        );
      } catch (_) {
        // No share target, or the sheet was dismissed. The duel exists and
        // its screen offers the link again.
      }
    }
    if (!mounted) return;
    _openDuel(result.duel);
  });

  Future<void> _acceptInvite(String token) => _run('join', () async {
    final duel = await ref.read(duelsRepositoryProvider).joinInvite(token);
    if (!mounted) return;
    _openDuel(duel);
  });

  @override
  Widget build(BuildContext context) {
    final signedIn =
        PreviewConfig.enabled ||
        (ref.watch(hasSessionProvider).asData?.value ?? true);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Row(
              children: [
                BqCircleButton(
                  icon: BqIcons.chevronLeft,
                  label: 'Terug naar duels',
                  onTap: () => context.canPop() ? context.pop() : context.go('/duels'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nieuw duel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.displayLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1 tegen 1 · 3 rondes van 3 vragen · om de beurt',
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 16),
            if (!signedIn)
              DuelLoginCard(
                onLogin: () => context.push('/login'),
                onRegister: () => context.push('/register'),
              )
            else ...[
              if (_invitePreview != null) ...[
                _InviteBanner(
                  preview: _invitePreview!,
                  busy: _busy == 'join',
                  onAccept: () => _acceptInvite(_inviteToken!),
                ),
                const SizedBox(height: 16),
              ],
              _RandomCard(busy: _busy == 'random', onTap: _challengeRandom),
              const SizedBox(height: 16),
              _SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),
              Text(
                _query.isEmpty ? 'Vrienden' : 'Spelers',
                style: const TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 8),
              _CandidateList(
                query: _query,
                busyId: _busy,
                onChallenge: _challengePlayer,
              ),
              const SizedBox(height: 16),
              _InviteRow(busy: _busy == 'invite', onTap: _invite),
            ],
          ],
        ),
      ),
    );
  }
}

/// The big lapis "Willekeurige speler" card.
class _RandomCard extends StatelessWidget {
  const _RandomCard({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Willekeurige speler. Direct een tegenstander vinden',
      excludeSemantics: true,
      child: Material(
        color: AppTheme.lapis,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: busy ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.lapisStrong, width: 3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.paperRaised,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const BqIcon(
                    BqIcons.shuffle,
                    size: 26,
                    color: AppTheme.lapis,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Willekeurige speler',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.displayFontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          height: 24 / 20,
                          color: AppTheme.inkInverted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Direct een tegenstander vinden',
                        style: TextStyle(
                          fontFamily: AppTheme.sansFontName,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDCE3F1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppTheme.inkInverted,
                    ),
                  )
                else
                  const BqIcon(
                    BqIcons.chevronRight,
                    size: 20,
                    color: AppTheme.inkInverted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontFamily: AppTheme.sansFontName,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.ink,
        ),
        decoration: const InputDecoration(
          hintText: 'Zoek een speler op naam',
          contentPadding: EdgeInsets.symmetric(horizontal: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: BqIcon(BqIcons.search, size: 20, color: AppTheme.inkFaint),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 20),
        ),
      ),
    );
  }
}

/// Vrienden (past opponents and player-group members) or search results.
class _CandidateList extends ConsumerWidget {
  const _CandidateList({
    required this.query,
    required this.busyId,
    required this.onChallenge,
  });

  final String query;
  final String? busyId;
  final ValueChanged<DuelPlayer> onChallenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isNotEmpty && query.length < 2) {
      return const _ListNote('Typ minstens 2 letters.');
    }

    final async = ref.watch(duelCandidatesProvider(query));
    return async.when(
      loading: () => const BqCard(
        child: SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ),
        ),
      ),
      error: (error, _) => _ListNote(error.toString()),
      data: (candidates) {
        if (candidates.isEmpty) {
          return _ListNote(
            query.isEmpty
                ? 'Nog geen vrienden. Wie je eerder in een duel of in een '
                      'groep tegenkwam, staat hier. Zoek iemand op naam of '
                      'nodig iemand uit met een link.'
                : 'Geen speler gevonden die "$query" heet.',
          );
        }
        return BqListCard(
          children: [
            for (final candidate in candidates)
              _CandidateRow(
                player: candidate.player,
                busy: busyId == candidate.player.id,
                enabled: busyId == null,
                onChallenge: () => onChallenge(candidate.player),
              ),
          ],
        );
      },
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.player,
    required this.busy,
    required this.enabled,
    required this.onChallenge,
  });

  final DuelPlayer player;
  final bool busy;
  final bool enabled;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          BqAvatar(name: player.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyStrong,
                ),
                Text('Level ${player.level}', style: AppTheme.caption),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: '${player.name} uitdagen',
            onTap: enabled ? onChallenge : null,
            excludeSemantics: true,
            child: BqButton(
              label: 'Uitdagen',
              style: BqButtonStyle.tint,
              height: 38,
              expand: false,
              fontSize: 14,
              radius: 10,
              loading: busy,
              onPressed: enabled ? onChallenge : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListNote extends StatelessWidget {
  const _ListNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return BqCard(child: Text(text, style: AppTheme.bodyMuted));
  }
}

/// "Nodig iemand uit met een link" - the invited friend plays for free.
class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BqCard(
      padding: EdgeInsets.zero,
      child: BqListRow(
        leading: const BqIconTile(
          background: AppTheme.positiveTint,
          child: BqIcon(BqIcons.link, size: 20, color: AppTheme.positive),
        ),
        title: 'Nodig iemand uit met een link',
        subtitle: 'Je vriend speelt dit duel gratis',
        subtitleColor: AppTheme.positive,
        showChevron: !busy,
        trailing: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : null,
        onTap: busy ? null : onTap,
      ),
    );
  }
}

/// Shown when the screen was opened from a shared duel link.
class _InviteBanner extends StatelessWidget {
  const _InviteBanner({
    required this.preview,
    required this.busy,
    required this.onAccept,
  });

  final Future<DuelInvitePreview> preview;
  final bool busy;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DuelInvitePreview>(
      future: preview,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BqCard(
            child: SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              ),
            ),
          );
        }

        final invite = snapshot.data;
        if (invite == null || !invite.joinable) {
          return BqCard(
            child: Text(
              snapshot.hasError
                  ? snapshot.error.toString()
                  : 'Deze uitnodiging is niet meer geldig: iemand anders '
                        'speelt dit duel al, of het is verlopen.',
              style: AppTheme.bodyMuted,
            ),
          );
        }

        final name = invite.challenger.name;
        return BqCard(
          radius: 18,
          borderColor: AppTheme.coralLine,
          borderWidth: 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BqAvatar(name: name, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$name daagt je uit',
                          style: AppTheme.displayTitle,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Je speelt dit duel gratis',
                          style: TextStyle(
                            fontFamily: AppTheme.sansFontName,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.positive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              BqButton(
                label: 'Duel accepteren',
                style: BqButtonStyle.coral,
                height: 48,
                loading: busy,
                onPressed: busy ? null : onAccept,
              ),
            ],
          ),
        );
      },
    );
  }
}
