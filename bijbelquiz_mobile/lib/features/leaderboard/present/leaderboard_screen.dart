import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/avatar/mascot_avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../groups/data/player_group_repository.dart';
import '../../groups/domain/player_group.dart';
import '../../profile/present/profile_provider.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

/// Ranglijst - BijbelQuiz 2.0 (`R-Ranglijst`).
///
/// Title with the running period, period tabs, a top-3 podium and a white
/// list card for place 4 and down with the player's own row tinted lapis.
/// Saved player groups appear as scope chips above the tabs.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  /// The running month first, like the current-period tab in the design.
  LeaderboardPeriod _selectedRange = LeaderboardPeriod.month;

  /// Null means the global board. Otherwise the saved group being viewed.
  String? _selectedGroupId;

  Future<void> _refreshData() async {
    ref.invalidate(playerGroupsProvider);

    final groupId = _selectedGroupId;
    if (groupId == null) {
      ref.invalidate(leaderboardByPeriodProvider(_selectedRange));
      await ref.read(leaderboardByPeriodProvider(_selectedRange).future);
      return;
    }

    final key = (groupId: groupId, period: _selectedRange);
    ref.invalidate(playerGroupLeaderboardProvider(key));
    await ref.read(playerGroupLeaderboardProvider(key).future);
  }

  @override
  Widget build(BuildContext context) {
    final groups =
        ref.watch(playerGroupsProvider).asData?.value ?? const <PlayerGroup>[];

    // A group deleted from another device leaves a dead selection behind; fall
    // back to the global board rather than showing an error for a tab that is
    // no longer on screen.
    final activeGroup = _selectedGroupId == null
        ? null
        : groups.where((group) => group.id == _selectedGroupId).firstOrNull;
    if (_selectedGroupId != null && activeGroup == null && groups.isNotEmpty) {
      _selectedGroupId = null;
    }

    // Watched through an explicit branch rather than a stored provider: the
    // two families have different argument types.
    final AsyncValue<List<LeaderboardEntry>> leaderboardAsync =
        _selectedGroupId == null
        ? ref.watch(leaderboardByPeriodProvider(_selectedRange))
        : ref.watch(
            playerGroupLeaderboardProvider((
              groupId: _selectedGroupId!,
              period: _selectedRange,
            )),
          );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.lapis,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: _refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _Header(subtitle: _subtitle(activeGroup)),
              const SizedBox(height: 16),
              if (groups.isNotEmpty) ...[
                _ScopeSelector(
                  groups: groups,
                  selectedGroupId: _selectedGroupId,
                  onSelect: (value) => setState(() => _selectedGroupId = value),
                ),
                const SizedBox(height: 8),
              ],
              _PeriodTabs(
                selected: _selectedRange,
                onSelect: (value) => setState(() => _selectedRange = value),
              ),
              const SizedBox(height: 16),
              ...leaderboardAsync.when(
                data: (entries) => _board(entries, activeGroup),
                loading: () => const [SizedBox(height: 140), AppLoader()],
                error: (err, _) => [
                  const SizedBox(height: 24),
                  AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'Ranglijst kon niet laden',
                    description: '$err',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The line under the title: what the board counts, or which group is on
  /// screen.
  String _subtitle(PlayerGroup? group) {
    if (group != null) {
      final count = group.memberCount;
      return '$count ${count == 1 ? 'speler' : 'spelers'} in ${group.name}';
    }
    switch (_selectedRange) {
      case LeaderboardPeriod.month:
        // The server's monthly board is a rolling window (the last 30 days),
        // not the calendar month, so no end date is promised here.
        return 'XP van de afgelopen 30 dagen';
      case LeaderboardPeriod.all:
        return 'Alle XP sinds de start telt mee';
    }
  }

  List<Widget> _board(List<LeaderboardEntry> entries, PlayerGroup? group) {
    final sorted = [...entries]..sort((a, b) => b.xp.compareTo(a.xp));

    final profile = ref.watch(profileProvider).asData?.value;
    final hasSession = ref.watch(hasSessionProvider).asData?.value ?? true;
    final myId = profile?.id ?? '';
    final myName = (profile?.name ?? '').trim().toLowerCase();
    var myIndex = myId.isEmpty
        ? -1
        : sorted.indexWhere((entry) => entry.id == myId);
    if (myIndex < 0 && myName.isNotEmpty) {
      myIndex = sorted.indexWhere(
        (entry) => entry.name.trim().toLowerCase() == myName,
      );
    }
    final myEntryId = myIndex >= 0 ? sorted[myIndex].id : null;

    return [
      // Said once, above the board, where the player's own row would be.
      if (profile == null && !hasSession) ...[
        const _GuestCard(),
        const SizedBox(height: 16),
      ] else if (profile != null && myIndex < 0 && sorted.isNotEmpty) ...[
        const _NotPlacedCard(),
        const SizedBox(height: 16),
      ],
      if (sorted.isEmpty)
        _EmptyBoard(period: _selectedRange, inGroup: group != null)
      else ...[
        _Podium(entries: sorted.take(3).toList(), myEntryId: myEntryId),
        if (sorted.length > 3)
          _RestList(
            // Collapse again when the player switches board.
            key: ValueKey('${_selectedGroupId ?? 'all'}-$_selectedRange'),
            entries: sorted,
            myIndex: myIndex,
          ),
      ],
    ];
  }
}

String _formatXp(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Header and selectors
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: const Text('Ranglijst', style: AppTheme.displayLarge),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const BqIcon(BqIcons.trophy, size: 16, color: AppTheme.goldText),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Segmented period control: grey track, the active option a white pill.
class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelect});

  final LeaderboardPeriod selected;
  final ValueChanged<LeaderboardPeriod> onSelect;

  static const List<(LeaderboardPeriod, String)> _options = [
    (LeaderboardPeriod.month, 'Deze maand'),
    (LeaderboardPeriod.all, 'Altijd'),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Periode',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DDD5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _options.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: _TabButton(
                  label: _options[i].$2,
                  active: selected == _options[i].$1,
                  onTap: () => onSelect(_options[i].$1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.paperRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppTheme.rule : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w700,
              color: active ? AppTheme.lapis : AppTheme.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Global board, or one of the saved groups.
///
/// Hidden entirely when the player has no groups.
class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelect,
  });

  final List<PlayerGroup> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ScopeChip(
            label: 'Iedereen',
            active: selectedGroupId == null,
            onTap: () => onSelect(null),
          ),
          for (final group in groups)
            _ScopeChip(
              label: group.name,
              active: selectedGroupId == group.id,
              onTap: () => onSelect(group.id),
            ),
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // 44 high to tap, 36 high to see.
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 36,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppTheme.lapis : AppTheme.paperRaised,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(
                  color: active ? AppTheme.lapis : AppTheme.rule,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                  color: active ? AppTheme.inkInverted : AppTheme.inkSoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Podium
// ---------------------------------------------------------------------------

class _PodiumStyle {
  const _PodiumStyle({
    required this.ring,
    required this.text,
    required this.block,
    required this.blockHeight,
    required this.avatarSize,
  });

  final Color ring;
  final Color text;
  final Color block;
  final double blockHeight;
  final double avatarSize;

  static const gold = _PodiumStyle(
    ring: AppTheme.gold,
    text: AppTheme.goldText,
    block: Color(0xFFF0D48A),
    blockHeight: 70,
    avatarSize: 66,
  );
  static const silver = _PodiumStyle(
    ring: Color(0xFFA9AFBB),
    text: Color(0xFF5C6370),
    block: Color(0xFFD5D9E1),
    blockHeight: 46,
    avatarSize: 54,
  );
  static const bronze = _PodiumStyle(
    ring: Color(0xFFC98A5A),
    text: Color(0xFF8A5530),
    block: Color(0xFFE6C9B1),
    blockHeight: 32,
    avatarSize: 54,
  );

  static _PodiumStyle forPlace(int place) => switch (place) {
    1 => gold,
    2 => silver,
    _ => bronze,
  };
}

/// Top three: second left, first in the middle with a crown, third right.
class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.myEntryId});

  /// Up to three entries, best first.
  final List<LeaderboardEntry> entries;
  final String? myEntryId;

  @override
  Widget build(BuildContext context) {
    Widget slot(int place) {
      if (entries.length < place) return const Expanded(child: SizedBox());
      final entry = entries[place - 1];
      return Expanded(
        child: _PodiumSlot(
          entry: entry,
          place: place,
          isMe: myEntryId != null && entry.id == myEntryId,
        ),
      );
    }

    return Semantics(
      label: 'Top 3',
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            slot(2),
            const SizedBox(width: 10),
            slot(1),
            const SizedBox(width: 10),
            slot(3),
          ],
        ),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.place,
    required this.isMe,
  });

  final LeaderboardEntry entry;
  final int place;
  final bool isMe;

  static const String _crown =
      '<svg viewBox="0 0 30 22" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 18L5 5l6 6 4-9 4 9 6-6 2 13z" fill="#E9B12E" stroke="#A87C14" stroke-width="2" stroke-linejoin="round"/></svg>';

  @override
  Widget build(BuildContext context) {
    final style = _PodiumStyle.forPlace(place);
    final size = style.avatarSize;

    return Semantics(
      label:
          'Plek $place, ${entry.name}${isMe ? ' (jij)' : ''}, '
          '${_formatXp(entry.xp)} XP',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (place == 1) ...[
            SvgPicture.string(_crown, width: 30, height: 22),
            const SizedBox(height: 2),
          ],
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.paperRaised,
                  border: Border.all(color: style.ring, width: 3),
                ),
                child: ClipOval(
                  child: MascotAvatar(avatar: entry.avatar, size: size - 6),
                ),
              ),
              Positioned(
                bottom: -8,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: style.ring,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.paperRaised, width: 2),
                  ),
                  child: Text(
                    '$place',
                    style: const TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.inkInverted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w800,
              color: isMe ? AppTheme.lapis : AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatXp(entry.xp)} XP',
            maxLines: 1,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: style.text,
              fontFeatures: const [FontFeature.tabularFigures()],
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
// Place 4 and down
// ---------------------------------------------------------------------------

