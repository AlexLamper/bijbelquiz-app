import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/server_image.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_entry.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardPeriod _selectedRange = LeaderboardPeriod.week;

  Future<void> _refreshData() async {
    ref.invalidate(leaderboardByPeriodProvider(_selectedRange));
    await ref.read(leaderboardByPeriodProvider(_selectedRange).future);
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardByPeriodProvider(_selectedRange));

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: leaderboardAsync.when(
            data: (entries) {
              final sortedEntries = [...entries]
                ..sort((a, b) => b.xp.compareTo(a.xp));

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const Text(
                    'Ranglijst',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTheme.sansFontName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RangeSelector(
                    selectedRange: _selectedRange,
                    onSelect: (value) {
                      setState(() {
                        _selectedRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (sortedEntries.isNotEmpty)
                    _TopPlayerCard(
                      entry: sortedEntries.first,
                      periodLabel: _selectedRange.displayName.toLowerCase(),
                    )
                  else
                    const _EmptyLeaderboardState(),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: sortedEntries.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'Nog geen ranglijstdata beschikbaar.',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                          )
                        : Column(
                            children: List.generate(sortedEntries.length, (
                              index,
                            ) {
                              final entry = sortedEntries[index];
                              return _LeaderboardRow(
                                entry: entry,
                                rank: index + 1,
                                isLast: index == sortedEntries.length - 1,
                              );
                            }),
                          ),
                  ),
                ],
              );
            },
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 260),
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (err, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 120),
                const Icon(
                  Icons.error_outline,
                  size: 52,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Fout bij laden van ranglijst: $err',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onSelect});

  final LeaderboardPeriod selectedRange;
  final ValueChanged<LeaderboardPeriod> onSelect;

  static const Map<LeaderboardPeriod, String> _labels = {
    LeaderboardPeriod.week: 'Deze Week',
    LeaderboardPeriod.month: 'Deze Maand',
    LeaderboardPeriod.all: 'Altijd',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: _labels.entries.map((entry) {
          final active = selectedRange == entry.key;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppTheme.filterActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : AppTheme.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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

class _TopPlayerCard extends StatelessWidget {
  const _TopPlayerCard({required this.entry, required this.periodLabel});

  final LeaderboardEntry entry;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D86DB), Color(0xFF8EA5F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Avatar(imageUrl: entry.image, name: entry.name, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nummer 1',
                  style: TextStyle(
                    color: Color(0xFFEAF0FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  periodLabel,
                  style: const TextStyle(
                    color: Color(0xFFDDE7FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                '${entry.xp} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: AppTheme.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _Avatar(imageUrl: entry.image, name: entry.name, radius: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.xp} punten',
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${entry.xp} XP',
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on LeaderboardPeriod {
  String get displayName {
    switch (this) {
      case LeaderboardPeriod.week:
        return 'Deze week';
      case LeaderboardPeriod.month:
        return 'Deze maand';
      case LeaderboardPeriod.all:
        return 'All-time';
    }
  }
}

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
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE9EDF8),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          color: AppTheme.ink,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty || imageUrl == 'null') {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        ServerImage.getFullUrl(imageUrl!),
        width: radius * 2,
        height: radius * 2,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Text(
        'Nog geen spelers gevonden.',
        style: TextStyle(color: AppTheme.muted),
      ),
    );
  }
}
