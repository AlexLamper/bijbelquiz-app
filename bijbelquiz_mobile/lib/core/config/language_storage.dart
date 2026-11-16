import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'brand.dart';

/// The language chosen in Settings (Bible Quizzes only). Each language is its
/// own site with its own accounts, so it is read once at launch, before the
/// first API call, and a change takes effect after a restart.
class LanguageStorage {
  LanguageStorage._();

  static const _key = 'app_language_v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Applies the stored choice to [Brand]. No-op for BijbelQuiz.
  static Future<void> load() async {
    if (!Brand.isBibleQuizzes) return;
    try {
      Brand.setLanguage(await _storage.read(key: _key));
    } catch (_) {
      // Unreadable storage: follow the device language.
    }
  }

  /// Null means "follow the device".
  static Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String? code) async {
    if (code == null) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: code);
    }
  }
}

/// Each language's own name, as people look for it in a list.
const Map<String, String> kLanguageNames = {
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'de': 'Deutsch',
  'fr': 'Français',
};
