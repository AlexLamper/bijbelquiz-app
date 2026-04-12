import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/leaderboard_repository.dart';
import '../../../core/ui/server_image.dart';

// Brand Colors derived from the screenshot
const Color brandDark = Color(0xFF131A26); // Dark Navy background for header
const Color bgLight = Color(0xFFFAFAFC); // Off-white for the list background
const Color textMuted = Color(0xFF8E8E93);
const Color borderLight = Color(0xFFE5E5EA);

const Color goldColor = Color(0xFFD4AF37);
const Color silverColor = Color(0xFFA8A8A8);
const Color bronzeColor = Color(0xFFCD7F32);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: bgLight,
      body: leaderboardAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text("Geen ranglijst data beschikbaar."));
          }

          // Safely extract top 3 for the podium
          final top1 = entries.isNotEmpty ? entries[0] : null;
          final top2 = entries.length > 1 ? entries[1] : null;
          final top3 = entries.length > 2 ? entries[2] : null;

          return Column(
            children: [
              // Custom Dark Header with Podium
              Container(
                width: double.infinity,
                color: brandDark,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Ranglijst',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null)
                            Expanded(child: _PodiumItem(entry: top2, rank: 2)),
                          if (top1 != null)
                            Expanded(child: _PodiumItem(entry: top1, rank: 1)),
                          if (top3 != null)
                            Expanded(child: _PodiumItem(entry: top3, rank: 3)),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Scrollable List for the rest of the players
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: entries.length > 3 ? entries.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final entry = entries[index + 3];
                    final rank = index + 4;
                    return _LeaderboardListItem(entry: entry, rank: rank);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Fout bij laden van ranglijst: $err'),
              TextButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final dynamic entry; // Replace with LeaderboardEntry model type
  final int rank;

  const _PodiumItem({
    required this.entry,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final double avatarSize = isFirst ? 80.0 : 64.0;
    
    final Color ringColor = rank == 1 
        ? goldColor 
        : (rank == 2 ? silverColor : bronzeColor);

    final String initial = entry.name.isNotEmpty 
        ? entry.name[0].toUpperCase() 
        : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Outer Ring
            Container(
              width: avatarSize + 12,
              height: avatarSize + 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
              ),
              child: Center(
                // Inner Avatar
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: const Color(0xFF2A3441), // Fallback dark grey
                  backgroundImage: (entry.image != null && entry.image!.isNotEmpty)
                      ? NetworkImage(ServerImage.getFullUrl(entry.image!))
                      : null,
                  child: (entry.image == null || entry.image!.isEmpty)
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: isFirst ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            
            // Lightning Bolt for #1
            if (isFirst)
              Positioned(
                top: -18,
                child: Icon(Icons.bolt, color: ringColor, size: 32),
              ),

            // Rank Badge
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: ringColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            entry.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // XP
        Text(
          '${entry.xp} XP',
          style: const TextStyle(
            color: textMuted,
            fontSize: 12,
          ),
        ),
        // Add a bit of bottom spacing for rank 2 & 3 to slightly stagger them upward
        if (!isFirst) const SizedBox(height: 10),
      ],
    );
  }
}

class _LeaderboardListItem extends StatelessWidget {
  final dynamic entry; // Replace with LeaderboardEntry model type
  final int rank;

  const _LeaderboardListItem({
    required this.entry,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = entry.name.isNotEmpty 
        ? entry.name[0].toUpperCase() 
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black, // Matching the screenshot's dark placeholder
            backgroundImage: (entry.image != null && entry.image!.isNotEmpty)
                ? NetworkImage(ServerImage.getFullUrl(entry.image!))
                : null,
            child: (entry.image == null || entry.image!.isEmpty)
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Details (Name & XP)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.xp} XP',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Trailing Arrow
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD1D1D6), // Light grey chevron
          ),
        ],
      ),
    );
  }
}