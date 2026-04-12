import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/present/splash_screen.dart';
import '../../features/auth/present/login_screen.dart';
import '../../features/auth/present/register_screen.dart';
import '../../features/dashboard/present/home_screen.dart';
import '../../features/quiz/present/library_screen.dart';
import '../../features/leaderboard/present/leaderboard_screen.dart';
import '../../features/profile/present/profile_screen.dart';
import '../../features/premium/present/premium_screen.dart';
import '../../features/quiz/present/quiz_detail_screen.dart';
import '../../features/quiz/present/quiz_player_screen.dart';

// Main Scaffold representing the Bottom Navigation persistence
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int currentIndex = _calculateSelectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF8E8E93),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Huis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), // Or book_outlined
              activeIcon: Icon(Icons.book),
              label: 'Bibliotheek',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Ranglijst',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profiel',
            ),
          ],
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/quizzes')) return 1;
    if (location.startsWith('/leaderboard')) return 2;
    if (location.startsWith('/profile')) return 3;
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
        context.go('/profile');
        break;
    }
  }
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
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
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
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
