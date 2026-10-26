import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/app_notice.dart';
import '../../../core/ui/bq.dart';
import 'auth_controller.dart';
import 'widgets/apple_sign_in_button.dart';
import 'widgets/auth_page.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/user_data_info_link.dart';

enum _Method { email, apple, google }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _Method? _pending;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(_Method method) async {
    setState(() => _pending = method);
    final auth = ref.read(authControllerProvider.notifier);
    switch (method) {
      case _Method.email:
        await auth.login(_emailController.text, _passwordController.text);
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
        // The profile tab is where the account's progress shows up, including
        // whatever was parked while playing signed out.
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
      title: 'Welkom terug',
      subtitle:
          'Log in om je voortgang bij te houden en mee te doen op de '
          'ranglijst.',
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
                hint: 'Je wachtwoord',
                controller: _passwordController,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
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
          label: 'Inloggen',
          loading: _pending == _Method.email,
          onPressed: busy ? null : () => _run(_Method.email),
        ),
      ],
      footer: [
        AuthSwitchLink(
          question: 'Nog geen account?',
          action: 'Registreren',
          onTap: busy ? null : () => context.pushReplacement('/register'),
        ),
        Center(child: buildUserDataInfoLink(context)),
      ],
    );
  }
}
