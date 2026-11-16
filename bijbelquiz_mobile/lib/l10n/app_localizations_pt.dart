// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'um quiz bíblico';

  @override
  String inviteJoin(String title, String brand) {
    return 'Você topa jogar $title no $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Ou digite o código: $code';
  }
}
