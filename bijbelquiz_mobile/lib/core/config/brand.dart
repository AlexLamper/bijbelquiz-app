import 'dart:ui' show Locale, PlatformDispatcher;

/// Which app this build is: BijbelQuiz (Dutch, bijbelquiz.com) or Bible Quizzes
/// (biblequizzes.app, English at the root and /es /pt /de /fr per language).
///
/// Chosen at build time with `--dart-define=APP_BRAND=biblequizzes`. Without it
/// the build is BijbelQuiz, exactly as before: same API, same texts, same IDs.
enum AppBrand { bijbelquiz, biblequizzes }

class Brand {
  Brand._();

  static const String _raw = String.fromEnvironment('APP_BRAND', defaultValue: 'bijbelquiz');

  static const AppBrand current = _raw == 'biblequizzes' ? AppBrand.biblequizzes : AppBrand.bijbelquiz;

  static bool get isBijbelQuiz => current == AppBrand.bijbelquiz;
  static bool get isBibleQuizzes => current == AppBrand.biblequizzes;

  /// Display name of the app.
  static String get name => isBijbelQuiz ? 'Bijbelquiz' : 'Bible Quizzes';

  /// Languages of Bible Quizzes, in the order of the website. Each is its own
  /// site with its own accounts and quizzes (see the website's src/config/site.ts).
  static const List<String> intlLanguages = ['en', 'es', 'pt', 'de', 'fr'];

  static const String intlOrigin = 'https://biblequizzes.app';

  /// A language chosen in the app; null follows the device.
  static String? _languageOverride;

  static void setLanguage(String? code) {
    _languageOverride = (code != null && intlLanguages.contains(code)) ? code : null;
  }

  /// The language this build shows: always `nl` for BijbelQuiz; for Bible
  /// Quizzes the chosen one, else the device language when we have it, else English.
  static String get language {
    if (isBijbelQuiz) return 'nl';
    if (_languageOverride != null) return _languageOverride!;
    for (final locale in PlatformDispatcher.instance.locales) {
      if (intlLanguages.contains(locale.languageCode)) return locale.languageCode;
    }
    return 'en';
  }

  static Locale get locale => Locale(language);

  /// Public site for the current language, without a trailing slash:
  /// https://www.bijbelquiz.com, https://biblequizzes.app, https://biblequizzes.app/de.
  static String get siteUrl {
    if (isBijbelQuiz) return 'https://www.bijbelquiz.com';
    return language == 'en' ? intlOrigin : '$intlOrigin/$language';
  }
}
