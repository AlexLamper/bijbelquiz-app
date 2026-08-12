import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_notice.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/primary_button.dart';
import '../../../core/ui/custom_text_field.dart';
import 'auth_controller.dart';
import 'splash_screen.dart' show BijbelQuizWordmark;
import 'widgets/google_sign_in_button.dart';
import 'widgets/user_data_info_link.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.login(_emailController.text, _passwordController.text);
  }

  Future<void> _loginWithGoogle() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/home');
      } else if (next.hasError) {
        AppNotice.error(context, next.error);
      }
    });

    final state = ref.watch(authControllerProvider);
    final isIOSApp = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final showGoogleSignIn = !isIOSApp;
    final hasSocialLoginOption = showGoogleSignIn;
    final isGoogleInit = showGoogleSignIn
        ? ref.watch(googleSignInInitProvider).hasValue
        : true;
    final isLoading = state.isLoading || !isGoogleInit;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          children: [
            const BijbelQuizWordmark(fontSize: 22),
            const SizedBox(height: 44),
            const Eyebrow('Inloggen'),
            const SizedBox(height: 18),
            const Text('Welkom terug', style: AppTheme.displayLarge),
            const SizedBox(height: 14),
            const Text(
              'Log in om je voortgang bij te houden en mee te doen op de '
              'ranglijst.',
              style: AppTheme.bodyLead,
            ),
            const SizedBox(height: 36),
            CustomTextField(
              label: 'E-mail',
              hintText: 'jij@voorbeeld.nl',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'Wachtwoord',
              hintText: '••••••••',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Inloggen',
              isLoading: isLoading,
              onPressed: isLoading ? null : _login,
            ),
            if (hasSocialLoginOption) ...[
              const SizedBox(height: 28),
              // `border-t border-rule` with the label sitting on the rule.
              Row(
                children: [
                  const Expanded(child: RuleLine()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('OF LOG IN MET', style: AppTheme.overline),
                  ),
                  const Expanded(child: RuleLine()),
                ],
              ),
              const SizedBox(height: 20),
              buildGoogleSignInButton(
                context: context,
                isLoading: isLoading,
                onPressed: isLoading ? null : _loginWithGoogle,
              ),
            ],
            const SizedBox(height: 32),
            const RuleLine(),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => context.push('/register'),
                child: Text.rich(
                  TextSpan(
                    style: AppTheme.bodyMuted,
                    children: const [
                      TextSpan(text: 'Nog geen account?  '),
                      TextSpan(
                        text: 'Registreren',
                        style: TextStyle(
                          color: AppTheme.lapis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: buildUserDataInfoLink(context)),
          ],
        ),
      ),
    );
  }
}
