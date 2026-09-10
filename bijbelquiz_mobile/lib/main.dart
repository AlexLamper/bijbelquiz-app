import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/config/preview_config.dart';
import 'core/config/revenuecat_config.dart';
import 'core/notifications/streak_reminder.dart';
import 'core/preview/preview_data.dart';
import 'core/ui/app_notice.dart';
import 'features/auth/domain/user.dart';
import 'features/auth/present/auth_controller.dart';
import 'features/profile/data/profile_model.dart';
import 'features/profile/present/profile_provider.dart';
import 'features/quiz/data/pending_attempt_claimer.dart';
import 'features/quiz/data/pending_attempt_store.dart';

/// The app-wide messenger, for notices raised outside any screen.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Writes the quizzes played before signing in to the account that just did,
/// and says so once. Failures leave the attempts parked for the next sign-in.
Future<void> _claimPendingAttempts(WidgetRef ref) async {
  final summary = await ref.read(pendingAttemptClaimerProvider).claim();
  if (summary.isEmpty) return;

  // The profile's XP, streak and recent activity all moved.
  ref.invalidate(profileProvider);
  ref.invalidate(pendingAttemptsProvider);

  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  final title = summary.firstTitle ?? 'je quiz';
  AppNotice.successOn(
    messenger,
    summary.saved == 1
        ? 'Je score voor "$title" is opgeslagen (+${summary.xpEarned} XP).'
        : '${summary.saved} quizzen opgeslagen (+${summary.xpEarned} XP).',
    title: 'Voortgang bewaard',
  );
}

Future<void> _initRevenueCat() async {
  if (kIsWeb) return;
  final apiKey = RevenueCatConfig.sdkPublicApiKey();
  assert(() {
    debugPrint(
      '[RevenueCat][Main] key source: ${RevenueCatConfig.sdkKeySource()}',
    );
    return true;
  }());
  if (apiKey.isEmpty) {
    assert(() {
      debugPrint(
        'RevenueCat: no API key. Pass --dart-define=REVENUECAT_TEST_KEY=... '
        'or REVENUECAT_APPLE_KEY / REVENUECAT_GOOGLE_KEY. See revenuecat_config.dart.',
      );
      return true;
    }());
    return;
  }
  await Purchases.setLogLevel(
    AppConfig.isProduction ? LogLevel.error : LogLevel.debug,
  );
  await Purchases.configure(PurchasesConfiguration(apiKey));
  assert(() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final active = customerInfo.entitlements.active.keys.join(', ');
      debugPrint(
        '[RevenueCat][Main] CustomerInfo updated. Active entitlements: '
        '${active.isEmpty ? '(none)' : active}',
      );
    });
    debugPrint('[RevenueCat][Main] SDK configured with debug listener.');
    return true;
  }());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Paper-coloured system chrome, matching --paper on www.bijbelquiz.com.
  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);

  if (PreviewConfig.enabled) {
    // Point image URLs at the live site so quiz artwork resolves without a
    // local backend, then run with canned data and no auth.
    AppConfig.setCustomApiBaseUrl('https://www.bijbelquiz.com/api/mobile');
    debugPrint('[Preview] Design-preview mode active - using canned data.');
    runApp(PreviewData.scope(const BijbelquizApp()));
    return;
  }

  try {
    await _initRevenueCat();
  } catch (e, st) {
    assert(() {
      debugPrint('[RevenueCat][Main] init failed: $e\n$st');
      return true;
    }());
  }

  // Prepares the plugin and the timezone database only. No permission is
  // requested here - that happens after a finished quiz, if the player says
  // yes. `init` swallows its own failures.
  await StreakReminder.instance.init();

  runApp(const ProviderScope(child: BijbelquizApp()));
}

class BijbelquizApp extends ConsumerWidget {
  const BijbelquizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Every profile refresh re-aims the streak reminder. Done here rather than
    // at each call site because the streak moves for several reasons - a quiz
    // on the website, a day passing - and a reminder that only updates after a
    // quiz in this app would fire on an evening the player is already safe.
    ref.listen<AsyncValue<ProfileModel>>(profileProvider, (previous, next) {
      final profile = next.asData?.value;
      if (profile == null) return;

      unawaited(
        StreakReminder.instance.sync(
          streak: profile.streak,
          lastPlayedAt: profile.lastPlayedAt,
        ),
      );
    });

    // Quizzes played before signing in are written to the account the moment
    // one appears. Whether the sign-in came from the profile tab, a finished
    // quiz, Google or Apple, it all passes through this one provider. Keyed
    // on the user id so a state refresh for the same account does not run the
    // claim twice.
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      final user = next.asData?.value;
      if (user == null || previous?.asData?.value?.id == user.id) return;
      unawaited(_claimPendingAttempts(ref));
    });

    final routerConfig = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Bijbelquiz',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: routerConfig,
    );
  }
}
