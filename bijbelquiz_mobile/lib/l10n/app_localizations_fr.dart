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

  @override
  String get joinFailed => 'Impossible de rejoindre.';

  @override
  String get joinFailedConnection =>
      'Impossible de rejoindre. Vérifie ta connexion.';

  @override
  String get trialEndingTitle => 'Ton essai se termine bientôt';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Ton Bible Quizzes Premium commence dans $kTrialReminderDaysBeforeEnd jours. Tu ne veux pas continuer ? Résilie dans les réglages du store.';
  }

  @override
  String get trialReminderChannel => 'Rappel d\'essai';

  @override
  String get trialReminderChannelDescription =>
      'Un rappel avant la fin de ton essai gratuit.';

  @override
  String get supportEmail => 'info@biblequizzes.app';

  @override
  String get groupCodeIncomplete => 'Saisis le code de groupe complet.';

  @override
  String groupJoined(Object name) {
    return 'Tu fais maintenant partie de $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Va sur biblequizzes.app/group-license dans ton navigateur.';

  @override
  String get groupLicense => 'Licence de groupe';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Écris-nous à $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      'Ton animateur, pasteur ou professeur a un code de groupe ? Saisis-le ci-dessous et tu as Premium tout de suite.';

  @override
  String get premiumViaGroup => 'Premium via ton groupe';

  @override
  String get yourGroups => 'Tes groupes';

  @override
  String get premiumWholeGroup => 'Premium pour tout ton groupe';

  @override
  String get forChurches => 'Pour les églises, écoles et associations';

  @override
  String get groupPerkAll => 'Tout Premium pour chaque membre';

  @override
  String get groupPerkCode => 'Un code que tu lis à voix haute dans la salle';

  @override
  String get groupPerkManage => 'Tu décides qui participe';

  @override
  String get groupLicenseWebsiteOnly =>
      'La licence de groupe s\'achète sur le site, car un achat sur l\'App Store est lié à un seul compte et non à un groupe.';

  @override
  String get openWebsite => 'Ouvrir biblequizzes.app';

  @override
  String get youManageGroup => 'Tu gères ce groupe';

  @override
  String get youTakePart => 'Tu participes';

  @override
  String get groupCode => 'Code de groupe';

  @override
  String get purchaseReceivedNotActive =>
      'Ton achat est bien reçu, mais Premium n\'est pas encore actif. Appuie sur « Restaurer » dans une minute.';

  @override
  String noPurchaseFound(Object storeName) {
    return 'Aucun achat Premium trouvé sur ce compte $storeName.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Ton achat attend encore une validation ou un paiement. Premium s\'activera tout seul dès que $storeName l\'aura finalisé.';
  }

  @override
  String get noInternetRetry =>
      'Pas de connexion internet. Vérifie ta connexion et réessaie.';

  @override
  String get alreadyPurchased =>
      'Tu l\'as déjà acheté. Appuie sur « Restaurer » pour le récupérer.';

  @override
  String get purchaseOtherAccount =>
      'Cet achat appartient déjà à un autre compte Bible Quizzes. Connecte-toi avec ce compte pour utiliser ton Premium.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'Les achats ne sont pas autorisés sur cet appareil. Vérifie les réglages de ton compte $store.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'Cet abonnement n\'est pas disponible sur $store pour le moment. Réessaie plus tard.';
  }

  @override
  String storeError(Object store) {
    return '$store a renvoyé une erreur. Réessaie plus tard.';
  }

  @override
  String get purchasesNotInVersion =>
      'Les achats ne sont pas disponibles dans cette version de l\'app.';

  @override
  String get restoreFailed => 'La restauration a échoué. Réessaie.';

  @override
  String get introPerkExplain =>
      'Une explication pour chaque question : pourquoi la réponse est juste';

  @override
  String get introPerkAll => 'Tous les quiz, autant que tu veux';

  @override
  String get introPerkReview => 'Un bilan complet après chaque quiz';

  @override
  String get introPerkDaily => 'Un nouveau quiz chaque jour, sans limite';

  @override
  String get introPerkStick =>
      'Une explication pour chaque question, pour que ça reste';

  @override
  String get introPerkLookBack => 'Revois tes réponses après chaque quiz';

  @override
  String get introPerkTogetherFree => 'Jouer ensemble reste gratuit pour tous';

  @override
  String get introPerkSoloUnlimited => 'En plus, jeu en solo illimité';

  @override
  String get introPerkDiscuss =>
      'Une explication pour chaque question à discuter ensemble';

  @override
  String stepOfThree(Object page) {
    return 'Étape $page sur 3';
  }

  @override
  String get actionNext => 'Suivant';

  @override
  String get introGrowQuestion => 'Dans quoi veux-tu progresser ?';

  @override
  String get introGrowSubtitle =>
      'Nous te montrerons ce que Premium fait pour cela.';

  @override
  String get introGoalKnowledge => 'Mieux connaître la Bible';

  @override
  String get introGoalKnowledgeBody =>
      'Comprendre pourquoi une réponse est juste.';

  @override
  String get introGoalDaily => 'Apprendre chaque jour';

  @override
  String get introGoalDailyBody => 'Prendre une habitude et la garder.';

  @override
  String get introGoalGroupBody =>
      'En famille ou en groupe, les uns contre les autres.';

  @override
  String get introYouGet => 'Voici ce que tu obtiens';

  @override
  String get introOneMembership =>
      'Tout dans un seul abonnement, sur le web et l\'app.';

  @override
  String get choosePlan => 'Choisis ton offre';

  @override
  String get pricesNextPage =>
      'Tu verras les prix à la page suivante. Résiliation possible à tout moment.';

  @override
  String get accountWebAndApp =>
      'Ton compte fonctionne à la fois sur le web et dans l\'app. Un achat sur ton téléphone te donne aussi Premium sur le site, et inversement.';

  @override
  String get paywallHeadlineDefault => 'Joue sans limite\navec Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'Tu as joué tes\n$kFreeQuizLimit quiz gratuits';
  }

  @override
  String get paywallHeadlineTogether =>
      'Continuez à jouer ensemble\nsans limite';

  @override
  String get paywallHeadlineGroup => 'Joue avec tout\nton groupe';

  @override
  String get paywallHeadlineExplain => 'Lis le pourquoi\nde chaque question';

  @override
  String get paywallHeadlineUnlock => 'Débloque\ntous les quiz';

  @override
  String get premiumRestored => 'Premium restauré';

  @override
  String get welcomePremium => 'Bienvenue dans Premium';

  @override
  String get premiumBackOn => 'Ton Premium est réactivé sur ce compte.';

  @override
  String get premiumFullAccess =>
      'Tu as maintenant accès à toutes les fonctions Premium, dans l\'app et sur le site. Amuse-toi bien !';

  @override
  String get playOnPremium => 'Continue à jouer avec Premium.';

  @override
  String get chooseSubscription => 'Choisis un abonnement';

  @override
  String get yearly => 'Annuel';

  @override
  String get perYear => 'par an';

  @override
  String get monthly => 'Mensuel';

  @override
  String get perMonth => 'par mois';

  @override
  String get noTrial => 'Sans essai';

  @override
  String get reloadPrices => 'Recharger les prix';

  @override
  String storeUnreachable(Object storeName) {
    return '$storeName est injoignable pour le moment. Vérifie ta connexion.';
  }

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get terms => 'Conditions';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get alreadyPremium =>
      'Tu as déjà Premium sur ce compte. Rien n\'a été débité.';

  @override
  String get premiumOn => 'Premium est actif';

  @override
  String get restoreSignIn =>
      'Connecte-toi à ton compte et nous y restaurerons tes achats.';

  @override
  String get needAccountForPremium =>
      'Crée d\'abord un compte gratuit ou connecte-toi, pour que Premium t\'appartienne - dans l\'app et sur le site.';

  @override
  String get accountNeeded => 'Compte requis';

  @override
  String get pleaseWait => 'Patiente un peu';

  @override
  String get nothingToRestore => 'Rien à restaurer';

  @override
  String get viewAllPlans => 'Voir toutes les offres';

  @override
  String get explainEveryAnswer => 'Une explication pour chaque réponse';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'Gratuitement, tu joues $kFreeQuizLimit quiz. Avec Premium, tous les livres de la Bible s\'ouvrent, y compris les Psaumes et l\'Apocalypse.';
  }

  @override
  String get premiumEverythingOpen => 'Tout ouvert avec Premium';

  @override
  String get abbrGenesis => 'Gn';

  @override
  String get quizzes12 => '12 quiz';

  @override
  String get abbrPsalms => 'Ps';

  @override
  String get quizzes15 => '15 quiz';

  @override
  String get abbrRevelation => 'Ap';

  @override
  String get bookRevelation => 'Apocalypse';

  @override
  String get quizzes9 => '9 quiz';

  @override
  String get free => 'Gratuit';

  @override
  String get orLifetime => 'Ou en une fois : Premium à vie';

  @override
  String lifetimeOnce(Object price) {
    return 'Premium à vie, $price une fois';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly par semaine sur $lifetimeHorizonYears ans';
  }

  @override
  String get lifetimePremium => 'Premium à vie';

  @override
  String get payNothingToday => 'Tu ne paies rien aujourd\'hui.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'Tu ne paies rien aujourd\'hui. Rappel le jour $day.';
  }

  @override
  String get cancelAnytime => 'Résilie quand tu veux.';

  @override
  String get payOnceNoSub => 'Paiement unique, sans abonnement.';

  @override
  String get startPremium => 'Démarrer Premium';

  @override
  String tryTrial(Object label) {
    return 'Essaie $label';
  }

  @override
  String get badgeFirstStepsDesc => 'Termine ton premier quiz.';

  @override
  String get badgeKnowledgeSeeker => 'Chercheur de savoir';

  @override
  String get badgeKnowledgeSeekerDesc => 'Joue 10 quiz différents.';

  @override
  String get badgePerfect => 'Sans faute';

  @override
  String get badgePerfectDesc => 'Obtiens 100 % à un quiz.';

  @override
  String get badgeOnARoll => 'Sur une lancée';

  @override
  String get badgeOnARollDesc => 'Fais une série de 3 jours.';

  @override
  String get badgeDedicated => 'Assidu';

  @override
  String get badgeDedicatedDesc => 'Joue 7 jours d\'affilée.';

  @override
  String get badgeScholar => 'Érudit';

  @override
  String get badgeMaster => 'Maître';

  @override
  String get badgeAllRounder => 'Polyvalent';

  @override
  String get badgeAllRounderDesc => 'Joue une grande variété de quiz.';

  @override
  String get rankSeeker => 'Chercheur';

  @override
  String get saveFailed => 'L\'enregistrement a échoué. Réessaie.';

  @override
  String get saveFailedConnection =>
      'L\'enregistrement a échoué. Vérifie ta connexion.';

  @override
  String get achievements => 'Succès';

  @override
  String get achievementsLoadFailed => 'Les succès n\'ont pas chargé';

  @override
  String get noBadgesYet =>
      'Pas encore de badge. Joue des quiz pour débloquer ton premier.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'À obtenir · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked badges sur $total obtenus';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked badges sur $total';
  }

  @override
  String get allEarned => 'Tout obtenu';

  @override
  String leftToEarn(Object left) {
    return 'Encore $left';
  }

  @override
  String get profileUpdated => 'Profil mis à jour.';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profileLoadFailed => 'Le profil n\'a pas chargé';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get surpriseMe => 'Surprends-moi';

  @override
  String get displayName => 'Nom affiché';

  @override
  String get displayNameHint => 'Comment tu apparais dans le classement';

  @override
  String get displayNameHelp =>
      'Visible dans le classement et en multijoueur. Modifiable une fois tous les 30 jours.';

  @override
  String get buildMascot => 'Compose ta mascotte';

  @override
  String get figure => 'Personnage';

  @override
  String get color => 'Couleur';

  @override
  String get background => 'Arrière-plan';

  @override
  String get accessory => 'Accessoire';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get settings => 'Réglages';

  @override
  String get statistics => 'Statistiques';

  @override
  String get recentlyPlayed => 'Joué récemment';

  @override
  String levelN(Object level) {
    return 'Niveau $level';
  }

  @override
  String get maxLevel => 'Niveau maximal atteint';

  @override
  String progressToLevel(Object level) {
    return 'Progression vers le niveau $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return 'Encore $xpRemaining XP pour le niveau $level';
  }

  @override
  String get daysInARow => 'Jours d\'affilée';

  @override
  String get quizzesPlayed => 'Quiz joués';

  @override
  String get averageScore => 'Score moyen';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'Voir tous les succès, $unlockedCount sur $overviewCount obtenus';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'Tous $unlockedCount sur $overviewCount';
  }

  @override
  String get youHavePremium => 'Tu as Premium';

  @override
  String get youPlayFree => 'Tu joues gratuitement';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score sur $totalQuestions justes';
  }

  @override
  String get completed => 'Terminé';

  @override
  String get guestPerkKeep => 'Des points, un niveau et une série qui restent';

  @override
  String get guestPerkLeaderboard => 'Une place dans le classement';

  @override
  String get guestPerkBadges => 'Des badges pour tes succès';

  @override
  String get guestPerkWebsite => 'La même progression sur biblequizzes.app';

  @override
  String get saveYourProgress => 'Garde ta progression';

  @override
  String get guestExplain =>
      'Tu joues sans compte. C\'est possible, mais ton score, tes points et ta série ne sont conservés qu\'avec un compte gratuit.';

  @override
  String get createFreeAccount => 'Créer un compte gratuit';

  @override
  String get pendingOne => 'Un quiz attend ton compte';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount quiz attendent ton compte';
  }

  @override
  String get withAccount => 'Avec un compte';

  @override
  String get oneQuiz => '1 quiz';

  @override
  String quizzesN(Object total) {
    return '$total quiz';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played sur $total joués';
  }

  @override
  String get quizzesLoadFailed => 'Les quiz n\'ont pas chargé';

  @override
  String get byBibleBook => 'Par livre de la Bible';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount livres · $quizzes quiz';
  }

  @override
  String get bibleBook => 'Livre de la Bible';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount quiz';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played sur $quizzesCount joués';
  }

  @override
  String get noQuizzesForBook => 'Il n\'y a pas encore de quiz sur ce livre.';

  @override
  String allQuizzesAbout(Object name) {
    return 'Tous les quiz sur $name';
  }

  @override
  String get startWith => 'COMMENCE PAR';

  @override
  String get continueWith => 'CONTINUE AVEC';

  @override
  String get anyLevel => 'Tous niveaux';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get results => 'Résultats';

  @override
  String get allQuizzes => 'Tous les quiz';

  @override
  String get popular => 'Populaires';

  @override
  String get allBooks => 'Tous les livres';

  @override
  String get searchHint => 'Cherche un livre de la Bible ou un thème';

  @override
  String get clear => 'Effacer';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount questions · $questionCount2 min';
  }

  @override
  String get notPlayedYet => 'Pas encore joué';

  @override
  String get noQuizzesFilters => 'Aucun quiz trouvé avec ces filtres.';

  @override
  String get sortBibleOrder => 'Ordre biblique';

  @override
  String get sortMostPopular => 'Les plus populaires';

  @override
  String get sortNewest => 'Plus récents';

  @override
  String get sortShortest => 'Plus courts';

  @override
  String get sort => 'Trier';

  @override
  String get hideText => 'Masquer le texte';

  @override
  String hideTextOf(Object reference) {
    return 'Masquer le texte de $reference';
  }

  @override
  String get unlockPremiumExplain => 'Débloque Premium pour l\'explication';

  @override
  String get readWhyWrong => 'Lis pourquoi c\'était faux';

  @override
  String get timeUp => 'Temps écoulé';

  @override
  String get finishQuiz => 'Terminer le quiz';

  @override
  String get a11yYourAnswerRight => ', ta réponse, juste';

  @override
  String get a11yCorrectAnswer => ', la bonne réponse';

  @override
  String get a11yYourAnswerWrong => ', ta réponse, fausse';

  @override
  String questionOf(Object current, Object total) {
    return 'Question $current sur $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return 'Encore $secondsLeft secondes';
  }

  @override
  String get wellPlayed => 'Bien joué';

  @override
  String get niceTry => 'Bien essayé';

  @override
  String get nextQuiz => 'Quiz suivant';

  @override
  String get playWithOthers => 'Joue avec d\'autres';

  @override
  String get viewAnswers => 'Voir les réponses';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Score $correct sur $total';
  }

  @override
  String get newBestScore => 'Nouveau record';

  @override
  String get scoreNotSaved => 'Ton score n\'est pas encore enregistré';

  @override
  String get scoreSaving => 'Ton score est en cours d\'enregistrement';

  @override
  String get again => 'Rejouer';

  @override
  String get noExtraXp => 'Pas d\'XP en plus cette fois';

  @override
  String get replayRule => 'Rejouer ne compte que si tu améliores ton score.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return 'Encore $xpToNextLevel XP pour le niveau $level';
  }

  @override
  String get playTomorrowStreak => 'Joue demain pour garder ta série';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Garde ton score, $previewXp XP et ta série';
  }

  @override
  String get keepScoreBody =>
      'Connecte-toi ou crée un compte gratuit et ce score est ajouté tout de suite. Tes quiz comptent alors pour ton niveau et le classement.';

  @override
  String get yourAnswers => 'Tes réponses';

  @override
  String get allCorrectReview =>
      'Tout est juste. Consulte l\'explication de chaque question.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount questions sur $questionsCount fausses.';
  }

  @override
  String get fullExplainPremium =>
      'L\'explication complète de chaque question fait partie de Premium.';

  @override
  String get unlockFullReview => 'Débloque le bilan complet';

  @override
  String get correct => 'Juste';

  @override
  String get wrong => 'Faux';

  @override
  String correctAnswerIs(Object text) {
    return 'Bonne réponse : $text';
  }

  @override
  String get quizLoadFailed => 'Le quiz n\'a pas chargé';

  @override
  String get howToPlay => 'Comment veux-tu jouer ?';

  @override
  String get rememberedNext =>
      'Mémorisé pour tes prochains quiz, aussi sur le site.';

  @override
  String get freeLeftPrefix => 'Encore ';

  @override
  String get freeLeftOne => ' quiz gratuit';

  @override
  String get freeLeftMany => ' quiz gratuits';

  @override
  String get unlockWithPremium => 'Débloquer avec Premium';

  @override
  String readAndStart(Object label) {
    return 'Lis $label et commence';
  }

  @override
  String get startQuiz => 'Lancer le quiz';

  @override
  String readFirstLabel(Object label) {
    return 'Lis d\'abord $label';
  }

  @override
  String get alreadyPlayed => 'Déjà joué';

  @override
  String get playAgainBetter => 'Rejoue pour un meilleur score';

  @override
  String get yourBestScore => 'Ton meilleur score';

  @override
  String lastPlayed(Object last) {
    return 'Dernière partie $last';
  }

  @override
  String get testKnowledge => 'Teste tes connaissances sur ce thème.';

  @override
  String get aboutQuiz => 'À propos de ce quiz';

  @override
  String get finished => 'Terminé';

  @override
  String get readChapterExplain =>
      'Tu lis le chapitre du quiz avant que les questions commencent.';

  @override
  String get timePerQuestion => 'Temps par question';

  @override
  String get timerExplain =>
      'Désactivé par défaut. Active un chrono si tu veux un défi.';

  @override
  String get off => 'Désactivé';

  @override
  String get noChapterToRead => 'Pas de chapitre à lire';

  @override
  String get multiChapter =>
      'Ce quiz porte sur plus d\'un chapitre. Tu peux simplement commencer le quiz.';

  @override
  String get chapterFetchFailed =>
      'Ce chapitre n\'a pas pu être chargé. Tu peux simplement commencer le quiz.';

  @override
  String get readFirst => 'Lis d\'abord';

  @override
  String readBeforeQuiz(Object title) {
    return 'Lis avant le quiz $title';
  }

  @override
  String get bibleVersionName => 'Louis Segond 1910';

  @override
  String get keepStreakQuestion => 'Garder ta série ?';

  @override
  String keepStreakBody(Object streak) {
    return 'Tu as joué $streak jours d\'affilée. On te fait signe à 19 h les jours où tu n\'as pas encore joué ?';
  }

  @override
  String get noQuestionsYet => 'Pas encore de questions';

  @override
  String get quizNoQuestions => 'Ce quiz n\'a pas encore de questions.';

  @override
  String get goBack => 'Retour';

  @override
  String get today => 'aujourd\'hui';

  @override
  String get yesterday => 'hier';

  @override
  String daysAgo(Object days) {
    return 'il y a $days jours';
  }

  @override
  String onDate(Object date) {
    return 'le $date';
  }

  @override
  String get mpQuotaFailed => 'Impossible de charger ton quota de parties.';

  @override
  String get mpCreateFailed => 'Impossible de créer une salle.';

  @override
  String mpJoinFailed(Object code) {
    return 'Impossible de rejoindre la salle $code.';
  }

  @override
  String mpLoadFailed(Object code) {
    return 'Impossible de charger la salle $code.';
  }

  @override
  String get mpStartFailed => 'Impossible de lancer le quiz.';

  @override
  String get mpNextFailed => 'Impossible de passer à la question suivante.';

  @override
  String get mpAnswerFailed => 'Impossible d\'envoyer ta réponse.';

  @override
  String get mpResultsFailed => 'Impossible de charger les résultats.';

  @override
  String get unexpectedServerResponse => 'Réponse inattendue du serveur.';

  @override
  String get roomNotFoundDot => 'Salle introuvable.';

  @override
  String get playTogether => 'Jouer ensemble';

  @override
  String get backToPlayTogether => 'Retour à Jouer ensemble';

  @override
  String get stopQuiz => 'Arrêter le quiz';

  @override
  String get leaveGame => 'Quitter la partie';

  @override
  String get multiplayerQuiz => 'Quiz multijoueur';

  @override
  String roomCodeLabel(Object code) {
    return 'Salle $code';
  }

  @override
  String get waitingNextQuestion => 'En attente de la question suivante…';

  @override
  String get nextIn => 'Suivante dans ';

  @override
  String correctOfPlayers(Object correctCount, Object playersCount) {
    return '$correctCount sur $playersCount ont trouvé';
  }

  @override
  String get standings => 'Classement';

  @override
  String get stopQuizQuestion => 'Arrêter le quiz ?';

  @override
  String get stopQuizBody =>
      'Veux-tu arrêter ce quiz multijoueur pour tous les joueurs ?';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get stopQuizAction => 'Arrêter';

  @override
  String get leaveGameQuestion => 'Quitter la partie ?';

  @override
  String get leaveGameBody =>
      'Ton score est conservé si tu reviens via Jouer ensemble.';

  @override
  String get stay => 'Rester';

  @override
  String get leaveGameAction => 'Quitter';

  @override
  String questionNumberOf(Object number, Object total) {
    return 'Question $number sur $total';
  }

  @override
  String secondsRemaining(Object seconds) {
    return 'Encore $seconds secondes';
  }

  @override
  String nextQuestionIn(Object seconds) {
    return 'Question suivante dans $seconds secondes';
  }

  @override
  String get a11yYourAnswer => ', ta réponse';

  @override
  String get a11yRightAnswer => ', bonne réponse';

  @override
  String get a11yWrongShort => ', faux';

  @override
  String a11yChosenTimes(Object count) {
    return ', choisie $count fois';
  }

  @override
  String get noAnswerLower => 'pas de réponse';

  @override
  String get stillThinking => 'réfléchit encore';

  @override
  String get noAnswer => 'Pas de réponse';

  @override
  String get rightExclaim => 'Juste !';

  @override
  String get tooBad => 'Dommage';

  @override
  String get correctMarkedGreen => 'La bonne réponse est marquée en vert.';

  @override
  String get yourAnswerCorrect => 'Ta réponse est juste.';

  @override
  String get yourChoiceMarked =>
      'Ton choix est marqué à côté de la bonne réponse.';

  @override
  String pointsGained(Object gained) {
    return '+$gained points';
  }

  @override
  String get nextQuestion => 'Question suivante';

  @override
  String get hostMovingOn =>
      'L\'hôte va bientôt passer à la question suivante.';

  @override
  String get submitted => 'Envoyé';

  @override
  String get waitingOtherPlayers => 'En attente des autres joueurs…';

  @override
  String get hostSetsPace =>
      'Tu donnes le rythme. Affiche les réponses quand tout le monde a fini.';

  @override
  String get showAnswers => 'Afficher les réponses';

  @override
  String get startQuestions => 'Lancer les questions';

  @override
  String get waitHostQuestions => 'Attends que l\'hôte lance les questions.';

  @override
  String get waitingHostQuestions =>
      'En attente que l\'hôte lance les questions…';

  @override
  String readBeforeQuizMp(Object quizTitle) {
    return 'Lis avant le quiz $quizTitle';
  }

  @override
  String get readChapterCalmly =>
      'Prends le temps de lire ce chapitre. Les questions portent dessus, donc lire aide vraiment.';

  @override
  String get chapterNotLoaded => 'Le chapitre n\'a pas chargé';

  @override
  String get chapterFetchFailedHost =>
      'Ce chapitre n\'a pas pu être chargé. L\'hôte peut simplement lancer les questions.';

  @override
  String get lobby => 'Salle d\'attente';

  @override
  String get closeRoom => 'Fermer la salle';

  @override
  String get leaveRoom => 'Quitter la salle';

  @override
  String get closeRoomQuestion => 'Fermer la salle ?';

  @override
  String get leaveRoomQuestion => 'Quitter la salle ?';

  @override
  String get closeRoomBody =>
      'Si tu es seul, la salle ferme. S\'il y a déjà des joueurs, quelqu\'un d\'autre devient l\'hôte.';

  @override
  String get rejoinLater => 'Tu pourras revenir plus tard avec le même code.';

  @override
  String get closeRoomAction => 'Fermer';

  @override
  String get leaveRoomAction => 'Quitter';

  @override
  String get freeGamesUsed => 'Tes parties gratuites sont épuisées';

  @override
  String get premiumHostUnlimited =>
      'Avec Premium, tu héberges des parties illimitées, jusqu\'à 20 joueurs à la fois. Ton groupe attend simplement dans la salle.';

  @override
  String get newRoomCode => 'Tu recevras un nouveau code de salle.';

  @override
  String get startWhenEveryone => 'Lance le quiz quand tout le monde est là.';

  @override
  String get hostStartsWhenEveryone =>
      'L\'hôte lance le quiz quand tout le monde est là.';

  @override
  String get roomCodeCopied => 'Code de salle copié.';

  @override
  String get change => 'Modifier';

  @override
  String get players => 'Joueurs';

  @override
  String playersOfMax(Object playersCount, Object maxPlayers) {
    return '$playersCount sur $maxPlayers';
  }

  @override
  String get startTheQuiz => 'Lancer le quiz';

  @override
  String get oneQuestion => '1 question';

  @override
  String totalQuestionsN(Object totalQuestions) {
    return '$totalQuestions questions';
  }

  @override
  String secondsPerQuestion(Object questionTimerSeconds) {
    return '$questionTimerSeconds s par question';
  }

  @override
  String get hostSetsPaceShort => 'L\'hôte donne le rythme';

  @override
  String get readFirstShort => 'Lire d\'abord';

  @override
  String get joinMyQuizShareTitle => 'Rejoins ma partie Bible Quizzes';

  @override
  String get playersEnterCode =>
      'Les joueurs saisissent ce code dans Jouer ensemble';

  @override
  String get shareCode => 'Partager le code';

  @override
  String get copyCode => 'Copier le code';

  @override
  String get newPlayersAppear =>
      'Les nouveaux joueurs apparaissent ici automatiquement.';

  @override
  String get waitHostQuiz => 'Attends que l\'hôte lance le quiz.';

  @override
  String get quizCompleted => 'Quiz terminé';

  @override
  String get finalStandings => 'Classement final';

  @override
  String winnerWith(Object winner, Object score) {
    return 'Gagnant : $winner avec $score points';
  }

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String get startNewRoom => 'Créer une nouvelle salle';

  @override
  String groupSaved(Object savedGroupName) {
    return '« $savedGroupName » a été enregistré.';
  }

  @override
  String get groupStandingsOnLeaderboard =>
      'Tu trouveras le classement de ce groupe dans le classement.';

  @override
  String get saveGroupQuestion => 'Enregistrer ce groupe ?';

  @override
  String saveGroupBody(Object playersCount) {
    return 'Tu tiendras alors ton propre classement avec ces $playersCount joueurs et pourras les réinviter d\'un geste.';
  }

  @override
  String get saveGroup => 'Enregistrer le groupe';

  @override
  String placeNamePoints(Object place, Object name, Object score) {
    return '$place. $name, $score points';
  }

  @override
  String pointsN(Object score) {
    return '$score points';
  }

  @override
  String correctOfTotal(Object correctAnswers, Object totalQuestions) {
    return '$correctAnswers sur $totalQuestions justes';
  }

  @override
  String correctN(Object correctAnswers) {
    return '$correctAnswers justes';
  }

  @override
  String get roomReconnecting =>
      'Salle momentanément injoignable. Reconnexion...';

  @override
  String get roomClosedFinal =>
      'La salle est fermée. Voici le classement final.';

  @override
  String get roomGone =>
      'Cette salle n\'existe plus. Reviens en arrière et crée une nouvelle salle.';

  @override
  String get createRoom => 'Créer une salle';

  @override
  String get createRoomInvite => 'Créer la salle et inviter';

  @override
  String thenInviteGroup(Object name) {
    return 'Ensuite, nous inviterons $name.';
  }

  @override
  String get selectQuizFirst => 'Choisis d\'abord un quiz.';

  @override
  String get enterRoomCode => 'Saisis un code de salle.';

  @override
  String get roomCodeTooShort => 'Le code semble trop court. Vérifie-le.';

  @override
  String pickQuizThenInvite(Object name) {
    return 'Choisis d\'abord un quiz, puis nous inviterons $name.';
  }

  @override
  String get yourGroupsShort => 'Tes groupes';

  @override
  String get pickQuizInviteGroup =>
      'Choisis un quiz et envoie une nouvelle invitation à ton groupe d\'un geste.';

  @override
  String get signInToPlayTogether => 'Connecte-toi pour jouer ensemble';

  @override
  String get playTogetherNeedsAccount =>
      'Créer ou rejoindre une salle se fait avec un compte gratuit, pour que ton nom et ton score soient justes.';

  @override
  String get playTogetherIntro =>
      'Avec ta famille, tes amis ou ton groupe de jeunes : tout le monde joue au même quiz en même temps, chacun sur son téléphone.';

  @override
  String upToPlayers(Object maxPlayers) {
    return 'Jusqu\'à $maxPlayers joueurs par salle';
  }

  @override
  String get youAreHost => 'Tu es l\'hôte';

  @override
  String premiumHostRooms(Object maxPlayersPremium) {
    return 'Avec Premium, tu héberges des salles illimitées, jusqu\'à $maxPlayersPremium joueurs à la fois. Rejoindre avec un code reste toujours gratuit.';
  }

  @override
  String get viewPremium => 'Voir Premium';

  @override
  String get hostSteps =>
      'Choisis un quiz, partage le code avec ton groupe et lance quand tout le monde est là.';

  @override
  String get pickQuiz => 'Choisis un quiz';

  @override
  String get gameThisMonth => 'Ta partie du mois';

  @override
  String get lastFreeGame => 'Dernière partie gratuite';

  @override
  String freeGamesLeftN(Object remaining) {
    return 'Encore $remaining parties gratuites';
  }

  @override
  String get freeGameMonthly =>
      'C\'est ta partie gratuite du mois. Le mois prochain, tu en auras une autre. Avec Premium, tu en héberges autant que tu veux.';

  @override
  String get lastFreeGameBody =>
      'C\'est ta dernière partie gratuite à héberger. Ensuite, tu en récupères une chaque mois. Rejoindre la partie de quelqu\'un d\'autre reste gratuit.';

  @override
  String freeGamesLeftBody(Object remaining) {
    return 'Il te reste $remaining parties gratuites à héberger. Une partie ne compte que lorsque tu la lances vraiment.';
  }

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get hostShares6 => 'L\'hôte partage un code de 6 caractères';

  @override
  String get join => 'Rejoindre';

  @override
  String roomCodeA11y(Object length) {
    return 'Code de salle, $length caractères';
  }

  @override
  String get lobbyStillOpen => 'Ta salle d\'attente est encore ouverte';

  @override
  String get lastGameOver => 'Ta dernière partie est terminée';

  @override
  String get gameStillRunning => 'Ta partie est encore en cours';

  @override
  String resumeA11y(Object label, Object quizTitle, Object code) {
    return '$label. $quizTitle, salle $code. Continuer';
  }

  @override
  String quizRoom(Object quizTitle, Object code) {
    return '$quizTitle - salle $code';
  }

  @override
  String get invite => 'Inviter';

  @override
  String get pickOtherQuiz => 'Choisir un autre quiz';

  @override
  String get setUpRoom => 'Configurer la salle';

  @override
  String get noQuizzesForRoom => 'Aucun quiz trouvé pour créer une salle.';

  @override
  String get cantLoadQuizzes => 'Impossible de charger les quiz';

  @override
  String get numberOfPlayers => 'Nombre de joueurs';

  @override
  String maxN(Object maxPlayers) {
    return 'Max. $maxPlayers';
  }

  @override
  String countPlayersPremium(Object count) {
    return '$count joueurs, Premium';
  }

  @override
  String hostCanInvite(Object maxPlayersPremium) {
    return 'Tu es l\'hôte et peux inviter jusqu\'à $maxPlayersPremium joueurs.';
  }

  @override
  String freeUpToPlayers(Object maxPlayersFree) {
    return 'Gratuit jusqu\'à $maxPlayersFree joueurs. Une partie gratuite ne compte que lorsque tu la lances vraiment.';
  }

  @override
  String maxPlayersNeedsPremium(Object maxPlayers, Object maxPlayersFree) {
    return '$maxPlayers joueurs nécessite Premium. Gratuitement, tu joues jusqu\'à $maxPlayersFree joueurs.';
  }

  @override
  String freeGamesLeftHost(Object freeGamesLeft) {
    return 'Il te reste $freeGamesLeft parties gratuites à héberger.';
  }

  @override
  String get readChapterFirst => 'Lire d\'abord le chapitre';

  @override
  String get onlySingleChapter =>
      'Ne fonctionne qu\'avec les quiz sur 1 chapitre.';

  @override
  String get pacePerQuestion => 'Rythme par question';

  @override
  String get youAdvance =>
      'Tu passes toi-même aux réponses et à la question suivante.';

  @override
  String everyoneGetsSeconds(Object tempo) {
    return 'Chacun a $tempo secondes par question.';
  }

  @override
  String get hostDecides => 'L\'hôte décide';

  @override
  String secondsPerQuestionLong(Object i) {
    return '$i secondes par question';
  }
}
