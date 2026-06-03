import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/present/auth_controller.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.body,
    required this.highlights,
  });

  final IconData icon;
  final String badge;
  final String title;
  final String body;
  final List<String> highlights;
}

const List<_OnboardingPageData> _pages = [
  _OnboardingPageData(
    icon: Icons.menu_book_rounded,
    badge: 'Welkom',
    title: 'Hoe goed ken jij\nde Bijbel?',
    body:
        'Ontdek het met tientallen quizzen. Test je kennis, daag jezelf uit '
        'en leer elke dag iets nieuws over Gods Woord.',
    highlights: [
      'Tientallen quizzen in elke categorie',
      'Van makkelijk tot uitdagend',
    ],
  ),
  _OnboardingPageData(
    icon: Icons.emoji_events_rounded,
    badge: 'Groei',
    title: 'Klim naar de top\nvan de ranglijst',
    body:
        'Verdien punten bij elke vraag, bouw een dagelijkse streak op en '
        'concurreer met spelers uit het hele land.',
    highlights: [
      'Dagelijkse streaks en prestaties',
      'Vergelijk je score op de ranglijst',
    ],
  ),
  _OnboardingPageData(
    icon: Icons.groups_2_rounded,
    badge: 'Samen',
    title: 'Speel samen\nmet vrienden',
    body:
        'Speciaal ontworpen voor groepen — van gezin tot jeugdvereniging. '
        'Host een room en speel live tegelijk met tot 20 spelers.',
    highlights: [
      'Live multiplayer met één kamercode',
      'Iedereen krijgt dezelfde vragen en timer',
    ],
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    // TEMP (testing): onboarding is shown on every launch and the seen-flag is
    // not persisted. Re-enable `onboardingStorageProvider.markSeen()` before
    // release. Route to home if already logged in, otherwise to login.
    final token = await ref.read(authStorageProvider).getToken();
    final hasSession = token != null && token.isNotEmpty;
    if (mounted) context.go(hasSession ? '/home' : '/login');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: brand + skip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bijbelquiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isLast ? 0 : 1,
                      child: TextButton(
                        onPressed: _isLast ? null : _finish,
                        child: const Text(
                          'Overslaan',
                          style: TextStyle(
                            color: Color(0xFFC7D2F2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _OnboardingPage(data: _pages[i]),
                ),
              ),
              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 7,
                    width: active ? 24 : 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.brand,
                      minimumSize: const Size.fromHeight(54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    child: Text(_isLast ? 'Aan de slag' : 'Volgende'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          // Illustration: layered glow + glass icon tile
          Center(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 42),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.badge.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFD7E0FA),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.sansFontName,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.body,
            style: const TextStyle(
              color: Color(0xFFC7D2F2),
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          ...data.highlights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
