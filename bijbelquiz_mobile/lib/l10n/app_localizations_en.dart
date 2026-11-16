// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'a Bible quiz';

  @override
  String inviteJoin(String title, String brand) {
    return 'Will you join $title on $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Or enter the code: $code';
  }
}