class _RestList extends StatefulWidget {
  const _RestList({super.key, required this.entries, required this.myIndex});

  /// The whole board, sorted, best first. Rows start at place 4.
  final List<LeaderboardEntry> entries;

  /// Index of the signed-in player in [entries], or -1.
  final int myIndex;

  /// Places shown before the list has to be expanded. Keeps a 100-player
  /// board from turning the page into an endless scroll.
  static const int collapsedLimit = 20;

  @override
  State<_RestList> createState() => _RestListState();
}

class _RestListState extends State<_RestList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final total = entries.length;
    final canCollapse = total > _RestList.collapsedLimit;
    final end = _expanded || !canCollapse ? total : _RestList.collapsedLimit;

    Widget row(int index) {
      final isMe = index == widget.myIndex;
      return _BoardRow(
        entry: entries[index],
        rank: index + 1,
        isMe: isMe,
        // XP needed to pass the player one place up.
        xpToNext: isMe && index > 0
            ? entries[index - 1].xp - entries[index].xp + 1
            : null,
      );
    }

    final rows = <Widget>[for (var i = 3; i < end; i++) row(i)];

    // The player's own row is pinned under a collapsed list, so their place
    // is never hidden behind "Toon alle".
    final myRowHidden = widget.myIndex >= end;
    if (myRowHidden) {
      rows
        ..add(const _GapRow())
        ..add(row(widget.myIndex));
    }

    if (canCollapse) {
      rows.add(
        _ShowMoreRow(
          expanded: _expanded,
          total: total,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
      );
    }

    return BqListCard(children: rows);
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({
    required this.entry,
    required this.rank,
    required this.isMe,
    this.xpToNext,
  });

  final LeaderboardEntry entry;
  final int rank;
  final bool isMe;
  final int? xpToNext;

  @override
  Widget build(BuildContext context) {
    final strong = isMe ? AppTheme.lapisStrong : AppTheme.inkSoft;
    final gap = xpToNext;

    return Semantics(
      label:
          'Plek $rank, ${entry.name}${isMe ? ' (jij)' : ''}, '
          '${_formatXp(entry.xp)} XP',
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
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: strong,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 12),
            MascotAvatar(avatar: entry.avatar, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStrong,
                  ),
                  if (gap != null)
                    Text(
                      'Nog ${_formatXp(gap)} XP tot plek ${rank - 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.sansFontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lapis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_formatXp(entry.xp)} XP',
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

/// Marks the jump between the visible rows and the player's pinned row.
class _GapRow extends StatelessWidget {
  const _GapRow();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox(
        height: 28,
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkFaint,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowMoreRow extends StatelessWidget {
  const _ShowMoreRow({
    required this.expanded,
    required this.total,
    required this.onTap,
  });

  final bool expanded;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: expanded ? 'Toon minder' : 'Toon alle $total spelers',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  expanded ? 'Toon minder' : 'Toon alle $total spelers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lapis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              RotatedBox(
                quarterTurns: expanded ? 3 : 1,
                child: const BqIcon(
                  BqIcons.chevronRight,
                  size: 16,
                  color: AppTheme.lapis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

/// A visitor can read the board but is not on it.
class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    return BqCard(
      child: Row(
        children: [
          const BqIconTile(
            background: AppTheme.goldTint,
            child: BqIcon(BqIcons.trophy, size: 22, color: AppTheme.goldText),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Met een gratis account telt je XP mee.',
              style: AppTheme.bodyMuted,
            ),
          ),
          const SizedBox(width: 10),
          BqButton(
            label: 'Inloggen',
            style: BqButtonStyle.tint,
            height: 44,
            expand: false,
            fontSize: 15,
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }
}

/// Signed in, but no entry on this board yet (new account, or no XP in the
/// selected period).
class _NotPlacedCard extends StatelessWidget {
  const _NotPlacedCard();

  @override
  Widget build(BuildContext context) {
    return const BqCard(
      color: AppTheme.lapisTint,
      borderColor: AppTheme.lapisSoft,
      child: Row(
        children: [
          BqIconTile(
            background: AppTheme.paperRaised,
            child: BqIcon(BqIcons.trophy, size: 22, color: AppTheme.lapis),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Je staat nog niet op deze ranglijst',
                  style: AppTheme.bodyStrong,
                ),
                Text(
                  'Speel een quiz om mee te doen.',
                  style: TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lapis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.period, required this.inGroup});

  final LeaderboardPeriod period;
  final bool inGroup;

  @override
  Widget build(BuildContext context) {
    final message = period == LeaderboardPeriod.month
        ? 'Deze maand heeft nog niemand${inGroup ? ' in deze groep' : ''} XP '
              'verdiend. Speel een quiz en sta bovenaan.'
        : 'Nog geen ranglijstdata beschikbaar.';

    return BqCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const BqIconTile(
            size: 48,
            radius: 12,
            background: AppTheme.goldTint,
            child: BqIcon(BqIcons.trophy, size: 26, color: AppTheme.goldText),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nog niemand op de ranglijst',
            textAlign: TextAlign.center,
            style: AppTheme.displaySmall,
          ),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: AppTheme.bodyMuted),
        ],
      ),
    );
  }
}
