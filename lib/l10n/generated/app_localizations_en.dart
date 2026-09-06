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
  String get languageSystem => 'System Default';

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
  String get themeSystem => 'System';

  @override
  String get spacedRepetitionAlgorithm => 'SPACED REPETITION (SRS)';

  @override
  String get enableFsrs => 'Enable FSRS v4.5';

  @override
  String get fsrsSubtitle =>
      'Modern spaced repetition algorithm superior to Anki\'s classic SM-2.';

  @override
  String get aboutSection => 'ABOUT';

  @override
  String get appVersion => 'Version';

  @override
  String get cardBrowserTitle => 'Card Browser';

  @override
  String get searchCardsPlaceholder => 'Search by keyword, tag...';

  @override
  String get filterAll => 'All';

  @override
  String get filterDue => 'Due';

  @override
  String get filterNew => 'New';

  @override
  String cardsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0';
  }

  @override
  String get showAnswer => 'Show Answer';

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
      'Congratulations! You have finished studying for now.';

  @override
  String get backToDecks => 'Back to Decks';

  @override
  String get authTitle => 'AnkiWeb Login';

  @override
  String get authEmail => 'AnkiWeb Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authLoginButton => 'Log In';

  @override
  String get authLoggingIn => 'Logging in...';

  @override
  String get authSuccess => 'Login successful!';

  @override
  String get authFailed => 'Login failed. Please check your credentials.';
}
