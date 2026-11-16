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

  @override
  String get errGenericTitle => 'Er ging iets mis';

  @override
  String get errGenericMessage =>
      'We konden dit niet afronden. Probeer het zo nog een keer.';

  @override
  String get errNetworkTitle => 'Geen verbinding';

  @override
  String get errNetworkMessage =>
      'Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get errSignedOutTitle => 'Opnieuw inloggen';

  @override
  String get errSignedOutMessage =>
      'Je sessie is verlopen. Log opnieuw in om verder te spelen.';

  @override
  String get errRoomNotFoundTitle => 'Kamer niet gevonden';

  @override
  String get errRoomNotFoundMessage =>
      'Deze kamer bestaat niet meer of is gesloten. Controleer de code, of start zelf een nieuwe kamer.';

  @override
  String get errRoomFullTitle => 'Kamer is vol';

  @override
  String get errRoomFullMessage =>
      'Er passen geen spelers meer bij in deze kamer. Vraag de host om een nieuwe kamer te openen.';

  @override
  String get errRoomStartedTitle => 'Spel is al begonnen';

  @override
  String get errRoomStartedMessage =>
      'Deze quiz loopt al. Wacht tot de ronde klaar is of start een nieuwe kamer.';

  @override
  String get errRoomFinishedTitle => 'Spel is afgelopen';

  @override
  String get errRoomFinishedMessage =>
      'Deze kamer is gesloten. Start een nieuwe kamer om verder te spelen.';

  @override
  String get errRoomCodeTitle => 'Ongeldige kamercode';

  @override
  String get errRoomCodeMessage =>
      'Deze code klopt niet. Een kamercode bestaat uit 6 tekens.';

  @override
  String get errAlreadyInRoomTitle => 'Je zit al in deze kamer';

  @override
  String get errAlreadyInRoomMessage =>
      'Ga terug naar de kamer om verder te spelen.';

  @override
  String get errPremiumTitle => 'Premium vereist';

  @override
  String get errPremiumMessage =>
      'Zelf een kamer hosten hoort bij Bijbelquiz Premium. Meespelen kan altijd gratis.';

  @override
  String get errForbiddenTitle => 'Geen toegang';

  @override
  String get errForbiddenMessage => 'Alleen de host kan dit doen.';

  @override
  String get errRateLimitedTitle => 'Even wachten';

  @override
  String get errRateLimitedMessage =>
      'Je probeerde het te vaak achter elkaar. Wacht een moment en probeer het opnieuw.';

  @override
  String get errNotFoundTitle => 'Niet gevonden';

  @override
  String get errNotFoundMessage =>
      'We konden dit niet vinden. Ga terug en probeer het opnieuw.';

  @override
  String get errConflictTitle => 'Dat kan nu niet';

  @override
  String get errConflictMessage =>
      'Deze actie past niet bij de huidige stand van het spel. Ververs en probeer het opnieuw.';

  @override
  String get errServerTitle => 'Server reageert niet';

  @override
  String get errServerMessage =>
      'Er ging iets mis aan onze kant. Probeer het over een paar seconden nog eens.';

  @override
  String get errLiveLostTitle => 'Live verbinding weg';

  @override
  String get errLiveLostMessage =>
      'De live verbinding viel weg. We halen de stand nu automatisch op.';

  @override
  String get errLoginTitle => 'Inloggen mislukt';

  @override
  String get errLoginBadCredentials =>
      'Dit e-mailadres of wachtwoord klopt niet.';

  @override
  String get errAccountExistsTitle => 'Account bestaat al';

  @override
  String get errAccountExistsMessage =>
      'Er bestaat al een account met dit e-mailadres. Log in.';

  @override
  String get errRegisterTitle => 'Registreren mislukt';

  @override
  String get errRegisterMessage =>
      'We konden je account niet aanmaken. Probeer het opnieuw.';

  @override
  String get errLoginMessage =>
      'We konden je niet inloggen. Probeer het opnieuw.';

  @override
  String get errLeaderboardTitle => 'Ranglijst niet geladen';

  @override
  String get errLeaderboardMessage =>
      'We konden de ranglijst niet ophalen. Probeer het opnieuw.';

  @override
  String get errQuizzesTitle => 'Quizzen niet geladen';

  @override
  String get errQuizzesMessage =>
      'We konden de quizzen niet ophalen. Probeer het opnieuw.';

  @override
  String get errProfileTitle => 'Profiel niet geladen';

  @override
  String get errProfileMessage =>
      'We konden je profiel niet ophalen. Probeer het opnieuw.';

  @override
  String get errPurchaseTitle => 'Aankoop mislukt';

  @override
  String get errPurchaseMessage =>
      'De aankoop is niet afgerond. Er is niets in rekening gebracht.';

  @override
  String get streakReminderTitle => 'Je reeks staat op het spel';

  @override
  String get streakReminderChannel => 'Reeksherinnering';

  @override
  String get streakReminderChannelDescription =>
      'Een herinnering op de avond dat je reeks dreigt te verlopen.';

  @override
  String streakReminderBody(Object streak) {
    return 'Je reeks van $streak dagen loopt vanavond af. Eén quiz is genoeg om hem te houden.';
  }

  @override
  String get navQuizzes => 'Quizzen';

  @override
  String get navTogether => 'Samen';

  @override
  String get navLeaderboard => 'Ranglijst';

  @override
  String get navProfile => 'Profiel';

  @override
  String get savedQuizFallback => 'je quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Je score voor \"$title\" is opgeslagen (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved quizzen opgeslagen (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Voortgang bewaard';

  @override
  String get navHome => 'Home';

  @override
  String get avatarLamb => 'Lam';

  @override
  String get avatarLion => 'Leeuw';

  @override
  String get avatarDove => 'Duif';

  @override
  String get avatarOwl => 'Uil';

  @override
  String get avatarDeer => 'Hert';

  @override
  String get avatarOx => 'Os';

  @override
  String get avatarSand => 'Zand';

  @override
  String get avatarLapis => 'Lapis';

  @override
  String get avatarClay => 'Klei';

  @override
  String get avatarOlive => 'Olijf';

  @override
  String get avatarRose => 'Roos';

  @override
  String get avatarSlate => 'Leisteen';

  @override
  String get avatarParchment => 'Perkament';

  @override
  String get avatarSky => 'Hemel';

  @override
  String get avatarSage => 'Salie';

  @override
  String get avatarSunrise => 'Zonsopgang';

  @override
  String get avatarNight => 'Nacht';

  @override
  String get avatarBlush => 'Blos';

  @override
  String get avatarNone => 'Geen';

  @override
  String get avatarGlasses => 'Bril';

  @override
  String get avatarCap => 'Pet';

  @override
  String get avatarScarf => 'Sjaal';

  @override
  String get avatarCrown => 'Kroon';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character met $accessory';
  }

  @override
  String get wordmarkFirst => 'Bijbel';

  @override
  String get wordmarkSecond => 'Quiz';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get actionBack => 'Terug';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount vragen';
  }

  @override
  String get actionStart => 'Start';

  @override
  String get authGoogleAndroidInterrupted =>
      'Google-login onderbroken op Android. Controleer SHA-1/SHA-256 van de release key in Google Cloud OAuth client.';

  @override
  String get authGoogleNoToken =>
      'Google gaf geen idToken terug. Probeer opnieuw of kies een ander account.';

  @override
  String get authAppleUnavailable =>
      'Apple-login is niet beschikbaar op dit apparaat. Voeg web fallback toe met APPLE_SERVICE_ID en APPLE_REDIRECT_URI of controleer je Apple ID/provisioning.';

  @override
  String get authAppleError1000 =>
      'Apple-login kon niet worden gestart (AuthorizationError 1000). Dit is meestal een iOS-device/provisioning probleem: gebruik een echte iPhone (of iOS-simulator met Apple ID), vernieuw signing/provisioning in Xcode voor bundle ID com.bijbelquiz.app en installeer de app opnieuw.';

  @override
  String get authAppleWebNotConfigured =>
      'Apple web-fallback is niet geconfigureerd. Stel APPLE_SERVICE_ID en APPLE_REDIRECT_URI in.';

  @override
  String get authWelcomeBack => 'Welkom terug';

  @override
  String get authLoginSubtitle =>
      'Log in om je voortgang bij te houden en mee te doen op de ranglijst.';

  @override
  String get authEmailHint => 'naam@voorbeeld.nl';

  @override
  String get authPassword => 'Wachtwoord';

  @override
  String get authPasswordHint => 'Je wachtwoord';

  @override
  String get authSignIn => 'Inloggen';

  @override
  String get authNoAccount => 'Nog geen account?';

  @override
  String get authRegister => 'Registreren';

  @override
  String get authCreateAccount => 'Account aanmaken';

  @override
  String get authCreateSubtitle => 'Gratis, en je voortgang blijft bewaard.';

  @override
  String get authName => 'Naam';

  @override
  String get authNameHelp =>
      'Zo zien anderen je op de ranglijst en als je samen speelt.';

  @override
  String get authTermsPrefixRegister =>
      'Door een account te maken ga je akkoord met de ';

  @override
  String get authHaveAccount => 'Heb je al een account?';

  @override
  String get splashTagline => 'Hoe goed ken jij de Bijbel?';

  @override
  String get authOrEmail => 'of met e-mail';

  @override
  String get authTermsPrefix => 'Door verder te gaan ga je akkoord met de ';

  @override
  String get errLinkTitle => 'Link niet geopend';

  @override
  String get errLinkMessage =>
      'We konden deze pagina niet openen. Probeer het opnieuw.';

  @override
  String get authTermsAnd => ' en het ';

  @override
  String get authShowPassword => 'Wachtwoord tonen';

  @override
  String get authHidePassword => 'Wachtwoord verbergen';

  @override
  String get authContinueGoogle => 'Doorgaan met Google';

  @override
  String get authContinueApple => 'Doorgaan met Apple';

  @override
  String get dataInfoTitle => 'Hoe we met je gegevens omgaan';

  @override
  String get dataInfoBody =>
      'Bij het inloggen of registreren gebruiken we alleen gegevens die nodig zijn om je account te laten werken, zoals je naam, e-mailadres en inloggegevens.\n\nJe gegevens worden via beveiligde verbindingen verzonden en we delen ze niet voor advertenties zonder jouw toestemming.\n\nJe kunt altijd je account laten verwijderen. Neem hiervoor contact op via info@bijbelquiz.com of via de supportkanalen in de app. Na verwijdering worden je accountgegevens verwijderd volgens ons privacybeleid.';

  @override
  String get dataInfoMore => 'Meer over gegevensgebruik';

  @override
  String get homeContinue => 'Verder spelen';

  @override
  String get homeAll => 'Alles';

  @override
  String get homePickTopic => 'Kies een onderwerp';

  @override
  String get homePopular => 'Populaire quizzen';

  @override
  String get streakOneDay => 'Reeks van 1 dag';

  @override
  String streakDays(Object streak) {
    return 'Reeks van $streak dagen';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count vragen';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz van de dag: $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ VAN DE DAG';

  @override
  String get actionUnlock => 'Ontgrendel';

  @override
  String get actionPlayNow => 'Speel nu';

  @override
  String get homeChallengeLoading =>
      'Nieuwe uitdaging verschijnt zodra quizdata geladen is.';

  @override
  String get homeLoadFailed => 'Home kon niet laden';

  @override
  String get checkConnectionRetry =>
      'Controleer je verbinding en probeer het opnieuw.';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get homeGuestTitle => 'Speel gratis, zonder account';

  @override
  String get homeGuestBody =>
      'Maak er een aan om je score, punten en reeks te bewaren.';

  @override
  String get homeGuestAction => 'Voortgang bewaren';

  @override
  String chapterN(Object chapter) {
    return 'Hoofdstuk $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText goed';
  }

  @override
  String get played => 'Gespeeld';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score van $total goed';
  }

  @override
  String get books39 => '39 boeken';

  @override
  String get books27 => '27 boeken';

  @override
  String get catGeneral => 'Algemeen';

  @override
  String get catWholeBible => 'Hele Bijbel';

  @override
  String get catByTheme => 'Per thema';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount vragen';
  }

  @override
  String get groupsLoadFailed => 'Kon je groepen niet laden.';

  @override
  String get groupSaveFailed => 'Groep bewaren is niet gelukt.';

  @override
  String get groupSaveFailedTitle => 'Groep bewaren mislukt';

  @override
  String get groupSaveNoGroup =>
      'De server gaf geen groep terug. Probeer het opnieuw.';

  @override
  String get groupRenameFailed => 'Hernoemen is niet gelukt.';

  @override
  String get deleteFailed => 'Verwijderen is niet gelukt.';

  @override
  String get groupStandingsFailed => 'Kon de stand van deze groep niet laden.';

  @override
  String get groupsTitle => 'Groepen';

  @override
  String get groupSingular => 'Groep';

  @override
  String get leaderboardLoadFailed => 'Ranglijst kon niet laden';

  @override
  String get leaderboardMonthHint => 'XP van de afgelopen 30 dagen';

  @override
  String get leaderboardAllTimeHint => 'Alle XP sinds de start telt mee';

  @override
  String get periodMonth => 'Deze maand';

  @override
  String get periodAllTime => 'Altijd';

  @override
  String get periodLabel => 'Periode';

  @override
  String get everyone => 'Iedereen';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return 'Nog $gap XP tot plek $rank';
  }

  @override
  String get showLess => 'Toon minder';

  @override
  String showAllPlayers(Object total) {
    return 'Toon alle $total spelers';
  }

  @override
  String get leaderboardGuestHint => 'Met een gratis account telt je XP mee.';

  @override
  String get leaderboardNotOnIt => 'Je staat nog niet op deze ranglijst';

  @override
  String get leaderboardPlayToJoin => 'Speel een quiz om mee te doen.';

  @override
  String get leaderboardNoData => 'Nog geen ranglijstdata beschikbaar.';

  @override
  String get leaderboardEmpty => 'Nog niemand op de ranglijst';

  @override
  String get onboardingTagline =>
      'Korte quizzen over de bijbelboeken, alleen of samen met anderen.';

  @override
  String get onboardingGuest => 'Eerst spelen zonder account';

  @override
  String get onboardingPreviewA11y =>
      'Voorbeeld: een quizvraag met het goede antwoord, een duel tegen Lotte, XP en een reeks';

  @override
  String get onboardingSampleQuestion =>
      'Hoeveel broden had de jongen bij zich?';

  @override
  String get onboardingSampleStreak => '6 dagen op rij';

  @override
  String get seasonEndsToday => 'Loopt vandaag af';

  @override
  String get seasonOneDayLeft => 'Nog 1 dag';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return 'Nog $daysRemaining dagen';
  }

  @override
  String get season => 'Seizoen';

  @override
  String get manageSubscription => 'Abonnement beheren';

  @override
  String get viaWebsite => 'Via de website';

  @override
  String get lifetime => 'Levenslang';

  @override
  String get active => 'Actief';

  @override
  String get deleteSignInFirst =>
      'Log eerst in met het account dat je wilt verwijderen.';

  @override
  String get deleteAccountQuestion => 'Account verwijderen?';

  @override
  String get deleteAccountBody =>
      'Je account, je voortgang, je XP en je duels worden definitief verwijderd. Dit kan niet ongedaan worden gemaakt.\n\nEen abonnement via de App Store of Google Play stopt hierdoor niet: zeg dat eerst op in de abonnementen van je telefoon.';

  @override
  String get deletePermanently => 'Definitief verwijderen';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'Verwijderen is niet gelukt. Probeer het opnieuw of mail $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Account niet verwijderd';

  @override
  String get accountDeleted => 'Je account is verwijderd.';

  @override
  String get notificationsOff =>
      'Meldingen staan uit voor BijbelQuiz. Zet ze aan in de instellingen van je telefoon.';

  @override
  String get purchasesRestored => 'Aankopen hersteld';

  @override
  String get settingsReminder => 'Herinnering';

  @override
  String get settingsTime => 'Tijdstip';

  @override
  String get settingsPlaying => 'Spelen';

  @override
  String get settingsReadChapterFirst => 'Eerst het hoofdstuk lezen';

  @override
  String get settingsShowReference => 'Bijbelverwijzing bij uitleg';

  @override
  String get settingsLargeText => 'Grote vraagtekst';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get settingsManage => 'Beheer';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get guestPlaying => 'Je speelt zonder account';

  @override
  String get signInOrCreate => 'Inloggen of een account aanmaken';

  @override
  String get yourAccount => 'Je account';

  @override
  String get signedIn => 'Ingelogd';

  @override
  String signedInAs(Object email) {
    return 'Ingelogd als $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice seconden';
  }
}
