// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flanki';

  @override
  String get navDecks => 'Decks';

  @override
  String get navBrowser => 'Browser';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchDecks => 'Search decks...';

  @override
  String get studyNow => 'Study Now';

  @override
  String get customStudy => 'Custom Study';

  @override
  String get addNewDeck => 'Add New Deck';

  @override
  String get importApkg => 'Import .apkg';

  @override
  String get syncAnkiWeb => 'Sync AnkiWeb';

  @override
  String get dueCards => 'Due';

  @override
  String get newCards => 'New';

  @override
  String get learningCards => 'Learning';

  @override
  String get totalCards => 'Total Cards';

  @override
  String get noDecksFound =>
      'No decks found. Create one or import from AnkiWeb!';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncCompleted => 'Sync completed successfully';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get settingsTitle => 'Settings & Configuration';

  @override
  String get accountAndSync => 'ACCOUNT & SYNC';

  @override
  String get linkedAnkiWeb => 'Linked with AnkiWeb';

  @override
  String get notLinkedAnkiWeb => 'Not linked to AnkiWeb';

  @override
  String get loginToSyncHint =>
      'Log in to sync cards and progress with the cloud.';

  @override
  String get readyToSync => 'Ready to sync';

  @override
  String syncedAt(String time) {
    return 'Synced at: $time';
  }

  @override
  String get logout => 'Log out';

  @override
  String get loggedOut => 'Logged out';

  @override
  String get logoutSubtitle => 'Secure session token removed from device.';

  @override
  String get connectAnkiWeb => 'Connect AnkiWeb Account';

  @override
  String get connectAnkiWebSubtitle =>
      'Two-way sync for flashcards and learning progress with Anki servers.';

  @override
  String get appPreferences => 'APP PREFERENCES';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose app display language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Theme and visual customization';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System Default';

  @override
  String get spacedRepetitionAlgorithm => 'SPACED REPETITION ENGINE';

  @override
  String get enableFsrs => 'Enable FSRS v5';

  @override
  String get fsrsSubtitle =>
      'Optimized retention algorithm based on Difficulty, Stability, and Retrievability.';

  @override
  String get aboutSection => 'ABOUT FLANKI';

  @override
  String get appVersion => 'App Version';

  @override
  String get searchCardsPlaceholder => 'Search questions, answers, or tags...';

  @override
  String get filterAll => 'All';

  @override
  String get filterDue => 'Due';

  @override
  String get filterNew => 'New';

  @override
  String get filterFlagged => 'Flagged';

  @override
  String get filterSuspended => 'Suspended';

  @override
  String get noCardsFound => 'No cards found';

  @override
  String cardsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get ratingAgain => 'Again';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingEasy => 'Easy';

  @override
  String get studySessionComplete =>
      'Congratulations! You have completed today\'s study session.';

  @override
  String get studyCompleteTitle => 'Great job! You finished';

  @override
  String studyCompleteDesc(int count) {
    return 'Completed $count cards in this session with FSRS algorithm.';
  }

  @override
  String get backToDecks => 'Back to decks';

  @override
  String get authTitle => 'Log in to AnkiWeb';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authLoggingIn => 'Logging in...';

  @override
  String get authSuccess => 'Logged in successfully!';

  @override
  String get authFailed => 'Login failed. Please check your credentials.';

  @override
  String get statsTitle => 'Stats & Progress';

  @override
  String get retentionRate => 'RETENTION RATE';

  @override
  String get targetReached => 'Target reached';

  @override
  String targetSuffix(String rate) {
    return '/ $rate target';
  }

  @override
  String get reviewedToday => 'Reviewed today';

  @override
  String get reviewedDiff => 'Cards reviewed';

  @override
  String get studyTime => 'Study time';

  @override
  String get studyTimePerCard => '~15s per card';

  @override
  String get studyHistory => 'Study history';

  @override
  String streakDays(int days) {
    return '$days day streak';
  }

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get studyQuestion => 'QUESTION';

  @override
  String get studyAnswer => 'ANSWER';

  @override
  String get tapToFlip => 'Tap screen to flip card';

  @override
  String get swipeHint => 'Swipe left: Again • Swipe right: Good';

  @override
  String cardsRemaining(int count) {
    return 'Cards left: $count';
  }

  @override
  String get studyAgain => 'Study again';

  @override
  String get cardActionTitle => 'Card Options';

  @override
  String get flagSelector => 'MARK WITH FLAG';

  @override
  String get buryCard => 'Bury card';

  @override
  String get suspendCard => 'Suspend';

  @override
  String get editCardContent => 'Edit card content';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get frontSide => 'FRONT';

  @override
  String get backSide => 'BACK';

  @override
  String get addCardTitle => 'Add New Card';

  @override
  String get saveCard => 'Save card';

  @override
  String get noteType => 'NOTE TYPE';

  @override
  String get deckLabel => 'DECK';

  @override
  String get extraNotes => 'NOTES';

  @override
  String get tagsLabel => 'TAGS';

  @override
  String get addTagPlaceholder => 'Add tag (e.g. toeic, grammar)...';

  @override
  String get cramModeTitle => 'Custom Cram Study';

  @override
  String get cramModeDesc =>
      'Create an ad-hoc session filtered by tags or flags. Does not affect original FSRS schedules.';

  @override
  String get filterMode => 'CARD FILTER';

  @override
  String get byTag => 'By Tag';

  @override
  String get flaggedCards => 'Flagged';

  @override
  String get reviewAhead => 'Review Ahead';

  @override
  String get cardLimit => 'CARD LIMIT';

  @override
  String get startCram => 'Start cram session';

  @override
  String get cramDeckCreated => 'Cram Deck Created';

  @override
  String cramDeckCreatedDesc(int count, String tag) {
    return 'Filtered $count cards for cram study (#$tag).';
  }

  @override
  String streakDaysBadge(int count) {
    return '$count Day Streak';
  }

  @override
  String targetRetentionBadge(String rate) {
    return 'Target $rate retention';
  }

  @override
  String get cramTagInputLabel => 'TAG NAME TO STUDY';

  @override
  String cardsCountUnit(int count) {
    return '$count cards';
  }

  @override
  String get cramButton => 'Cram';

  @override
  String get linkedBadge => 'Linked';

  @override
  String get syncBadge => 'Sync';

  @override
  String get syncError => 'Sync Error';

  @override
  String get importApkgSuccess => 'Import .apkg Successful';

  @override
  String importApkgSuccessDesc(int decks, int cards, int media) {
    return 'Imported $decks decks, $cards cards ($media media files).';
  }

  @override
  String get importApkgError => 'Import .apkg Error';

  @override
  String get undoSuccessTitle => 'Undone';

  @override
  String get undoSuccessDesc => 'Restored previous card rating.';

  @override
  String get addCard => 'Add Card';

  @override
  String get missingContent => 'Missing Content';

  @override
  String get missingContentDesc => 'Please enter question/front content.';

  @override
  String get cardCreatedSuccess => 'Card Created';

  @override
  String get cardCreatedSuccessDesc => 'Added card to deck.';

  @override
  String get basicNoteType => 'Basic';

  @override
  String get basicNoteSubtitle => 'Question / Answer';

  @override
  String get clozeNoteType => 'Cloze';

  @override
  String get clozeNoteSubtitle => 'Fill in the blank';

  @override
  String get reversedNoteType => 'Reversed';

  @override
  String get reversedNoteSubtitle => 'Two-way card';

  @override
  String get clozeTextLabel => 'TEXT';

  @override
  String get frontPlaceholder => 'Enter question, vocabulary or concept...';

  @override
  String get clozePlaceholder => 'The capital of France is {{c1::Paris}}.';

  @override
  String get backPlaceholder => 'Enter explanation, examples...';

  @override
  String get authScreenTitle => 'AnkiWeb Account';

  @override
  String get authHeaderTitle => 'AnkiWeb Sync';

  @override
  String get authHeaderDesc =>
      'Log in to your AnkiWeb account to synchronize decks, FSRS schedules, and study progress across devices.';

  @override
  String get authEmailLabel => 'ANKIWEB EMAIL';

  @override
  String get authPasswordLabel => 'PASSWORD';

  @override
  String get authPasswordPlaceholder => 'Enter password...';

  @override
  String get authSubmitButton => 'Log In & Start Sync';

  @override
  String get authSubmitting => 'Authenticating...';

  @override
  String get authMissingInfoTitle => 'Missing Credentials';

  @override
  String get authMissingInfoDesc =>
      'Please provide both AnkiWeb email and password.';

  @override
  String get authSuccessToastTitle => 'Login Successful';

  @override
  String authSuccessToastDesc(String email) {
    return 'Linked account $email with Flanki.';
  }

  @override
  String get authGuestMode => 'Try Offline';

  @override
  String get authSecurityNote =>
      'Security: Flanki stores only your session HostKey securely on device, never your raw password.';

  @override
  String intervalMinutes(int count) {
    return '${count}m';
  }

  @override
  String intervalHours(int count) {
    return '${count}h';
  }

  @override
  String intervalDays(int count) {
    return '${count}d';
  }

  @override
  String intervalMonths(String count) {
    return '${count}mo';
  }

  @override
  String intervalYears(String count) {
    return '${count}y';
  }

  @override
  String deckPrefix(String deck) {
    return 'Deck: $deck';
  }

  @override
  String intervalBadge(int days) {
    return '${days}d interval';
  }

  @override
  String get newBadge => 'New';

  @override
  String studyMinutesUnit(int count) {
    return '${count}m';
  }

  @override
  String get targetNotReached => 'In progress';

  @override
  String targetRetentionRate(String rate) {
    return 'Target $rate';
  }

  @override
  String get algorithmLabel => 'Algorithm';

  @override
  String get themeZinc => 'Zinc Theme';

  @override
  String get ankiRustCore => 'Anki Rust Core';

  @override
  String get createDeckTitle => 'Create Deck';

  @override
  String get createDeckDesc => 'Create a new deck to organize your flashcards.';

  @override
  String get deckNameLabel => 'DECK NAME';

  @override
  String get deckNamePlaceholder => 'e.g. English::Vocabulary';

  @override
  String get deckDescLabel => 'DESCRIPTION (OPTIONAL)';

  @override
  String get deckDescPlaceholder => 'Short description of this deck...';

  @override
  String get deckCreatedSuccess => 'Deck Created';

  @override
  String deckCreatedSuccessDesc(String name) {
    return 'Deck \"$name\" has been created.';
  }

  @override
  String get deckNameRequired => 'Please enter a deck name.';

  @override
  String get deckAlreadyExists => 'A deck with this name already exists.';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get deleteCardTitle => 'Delete Card';

  @override
  String get deleteCardConfirm =>
      'Are you sure you want to delete this card? This action cannot be undone.';

  @override
  String get cardDeleted => 'Card deleted';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String get sm2Subtitle => 'Traditional SM-2 algorithm';

  @override
  String get selectApkgOrZipPrompt => 'Please select an .apkg or .zip file';

  @override
  String subdecksCount(int count) {
    return '$count subdecks';
  }

  @override
  String get importedFromApkg => 'Imported from Anki .apkg package';

  @override
  String badgeDue(int count) {
    return '$count due';
  }

  @override
  String badgeNew(int count) {
    return '$count new';
  }

  @override
  String badgeTotalCards(int count) {
    return '$count cards';
  }

  @override
  String get createDeckAction => 'Create Deck';

  @override
  String get importApkgAction => 'Import Anki (.apkg)';

  @override
  String get cramAction => 'Cram Study';

  @override
  String get deckHierarchyTip =>
      'Tip: Use :: to create hierarchy (e.g. English::Unit 01)';

  @override
  String get typeAnswerPlaceholder => 'Type your answer...';

  @override
  String get correctAnswerLabel => 'Correct!';

  @override
  String get yourAnswerLabel => 'You typed: ';

  @override
  String get expectedAnswerLabel => 'Correct answer: ';

  @override
  String get answerLabel => 'Answer: ';

  @override
  String get stabilityLabel => 'Stability';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get repsLabel => 'Reps';

  @override
  String get lapsesLabel => 'Lapses';

  @override
  String get newCardsPerDay => 'New cards per day';

  @override
  String get maxReviewsPerDay => 'Maximum reviews per day';

  @override
  String get selectCardToViewDetails =>
      'Select a card on the left to view and edit details';

  @override
  String get unsuspendCard => 'Unsuspend';

  @override
  String get fsrsScheduleTitle => 'FSRS ALGORITHM & SCHEDULE';

  @override
  String get intervalLabel => 'Interval';

  @override
  String get repsAndLapsesLabel => 'Reps / Lapses';

  @override
  String get dartCoreEngine => 'Dart Core (Drift SQLite)';

  @override
  String get submitAnswer => 'Submit';

  @override
  String get showAnswer => 'Show Answer';

  @override
  String get hideAnswer => 'Hide Answer';

  @override
  String get syncMediaOnly => 'Sync Media (Images & Audio)';

  @override
  String get syncingMedia => 'Syncing media files...';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get clozeDeletion => 'Cloze Deletion';

  @override
  String get connected => 'Connected';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get syncConflictTitle => 'AnkiWeb Sync Conflict';

  @override
  String get syncConflictDesc =>
      'Both this device and AnkiWeb have new study progress or card changes since the last sync. The system cannot automatically merge two independent sessions.';

  @override
  String get previousSyncLabel => 'Previous sync:';

  @override
  String get ankiWebUpdateLabel => 'AnkiWeb update:';

  @override
  String get selectVersionToKeep =>
      'Please select which version of data you want to keep:';

  @override
  String get uploadToCloudTitle => 'Upload to AnkiWeb (Overwrite Cloud)';

  @override
  String get uploadToCloudDesc =>
      'Keep all progress and review history on this device and overwrite AnkiWeb Cloud.';

  @override
  String get downloadFromCloudTitle =>
      'Download from AnkiWeb (Overwrite Device)';

  @override
  String get downloadFromCloudDesc =>
      'Download all data from AnkiWeb Cloud and replace the local data on this device.';

  @override
  String get unknownTime => 'Unknown';

  @override
  String get preparingUpload => 'Preparing to upload to AnkiWeb...';

  @override
  String get connectingToAnkiWeb => 'Connecting to AnkiWeb...';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateChangelog => 'Release Notes:';

  @override
  String get downloadingUpdate => 'Downloading update installer...';

  @override
  String get later => 'Later';

  @override
  String get openDownloadPage => 'Open Download Page';

  @override
  String get restartAndInstall => 'Restart & Update';

  @override
  String get downloadAndInstall => 'Download & Update';

  @override
  String updateBannerTitle(String version) {
    return 'A new update is available (v$version)';
  }

  @override
  String get updateBannerSubtitle => 'Click to view details and update';

  @override
  String get updateAction => 'Update';

  @override
  String get checkingForUpdates => 'Checking...';

  @override
  String newVersionBadge(String version) {
    return 'New v$version';
  }

  @override
  String get latestVersionStatus => 'Up to date';

  @override
  String get checkForUpdates => 'Check';

  @override
  String get cramDeckDefaultDesc =>
      'Cram study deck without affecting primary FSRS schedule.';

  @override
  String get importedDeckDefaultDesc => 'Imported from Anki package .apkg';

  @override
  String get authEmailPasswordEmpty => 'Email and password cannot be empty.';

  @override
  String get authInvalidCredentials => 'Incorrect AnkiWeb email or password.';

  @override
  String get authTooManyAttempts =>
      'Too many login attempts. Please try again in a few minutes.';

  @override
  String get authServerResponseInvalid =>
      'Invalid response from AnkiWeb server.';

  @override
  String authNetworkError(String error) {
    return 'Cannot connect to AnkiWeb server. Please check your network: $error';
  }

  @override
  String authUnknownError(String error) {
    return 'AnkiWeb connection error: $error';
  }

  @override
  String get syncConnecting => 'Connecting to AnkiWeb...';

  @override
  String get syncDownloadingCollection =>
      'Downloading collection data from AnkiWeb...';

  @override
  String get syncProcessingData => 'Processing cards & saving database...';

  @override
  String get syncCheckingMedia => 'Checking media files (images & audio)...';

  @override
  String syncDownloadingMediaProgress(int downloaded, int total) {
    return 'Downloading media ($downloaded/$total)...';
  }

  @override
  String get syncCompressingUpload =>
      'Compressing and preparing upload to AnkiWeb...';

  @override
  String get syncUploadingCloud => 'Uploading data to AnkiWeb Cloud...';

  @override
  String get syncUploadComplete => 'Upload complete!';

  @override
  String get syncSessionExpired =>
      'AnkiWeb session expired. Please log in again.';

  @override
  String get syncNoInternet => 'No internet connection.';

  @override
  String get syncConflictDetected =>
      'Conflict detected: Both AnkiWeb and this device have new study data.';

  @override
  String get trayOpenFlanki => 'Open Flanki';

  @override
  String get trayStudyNow => 'Study Now';

  @override
  String get trayExit => 'Quit Flanki';

  @override
  String get notificationDailyChannelName => 'Study Reminder';

  @override
  String get notificationDailyChannelDesc => 'Daily flashcard study reminders';

  @override
  String get notificationDailyTitle => 'Time to study with Flanki! 🦉';

  @override
  String notificationDailyBodyDue(int count) {
    return 'You have $count cards waiting for review today. Review now to remember longer!';
  }

  @override
  String get notificationDailyBodyGeneric =>
      'Spend 5 minutes a day with Flanki to keep your memory sharp!';

  @override
  String get notificationStreakChannelName => 'Streak Saver';

  @override
  String get notificationStreakChannelDesc =>
      'Urgent reminder before midnight to protect your study streak';

  @override
  String notificationStreakTitleActive(int count) {
    return 'Save your $count-day streak! 🔥';
  }

  @override
  String get notificationStreakTitleInactive => 'You haven\'t studied today! ⏳';

  @override
  String get notificationStreakBodyActive =>
      'Only a few hours left before midnight! Study for 3 minutes to keep your streak.';

  @override
  String get notificationStreakBodyInactive =>
      'Spend a few minutes before the day ends to start a new streak!';

  @override
  String get notificationTestTitle => 'Flanki: Test Notification 🚀';

  @override
  String get notificationTestBody => 'Notification system is working properly!';

  @override
  String get settingsStudyReminders => 'STUDY REMINDERS';

  @override
  String get settingsDailyReminder => 'Daily Study Reminder';

  @override
  String get settingsDailyReminderSubtitle =>
      'Get notified on time to build and keep your flashcard study habit';

  @override
  String get settingsReminderTime => 'Reminder Time';

  @override
  String get settingsStreakSaver => 'Streak Saver 🔥';

  @override
  String get settingsStreakSaverSubtitle =>
      'Urgent reminder before midnight if not yet studied. Automatically dismissed if studied today.';

  @override
  String get settingsMinimizeToTray => 'Minimize to System Tray';

  @override
  String get settingsMinimizeToTraySubtitle =>
      'Closing the window (X) minimizes Flanki to tray to keep background reminder timers active.';

  @override
  String get settingsLaunchAtStartup => 'Launch at System Startup';

  @override
  String get settingsLaunchAtStartupSubtitle =>
      'Automatically start Flanki in background when logging into your computer.';

  @override
  String get settingsTestNotificationSent => 'Test notification sent!';

  @override
  String get settingsTestNotificationCheck =>
      'Check your system notification center or desktop toast.';

  @override
  String get settingsTestNotificationButton => 'Test Notification Now';

  @override
  String syncSuccessWithMedia(int deckCount, int cardCount, String media) {
    return 'Successfully downloaded $deckCount decks, $cardCount cards$media from AnkiWeb.';
  }

  @override
  String syncMediaCountPart(int count) {
    return ' and $count media files';
  }

  @override
  String syncMediaSyncedSuccess(int count) {
    return 'Successfully synced $count media files from AnkiWeb.';
  }

  @override
  String get syncCollectionAndMediaUpToDate =>
      'Deck collection and media are already in sync with AnkiWeb Cloud.';

  @override
  String get syncFirstTime => 'First-time initial sync.';

  @override
  String get syncLocalChangesToPush =>
      'This device has new study progress ready to push to AnkiWeb.';

  @override
  String get syncRemoteChangesToPull =>
      'AnkiWeb has newer study progress from another device ready to pull.';

  @override
  String get syncAlreadyFullySynced =>
      'Data between this device and AnkiWeb is already fully synchronized.';

  @override
  String get syncUploadSuccess =>
      'Successfully uploaded all collection data & review history to AnkiWeb Cloud.';

  @override
  String get syncNoMediaChanges => 'No new media changes.';

  @override
  String get syncAllMediaUpToDate => 'All media files are up to date.';

  @override
  String syncMediaDownloadedSuccess(int count) {
    return 'Successfully downloaded $count media files from AnkiWeb.';
  }

  @override
  String syncServerError(int statusCode, String message) {
    return 'AnkiWeb server error ($statusCode): $message';
  }

  @override
  String syncCheckStatusServerError(int statusCode) {
    return 'Server status check error ($statusCode).';
  }

  @override
  String syncCheckError(String error) {
    return 'Sync check error: $error';
  }

  @override
  String syncUploadError(String error) {
    return 'AnkiWeb upload error: $error';
  }

  @override
  String syncMediaError(String error) {
    return 'AnkiWeb media sync error: $error';
  }

  @override
  String syncMediaBatchError(String range, int statusCode, String message) {
    return 'Media batch download error ($range): $statusCode $message';
  }

  @override
  String syncCollectionError(String error) {
    return 'AnkiWeb sync error: $error';
  }
}
