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
