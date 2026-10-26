import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/bq.dart';
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

      // A signed-in user never sees the onboarding again - it is a
      // first-run intro. Mark it seen so signing out later also skips it.
      await ref.read(onboardingStorageProvider).markSeen();
      if (mounted) context.go('/home');
      return;
    }

    // No account is needed to use the app. The intro runs once, on the first
    // launch; after that a visitor lands on the home screen like anybody
    // else. Signing in is offered on the profile tab and after a finished
    // quiz, where there is something to keep.
    final hasSeenOnboarding = await ref
        .read(onboardingStorageProvider)
        .hasSeen();
    if (!mounted) return;
    context.go(hasSeenOnboarding ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    // The welcome screen's logo lockup on the paper background, while the
    // stored session is checked.
    return const Scaffold(
      backgroundColor: AppTheme.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BqLogo(markSize: 64, fontSize: 36),
            SizedBox(height: 14),
            Text(
              'Hoe goed ken jij de Bijbel?',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.inkMuted,
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppTheme.lapis,
              ),
            ),
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
