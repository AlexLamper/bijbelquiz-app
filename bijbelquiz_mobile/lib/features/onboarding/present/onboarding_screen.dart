import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import '../../auth/present/auth_controller.dart';
import '../../auth/present/widgets/apple_sign_in_button.dart';
import '../../auth/present/widgets/auth_terms_line.dart';
import '../../auth/present/widgets/google_sign_in_button.dart';
import '../../auth/present/widgets/social_auth_button.dart';
import '../data/onboarding_storage.dart';

enum _Provider { apple, google }

/// The first-run welcome: what BijbelQuiz is, in one picture, and three ways
/// in - Apple, Google, or straight to playing without an account.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Provider? _pending;
  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;

    // Persist the seen-flag so the intro never reappears on later launches.
    await ref.read(onboardingStorageProvider).markSeen();

    // Straight into the app, account or not. Without one, sign-in is offered
    // again on the profile tab and after a finished quiz, where there is a
    // score to keep.
    if (mounted) context.go('/home');
  }

  Future<void> _signIn(_Provider provider) async {
    setState(() => _pending = provider);
    final auth = ref.read(authControllerProvider.notifier);
    switch (provider) {
      case _Provider.apple:
        await auth.signInWithApple();
      case _Provider.google:
        await auth.signInWithGoogle();
    }
    // A cancelled sign-in leaves the state untouched; clear the spinner.
    if (mounted) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _finish();
      } else if (next.hasError) {
        AppNotice.error(context, next.error);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isIOSApp = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final showGoogle = !isIOSApp;
    final googleReady = showGoogle
        ? ref.watch(googleSignInInitProvider).hasValue
        : true;
    final showApple =
        isIOSApp &&
        (ref.watch(appleSignInAvailableProvider).asData?.value ?? false);
    final busy = authState.isLoading || _pending != null || _finishing;

    final providerButtons = <Widget>[
      if (showApple)
        SocialAuthButton.apple(
          loading: _pending == _Provider.apple,
          onPressed: busy ? null : () => _signIn(_Provider.apple),
        ),
      if (showGoogle)
        buildGoogleSignInButton(
          context: context,
          isLoading: _pending == _Provider.google || !googleReady,
          onPressed: busy ? null : () => _signIn(_Provider.google),
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BqLogo(markSize: 44, fontSize: 26),
                    const SizedBox(height: 40),
                    Semantics(
                      header: true,
                      child: const Text(
                        'Hoe goed ken jij de Bijbel?',
                        style: AppTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Korte quizzen over de bijbelboeken, alleen of samen met '
                      'anderen.',
                      style: AppTheme.bodyLead.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _WelcomeIllustration(),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < providerButtons.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      providerButtons[i],
                    ],
                    if (providerButtons.isNotEmpty) const SizedBox(height: 12),
                    Center(
                      child: Semantics(
                        button: true,
                        enabled: !busy,
                        child: InkWell(
                          onTap: busy ? null : _finish,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  'Eerst spelen zonder account',
                                  style: TextStyle(
                                    fontFamily: AppTheme.sansFontName,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: busy
                                        ? AppTheme.lapis.withValues(alpha: 0.5)
                                        : AppTheme.lapis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const AuthTermsLine(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Illustration
// ---------------------------------------------------------------------------

/// Light gold of the little sun behind the quiz card.
const Color _sun = Color(0xFFF3D27A);

/// Answer text on the neutral tiles of the mini quiz card.
const Color _answerText = Color(0xFF8A877F);

const BoxShadow _floatShadow = BoxShadow(
  color: Color(0x1A1B1A18),
  blurRadius: 20,
  offset: Offset(0, 10),
);

const String _checkSvg =
    '<svg viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M5 12.5l4.5 4.5L19 7"/></svg>';

const String _swordsSvg =
    '<svg viewBox="0 0 24 24" fill="none" stroke="#B4502B" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg"><path d="M4 4l10 10"/><path d="M20 4L10 14"/><path d="M6 15l3 3"/><path d="M18 15l-3 3"/><path d="M4 20l3-3"/><path d="M20 20l-3-3"/></svg>';

const String _boltSvg =
    '<svg viewBox="0 0 24 24" fill="#3D2C05" xmlns="http://www.w3.org/2000/svg"><path d="M13 2L4 14h7l-1 8 9-12h-7z"/></svg>';

double _deg(double degrees) => degrees * math.pi / 180;

/// A tilted mini quiz card with the right answer picked, and around it what
/// playing earns: a duel score, XP and a streak. Built from widgets rather
/// than an image so the text stays sharp at every size.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Voorbeeld: een quizvraag met het goede antwoord, een duel tegen '
          'Lotte, XP en een reeks',
      child: ExcludeSemantics(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 350,
              height: 330,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 40,
                    top: 18,
                    child: Container(
                      width: 270,
                      height: 270,
                      decoration: const BoxDecoration(
                        color: AppTheme.lapisSoft,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 26,
                    top: 40,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: _sun,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    top: 44,
                    child: Transform.rotate(
                      angle: _deg(-3),
                      child: const _MiniQuizCard(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Transform.rotate(
                      angle: _deg(4),
                      child: const _DuelChip(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 34,
                    child: Transform.rotate(
                      angle: _deg(-5),
                      child: const _XpChip(),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 6,
                    child: Transform.rotate(
                      angle: _deg(3),
                      child: const _StreakChip(),
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
}

class _MiniQuizCard extends StatelessWidget {
  const _MiniQuizCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 254,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.rule),
        boxShadow: const [_floatShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.lapisTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: const Text(
              'JOHANNES 6',
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.44,
                color: AppTheme.lapisStrong,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hoeveel broden had de jongen bij zich?',
            style: AppTheme.displayTitle,
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _Answer('3')),
              SizedBox(width: 8),
              Expanded(child: _Answer('5', correct: true)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(child: _Answer('7')),
              SizedBox(width: 8),
              Expanded(child: _Answer('12')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer(this.label, {this.correct = false});

  final String label;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    // The darker bottom edge is the outer box showing below the face: a
    // rounded border may only use one colour.
    return Container(
      height: 38,
      padding: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: correct ? AppTheme.positiveDeep : AppTheme.ruleStrong,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: correct ? AppTheme.positive : AppTheme.paperRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: correct ? AppTheme.positiveDeep : AppTheme.rule,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (correct) ...[
              SvgPicture.string(_checkSvg, width: 14, height: 14),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: correct ? AppTheme.inkInverted : _answerText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuelChip extends StatelessWidget {
  const _DuelChip();

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(
      fontFamily: AppTheme.sansFontName,
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: AppTheme.inkSoft,
    );
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.rule),
        boxShadow: const [_floatShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.string(_swordsSvg, width: 16, height: 16),
          const SizedBox(width: 8),
          const Text('Jij', style: label),
          const SizedBox(width: 8),
          const Text(
            '3 - 2',
            style: TextStyle(
              fontFamily: AppTheme.displayFontName,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Lotte', style: label),
        ],
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: const [_floatShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.string(_boltSvg, width: 15, height: 15),
          const SizedBox(width: 5),
          const Text(
            '+15 XP',
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.goldInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.paperRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.rule),
        boxShadow: const [_floatShadow],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BqIcon(BqIcons.flame, size: 16),
          SizedBox(width: 6),
          Text(
            '6 dagen op rij',
            style: TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
