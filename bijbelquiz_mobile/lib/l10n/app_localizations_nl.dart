// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Bijbelquiz';

  @override
  String get inviteFallbackTitle => 'een bijbelquiz';

  @override
  String inviteJoin(String title, String brand) {
    return 'Doe je mee met $title op $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Of vul de code in: $code';
  }
}
