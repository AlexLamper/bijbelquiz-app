import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('nl'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In nl, this message translates to:
  /// **'Bijbelquiz'**
  String get appName;

  /// No description provided for @inviteFallbackTitle.
  ///
  /// In nl, this message translates to:
  /// **'een bijbelquiz'**
  String get inviteFallbackTitle;

  /// No description provided for @inviteJoin.
  ///
  /// In nl, this message translates to:
  /// **'Doe je mee met {title} op {brand}?'**
  String inviteJoin(String title, String brand);

  /// No description provided for @inviteCode.
  ///
  /// In nl, this message translates to:
  /// **'Of vul de code in: {code}'**
  String inviteCode(String code);

  /// No description provided for @errGenericTitle.
  ///
  /// In nl, this message translates to:
  /// **'Er ging iets mis'**
  String get errGenericTitle;

  /// No description provided for @errGenericMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden dit niet afronden. Probeer het zo nog een keer.'**
  String get errGenericMessage;

  /// No description provided for @errNetworkTitle.
  ///
  /// In nl, this message translates to:
  /// **'Geen verbinding'**
  String get errNetworkTitle;

  /// No description provided for @errNetworkMessage.
  ///
  /// In nl, this message translates to:
  /// **'Controleer je internetverbinding en probeer het opnieuw.'**
  String get errNetworkMessage;

  /// No description provided for @errSignedOutTitle.
  ///
  /// In nl, this message translates to:
  /// **'Opnieuw inloggen'**
  String get errSignedOutTitle;

  /// No description provided for @errSignedOutMessage.
  ///
  /// In nl, this message translates to:
  /// **'Je sessie is verlopen. Log opnieuw in om verder te spelen.'**
  String get errSignedOutMessage;

  /// No description provided for @errRoomNotFoundTitle.
  ///
  /// In nl, this message translates to:
  /// **'Kamer niet gevonden'**
  String get errRoomNotFoundTitle;

  /// No description provided for @errRoomNotFoundMessage.
  ///
  /// In nl, this message translates to:
  /// **'Deze kamer bestaat niet meer of is gesloten. Controleer de code, of start zelf een nieuwe kamer.'**
  String get errRoomNotFoundMessage;

  /// No description provided for @errRoomFullTitle.
  ///
  /// In nl, this message translates to:
  /// **'Kamer is vol'**
  String get errRoomFullTitle;

  /// No description provided for @errRoomFullMessage.
  ///
  /// In nl, this message translates to:
  /// **'Er passen geen spelers meer bij in deze kamer. Vraag de host om een nieuwe kamer te openen.'**
  String get errRoomFullMessage;

  /// No description provided for @errRoomStartedTitle.
  ///
  /// In nl, this message translates to:
  /// **'Spel is al begonnen'**
  String get errRoomStartedTitle;

  /// No description provided for @errRoomStartedMessage.
  ///
  /// In nl, this message translates to:
  /// **'Deze quiz loopt al. Wacht tot de ronde klaar is of start een nieuwe kamer.'**
  String get errRoomStartedMessage;

  /// No description provided for @errRoomFinishedTitle.
  ///
  /// In nl, this message translates to:
  /// **'Spel is afgelopen'**
  String get errRoomFinishedTitle;

  /// No description provided for @errRoomFinishedMessage.
  ///
  /// In nl, this message translates to:
  /// **'Deze kamer is gesloten. Start een nieuwe kamer om verder te spelen.'**
  String get errRoomFinishedMessage;

  /// No description provided for @errRoomCodeTitle.
  ///
  /// In nl, this message translates to:
  /// **'Ongeldige kamercode'**
  String get errRoomCodeTitle;

  /// No description provided for @errRoomCodeMessage.
  ///
  /// In nl, this message translates to:
  /// **'Deze code klopt niet. Een kamercode bestaat uit 6 tekens.'**
  String get errRoomCodeMessage;

  /// No description provided for @errAlreadyInRoomTitle.
  ///
  /// In nl, this message translates to:
  /// **'Je zit al in deze kamer'**
  String get errAlreadyInRoomTitle;

  /// No description provided for @errAlreadyInRoomMessage.
  ///
  /// In nl, this message translates to:
  /// **'Ga terug naar de kamer om verder te spelen.'**
  String get errAlreadyInRoomMessage;

  /// No description provided for @errPremiumTitle.
  ///
  /// In nl, this message translates to:
  /// **'Premium vereist'**
  String get errPremiumTitle;

  /// No description provided for @errPremiumMessage.
  ///
  /// In nl, this message translates to:
  /// **'Zelf een kamer hosten hoort bij Bijbelquiz Premium. Meespelen kan altijd gratis.'**
  String get errPremiumMessage;

  /// No description provided for @errForbiddenTitle.
  ///
  /// In nl, this message translates to:
  /// **'Geen toegang'**
  String get errForbiddenTitle;

  /// No description provided for @errForbiddenMessage.
  ///
  /// In nl, this message translates to:
  /// **'Alleen de host kan dit doen.'**
  String get errForbiddenMessage;

  /// No description provided for @errRateLimitedTitle.
  ///
  /// In nl, this message translates to:
  /// **'Even wachten'**
  String get errRateLimitedTitle;

  /// No description provided for @errRateLimitedMessage.
  ///
  /// In nl, this message translates to:
  /// **'Je probeerde het te vaak achter elkaar. Wacht een moment en probeer het opnieuw.'**
  String get errRateLimitedMessage;

  /// No description provided for @errNotFoundTitle.
  ///
  /// In nl, this message translates to:
  /// **'Niet gevonden'**
  String get errNotFoundTitle;

  /// No description provided for @errNotFoundMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden dit niet vinden. Ga terug en probeer het opnieuw.'**
  String get errNotFoundMessage;

  /// No description provided for @errConflictTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dat kan nu niet'**
  String get errConflictTitle;

  /// No description provided for @errConflictMessage.
  ///
  /// In nl, this message translates to:
  /// **'Deze actie past niet bij de huidige stand van het spel. Ververs en probeer het opnieuw.'**
  String get errConflictMessage;

  /// No description provided for @errServerTitle.
  ///
  /// In nl, this message translates to:
  /// **'Server reageert niet'**
  String get errServerTitle;

  /// No description provided for @errServerMessage.
  ///
  /// In nl, this message translates to:
  /// **'Er ging iets mis aan onze kant. Probeer het over een paar seconden nog eens.'**
  String get errServerMessage;

  /// No description provided for @errLiveLostTitle.
  ///
  /// In nl, this message translates to:
  /// **'Live verbinding weg'**
  String get errLiveLostTitle;

  /// No description provided for @errLiveLostMessage.
  ///
  /// In nl, this message translates to:
  /// **'De live verbinding viel weg. We halen de stand nu automatisch op.'**
  String get errLiveLostMessage;

  /// No description provided for @errLoginTitle.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen mislukt'**
  String get errLoginTitle;

  /// No description provided for @errLoginBadCredentials.
  ///
  /// In nl, this message translates to:
  /// **'Dit e-mailadres of wachtwoord klopt niet.'**
  String get errLoginBadCredentials;

  /// No description provided for @errAccountExistsTitle.
  ///
  /// In nl, this message translates to:
  /// **'Account bestaat al'**
  String get errAccountExistsTitle;

  /// No description provided for @errAccountExistsMessage.
  ///
  /// In nl, this message translates to:
  /// **'Er bestaat al een account met dit e-mailadres. Log in.'**
  String get errAccountExistsMessage;

  /// No description provided for @errRegisterTitle.
  ///
  /// In nl, this message translates to:
  /// **'Registreren mislukt'**
  String get errRegisterTitle;

  /// No description provided for @errRegisterMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden je account niet aanmaken. Probeer het opnieuw.'**
  String get errRegisterMessage;

  /// No description provided for @errLoginMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden je niet inloggen. Probeer het opnieuw.'**
  String get errLoginMessage;

  /// No description provided for @errLeaderboardTitle.
  ///
  /// In nl, this message translates to:
  /// **'Ranglijst niet geladen'**
  String get errLeaderboardTitle;

  /// No description provided for @errLeaderboardMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden de ranglijst niet ophalen. Probeer het opnieuw.'**
  String get errLeaderboardMessage;

  /// No description provided for @errQuizzesTitle.
  ///
  /// In nl, this message translates to:
  /// **'Quizzen niet geladen'**
  String get errQuizzesTitle;

  /// No description provided for @errQuizzesMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden de quizzen niet ophalen. Probeer het opnieuw.'**
  String get errQuizzesMessage;

  /// No description provided for @errProfileTitle.
  ///
  /// In nl, this message translates to:
  /// **'Profiel niet geladen'**
  String get errProfileTitle;

  /// No description provided for @errProfileMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden je profiel niet ophalen. Probeer het opnieuw.'**
  String get errProfileMessage;

  /// No description provided for @errPurchaseTitle.
  ///
  /// In nl, this message translates to:
  /// **'Aankoop mislukt'**
  String get errPurchaseTitle;

  /// No description provided for @errPurchaseMessage.
  ///
  /// In nl, this message translates to:
  /// **'De aankoop is niet afgerond. Er is niets in rekening gebracht.'**
  String get errPurchaseMessage;

  /// No description provided for @streakReminderTitle.
  ///
  /// In nl, this message translates to:
  /// **'Je reeks staat op het spel'**
  String get streakReminderTitle;

  /// No description provided for @streakReminderChannel.
  ///
  /// In nl, this message translates to:
  /// **'Reeksherinnering'**
  String get streakReminderChannel;

  /// No description provided for @streakReminderChannelDescription.
  ///
  /// In nl, this message translates to:
  /// **'Een herinnering op de avond dat je reeks dreigt te verlopen.'**
  String get streakReminderChannelDescription;

  /// No description provided for @streakReminderBody.
  ///
  /// In nl, this message translates to:
  /// **'Je reeks van {streak} dagen loopt vanavond af. Eén quiz is genoeg om hem te houden.'**
  String streakReminderBody(Object streak);

  /// No description provided for @navQuizzes.
  ///
  /// In nl, this message translates to:
  /// **'Quizzen'**
  String get navQuizzes;

  /// No description provided for @navTogether.
  ///
  /// In nl, this message translates to:
  /// **'Samen'**
  String get navTogether;

  /// No description provided for @navLeaderboard.
  ///
  /// In nl, this message translates to:
  /// **'Ranglijst'**
  String get navLeaderboard;

  /// No description provided for @navProfile.
  ///
  /// In nl, this message translates to:
  /// **'Profiel'**
  String get navProfile;

  /// No description provided for @savedQuizFallback.
  ///
  /// In nl, this message translates to:
  /// **'je quiz'**
  String get savedQuizFallback;

  /// No description provided for @savedScoreOne.
  ///
  /// In nl, this message translates to:
  /// **'Je score voor \"{title}\" is opgeslagen (+{xpEarned} XP).'**
  String savedScoreOne(Object title, Object xpEarned);

  /// No description provided for @savedScoreMany.
  ///
  /// In nl, this message translates to:
  /// **'{saved} quizzen opgeslagen (+{xpEarned} XP).'**
  String savedScoreMany(Object saved, Object xpEarned);

  /// No description provided for @progressSaved.
  ///
  /// In nl, this message translates to:
  /// **'Voortgang bewaard'**
  String get progressSaved;

  /// No description provided for @navHome.
  ///
  /// In nl, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @avatarLamb.
  ///
  /// In nl, this message translates to:
  /// **'Lam'**
  String get avatarLamb;

  /// No description provided for @avatarLion.
  ///
  /// In nl, this message translates to:
  /// **'Leeuw'**
  String get avatarLion;

  /// No description provided for @avatarDove.
  ///
  /// In nl, this message translates to:
  /// **'Duif'**
  String get avatarDove;

  /// No description provided for @avatarOwl.
  ///
  /// In nl, this message translates to:
  /// **'Uil'**
  String get avatarOwl;

  /// No description provided for @avatarDeer.
  ///
  /// In nl, this message translates to:
  /// **'Hert'**
  String get avatarDeer;

  /// No description provided for @avatarOx.
  ///
  /// In nl, this message translates to:
  /// **'Os'**
  String get avatarOx;

  /// No description provided for @avatarSand.
  ///
  /// In nl, this message translates to:
  /// **'Zand'**
  String get avatarSand;

  /// No description provided for @avatarLapis.
  ///
  /// In nl, this message translates to:
  /// **'Lapis'**
  String get avatarLapis;

  /// No description provided for @avatarClay.
  ///
  /// In nl, this message translates to:
  /// **'Klei'**
  String get avatarClay;

  /// No description provided for @avatarOlive.
  ///
  /// In nl, this message translates to:
  /// **'Olijf'**
  String get avatarOlive;

  /// No description provided for @avatarRose.
  ///
  /// In nl, this message translates to:
  /// **'Roos'**
  String get avatarRose;

  /// No description provided for @avatarSlate.
  ///
  /// In nl, this message translates to:
  /// **'Leisteen'**
  String get avatarSlate;

  /// No description provided for @avatarParchment.
  ///
  /// In nl, this message translates to:
  /// **'Perkament'**
  String get avatarParchment;

  /// No description provided for @avatarSky.
  ///
  /// In nl, this message translates to:
  /// **'Hemel'**
  String get avatarSky;

  /// No description provided for @avatarSage.
  ///
  /// In nl, this message translates to:
  /// **'Salie'**
  String get avatarSage;

  /// No description provided for @avatarSunrise.
  ///
  /// In nl, this message translates to:
  /// **'Zonsopgang'**
  String get avatarSunrise;

  /// No description provided for @avatarNight.
  ///
  /// In nl, this message translates to:
  /// **'Nacht'**
  String get avatarNight;

  /// No description provided for @avatarBlush.
  ///
  /// In nl, this message translates to:
  /// **'Blos'**
  String get avatarBlush;

  /// No description provided for @avatarNone.
  ///
  /// In nl, this message translates to:
  /// **'Geen'**
  String get avatarNone;

  /// No description provided for @avatarGlasses.
  ///
  /// In nl, this message translates to:
  /// **'Bril'**
  String get avatarGlasses;

  /// No description provided for @avatarCap.
  ///
  /// In nl, this message translates to:
  /// **'Pet'**
  String get avatarCap;

  /// No description provided for @avatarScarf.
  ///
  /// In nl, this message translates to:
  /// **'Sjaal'**
  String get avatarScarf;

  /// No description provided for @avatarCrown.
  ///
  /// In nl, this message translates to:
  /// **'Kroon'**
  String get avatarCrown;

  /// No description provided for @avatarWith.
  ///
  /// In nl, this message translates to:
  /// **'{character} met {accessory}'**
  String avatarWith(Object character, Object accessory);

  /// No description provided for @wordmarkFirst.
  ///
  /// In nl, this message translates to:
  /// **'Bijbel'**
  String get wordmarkFirst;

  /// No description provided for @wordmarkSecond.
  ///
  /// In nl, this message translates to:
  /// **'Quiz'**
  String get wordmarkSecond;

  /// No description provided for @actionClose.
  ///
  /// In nl, this message translates to:
  /// **'Sluiten'**
  String get actionClose;

  /// No description provided for @actionBack.
  ///
  /// In nl, this message translates to:
  /// **'Terug'**
  String get actionBack;

  /// No description provided for @questionsCount.
  ///
  /// In nl, this message translates to:
  /// **'{questionCount} vragen'**
  String questionsCount(Object questionCount);

  /// No description provided for @actionStart.
  ///
  /// In nl, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @authGoogleAndroidInterrupted.
  ///
  /// In nl, this message translates to:
  /// **'Google-login onderbroken op Android. Controleer SHA-1/SHA-256 van de release key in Google Cloud OAuth client.'**
  String get authGoogleAndroidInterrupted;

  /// No description provided for @authGoogleNoToken.
  ///
  /// In nl, this message translates to:
  /// **'Google gaf geen idToken terug. Probeer opnieuw of kies een ander account.'**
  String get authGoogleNoToken;

  /// No description provided for @authAppleUnavailable.
  ///
  /// In nl, this message translates to:
  /// **'Apple-login is niet beschikbaar op dit apparaat. Voeg web fallback toe met APPLE_SERVICE_ID en APPLE_REDIRECT_URI of controleer je Apple ID/provisioning.'**
  String get authAppleUnavailable;

  /// No description provided for @authAppleError1000.
  ///
  /// In nl, this message translates to:
  /// **'Apple-login kon niet worden gestart (AuthorizationError 1000). Dit is meestal een iOS-device/provisioning probleem: gebruik een echte iPhone (of iOS-simulator met Apple ID), vernieuw signing/provisioning in Xcode voor bundle ID com.bijbelquiz.app en installeer de app opnieuw.'**
  String get authAppleError1000;

  /// No description provided for @authAppleWebNotConfigured.
  ///
  /// In nl, this message translates to:
  /// **'Apple web-fallback is niet geconfigureerd. Stel APPLE_SERVICE_ID en APPLE_REDIRECT_URI in.'**
  String get authAppleWebNotConfigured;

  /// No description provided for @authWelcomeBack.
  ///
  /// In nl, this message translates to:
  /// **'Welkom terug'**
  String get authWelcomeBack;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Log in om je voortgang bij te houden en mee te doen op de ranglijst.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailHint.
  ///
  /// In nl, this message translates to:
  /// **'naam@voorbeeld.nl'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In nl, this message translates to:
  /// **'Je wachtwoord'**
  String get authPasswordHint;

  /// No description provided for @authSignIn.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen account?'**
  String get authNoAccount;

  /// No description provided for @authRegister.
  ///
  /// In nl, this message translates to:
  /// **'Registreren'**
  String get authRegister;

  /// No description provided for @authCreateAccount.
  ///
  /// In nl, this message translates to:
  /// **'Account aanmaken'**
  String get authCreateAccount;

  /// No description provided for @authCreateSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Gratis, en je voortgang blijft bewaard.'**
  String get authCreateSubtitle;

  /// No description provided for @authName.
  ///
  /// In nl, this message translates to:
  /// **'Naam'**
  String get authName;

  /// No description provided for @authNameHelp.
  ///
  /// In nl, this message translates to:
  /// **'Zo zien anderen je op de ranglijst en als je samen speelt.'**
  String get authNameHelp;

  /// No description provided for @authTermsPrefixRegister.
  ///
  /// In nl, this message translates to:
  /// **'Door een account te maken ga je akkoord met de '**
  String get authTermsPrefixRegister;

  /// No description provided for @authHaveAccount.
  ///
  /// In nl, this message translates to:
  /// **'Heb je al een account?'**
  String get authHaveAccount;

  /// No description provided for @splashTagline.
  ///
  /// In nl, this message translates to:
  /// **'Hoe goed ken jij de Bijbel?'**
  String get splashTagline;

  /// No description provided for @authOrEmail.
  ///
  /// In nl, this message translates to:
  /// **'of met e-mail'**
  String get authOrEmail;

  /// No description provided for @authTermsPrefix.
  ///
  /// In nl, this message translates to:
  /// **'Door verder te gaan ga je akkoord met de '**
  String get authTermsPrefix;

  /// No description provided for @errLinkTitle.
  ///
  /// In nl, this message translates to:
  /// **'Link niet geopend'**
  String get errLinkTitle;

  /// No description provided for @errLinkMessage.
  ///
  /// In nl, this message translates to:
  /// **'We konden deze pagina niet openen. Probeer het opnieuw.'**
  String get errLinkMessage;

  /// No description provided for @authTermsAnd.
  ///
  /// In nl, this message translates to:
  /// **' en het '**
  String get authTermsAnd;

  /// No description provided for @authShowPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord tonen'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord verbergen'**
  String get authHidePassword;

  /// No description provided for @authContinueGoogle.
  ///
  /// In nl, this message translates to:
  /// **'Doorgaan met Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueApple.
  ///
  /// In nl, this message translates to:
  /// **'Doorgaan met Apple'**
  String get authContinueApple;

  /// No description provided for @dataInfoTitle.
  ///
  /// In nl, this message translates to:
  /// **'Hoe we met je gegevens omgaan'**
  String get dataInfoTitle;

  /// No description provided for @dataInfoBody.
  ///
  /// In nl, this message translates to:
  /// **'Bij het inloggen of registreren gebruiken we alleen gegevens die nodig zijn om je account te laten werken, zoals je naam, e-mailadres en inloggegevens.\n\nJe gegevens worden via beveiligde verbindingen verzonden en we delen ze niet voor advertenties zonder jouw toestemming.\n\nJe kunt altijd je account laten verwijderen. Neem hiervoor contact op via info@bijbelquiz.com of via de supportkanalen in de app. Na verwijdering worden je accountgegevens verwijderd volgens ons privacybeleid.'**
  String get dataInfoBody;

  /// No description provided for @dataInfoMore.
  ///
  /// In nl, this message translates to:
  /// **'Meer over gegevensgebruik'**
  String get dataInfoMore;

  /// No description provided for @homeContinue.
  ///
  /// In nl, this message translates to:
  /// **'Verder spelen'**
  String get homeContinue;

  /// No description provided for @homeAll.
  ///
  /// In nl, this message translates to:
  /// **'Alles'**
  String get homeAll;

  /// No description provided for @homePickTopic.
  ///
  /// In nl, this message translates to:
  /// **'Kies een onderwerp'**
  String get homePickTopic;

  /// No description provided for @homePopular.
  ///
  /// In nl, this message translates to:
  /// **'Populaire quizzen'**
  String get homePopular;

  /// No description provided for @streakOneDay.
  ///
  /// In nl, this message translates to:
  /// **'Reeks van 1 dag'**
  String get streakOneDay;

  /// No description provided for @streakDays.
  ///
  /// In nl, this message translates to:
  /// **'Reeks van {streak} dagen'**
  String streakDays(Object streak);

  /// No description provided for @questionsCountShort.
  ///
  /// In nl, this message translates to:
  /// **'{count} vragen'**
  String questionsCountShort(Object count);

  /// No description provided for @quizOfTheDayLabel.
  ///
  /// In nl, this message translates to:
  /// **'Quiz van de dag: {title}'**
  String quizOfTheDayLabel(Object title);

  /// No description provided for @quizOfTheDayKicker.
  ///
  /// In nl, this message translates to:
  /// **'QUIZ VAN DE DAG'**
  String get quizOfTheDayKicker;

  /// No description provided for @actionUnlock.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendel'**
  String get actionUnlock;

  /// No description provided for @actionPlayNow.
  ///
  /// In nl, this message translates to:
  /// **'Speel nu'**
  String get actionPlayNow;

  /// No description provided for @homeChallengeLoading.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe uitdaging verschijnt zodra quizdata geladen is.'**
  String get homeChallengeLoading;

  /// No description provided for @homeLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Home kon niet laden'**
  String get homeLoadFailed;

  /// No description provided for @checkConnectionRetry.
  ///
  /// In nl, this message translates to:
  /// **'Controleer je verbinding en probeer het opnieuw.'**
  String get checkConnectionRetry;

  /// No description provided for @actionRetry.
  ///
  /// In nl, this message translates to:
  /// **'Opnieuw proberen'**
  String get actionRetry;

  /// No description provided for @homeGuestTitle.
  ///
  /// In nl, this message translates to:
  /// **'Speel gratis, zonder account'**
  String get homeGuestTitle;

  /// No description provided for @homeGuestBody.
  ///
  /// In nl, this message translates to:
  /// **'Maak er een aan om je score, punten en reeks te bewaren.'**
  String get homeGuestBody;

  /// No description provided for @homeGuestAction.
  ///
  /// In nl, this message translates to:
  /// **'Voortgang bewaren'**
  String get homeGuestAction;

  /// No description provided for @chapterN.
  ///
  /// In nl, this message translates to:
  /// **'Hoofdstuk {chapter}'**
  String chapterN(Object chapter);

  /// No description provided for @scoreCorrect.
  ///
  /// In nl, this message translates to:
  /// **'{scoreText} goed'**
  String scoreCorrect(Object scoreText);

  /// No description provided for @played.
  ///
  /// In nl, this message translates to:
  /// **'Gespeeld'**
  String get played;

  /// No description provided for @scoreA11y.
  ///
  /// In nl, this message translates to:
  /// **'{title}, {score} van {total} goed'**
  String scoreA11y(Object title, Object score, Object total);

  /// No description provided for @books39.
  ///
  /// In nl, this message translates to:
  /// **'39 boeken'**
  String get books39;

  /// No description provided for @books27.
  ///
  /// In nl, this message translates to:
  /// **'27 boeken'**
  String get books27;

  /// No description provided for @catGeneral.
  ///
  /// In nl, this message translates to:
  /// **'Algemeen'**
  String get catGeneral;

  /// No description provided for @catWholeBible.
  ///
  /// In nl, this message translates to:
  /// **'Hele Bijbel'**
  String get catWholeBible;

  /// No description provided for @catByTheme.
  ///
  /// In nl, this message translates to:
  /// **'Per thema'**
  String get catByTheme;

  /// No description provided for @questionsCountQuiz.
  ///
  /// In nl, this message translates to:
  /// **'{questionCount} vragen'**
  String questionsCountQuiz(Object questionCount);

  /// No description provided for @groupsLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Kon je groepen niet laden.'**
  String get groupsLoadFailed;

  /// No description provided for @groupSaveFailed.
  ///
  /// In nl, this message translates to:
  /// **'Groep bewaren is niet gelukt.'**
  String get groupSaveFailed;

  /// No description provided for @groupSaveFailedTitle.
  ///
  /// In nl, this message translates to:
  /// **'Groep bewaren mislukt'**
  String get groupSaveFailedTitle;

  /// No description provided for @groupSaveNoGroup.
  ///
  /// In nl, this message translates to:
  /// **'De server gaf geen groep terug. Probeer het opnieuw.'**
  String get groupSaveNoGroup;

  /// No description provided for @groupRenameFailed.
  ///
  /// In nl, this message translates to:
  /// **'Hernoemen is niet gelukt.'**
  String get groupRenameFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In nl, this message translates to:
  /// **'Verwijderen is niet gelukt.'**
  String get deleteFailed;

  /// No description provided for @groupStandingsFailed.
  ///
  /// In nl, this message translates to:
  /// **'Kon de stand van deze groep niet laden.'**
  String get groupStandingsFailed;

  /// No description provided for @groupsTitle.
  ///
  /// In nl, this message translates to:
  /// **'Groepen'**
  String get groupsTitle;

  /// No description provided for @groupSingular.
  ///
  /// In nl, this message translates to:
  /// **'Groep'**
  String get groupSingular;

  /// No description provided for @leaderboardLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Ranglijst kon niet laden'**
  String get leaderboardLoadFailed;

  /// No description provided for @leaderboardMonthHint.
  ///
  /// In nl, this message translates to:
  /// **'XP van de afgelopen 30 dagen'**
  String get leaderboardMonthHint;

  /// No description provided for @leaderboardAllTimeHint.
  ///
  /// In nl, this message translates to:
  /// **'Alle XP sinds de start telt mee'**
  String get leaderboardAllTimeHint;

  /// No description provided for @periodMonth.
  ///
  /// In nl, this message translates to:
  /// **'Deze maand'**
  String get periodMonth;

  /// No description provided for @periodAllTime.
  ///
  /// In nl, this message translates to:
  /// **'Altijd'**
  String get periodAllTime;

  /// No description provided for @periodLabel.
  ///
  /// In nl, this message translates to:
  /// **'Periode'**
  String get periodLabel;

  /// No description provided for @everyone.
  ///
  /// In nl, this message translates to:
  /// **'Iedereen'**
  String get everyone;

  /// No description provided for @leaderboardGap.
  ///
  /// In nl, this message translates to:
  /// **'Nog {gap} XP tot plek {rank}'**
  String leaderboardGap(Object gap, Object rank);

  /// No description provided for @showLess.
  ///
  /// In nl, this message translates to:
  /// **'Toon minder'**
  String get showLess;

  /// No description provided for @showAllPlayers.
  ///
  /// In nl, this message translates to:
  /// **'Toon alle {total} spelers'**
  String showAllPlayers(Object total);

  /// No description provided for @leaderboardGuestHint.
  ///
  /// In nl, this message translates to:
  /// **'Met een gratis account telt je XP mee.'**
  String get leaderboardGuestHint;

  /// No description provided for @leaderboardNotOnIt.
  ///
  /// In nl, this message translates to:
  /// **'Je staat nog niet op deze ranglijst'**
  String get leaderboardNotOnIt;

  /// No description provided for @leaderboardPlayToJoin.
  ///
  /// In nl, this message translates to:
  /// **'Speel een quiz om mee te doen.'**
  String get leaderboardPlayToJoin;

  /// No description provided for @leaderboardNoData.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen ranglijstdata beschikbaar.'**
  String get leaderboardNoData;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In nl, this message translates to:
  /// **'Nog niemand op de ranglijst'**
  String get leaderboardEmpty;

  /// No description provided for @onboardingTagline.
  ///
  /// In nl, this message translates to:
  /// **'Korte quizzen over de bijbelboeken, alleen of samen met anderen.'**
  String get onboardingTagline;

  /// No description provided for @onboardingGuest.
  ///
  /// In nl, this message translates to:
  /// **'Eerst spelen zonder account'**
  String get onboardingGuest;

  /// No description provided for @onboardingPreviewA11y.
  ///
  /// In nl, this message translates to:
  /// **'Voorbeeld: een quizvraag met het goede antwoord, een duel tegen Lotte, XP en een reeks'**
  String get onboardingPreviewA11y;

  /// No description provided for @onboardingSampleQuestion.
  ///
  /// In nl, this message translates to:
  /// **'Hoeveel broden had de jongen bij zich?'**
  String get onboardingSampleQuestion;

  /// No description provided for @onboardingSampleStreak.
  ///
  /// In nl, this message translates to:
  /// **'6 dagen op rij'**
  String get onboardingSampleStreak;

  /// No description provided for @seasonEndsToday.
  ///
  /// In nl, this message translates to:
  /// **'Loopt vandaag af'**
  String get seasonEndsToday;

  /// No description provided for @seasonOneDayLeft.
  ///
  /// In nl, this message translates to:
  /// **'Nog 1 dag'**
  String get seasonOneDayLeft;

  /// No description provided for @seasonDaysLeft.
  ///
  /// In nl, this message translates to:
  /// **'Nog {daysRemaining} dagen'**
  String seasonDaysLeft(Object daysRemaining);

  /// No description provided for @season.
  ///
  /// In nl, this message translates to:
  /// **'Seizoen'**
  String get season;

  /// No description provided for @manageSubscription.
  ///
  /// In nl, this message translates to:
  /// **'Abonnement beheren'**
  String get manageSubscription;

  /// No description provided for @viaWebsite.
  ///
  /// In nl, this message translates to:
  /// **'Via de website'**
  String get viaWebsite;

  /// No description provided for @lifetime.
  ///
  /// In nl, this message translates to:
  /// **'Levenslang'**
  String get lifetime;

  /// No description provided for @active.
  ///
  /// In nl, this message translates to:
  /// **'Actief'**
  String get active;

  /// No description provided for @deleteSignInFirst.
  ///
  /// In nl, this message translates to:
  /// **'Log eerst in met het account dat je wilt verwijderen.'**
  String get deleteSignInFirst;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In nl, this message translates to:
  /// **'Account verwijderen?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountBody.
  ///
  /// In nl, this message translates to:
  /// **'Je account, je voortgang, je XP en je duels worden definitief verwijderd. Dit kan niet ongedaan worden gemaakt.\n\nEen abonnement via de App Store of Google Play stopt hierdoor niet: zeg dat eerst op in de abonnementen van je telefoon.'**
  String get deleteAccountBody;

  /// No description provided for @deletePermanently.
  ///
  /// In nl, this message translates to:
  /// **'Definitief verwijderen'**
  String get deletePermanently;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In nl, this message translates to:
  /// **'Verwijderen is niet gelukt. Probeer het opnieuw of mail {accountEmail}.'**
  String deleteAccountFailed(Object accountEmail);

  /// No description provided for @accountNotDeleted.
  ///
  /// In nl, this message translates to:
  /// **'Account niet verwijderd'**
  String get accountNotDeleted;

  /// No description provided for @accountDeleted.
  ///
  /// In nl, this message translates to:
  /// **'Je account is verwijderd.'**
  String get accountDeleted;

  /// No description provided for @notificationsOff.
  ///
  /// In nl, this message translates to:
  /// **'Meldingen staan uit voor BijbelQuiz. Zet ze aan in de instellingen van je telefoon.'**
  String get notificationsOff;

  /// No description provided for @purchasesRestored.
  ///
  /// In nl, this message translates to:
  /// **'Aankopen hersteld'**
  String get purchasesRestored;

  /// No description provided for @settingsReminder.
  ///
  /// In nl, this message translates to:
  /// **'Herinnering'**
  String get settingsReminder;

  /// No description provided for @settingsTime.
  ///
  /// In nl, this message translates to:
  /// **'Tijdstip'**
  String get settingsTime;

  /// No description provided for @settingsPlaying.
  ///
  /// In nl, this message translates to:
  /// **'Spelen'**
  String get settingsPlaying;

  /// No description provided for @settingsReadChapterFirst.
  ///
  /// In nl, this message translates to:
  /// **'Eerst het hoofdstuk lezen'**
  String get settingsReadChapterFirst;

  /// No description provided for @settingsShowReference.
  ///
  /// In nl, this message translates to:
  /// **'Bijbelverwijzing bij uitleg'**
  String get settingsShowReference;

  /// No description provided for @settingsLargeText.
  ///
  /// In nl, this message translates to:
  /// **'Grote vraagtekst'**
  String get settingsLargeText;

  /// No description provided for @restorePurchases.
  ///
  /// In nl, this message translates to:
  /// **'Aankopen herstellen'**
  String get restorePurchases;

  /// No description provided for @settingsManage.
  ///
  /// In nl, this message translates to:
  /// **'Beheer'**
  String get settingsManage;

  /// No description provided for @signOut.
  ///
  /// In nl, this message translates to:
  /// **'Uitloggen'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In nl, this message translates to:
  /// **'Account verwijderen'**
  String get deleteAccount;

  /// No description provided for @guestPlaying.
  ///
  /// In nl, this message translates to:
  /// **'Je speelt zonder account'**
  String get guestPlaying;

  /// No description provided for @signInOrCreate.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen of een account aanmaken'**
  String get signInOrCreate;

  /// No description provided for @yourAccount.
  ///
  /// In nl, this message translates to:
  /// **'Je account'**
  String get yourAccount;

  /// No description provided for @signedIn.
  ///
  /// In nl, this message translates to:
  /// **'Ingelogd'**
  String get signedIn;

  /// No description provided for @signedInAs.
  ///
  /// In nl, this message translates to:
  /// **'Ingelogd als {email}'**
  String signedInAs(Object email);

  /// No description provided for @secondsN.
  ///
  /// In nl, this message translates to:
  /// **'{choice} seconden'**
  String secondsN(Object choice);

  /// No description provided for @joinFailed.
  ///
  /// In nl, this message translates to:
  /// **'Deelnemen is niet gelukt.'**
  String get joinFailed;

  /// No description provided for @joinFailedConnection.
  ///
  /// In nl, this message translates to:
  /// **'Deelnemen is niet gelukt. Controleer je verbinding.'**
  String get joinFailedConnection;

  /// No description provided for @trialEndingTitle.
  ///
  /// In nl, this message translates to:
  /// **'Je proefperiode loopt bijna af'**
  String get trialEndingTitle;

  /// No description provided for @trialEndingBody.
  ///
  /// In nl, this message translates to:
  /// **'Over {kTrialReminderDaysBeforeEnd} dagen gaat je BijbelQuiz Premium in. Wil je niet verder? Zeg dan op in je store-instellingen.'**
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd);

  /// No description provided for @trialReminderChannel.
  ///
  /// In nl, this message translates to:
  /// **'Herinnering proefperiode'**
  String get trialReminderChannel;

  /// No description provided for @trialReminderChannelDescription.
  ///
  /// In nl, this message translates to:
  /// **'Een herinnering voordat je gratis proefperiode afloopt.'**
  String get trialReminderChannelDescription;

  /// No description provided for @supportEmail.
  ///
  /// In nl, this message translates to:
  /// **'info@bijbelquiz.com'**
  String get supportEmail;

  /// No description provided for @groupCodeIncomplete.
  ///
  /// In nl, this message translates to:
  /// **'Vul de volledige groepscode in.'**
  String get groupCodeIncomplete;

  /// No description provided for @groupJoined.
  ///
  /// In nl, this message translates to:
  /// **'Je hoort nu bij {name}.'**
  String groupJoined(Object name);

  /// No description provided for @groupLicenseGoToSite.
  ///
  /// In nl, this message translates to:
  /// **'Ga naar bijbelquiz.com/groepslicentie in je browser.'**
  String get groupLicenseGoToSite;

  /// No description provided for @groupLicense.
  ///
  /// In nl, this message translates to:
  /// **'Groepslicentie'**
  String get groupLicense;

  /// No description provided for @mailUsAt.
  ///
  /// In nl, this message translates to:
  /// **'Mail ons op {supportEmail}.'**
  String mailUsAt(Object supportEmail);

  /// No description provided for @groupCodeIntro.
  ///
  /// In nl, this message translates to:
  /// **'Heeft je jeugdleider, dominee of docent een groepscode? Vul hem hieronder in en je hebt meteen Premium.'**
  String get groupCodeIntro;

  /// No description provided for @premiumViaGroup.
  ///
  /// In nl, this message translates to:
  /// **'Premium via je groep'**
  String get premiumViaGroup;

  /// No description provided for @yourGroups.
  ///
  /// In nl, this message translates to:
  /// **'Jouw groepen'**
  String get yourGroups;

  /// No description provided for @premiumWholeGroup.
  ///
  /// In nl, this message translates to:
  /// **'Premium voor je hele groep'**
  String get premiumWholeGroup;

  /// No description provided for @forChurches.
  ///
  /// In nl, this message translates to:
  /// **'Voor kerken, scholen en verenigingen'**
  String get forChurches;

  /// No description provided for @groupPerkAll.
  ///
  /// In nl, this message translates to:
  /// **'Alles van Premium voor elk lid'**
  String get groupPerkAll;

  /// No description provided for @groupPerkCode.
  ///
  /// In nl, this message translates to:
  /// **'Een code die je voorleest in de zaal'**
  String get groupPerkCode;

  /// No description provided for @groupPerkManage.
  ///
  /// In nl, this message translates to:
  /// **'Je beheert zelf wie er meedoet'**
  String get groupPerkManage;

  /// No description provided for @groupLicenseWebsiteOnly.
  ///
  /// In nl, this message translates to:
  /// **'Een groepslicentie koop je op de website, omdat een aankoop in de App Store aan een enkel account vastzit en niet aan een groep.'**
  String get groupLicenseWebsiteOnly;

  /// No description provided for @openWebsite.
  ///
  /// In nl, this message translates to:
  /// **'Open bijbelquiz.com'**
  String get openWebsite;

  /// No description provided for @youManageGroup.
  ///
  /// In nl, this message translates to:
  /// **'Je beheert deze groep'**
  String get youManageGroup;

  /// No description provided for @youTakePart.
  ///
  /// In nl, this message translates to:
  /// **'Je doet mee'**
  String get youTakePart;

  /// No description provided for @groupCode.
  ///
  /// In nl, this message translates to:
  /// **'Groepscode'**
  String get groupCode;

  /// No description provided for @purchaseReceivedNotActive.
  ///
  /// In nl, this message translates to:
  /// **'Je aankoop is ontvangen, maar Premium staat nog niet aan. Tik over een minuut op \"Herstellen\".'**
  String get purchaseReceivedNotActive;

  /// No description provided for @noPurchaseFound.
  ///
  /// In nl, this message translates to:
  /// **'We vonden geen Premium-aankoop op dit {storeName}-account.'**
  String noPurchaseFound(Object storeName);

  /// No description provided for @purchasePending.
  ///
  /// In nl, this message translates to:
  /// **'Je aankoop wacht nog op goedkeuring of betaling. Premium gaat vanzelf aan zodra de {storeName} die afrondt.'**
  String purchasePending(Object storeName);

  /// No description provided for @noInternetRetry.
  ///
  /// In nl, this message translates to:
  /// **'Geen internetverbinding. Controleer je verbinding en probeer het opnieuw.'**
  String get noInternetRetry;

  /// No description provided for @alreadyPurchased.
  ///
  /// In nl, this message translates to:
  /// **'Je hebt dit al gekocht. Tik op \"Herstellen\" om het terug te zetten.'**
  String get alreadyPurchased;

  /// No description provided for @purchaseOtherAccount.
  ///
  /// In nl, this message translates to:
  /// **'Deze aankoop hoort al bij een ander BijbelQuiz-account. Log in met dat account om je Premium te gebruiken.'**
  String get purchaseOtherAccount;

  /// No description provided for @purchasesNotAllowed.
  ///
  /// In nl, this message translates to:
  /// **'Aankopen zijn niet toegestaan op dit apparaat. Controleer de instellingen van je {store}-account.'**
  String purchasesNotAllowed(Object store);

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In nl, this message translates to:
  /// **'Dit abonnement is nu niet beschikbaar in de {store}. Probeer het later opnieuw.'**
  String subscriptionUnavailable(Object store);

  /// No description provided for @storeError.
  ///
  /// In nl, this message translates to:
  /// **'De {store} geeft een fout. Probeer het later opnieuw.'**
  String storeError(Object store);

  /// No description provided for @purchasesNotInVersion.
  ///
  /// In nl, this message translates to:
  /// **'Aankopen zijn in deze versie van de app niet beschikbaar.'**
  String get purchasesNotInVersion;

  /// No description provided for @restoreFailed.
  ///
  /// In nl, this message translates to:
  /// **'Herstellen is niet gelukt. Probeer het opnieuw.'**
  String get restoreFailed;

  /// No description provided for @introPerkExplain.
  ///
  /// In nl, this message translates to:
  /// **'Uitleg bij elke vraag: waarom het antwoord klopt'**
  String get introPerkExplain;

  /// No description provided for @introPerkAll.
  ///
  /// In nl, this message translates to:
  /// **'Alle quizzen, zo vaak je wilt'**
  String get introPerkAll;

  /// No description provided for @introPerkReview.
  ///
  /// In nl, this message translates to:
  /// **'Een volledige review na elke quiz'**
  String get introPerkReview;

  /// No description provided for @introPerkDaily.
  ///
  /// In nl, this message translates to:
  /// **'Elke dag een nieuwe quiz, zonder limiet'**
  String get introPerkDaily;

  /// No description provided for @introPerkStick.
  ///
  /// In nl, this message translates to:
  /// **'Uitleg bij elke vraag, zodat het blijft hangen'**
  String get introPerkStick;

  /// No description provided for @introPerkLookBack.
  ///
  /// In nl, this message translates to:
  /// **'Je antwoorden terugkijken na elke quiz'**
  String get introPerkLookBack;

  /// No description provided for @introPerkTogetherFree.
  ///
  /// In nl, this message translates to:
  /// **'Samen spelen blijft voor iedereen gratis'**
  String get introPerkTogetherFree;

  /// No description provided for @introPerkSoloUnlimited.
  ///
  /// In nl, this message translates to:
  /// **'Daarnaast alleen onbeperkt verder spelen'**
  String get introPerkSoloUnlimited;

  /// No description provided for @introPerkDiscuss.
  ///
  /// In nl, this message translates to:
  /// **'Uitleg bij elke vraag om samen na te praten'**
  String get introPerkDiscuss;

  /// No description provided for @stepOfThree.
  ///
  /// In nl, this message translates to:
  /// **'Stap {page} van 3'**
  String stepOfThree(Object page);

  /// No description provided for @actionNext.
  ///
  /// In nl, this message translates to:
  /// **'Verder'**
  String get actionNext;

  /// No description provided for @introGrowQuestion.
  ///
  /// In nl, this message translates to:
  /// **'Waar wil je in groeien?'**
  String get introGrowQuestion;

  /// No description provided for @introGrowSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Dan laten we zien wat Premium daarvoor doet.'**
  String get introGrowSubtitle;

  /// No description provided for @introGoalKnowledge.
  ///
  /// In nl, this message translates to:
  /// **'Meer Bijbelkennis'**
  String get introGoalKnowledge;

  /// No description provided for @introGoalKnowledgeBody.
  ///
  /// In nl, this message translates to:
  /// **'Begrijpen waarom een antwoord klopt.'**
  String get introGoalKnowledgeBody;

  /// No description provided for @introGoalDaily.
  ///
  /// In nl, this message translates to:
  /// **'Elke dag iets leren'**
  String get introGoalDaily;

  /// No description provided for @introGoalDailyBody.
  ///
  /// In nl, this message translates to:
  /// **'Een gewoonte opbouwen en vasthouden.'**
  String get introGoalDailyBody;

  /// No description provided for @introGoalGroupBody.
  ///
  /// In nl, this message translates to:
  /// **'Met familie of een groep tegen elkaar.'**
  String get introGoalGroupBody;

  /// No description provided for @introYouGet.
  ///
  /// In nl, this message translates to:
  /// **'Dit krijg je erbij'**
  String get introYouGet;

  /// No description provided for @introOneMembership.
  ///
  /// In nl, this message translates to:
  /// **'Alles in een lidmaatschap, op web en app.'**
  String get introOneMembership;

  /// No description provided for @choosePlan.
  ///
  /// In nl, this message translates to:
  /// **'Kies je plan'**
  String get choosePlan;

  /// No description provided for @pricesNextPage.
  ///
  /// In nl, this message translates to:
  /// **'Op de volgende pagina zie je de prijzen. Opzeggen kan altijd.'**
  String get pricesNextPage;

  /// No description provided for @accountWebAndApp.
  ///
  /// In nl, this message translates to:
  /// **'Je account werkt op web en app tegelijk. Een aankoop op je telefoon geeft je ook Premium op de website, en andersom.'**
  String get accountWebAndApp;

  /// No description provided for @paywallHeadlineDefault.
  ///
  /// In nl, this message translates to:
  /// **'Speel onbeperkt\nmet Premium'**
  String get paywallHeadlineDefault;

  /// No description provided for @paywallHeadlineLimit.
  ///
  /// In nl, this message translates to:
  /// **'Je {kFreeQuizLimit} gratis quizzen\nzijn gespeeld'**
  String paywallHeadlineLimit(Object kFreeQuizLimit);

  /// No description provided for @paywallHeadlineTogether.
  ///
  /// In nl, this message translates to:
  /// **'Speel onbeperkt\nsamen verder'**
  String get paywallHeadlineTogether;

  /// No description provided for @paywallHeadlineGroup.
  ///
  /// In nl, this message translates to:
  /// **'Speel met je\nhele groep'**
  String get paywallHeadlineGroup;

  /// No description provided for @paywallHeadlineExplain.
  ///
  /// In nl, this message translates to:
  /// **'Lees bij elke vraag\nwaarom'**
  String get paywallHeadlineExplain;

  /// No description provided for @paywallHeadlineUnlock.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendel\nalle quizzen'**
  String get paywallHeadlineUnlock;

  /// No description provided for @premiumRestored.
  ///
  /// In nl, this message translates to:
  /// **'Premium hersteld'**
  String get premiumRestored;

  /// No description provided for @welcomePremium.
  ///
  /// In nl, this message translates to:
  /// **'Welkom bij Premium'**
  String get welcomePremium;

  /// No description provided for @premiumBackOn.
  ///
  /// In nl, this message translates to:
  /// **'Je Premium staat weer aan op dit account.'**
  String get premiumBackOn;

  /// No description provided for @premiumFullAccess.
  ///
  /// In nl, this message translates to:
  /// **'Je hebt nu volledige toegang tot alle premium functies, in de app en op de website. Veel plezier!'**
  String get premiumFullAccess;

  /// No description provided for @playOnPremium.
  ///
  /// In nl, this message translates to:
  /// **'Speel verder met Premium.'**
  String get playOnPremium;

  /// No description provided for @chooseSubscription.
  ///
  /// In nl, this message translates to:
  /// **'Kies een abonnement'**
  String get chooseSubscription;

  /// No description provided for @yearly.
  ///
  /// In nl, this message translates to:
  /// **'Jaarlijks'**
  String get yearly;

  /// No description provided for @perYear.
  ///
  /// In nl, this message translates to:
  /// **'per jaar'**
  String get perYear;

  /// No description provided for @monthly.
  ///
  /// In nl, this message translates to:
  /// **'Maandelijks'**
  String get monthly;

  /// No description provided for @perMonth.
  ///
  /// In nl, this message translates to:
  /// **'per maand'**
  String get perMonth;

  /// No description provided for @noTrial.
  ///
  /// In nl, this message translates to:
  /// **'Geen proefperiode'**
  String get noTrial;

  /// No description provided for @reloadPrices.
  ///
  /// In nl, this message translates to:
  /// **'Prijzen opnieuw laden'**
  String get reloadPrices;

  /// No description provided for @storeUnreachable.
  ///
  /// In nl, this message translates to:
  /// **'De {storeName} is nu niet bereikbaar. Controleer je verbinding.'**
  String storeUnreachable(Object storeName);

  /// No description provided for @restorePurchase.
  ///
  /// In nl, this message translates to:
  /// **'Aankoop herstellen'**
  String get restorePurchase;

  /// No description provided for @terms.
  ///
  /// In nl, this message translates to:
  /// **'Voorwaarden'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In nl, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @alreadyPremium.
  ///
  /// In nl, this message translates to:
  /// **'Je hebt al Premium op dit account. Er is niets afgeschreven.'**
  String get alreadyPremium;

  /// No description provided for @premiumOn.
  ///
  /// In nl, this message translates to:
  /// **'Premium staat aan'**
  String get premiumOn;

  /// No description provided for @restoreSignIn.
  ///
  /// In nl, this message translates to:
  /// **'Log in met je account, dan zetten we je aankopen terug op dat account.'**
  String get restoreSignIn;

  /// No description provided for @needAccountForPremium.
  ///
  /// In nl, this message translates to:
  /// **'Maak eerst een gratis account of log in, dan hoort Premium bij jou - in de app en op de website.'**
  String get needAccountForPremium;

  /// No description provided for @accountNeeded.
  ///
  /// In nl, this message translates to:
  /// **'Account nodig'**
  String get accountNeeded;

  /// No description provided for @pleaseWait.
  ///
  /// In nl, this message translates to:
  /// **'Even geduld'**
  String get pleaseWait;

  /// No description provided for @nothingToRestore.
  ///
  /// In nl, this message translates to:
  /// **'Niets om te herstellen'**
  String get nothingToRestore;

  /// No description provided for @viewAllPlans.
  ///
  /// In nl, this message translates to:
  /// **'Alle plannen bekijken'**
  String get viewAllPlans;

  /// No description provided for @explainEveryAnswer.
  ///
  /// In nl, this message translates to:
  /// **'Uitleg bij elk antwoord'**
  String get explainEveryAnswer;

  /// No description provided for @paywallFreeLimit.
  ///
  /// In nl, this message translates to:
  /// **'Gratis speel je {kFreeQuizLimit} quizzen. Met Premium gaan alle bijbelboeken open, ook Psalmen en Openbaring.'**
  String paywallFreeLimit(Object kFreeQuizLimit);

  /// No description provided for @premiumEverythingOpen.
  ///
  /// In nl, this message translates to:
  /// **'Met Premium alles open'**
  String get premiumEverythingOpen;

  /// No description provided for @abbrGenesis.
  ///
  /// In nl, this message translates to:
  /// **'Gen'**
  String get abbrGenesis;

  /// No description provided for @quizzes12.
  ///
  /// In nl, this message translates to:
  /// **'12 quizzen'**
  String get quizzes12;

  /// No description provided for @abbrPsalms.
  ///
  /// In nl, this message translates to:
  /// **'Ps'**
  String get abbrPsalms;

  /// No description provided for @quizzes15.
  ///
  /// In nl, this message translates to:
  /// **'15 quizzen'**
  String get quizzes15;

  /// No description provided for @abbrRevelation.
  ///
  /// In nl, this message translates to:
  /// **'Opb'**
  String get abbrRevelation;

  /// No description provided for @bookRevelation.
  ///
  /// In nl, this message translates to:
  /// **'Openbaring'**
  String get bookRevelation;

  /// No description provided for @quizzes9.
  ///
  /// In nl, this message translates to:
  /// **'9 quizzen'**
  String get quizzes9;

  /// No description provided for @free.
  ///
  /// In nl, this message translates to:
  /// **'Gratis'**
  String get free;

  /// No description provided for @orLifetime.
  ///
  /// In nl, this message translates to:
  /// **'Of eenmalig: levenslang Premium'**
  String get orLifetime;

  /// No description provided for @lifetimeOnce.
  ///
  /// In nl, this message translates to:
  /// **'Levenslang Premium, {price} eenmalig'**
  String lifetimeOnce(Object price);

  /// No description provided for @lifetimePerWeek.
  ///
  /// In nl, this message translates to:
  /// **'{weekly} per week over {lifetimeHorizonYears} jaar'**
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears);

  /// No description provided for @lifetimePremium.
  ///
  /// In nl, this message translates to:
  /// **'Levenslang Premium'**
  String get lifetimePremium;

  /// No description provided for @payNothingToday.
  ///
  /// In nl, this message translates to:
  /// **'Vandaag betaal je niets.'**
  String get payNothingToday;

  /// No description provided for @payNothingTodayReminder.
  ///
  /// In nl, this message translates to:
  /// **'Vandaag betaal je niets. Herinnering op dag {day}.'**
  String payNothingTodayReminder(Object day);

  /// No description provided for @cancelAnytime.
  ///
  /// In nl, this message translates to:
  /// **'Zeg op wanneer je wilt.'**
  String get cancelAnytime;

  /// No description provided for @payOnceNoSub.
  ///
  /// In nl, this message translates to:
  /// **'Eenmalig betalen, geen abonnement.'**
  String get payOnceNoSub;

  /// No description provided for @startPremium.
  ///
  /// In nl, this message translates to:
  /// **'Start Premium'**
  String get startPremium;

  /// No description provided for @tryTrial.
  ///
  /// In nl, this message translates to:
  /// **'Probeer {label}'**
  String tryTrial(Object label);

  /// No description provided for @badgeFirstStepsDesc.
  ///
  /// In nl, this message translates to:
  /// **'Voltooi je eerste quiz.'**
  String get badgeFirstStepsDesc;

  /// No description provided for @badgeKnowledgeSeeker.
  ///
  /// In nl, this message translates to:
  /// **'Kenniszoeker'**
  String get badgeKnowledgeSeeker;

  /// No description provided for @badgeKnowledgeSeekerDesc.
  ///
  /// In nl, this message translates to:
  /// **'Speel 10 verschillende quizzen.'**
  String get badgeKnowledgeSeekerDesc;

  /// No description provided for @badgePerfect.
  ///
  /// In nl, this message translates to:
  /// **'Foutloos'**
  String get badgePerfect;

  /// No description provided for @badgePerfectDesc.
  ///
  /// In nl, this message translates to:
  /// **'Haal een 100% score op een quiz.'**
  String get badgePerfectDesc;

  /// No description provided for @badgeOnARoll.
  ///
  /// In nl, this message translates to:
  /// **'Op Dreef'**
  String get badgeOnARoll;

  /// No description provided for @badgeOnARollDesc.
  ///
  /// In nl, this message translates to:
  /// **'Bouw een streak van 3 dagen op.'**
  String get badgeOnARollDesc;

  /// No description provided for @badgeDedicated.
  ///
  /// In nl, this message translates to:
  /// **'Toegewijd'**
  String get badgeDedicated;

  /// No description provided for @badgeDedicatedDesc.
  ///
  /// In nl, this message translates to:
  /// **'Speel 7 dagen op rij.'**
  String get badgeDedicatedDesc;

  /// No description provided for @badgeScholar.
  ///
  /// In nl, this message translates to:
  /// **'Geleerde'**
  String get badgeScholar;

  /// No description provided for @badgeMaster.
  ///
  /// In nl, this message translates to:
  /// **'Meester'**
  String get badgeMaster;

  /// No description provided for @badgeAllRounder.
  ///
  /// In nl, this message translates to:
  /// **'Allrounder'**
  String get badgeAllRounder;

  /// No description provided for @badgeAllRounderDesc.
  ///
  /// In nl, this message translates to:
  /// **'Speel een brede selectie quizzen.'**
  String get badgeAllRounderDesc;

  /// No description provided for @rankSeeker.
  ///
  /// In nl, this message translates to:
  /// **'Zoeker'**
  String get rankSeeker;

  /// No description provided for @saveFailed.
  ///
  /// In nl, this message translates to:
  /// **'Opslaan is niet gelukt. Probeer het opnieuw.'**
  String get saveFailed;

  /// No description provided for @saveFailedConnection.
  ///
  /// In nl, this message translates to:
  /// **'Opslaan is niet gelukt. Controleer je verbinding.'**
  String get saveFailedConnection;

  /// No description provided for @achievements.
  ///
  /// In nl, this message translates to:
  /// **'Prestaties'**
  String get achievements;

  /// No description provided for @achievementsLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Prestaties konden niet laden'**
  String get achievementsLoadFailed;

  /// No description provided for @noBadgesYet.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen badges behaald. Speel quizzen om je eerste badge vrij te spelen.'**
  String get noBadgesYet;

  /// No description provided for @stillToEarn.
  ///
  /// In nl, this message translates to:
  /// **'Nog te halen · {lockedCount}'**
  String stillToEarn(Object lockedCount);

  /// No description provided for @badgesEarnedA11y.
  ///
  /// In nl, this message translates to:
  /// **'{unlocked} van {total} badges behaald'**
  String badgesEarnedA11y(Object unlocked, Object total);

  /// No description provided for @badgesOf.
  ///
  /// In nl, this message translates to:
  /// **'{unlocked} van {total} badges'**
  String badgesOf(Object unlocked, Object total);

  /// No description provided for @allEarned.
  ///
  /// In nl, this message translates to:
  /// **'Alles behaald'**
  String get allEarned;

  /// No description provided for @leftToEarn.
  ///
  /// In nl, this message translates to:
  /// **'Nog {left} te halen'**
  String leftToEarn(Object left);

  /// No description provided for @profileUpdated.
  ///
  /// In nl, this message translates to:
  /// **'Profiel bijgewerkt.'**
  String get profileUpdated;

  /// No description provided for @editProfile.
  ///
  /// In nl, this message translates to:
  /// **'Profiel bewerken'**
  String get editProfile;

  /// No description provided for @profileLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Profiel kon niet laden'**
  String get profileLoadFailed;

  /// No description provided for @actionSave.
  ///
  /// In nl, this message translates to:
  /// **'Opslaan'**
  String get actionSave;

  /// No description provided for @surpriseMe.
  ///
  /// In nl, this message translates to:
  /// **'Verras me'**
  String get surpriseMe;

  /// No description provided for @displayName.
  ///
  /// In nl, this message translates to:
  /// **'Weergavenaam'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In nl, this message translates to:
  /// **'Hoe je op de ranglijst verschijnt'**
  String get displayNameHint;

  /// No description provided for @displayNameHelp.
  ///
  /// In nl, this message translates to:
  /// **'Zichtbaar op de ranglijst en in multiplayer. Eens per 30 dagen te wijzigen.'**
  String get displayNameHelp;

  /// No description provided for @buildMascot.
  ///
  /// In nl, this message translates to:
  /// **'Stel je mascotte samen'**
  String get buildMascot;

  /// No description provided for @figure.
  ///
  /// In nl, this message translates to:
  /// **'Figuur'**
  String get figure;

  /// No description provided for @color.
  ///
  /// In nl, this message translates to:
  /// **'Kleur'**
  String get color;

  /// No description provided for @background.
  ///
  /// In nl, this message translates to:
  /// **'Achtergrond'**
  String get background;

  /// No description provided for @accessory.
  ///
  /// In nl, this message translates to:
  /// **'Accessoire'**
  String get accessory;

  /// No description provided for @notSignedIn.
  ///
  /// In nl, this message translates to:
  /// **'Niet ingelogd'**
  String get notSignedIn;

  /// No description provided for @settings.
  ///
  /// In nl, this message translates to:
  /// **'Instellingen'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In nl, this message translates to:
  /// **'Statistieken'**
  String get statistics;

  /// No description provided for @recentlyPlayed.
  ///
  /// In nl, this message translates to:
  /// **'Recent gespeeld'**
  String get recentlyPlayed;

  /// No description provided for @levelN.
  ///
  /// In nl, this message translates to:
  /// **'Level {level}'**
  String levelN(Object level);

  /// No description provided for @maxLevel.
  ///
  /// In nl, this message translates to:
  /// **'Hoogste level bereikt'**
  String get maxLevel;

  /// No description provided for @progressToLevel.
  ///
  /// In nl, this message translates to:
  /// **'Voortgang naar level {level}'**
  String progressToLevel(Object level);

  /// No description provided for @xpToLevel.
  ///
  /// In nl, this message translates to:
  /// **'Nog {xpRemaining} XP tot level {level}'**
  String xpToLevel(Object xpRemaining, Object level);

  /// No description provided for @daysInARow.
  ///
  /// In nl, this message translates to:
  /// **'Dagen op rij'**
  String get daysInARow;

  /// No description provided for @quizzesPlayed.
  ///
  /// In nl, this message translates to:
  /// **'Quizzen gespeeld'**
  String get quizzesPlayed;

  /// No description provided for @averageScore.
  ///
  /// In nl, this message translates to:
  /// **'Gemiddelde score'**
  String get averageScore;

  /// No description provided for @viewAllAchievementsA11y.
  ///
  /// In nl, this message translates to:
  /// **'Alle prestaties bekijken, {unlockedCount} van {overviewCount} behaald'**
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount);

  /// No description provided for @allOf.
  ///
  /// In nl, this message translates to:
  /// **'Alle {unlockedCount} van {overviewCount}'**
  String allOf(Object unlockedCount, Object overviewCount);

  /// No description provided for @youHavePremium.
  ///
  /// In nl, this message translates to:
  /// **'Je hebt Premium'**
  String get youHavePremium;

  /// No description provided for @youPlayFree.
  ///
  /// In nl, this message translates to:
  /// **'Je speelt gratis'**
  String get youPlayFree;

  /// No description provided for @scoreOfTotal.
  ///
  /// In nl, this message translates to:
  /// **'{score} van {totalQuestions} goed'**
  String scoreOfTotal(Object score, Object totalQuestions);

  /// No description provided for @completed.
  ///
  /// In nl, this message translates to:
  /// **'Voltooid'**
  String get completed;

  /// No description provided for @guestPerkKeep.
  ///
  /// In nl, this message translates to:
  /// **'Punten, niveau en reeks die blijven staan'**
  String get guestPerkKeep;

  /// No description provided for @guestPerkLeaderboard.
  ///
  /// In nl, this message translates to:
  /// **'Een plek op de ranglijst'**
  String get guestPerkLeaderboard;

  /// No description provided for @guestPerkBadges.
  ///
  /// In nl, this message translates to:
  /// **'Badges voor je prestaties'**
  String get guestPerkBadges;

  /// No description provided for @guestPerkWebsite.
  ///
  /// In nl, this message translates to:
  /// **'Dezelfde voortgang op bijbelquiz.com'**
  String get guestPerkWebsite;

  /// No description provided for @saveYourProgress.
  ///
  /// In nl, this message translates to:
  /// **'Bewaar je voortgang'**
  String get saveYourProgress;

  /// No description provided for @guestExplain.
  ///
  /// In nl, this message translates to:
  /// **'Je speelt zonder account. Dat kan gewoon, maar je score, punten en reeks blijven alleen bewaard met een gratis account.'**
  String get guestExplain;

  /// No description provided for @createFreeAccount.
  ///
  /// In nl, this message translates to:
  /// **'Gratis account aanmaken'**
  String get createFreeAccount;

  /// No description provided for @pendingOne.
  ///
  /// In nl, this message translates to:
  /// **'Eén quiz wacht op je account'**
  String get pendingOne;

  /// No description provided for @pendingMany.
  ///
  /// In nl, this message translates to:
  /// **'{pendingCount} quizzen wachten op je account'**
  String pendingMany(Object pendingCount);

  /// No description provided for @withAccount.
  ///
  /// In nl, this message translates to:
  /// **'Met een account'**
  String get withAccount;

  /// No description provided for @oneQuiz.
  ///
  /// In nl, this message translates to:
  /// **'1 quiz'**
  String get oneQuiz;

  /// No description provided for @quizzesN.
  ///
  /// In nl, this message translates to:
  /// **'{total} quizzen'**
  String quizzesN(Object total);

  /// No description provided for @playedOf.
  ///
  /// In nl, this message translates to:
  /// **'{played} van {total} gespeeld'**
  String playedOf(Object played, Object total);

  /// No description provided for @quizzesLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Quizzen konden niet laden'**
  String get quizzesLoadFailed;

  /// No description provided for @byBibleBook.
  ///
  /// In nl, this message translates to:
  /// **'Per bijbelboek'**
  String get byBibleBook;

  /// No description provided for @booksAndQuizzes.
  ///
  /// In nl, this message translates to:
  /// **'{booksCount} boeken · {quizzes} quizzen'**
  String booksAndQuizzes(Object booksCount, Object quizzes);

  /// No description provided for @bibleBook.
  ///
  /// In nl, this message translates to:
  /// **'Bijbelboek'**
  String get bibleBook;

  /// No description provided for @quizzesCountList.
  ///
  /// In nl, this message translates to:
  /// **'{quizzesCount} quizzen'**
  String quizzesCountList(Object quizzesCount);

  /// No description provided for @playedOfList.
  ///
  /// In nl, this message translates to:
  /// **'{played} van {quizzesCount} gespeeld'**
  String playedOfList(Object played, Object quizzesCount);

  /// No description provided for @noQuizzesForBook.
  ///
  /// In nl, this message translates to:
  /// **'Over dit boek zijn nog geen quizzen.'**
  String get noQuizzesForBook;

  /// No description provided for @allQuizzesAbout.
  ///
  /// In nl, this message translates to:
  /// **'Alle quizzen over {name}'**
  String allQuizzesAbout(Object name);

  /// No description provided for @startWith.
  ///
  /// In nl, this message translates to:
  /// **'BEGIN MET'**
  String get startWith;

  /// No description provided for @continueWith.
  ///
  /// In nl, this message translates to:
  /// **'GA VERDER MET'**
  String get continueWith;

  /// No description provided for @anyLevel.
  ///
  /// In nl, this message translates to:
  /// **'Elk niveau'**
  String get anyLevel;

  /// No description provided for @easy.
  ///
  /// In nl, this message translates to:
  /// **'Makkelijk'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In nl, this message translates to:
  /// **'Gemiddeld'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In nl, this message translates to:
  /// **'Moeilijk'**
  String get hard;

  /// No description provided for @results.
  ///
  /// In nl, this message translates to:
  /// **'Resultaten'**
  String get results;

  /// No description provided for @allQuizzes.
  ///
  /// In nl, this message translates to:
  /// **'Alle quizzen'**
  String get allQuizzes;

  /// No description provided for @popular.
  ///
  /// In nl, this message translates to:
  /// **'Populair'**
  String get popular;

  /// No description provided for @allBooks.
  ///
  /// In nl, this message translates to:
  /// **'Alle boeken'**
  String get allBooks;

  /// No description provided for @searchHint.
  ///
  /// In nl, this message translates to:
  /// **'Zoek een bijbelboek of onderwerp'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In nl, this message translates to:
  /// **'Wissen'**
  String get clear;

  /// No description provided for @questionsAndMinutes.
  ///
  /// In nl, this message translates to:
  /// **'{questionCount} vragen · {questionCount2} min'**
  String questionsAndMinutes(Object questionCount, Object questionCount2);

  /// No description provided for @notPlayedYet.
  ///
  /// In nl, this message translates to:
  /// **'Nog niet gespeeld'**
  String get notPlayedYet;

  /// No description provided for @noQuizzesFilters.
  ///
  /// In nl, this message translates to:
  /// **'Geen quizzen gevonden met de huidige filters.'**
  String get noQuizzesFilters;

  /// No description provided for @sortBibleOrder.
  ///
  /// In nl, this message translates to:
  /// **'Bijbelvolgorde'**
  String get sortBibleOrder;

  /// No description provided for @sortMostPopular.
  ///
  /// In nl, this message translates to:
  /// **'Meest populair'**
  String get sortMostPopular;

  /// No description provided for @sortNewest.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwste eerst'**
  String get sortNewest;

  /// No description provided for @sortShortest.
  ///
  /// In nl, this message translates to:
  /// **'Kortste'**
  String get sortShortest;

  /// No description provided for @sort.
  ///
  /// In nl, this message translates to:
  /// **'Sorteren'**
  String get sort;

  /// No description provided for @hideText.
  ///
  /// In nl, this message translates to:
  /// **'Verberg tekst'**
  String get hideText;

  /// No description provided for @hideTextOf.
  ///
  /// In nl, this message translates to:
  /// **'Verberg de tekst van {reference}'**
  String hideTextOf(Object reference);

  /// No description provided for @unlockPremiumExplain.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendel Premium voor uitleg'**
  String get unlockPremiumExplain;

  /// No description provided for @readWhyWrong.
  ///
  /// In nl, this message translates to:
  /// **'Lees waarom dit fout was'**
  String get readWhyWrong;

  /// No description provided for @timeUp.
  ///
  /// In nl, this message translates to:
  /// **'Tijd om'**
  String get timeUp;

  /// No description provided for @finishQuiz.
  ///
  /// In nl, this message translates to:
  /// **'Rond quiz af'**
  String get finishQuiz;

  /// No description provided for @a11yYourAnswerRight.
  ///
  /// In nl, this message translates to:
  /// **', jouw antwoord, goed'**
  String get a11yYourAnswerRight;

  /// No description provided for @a11yCorrectAnswer.
  ///
  /// In nl, this message translates to:
  /// **', het goede antwoord'**
  String get a11yCorrectAnswer;

  /// No description provided for @a11yYourAnswerWrong.
  ///
  /// In nl, this message translates to:
  /// **', jouw antwoord, fout'**
  String get a11yYourAnswerWrong;

  /// No description provided for @questionOf.
  ///
  /// In nl, this message translates to:
  /// **'Vraag {current} van {total}'**
  String questionOf(Object current, Object total);

  /// No description provided for @secondsLeft.
  ///
  /// In nl, this message translates to:
  /// **'Nog {secondsLeft} seconden'**
  String secondsLeft(Object secondsLeft);

  /// No description provided for @wellPlayed.
  ///
  /// In nl, this message translates to:
  /// **'Mooi gespeeld'**
  String get wellPlayed;

  /// No description provided for @niceTry.
  ///
  /// In nl, this message translates to:
  /// **'Goed geprobeerd'**
  String get niceTry;

  /// No description provided for @nextQuiz.
  ///
  /// In nl, this message translates to:
  /// **'Volgende quiz'**
  String get nextQuiz;

  /// No description provided for @playWithOthers.
  ///
  /// In nl, this message translates to:
  /// **'Speel samen met anderen'**
  String get playWithOthers;

  /// No description provided for @viewAnswers.
  ///
  /// In nl, this message translates to:
  /// **'Bekijk antwoorden'**
  String get viewAnswers;

  /// No description provided for @scoreA11yShort.
  ///
  /// In nl, this message translates to:
  /// **'Score {correct} van {total}'**
  String scoreA11yShort(Object correct, Object total);

  /// No description provided for @newBestScore.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe beste score'**
  String get newBestScore;

  /// No description provided for @scoreNotSaved.
  ///
  /// In nl, this message translates to:
  /// **'Je score is nog niet opgeslagen'**
  String get scoreNotSaved;

  /// No description provided for @scoreSaving.
  ///
  /// In nl, this message translates to:
  /// **'Je score wordt opgeslagen'**
  String get scoreSaving;

  /// No description provided for @again.
  ///
  /// In nl, this message translates to:
  /// **'Opnieuw'**
  String get again;

  /// No description provided for @noExtraXp.
  ///
  /// In nl, this message translates to:
  /// **'Geen extra XP deze keer'**
  String get noExtraXp;

  /// No description provided for @replayRule.
  ///
  /// In nl, this message translates to:
  /// **'Een herhaling telt alleen mee als je jezelf verbetert.'**
  String get replayRule;

  /// No description provided for @xpToLevelResult.
  ///
  /// In nl, this message translates to:
  /// **'Nog {xpToNextLevel} XP tot level {level}'**
  String xpToLevelResult(Object xpToNextLevel, Object level);

  /// No description provided for @playTomorrowStreak.
  ///
  /// In nl, this message translates to:
  /// **'Speel morgen om je reeks te houden'**
  String get playTomorrowStreak;

  /// No description provided for @keepScoreXp.
  ///
  /// In nl, this message translates to:
  /// **'Bewaar je score, {previewXp} XP en je reeks'**
  String keepScoreXp(Object previewXp);

  /// No description provided for @keepScoreBody.
  ///
  /// In nl, this message translates to:
  /// **'Log in of maak een gratis account, dan wordt deze score direct bijgeschreven. Je quizzen tellen dan mee voor je niveau en de ranglijst.'**
  String get keepScoreBody;

  /// No description provided for @yourAnswers.
  ///
  /// In nl, this message translates to:
  /// **'Jouw antwoorden'**
  String get yourAnswers;

  /// No description provided for @allCorrectReview.
  ///
  /// In nl, this message translates to:
  /// **'Alles goed. Bekijk de uitleg bij elke vraag.'**
  String get allCorrectReview;

  /// No description provided for @wrongOf.
  ///
  /// In nl, this message translates to:
  /// **'{wrongCount} van de {questionsCount} vragen fout.'**
  String wrongOf(Object wrongCount, Object questionsCount);

  /// No description provided for @fullExplainPremium.
  ///
  /// In nl, this message translates to:
  /// **'De volledige uitleg bij elke vraag is onderdeel van Premium.'**
  String get fullExplainPremium;

  /// No description provided for @unlockFullReview.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendel de volledige review'**
  String get unlockFullReview;

  /// No description provided for @correct.
  ///
  /// In nl, this message translates to:
  /// **'Goed'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In nl, this message translates to:
  /// **'Fout'**
  String get wrong;

  /// No description provided for @correctAnswerIs.
  ///
  /// In nl, this message translates to:
  /// **'Goed antwoord: {text}'**
  String correctAnswerIs(Object text);

  /// No description provided for @quizLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Quiz kon niet laden'**
  String get quizLoadFailed;

  /// No description provided for @howToPlay.
  ///
  /// In nl, this message translates to:
  /// **'Hoe wil je spelen?'**
  String get howToPlay;

  /// No description provided for @rememberedNext.
  ///
  /// In nl, this message translates to:
  /// **'Wordt onthouden voor je volgende quizzen, ook op de website.'**
  String get rememberedNext;

  /// No description provided for @freeLeftPrefix.
  ///
  /// In nl, this message translates to:
  /// **'Nog '**
  String get freeLeftPrefix;

  /// No description provided for @freeLeftOne.
  ///
  /// In nl, this message translates to:
  /// **' gratis quiz'**
  String get freeLeftOne;

  /// No description provided for @freeLeftMany.
  ///
  /// In nl, this message translates to:
  /// **' gratis quizzen'**
  String get freeLeftMany;

  /// No description provided for @unlockWithPremium.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendel met Premium'**
  String get unlockWithPremium;

  /// No description provided for @readAndStart.
  ///
  /// In nl, this message translates to:
  /// **'Lees {label} en start'**
  String readAndStart(Object label);

  /// No description provided for @startQuiz.
  ///
  /// In nl, this message translates to:
  /// **'Start quiz'**
  String get startQuiz;

  /// No description provided for @readFirstLabel.
  ///
  /// In nl, this message translates to:
  /// **'Lees eerst {label}'**
  String readFirstLabel(Object label);

  /// No description provided for @alreadyPlayed.
  ///
  /// In nl, this message translates to:
  /// **'Al gespeeld'**
  String get alreadyPlayed;

  /// No description provided for @playAgainBetter.
  ///
  /// In nl, this message translates to:
  /// **'Speel opnieuw voor een betere score'**
  String get playAgainBetter;

  /// No description provided for @yourBestScore.
  ///
  /// In nl, this message translates to:
  /// **'Jouw beste score'**
  String get yourBestScore;

  /// No description provided for @lastPlayed.
  ///
  /// In nl, this message translates to:
  /// **'Laatst gespeeld {last}'**
  String lastPlayed(Object last);

  /// No description provided for @testKnowledge.
  ///
  /// In nl, this message translates to:
  /// **'Test je kennis over dit onderwerp.'**
  String get testKnowledge;

  /// No description provided for @aboutQuiz.
  ///
  /// In nl, this message translates to:
  /// **'Over deze quiz'**
  String get aboutQuiz;

  /// No description provided for @finished.
  ///
  /// In nl, this message translates to:
  /// **'Afgerond'**
  String get finished;

  /// No description provided for @readChapterExplain.
  ///
  /// In nl, this message translates to:
  /// **'Je leest het hoofdstuk waar deze quiz over gaat voordat de vragen beginnen.'**
  String get readChapterExplain;

  /// No description provided for @timePerQuestion.
  ///
  /// In nl, this message translates to:
  /// **'Tijd per vraag'**
  String get timePerQuestion;

  /// No description provided for @timerExplain.
  ///
  /// In nl, this message translates to:
  /// **'Standaard uit. Zet een klok aan als je jezelf wilt uitdagen.'**
  String get timerExplain;

  /// No description provided for @off.
  ///
  /// In nl, this message translates to:
  /// **'Uit'**
  String get off;

  /// No description provided for @noChapterToRead.
  ///
  /// In nl, this message translates to:
  /// **'Geen hoofdstuk om te lezen'**
  String get noChapterToRead;

  /// No description provided for @multiChapter.
  ///
  /// In nl, this message translates to:
  /// **'Deze quiz gaat over meer dan een hoofdstuk. Je kunt gewoon met de quiz beginnen.'**
  String get multiChapter;

  /// No description provided for @chapterFetchFailed.
  ///
  /// In nl, this message translates to:
  /// **'Dit hoofdstuk kon nu niet opgehaald worden. Je kunt gewoon met de quiz beginnen.'**
  String get chapterFetchFailed;

  /// No description provided for @readFirst.
  ///
  /// In nl, this message translates to:
  /// **'Lees eerst'**
  String get readFirst;

  /// No description provided for @readBeforeQuiz.
  ///
  /// In nl, this message translates to:
  /// **'Lees voor de quiz {title}'**
  String readBeforeQuiz(Object title);

  /// No description provided for @bibleVersionName.
  ///
  /// In nl, this message translates to:
  /// **'Statenvertaling'**
  String get bibleVersionName;

  /// No description provided for @keepStreakQuestion.
  ///
  /// In nl, this message translates to:
  /// **'Je reeks vasthouden?'**
  String get keepStreakQuestion;

  /// No description provided for @keepStreakBody.
  ///
  /// In nl, this message translates to:
  /// **'Je hebt {streak} dagen op rij gespeeld. Zullen we je om 19:00 een seintje geven op een dag dat je nog niet gespeeld hebt?'**
  String keepStreakBody(Object streak);

  /// No description provided for @noQuestionsYet.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen vragen'**
  String get noQuestionsYet;

  /// No description provided for @quizNoQuestions.
  ///
  /// In nl, this message translates to:
  /// **'Deze quiz heeft nog geen vragen.'**
  String get quizNoQuestions;

  /// No description provided for @goBack.
  ///
  /// In nl, this message translates to:
  /// **'Ga terug'**
  String get goBack;

  /// No description provided for @today.
  ///
  /// In nl, this message translates to:
  /// **'vandaag'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In nl, this message translates to:
  /// **'gisteren'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In nl, this message translates to:
  /// **'{days} dagen geleden'**
  String daysAgo(Object days);

  /// No description provided for @onDate.
  ///
  /// In nl, this message translates to:
  /// **'op {date}'**
  String onDate(Object date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'nl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
