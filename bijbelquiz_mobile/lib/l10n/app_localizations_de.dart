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

  @override
  String get errGenericTitle => 'Etwas ist schiefgelaufen';

  @override
  String get errGenericMessage =>
      'Das hat nicht geklappt. Bitte versuche es gleich noch einmal.';

  @override
  String get errNetworkTitle => 'Keine Verbindung';

  @override
  String get errNetworkMessage =>
      'Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errSignedOutTitle => 'Erneut anmelden';

  @override
  String get errSignedOutMessage =>
      'Deine Sitzung ist abgelaufen. Melde dich erneut an, um weiterzuspielen.';

  @override
  String get errRoomNotFoundTitle => 'Raum nicht gefunden';

  @override
  String get errRoomNotFoundMessage =>
      'Diesen Raum gibt es nicht mehr oder er ist geschlossen. Prüfe den Code oder starte selbst einen neuen Raum.';

  @override
  String get errRoomFullTitle => 'Raum ist voll';

  @override
  String get errRoomFullMessage =>
      'In diesen Raum passen keine Spieler mehr. Bitte den Gastgeber, einen neuen Raum zu öffnen.';

  @override
  String get errRoomStartedTitle => 'Das Spiel hat schon begonnen';

  @override
  String get errRoomStartedMessage =>
      'Dieses Quiz läuft schon. Warte, bis die Runde vorbei ist, oder starte einen neuen Raum.';

  @override
  String get errRoomFinishedTitle => 'Das Spiel ist vorbei';

  @override
  String get errRoomFinishedMessage =>
      'Dieser Raum ist geschlossen. Starte einen neuen Raum, um weiterzuspielen.';

  @override
  String get errRoomCodeTitle => 'Ungültiger Raumcode';

  @override
  String get errRoomCodeMessage =>
      'Dieser Code stimmt nicht. Ein Raumcode hat 6 Zeichen.';

  @override
  String get errAlreadyInRoomTitle => 'Du bist schon in diesem Raum';

  @override
  String get errAlreadyInRoomMessage =>
      'Geh zurück in den Raum, um weiterzuspielen.';

  @override
  String get errPremiumTitle => 'Premium erforderlich';

  @override
  String get errPremiumMessage =>
      'Selbst einen Raum zu hosten gehört zu Bible Quizzes Premium. Mitspielen ist immer kostenlos.';

  @override
  String get errForbiddenTitle => 'Kein Zugriff';

  @override
  String get errForbiddenMessage => 'Nur der Gastgeber kann das tun.';

  @override
  String get errRateLimitedTitle => 'Einen Moment';

  @override
  String get errRateLimitedMessage =>
      'Du hast es zu oft hintereinander versucht. Warte kurz und versuche es erneut.';

  @override
  String get errNotFoundTitle => 'Nicht gefunden';

  @override
  String get errNotFoundMessage =>
      'Das konnten wir nicht finden. Geh zurück und versuche es erneut.';

  @override
  String get errConflictTitle => 'Das geht gerade nicht';

  @override
  String get errConflictMessage =>
      'Diese Aktion passt nicht zum aktuellen Spielstand. Aktualisiere und versuche es erneut.';

  @override
  String get errServerTitle => 'Server antwortet nicht';

  @override
  String get errServerMessage =>
      'Bei uns ist etwas schiefgelaufen. Versuche es in ein paar Sekunden erneut.';

  @override
  String get errLiveLostTitle => 'Live-Verbindung unterbrochen';

  @override
  String get errLiveLostMessage =>
      'Die Live-Verbindung ist abgebrochen. Wir holen den Stand jetzt automatisch.';

  @override
  String get errLoginTitle => 'Anmeldung fehlgeschlagen';

  @override
  String get errLoginBadCredentials =>
      'Diese E-Mail-Adresse oder dieses Passwort stimmt nicht.';

  @override
  String get errAccountExistsTitle => 'Konto existiert bereits';

  @override
  String get errAccountExistsMessage =>
      'Es gibt schon ein Konto mit dieser E-Mail-Adresse. Melde dich an.';

  @override
  String get errRegisterTitle => 'Registrierung fehlgeschlagen';

  @override
  String get errRegisterMessage =>
      'Wir konnten dein Konto nicht erstellen. Versuche es erneut.';

  @override
  String get errLoginMessage =>
      'Wir konnten dich nicht anmelden. Versuche es erneut.';

  @override
  String get errLeaderboardTitle => 'Rangliste nicht geladen';

  @override
  String get errLeaderboardMessage =>
      'Wir konnten die Rangliste nicht laden. Versuche es erneut.';

  @override
  String get errQuizzesTitle => 'Quizze nicht geladen';

  @override
  String get errQuizzesMessage =>
      'Wir konnten die Quizze nicht laden. Versuche es erneut.';

  @override
  String get errProfileTitle => 'Profil nicht geladen';

  @override
  String get errProfileMessage =>
      'Wir konnten dein Profil nicht laden. Versuche es erneut.';

  @override
  String get errPurchaseTitle => 'Kauf fehlgeschlagen';

  @override
  String get errPurchaseMessage =>
      'Der Kauf wurde nicht abgeschlossen. Dir wurde nichts berechnet.';

  @override
  String get streakReminderTitle => 'Deine Serie steht auf dem Spiel';

  @override
  String get streakReminderChannel => 'Serien-Erinnerung';

  @override
  String get streakReminderChannelDescription =>
      'Eine Erinnerung am Abend, an dem deine Serie abzulaufen droht.';

  @override
  String streakReminderBody(Object streak) {
    return 'Deine Serie von $streak Tagen endet heute Abend. Ein Quiz reicht, um sie zu halten.';
  }

  @override
  String get navQuizzes => 'Quizze';

  @override
  String get navTogether => 'Zusammen';

  @override
  String get navLeaderboard => 'Rangliste';

  @override
  String get navProfile => 'Profil';

  @override
  String get savedQuizFallback => 'dein Quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Dein Ergebnis für \"$title\" wurde gespeichert (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved Quizze gespeichert (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Fortschritt gespeichert';

  @override
  String get navHome => 'Start';

  @override
  String get avatarLamb => 'Lamm';

  @override
  String get avatarLion => 'Löwe';

  @override
  String get avatarDove => 'Taube';

  @override
  String get avatarOwl => 'Eule';

  @override
  String get avatarDeer => 'Hirsch';

  @override
  String get avatarOx => 'Ochse';

  @override
  String get avatarSand => 'Sand';

  @override
  String get avatarLapis => 'Lapis';

  @override
  String get avatarClay => 'Ton';

  @override
  String get avatarOlive => 'Olive';

  @override
  String get avatarRose => 'Rose';

  @override
  String get avatarSlate => 'Schiefer';

  @override
  String get avatarParchment => 'Pergament';

  @override
  String get avatarSky => 'Himmel';

  @override
  String get avatarSage => 'Salbei';

  @override
  String get avatarSunrise => 'Sonnenaufgang';

  @override
  String get avatarNight => 'Nacht';

  @override
  String get avatarBlush => 'Röte';

  @override
  String get avatarNone => 'Keins';

  @override
  String get avatarGlasses => 'Brille';

  @override
  String get avatarCap => 'Kappe';

  @override
  String get avatarScarf => 'Schal';

  @override
  String get avatarCrown => 'Krone';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character mit $accessory';
  }

  @override
  String get wordmarkFirst => 'Bible';

  @override
  String get wordmarkSecond => 'Quizzes';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionBack => 'Zurück';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount Fragen';
  }

  @override
  String get actionStart => 'Starten';

  @override
  String get authGoogleAndroidInterrupted =>
      'Die Google-Anmeldung wurde unter Android unterbrochen. Prüfe SHA-1/SHA-256 des Release-Schlüssels im Google-Cloud-OAuth-Client.';

  @override
  String get authGoogleNoToken =>
      'Google hat kein Anmelde-Token zurückgegeben. Versuche es erneut oder wähle ein anderes Konto.';

  @override
  String get authAppleUnavailable =>
      'Mit Apple anmelden ist auf diesem Gerät nicht verfügbar.';

  @override
  String get authAppleError1000 =>
      'Die Anmeldung mit Apple konnte nicht starten (Fehler 1000). Prüfe, ob auf diesem Gerät eine Apple-ID angemeldet ist, und versuche es erneut.';

  @override
  String get authAppleWebNotConfigured =>
      'Mit Apple anmelden ist für diese Plattform noch nicht eingerichtet.';

  @override
  String get authWelcomeBack => 'Willkommen zurück';

  @override
  String get authLoginSubtitle =>
      'Melde dich an, um deinen Fortschritt zu behalten und in der Rangliste mitzuspielen.';

  @override
  String get authEmailHint => 'name@beispiel.de';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authPasswordHint => 'Dein Passwort';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authNoAccount => 'Noch kein Konto?';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authCreateSubtitle =>
      'Kostenlos, und dein Fortschritt bleibt gespeichert.';

  @override
  String get authName => 'Name';

  @override
  String get authNameHelp =>
      'So sehen dich andere in der Rangliste und beim gemeinsamen Spielen.';

  @override
  String get authTermsPrefixRegister =>
      'Mit dem Erstellen eines Kontos stimmst du den ';

  @override
  String get authHaveAccount => 'Schon ein Konto?';

  @override
  String get splashTagline => 'Wie gut kennst du die Bibel?';

  @override
  String get authOrEmail => 'oder mit E-Mail';

  @override
  String get authTermsPrefix => 'Wenn du fortfährst, stimmst du den ';

  @override
  String get errLinkTitle => 'Link nicht geöffnet';

  @override
  String get errLinkMessage =>
      'Wir konnten diese Seite nicht öffnen. Versuche es erneut.';

  @override
  String get authTermsAnd => ' und der ';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authContinueGoogle => 'Weiter mit Google';

  @override
  String get authContinueApple => 'Weiter mit Apple';

  @override
  String get dataInfoTitle => 'Wie wir mit deinen Daten umgehen';

  @override
  String get dataInfoBody =>
      'Bei der Anmeldung oder Registrierung nutzen wir nur die Daten, die dein Konto braucht, etwa deinen Namen, deine E-Mail-Adresse und deine Anmeldedaten.\n\nDeine Daten werden über sichere Verbindungen übertragen, und wir geben sie ohne deine Zustimmung nicht für Werbung weiter.\n\nDu kannst dein Konto jederzeit löschen lassen. Schreib uns an info@biblequizzes.app oder nutze die Support-Kanäle in der App. Nach der Löschung werden deine Kontodaten gemäß unserer Datenschutzerklärung entfernt.';

  @override
  String get dataInfoMore => 'Mehr zur Datennutzung';

  @override
  String get homeContinue => 'Weiterspielen';

  @override
  String get homeAll => 'Alle';

  @override
  String get homePickTopic => 'Wähle ein Thema';

  @override
  String get homePopular => 'Beliebte Quizze';

  @override
  String get streakOneDay => 'Serie von 1 Tag';

  @override
  String streakDays(Object streak) {
    return 'Serie von $streak Tagen';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count Fragen';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz des Tages: $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ DES TAGES';

  @override
  String get actionUnlock => 'Freischalten';

  @override
  String get actionPlayNow => 'Jetzt spielen';

  @override
  String get homeChallengeLoading =>
      'Eine neue Herausforderung erscheint, sobald die Quizze geladen sind.';

  @override
  String get homeLoadFailed => 'Startseite nicht geladen';

  @override
  String get checkConnectionRetry =>
      'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get homeGuestTitle => 'Kostenlos spielen, ohne Konto';

  @override
  String get homeGuestBody =>
      'Erstelle eins, um Ergebnis, Punkte und Serie zu behalten.';

  @override
  String get homeGuestAction => 'Fortschritt speichern';

  @override
  String chapterN(Object chapter) {
    return 'Kapitel $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText richtig';
  }

  @override
  String get played => 'Gespielt';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score von $total richtig';
  }

  @override
  String get books39 => '39 Bücher';

  @override
  String get books27 => '27 Bücher';

  @override
  String get catGeneral => 'Allgemein';

  @override
  String get catWholeBible => 'Ganze Bibel';

  @override
  String get catByTheme => 'Nach Thema';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount Fragen';
  }

  @override
  String get groupsLoadFailed => 'Deine Gruppen konnten nicht geladen werden.';

  @override
  String get groupSaveFailed => 'Die Gruppe konnte nicht gespeichert werden.';

  @override
  String get groupSaveFailedTitle => 'Gruppe speichern fehlgeschlagen';

  @override
  String get groupSaveNoGroup =>
      'Der Server hat keine Gruppe zurückgegeben. Versuche es erneut.';

  @override
  String get groupRenameFailed => 'Umbenennen hat nicht geklappt.';

  @override
  String get deleteFailed => 'Löschen hat nicht geklappt.';

  @override
  String get groupStandingsFailed =>
      'Der Stand dieser Gruppe konnte nicht geladen werden.';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String get groupSingular => 'Gruppe';

  @override
  String get leaderboardLoadFailed => 'Rangliste konnte nicht laden';

  @override
  String get leaderboardMonthHint => 'XP der letzten 30 Tage';

  @override
  String get leaderboardAllTimeHint => 'Alle XP seit dem Start zählen';

  @override
  String get periodMonth => 'Diesen Monat';

  @override
  String get periodAllTime => 'Gesamt';

  @override
  String get periodLabel => 'Zeitraum';

  @override
  String get everyone => 'Alle';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return 'Noch $gap XP bis Platz $rank';
  }

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String showAllPlayers(Object total) {
    return 'Alle $total Spieler anzeigen';
  }

  @override
  String get leaderboardGuestHint =>
      'Mit einem kostenlosen Konto zählen deine XP.';

  @override
  String get leaderboardNotOnIt => 'Du stehst noch nicht in dieser Rangliste';

  @override
  String get leaderboardPlayToJoin => 'Spiel ein Quiz, um mitzumachen.';

  @override
  String get leaderboardNoData => 'Noch keine Ranglistendaten.';

  @override
  String get leaderboardEmpty => 'Noch niemand in der Rangliste';

  @override
  String get onboardingTagline =>
      'Kurze Quizze zu den Büchern der Bibel, allein oder mit anderen.';

  @override
  String get onboardingGuest => 'Erst ohne Konto spielen';

  @override
  String get onboardingPreviewA11y =>
      'Beispiel: eine Quizfrage mit der richtigen Antwort, ein Duell gegen Sarah, XP und eine Serie';

  @override
  String get onboardingSampleQuestion =>
      'Wie viele Brote hatte der Junge bei sich?';

  @override
  String get onboardingSampleStreak => '6 Tage am Stück';

  @override
  String get seasonEndsToday => 'Endet heute';

  @override
  String get seasonOneDayLeft => 'Noch 1 Tag';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return 'Noch $daysRemaining Tage';
  }

  @override
  String get season => 'Saison';

  @override
  String get manageSubscription => 'Abo verwalten';

  @override
  String get viaWebsite => 'Über die Website';

  @override
  String get lifetime => 'Lebenslang';

  @override
  String get active => 'Aktiv';

  @override
  String get deleteSignInFirst =>
      'Melde dich zuerst mit dem Konto an, das du löschen möchtest.';

  @override
  String get deleteAccountQuestion => 'Konto löschen?';

  @override
  String get deleteAccountBody =>
      'Dein Konto, dein Fortschritt, deine XP und deine Duelle werden endgültig gelöscht. Das kann nicht rückgängig gemacht werden.\n\nEin Abo über den App Store oder Google Play endet dadurch nicht: kündige es zuerst in den Abos deines Handys.';

  @override
  String get deletePermanently => 'Endgültig löschen';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'Löschen hat nicht geklappt. Versuche es erneut oder schreib an $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Konto nicht gelöscht';

  @override
  String get accountDeleted => 'Dein Konto wurde gelöscht.';

  @override
  String get notificationsOff =>
      'Mitteilungen sind für Bible Quizzes aus. Schalte sie in den Einstellungen deines Handys ein.';

  @override
  String get purchasesRestored => 'Käufe wiederhergestellt';

  @override
  String get settingsReminder => 'Erinnerung';

  @override
  String get settingsTime => 'Uhrzeit';

  @override
  String get settingsPlaying => 'Spielen';

  @override
  String get settingsReadChapterFirst => 'Zuerst das Kapitel lesen';

  @override
  String get settingsShowReference => 'Bibelstelle bei der Erklärung';

  @override
  String get settingsLargeText => 'Große Fragetexte';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get settingsManage => 'Verwalten';

  @override
  String get signOut => 'Abmelden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get guestPlaying => 'Du spielst ohne Konto';

  @override
  String get signInOrCreate => 'Anmelden oder Konto erstellen';

  @override
  String get yourAccount => 'Dein Konto';

  @override
  String get signedIn => 'Angemeldet';

  @override
  String signedInAs(Object email) {
    return 'Angemeldet als $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice Sekunden';
  }
}
