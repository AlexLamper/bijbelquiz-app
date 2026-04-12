import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'profile_provider.dart';
import '../../auth/present/auth_controller.dart';
import '../data/profile_model.dart';

// Brand Colors
const Color brandDark = Color(0xFF131D2B); // The darker blue requested
const Color textMuted = Color(0xFF7C7C80);
const Color borderLight = Color(0xFFE5E5EA);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white to let cards pop
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
        },
        child: profileAsync.when(
          data: (profile) => _buildProfileBody(context, ref, profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Fout bij laden van profiel:\n$err',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBody(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) {
    final userInitial = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : 'U';

    final currentXpInLevel = profile.xp % 500;
    final progressPercentage = currentXpInLevel / 500.0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // 1. Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: borderLight, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          userInitial,
                          style: const TextStyle(
                            fontSize: 36,
                            color: brandDark,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: brandDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 15,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Top Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'TOTALE XP',
                      value: profile.xp.toString(),
                      icon: Icons.emoji_events,
                      iconColor: brandDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'REEKS',
                      value: profile.streak.toString(),
                      icon: Icons.local_fire_department,
                      iconColor: const Color(0xFFF5A623), // Gold/Orange flame
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Level Progress Card
              LevelProgressCard(
                level: profile.level,
                levelTitle: profile.levelTitle,
                currentXp: profile.xp,
                requiredXp: ((profile.xp ~/ 500) + 1) * 500, // Total XP needed for next level
                progress: progressPercentage,
              ),
              const SizedBox(height: 16),

              // 4. Secondary Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Quizzen Gespeeld',
                      value: profile.recentProgress.length.toString(),
                      isTitleCase: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: StatCard(
                      title: 'Gem. Score',
                      value: '33%', // Replace with dynamic average score if available
                      isTitleCase: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Badges Card
              BadgesCard(
                earnedBadges: profile.badges.length,
                totalBadges: 8,
              ),
              const SizedBox(height: 32),

              // 6. Premium Upsell
              if (!profile.isPremium) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderLight, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Ontdek Premium',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                color: brandDark, // Applied Darker Blue
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Krijg onbeperkt toegang',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/premium');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Probeer', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 7. Settings / Actions
              const Text(
                'Instellingen & Acties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: brandDark, // Applied Darker Blue
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderLight, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Uitloggen',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      trailing: const Icon(Icons.logout, color: Colors.red, size: 20),
                      onTap: () async {
                        final storage = ref.read(authStorageProvider);
                        await storage.deleteToken();
                        ref.invalidate(profileProvider);
                        ref.invalidate(authControllerProvider);
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable UI Components ---

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isTitleCase;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.isTitleCase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTitleCase ? title : title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isTitleCase ? 0 : 0.5,
                  color: isTitleCase ? textMuted : brandDark,
                ),
              ),
              if (icon != null) Icon(icon, size: 18, color: iconColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

class LevelProgressCard extends StatelessWidget {
  final int level;
  final String levelTitle;
  final int currentXp;
  final int requiredXp;
  final double progress;

  const LevelProgressCard({
    super.key,
    required this.level,
    required this.levelTitle,
    required this.currentXp,
    required this.requiredXp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIVEAU $level',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: brandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelTitle,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: brandDark,
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Custom Progress Bar Track
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: brandDark, 
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$currentXp / $requiredXp XP naar volgend niveau',
            style: const TextStyle(
              fontSize: 13,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgesCard extends StatelessWidget {
  final int earnedBadges;
  final int totalBadges;

  const BadgesCard({
    super.key,
    required this.earnedBadges,
    required this.totalBadges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: brandDark, // Applied Darker Blue
                ),
              ),
              Text(
                '$earnedBadges / $totalBadges verdiend',
                style: const TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBadgeItem(
                  isActive: earnedBadges > 0,
                  icon: Icons.pets, 
                ),
                const SizedBox(width: 12),
                _buildBadgeItem(
                  isActive: earnedBadges > 1,
                  icon: Icons.search,
                ),
                const SizedBox(width: 12),
                _buildBadgeItem(
                  isActive: earnedBadges > 2,
                  icon: Icons.star,
                ),
                const SizedBox(width: 12),
                _buildBadgeItem(
                  isActive: earnedBadges > 3,
                  icon: Icons.emoji_events,
                ),
                const SizedBox(width: 12),
                _buildBadgeItem(
                  isActive: earnedBadges > 4,
                  icon: Icons.local_fire_department,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({required bool isActive, required IconData icon}) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFD4AF37) : borderLight, // Gold if active
          width: isActive ? 2 : 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: isActive ? brandDark : const Color(0xFFD1D1D6),
        ),
      ),
    );
  }
}