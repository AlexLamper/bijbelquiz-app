import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics.dart';
import '../config/app_config.dart';
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
import '../../features/profile/present/profile_identity_screen.dart';
import '../../features/premium/present/group_license_screen.dart';
import '../../features/premium/present/premium_screen.dart';
import '../../features/multiplayer/present/play_together_screen.dart';
import '../../features/multiplayer/present/multiplayer_lobby_screen.dart';
import '../../features/multiplayer/present/multiplayer_game_screen.dart';
import '../../features/multiplayer/present/multiplayer_results_screen.dart';
import '../../features/quiz/present/quiz_detail_screen.dart';
import '../../features/quiz/present/quiz_passage_screen.dart';
import '../../features/quiz/present/quiz_player_screen.dart';

// Main Scaffold representing the Bottom Navigation persistence
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    // `border-t border-rule bg-paper-raised` - the site's mobile tab bar.
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
    // `menu_book` read as "read a chapter", not "answer questions", and sat
    // too close to the Bible imagery used elsewhere in the app.
    _NavItemData(Icons.quiz_outlined, Icons.quiz, 'Quizzen'),
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

/// Tab item - active is solid ink with a `bg-lapis` marker rule above it,
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

/// Maps an incoming website invite URL onto the app's own routes.
///
/// The shared link is `/samen-spelen/CODE/lobby?bron=uitnodiging`, which is a
/// real page on bijbelquiz.com so that somebody without the app still lands
/// somewhere useful. When the app *is* installed the OS hands us that same
/// path, and this turns it into `/play-together/room/CODE`.
///
/// `bron` is preserved so the join is still attributed to the invite in the
/// funnel; dropping it here would make every deep-linked join look like a
/// typed code.
String? _redirectWebInviteLinks(BuildContext context, GoRouterState state) {
  final segments = state.uri.pathSegments;
  if (segments.isEmpty || segments.first != 'samen-spelen') return null;

  // `/samen-spelen` on its own is the entry page, not a room.
  if (segments.length < 2) return '/play-together';

  final code = segments[1].toUpperCase();
  final viaInvite =
      state.uri.queryParameters[AppConfig.inviteSourceParam] ==
      AppConfig.inviteSourceValue;
  final query = viaInvite
      ? '?${AppConfig.inviteSourceParam}=${AppConfig.inviteSourceValue}'
      : '';

  final base = '/play-together/room/$code';

  // The website uses Dutch path segments for the phases; the app uses English
  // ones. Anything else - including `/lobby` - is the lobby.
  final phase = segments.length > 2 ? segments[2] : 'lobby';
  switch (phase) {
    case 'spel':
      return '$base/play$query';
    case 'uitslag':
      return '$base/results$query';
    default:
      return '$base$query';
  }
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Design-preview mode skips splash/onboarding/login and lands on the
    // dashboard so the styling can be reviewed straight away.
    initialLocation: PreviewConfig.enabled ? '/home' : '/',
    // An invite link is a *website* URL - the app has no say in its shape,
    // because it also has to work for somebody without the app. Translating it
    // here is what lets one link serve both.
    redirect: _redirectWebInviteLinks,
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
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const ProfileIdentityScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/group-license',
        builder: (context, state) => const GroupLicenseScreen(),
      ),
      GoRoute(
        path: '/premium',
        // `?reden=` names the surface that raised the paywall, so the screen
        // can open on what the player was stopped from doing and the funnel
        // can attribute the sale to it.
        builder: (context, state) => PremiumScreen(
          trigger: state.uri.queryParameters['reden'] ?? PaywallTrigger.direct,
        ),
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
        path: '/quiz/:id/lezen',
        builder: (context, state) =>
            QuizPassageScreen(idOrSlug: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quiz/:id/play',
        builder: (context, state) =>
            QuizPlayerScreen(idOrSlug: state.pathParameters['id']!),
      ),
    ],
  );
});
