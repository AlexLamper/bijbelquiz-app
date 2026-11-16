import '../core/config/brand.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// The app's texts in its language, usable anywhere (also outside widgets).
/// Dutch for BijbelQuiz; for Bible Quizzes the app's language (see [Brand]).
AppLocalizations get tr => lookupAppLocalizations(Brand.locale);
