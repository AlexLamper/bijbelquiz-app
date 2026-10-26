import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import 'auth_controller.dart';
import 'widgets/apple_sign_in_button.dart';
import 'widgets/auth_page.dart';
import 'widgets/auth_terms_line.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/user_data_info_link.dart';

enum _Method { email, apple, google }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _Method? _pending;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(_Method method) async {
    setState(() => _pending = method);
    final auth = ref.read(authControllerProvider.notifier);
    switch (method) {
      case _Method.email:
        await auth.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      case _Method.apple:
        await auth.signInWithApple();
      case _Method.google:
        await auth.signInWithGoogle();
    }
    if (mounted) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // The profile tab is where the new account's progress shows up,
        // including whatever was parked while playing signed out.
        context.go('/profile');
      } else if (next.hasError) {
        AppNotice.error(context, next.error);
      }
    });

    final state = ref.watch(authControllerProvider);
    final isIOSApp = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final showGoogle = !isIOSApp;
    final googleReady = showGoogle
        ? ref.watch(googleSignInInitProvider).hasValue
        : true;
    final showApple =
        isIOSApp &&
        (ref.watch(appleSignInAvailableProvider).asData?.value ?? false);
    final busy = state.isLoading || _pending != null;

    final providers = <Widget>[
      if (showApple)
        SocialAuthButton.apple(
          loading: _pending == _Method.apple,
          onPressed: busy ? null : () => _run(_Method.apple),
        ),
      if (showGoogle)
        buildGoogleSignInButton(
          context: context,
          isLoading: _pending == _Method.google || !googleReady,
          onPressed: busy ? null : () => _run(_Method.google),
        ),
    ];

    return AuthPage(
      title: 'Account aanmaken',
      subtitle: 'Gratis, en je voortgang blijft bewaard.',
      card: [
        for (var i = 0; i < providers.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          providers[i],
        ],
        if (providers.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AuthOrDivider(),
          const SizedBox(height: 20),
        ],
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: 'Naam',
                hint: 'Bijvoorbeeld Alex',
                helper: 'Zo zien anderen je op de ranglijst en in duels.',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                enabled: !busy,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'E-mailadres',
                hint: 'naam@voorbeeld.nl',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !busy,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Wachtwoord',
                hint: 'Minimaal 6 tekens',
                controller: _passwordController,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !busy,
                onSubmitted: (_) {
                  if (!busy) _run(_Method.email);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BqButton(
          label: 'Account aanmaken',
          loading: _pending == _Method.email,
          onPressed: busy ? null : () => _run(_Method.email),
        ),
        const SizedBox(height: 12),
        const AuthTermsLine(
          prefix: 'Door een account te maken ga je akkoord met de ',
          fontSize: 13,
        ),
      ],
      footer: [
        AuthSwitchLink(
          question: 'Heb je al een account?',
          action: 'Inloggen',
          onTap: busy ? null : () => context.pushReplacement('/login'),
        ),
        Center(child: buildUserDataInfoLink(context)),
      ],
    );
  }
}
