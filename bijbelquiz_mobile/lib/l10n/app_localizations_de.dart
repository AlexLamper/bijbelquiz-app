// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'ein Bibelquiz';

  @override
  String inviteJoin(String title, String brand) {
    return 'Machst du mit bei $title auf $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Oder gib den Code ein: $code';
  }
}
