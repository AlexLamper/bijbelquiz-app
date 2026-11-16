// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'a Bible quiz';

  @override
  String inviteJoin(String title, String brand) {
    return 'Will you join $title on $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Or enter the code: $code';
  }

  @override
  String get errGenericTitle => 'Something went wrong';

  @override
  String get errGenericMessage =>
      'We couldn\'t finish this. Please try again in a moment.';

  @override
  String get errNetworkTitle => 'No connection';

  @override
  String get errNetworkMessage =>
      'Check your internet connection and try again.';

  @override
  String get errSignedOutTitle => 'Sign in again';

  @override
  String get errSignedOutMessage =>
      'Your session has expired. Sign in again to keep playing.';

  @override
  String get errRoomNotFoundTitle => 'Room not found';

  @override
  String get errRoomNotFoundMessage =>
      'This room no longer exists or has closed. Check the code, or start a new room yourself.';

  @override
  String get errRoomFullTitle => 'Room is full';

  @override
  String get errRoomFullMessage =>
      'No more players fit in this room. Ask the host to open a new room.';

  @override
  String get errRoomStartedTitle => 'Game has already started';

  @override
  String get errRoomStartedMessage =>
      'This quiz is already running. Wait until the round is over or start a new room.';

  @override
  String get errRoomFinishedTitle => 'Game is over';

  @override
  String get errRoomFinishedMessage =>
      'This room is closed. Start a new room to keep playing.';

  @override
  String get errRoomCodeTitle => 'Invalid room code';

  @override
  String get errRoomCodeMessage =>
      'This code isn\'t right. A room code has 6 characters.';

  @override
  String get errAlreadyInRoomTitle => 'You\'re already in this room';

  @override
  String get errAlreadyInRoomMessage => 'Go back to the room to keep playing.';

  @override
  String get errPremiumTitle => 'Premium required';

  @override
  String get errPremiumMessage =>
      'Hosting a room yourself is part of Bible Quizzes Premium. Joining is always free.';

  @override
  String get errForbiddenTitle => 'No access';

  @override
  String get errForbiddenMessage => 'Only the host can do this.';

  @override
  String get errRateLimitedTitle => 'Hold on';

  @override
  String get errRateLimitedMessage =>
      'You tried too many times in a row. Wait a moment and try again.';

  @override
  String get errNotFoundTitle => 'Not found';

  @override
  String get errNotFoundMessage =>
      'We couldn\'t find this. Go back and try again.';

  @override
  String get errConflictTitle => 'That\'s not possible right now';

  @override
  String get errConflictMessage =>
      'This action doesn\'t fit the current state of the game. Refresh and try again.';

  @override
  String get errServerTitle => 'Server not responding';

  @override
  String get errServerMessage =>
      'Something went wrong on our side. Try again in a few seconds.';

  @override
  String get errLiveLostTitle => 'Live connection lost';

  @override
  String get errLiveLostMessage =>
      'The live connection dropped. We\'re fetching the latest state automatically.';

  @override
  String get errLoginTitle => 'Sign-in failed';

  @override
  String get errLoginBadCredentials =>
      'This email address or password is incorrect.';

  @override
  String get errAccountExistsTitle => 'Account already exists';

  @override
  String get errAccountExistsMessage =>
      'An account with this email address already exists. Sign in.';

  @override
  String get errRegisterTitle => 'Sign-up failed';

  @override
  String get errRegisterMessage =>
      'We couldn\'t create your account. Please try again.';

  @override
  String get errLoginMessage => 'We couldn\'t sign you in. Please try again.';

  @override
  String get errLeaderboardTitle => 'Leaderboard didn\'t load';

  @override
  String get errLeaderboardMessage =>
      'We couldn\'t fetch the leaderboard. Please try again.';

  @override
  String get errQuizzesTitle => 'Quizzes didn\'t load';

  @override
  String get errQuizzesMessage =>
      'We couldn\'t fetch the quizzes. Please try again.';

  @override
  String get errProfileTitle => 'Profile didn\'t load';

  @override
  String get errProfileMessage =>
      'We couldn\'t fetch your profile. Please try again.';

  @override
  String get errPurchaseTitle => 'Purchase failed';

  @override
  String get errPurchaseMessage =>
      'The purchase wasn\'t completed. You haven\'t been charged.';

  @override
  String get streakReminderTitle => 'Your streak is at stake';

  @override
  String get streakReminderChannel => 'Streak reminder';

  @override
  String get streakReminderChannelDescription =>
      'A reminder on the evening your streak is about to run out.';

  @override
  String streakReminderBody(Object streak) {
    return 'Your $streak-day streak ends tonight. One quiz is enough to keep it.';
  }

  @override
  String get navQuizzes => 'Quizzes';

  @override
  String get navTogether => 'Together';

  @override
  String get navLeaderboard => 'Leaderboard';

  @override
  String get navProfile => 'Profile';

  @override
  String get savedQuizFallback => 'your quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Your score for \"$title\" has been saved (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved quizzes saved (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Progress saved';

  @override
  String get navHome => 'Home';

  @override
  String get avatarLamb => 'Lamb';

  @override
  String get avatarLion => 'Lion';

  @override
  String get avatarDove => 'Dove';

  @override
  String get avatarOwl => 'Owl';

  @override
  String get avatarDeer => 'Deer';

  @override
  String get avatarOx => 'Ox';

  @override
  String get avatarSand => 'Sand';

  @override
  String get avatarLapis => 'Lapis';

  @override
  String get avatarClay => 'Clay';

  @override
  String get avatarOlive => 'Olive';

  @override
  String get avatarRose => 'Rose';

  @override
  String get avatarSlate => 'Slate';

  @override
  String get avatarParchment => 'Parchment';

  @override
  String get avatarSky => 'Sky';

  @override
  String get avatarSage => 'Sage';

  @override
  String get avatarSunrise => 'Sunrise';

  @override
  String get avatarNight => 'Night';

  @override
  String get avatarBlush => 'Blush';

  @override
  String get avatarNone => 'None';

  @override
  String get avatarGlasses => 'Glasses';

  @override
  String get avatarCap => 'Cap';

  @override
  String get avatarScarf => 'Scarf';

  @override
  String get avatarCrown => 'Crown';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character with $accessory';
  }

  @override
  String get wordmarkFirst => 'Bible';

  @override
  String get wordmarkSecond => 'Quizzes';

  @override
  String get actionClose => 'Close';

  @override
  String get actionBack => 'Back';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount questions';
  }

  @override
  String get actionStart => 'Start';

  @override
  String get authGoogleAndroidInterrupted =>
      'Google sign-in was interrupted on Android. Check the SHA-1/SHA-256 of the release key in the Google Cloud OAuth client.';

  @override
  String get authGoogleNoToken =>
      'Google didn\'t return a sign-in token. Try again or choose another account.';

  @override
  String get authAppleUnavailable =>
      'Sign in with Apple isn\'t available on this device.';

  @override
  String get authAppleError1000 =>
      'Sign in with Apple couldn\'t start (error 1000). Make sure you\'re signed in with an Apple ID on this device and try again.';

  @override
  String get authAppleWebNotConfigured =>
      'Sign in with Apple isn\'t set up for this platform yet.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authLoginSubtitle =>
      'Sign in to keep your progress and join the leaderboard.';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authNoAccount => 'No account yet?';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateSubtitle => 'Free, and your progress is saved.';

  @override
  String get authName => 'Name';

  @override
  String get authNameHelp =>
      'This is how others see you on the leaderboard and when you play together.';

  @override
  String get authTermsPrefixRegister =>
      'By creating an account you agree to the ';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get splashTagline => 'How well do you know the Bible?';

  @override
  String get authOrEmail => 'or with email';

  @override
  String get authTermsPrefix => 'By continuing you agree to the ';

  @override
  String get errLinkTitle => 'Link didn\'t open';

  @override
  String get errLinkMessage => 'We couldn\'t open this page. Please try again.';

  @override
  String get authTermsAnd => ' and the ';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get dataInfoTitle => 'How we handle your data';

  @override
  String get dataInfoBody =>
      'When you sign in or sign up we only use the data needed to make your account work, such as your name, email address and sign-in details.\n\nYour data is sent over secure connections and we don\'t share it for advertising without your permission.\n\nYou can always have your account deleted. Contact us at info@biblequizzes.app or through the support channels in the app. After deletion your account data is removed in line with our privacy policy.';

  @override
  String get dataInfoMore => 'More about data use';

  @override
  String get homeContinue => 'Continue playing';

  @override
  String get homeAll => 'All';

  @override
  String get homePickTopic => 'Pick a topic';

  @override
  String get homePopular => 'Popular quizzes';

  @override
  String get streakOneDay => '1-day streak';

  @override
  String streakDays(Object streak) {
    return '$streak-day streak';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count questions';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz of the day: $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ OF THE DAY';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get actionPlayNow => 'Play now';

  @override
  String get homeChallengeLoading =>
      'A new challenge appears once the quizzes have loaded.';

  @override
  String get homeLoadFailed => 'Home didn\'t load';

  @override
  String get checkConnectionRetry => 'Check your connection and try again.';

  @override
  String get actionRetry => 'Try again';

  @override
  String get homeGuestTitle => 'Play for free, no account';

  @override
  String get homeGuestBody =>
      'Create one to keep your score, points and streak.';

  @override
  String get homeGuestAction => 'Save progress';

  @override
  String chapterN(Object chapter) {
    return 'Chapter $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText correct';
  }

  @override
  String get played => 'Played';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score of $total correct';
  }

  @override
  String get books39 => '39 books';

  @override
  String get books27 => '27 books';

  @override
  String get catGeneral => 'General';

  @override
  String get catWholeBible => 'Whole Bible';

  @override
  String get catByTheme => 'By theme';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount questions';
  }

  @override
  String get groupsLoadFailed => 'Couldn\'t load your groups.';

  @override
  String get groupSaveFailed => 'Saving the group didn\'t work.';

  @override
  String get groupSaveFailedTitle => 'Saving group failed';

  @override
  String get groupSaveNoGroup =>
      'The server didn\'t return a group. Please try again.';

  @override
  String get groupRenameFailed => 'Renaming didn\'t work.';

  @override
  String get deleteFailed => 'Deleting didn\'t work.';

  @override
  String get groupStandingsFailed => 'Couldn\'t load this group\'s standings.';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupSingular => 'Group';

  @override
  String get leaderboardLoadFailed => 'Leaderboard didn\'t load';

  @override
  String get leaderboardMonthHint => 'XP from the last 30 days';

  @override
  String get leaderboardAllTimeHint => 'All XP since the start counts';

  @override
  String get periodMonth => 'This month';

  @override
  String get periodAllTime => 'All time';

  @override
  String get periodLabel => 'Period';

  @override
  String get everyone => 'Everyone';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return '$gap XP to place $rank';
  }

  @override
  String get showLess => 'Show less';

  @override
  String showAllPlayers(Object total) {
    return 'Show all $total players';
  }

  @override
  String get leaderboardGuestHint => 'With a free account your XP counts.';

  @override
  String get leaderboardNotOnIt => 'You\'re not on this leaderboard yet';

  @override
  String get leaderboardPlayToJoin => 'Play a quiz to join.';

  @override
  String get leaderboardNoData => 'No leaderboard data yet.';

  @override
  String get leaderboardEmpty => 'No one on the leaderboard yet';

  @override
  String get onboardingTagline =>
      'Short quizzes on the books of the Bible, alone or with others.';

  @override
  String get onboardingGuest => 'Play first, no account';

  @override
  String get onboardingPreviewA11y =>
      'Example: a quiz question with the right answer, a duel against Sarah, XP and a streak';

  @override
  String get onboardingSampleQuestion =>
      'How many loaves did the boy have with him?';

  @override
  String get onboardingSampleStreak => '6 days in a row';

  @override
  String get seasonEndsToday => 'Ends today';

  @override
  String get seasonOneDayLeft => '1 day left';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return '$daysRemaining days left';
  }

  @override
  String get season => 'Season';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get viaWebsite => 'Via the website';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get active => 'Active';

  @override
  String get deleteSignInFirst =>
      'First sign in with the account you want to delete.';

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'Your account, progress, XP and duels will be permanently deleted. This can\'t be undone.\n\nA subscription through the App Store or Google Play doesn\'t stop because of this: cancel it first in your phone\'s subscriptions.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'Deleting didn\'t work. Try again or email $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Account not deleted';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get notificationsOff =>
      'Notifications are off for Bible Quizzes. Turn them on in your phone\'s settings.';

  @override
  String get purchasesRestored => 'Purchases restored';

  @override
  String get settingsReminder => 'Reminder';

  @override
  String get settingsTime => 'Time';

  @override
  String get settingsPlaying => 'Playing';

  @override
  String get settingsReadChapterFirst => 'Read the chapter first';

  @override
  String get settingsShowReference => 'Bible reference with explanation';

  @override
  String get settingsLargeText => 'Large question text';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get settingsManage => 'Manage';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get guestPlaying => 'You\'re playing without an account';

  @override
  String get signInOrCreate => 'Sign in or create an account';

  @override
  String get yourAccount => 'Your account';

  @override
  String get signedIn => 'Signed in';

  @override
  String signedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice seconds';
  }

  @override
  String get joinFailed => 'Joining didn\'t work.';

  @override
  String get joinFailedConnection =>
      'Joining didn\'t work. Check your connection.';

  @override
  String get trialEndingTitle => 'Your trial is almost over';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Your Bible Quizzes Premium starts in $kTrialReminderDaysBeforeEnd days. Don\'t want to continue? Cancel in your store settings.';
  }

  @override
  String get trialReminderChannel => 'Trial reminder';

  @override
  String get trialReminderChannelDescription =>
      'A reminder before your free trial ends.';

  @override
  String get supportEmail => 'info@biblequizzes.app';

  @override
  String get groupCodeIncomplete => 'Enter the full group code.';

  @override
  String groupJoined(Object name) {
    return 'You\'re now part of $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Go to biblequizzes.app/group-license in your browser.';

  @override
  String get groupLicense => 'Group license';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Email us at $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      'Does your youth leader, pastor or teacher have a group code? Enter it below and you get Premium right away.';

  @override
  String get premiumViaGroup => 'Premium through your group';

  @override
  String get yourGroups => 'Your groups';

  @override
  String get premiumWholeGroup => 'Premium for your whole group';

  @override
  String get forChurches => 'For churches, schools and clubs';

  @override
  String get groupPerkAll => 'All of Premium for every member';

  @override
  String get groupPerkCode => 'One code you read out in the room';

  @override
  String get groupPerkManage => 'You decide who takes part';

  @override
  String get groupLicenseWebsiteOnly =>
      'You buy a group license on the website, because an App Store purchase is tied to a single account, not a group.';

  @override
  String get openWebsite => 'Open biblequizzes.app';

  @override
  String get youManageGroup => 'You manage this group';

  @override
  String get youTakePart => 'You\'re in';

  @override
  String get groupCode => 'Group code';

  @override
  String get purchaseReceivedNotActive =>
      'Your purchase came through, but Premium isn\'t on yet. Tap \"Restore\" in a minute.';

  @override
  String noPurchaseFound(Object storeName) {
    return 'We found no Premium purchase on this $storeName account.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Your purchase is still waiting for approval or payment. Premium turns on by itself once $storeName completes it.';
  }

  @override
  String get noInternetRetry =>
      'No internet connection. Check your connection and try again.';

  @override
  String get alreadyPurchased =>
      'You\'ve already bought this. Tap \"Restore\" to get it back.';

  @override
  String get purchaseOtherAccount =>
      'This purchase already belongs to another Bible Quizzes account. Sign in with that account to use your Premium.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'Purchases aren\'t allowed on this device. Check your $store account settings.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'This subscription isn\'t available in $store right now. Try again later.';
  }

  @override
  String storeError(Object store) {
    return '$store returned an error. Try again later.';
  }

  @override
  String get purchasesNotInVersion =>
      'Purchases aren\'t available in this version of the app.';

  @override
  String get restoreFailed => 'Restoring didn\'t work. Please try again.';

  @override
  String get introPerkExplain =>
      'An explanation for every question: why the answer is right';

  @override
  String get introPerkAll => 'All quizzes, as often as you like';

  @override
  String get introPerkReview => 'A full review after every quiz';

  @override
  String get introPerkDaily => 'A new quiz every day, no limit';

  @override
  String get introPerkStick =>
      'An explanation for every question, so it sticks';

  @override
  String get introPerkLookBack => 'Look back at your answers after every quiz';

  @override
  String get introPerkTogetherFree =>
      'Playing together stays free for everyone';

  @override
  String get introPerkSoloUnlimited => 'Plus unlimited solo play';

  @override
  String get introPerkDiscuss =>
      'An explanation for every question to talk over together';

  @override
  String stepOfThree(Object page) {
    return 'Step $page of 3';
  }

  @override
  String get actionNext => 'Next';

  @override
  String get introGrowQuestion => 'Where do you want to grow?';

  @override
  String get introGrowSubtitle =>
      'Then we\'ll show what Premium does for that.';

  @override
  String get introGoalKnowledge => 'More Bible knowledge';

  @override
  String get introGoalKnowledgeBody => 'Understand why an answer is right.';

  @override
  String get introGoalDaily => 'Learn something every day';

  @override
  String get introGoalDailyBody => 'Build a habit and keep it.';

  @override
  String get introGoalGroupBody => 'Against each other with family or a group.';

  @override
  String get introYouGet => 'Here\'s what you get';

  @override
  String get introOneMembership =>
      'Everything in one membership, on web and app.';

  @override
  String get choosePlan => 'Choose your plan';

  @override
  String get pricesNextPage =>
      'You\'ll see the prices on the next page. You can cancel any time.';

  @override
  String get accountWebAndApp =>
      'Your account works on web and app at the same time. A purchase on your phone also gives you Premium on the website, and the other way round.';

  @override
  String get paywallHeadlineDefault => 'Play unlimited\nwith Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'You\'ve played your\n$kFreeQuizLimit free quizzes';
  }

  @override
  String get paywallHeadlineTogether => 'Keep playing together\nwithout limits';

  @override
  String get paywallHeadlineGroup => 'Play with your\nwhole group';

  @override
  String get paywallHeadlineExplain => 'Read why\nfor every question';

  @override
  String get paywallHeadlineUnlock => 'Unlock\nevery quiz';

  @override
  String get premiumRestored => 'Premium restored';

  @override
  String get welcomePremium => 'Welcome to Premium';

  @override
  String get premiumBackOn => 'Your Premium is back on for this account.';

  @override
  String get premiumFullAccess =>
      'You now have full access to every Premium feature, in the app and on the website. Enjoy!';

  @override
  String get playOnPremium => 'Keep playing with Premium.';

  @override
  String get chooseSubscription => 'Choose a subscription';

  @override
  String get yearly => 'Yearly';

  @override
  String get perYear => 'per year';

  @override
  String get monthly => 'Monthly';

  @override
  String get perMonth => 'per month';

  @override
  String get noTrial => 'No trial';

  @override
  String get reloadPrices => 'Reload prices';

  @override
  String storeUnreachable(Object storeName) {
    return '$storeName can\'t be reached right now. Check your connection.';
  }

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get alreadyPremium =>
      'You already have Premium on this account. Nothing was charged.';

  @override
  String get premiumOn => 'Premium is on';

  @override
  String get restoreSignIn =>
      'Sign in with your account and we\'ll put your purchases back on it.';

  @override
  String get needAccountForPremium =>
      'First create a free account or sign in, so Premium belongs to you - in the app and on the website.';

  @override
  String get accountNeeded => 'Account needed';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get nothingToRestore => 'Nothing to restore';

  @override
  String get viewAllPlans => 'View all plans';

  @override
  String get explainEveryAnswer => 'An explanation for every answer';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'For free you play $kFreeQuizLimit quizzes. With Premium every book of the Bible opens up, including Psalms and Revelation.';
  }

  @override
  String get premiumEverythingOpen => 'Everything open with Premium';

  @override
  String get abbrGenesis => 'Gen';

  @override
  String get quizzes12 => '12 quizzes';

  @override
  String get abbrPsalms => 'Ps';

  @override
  String get quizzes15 => '15 quizzes';

  @override
  String get abbrRevelation => 'Rev';

  @override
  String get bookRevelation => 'Revelation';

  @override
  String get quizzes9 => '9 quizzes';

  @override
  String get free => 'Free';

  @override
  String get orLifetime => 'Or one-time: lifetime Premium';

  @override
  String lifetimeOnce(Object price) {
    return 'Lifetime Premium, $price once';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly per week over $lifetimeHorizonYears years';
  }

  @override
  String get lifetimePremium => 'Lifetime Premium';

  @override
  String get payNothingToday => 'You pay nothing today.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'You pay nothing today. Reminder on day $day.';
  }

  @override
  String get cancelAnytime => 'Cancel whenever you like.';

  @override
  String get payOnceNoSub => 'Pay once, no subscription.';

  @override
  String get startPremium => 'Start Premium';

  @override
  String tryTrial(Object label) {
    return 'Try $label';
  }

  @override
  String get badgeFirstStepsDesc => 'Complete your first quiz.';

  @override
  String get badgeKnowledgeSeeker => 'Knowledge Seeker';

  @override
  String get badgeKnowledgeSeekerDesc => 'Play 10 different quizzes.';

  @override
  String get badgePerfect => 'Flawless';

  @override
  String get badgePerfectDesc => 'Score 100% on a quiz.';

  @override
  String get badgeOnARoll => 'On a Roll';

  @override
  String get badgeOnARollDesc => 'Build a 3-day streak.';

  @override
  String get badgeDedicated => 'Dedicated';

  @override
  String get badgeDedicatedDesc => 'Play 7 days in a row.';

  @override
  String get badgeScholar => 'Scholar';

  @override
  String get badgeMaster => 'Master';

  @override
  String get badgeAllRounder => 'All-Rounder';

  @override
  String get badgeAllRounderDesc => 'Play a wide range of quizzes.';

  @override
  String get rankSeeker => 'Seeker';

  @override
  String get saveFailed => 'Saving didn\'t work. Please try again.';

  @override
  String get saveFailedConnection =>
      'Saving didn\'t work. Check your connection.';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementsLoadFailed => 'Achievements didn\'t load';

  @override
  String get noBadgesYet =>
      'No badges yet. Play quizzes to unlock your first badge.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'Still to earn · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked of $total badges earned';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked of $total badges';
  }

  @override
  String get allEarned => 'All earned';

  @override
  String leftToEarn(Object left) {
    return '$left to go';
  }

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileLoadFailed => 'Profile didn\'t load';

  @override
  String get actionSave => 'Save';

  @override
  String get surpriseMe => 'Surprise me';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'How you appear on the leaderboard';

  @override
  String get displayNameHelp =>
      'Visible on the leaderboard and in multiplayer. Can be changed once every 30 days.';

  @override
  String get buildMascot => 'Build your mascot';

  @override
  String get figure => 'Figure';

  @override
  String get color => 'Colour';

  @override
  String get background => 'Background';

  @override
  String get accessory => 'Accessory';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String levelN(Object level) {
    return 'Level $level';
  }

  @override
  String get maxLevel => 'Highest level reached';

  @override
  String progressToLevel(Object level) {
    return 'Progress to level $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return '$xpRemaining XP to level $level';
  }

  @override
  String get daysInARow => 'Days in a row';

  @override
  String get quizzesPlayed => 'Quizzes played';

  @override
  String get averageScore => 'Average score';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'View all achievements, $unlockedCount of $overviewCount earned';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'All $unlockedCount of $overviewCount';
  }

  @override
  String get youHavePremium => 'You have Premium';

  @override
  String get youPlayFree => 'You play for free';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score of $totalQuestions correct';
  }

  @override
  String get completed => 'Completed';

  @override
  String get guestPerkKeep => 'Points, level and streak that stay';

  @override
  String get guestPerkLeaderboard => 'A place on the leaderboard';

  @override
  String get guestPerkBadges => 'Badges for your achievements';

  @override
  String get guestPerkWebsite => 'The same progress on biblequizzes.app';

  @override
  String get saveYourProgress => 'Save your progress';

  @override
  String get guestExplain =>
      'You\'re playing without an account. That\'s fine, but your score, points and streak are only kept with a free account.';

  @override
  String get createFreeAccount => 'Create a free account';

  @override
  String get pendingOne => 'One quiz is waiting for your account';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount quizzes are waiting for your account';
  }

  @override
  String get withAccount => 'With an account';

  @override
  String get oneQuiz => '1 quiz';

  @override
  String quizzesN(Object total) {
    return '$total quizzes';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played of $total played';
  }

  @override
  String get quizzesLoadFailed => 'Quizzes didn\'t load';

  @override
  String get byBibleBook => 'By book of the Bible';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount books · $quizzes quizzes';
  }

  @override
  String get bibleBook => 'Book of the Bible';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount quizzes';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played of $quizzesCount played';
  }

  @override
  String get noQuizzesForBook => 'There are no quizzes on this book yet.';

  @override
  String allQuizzesAbout(Object name) {
    return 'All quizzes on $name';
  }

  @override
  String get startWith => 'START WITH';

  @override
  String get continueWith => 'CONTINUE WITH';

  @override
  String get anyLevel => 'Any level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get results => 'Results';

  @override
  String get allQuizzes => 'All quizzes';

  @override
  String get popular => 'Popular';

  @override
  String get allBooks => 'All books';

  @override
  String get searchHint => 'Search a book of the Bible or topic';

  @override
  String get clear => 'Clear';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount questions · $questionCount2 min';
  }

  @override
  String get notPlayedYet => 'Not played yet';

  @override
  String get noQuizzesFilters => 'No quizzes found with the current filters.';

  @override
  String get sortBibleOrder => 'Bible order';

  @override
  String get sortMostPopular => 'Most popular';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortShortest => 'Shortest';

  @override
  String get sort => 'Sort';

  @override
  String get hideText => 'Hide text';

  @override
  String hideTextOf(Object reference) {
    return 'Hide the text of $reference';
  }

  @override
  String get unlockPremiumExplain => 'Unlock Premium for the explanation';

  @override
  String get readWhyWrong => 'Read why this was wrong';

  @override
  String get timeUp => 'Time\'s up';

  @override
  String get finishQuiz => 'Finish quiz';

  @override
  String get a11yYourAnswerRight => ', your answer, correct';

  @override
  String get a11yCorrectAnswer => ', the correct answer';

  @override
  String get a11yYourAnswerWrong => ', your answer, wrong';

  @override
  String questionOf(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return '$secondsLeft seconds left';
  }

  @override
  String get wellPlayed => 'Well played';

  @override
  String get niceTry => 'Nice try';

  @override
  String get nextQuiz => 'Next quiz';

  @override
  String get playWithOthers => 'Play together with others';

  @override
  String get viewAnswers => 'View answers';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Score $correct of $total';
  }

  @override
  String get newBestScore => 'New best score';

  @override
  String get scoreNotSaved => 'Your score hasn\'t been saved yet';

  @override
  String get scoreSaving => 'Your score is being saved';

  @override
  String get again => 'Again';

  @override
  String get noExtraXp => 'No extra XP this time';

  @override
  String get replayRule => 'A replay only counts if you beat your own score.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return '$xpToNextLevel XP to level $level';
  }

  @override
  String get playTomorrowStreak => 'Play tomorrow to keep your streak';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Keep your score, $previewXp XP and your streak';
  }

  @override
  String get keepScoreBody =>
      'Sign in or create a free account and this score is added straight away. Your quizzes then count towards your level and the leaderboard.';

  @override
  String get yourAnswers => 'Your answers';

  @override
  String get allCorrectReview =>
      'All correct. See the explanation for each question.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount of the $questionsCount questions wrong.';
  }

  @override
  String get fullExplainPremium =>
      'The full explanation for every question is part of Premium.';

  @override
  String get unlockFullReview => 'Unlock the full review';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String correctAnswerIs(Object text) {
    return 'Correct answer: $text';
  }

  @override
  String get quizLoadFailed => 'Quiz didn\'t load';

  @override
  String get howToPlay => 'How do you want to play?';

  @override
  String get rememberedNext =>
      'Remembered for your next quizzes, also on the website.';

  @override
  String get freeLeftPrefix => '';

  @override
  String get freeLeftOne => ' free quiz left';

  @override
  String get freeLeftMany => ' free quizzes left';

  @override
  String get unlockWithPremium => 'Unlock with Premium';

  @override
  String readAndStart(Object label) {
    return 'Read $label and start';
  }

  @override
  String get startQuiz => 'Start quiz';

  @override
  String readFirstLabel(Object label) {
    return 'Read $label first';
  }

  @override
  String get alreadyPlayed => 'Already played';

  @override
  String get playAgainBetter => 'Play again for a better score';

  @override
  String get yourBestScore => 'Your best score';

  @override
  String lastPlayed(Object last) {
    return 'Last played $last';
  }

  @override
  String get testKnowledge => 'Test your knowledge of this topic.';

  @override
  String get aboutQuiz => 'About this quiz';

  @override
  String get finished => 'Finished';

  @override
  String get readChapterExplain =>
      'You read the chapter this quiz is about before the questions start.';

  @override
  String get timePerQuestion => 'Time per question';

  @override
  String get timerExplain =>
      'Off by default. Turn on a clock if you want a challenge.';

  @override
  String get off => 'Off';

  @override
  String get noChapterToRead => 'No chapter to read';

  @override
  String get multiChapter =>
      'This quiz covers more than one chapter. You can just start the quiz.';

  @override
  String get chapterFetchFailed =>
      'This chapter couldn\'t be loaded right now. You can just start the quiz.';

  @override
  String get readFirst => 'Read first';

  @override
  String readBeforeQuiz(Object title) {
    return 'Read before the quiz $title';
  }

  @override
  String get bibleVersionName => 'World English Bible';

  @override
  String get keepStreakQuestion => 'Keep your streak?';

  @override
  String keepStreakBody(Object streak) {
    return 'You\'ve played $streak days in a row. Shall we nudge you at 7 pm on a day you haven\'t played yet?';
  }

  @override
  String get noQuestionsYet => 'No questions yet';

  @override
  String get quizNoQuestions => 'This quiz has no questions yet.';

  @override
  String get goBack => 'Go back';

  @override
  String get today => 'today';

  @override
  String get yesterday => 'yesterday';

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String onDate(Object date) {
    return 'on $date';
  }
}
