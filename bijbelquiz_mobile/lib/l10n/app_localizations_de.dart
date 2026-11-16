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

  @override
  String get joinFailed => 'Beitreten hat nicht geklappt.';

  @override
  String get joinFailedConnection =>
      'Beitreten hat nicht geklappt. Prüfe deine Verbindung.';

  @override
  String get trialEndingTitle => 'Dein Testzeitraum endet bald';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Dein Bible Quizzes Premium beginnt in $kTrialReminderDaysBeforeEnd Tagen. Willst du nicht weitermachen? Kündige in den Store-Einstellungen.';
  }

  @override
  String get trialReminderChannel => 'Testzeitraum-Erinnerung';

  @override
  String get trialReminderChannelDescription =>
      'Eine Erinnerung, bevor dein kostenloser Testzeitraum endet.';

  @override
  String get supportEmail => 'info@biblequizzes.app';

  @override
  String get groupCodeIncomplete => 'Gib den vollständigen Gruppencode ein.';

  @override
  String groupJoined(Object name) {
    return 'Du gehörst jetzt zu $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Öffne biblequizzes.app/group-license in deinem Browser.';

  @override
  String get groupLicense => 'Gruppenlizenz';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Schreib uns an $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      'Hat deine Jugendleitung, dein Pastor oder deine Lehrkraft einen Gruppencode? Gib ihn unten ein und du hast sofort Premium.';

  @override
  String get premiumViaGroup => 'Premium über deine Gruppe';

  @override
  String get yourGroups => 'Deine Gruppen';

  @override
  String get premiumWholeGroup => 'Premium für deine ganze Gruppe';

  @override
  String get forChurches => 'Für Gemeinden, Schulen und Vereine';

  @override
  String get groupPerkAll => 'Alles von Premium für jedes Mitglied';

  @override
  String get groupPerkCode => 'Ein Code, den du im Raum vorliest';

  @override
  String get groupPerkManage => 'Du bestimmst selbst, wer mitmacht';

  @override
  String get groupLicenseWebsiteOnly =>
      'Eine Gruppenlizenz kaufst du auf der Website, weil ein Kauf im App Store an ein einzelnes Konto gebunden ist und nicht an eine Gruppe.';

  @override
  String get openWebsite => 'biblequizzes.app öffnen';

  @override
  String get youManageGroup => 'Du verwaltest diese Gruppe';

  @override
  String get youTakePart => 'Du machst mit';

  @override
  String get groupCode => 'Gruppencode';

  @override
  String get purchaseReceivedNotActive =>
      'Dein Kauf ist eingegangen, aber Premium ist noch nicht aktiv. Tippe in einer Minute auf \"Wiederherstellen\".';

  @override
  String noPurchaseFound(Object storeName) {
    return 'Wir haben auf diesem $storeName-Konto keinen Premium-Kauf gefunden.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Dein Kauf wartet noch auf Freigabe oder Zahlung. Premium schaltet sich ein, sobald $storeName ihn abschließt.';
  }

  @override
  String get noInternetRetry =>
      'Keine Internetverbindung. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get alreadyPurchased =>
      'Du hast das schon gekauft. Tippe auf \"Wiederherstellen\", um es zurückzuholen.';

  @override
  String get purchaseOtherAccount =>
      'Dieser Kauf gehört bereits zu einem anderen Bible-Quizzes-Konto. Melde dich mit diesem Konto an, um dein Premium zu nutzen.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'Käufe sind auf diesem Gerät nicht erlaubt. Prüfe die Einstellungen deines $store-Kontos.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'Dieses Abo ist im $store gerade nicht verfügbar. Versuche es später erneut.';
  }

  @override
  String storeError(Object store) {
    return '$store meldet einen Fehler. Versuche es später erneut.';
  }

  @override
  String get purchasesNotInVersion =>
      'Käufe sind in dieser App-Version nicht verfügbar.';

  @override
  String get restoreFailed =>
      'Wiederherstellen hat nicht geklappt. Versuche es erneut.';

  @override
  String get introPerkExplain =>
      'Eine Erklärung zu jeder Frage: warum die Antwort stimmt';

  @override
  String get introPerkAll => 'Alle Quizze, so oft du willst';

  @override
  String get introPerkReview => 'Eine vollständige Auswertung nach jedem Quiz';

  @override
  String get introPerkDaily => 'Jeden Tag ein neues Quiz, ohne Limit';

  @override
  String get introPerkStick =>
      'Eine Erklärung zu jeder Frage, damit es hängen bleibt';

  @override
  String get introPerkLookBack => 'Deine Antworten nach jedem Quiz ansehen';

  @override
  String get introPerkTogetherFree =>
      'Zusammen spielen bleibt für alle kostenlos';

  @override
  String get introPerkSoloUnlimited => 'Dazu unbegrenzt allein weiterspielen';

  @override
  String get introPerkDiscuss =>
      'Eine Erklärung zu jeder Frage zum gemeinsamen Nachbesprechen';

  @override
  String stepOfThree(Object page) {
    return 'Schritt $page von 3';
  }

  @override
  String get actionNext => 'Weiter';

  @override
  String get introGrowQuestion => 'Worin möchtest du wachsen?';

  @override
  String get introGrowSubtitle => 'Dann zeigen wir, was Premium dafür tut.';

  @override
  String get introGoalKnowledge => 'Mehr Bibelwissen';

  @override
  String get introGoalKnowledgeBody => 'Verstehen, warum eine Antwort stimmt.';

  @override
  String get introGoalDaily => 'Jeden Tag etwas lernen';

  @override
  String get introGoalDailyBody => 'Eine Gewohnheit aufbauen und halten.';

  @override
  String get introGoalGroupBody =>
      'Mit Familie oder einer Gruppe gegeneinander.';

  @override
  String get introYouGet => 'Das bekommst du dazu';

  @override
  String get introOneMembership =>
      'Alles in einer Mitgliedschaft, im Web und in der App.';

  @override
  String get choosePlan => 'Wähle deinen Plan';

  @override
  String get pricesNextPage =>
      'Auf der nächsten Seite siehst du die Preise. Kündigen geht jederzeit.';

  @override
  String get accountWebAndApp =>
      'Dein Konto funktioniert gleichzeitig im Web und in der App. Ein Kauf auf dem Handy gibt dir auch Premium auf der Website und umgekehrt.';

  @override
  String get paywallHeadlineDefault => 'Unbegrenzt spielen\nmit Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'Deine $kFreeQuizLimit kostenlosen\nQuizze sind gespielt';
  }

  @override
  String get paywallHeadlineTogether => 'Unbegrenzt zusammen\nweiterspielen';

  @override
  String get paywallHeadlineGroup => 'Spiel mit deiner\nganzen Gruppe';

  @override
  String get paywallHeadlineExplain => 'Lies bei jeder Frage\nwarum';

  @override
  String get paywallHeadlineUnlock => 'Alle Quizze\nfreischalten';

  @override
  String get premiumRestored => 'Premium wiederhergestellt';

  @override
  String get welcomePremium => 'Willkommen bei Premium';

  @override
  String get premiumBackOn => 'Dein Premium ist auf diesem Konto wieder aktiv.';

  @override
  String get premiumFullAccess =>
      'Du hast jetzt vollen Zugriff auf alle Premium-Funktionen, in der App und auf der Website. Viel Spaß!';

  @override
  String get playOnPremium => 'Spiel mit Premium weiter.';

  @override
  String get chooseSubscription => 'Wähle ein Abo';

  @override
  String get yearly => 'Jährlich';

  @override
  String get perYear => 'pro Jahr';

  @override
  String get monthly => 'Monatlich';

  @override
  String get perMonth => 'pro Monat';

  @override
  String get noTrial => 'Kein Testzeitraum';

  @override
  String get reloadPrices => 'Preise neu laden';

  @override
  String storeUnreachable(Object storeName) {
    return '$storeName ist gerade nicht erreichbar. Prüfe deine Verbindung.';
  }

  @override
  String get restorePurchase => 'Kauf wiederherstellen';

  @override
  String get terms => 'Bedingungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get alreadyPremium =>
      'Du hast auf diesem Konto schon Premium. Es wurde nichts abgebucht.';

  @override
  String get premiumOn => 'Premium ist aktiv';

  @override
  String get restoreSignIn =>
      'Melde dich mit deinem Konto an, dann stellen wir deine Käufe dort wieder her.';

  @override
  String get needAccountForPremium =>
      'Erstelle zuerst ein kostenloses Konto oder melde dich an, damit Premium dir gehört - in der App und auf der Website.';

  @override
  String get accountNeeded => 'Konto nötig';

  @override
  String get pleaseWait => 'Einen Moment';

  @override
  String get nothingToRestore => 'Nichts wiederherzustellen';

  @override
  String get viewAllPlans => 'Alle Pläne ansehen';

  @override
  String get explainEveryAnswer => 'Erklärung zu jeder Antwort';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'Kostenlos spielst du $kFreeQuizLimit Quizze. Mit Premium öffnen sich alle Bücher der Bibel, auch Psalmen und Offenbarung.';
  }

  @override
  String get premiumEverythingOpen => 'Mit Premium alles offen';

  @override
  String get abbrGenesis => '1Mo';

  @override
  String get quizzes12 => '12 Quizze';

  @override
  String get abbrPsalms => 'Ps';

  @override
  String get quizzes15 => '15 Quizze';

  @override
  String get abbrRevelation => 'Offb';

  @override
  String get bookRevelation => 'Offenbarung';

  @override
  String get quizzes9 => '9 Quizze';

  @override
  String get free => 'Kostenlos';

  @override
  String get orLifetime => 'Oder einmalig: Premium lebenslang';

  @override
  String lifetimeOnce(Object price) {
    return 'Premium lebenslang, einmalig $price';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly pro Woche über $lifetimeHorizonYears Jahre';
  }

  @override
  String get lifetimePremium => 'Premium lebenslang';

  @override
  String get payNothingToday => 'Heute zahlst du nichts.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'Heute zahlst du nichts. Erinnerung an Tag $day.';
  }

  @override
  String get cancelAnytime => 'Kündige, wann du willst.';

  @override
  String get payOnceNoSub => 'Einmal zahlen, kein Abo.';

  @override
  String get startPremium => 'Premium starten';

  @override
  String tryTrial(Object label) {
    return '$label testen';
  }

  @override
  String get badgeFirstStepsDesc => 'Schließe dein erstes Quiz ab.';

  @override
  String get badgeKnowledgeSeeker => 'Wissenssucher';

  @override
  String get badgeKnowledgeSeekerDesc => 'Spiele 10 verschiedene Quizze.';

  @override
  String get badgePerfect => 'Fehlerlos';

  @override
  String get badgePerfectDesc => 'Erreiche 100% in einem Quiz.';

  @override
  String get badgeOnARoll => 'In Fahrt';

  @override
  String get badgeOnARollDesc => 'Baue eine Serie von 3 Tagen auf.';

  @override
  String get badgeDedicated => 'Engagiert';

  @override
  String get badgeDedicatedDesc => 'Spiele 7 Tage am Stück.';

  @override
  String get badgeScholar => 'Gelehrter';

  @override
  String get badgeMaster => 'Meister';

  @override
  String get badgeAllRounder => 'Allrounder';

  @override
  String get badgeAllRounderDesc => 'Spiele eine breite Auswahl an Quizzen.';

  @override
  String get rankSeeker => 'Suchender';

  @override
  String get saveFailed => 'Speichern hat nicht geklappt. Versuche es erneut.';

  @override
  String get saveFailedConnection =>
      'Speichern hat nicht geklappt. Prüfe deine Verbindung.';

  @override
  String get achievements => 'Erfolge';

  @override
  String get achievementsLoadFailed => 'Erfolge konnten nicht laden';

  @override
  String get noBadgesYet =>
      'Noch keine Abzeichen. Spiele Quizze, um dein erstes freizuschalten.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'Noch zu holen · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked von $total Abzeichen erreicht';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked von $total Abzeichen';
  }

  @override
  String get allEarned => 'Alles erreicht';

  @override
  String leftToEarn(Object left) {
    return 'Noch $left zu holen';
  }

  @override
  String get profileUpdated => 'Profil aktualisiert.';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get profileLoadFailed => 'Profil konnte nicht laden';

  @override
  String get actionSave => 'Speichern';

  @override
  String get surpriseMe => 'Überrasch mich';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get displayNameHint => 'Wie du in der Rangliste erscheinst';

  @override
  String get displayNameHelp =>
      'Sichtbar in der Rangliste und im Mehrspielermodus. Alle 30 Tage änderbar.';

  @override
  String get buildMascot => 'Stell dein Maskottchen zusammen';

  @override
  String get figure => 'Figur';

  @override
  String get color => 'Farbe';

  @override
  String get background => 'Hintergrund';

  @override
  String get accessory => 'Accessoire';

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get settings => 'Einstellungen';

  @override
  String get statistics => 'Statistiken';

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String levelN(Object level) {
    return 'Level $level';
  }

  @override
  String get maxLevel => 'Höchstes Level erreicht';

  @override
  String progressToLevel(Object level) {
    return 'Fortschritt zu Level $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return 'Noch $xpRemaining XP bis Level $level';
  }

  @override
  String get daysInARow => 'Tage am Stück';

  @override
  String get quizzesPlayed => 'Gespielte Quizze';

  @override
  String get averageScore => 'Durchschnitt';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'Alle Erfolge ansehen, $unlockedCount von $overviewCount erreicht';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'Alle $unlockedCount von $overviewCount';
  }

  @override
  String get youHavePremium => 'Du hast Premium';

  @override
  String get youPlayFree => 'Du spielst kostenlos';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score von $totalQuestions richtig';
  }

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get guestPerkKeep => 'Punkte, Level und Serie, die bleiben';

  @override
  String get guestPerkLeaderboard => 'Ein Platz in der Rangliste';

  @override
  String get guestPerkBadges => 'Abzeichen für deine Erfolge';

  @override
  String get guestPerkWebsite => 'Derselbe Fortschritt auf biblequizzes.app';

  @override
  String get saveYourProgress => 'Speichere deinen Fortschritt';

  @override
  String get guestExplain =>
      'Du spielst ohne Konto. Das geht, aber Ergebnis, Punkte und Serie bleiben nur mit einem kostenlosen Konto gespeichert.';

  @override
  String get createFreeAccount => 'Kostenloses Konto erstellen';

  @override
  String get pendingOne => 'Ein Quiz wartet auf dein Konto';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount Quizze warten auf dein Konto';
  }

  @override
  String get withAccount => 'Mit einem Konto';

  @override
  String get oneQuiz => '1 Quiz';

  @override
  String quizzesN(Object total) {
    return '$total Quizze';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played von $total gespielt';
  }

  @override
  String get quizzesLoadFailed => 'Quizze konnten nicht laden';

  @override
  String get byBibleBook => 'Nach Bibelbuch';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount Bücher · $quizzes Quizze';
  }

  @override
  String get bibleBook => 'Bibelbuch';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount Quizze';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played von $quizzesCount gespielt';
  }

  @override
  String get noQuizzesForBook => 'Zu diesem Buch gibt es noch keine Quizze.';

  @override
  String allQuizzesAbout(Object name) {
    return 'Alle Quizze zu $name';
  }

  @override
  String get startWith => 'BEGINNE MIT';

  @override
  String get continueWith => 'WEITER MIT';

  @override
  String get anyLevel => 'Jedes Level';

  @override
  String get easy => 'Leicht';

  @override
  String get medium => 'Mittel';

  @override
  String get hard => 'Schwer';

  @override
  String get results => 'Ergebnisse';

  @override
  String get allQuizzes => 'Alle Quizze';

  @override
  String get popular => 'Beliebt';

  @override
  String get allBooks => 'Alle Bücher';

  @override
  String get searchHint => 'Suche ein Bibelbuch oder Thema';

  @override
  String get clear => 'Löschen';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount Fragen · $questionCount2 Min.';
  }

  @override
  String get notPlayedYet => 'Noch nicht gespielt';

  @override
  String get noQuizzesFilters =>
      'Mit den aktuellen Filtern wurden keine Quizze gefunden.';

  @override
  String get sortBibleOrder => 'Bibelreihenfolge';

  @override
  String get sortMostPopular => 'Am beliebtesten';

  @override
  String get sortNewest => 'Neueste zuerst';

  @override
  String get sortShortest => 'Kürzeste';

  @override
  String get sort => 'Sortieren';

  @override
  String get hideText => 'Text ausblenden';

  @override
  String hideTextOf(Object reference) {
    return 'Den Text von $reference ausblenden';
  }

  @override
  String get unlockPremiumExplain => 'Premium freischalten für die Erklärung';

  @override
  String get readWhyWrong => 'Lies, warum das falsch war';

  @override
  String get timeUp => 'Zeit um';

  @override
  String get finishQuiz => 'Quiz beenden';

  @override
  String get a11yYourAnswerRight => ', deine Antwort, richtig';

  @override
  String get a11yCorrectAnswer => ', die richtige Antwort';

  @override
  String get a11yYourAnswerWrong => ', deine Antwort, falsch';

  @override
  String questionOf(Object current, Object total) {
    return 'Frage $current von $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return 'Noch $secondsLeft Sekunden';
  }

  @override
  String get wellPlayed => 'Gut gespielt';

  @override
  String get niceTry => 'Guter Versuch';

  @override
  String get nextQuiz => 'Nächstes Quiz';

  @override
  String get playWithOthers => 'Mit anderen zusammen spielen';

  @override
  String get viewAnswers => 'Antworten ansehen';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Ergebnis $correct von $total';
  }

  @override
  String get newBestScore => 'Neue Bestleistung';

  @override
  String get scoreNotSaved => 'Dein Ergebnis ist noch nicht gespeichert';

  @override
  String get scoreSaving => 'Dein Ergebnis wird gespeichert';

  @override
  String get again => 'Nochmal';

  @override
  String get noExtraXp => 'Diesmal keine extra XP';

  @override
  String get replayRule =>
      'Eine Wiederholung zählt nur, wenn du dich verbesserst.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return 'Noch $xpToNextLevel XP bis Level $level';
  }

  @override
  String get playTomorrowStreak => 'Spiel morgen, um deine Serie zu halten';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Behalte dein Ergebnis, $previewXp XP und deine Serie';
  }

  @override
  String get keepScoreBody =>
      'Melde dich an oder erstelle ein kostenloses Konto, dann wird dieses Ergebnis sofort gutgeschrieben. Deine Quizze zählen dann für dein Level und die Rangliste.';

  @override
  String get yourAnswers => 'Deine Antworten';

  @override
  String get allCorrectReview =>
      'Alles richtig. Sieh dir die Erklärung zu jeder Frage an.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount von $questionsCount Fragen falsch.';
  }

  @override
  String get fullExplainPremium =>
      'Die vollständige Erklärung zu jeder Frage gehört zu Premium.';

  @override
  String get unlockFullReview => 'Vollständige Auswertung freischalten';

  @override
  String get correct => 'Richtig';

  @override
  String get wrong => 'Falsch';

  @override
  String correctAnswerIs(Object text) {
    return 'Richtige Antwort: $text';
  }

  @override
  String get quizLoadFailed => 'Quiz konnte nicht laden';

  @override
  String get howToPlay => 'Wie möchtest du spielen?';

  @override
  String get rememberedNext =>
      'Wird für deine nächsten Quizze gespeichert, auch auf der Website.';

  @override
  String get freeLeftPrefix => 'Noch ';

  @override
  String get freeLeftOne => ' kostenloses Quiz';

  @override
  String get freeLeftMany => ' kostenlose Quizze';

  @override
  String get unlockWithPremium => 'Mit Premium freischalten';

  @override
  String readAndStart(Object label) {
    return '$label lesen und starten';
  }

  @override
  String get startQuiz => 'Quiz starten';

  @override
  String readFirstLabel(Object label) {
    return 'Zuerst $label lesen';
  }

  @override
  String get alreadyPlayed => 'Schon gespielt';

  @override
  String get playAgainBetter => 'Spiel nochmal für ein besseres Ergebnis';

  @override
  String get yourBestScore => 'Deine beste Punktzahl';

  @override
  String lastPlayed(Object last) {
    return 'Zuletzt gespielt $last';
  }

  @override
  String get testKnowledge => 'Teste dein Wissen zu diesem Thema.';

  @override
  String get aboutQuiz => 'Über dieses Quiz';

  @override
  String get finished => 'Beendet';

  @override
  String get readChapterExplain =>
      'Du liest das Kapitel, um das es im Quiz geht, bevor die Fragen beginnen.';

  @override
  String get timePerQuestion => 'Zeit pro Frage';

  @override
  String get timerExplain =>
      'Standardmäßig aus. Schalte eine Uhr ein, wenn du dich herausfordern willst.';

  @override
  String get off => 'Aus';

  @override
  String get noChapterToRead => 'Kein Kapitel zum Lesen';

  @override
  String get multiChapter =>
      'Dieses Quiz umfasst mehr als ein Kapitel. Du kannst einfach mit dem Quiz beginnen.';

  @override
  String get chapterFetchFailed =>
      'Dieses Kapitel konnte gerade nicht geladen werden. Du kannst einfach mit dem Quiz beginnen.';

  @override
  String get readFirst => 'Zuerst lesen';

  @override
  String readBeforeQuiz(Object title) {
    return 'Lies vor dem Quiz $title';
  }

  @override
  String get bibleVersionName => 'Lutherbibel 1912';

  @override
  String get keepStreakQuestion => 'Deine Serie halten?';

  @override
  String keepStreakBody(Object streak) {
    return 'Du hast $streak Tage am Stück gespielt. Sollen wir dich an Tagen, an denen du noch nicht gespielt hast, um 19:00 erinnern?';
  }

  @override
  String get noQuestionsYet => 'Noch keine Fragen';

  @override
  String get quizNoQuestions => 'Dieses Quiz hat noch keine Fragen.';

  @override
  String get goBack => 'Zurück';

  @override
  String get today => 'heute';

  @override
  String get yesterday => 'gestern';

  @override
  String daysAgo(Object days) {
    return 'vor $days Tagen';
  }

  @override
  String onDate(Object date) {
    return 'am $date';
  }
}
