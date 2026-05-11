import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/primary_button.dart';
import '../../../core/ui/custom_text_field.dart';
import 'auth_controller.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/apple_sign_in_button.dart';
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

  Future<void> _loginWithApple() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.signInWithApple();
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
    final isGoogleInit =
        showGoogleSignIn ? ref.watch(googleSignInInitProvider).hasValue : true;
    final isLoading = state.isLoading || !isGoogleInit;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-dark.png',
                width: 80,
                height: 80,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.book, size: 64, color: Colors.blueAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'Welkom terug',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in om je voortgang bij te houden.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF131D2B), // AppTheme.ink, dark gray
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'E-mail',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Wachtwoord',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Inloggen',
                isLoading: isLoading,
                onPressed: isLoading ? null : _login,
              ),
              const SizedBox(height: 10),
              Text(
                'of log in met',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8A8F98),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              if (showGoogleSignIn)
                buildGoogleSignInButton(
                  context: context,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _loginWithGoogle,
                ),
              if (showGoogleSignIn) const SizedBox(height: 12),
              buildAppleSignInButton(
                isLoading: isLoading,
                onPressed: isLoading ? null : _loginWithApple,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.push('/register');
                },
                child: Text(
                  'Nog geen account? Registreren',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              buildUserDataInfoLink(context),
            ],
          ),
        ),
      ),
    );
  }
}
