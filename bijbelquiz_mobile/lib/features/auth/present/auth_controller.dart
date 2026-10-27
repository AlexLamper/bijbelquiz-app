import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_auth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/config/apple_sign_in_config.dart';
import '../data/auth_repository.dart';
import '../../../core/api/api_client.dart';
import '../data/auth_local_storage.dart';
import '../domain/user.dart';
import '../../profile/data/profile_repository.dart';
import '../../premium/present/premium_controller.dart';

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

/// Whether a session token is stored on this device.
///
/// The app can be used without an account, so "is there a session" is a
/// question screens ask all the time: whether to offer sign-in, whether to
/// fetch the profile at all, whether a finished quiz is written to the server
/// or parked on the device. It is answered from storage rather than from
/// `authControllerProvider`, whose value is also null while a stored session
/// is still being restored, and rather than from a failing `profileProvider`,
/// which also fails offline. Invalidated by the controller on every sign-in
/// and sign-out.
final hasSessionProvider = FutureProvider<bool>((ref) async {
  final token = await ref.watch(authStorageProvider).getToken();
  return token != null && token.isNotEmpty;
});

// State management
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

final googleSignInInitProvider = FutureProvider<void>((ref) async {
  return ref
      .read(authControllerProvider.notifier)
      .ensureGoogleSignInInitialized();
});

class AuthController extends AsyncNotifier<User?> {
  bool _googleSignInInitialized = false;
  static const String _googleWebClientId =
      '1036826851129-29bsvr0f17j6bj4g9hsrhhbotsasp4tu.apps.googleusercontent.com';

