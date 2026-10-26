import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/bq.dart';

/// Shared frame of the login and register pages: back button with the logo,
/// a Fredoka title and lead, one white card holding the form, and a footer
/// below the card.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.card,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> card;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                // Reached from inside the app - the profile tab or a finished
                // quiz - so it is a pushed page with a way back.
                BqCircleButton(
                  icon: BqIcons.chevronLeft,
                  label: 'Terug',
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                ),
                const Expanded(
                  child: Center(child: BqLogo(markSize: 32, fontSize: 21)),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 28),
            Semantics(
              header: true,
              child: Text(title, style: AppTheme.displayLarge),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTheme.bodyLead.copyWith(color: AppTheme.inkMuted),
            ),
            const SizedBox(height: 20),
            BqCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: card,
              ),
            ),
            const SizedBox(height: 12),
            ...footer,
          ],
        ),
      ),
    );
  }
}

/// "------ of met e-mail ------"
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, this.label = 'of met e-mail'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.rule)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.inkMuted,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppTheme.rule)),
        ],
      ),
    );
  }
}

/// "Nog geen account? Registreren" - a 44px tappable line under the card.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: '$question $action',
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                widthFactor: 1,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$question '),
                      TextSpan(
                        text: action,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.lapis,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontFamily: AppTheme.sansFontName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.inkMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
