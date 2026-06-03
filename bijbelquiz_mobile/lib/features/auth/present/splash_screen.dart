import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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
      if (mounted) context.go('/home');
      return;
    }

    // No session: show the intro flow once before the login screen.
    final hasSeenOnboarding = await ref
        .read(onboardingStorageProvider)
        .hasSeen();

    if (mounted) {
      context.go(hasSeenOnboarding ? '/login' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo tile on a soft glow
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/images/logo-dark.png',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.brand,
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bijbelquiz',
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Test jouw kennis van de Bijbel',
                style: TextStyle(
                  fontFamily: AppTheme.sansFontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC7D2F2),
                ),
              ),
              const SizedBox(height: 44),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
