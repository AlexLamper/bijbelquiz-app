import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/preview_config.dart';
import '../theme/app_theme.dart';

import '../../features/auth/present/splash_screen.dart';
import '../../features/onboarding/present/onboarding_screen.dart';
import '../../features/auth/present/login_screen.dart';
import '../../features/auth/present/register_screen.dart';
import '../../features/dashboard/present/home_screen.dart';
import '../../features/quiz/present/library_screen.dart';
import '../../features/leaderboard/present/leaderboard_screen.dart';
import '../../features/profile/present/profile_screen.dart';
import '../../features/profile/present/profile_achievements_screen.dart';
import '../../features/premium/present/premium_screen.dart';
import '../../features/multiplayer/present/play_together_screen.dart';
import '../../features/multiplayer/present/multiplayer_lobby_screen.dart';
import '../../features/multiplayer/present/multiplayer_game_screen.dart';
import '../../features/multiplayer/present/multiplayer_results_screen.dart';
import '../../features/quiz/present/quiz_detail_screen.dart';
import '../../features/quiz/present/quiz_player_screen.dart';

// Main Scaffold representing the Bottom Navigation persistence
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    // `border-t border-rule bg-paper-raised` — the site's mobile tab bar.
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.paperRaised,
          border: Border(top: BorderSide(color: AppTheme.rule, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: _items[i],
                      active: currentIndex == i,
                      onTap: () => _onItemTapped(i, context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<_NavItemData> _items = [
    _NavItemData(Icons.home_outlined, Icons.home, 'Home'),
    _NavItemData(Icons.menu_book_outlined, Icons.menu_book, 'Quizzen'),
    _NavItemData(Icons.leaderboard_outlined, Icons.leaderboard, 'Ranglijst'),
    _NavItemData(Icons.groups_outlined, Icons.groups, 'Samen'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profiel'),
  ];

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/quizzes')) return 1;
    if (location.startsWith('/leaderboard')) return 2;
    if (location.startsWith('/play-together')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/quizzes');
        break;
      case 2:
        context.go('/leaderboard');
        break;
      case 3:
        context.go('/play-together');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Tab item — active is solid ink with a `bg-lapis` marker rule above it,
/// matching the underline the site draws under the active desktop nav link
/// (`after:absolute after:bottom-0 after:h-px after:bg-lapis`).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItemData item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.ink : AppTheme.inkMuted;
    return InkWell(
      onTap: onTap,
      splashColor: AppTheme.paperSunken,
      highlightColor: AppTheme.paperSunken,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: 22,
            color: active ? AppTheme.lapis : Colors.transparent,
          ),
          const SizedBox(height: 11),
          Icon(active ? item.activeIcon : item.icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 10,
              height: 1,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Design-preview mode skips splash/onboarding/login and lands on the
    // dashboard so the styling can be reviewed straight away.
    initialLocation: PreviewConfig.enabled ? '/home' : '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/quizzes',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/play-together',
            builder: (context, state) => const PlayTogetherScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/achievements',
            builder: (context, state) => const ProfileAchievementsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/play-together/room/:roomCode',
        builder: (context, state) =>
            MultiplayerLobbyScreen(roomCode: state.pathParameters['roomCode']!),
      ),
      GoRoute(
        path: '/play-together/room/:roomCode/play',
        builder: (context, state) =>
            MultiplayerGameScreen(roomCode: state.pathParameters['roomCode']!),
      ),
      GoRoute(
        path: '/play-together/room/:roomCode/results',
        builder: (context, state) => MultiplayerResultsScreen(
          roomCode: state.pathParameters['roomCode']!,
        ),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) =>
            QuizDetailScreen(idOrSlug: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quiz/:id/play',
        builder: (context, state) =>
            QuizPlayerScreen(idOrSlug: state.pathParameters['id']!),
      ),
    ],
  );
});
