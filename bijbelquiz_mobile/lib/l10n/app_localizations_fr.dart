// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'un quiz biblique';

  @override
  String inviteJoin(String title, String brand) {
    return 'Tu participes à $title sur $brand ?';
  }

  @override
  String inviteCode(String code) {
    return 'Ou saisis le code : $code';
  }

  @override
  String get errGenericTitle => 'Une erreur est survenue';

  @override
  String get errGenericMessage =>
      'Nous n\'avons pas pu terminer. Réessaie dans un instant.';

  @override
  String get errNetworkTitle => 'Pas de connexion';

  @override
  String get errNetworkMessage => 'Vérifie ta connexion internet et réessaie.';

  @override
  String get errSignedOutTitle => 'Reconnecte-toi';

  @override
  String get errSignedOutMessage =>
      'Ta session a expiré. Reconnecte-toi pour continuer à jouer.';

  @override
  String get errRoomNotFoundTitle => 'Salle introuvable';

  @override
  String get errRoomNotFoundMessage =>
      'Cette salle n\'existe plus ou est fermée. Vérifie le code ou crée toi-même une nouvelle salle.';

  @override
  String get errRoomFullTitle => 'La salle est pleine';

  @override
  String get errRoomFullMessage =>
      'Cette salle est complète. Demande à l\'hôte d\'ouvrir une nouvelle salle.';

  @override
  String get errRoomStartedTitle => 'La partie a déjà commencé';

  @override
  String get errRoomStartedMessage =>
      'Ce quiz est déjà en cours. Attends la fin de la manche ou crée une nouvelle salle.';

  @override
  String get errRoomFinishedTitle => 'La partie est terminée';

  @override
  String get errRoomFinishedMessage =>
      'Cette salle est fermée. Crée une nouvelle salle pour continuer à jouer.';

  @override
  String get errRoomCodeTitle => 'Code de salle invalide';

  @override
  String get errRoomCodeMessage =>
      'Ce code n\'est pas bon. Un code de salle compte 6 caractères.';

  @override
  String get errAlreadyInRoomTitle => 'Tu es déjà dans cette salle';

  @override
  String get errAlreadyInRoomMessage =>
      'Retourne dans la salle pour continuer à jouer.';

  @override
  String get errPremiumTitle => 'Premium requis';

  @override
  String get errPremiumMessage =>
      'Héberger ta propre salle fait partie de Bible Quizzes Premium. Rejoindre une partie est toujours gratuit.';

  @override
  String get errForbiddenTitle => 'Accès refusé';

  @override
  String get errForbiddenMessage => 'Seul l\'hôte peut faire cela.';

  @override
  String get errRateLimitedTitle => 'Un instant';

  @override
  String get errRateLimitedMessage =>
      'Tu as essayé trop de fois d\'affilée. Attends un instant et réessaie.';

  @override
  String get errNotFoundTitle => 'Introuvable';

  @override
  String get errNotFoundMessage =>
      'Nous ne l\'avons pas trouvé. Reviens en arrière et réessaie.';

  @override
  String get errConflictTitle => 'Ce n\'est pas possible pour l\'instant';

  @override
  String get errConflictMessage =>
      'Cette action ne correspond pas à l\'état actuel de la partie. Actualise et réessaie.';

  @override
  String get errServerTitle => 'Le serveur ne répond pas';

  @override
  String get errServerMessage =>
      'Un problème est survenu de notre côté. Réessaie dans quelques secondes.';

  @override
  String get errLiveLostTitle => 'Connexion en direct perdue';

  @override
  String get errLiveLostMessage =>
      'La connexion en direct a été coupée. Nous récupérons l\'état automatiquement.';

  @override
  String get errLoginTitle => 'Échec de la connexion';

  @override
  String get errLoginBadCredentials =>
      'Cette adresse e-mail ou ce mot de passe est incorrect.';

  @override
  String get errAccountExistsTitle => 'Le compte existe déjà';

  @override
  String get errAccountExistsMessage =>
      'Un compte existe déjà avec cette adresse e-mail. Connecte-toi.';

  @override
  String get errRegisterTitle => 'Échec de l\'inscription';

  @override
  String get errRegisterMessage =>
      'Nous n\'avons pas pu créer ton compte. Réessaie.';

  @override
  String get errLoginMessage => 'Nous n\'avons pas pu te connecter. Réessaie.';

  @override
  String get errLeaderboardTitle => 'Le classement n\'a pas chargé';

  @override
  String get errLeaderboardMessage =>
      'Nous n\'avons pas pu charger le classement. Réessaie.';

  @override
  String get errQuizzesTitle => 'Les quiz n\'ont pas chargé';

  @override
  String get errQuizzesMessage =>
      'Nous n\'avons pas pu charger les quiz. Réessaie.';

  @override
  String get errProfileTitle => 'Le profil n\'a pas chargé';

  @override
  String get errProfileMessage =>
      'Nous n\'avons pas pu charger ton profil. Réessaie.';

  @override
  String get errPurchaseTitle => 'Échec de l\'achat';

  @override
  String get errPurchaseMessage =>
      'L\'achat n\'a pas abouti. Rien ne t\'a été facturé.';

  @override
  String get streakReminderTitle => 'Ta série est en jeu';

  @override
  String get streakReminderChannel => 'Rappel de série';

  @override
  String get streakReminderChannelDescription =>
      'Un rappel le soir où ta série risque de se terminer.';

  @override
  String streakReminderBody(Object streak) {
    return 'Ta série de $streak jours se termine ce soir. Un quiz suffit pour la garder.';
  }

  @override
  String get navQuizzes => 'Quiz';

  @override
  String get navTogether => 'Ensemble';

  @override
  String get navLeaderboard => 'Classement';

  @override
  String get navProfile => 'Profil';

  @override
  String get savedQuizFallback => 'ton quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Ton score pour « $title » a été enregistré (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved quiz enregistrés (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Progression enregistrée';

  @override
  String get navHome => 'Accueil';

  @override
  String get avatarLamb => 'Agneau';

  @override
  String get avatarLion => 'Lion';

  @override
  String get avatarDove => 'Colombe';

  @override
  String get avatarOwl => 'Hibou';

  @override
  String get avatarDeer => 'Cerf';

  @override
  String get avatarOx => 'Bœuf';

  @override
  String get avatarSand => 'Sable';

  @override
  String get avatarLapis => 'Lapis';

  @override
  String get avatarClay => 'Argile';

  @override
  String get avatarOlive => 'Olive';

  @override
  String get avatarRose => 'Rose';

  @override
  String get avatarSlate => 'Ardoise';

  @override
  String get avatarParchment => 'Parchemin';

  @override
  String get avatarSky => 'Ciel';

  @override
  String get avatarSage => 'Sauge';

  @override
  String get avatarSunrise => 'Lever du soleil';

  @override
  String get avatarNight => 'Nuit';

  @override
  String get avatarBlush => 'Rose poudré';

  @override
  String get avatarNone => 'Aucun';

  @override
  String get avatarGlasses => 'Lunettes';

  @override
  String get avatarCap => 'Casquette';

  @override
  String get avatarScarf => 'Écharpe';

  @override
  String get avatarCrown => 'Couronne';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character avec $accessory';
  }

  @override
  String get wordmarkFirst => 'Bible';

  @override
  String get wordmarkSecond => 'Quizzes';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionBack => 'Retour';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount questions';
  }

  @override
  String get actionStart => 'Commencer';

  @override
  String get authGoogleAndroidInterrupted =>
      'La connexion Google a été interrompue sur Android. Vérifie le SHA-1/SHA-256 de la clé de publication dans le client OAuth Google Cloud.';

  @override
  String get authGoogleNoToken =>
      'Google n\'a renvoyé aucun jeton de connexion. Réessaie ou choisis un autre compte.';

  @override
  String get authAppleUnavailable =>
      'Se connecter avec Apple n\'est pas disponible sur cet appareil.';

  @override
  String get authAppleError1000 =>
      'La connexion avec Apple n\'a pas pu démarrer (erreur 1000). Vérifie qu\'un identifiant Apple est connecté sur cet appareil et réessaie.';

  @override
  String get authAppleWebNotConfigured =>
      'Se connecter avec Apple n\'est pas encore configuré sur cette plateforme.';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authLoginSubtitle =>
      'Connecte-toi pour garder ta progression et participer au classement.';

  @override
  String get authEmailHint => 'nom@exemple.fr';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordHint => 'Ton mot de passe';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authRegister => 'S\'inscrire';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateSubtitle => 'Gratuit, et ta progression est conservée.';

  @override
  String get authName => 'Nom';

  @override
  String get authNameHelp =>
      'C\'est ainsi que les autres te verront dans le classement et quand vous jouez ensemble.';

  @override
  String get authTermsPrefixRegister => 'En créant un compte, tu acceptes les ';

  @override
  String get authHaveAccount => 'Déjà un compte ?';

  @override
  String get splashTagline => 'Connais-tu bien la Bible ?';

  @override
  String get authOrEmail => 'ou par e-mail';

  @override
  String get authTermsPrefix => 'En continuant, tu acceptes les ';

  @override
  String get errLinkTitle => 'Le lien ne s\'est pas ouvert';

  @override
  String get errLinkMessage =>
      'Nous n\'avons pas pu ouvrir cette page. Réessaie.';

  @override
  String get authTermsAnd => ' et la ';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get dataInfoTitle => 'Comment nous traitons tes données';

  @override
  String get dataInfoBody =>
      'Lors de la connexion ou de l\'inscription, nous n\'utilisons que les données nécessaires au fonctionnement de ton compte, comme ton nom, ton adresse e-mail et tes identifiants.\n\nTes données transitent par des connexions sécurisées et nous ne les partageons pas à des fins publicitaires sans ton accord.\n\nTu peux toujours faire supprimer ton compte. Écris-nous à info@biblequizzes.app ou passe par les canaux d\'assistance de l\'app. Après suppression, les données de ton compte sont effacées conformément à notre politique de confidentialité.';

  @override
  String get dataInfoMore => 'En savoir plus sur l\'utilisation des données';

  @override
  String get homeContinue => 'Continuer à jouer';

  @override
  String get homeAll => 'Tout';

  @override
  String get homePickTopic => 'Choisis un thème';

  @override
  String get homePopular => 'Quiz populaires';

  @override
  String get streakOneDay => 'Série de 1 jour';

  @override
  String streakDays(Object streak) {
    return 'Série de $streak jours';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count questions';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz du jour : $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ DU JOUR';

  @override
  String get actionUnlock => 'Débloquer';

  @override
  String get actionPlayNow => 'Jouer';

  @override
  String get homeChallengeLoading =>
      'Un nouveau défi apparaît une fois les quiz chargés.';

  @override
  String get homeLoadFailed => 'L\'accueil n\'a pas chargé';

  @override
  String get checkConnectionRetry => 'Vérifie ta connexion et réessaie.';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get homeGuestTitle => 'Joue gratuitement, sans compte';

  @override
  String get homeGuestBody =>
      'Crées-en un pour garder ton score, tes points et ta série.';

  @override
  String get homeGuestAction => 'Garder ma progression';

  @override
  String chapterN(Object chapter) {
    return 'Chapitre $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText juste(s)';
  }

  @override
  String get played => 'Joué';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score sur $total justes';
  }

  @override
  String get books39 => '39 livres';

  @override
  String get books27 => '27 livres';

  @override
  String get catGeneral => 'Général';

  @override
  String get catWholeBible => 'Toute la Bible';

  @override
  String get catByTheme => 'Par thème';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount questions';
  }

  @override
  String get groupsLoadFailed => 'Impossible de charger tes groupes.';

  @override
  String get groupSaveFailed => 'L\'enregistrement du groupe a échoué.';

  @override
  String get groupSaveFailedTitle => 'Échec de l\'enregistrement du groupe';

  @override
  String get groupSaveNoGroup =>
      'Le serveur n\'a renvoyé aucun groupe. Réessaie.';

  @override
  String get groupRenameFailed => 'Le renommage a échoué.';

  @override
  String get deleteFailed => 'La suppression a échoué.';

  @override
  String get groupStandingsFailed =>
      'Impossible de charger le classement de ce groupe.';

  @override
  String get groupsTitle => 'Groupes';

  @override
  String get groupSingular => 'Groupe';

  @override
  String get leaderboardLoadFailed => 'Le classement n\'a pas chargé';

  @override
  String get leaderboardMonthHint => 'XP des 30 derniers jours';

  @override
  String get leaderboardAllTimeHint => 'Toute l\'XP depuis le début compte';

  @override
  String get periodMonth => 'Ce mois-ci';

  @override
  String get periodAllTime => 'Depuis toujours';

  @override
  String get periodLabel => 'Période';

  @override
  String get everyone => 'Tout le monde';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return 'Encore $gap XP pour la place $rank';
  }

  @override
  String get showLess => 'Afficher moins';

  @override
  String showAllPlayers(Object total) {
    return 'Afficher les $total joueurs';
  }

  @override
  String get leaderboardGuestHint => 'Avec un compte gratuit, ton XP compte.';

  @override
  String get leaderboardNotOnIt => 'Tu n\'es pas encore dans ce classement';

  @override
  String get leaderboardPlayToJoin => 'Joue un quiz pour participer.';

  @override
  String get leaderboardNoData => 'Pas encore de données de classement.';

  @override
  String get leaderboardEmpty => 'Personne dans le classement pour l\'instant';

  @override
  String get onboardingTagline =>
      'De courts quiz sur les livres de la Bible, seul ou avec d\'autres.';

  @override
  String get onboardingGuest => 'Jouer d\'abord sans compte';

  @override
  String get onboardingPreviewA11y =>
      'Exemple : une question avec la bonne réponse, un duel contre Sarah, de l\'XP et une série';

  @override
  String get onboardingSampleQuestion =>
      'Combien de pains le garçon avait-il ?';

  @override
  String get onboardingSampleStreak => '6 jours d\'affilée';

  @override
  String get seasonEndsToday => 'Se termine aujourd\'hui';

  @override
  String get seasonOneDayLeft => 'Encore 1 jour';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return 'Encore $daysRemaining jours';
  }

  @override
  String get season => 'Saison';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get viaWebsite => 'Via le site web';

  @override
  String get lifetime => 'À vie';

  @override
  String get active => 'Actif';

  @override
  String get deleteSignInFirst =>
      'Connecte-toi d\'abord avec le compte que tu veux supprimer.';

  @override
  String get deleteAccountQuestion => 'Supprimer le compte ?';

  @override
  String get deleteAccountBody =>
      'Ton compte, ta progression, ton XP et tes duels seront supprimés définitivement. C\'est irréversible.\n\nUn abonnement via l\'App Store ou Google Play ne s\'arrête pas pour autant : résilie-le d\'abord dans les abonnements de ton téléphone.';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'La suppression a échoué. Réessaie ou écris à $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Compte non supprimé';

  @override
  String get accountDeleted => 'Ton compte a été supprimé.';

  @override
  String get notificationsOff =>
      'Les notifications sont désactivées pour Bible Quizzes. Active-les dans les réglages de ton téléphone.';

  @override
  String get purchasesRestored => 'Achats restaurés';

  @override
  String get settingsReminder => 'Rappel';

  @override
  String get settingsTime => 'Heure';

  @override
  String get settingsPlaying => 'Jeu';

  @override
  String get settingsReadChapterFirst => 'Lire d\'abord le chapitre';

  @override
  String get settingsShowReference => 'Référence biblique dans l\'explication';

  @override
  String get settingsLargeText => 'Texte des questions en grand';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get settingsManage => 'Gérer';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get guestPlaying => 'Tu joues sans compte';

  @override
  String get signInOrCreate => 'Se connecter ou créer un compte';

  @override
  String get yourAccount => 'Ton compte';

  @override
  String get signedIn => 'Connecté';

  @override
  String signedInAs(Object email) {
    return 'Connecté en tant que $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice secondes';
  }
}