  Future<void> ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await google_auth.GoogleSignIn.instance.initialize(
        // Web requires explicit clientId. Native iOS/Android should rely on
        // platform OAuth setup (Info.plist / google-services).
        clientId: kIsWeb ? _googleWebClientId : null,
        // Android requires a serverClientId with google_sign_in v7 for token
        // based auth. Keep iOS null to avoid invalid_request issues there.
        serverClientId:
            !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? _googleWebClientId
            : null,
      );
      _googleSignInInitialized = true;
    }
  }

  @override
  FutureOr<User?> build() {
    return null;
  }

  /// The stored token changed: every screen asking `hasSessionProvider`
  /// re-reads it, and the profile that depends on it reloads.
  void _sessionChanged() {
    ref.invalidate(hasSessionProvider);
  }

  /// Link RevenueCat to the authenticated user (`appUserID` = server user
  /// id) so store purchases belong to the account on every device and on the
  /// website. RevenueCat aliases purchases made under the anonymous id of
  /// this install into the account. Also asks the server to reconcile
  /// Premium, without making the sign-in wait for it.
  Future<void> _linkRevenueCat(User? user) async {
    if (user == null || kIsWeb) return;
    try {
      await ref.read(premiumControllerProvider.notifier).onSignedIn(user.id);
    } catch (_) {
      // Non-fatal: RC linking failure shouldn't block auth.
    }
  }

  /// Restore a persisted session on app launch.
  ///
  /// Without this, a returning user (token already stored) reaches the app
  /// without RevenueCat being logged in, so a purchase is attributed to an
  /// anonymous RevenueCat id and the store webhook can't attach premium to
  /// their account.
  Future<void> restoreSession() async {
    final token = await ref.read(authStorageProvider).getToken();
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      final user = User(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        xp: profile.xp,
        isPremium: profile.isPremium,
      );
      // Also self-heals accounts whose purchase webhook never landed: the
      // premium controller asks the server to reconcile against RevenueCat
      // once RC is linked.
      await _linkRevenueCat(user);
      state = AsyncValue.data(user);
    } catch (_) {
      // Best-effort: keep the token-based session even if profile fetch fails
      // (e.g. offline). RevenueCat linking retries on the next launch.
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);
      await _linkRevenueCat(user);
      _sessionChanged();
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
      _sessionChanged();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await ensureGoogleSignInInitialized();
      final google_auth.GoogleSignInAccount account = await google_auth
          .GoogleSignIn
          .instance
          .authenticate(scopeHint: ['email', 'profile']);
      await _completeGoogleSignIn(account);
    } on google_auth.GoogleSignInException catch (e, st) {
      if (e.code == google_auth.GoogleSignInExceptionCode.canceled) {
        return; // User canceled the sign in dialog.
      }
      if (e.code == google_auth.GoogleSignInExceptionCode.interrupted) {
        // Android can report interrupted when UI flow closed unexpectedly.
        final current = await google_auth.GoogleSignIn.instance
            .attemptLightweightAuthentication();
        if (current != null) {
          try {
            await _completeGoogleSignIn(current);
            return;
          } catch (_) {}
        }
        state = AsyncValue.error(
          Exception(
            'Google-login onderbroken op Android. Controleer SHA-1/SHA-256 van de release key in Google Cloud OAuth client.',
          ),
          st,
        );
        return;
      }
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _completeGoogleSignIn(
    google_auth.GoogleSignInAccount account,
  ) async {
    final google_auth.GoogleSignInAuthentication auth = account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google gaf geen idToken terug. Probeer opnieuw of kies een ander account.',
      );
    }

    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.loginWithGoogle(idToken);
    await _linkRevenueCat(user);
    _sessionChanged();
    state = AsyncValue.data(user);
  }

  Future<void> signInWithApple() async {
    try {
      var useWebFallback = false;
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable && !AppleSignInConfig.hasWebFallbackConfig) {
        throw Exception(
          'Apple-login is niet beschikbaar op dit apparaat. Voeg web fallback toe met APPLE_SERVICE_ID en APPLE_REDIRECT_URI of controleer je Apple ID/provisioning.',
        );
      }
      if (!isAvailable && AppleSignInConfig.hasWebFallbackConfig) {
        useWebFallback = true;
      }

      final credential = await _getAppleCredentialWithFallback(
        forceWebFallback: useWebFallback,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple gaf geen identityToken terug. Probeer opnieuw.');
      }

      state = const AsyncValue.loading();
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithApple(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        givenName: credential.givenName,
        familyName: credential.familyName,
        email: credential.email,
      );
      await _linkRevenueCat(user);
      _sessionChanged();
      state = AsyncValue.data(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      if (e.code == AuthorizationErrorCode.unknown) {
        state = AsyncValue.error(
          Exception(
            'Apple-login kon niet worden gestart (AuthorizationError 1000). Dit is meestal een iOS-device/provisioning probleem: gebruik een echte iPhone (of iOS-simulator met Apple ID), vernieuw signing/provisioning in Xcode voor bundle ID com.bijbelquiz.app en installeer de app opnieuw.',
          ),
          StackTrace.current,
        );
        return;
      }
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AuthorizationCredentialAppleID> _getAppleCredentialWithFallback({
    required bool forceWebFallback,
  }) async {
    const scopes = [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ];

    if (forceWebFallback) {
      final credential = await _getAppleCredentialViaWeb(scopes);
      if (credential != null) return credential;
      throw Exception(
        'Apple web-fallback is niet geconfigureerd. Stel APPLE_SERVICE_ID en APPLE_REDIRECT_URI in.',
      );
    }

    try {
      return await SignInWithApple.getAppleIDCredential(scopes: scopes);
    } on SignInWithAppleAuthorizationException catch (e) {
      // AuthorizationError 1000 is often entitlement/provisioning related.
      if (e.code == AuthorizationErrorCode.unknown) {
        final viaWeb = await _getAppleCredentialViaWeb(scopes);
        if (viaWeb != null) return viaWeb;
      }
      rethrow;
    }
  }

  Future<AuthorizationCredentialAppleID?> _getAppleCredentialViaWeb(
    List<AppleIDAuthorizationScopes> scopes,
  ) async {
    if (!AppleSignInConfig.hasWebFallbackConfig) return null;
    final redirectUri = AppleSignInConfig.redirectUri;
    if (redirectUri == null) return null;

    return SignInWithApple.getAppleIDCredential(
      scopes: scopes,
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: AppleSignInConfig.serviceId,
        redirectUri: redirectUri,
      ),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    _sessionChanged();

    await ensureGoogleSignInInitialized();
    await google_auth.GoogleSignIn.instance.signOut();

    if (!kIsWeb) {
      // Back to an anonymous RevenueCat id, and drop the previous account's
      // Premium from memory so the next player is not shown it.
      try {
        await ref.read(premiumControllerProvider.notifier).onSignedOut();
      } catch (_) {}
    }

    state = const AsyncValue.data(null);
  }
}
