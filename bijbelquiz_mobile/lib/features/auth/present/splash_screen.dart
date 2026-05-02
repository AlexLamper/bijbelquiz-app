import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
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

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Technically, fetch /api/user here in full implementation
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Matches the dark navy brand color used across the app
    const Color brandDark = Color(0xFF131D2B);

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo area
            Image.asset(
              'assets/images/logo-dark.png',
              width: 120,
              height: 120,
              // If the image fails to load, show the exact CSS-styled logo from the Home screen
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: brandDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title matching the app's headers
            const Text(
              'Bijbelquiz',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: brandDark,
              ),
            ),

            const SizedBox(height: 48),

            // Optional: A subtle loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(brandDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
