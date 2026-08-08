import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../core/ui/primary_button.dart';
import '../../../core/ui/custom_text_field.dart';
import 'auth_controller.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/user_data_info_link.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  Future<void> _registerWithGoogle() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/home');
      } else if (next.hasError) {
        final msg = next.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.replaceAll('Exception: ', ''))),
        );
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
      appBar: AppBar(
        backgroundColor: AppTheme.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          color: AppTheme.inkSoft,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            const Eyebrow('Registreren'),
            const SizedBox(height: 18),
            const Text('Account aanmaken', style: AppTheme.displayLarge),
            const SizedBox(height: 14),
            const Text(
              'Maak een account aan om je voortgang op te slaan en mee te doen '
              'op de ranglijst.',
              style: AppTheme.bodyLead,
            ),
            const SizedBox(height: 36),
            CustomTextField(
              label: 'Naam',
              hintText: 'Je naam',
              controller: _nameController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
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
              text: 'Registreren',
              isLoading: isLoading,
              onPressed: isLoading ? null : _register,
            ),
            if (hasSocialLoginOption) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(child: RuleLine()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('OF GA VERDER MET', style: AppTheme.overline),
                  ),
                  const Expanded(child: RuleLine()),
                ],
              ),
              const SizedBox(height: 20),
              buildGoogleSignInButton(
                context: context,
                isLoading: isLoading,
                onPressed: isLoading ? null : _registerWithGoogle,
              ),
            ],
            const SizedBox(height: 32),
            const RuleLine(),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text.rich(
                  TextSpan(
                    style: AppTheme.bodyMuted,
                    children: const [
                      TextSpan(text: 'Heb je al een account?  '),
                      TextSpan(
                        text: 'Inloggen',
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
