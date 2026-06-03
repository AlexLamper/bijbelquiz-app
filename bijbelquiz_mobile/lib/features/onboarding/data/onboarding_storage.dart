import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists whether the user has already seen the intro/onboarding flow so it
/// is only shown once (on first launch).
class OnboardingStorage {
  OnboardingStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _seenKey = 'onboarding_seen_v1';

  Future<bool> hasSeen() async {
    final value = await _storage.read(key: _seenKey);
    return value == 'true';
  }

  Future<void> markSeen() async {
    await _storage.write(key: _seenKey, value: 'true');
  }
}

final onboardingStorageProvider = Provider<OnboardingStorage>(
  (ref) => OnboardingStorage(),
);
