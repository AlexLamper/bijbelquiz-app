// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'un quiz biblique';

  @override
  String inviteJoin(String title, String brand) {
    return 'Tu participes à $title sur $brand ?';
  }

  @override
  String inviteCode(String code) {
    return 'Ou saisis le code : $code';
  }
}
