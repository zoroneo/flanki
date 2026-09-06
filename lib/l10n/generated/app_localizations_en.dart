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
  String get targetSuffix => '/ 85% target';

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
  String get targetRetentionBadge => 'Target 85% retention';

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
}
