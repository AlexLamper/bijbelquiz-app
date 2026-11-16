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
}
