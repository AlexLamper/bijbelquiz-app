import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as gAuth;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../data/auth_repository.dart';
import '../../../core/api/api_client.dart';
import '../data/auth_local_storage.dart';
import '../domain/user.dart';

// Provides shared access
final authStorageProvider = Provider((ref) => AuthLocalStorage());
final apiClientProvider = Provider(
  (ref) => ApiClient(ref.watch(authStorageProvider)),
);
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authStorageProvider),
  ),
);

// State management
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

final googleSignInInitProvider = FutureProvider<void>((ref) async {
  return ref.read(authControllerProvider.notifier).ensureGoogleSignInInitialized();
});

class AuthController extends AsyncNotifier<User?> {
  bool _googleSignInInitialized = false;
  bool _listeningToGoogle = false;

  Future<void> ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await gAuth.GoogleSignIn.instance.initialize(
        // On web, we MUST use a "Web application" Client ID instead of the Android one
        clientId: kIsWeb 
            ? '1036826851129-29bsvr0f17j6bj4g9hsrhhbotsasp4tu.apps.googleusercontent.com'
            : '1036826851129-ptdjlk6vc9id1s4pkl7gks9k2bghb57i.apps.googleusercontent.com',
        serverClientId: kIsWeb ? null : '1036826851129-29bsvr0f17j6bj4g9hsrhhbotsasp4tu.apps.googleusercontent.com',
      );
      _googleSignInInitialized = true;
    }

    if (!_listeningToGoogle) {
      _listeningToGoogle = true;
      gAuth.GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is gAuth.GoogleSignInAuthenticationEventSignIn) {
          try {
            state = const AsyncValue.loading();
            final gAuth.GoogleSignInAccount account = event.user;
            final gAuth.GoogleSignInAuthentication auth = account.authentication;
            final String? idToken = auth.idToken;
            
            if (idToken == null) {
              throw Exception('Geen idToken ontvangen van Google.');
            }
            
            final repository = ref.read(authRepositoryProvider);
            final user = await repository.loginWithGoogle(idToken);
            await _linkRevenueCat(user);
            state = AsyncValue.data(user);
          } catch (e, st) {
            state = AsyncValue.error(e, st);
          }
        }
      });
    }
  }

  @override
  FutureOr<User?> build() {
    return null;
  }

  /// Link RevenueCat to the authenticated user so subscription status
  /// is correctly attributed across devices.
  Future<void> _linkRevenueCat(User? user) async {
    if (user == null || kIsWeb) return;
    try {
      await Purchases.logIn(user.id);
    } catch (_) {
      // Non-fatal: RC linking failure shouldn't block auth.
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);
      await _linkRevenueCat(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.register(name, email, password);
      await _linkRevenueCat(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await ensureGoogleSignInInitialized();
      final gAuth.GoogleSignInAccount account = await gAuth.GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      final gAuth.GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;
      
      if (idToken == null) {
        throw Exception('Geen idToken ontvangen van Google.');
      }
      
      state = const AsyncValue.loading();
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithGoogle(idToken);
      await _linkRevenueCat(user);
      state = AsyncValue.data(user);
    } on gAuth.GoogleSignInException catch (e, st) {
      if (e.code == gAuth.GoogleSignInExceptionCode.canceled ||
          e.code == gAuth.GoogleSignInExceptionCode.interrupted) {
        return; // User canceled the sign in
      }
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;

      if (identityToken == null) {
        throw Exception('Geen identity token ontvangen van Apple.');
      }

      state = const AsyncValue.loading();
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        givenName: credential.givenName,
        familyName: credential.familyName,
        email: credential.email,
      );
      await _linkRevenueCat(user);
      state = AsyncValue.data(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();

    await ensureGoogleSignInInitialized();
    await gAuth.GoogleSignIn.instance.signOut();

    if (!kIsWeb) {
      try {
        await Purchases.logOut();
      } catch (_) {}
    }

    state = const AsyncValue.data(null);
  }
}
