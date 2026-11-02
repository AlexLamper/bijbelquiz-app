import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics.dart';
import '../config/app_config.dart';
import '../config/preview_config.dart';
import '../theme/app_theme.dart';
import '../ui/bq.dart';

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
import '../../features/premium/present/premium_intro_screen.dart';
import '../../features/multiplayer/present/play_together_screen.dart';
import '../../features/multiplayer/present/multiplayer_lobby_screen.dart';
import '../../features/multiplayer/present/multiplayer_game_screen.dart';
import '../../features/multiplayer/present/multiplayer_results_screen.dart';
import '../../features/quiz/present/quiz_detail_screen.dart';
import '../../features/quiz/present/quiz_passage_screen.dart';
import '../../features/quiz/present/quiz_player_screen.dart';
import '../../features/admin/present/admin_screen.dart';
import '../../features/admin/present/admin_user_detail_screen.dart';
import '../../features/duels/present/new_duel_screen.dart';
import '../../features/duels/present/duel_play_screen.dart';
import '../../features/settings/present/settings_screen.dart';

/// The tab shell: Home, Quizzen, Samen spelen, Ranglijst, Profiel.
/// A page inside the tab shell: switching tabs swaps the screen with a short
/// crossfade instead of a push animation sliding a page over the last one.
CustomTransitionPage<void> _tabPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
  );
}

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: Scaffold(
        backgroundColor: AppTheme.paper,
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppTheme.paperRaised,
            border: Border(top: BorderSide(color: AppTheme.rule, width: 1)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
      ),
    );
  }

  static const List<_NavItemData> _items = [
    _NavItemData(BqIcons.home, BqIcons.homeFilled, 'Home', '/home'),
    _NavItemData(BqIcons.book, BqIcons.book, 'Quizzen', '/quizzes'),
    // Samen spelen took the place of Duels: a group around one phone or one
    // table plays far more than two strangers taking turns.
    _NavItemData(BqIcons.users, BqIcons.users, 'Samen', '/play-together'),
    _NavItemData(BqIcons.trophy, BqIcons.trophy, 'Ranglijst', '/leaderboard'),
    _NavItemData(BqIcons.user, BqIcons.user, 'Profiel', '/profile'),
  ];

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/quizzes')) return 1;
    if (location.startsWith('/play-together')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_items[index].path);
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label, this.path);

  final String icon;
  final String activeIcon;
  final String label;
  final String path;
}

/// Tab item: the active one gets a soft lapis pill behind its icon.
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
    final color = active ? AppTheme.lapis : AppTheme.inkMuted;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.transparent,
        highlightColor: AppTheme.ruleSoft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 56,
                      height: 30,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.lapisTint : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    BqIcon(
                      active ? item.activeIcon : item.icon,
                      size: 22,
                      color: color,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
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

  // The Duels tab is gone; anything still pointing at its list (an old
  // notification, the end of a duel that was already running) lands on the
  // tab that took its place. Running duels and duel invites still open.
  if (state.uri.path == '/duels') return '/play-together';

  // Duel invite: `/duel/<token>` from the website opens the challenge.
  if (segments.length >= 2 && segments.first == 'duel') {
    return Uri(
      path: '/duels/new',
      queryParameters: {'invite': segments[1]},
    ).toString();
  }

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
            pageBuilder: (context, state) =>
                _tabPage(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/quizzes',
            pageBuilder: (context, state) =>
                _tabPage(state, const LibraryScreen()),
          ),
          // Browsing by book stays inside the tab shell, under Quizzen.
          GoRoute(
            path: '/quizzes/boeken',
            builder: (context, state) => const LibraryBooksScreen(),
          ),
          GoRoute(
            path: '/quizzes/boek/:book',
            builder: (context, state) =>
                LibraryBookScreen(bookKey: state.pathParameters['book']!),
          ),
          GoRoute(
            path: '/leaderboard',
            pageBuilder: (context, state) =>
                _tabPage(state, const LeaderboardScreen()),
          ),
          GoRoute(
            path: '/play-together',
            pageBuilder: (context, state) =>
                _tabPage(
                  state,
                  PlayTogetherScreen(
                    initialQuizId: state.uri.queryParameters['quiz'],
                  ),
                ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _tabPage(state, const ProfileScreen()),
          ),
          GoRoute(
            path: '/profile/achievements',
            pageBuilder: (context, state) =>
                _tabPage(state, const ProfileAchievementsScreen()),
          ),
        ],
      ),
      GoRoute(
        // Outside the shell on purpose: it is opened from the profile and from
        // settings, and pushing a shell child from a screen that is not in the
        // shell builds a second tab bar around it.
        path: '/profile/edit',
        builder: (context, state) => const ProfileIdentityScreen(),
      ),
      GoRoute(
        path: '/duels/new',
        builder: (context, state) => const NewDuelScreen(),
      ),
      GoRoute(
        path: '/duels/:id',
        builder: (context, state) =>
            DuelPlayScreen(duelId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/group-license',
        builder: (context, state) => const GroupLicenseScreen(),
      ),
      GoRoute(
        // Admin-only; the screen itself checks the profile role and the
        // server returns 403 to non-admins, so no router guard is needed.
        path: '/beheer',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        // One account in Beheer. Same guard as /beheer: the screen checks the
        // profile role and the server answers 403 to non-admins.
        path: '/beheer/gebruikers/:id',
        builder: (context, state) =>
            AdminUserDetailScreen(userId: state.pathParameters['id']!),
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
        path: '/premium-intro',
        builder: (context, state) => PremiumIntroScreen(
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
