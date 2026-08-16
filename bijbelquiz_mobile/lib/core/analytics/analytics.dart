import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../../features/auth/present/auth_controller.dart';

/// The funnel event names.
///
/// A Dart mirror of `src/lib/analytics/events.ts` in the website repository.
/// The server drops names it does not know, so an app build that is ahead of
/// the backend degrades quietly instead of failing its whole flush - but the
/// two lists are meant to stay identical.
class AnalyticsEvents {
  AnalyticsEvents._();

  static const String quizCompleted = 'quiz_completed';
  static const String roomStarted = 'room_started';
  static const String roomJoined = 'room_joined';
  static const String roomInviteShared = 'room_invite_shared';
  static const String paywallShown = 'paywall_shown';
  static const String paywallDismissed = 'paywall_dismissed';
  static const String purchaseCompleted = 'purchase_completed';
  static const String trialStarted = 'trial_started';
  static const String trialConverted = 'trial_converted';
  static const String streakBroken = 'streak_broken';
}

/// Where a paywall was raised. Reporting slices conversion by this, so the
/// values must match `PAYWALL_TRIGGERS` on the server exactly.
class PaywallTrigger {
  PaywallTrigger._();

  static const String hostQuotaExhausted = 'host_quota_exhausted';
  static const String hostQuotaWarning = 'host_quota_warning';
  static const String hostPlayerCap = 'host_player_cap';
  static const String explanationLocked = 'explanation_locked';
  static const String premiumQuizLocked = 'premium_quiz_locked';
  static const String direct = 'direct';
}

final analyticsProvider = Provider<Analytics>((ref) {
  final analytics = Analytics(ref.watch(apiClientProvider));
  ref.onDispose(analytics.dispose);
  return analytics;
});

/// Queues funnel events and flushes them in batches.
///
/// Batched rather than per-event because the interesting moments arrive in
/// bursts - a paywall shown and dismissed inside two seconds - and because a
/// request per tap on a mobile connection is a real cost. Flushes early when
/// the app goes to the background, which is exactly when a user walks away
/// from a paywall.
///
/// Every failure is swallowed. A metric must never surface to a player.
class Analytics {
  Analytics(this._apiClient) {
    _lifecycleListener = AppLifecycleListener(
      onPause: () => unawaited(flush()),
      onDetach: () => unawaited(flush()),
    );
  }

  static const Duration _flushDelay = Duration(seconds: 3);
  static const int _maxQueue = 25;
  static const String _anonKey = 'analytics_anon_id';

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _queue = <Map<String, dynamic>>[];

  AppLifecycleListener? _lifecycleListener;
  Timer? _flushTimer;
  String? _anonymousId;
  bool _disposed = false;

  /// Records one event. Returns immediately; the network happens later.
  void track(String name, {Map<String, Object?> props = const {}}) {
    if (_disposed) return;

    _queue.add({
      'name': name,
      'props': props,
      'occurredAt': DateTime.now().millisecondsSinceEpoch,
    });

    // A queue that grows without bound means the network has been down for a
    // while; the oldest events are the least useful, so they go first.
    if (_queue.length > _maxQueue) {
      _queue.removeRange(0, _queue.length - _maxQueue);
    }

    _flushTimer ??= Timer(_flushDelay, () => unawaited(flush()));
  }

  Future<void> flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_queue.isEmpty) return;

    final batch = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();

    try {
      await _apiClient.dio.post(
        '/events',
        data: {
          'events': batch,
          'anonymousId': await _anonymousIdentifier(),
          'platform': _platform,
        },
      );
    } catch (_) {
      // Dropped rather than retried: a retry loop on a flaky connection costs
      // the user battery to recover data nobody will miss.
    }
  }

  /// Stable per install, so events fired before sign-in still connect to the
  /// account that appears later. Random, local, and gone when the app is.
  Future<String> _anonymousIdentifier() async {
    final cached = _anonymousId;
    if (cached != null) return cached;

    try {
      final stored = await _storage.read(key: _anonKey);
      if (stored != null && stored.isNotEmpty) {
        _anonymousId = stored;
        return stored;
      }
    } catch (_) {
      // Keychain unavailable; fall through and mint a per-session id.
    }

    final random = math.Random();
    final created =
        'a-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(1 << 32)}';
    _anonymousId = created;

    try {
      await _storage.write(key: _anonKey, value: created);
    } catch (_) {
      // Unstitched events are still better than none.
    }

    return created;
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS || Platform.isMacOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  void dispose() {
    _disposed = true;
    _flushTimer?.cancel();
    _flushTimer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    unawaited(flush());
  }
}
