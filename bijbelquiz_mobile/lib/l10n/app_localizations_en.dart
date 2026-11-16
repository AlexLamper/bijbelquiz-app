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
}
