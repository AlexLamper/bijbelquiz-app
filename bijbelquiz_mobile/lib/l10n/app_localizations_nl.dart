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

  @override
  String get joinFailed => 'Deelnemen is niet gelukt.';

  @override
  String get joinFailedConnection =>
      'Deelnemen is niet gelukt. Controleer je verbinding.';

  @override
  String get trialEndingTitle => 'Je proefperiode loopt bijna af';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Over $kTrialReminderDaysBeforeEnd dagen gaat je BijbelQuiz Premium in. Wil je niet verder? Zeg dan op in je store-instellingen.';
  }

  @override
  String get trialReminderChannel => 'Herinnering proefperiode';

  @override
  String get trialReminderChannelDescription =>
      'Een herinnering voordat je gratis proefperiode afloopt.';

  @override
  String get supportEmail => 'info@bijbelquiz.com';

  @override
  String get groupCodeIncomplete => 'Vul de volledige groepscode in.';

  @override
  String groupJoined(Object name) {
    return 'Je hoort nu bij $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Ga naar bijbelquiz.com/groepslicentie in je browser.';

  @override
  String get groupLicense => 'Groepslicentie';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Mail ons op $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      'Heeft je jeugdleider, dominee of docent een groepscode? Vul hem hieronder in en je hebt meteen Premium.';

  @override
  String get premiumViaGroup => 'Premium via je groep';

  @override
  String get yourGroups => 'Jouw groepen';

  @override
  String get premiumWholeGroup => 'Premium voor je hele groep';

  @override
  String get forChurches => 'Voor kerken, scholen en verenigingen';

  @override
  String get groupPerkAll => 'Alles van Premium voor elk lid';

  @override
  String get groupPerkCode => 'Een code die je voorleest in de zaal';

  @override
  String get groupPerkManage => 'Je beheert zelf wie er meedoet';

  @override
  String get groupLicenseWebsiteOnly =>
      'Een groepslicentie koop je op de website, omdat een aankoop in de App Store aan een enkel account vastzit en niet aan een groep.';

  @override
  String get openWebsite => 'Open bijbelquiz.com';

  @override
  String get youManageGroup => 'Je beheert deze groep';

  @override
  String get youTakePart => 'Je doet mee';

  @override
  String get groupCode => 'Groepscode';

  @override
  String get purchaseReceivedNotActive =>
      'Je aankoop is ontvangen, maar Premium staat nog niet aan. Tik over een minuut op \"Herstellen\".';

  @override
  String noPurchaseFound(Object storeName) {
    return 'We vonden geen Premium-aankoop op dit $storeName-account.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Je aankoop wacht nog op goedkeuring of betaling. Premium gaat vanzelf aan zodra de $storeName die afrondt.';
  }

  @override
  String get noInternetRetry =>
      'Geen internetverbinding. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get alreadyPurchased =>
      'Je hebt dit al gekocht. Tik op \"Herstellen\" om het terug te zetten.';

  @override
  String get purchaseOtherAccount =>
      'Deze aankoop hoort al bij een ander BijbelQuiz-account. Log in met dat account om je Premium te gebruiken.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'Aankopen zijn niet toegestaan op dit apparaat. Controleer de instellingen van je $store-account.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'Dit abonnement is nu niet beschikbaar in de $store. Probeer het later opnieuw.';
  }

  @override
  String storeError(Object store) {
    return 'De $store geeft een fout. Probeer het later opnieuw.';
  }

  @override
  String get purchasesNotInVersion =>
      'Aankopen zijn in deze versie van de app niet beschikbaar.';

  @override
  String get restoreFailed => 'Herstellen is niet gelukt. Probeer het opnieuw.';

  @override
  String get introPerkExplain =>
      'Uitleg bij elke vraag: waarom het antwoord klopt';

  @override
  String get introPerkAll => 'Alle quizzen, zo vaak je wilt';

  @override
  String get introPerkReview => 'Een volledige review na elke quiz';

  @override
  String get introPerkDaily => 'Elke dag een nieuwe quiz, zonder limiet';

  @override
  String get introPerkStick => 'Uitleg bij elke vraag, zodat het blijft hangen';

  @override
  String get introPerkLookBack => 'Je antwoorden terugkijken na elke quiz';

  @override
  String get introPerkTogetherFree =>
      'Samen spelen blijft voor iedereen gratis';

  @override
  String get introPerkSoloUnlimited =>
      'Daarnaast alleen onbeperkt verder spelen';

  @override
  String get introPerkDiscuss => 'Uitleg bij elke vraag om samen na te praten';

  @override
  String stepOfThree(Object page) {
    return 'Stap $page van 3';
  }

  @override
  String get actionNext => 'Verder';

  @override
  String get introGrowQuestion => 'Waar wil je in groeien?';

  @override
  String get introGrowSubtitle =>
      'Dan laten we zien wat Premium daarvoor doet.';

  @override
  String get introGoalKnowledge => 'Meer Bijbelkennis';

  @override
  String get introGoalKnowledgeBody => 'Begrijpen waarom een antwoord klopt.';

  @override
  String get introGoalDaily => 'Elke dag iets leren';

  @override
  String get introGoalDailyBody => 'Een gewoonte opbouwen en vasthouden.';

  @override
  String get introGoalGroupBody => 'Met familie of een groep tegen elkaar.';

  @override
  String get introYouGet => 'Dit krijg je erbij';

  @override
  String get introOneMembership => 'Alles in een lidmaatschap, op web en app.';

  @override
  String get choosePlan => 'Kies je plan';

  @override
  String get pricesNextPage =>
      'Op de volgende pagina zie je de prijzen. Opzeggen kan altijd.';

  @override
  String get accountWebAndApp =>
      'Je account werkt op web en app tegelijk. Een aankoop op je telefoon geeft je ook Premium op de website, en andersom.';

  @override
  String get paywallHeadlineDefault => 'Speel onbeperkt\nmet Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'Je $kFreeQuizLimit gratis quizzen\nzijn gespeeld';
  }

  @override
  String get paywallHeadlineTogether => 'Speel onbeperkt\nsamen verder';

  @override
  String get paywallHeadlineGroup => 'Speel met je\nhele groep';

  @override
  String get paywallHeadlineExplain => 'Lees bij elke vraag\nwaarom';

  @override
  String get paywallHeadlineUnlock => 'Ontgrendel\nalle quizzen';

  @override
  String get premiumRestored => 'Premium hersteld';

  @override
  String get welcomePremium => 'Welkom bij Premium';

  @override
  String get premiumBackOn => 'Je Premium staat weer aan op dit account.';

  @override
  String get premiumFullAccess =>
      'Je hebt nu volledige toegang tot alle premium functies, in de app en op de website. Veel plezier!';

  @override
  String get playOnPremium => 'Speel verder met Premium.';

  @override
  String get chooseSubscription => 'Kies een abonnement';

  @override
  String get yearly => 'Jaarlijks';

  @override
  String get perYear => 'per jaar';

  @override
  String get monthly => 'Maandelijks';

  @override
  String get perMonth => 'per maand';

  @override
  String get noTrial => 'Geen proefperiode';

  @override
  String get reloadPrices => 'Prijzen opnieuw laden';

  @override
  String storeUnreachable(Object storeName) {
    return 'De $storeName is nu niet bereikbaar. Controleer je verbinding.';
  }

  @override
  String get restorePurchase => 'Aankoop herstellen';

  @override
  String get terms => 'Voorwaarden';

  @override
  String get privacy => 'Privacy';

  @override
  String get alreadyPremium =>
      'Je hebt al Premium op dit account. Er is niets afgeschreven.';

  @override
  String get premiumOn => 'Premium staat aan';

  @override
  String get restoreSignIn =>
      'Log in met je account, dan zetten we je aankopen terug op dat account.';

  @override
  String get needAccountForPremium =>
      'Maak eerst een gratis account of log in, dan hoort Premium bij jou - in de app en op de website.';

  @override
  String get accountNeeded => 'Account nodig';

  @override
  String get pleaseWait => 'Even geduld';

  @override
  String get nothingToRestore => 'Niets om te herstellen';

  @override
  String get viewAllPlans => 'Alle plannen bekijken';

  @override
  String get explainEveryAnswer => 'Uitleg bij elk antwoord';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'Gratis speel je $kFreeQuizLimit quizzen. Met Premium gaan alle bijbelboeken open, ook Psalmen en Openbaring.';
  }

  @override
  String get premiumEverythingOpen => 'Met Premium alles open';

  @override
  String get abbrGenesis => 'Gen';

  @override
  String get quizzes12 => '12 quizzen';

  @override
  String get abbrPsalms => 'Ps';

  @override
  String get quizzes15 => '15 quizzen';

  @override
  String get abbrRevelation => 'Opb';

  @override
  String get bookRevelation => 'Openbaring';

  @override
  String get quizzes9 => '9 quizzen';

  @override
  String get free => 'Gratis';

  @override
  String get orLifetime => 'Of eenmalig: levenslang Premium';

  @override
  String lifetimeOnce(Object price) {
    return 'Levenslang Premium, $price eenmalig';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly per week over $lifetimeHorizonYears jaar';
  }

  @override
  String get lifetimePremium => 'Levenslang Premium';

  @override
  String get payNothingToday => 'Vandaag betaal je niets.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'Vandaag betaal je niets. Herinnering op dag $day.';
  }

  @override
  String get cancelAnytime => 'Zeg op wanneer je wilt.';

  @override
  String get payOnceNoSub => 'Eenmalig betalen, geen abonnement.';

  @override
  String get startPremium => 'Start Premium';

  @override
  String tryTrial(Object label) {
    return 'Probeer $label';
  }

  @override
  String get badgeFirstStepsDesc => 'Voltooi je eerste quiz.';

  @override
  String get badgeKnowledgeSeeker => 'Kenniszoeker';

  @override
  String get badgeKnowledgeSeekerDesc => 'Speel 10 verschillende quizzen.';

  @override
  String get badgePerfect => 'Foutloos';

  @override
  String get badgePerfectDesc => 'Haal een 100% score op een quiz.';

  @override
  String get badgeOnARoll => 'Op Dreef';

  @override
  String get badgeOnARollDesc => 'Bouw een streak van 3 dagen op.';

  @override
  String get badgeDedicated => 'Toegewijd';

  @override
  String get badgeDedicatedDesc => 'Speel 7 dagen op rij.';

  @override
  String get badgeScholar => 'Geleerde';

  @override
  String get badgeMaster => 'Meester';

  @override
  String get badgeAllRounder => 'Allrounder';

  @override
  String get badgeAllRounderDesc => 'Speel een brede selectie quizzen.';

  @override
  String get rankSeeker => 'Zoeker';

  @override
  String get saveFailed => 'Opslaan is niet gelukt. Probeer het opnieuw.';

  @override
  String get saveFailedConnection =>
      'Opslaan is niet gelukt. Controleer je verbinding.';

  @override
  String get achievements => 'Prestaties';

  @override
  String get achievementsLoadFailed => 'Prestaties konden niet laden';

  @override
  String get noBadgesYet =>
      'Nog geen badges behaald. Speel quizzen om je eerste badge vrij te spelen.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'Nog te halen · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked van $total badges behaald';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked van $total badges';
  }

  @override
  String get allEarned => 'Alles behaald';

  @override
  String leftToEarn(Object left) {
    return 'Nog $left te halen';
  }

  @override
  String get profileUpdated => 'Profiel bijgewerkt.';

  @override
  String get editProfile => 'Profiel bewerken';

  @override
  String get profileLoadFailed => 'Profiel kon niet laden';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get surpriseMe => 'Verras me';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String get displayNameHint => 'Hoe je op de ranglijst verschijnt';

  @override
  String get displayNameHelp =>
      'Zichtbaar op de ranglijst en in multiplayer. Eens per 30 dagen te wijzigen.';

  @override
  String get buildMascot => 'Stel je mascotte samen';

  @override
  String get figure => 'Figuur';

  @override
  String get color => 'Kleur';

  @override
  String get background => 'Achtergrond';

  @override
  String get accessory => 'Accessoire';

  @override
  String get notSignedIn => 'Niet ingelogd';

  @override
  String get settings => 'Instellingen';

  @override
  String get statistics => 'Statistieken';

  @override
  String get recentlyPlayed => 'Recent gespeeld';

  @override
  String levelN(Object level) {
    return 'Level $level';
  }

  @override
  String get maxLevel => 'Hoogste level bereikt';

  @override
  String progressToLevel(Object level) {
    return 'Voortgang naar level $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return 'Nog $xpRemaining XP tot level $level';
  }

  @override
  String get daysInARow => 'Dagen op rij';

  @override
  String get quizzesPlayed => 'Quizzen gespeeld';

  @override
  String get averageScore => 'Gemiddelde score';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'Alle prestaties bekijken, $unlockedCount van $overviewCount behaald';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'Alle $unlockedCount van $overviewCount';
  }

  @override
  String get youHavePremium => 'Je hebt Premium';

  @override
  String get youPlayFree => 'Je speelt gratis';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score van $totalQuestions goed';
  }

  @override
  String get completed => 'Voltooid';

  @override
  String get guestPerkKeep => 'Punten, niveau en reeks die blijven staan';

  @override
  String get guestPerkLeaderboard => 'Een plek op de ranglijst';

  @override
  String get guestPerkBadges => 'Badges voor je prestaties';

  @override
  String get guestPerkWebsite => 'Dezelfde voortgang op bijbelquiz.com';

  @override
  String get saveYourProgress => 'Bewaar je voortgang';

  @override
  String get guestExplain =>
      'Je speelt zonder account. Dat kan gewoon, maar je score, punten en reeks blijven alleen bewaard met een gratis account.';

  @override
  String get createFreeAccount => 'Gratis account aanmaken';

  @override
  String get pendingOne => 'Eén quiz wacht op je account';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount quizzen wachten op je account';
  }

  @override
  String get withAccount => 'Met een account';

  @override
  String get oneQuiz => '1 quiz';

  @override
  String quizzesN(Object total) {
    return '$total quizzen';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played van $total gespeeld';
  }

  @override
  String get quizzesLoadFailed => 'Quizzen konden niet laden';

  @override
  String get byBibleBook => 'Per bijbelboek';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount boeken · $quizzes quizzen';
  }

  @override
  String get bibleBook => 'Bijbelboek';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount quizzen';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played van $quizzesCount gespeeld';
  }

  @override
  String get noQuizzesForBook => 'Over dit boek zijn nog geen quizzen.';

  @override
  String allQuizzesAbout(Object name) {
    return 'Alle quizzen over $name';
  }

  @override
  String get startWith => 'BEGIN MET';

  @override
  String get continueWith => 'GA VERDER MET';

  @override
  String get anyLevel => 'Elk niveau';

  @override
  String get easy => 'Makkelijk';

  @override
  String get medium => 'Gemiddeld';

  @override
  String get hard => 'Moeilijk';

  @override
  String get results => 'Resultaten';

  @override
  String get allQuizzes => 'Alle quizzen';

  @override
  String get popular => 'Populair';

  @override
  String get allBooks => 'Alle boeken';

  @override
  String get searchHint => 'Zoek een bijbelboek of onderwerp';

  @override
  String get clear => 'Wissen';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount vragen · $questionCount2 min';
  }

  @override
  String get notPlayedYet => 'Nog niet gespeeld';

  @override
  String get noQuizzesFilters =>
      'Geen quizzen gevonden met de huidige filters.';

  @override
  String get sortBibleOrder => 'Bijbelvolgorde';

  @override
  String get sortMostPopular => 'Meest populair';

  @override
  String get sortNewest => 'Nieuwste eerst';

  @override
  String get sortShortest => 'Kortste';

  @override
  String get sort => 'Sorteren';

  @override
  String get hideText => 'Verberg tekst';

  @override
  String hideTextOf(Object reference) {
    return 'Verberg de tekst van $reference';
  }

  @override
  String get unlockPremiumExplain => 'Ontgrendel Premium voor uitleg';

  @override
  String get readWhyWrong => 'Lees waarom dit fout was';

  @override
  String get timeUp => 'Tijd om';

  @override
  String get finishQuiz => 'Rond quiz af';

  @override
  String get a11yYourAnswerRight => ', jouw antwoord, goed';

  @override
  String get a11yCorrectAnswer => ', het goede antwoord';

  @override
  String get a11yYourAnswerWrong => ', jouw antwoord, fout';

  @override
  String questionOf(Object current, Object total) {
    return 'Vraag $current van $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return 'Nog $secondsLeft seconden';
  }

  @override
  String get wellPlayed => 'Mooi gespeeld';

  @override
  String get niceTry => 'Goed geprobeerd';

  @override
  String get nextQuiz => 'Volgende quiz';

  @override
  String get playWithOthers => 'Speel samen met anderen';

  @override
  String get viewAnswers => 'Bekijk antwoorden';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Score $correct van $total';
  }

  @override
  String get newBestScore => 'Nieuwe beste score';

  @override
  String get scoreNotSaved => 'Je score is nog niet opgeslagen';

  @override
  String get scoreSaving => 'Je score wordt opgeslagen';

  @override
  String get again => 'Opnieuw';

  @override
  String get noExtraXp => 'Geen extra XP deze keer';

  @override
  String get replayRule =>
      'Een herhaling telt alleen mee als je jezelf verbetert.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return 'Nog $xpToNextLevel XP tot level $level';
  }

  @override
  String get playTomorrowStreak => 'Speel morgen om je reeks te houden';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Bewaar je score, $previewXp XP en je reeks';
  }

  @override
  String get keepScoreBody =>
      'Log in of maak een gratis account, dan wordt deze score direct bijgeschreven. Je quizzen tellen dan mee voor je niveau en de ranglijst.';

  @override
  String get yourAnswers => 'Jouw antwoorden';

  @override
  String get allCorrectReview => 'Alles goed. Bekijk de uitleg bij elke vraag.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount van de $questionsCount vragen fout.';
  }

  @override
  String get fullExplainPremium =>
      'De volledige uitleg bij elke vraag is onderdeel van Premium.';

  @override
  String get unlockFullReview => 'Ontgrendel de volledige review';

  @override
  String get correct => 'Goed';

  @override
  String get wrong => 'Fout';

  @override
  String correctAnswerIs(Object text) {
    return 'Goed antwoord: $text';
  }

  @override
  String get quizLoadFailed => 'Quiz kon niet laden';

  @override
  String get howToPlay => 'Hoe wil je spelen?';

  @override
  String get rememberedNext =>
      'Wordt onthouden voor je volgende quizzen, ook op de website.';

  @override
  String get freeLeftPrefix => 'Nog ';

  @override
  String get freeLeftOne => ' gratis quiz';

  @override
  String get freeLeftMany => ' gratis quizzen';

  @override
  String get unlockWithPremium => 'Ontgrendel met Premium';

  @override
  String readAndStart(Object label) {
    return 'Lees $label en start';
  }

  @override
  String get startQuiz => 'Start quiz';

  @override
  String readFirstLabel(Object label) {
    return 'Lees eerst $label';
  }

  @override
  String get alreadyPlayed => 'Al gespeeld';

  @override
  String get playAgainBetter => 'Speel opnieuw voor een betere score';

  @override
  String get yourBestScore => 'Jouw beste score';

  @override
  String lastPlayed(Object last) {
    return 'Laatst gespeeld $last';
  }

  @override
  String get testKnowledge => 'Test je kennis over dit onderwerp.';

  @override
  String get aboutQuiz => 'Over deze quiz';

  @override
  String get finished => 'Afgerond';

  @override
  String get readChapterExplain =>
      'Je leest het hoofdstuk waar deze quiz over gaat voordat de vragen beginnen.';

  @override
  String get timePerQuestion => 'Tijd per vraag';

  @override
  String get timerExplain =>
      'Standaard uit. Zet een klok aan als je jezelf wilt uitdagen.';

  @override
  String get off => 'Uit';

  @override
  String get noChapterToRead => 'Geen hoofdstuk om te lezen';

  @override
  String get multiChapter =>
      'Deze quiz gaat over meer dan een hoofdstuk. Je kunt gewoon met de quiz beginnen.';

  @override
  String get chapterFetchFailed =>
      'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.';

  @override
  String get readFirst => 'Lees eerst';

  @override
  String readBeforeQuiz(Object title) {
    return 'Lees voor de quiz $title';
  }

  @override
  String get bibleVersionName => 'Statenvertaling';

  @override
  String get keepStreakQuestion => 'Je reeks vasthouden?';

  @override
  String keepStreakBody(Object streak) {
    return 'Je hebt $streak dagen op rij gespeeld. Zullen we je om 19:00 een seintje geven op een dag dat je nog niet gespeeld hebt?';
  }

  @override
  String get noQuestionsYet => 'Nog geen vragen';

  @override
  String get quizNoQuestions => 'Deze quiz heeft nog geen vragen.';

  @override
  String get goBack => 'Ga terug';

  @override
  String get today => 'vandaag';

  @override
  String get yesterday => 'gisteren';

  @override
  String daysAgo(Object days) {
    return '$days dagen geleden';
  }

  @override
  String onDate(Object date) {
    return 'op $date';
  }

  @override
  String get mpQuotaFailed => 'Kon je speelruimte niet ophalen.';

  @override
  String get mpCreateFailed => 'Kon geen kamer maken.';

  @override
  String mpJoinFailed(Object code) {
    return 'Kon niet deelnemen aan kamer $code.';
  }

  @override
  String mpLoadFailed(Object code) {
    return 'Kon kamer $code niet laden.';
  }

  @override
  String get mpStartFailed => 'Kon de quiz niet starten.';

  @override
  String get mpNextFailed => 'Kon niet doorgaan naar de volgende vraag.';

  @override
  String get mpAnswerFailed => 'Kon antwoord niet insturen.';

  @override
  String get mpResultsFailed => 'Kon resultaten niet laden.';

  @override
  String get unexpectedServerResponse => 'Onverwacht antwoord van de server.';

  @override
  String get roomNotFoundDot => 'Kamer niet gevonden.';

  @override
  String get playTogether => 'Samen spelen';

  @override
  String get backToPlayTogether => 'Terug naar Samen spelen';

  @override
  String get stopQuiz => 'Quiz stoppen';

  @override
  String get leaveGame => 'Spel verlaten';

  @override
  String get multiplayerQuiz => 'Multiplayer quiz';

  @override
  String roomCodeLabel(Object code) {
    return 'Kamer $code';
  }

  @override
  String get waitingNextQuestion => 'Wachten op de volgende vraag…';

  @override
  String get nextIn => 'Volgende in ';

  @override
  String correctOfPlayers(Object correctCount, Object playersCount) {
    return '$correctCount van $playersCount had het goed';
  }

  @override
  String get standings => 'Stand';

  @override
  String get stopQuizQuestion => 'Quiz stoppen?';

  @override
  String get stopQuizBody =>
      'Wil je deze multiplayer-quiz stoppen voor alle spelers?';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get stopQuizAction => 'Stop quiz';

  @override
  String get leaveGameQuestion => 'Spel verlaten?';

  @override
  String get leaveGameBody =>
      'Je score blijft bewaard als je terugkomt via Samen spelen.';

  @override
  String get stay => 'Blijf';

  @override
  String get leaveGameAction => 'Verlaat spel';

  @override
  String questionNumberOf(Object number, Object total) {
    return 'Vraag $number van $total';
  }

  @override
  String secondsRemaining(Object seconds) {
    return 'Nog $seconds seconden';
  }

  @override
  String nextQuestionIn(Object seconds) {
    return 'Volgende vraag in $seconds seconden';
  }

  @override
  String get a11yYourAnswer => ', jouw antwoord';

  @override
  String get a11yRightAnswer => ', goed antwoord';

  @override
  String get a11yWrongShort => ', fout';

  @override
  String a11yChosenTimes(Object count) {
    return ', $count keer gekozen';
  }

  @override
  String get noAnswerLower => 'geen antwoord';

  @override
  String get stillThinking => 'denkt nog na';

  @override
  String get noAnswer => 'Geen antwoord';

  @override
  String get rightExclaim => 'Goed!';

  @override
  String get tooBad => 'Helaas';

  @override
  String get correctMarkedGreen => 'Het juiste antwoord is groen gemarkeerd.';

  @override
  String get yourAnswerCorrect => 'Je antwoord is correct.';

  @override
  String get yourChoiceMarked =>
      'Jouw keuze staat gemarkeerd naast het juiste antwoord.';

  @override
  String pointsGained(Object gained) {
    return '+$gained punten';
  }

  @override
  String get nextQuestion => 'Volgende vraag';

  @override
  String get hostMovingOn => 'De host gaat zo door naar de volgende vraag.';

  @override
  String get submitted => 'Ingestuurd';

  @override
  String get waitingOtherPlayers => 'Wachten op de andere spelers…';

  @override
  String get hostSetsPace =>
      'Jij bepaalt het tempo. Toon de antwoorden zodra iedereen klaar is.';

  @override
  String get showAnswers => 'Toon antwoorden';

  @override
  String get startQuestions => 'Start de vragen';

  @override
  String get waitHostQuestions => 'Wacht tot de host de vragen start.';

  @override
  String get waitingHostQuestions => 'Wachten tot de host de vragen start…';

  @override
  String readBeforeQuizMp(Object quizTitle) {
    return 'Lees voor de quiz $quizTitle';
  }

  @override
  String get readChapterCalmly =>
      'Neem dit hoofdstuk rustig door. De vragen hierna gaan hierover, dus lezen helpt echt.';

  @override
  String get chapterNotLoaded => 'Hoofdstuk niet geladen';

  @override
  String get chapterFetchFailedHost =>
      'Dit hoofdstuk kon nu niet opgehaald worden. De host kan gewoon met de vragen beginnen.';

  @override
  String get lobby => 'Wachtkamer';

  @override
  String get closeRoom => 'Kamer sluiten';

  @override
  String get leaveRoom => 'Kamer verlaten';

  @override
  String get closeRoomQuestion => 'Kamer sluiten?';

  @override
  String get leaveRoomQuestion => 'Kamer verlaten?';

  @override
  String get closeRoomBody =>
      'Ben je de enige, dan sluit de kamer. Zijn er al spelers, dan wordt iemand anders host.';

  @override
  String get rejoinLater => 'Je kunt later opnieuw meedoen met dezelfde code.';

  @override
  String get closeRoomAction => 'Sluit kamer';

  @override
  String get leaveRoomAction => 'Verlaat kamer';

  @override
  String get freeGamesUsed => 'Je gratis spellen zijn op';

  @override
  String get premiumHostUnlimited =>
      'Met Premium host je onbeperkt spellen, met tot 20 spelers tegelijk. Je groep blijft gewoon in de kamer wachten.';

  @override
  String get newRoomCode => 'Je krijgt een nieuwe kamercode.';

  @override
  String get startWhenEveryone => 'Start de quiz zodra iedereen er is.';

  @override
  String get hostStartsWhenEveryone =>
      'De host start de quiz zodra iedereen er is.';

  @override
  String get roomCodeCopied => 'Kamercode gekopieerd.';

  @override
  String get change => 'Wijzig';

  @override
  String get players => 'Spelers';

  @override
  String playersOfMax(Object playersCount, Object maxPlayers) {
    return '$playersCount van $maxPlayers';
  }

  @override
  String get startTheQuiz => 'Start de quiz';

  @override
  String get oneQuestion => '1 vraag';

  @override
  String totalQuestionsN(Object totalQuestions) {
    return '$totalQuestions vragen';
  }

  @override
  String secondsPerQuestion(Object questionTimerSeconds) {
    return '${questionTimerSeconds}s per vraag';
  }

  @override
  String get hostSetsPaceShort => 'Host bepaalt het tempo';

  @override
  String get readFirstShort => 'Eerst lezen';

  @override
  String get joinMyQuizShareTitle => 'Doe mee met mijn BijbelQuiz';

  @override
  String get playersEnterCode => 'Spelers vullen deze code in bij Samen spelen';

  @override
  String get shareCode => 'Deel code';

  @override
  String get copyCode => 'Code kopiëren';

  @override
  String get newPlayersAppear => 'Nieuwe spelers verschijnen hier vanzelf.';

  @override
  String get waitHostQuiz => 'Wacht tot de host de quiz start.';

  @override
  String get quizCompleted => 'Quiz voltooid';

  @override
  String get finalStandings => 'Eindstand';

  @override
  String winnerWith(Object winner, Object score) {
    return 'Winnaar: $winner met $score punten';
  }

  @override
  String get backHome => 'Terug naar home';

  @override
  String get startNewRoom => 'Nieuwe kamer starten';

  @override
  String groupSaved(Object savedGroupName) {
    return '\"$savedGroupName\" is bewaard.';
  }

  @override
  String get groupStandingsOnLeaderboard =>
      'Je vindt de stand van deze groep op de ranglijst.';

  @override
  String get saveGroupQuestion => 'Deze groep bewaren?';

  @override
  String saveGroupBody(Object playersCount) {
    return 'Dan houd je een eigen ranglijst bij met deze $playersCount spelers, en nodig je ze de volgende keer met een tik weer uit.';
  }

  @override
  String get saveGroup => 'Groep bewaren';

  @override
  String placeNamePoints(Object place, Object name, Object score) {
    return '$place. $name, $score punten';
  }

  @override
  String pointsN(Object score) {
    return '$score punten';
  }

  @override
  String correctOfTotal(Object correctAnswers, Object totalQuestions) {
    return '$correctAnswers van $totalQuestions goed';
  }

  @override
  String correctN(Object correctAnswers) {
    return '$correctAnswers goed';
  }

  @override
  String get roomReconnecting =>
      'Kamer even niet bereikbaar. Opnieuw verbinden...';

  @override
  String get roomClosedFinal => 'De kamer is gesloten. Dit is de eindstand.';

  @override
  String get roomGone =>
      'Deze kamer bestaat niet meer. Ga terug en start een nieuwe kamer.';

  @override
  String get createRoom => 'Kamer maken';

  @override
  String get createRoomInvite => 'Maak kamer en nodig uit';

  @override
  String thenInviteGroup(Object name) {
    return 'Daarna nodigen we $name uit.';
  }

  @override
  String get selectQuizFirst => 'Selecteer eerst een quiz.';

  @override
  String get enterRoomCode => 'Voer een kamercode in.';

  @override
  String get roomCodeTooShort => 'Kamercode lijkt te kort. Controleer de code.';

  @override
  String pickQuizThenInvite(Object name) {
    return 'Kies eerst een quiz, dan nodigen we $name uit.';
  }

  @override
  String get yourGroupsShort => 'Je groepen';

  @override
  String get pickQuizInviteGroup =>
      'Kies een quiz en stuur je groep in een tik een nieuwe uitnodiging.';

  @override
  String get signInToPlayTogether => 'Log in om samen te spelen';

  @override
  String get playTogetherNeedsAccount =>
      'Een kamer maken of meedoen kan met een gratis account, zodat je naam en score in de kamer kloppen.';

  @override
  String get playTogetherIntro =>
      'Met je gezin, vrienden of de jeugdclub: iedereen speelt tegelijk dezelfde quiz, ieder op een eigen telefoon.';

  @override
  String upToPlayers(Object maxPlayers) {
    return 'Tot $maxPlayers spelers per kamer';
  }

  @override
  String get youAreHost => 'Jij bent de host';

  @override
  String premiumHostRooms(Object maxPlayersPremium) {
    return 'Met Premium host je onbeperkt kamers, tot $maxPlayersPremium spelers tegelijk. Deelnemen met een kamercode blijft altijd gratis.';
  }

  @override
  String get viewPremium => 'Bekijk Premium';

  @override
  String get hostSteps =>
      'Kies een quiz, deel de code met je groep en start als iedereen er is.';

  @override
  String get pickQuiz => 'Kies een quiz';

  @override
  String get gameThisMonth => 'Je spel van deze maand';

  @override
  String get lastFreeGame => 'Laatste gratis spel';

  @override
  String freeGamesLeftN(Object remaining) {
    return 'Nog $remaining gratis spellen';
  }

  @override
  String get freeGameMonthly =>
      'Dit is je gratis spel voor deze maand. Volgende maand krijg je er weer een. Met Premium host je meteen zoveel je wilt.';

  @override
  String get lastFreeGameBody =>
      'Dit is je laatste gratis spel om te hosten. Daarna krijg je er elke maand een terug. Meedoen met andermans spel blijft gratis.';

  @override
  String freeGamesLeftBody(Object remaining) {
    return 'Je hebt nog $remaining gratis spellen om te hosten. Een spel telt pas mee zodra je hem echt start.';
  }

  @override
  String get joinWithCode => 'Meedoen met code';

  @override
  String get hostShares6 => 'De host deelt een code van 6 tekens';

  @override
  String get join => 'Meedoen';

  @override
  String roomCodeA11y(Object length) {
    return 'Kamercode, $length tekens';
  }

  @override
  String get lobbyStillOpen => 'Je wachtkamer staat nog open';

  @override
  String get lastGameOver => 'Je laatste spel is afgelopen';

  @override
  String get gameStillRunning => 'Je spel loopt nog';

  @override
  String resumeA11y(Object label, Object quizTitle, Object code) {
    return '$label. $quizTitle, kamer $code. Ga verder';
  }

  @override
  String quizRoom(Object quizTitle, Object code) {
    return '$quizTitle - kamer $code';
  }

  @override
  String get invite => 'Uitnodigen';

  @override
  String get pickOtherQuiz => 'Andere quiz kiezen';

  @override
  String get setUpRoom => 'Kamer instellen';

  @override
  String get noQuizzesForRoom =>
      'Geen quizzen gevonden om een kamer te starten.';

  @override
  String get cantLoadQuizzes => 'Kan quizzen niet laden';

  @override
  String get numberOfPlayers => 'Aantal spelers';

  @override
  String maxN(Object maxPlayers) {
    return 'Max. $maxPlayers';
  }

  @override
  String countPlayersPremium(Object count) {
    return '$count spelers, Premium';
  }

  @override
  String hostCanInvite(Object maxPlayersPremium) {
    return 'Jij bent de host en kunt tot $maxPlayersPremium spelers uitnodigen.';
  }

  @override
  String freeUpToPlayers(Object maxPlayersFree) {
    return 'Gratis tot $maxPlayersFree spelers. Een gratis spel telt pas mee als je het spel echt start.';
  }

  @override
  String maxPlayersNeedsPremium(Object maxPlayers, Object maxPlayersFree) {
    return '$maxPlayers spelers vraagt om Premium. Gratis speel je tot $maxPlayersFree spelers.';
  }

  @override
  String freeGamesLeftHost(Object freeGamesLeft) {
    return 'Je hebt nog $freeGamesLeft gratis spellen om te hosten.';
  }

  @override
  String get readChapterFirst => 'Lees eerst het hoofdstuk';

  @override
  String get onlySingleChapter => 'Werkt alleen bij quizzen over 1 hoofdstuk.';

  @override
  String get pacePerQuestion => 'Tempo per vraag';

  @override
  String get youAdvance =>
      'Jij gaat zelf door naar de antwoorden en de volgende vraag.';

  @override
  String everyoneGetsSeconds(Object tempo) {
    return 'Iedereen krijgt $tempo seconden per vraag.';
  }

  @override
  String get hostDecides => 'Host bepaalt';

  @override
  String secondsPerQuestionLong(Object i) {
    return '$i seconden per vraag';
  }
}
