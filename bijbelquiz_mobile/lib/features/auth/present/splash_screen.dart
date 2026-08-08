import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../onboarding/data/onboarding_storage.dart';
import '../present/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay to show logo
    await Future.delayed(const Duration(seconds: 2));

    final storage = ref.read(authStorageProvider);
    final token = await storage.getToken();
    final hasSession = token != null && token.isNotEmpty;

    if (hasSession) {
      // Links RevenueCat to the account so store purchases attach to this
      // user instead of an anonymous RevenueCat id.
      await ref.read(authControllerProvider.notifier).restoreSession();

      // A signed-in user never sees the onboarding again — it is a
      // first-run intro for visitors who still have to create an account.
      // Mark it seen so signing out later also skips it.
      await ref.read(onboardingStorageProvider).markSeen();
      if (mounted) context.go('/home');
      return;
    }

    final hasSeenOnboarding = await ref
        .read(onboardingStorageProvider)
        .hasSeen();
    if (!mounted) return;
    context.go(hasSeenOnboarding ? '/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    // Paper background with the site wordmark — the site has no dark hero.
    return const Scaffold(
      backgroundColor: AppTheme.paper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BijbelQuizWordmark(fontSize: 34),
            SizedBox(height: 18),
            Text('TEST JOUW KENNIS VAN DE BIJBEL', style: AppTheme.overline),
            SizedBox(height: 44),
            AppLoader(size: 20),
          ],
        ),
      ),
    );
  }
}

/// `<span class="font-display text-xl font-semibold tracking-[-0.02em]
///   text-ink">Bijbel<span class="text-lapis">Quiz</span></span>`
class BijbelQuizWordmark extends StatelessWidget {
  const BijbelQuizWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: AppTheme.displayFontName,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: fontSize * -0.02,
          color: AppTheme.ink,
        ),
        children: const [
          TextSpan(text: 'Bijbel'),
          TextSpan(
            text: 'Quiz',
            style: TextStyle(color: AppTheme.lapis),
          ),
        ],
      ),
    );
  }
}
