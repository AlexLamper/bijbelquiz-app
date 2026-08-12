import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/server_image.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

/// Mirrors https://www.bijbelquiz.com/ranglijst
///
/// eyebrow -> `font-display text-[32px]` heading -> lead -> period buttons ->
/// `border-y border-rule` stat band -> `rounded-lg border border-rule` table.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardPeriod _selectedRange = LeaderboardPeriod.all;

  Future<void> _refreshData() async {
    ref.invalidate(leaderboardByPeriodProvider(_selectedRange));
    await ref.read(leaderboardByPeriodProvider(_selectedRange).future);
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(
      leaderboardByPeriodProvider(_selectedRange),
    );

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.ink,
          backgroundColor: AppTheme.paperRaised,
          onRefresh: _refreshData,
          child: leaderboardAsync.when(
            data: (entries) {
              final sortedEntries = [...entries]
                ..sort((a, b) => b.xp.compareTo(a.xp));
              final topXp = sortedEntries.isEmpty ? 0 : sortedEntries.first.xp;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const GradientHeader(
                    eyebrow: 'Ranglijst',
                    title: 'Top spelers',
                    subtitle:
                        'Verdien XP door quizzen te spelen en stijg in de '
                        'ranglijst.',
                  ),
                  const SizedBox(height: 28),
                  _RangeSelector(
                    selectedRange: _selectedRange,
                    onSelect: (value) {
                      setState(() {
                        _selectedRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  StatStrip(
                    stacked: true,
                    items: [
                      StatItem(
                        value: '${sortedEntries.length}',
                        label: 'Deelnemers',
                      ),
                      StatItem(value: '$topXp', label: 'Top XP'),
                      StatItem(
                        value: _selectedRange.shortLabel,
                        label: 'Periode',
                        ruleColor: AppTheme.positive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (sortedEntries.isEmpty)
                    const _EmptyLeaderboardState()
                  else
                    _LeaderboardTable(
                      // Collapse again when the player switches period.
                      key: ValueKey(_selectedRange),
                      entries: sortedEntries,
                    ),
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 260), AppLoader()],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 100),
                AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Ranglijst kon niet laden',
                  description: '$err',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `h-9 rounded-md border-rule bg-paper-raised px-4 text-ink` /
/// active `h-9 rounded-md bg-ink px-4 text-ink-inverted`
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onSelect});

  final LeaderboardPeriod selectedRange;
  final ValueChanged<LeaderboardPeriod> onSelect;

  static const Map<LeaderboardPeriod, String> _labels = {
    LeaderboardPeriod.month: 'Maandelijks',
    LeaderboardPeriod.all: 'All-time',
  };

  @override
  Widget build(BuildContext context) {
    // Scrollable so the three labels never overflow on narrow phones.
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _labels.entries.map((entry) {
          final active = selectedRange == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: active ? AppTheme.ink : AppTheme.paperRaised,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => onSelect(entry.key),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: active ? AppTheme.ink : AppTheme.rule,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontFamily: AppTheme.sansFontName,
                      color: active ? AppTheme.inkInverted : AppTheme.ink,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LeaderboardTable extends StatefulWidget {
  const _LeaderboardTable({super.key, required this.entries});

  final List<LeaderboardEntry> entries;

  /// Rows shown before the list has to be expanded. Keeps a 100-player board
  /// from turning the page into an endless scroll.
  static const int collapsedLimit = 20;

  @override
  State<_LeaderboardTable> createState() => _LeaderboardTableState();
}

class _LeaderboardTableState extends State<_LeaderboardTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.entries.length;
    final canCollapse = total > _LeaderboardTable.collapsedLimit;
    final visible = _expanded || !canCollapse
        ? widget.entries
        : widget.entries.take(_LeaderboardTable.collapsedLimit).toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Column(
        children: [
          // `border-b border-rule px-5 py-3 text-[10px] uppercase
          //  tracking-[0.16em] text-ink-muted`
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.rule)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                SizedBox(
                  width: 44,
                  child: Text('POS', style: AppTheme.overline),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('SPELER', style: AppTheme.overline)),
                Text('XP', style: AppTheme.overline),
              ],
            ),
          ),
          for (var i = 0; i < visible.length; i++)
            _LeaderboardRow(
              entry: visible[i],
              rank: i + 1,
              isLast: !canCollapse && i == visible.length - 1,
            ),
          if (canCollapse)
            _ShowMoreRow(
              expanded: _expanded,
              total: total,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
        ],
      ),
    );
  }
}

/// Footer row of the table — `border-t border-rule` with a centred label, so
/// expanding reads as part of the table rather than as a floating button.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.paperSunken,
        splashColor: AppTheme.paperSunken,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  expanded ? 'TOON MINDER' : 'TOON ALLE $total SPELERS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.overline.copyWith(color: AppTheme.ink),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: AppTheme.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.rank,
    required this.isLast,
  });

  final LeaderboardEntry entry;
  final int rank;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    // `inline-flex h-8 min-w-8 items-center justify-center border px-1
    //  text-xs font-semibold` — deliberately square, no radius.
    final isLeader = rank == 1;
    final badgeBg = isLeader ? AppTheme.lapisTint : AppTheme.paperSunken;
    final badgeBorder = isLeader
        ? AppTheme.lapis.withValues(alpha: 0.35)
        : AppTheme.rule;
    final badgeFg = isLeader ? AppTheme.lapis : AppTheme.inkSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.rule)),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              border: Border.all(color: badgeBorder),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeFg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Avatar(imageUrl: entry.image, name: entry.name, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyStrong,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${entry.xp}',
            style: AppTheme.bodyStrong.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

extension on LeaderboardPeriod {
  String get shortLabel {
    switch (this) {
      case LeaderboardPeriod.month:
        return 'Maand';
      case LeaderboardPeriod.all:
        return 'Altijd';
    }
  }
}

/// Square-ish avatar with a hairline border — the site never uses drop shadows
/// and keeps photos inside a `ring-1 ring-rule` frame.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.name,
    required this.radius,
  });

  final String? imageUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.paperSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTheme.displayFontName,
          color: AppTheme.inkSoft,
          fontSize: radius * 0.85,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty || imageUrl == 'null') {
      return fallback;
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.paperSunken,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Image.network(
        ServerImage.getFullUrl(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _EmptyLeaderboardState extends StatelessWidget {
  const _EmptyLeaderboardState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Text(
        'Nog geen ranglijstdata beschikbaar.',
        style: AppTheme.bodyMuted,
      ),
    );
  }
}
