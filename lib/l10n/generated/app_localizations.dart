import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('vi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Flanki'**
  String get appTitle;

  /// No description provided for @navDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// No description provided for @navBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get navBrowser;

  /// No description provided for @navGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get navGrammar;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @searchDecks.
  ///
  /// In en, this message translates to:
  /// **'Search decks...'**
  String get searchDecks;

  /// No description provided for @studyNow.
  ///
  /// In en, this message translates to:
  /// **'Study Now'**
  String get studyNow;

  /// No description provided for @customStudy.
  ///
  /// In en, this message translates to:
  /// **'Custom Study'**
  String get customStudy;

  /// No description provided for @addNewDeck.
  ///
  /// In en, this message translates to:
  /// **'Add New Deck'**
  String get addNewDeck;

  /// No description provided for @importApkg.
  ///
  /// In en, this message translates to:
  /// **'Import .apkg'**
  String get importApkg;

  /// No description provided for @syncAnkiWeb.
  ///
  /// In en, this message translates to:
  /// **'Sync AnkiWeb'**
  String get syncAnkiWeb;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @dueCards.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueCards;

  /// No description provided for @newCards.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCards;

  /// No description provided for @learningCards.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningCards;

  /// No description provided for @totalCards.
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// No description provided for @noDecksFound.
  ///
  /// In en, this message translates to:
  /// **'No decks found. Create one or import from AnkiWeb!'**
  String get noDecksFound;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Configuration'**
  String get settingsTitle;

  /// No description provided for @accountAndSync.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & SYNC'**
  String get accountAndSync;

  /// No description provided for @linkedAnkiWeb.
  ///
  /// In en, this message translates to:
  /// **'Linked with AnkiWeb'**
  String get linkedAnkiWeb;

  /// No description provided for @notLinkedAnkiWeb.
  ///
  /// In en, this message translates to:
  /// **'Not linked to AnkiWeb'**
  String get notLinkedAnkiWeb;

  /// No description provided for @loginToSyncHint.
  ///
  /// In en, this message translates to:
  /// **'Log in to sync cards and progress with the cloud.'**
  String get loginToSyncHint;

  /// No description provided for @readyToSync.
  ///
  /// In en, this message translates to:
  /// **'Ready to sync'**
  String get readyToSync;

  /// Time of last sync
  ///
  /// In en, this message translates to:
  /// **'Synced at: {time}'**
  String syncedAt(String time);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOut;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure session token removed from device.'**
  String get logoutSubtitle;

  /// No description provided for @connectAnkiWeb.
  ///
  /// In en, this message translates to:
  /// **'Connect AnkiWeb Account'**
  String get connectAnkiWeb;

  /// No description provided for @connectAnkiWebSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two-way sync for flashcards and learning progress with Anki servers.'**
  String get connectAnkiWebSubtitle;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'APP PREFERENCES'**
  String get appPreferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app display language'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme and visual customization'**
  String get appearanceSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @spacedRepetitionAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'SPACED REPETITION ENGINE'**
  String get spacedRepetitionAlgorithm;

  /// No description provided for @enableFsrs.
  ///
  /// In en, this message translates to:
  /// **'Enable FSRS v5'**
  String get enableFsrs;

  /// No description provided for @fsrsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optimized retention algorithm based on Difficulty, Stability, and Retrievability.'**
  String get fsrsSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'ABOUT FLANKI'**
  String get aboutSection;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @searchLicensesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search packages...'**
  String get searchLicensesPlaceholder;

  /// No description provided for @thirdPartyLicenses.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Packages ({count})'**
  String thirdPartyLicenses(int count);

  /// No description provided for @noLicensesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching packages found'**
  String get noLicensesFound;

  /// No description provided for @licenseCopied.
  ///
  /// In en, this message translates to:
  /// **'License copied to clipboard'**
  String get licenseCopied;

  /// No description provided for @searchCardsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search questions, answers, or tags...'**
  String get searchCardsPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get filterDue;

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// No description provided for @filterFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get filterFlagged;

  /// No description provided for @filterSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get filterSuspended;

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get noCardsFound;

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String cardsCount(int count);

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @studySessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have completed today\'\'s study session.'**
  String get studySessionComplete;

  /// No description provided for @studyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job! You finished'**
  String get studyCompleteTitle;

  /// No description provided for @studyCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed {count} cards in this session with FSRS algorithm.'**
  String studyCompleteDesc(int count);

  /// No description provided for @backToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to decks'**
  String get backToDecks;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to AnkiWeb'**
  String get authTitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get authLoggingIn;

  /// No description provided for @authSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get authSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get authFailed;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats & Progress'**
  String get statsTitle;

  /// No description provided for @retentionRate.
  ///
  /// In en, this message translates to:
  /// **'RETENTION RATE'**
  String get retentionRate;

  /// No description provided for @targetReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached'**
  String get targetReached;

  /// Target retention suffix for stats screen
  ///
  /// In en, this message translates to:
  /// **'/ {rate} target'**
  String targetSuffix(String rate);

  /// No description provided for @reviewedToday.
  ///
  /// In en, this message translates to:
  /// **'Reviewed today'**
  String get reviewedToday;

  /// No description provided for @reviewedDiff.
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed'**
  String get reviewedDiff;

  /// No description provided for @studyTime.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get studyTime;

  /// No description provided for @studyTimePerCard.
  ///
  /// In en, this message translates to:
  /// **'~15s per card'**
  String get studyTimePerCard;

  /// No description provided for @studyHistory.
  ///
  /// In en, this message translates to:
  /// **'Study history'**
  String get studyHistory;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String streakDays(int days);

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @studyQuestion.
  ///
  /// In en, this message translates to:
  /// **'QUESTION'**
  String get studyQuestion;

  /// No description provided for @studyAnswer.
  ///
  /// In en, this message translates to:
  /// **'ANSWER'**
  String get studyAnswer;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get tapToFlip;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left: Again • Swipe right: Good'**
  String get swipeHint;

  /// No description provided for @cardsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cards left: {count}'**
  String cardsRemaining(int count);

  /// No description provided for @studyAgain.
  ///
  /// In en, this message translates to:
  /// **'Study again'**
  String get studyAgain;

  /// No description provided for @cardActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Options'**
  String get cardActionTitle;

  /// No description provided for @flagSelector.
  ///
  /// In en, this message translates to:
  /// **'MARK WITH FLAG'**
  String get flagSelector;

  /// No description provided for @buryCard.
  ///
  /// In en, this message translates to:
  /// **'Bury card'**
  String get buryCard;

  /// No description provided for @suspendCard.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspendCard;

  /// No description provided for @editCardContent.
  ///
  /// In en, this message translates to:
  /// **'Edit card content'**
  String get editCardContent;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'FRONT'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backSide;

  /// No description provided for @addCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addCardTitle;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save card'**
  String get saveCard;

  /// No description provided for @noteType.
  ///
  /// In en, this message translates to:
  /// **'NOTE TYPE'**
  String get noteType;

  /// No description provided for @deckLabel.
  ///
  /// In en, this message translates to:
  /// **'DECK'**
  String get deckLabel;

  /// No description provided for @extraNotes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get extraNotes;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get tagsLabel;

  /// No description provided for @addTagPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add tag (e.g. toeic, grammar)...'**
  String get addTagPlaceholder;

  /// No description provided for @cramModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Cram Study'**
  String get cramModeTitle;

  /// No description provided for @cramModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Create an ad-hoc session filtered by tags or flags. Does not affect original FSRS schedules.'**
  String get cramModeDesc;

  /// No description provided for @filterMode.
  ///
  /// In en, this message translates to:
  /// **'CARD FILTER'**
  String get filterMode;

  /// No description provided for @byTag.
  ///
  /// In en, this message translates to:
  /// **'By Tag'**
  String get byTag;

  /// No description provided for @flaggedCards.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get flaggedCards;

  /// No description provided for @reviewAhead.
  ///
  /// In en, this message translates to:
  /// **'Review Ahead'**
  String get reviewAhead;

  /// No description provided for @cardLimit.
  ///
  /// In en, this message translates to:
  /// **'CARD LIMIT'**
  String get cardLimit;

  /// No description provided for @startCram.
  ///
  /// In en, this message translates to:
  /// **'Start cram session'**
  String get startCram;

  /// No description provided for @cramDeckCreated.
  ///
  /// In en, this message translates to:
  /// **'Cram Deck Created'**
  String get cramDeckCreated;

  /// No description provided for @cramDeckCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Filtered {count} cards for cram study (#{tag}).'**
  String cramDeckCreatedDesc(int count, String tag);

  /// No description provided for @streakDaysBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String streakDaysBadge(int count);

  /// Badge showing target retention rate on decks screen
  ///
  /// In en, this message translates to:
  /// **'Target {rate} retention'**
  String targetRetentionBadge(String rate);

  /// No description provided for @cramTagInputLabel.
  ///
  /// In en, this message translates to:
  /// **'TAG NAME TO STUDY'**
  String get cramTagInputLabel;

  /// No description provided for @cardsCountUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCountUnit(int count);

  /// No description provided for @cramButton.
  ///
  /// In en, this message translates to:
  /// **'Cram'**
  String get cramButton;

  /// No description provided for @linkedBadge.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkedBadge;

  /// No description provided for @syncBadge.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncBadge;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get syncError;

  /// No description provided for @importApkgSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import .apkg Successful'**
  String get importApkgSuccess;

  /// No description provided for @importApkgSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Imported {decks} decks, {cards} cards ({media} media files).'**
  String importApkgSuccessDesc(int decks, int cards, int media);

  /// No description provided for @importApkgError.
  ///
  /// In en, this message translates to:
  /// **'Import .apkg Error'**
  String get importApkgError;

  /// No description provided for @undoSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get undoSuccessTitle;

  /// No description provided for @undoSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Restored previous card rating.'**
  String get undoSuccessDesc;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @missingContent.
  ///
  /// In en, this message translates to:
  /// **'Missing Content'**
  String get missingContent;

  /// No description provided for @missingContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter question/front content.'**
  String get missingContentDesc;

  /// No description provided for @cardCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card Created'**
  String get cardCreatedSuccess;

  /// No description provided for @cardCreatedSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Added card to deck.'**
  String get cardCreatedSuccessDesc;

  /// No description provided for @basicNoteType.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicNoteType;

  /// No description provided for @basicNoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Question / Answer'**
  String get basicNoteSubtitle;

  /// No description provided for @clozeNoteType.
  ///
  /// In en, this message translates to:
  /// **'Cloze'**
  String get clozeNoteType;

  /// No description provided for @clozeNoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get clozeNoteSubtitle;

  /// No description provided for @reversedNoteType.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversedNoteType;

  /// No description provided for @reversedNoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two-way card'**
  String get reversedNoteSubtitle;

  /// No description provided for @clozeTextLabel.
  ///
  /// In en, this message translates to:
  /// **'TEXT'**
  String get clozeTextLabel;

  /// No description provided for @frontPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter question, vocabulary or concept...'**
  String get frontPlaceholder;

  /// No description provided for @clozePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'The capital of France is \'{{\'c1::Paris\'}}\'.'**
  String get clozePlaceholder;

  /// No description provided for @backPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter explanation, examples...'**
  String get backPlaceholder;

  /// No description provided for @authScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb Account'**
  String get authScreenTitle;

  /// No description provided for @authHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb Sync'**
  String get authHeaderTitle;

  /// No description provided for @authHeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Log in to your AnkiWeb account to synchronize decks, FSRS schedules, and study progress across devices.'**
  String get authHeaderDesc;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'ANKIWEB EMAIL'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter password...'**
  String get authPasswordPlaceholder;

  /// No description provided for @authSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Log In & Start Sync'**
  String get authSubmitButton;

  /// No description provided for @authSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authSubmitting;

  /// No description provided for @authMissingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing Credentials'**
  String get authMissingInfoTitle;

  /// No description provided for @authMissingInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Please provide both AnkiWeb email and password.'**
  String get authMissingInfoDesc;

  /// No description provided for @authSuccessToastTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get authSuccessToastTitle;

  /// No description provided for @authSuccessToastDesc.
  ///
  /// In en, this message translates to:
  /// **'Linked account {email} with Flanki.'**
  String authSuccessToastDesc(String email);

  /// No description provided for @authGuestMode.
  ///
  /// In en, this message translates to:
  /// **'Try Offline'**
  String get authGuestMode;

  /// No description provided for @authSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Security: Flanki stores only your session HostKey securely on device, never your raw password.'**
  String get authSecurityNote;

  /// No description provided for @intervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String intervalMinutes(int count);

  /// No description provided for @intervalHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String intervalHours(int count);

  /// No description provided for @intervalDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String intervalDays(int count);

  /// No description provided for @intervalMonths.
  ///
  /// In en, this message translates to:
  /// **'{count}mo'**
  String intervalMonths(String count);

  /// No description provided for @intervalYears.
  ///
  /// In en, this message translates to:
  /// **'{count}y'**
  String intervalYears(String count);

  /// No description provided for @deckPrefix.
  ///
  /// In en, this message translates to:
  /// **'Deck: {deck}'**
  String deckPrefix(String deck);

  /// No description provided for @intervalBadge.
  ///
  /// In en, this message translates to:
  /// **'{days}d interval'**
  String intervalBadge(int days);

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @studyMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String studyMinutesUnit(int count);

  /// No description provided for @targetNotReached.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get targetNotReached;

  /// No description provided for @targetRetentionRate.
  ///
  /// In en, this message translates to:
  /// **'Target {rate}'**
  String targetRetentionRate(String rate);

  /// No description provided for @algorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithmLabel;

  /// No description provided for @themeZinc.
  ///
  /// In en, this message translates to:
  /// **'Zinc Theme'**
  String get themeZinc;

  /// No description provided for @ankiRustCore.
  ///
  /// In en, this message translates to:
  /// **'Anki Rust Core'**
  String get ankiRustCore;

  /// No description provided for @createDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeckTitle;

  /// No description provided for @createDeckDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a new deck to organize your flashcards.'**
  String get createDeckDesc;

  /// No description provided for @deckNameLabel.
  ///
  /// In en, this message translates to:
  /// **'DECK NAME'**
  String get deckNameLabel;

  /// No description provided for @deckNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. English::Vocabulary'**
  String get deckNamePlaceholder;

  /// No description provided for @deckDescLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION (OPTIONAL)'**
  String get deckDescLabel;

  /// No description provided for @deckDescPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Short description of this deck...'**
  String get deckDescPlaceholder;

  /// No description provided for @deckCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deck Created'**
  String get deckCreatedSuccess;

  /// No description provided for @deckCreatedSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Deck \"{name}\" has been created.'**
  String deckCreatedSuccessDesc(String name);

  /// No description provided for @deckNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a deck name.'**
  String get deckNameRequired;

  /// No description provided for @deckAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A deck with this name already exists.'**
  String get deckAlreadyExists;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card? This action cannot be undone.'**
  String get deleteCardConfirm;

  /// No description provided for @cardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get cardDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sm2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Traditional SM-2 algorithm'**
  String get sm2Subtitle;

  /// No description provided for @selectApkgOrZipPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select an .apkg or .zip file'**
  String get selectApkgOrZipPrompt;

  /// No description provided for @subdecksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subdecks'**
  String subdecksCount(int count);

  /// No description provided for @importedFromApkg.
  ///
  /// In en, this message translates to:
  /// **'Imported from Anki .apkg package'**
  String get importedFromApkg;

  /// No description provided for @badgeDue.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String badgeDue(int count);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String badgeNew(int count);

  /// No description provided for @badgeTotalCards.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String badgeTotalCards(int count);

  /// No description provided for @createDeckAction.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeckAction;

  /// No description provided for @importApkgAction.
  ///
  /// In en, this message translates to:
  /// **'Import Anki (.apkg)'**
  String get importApkgAction;

  /// No description provided for @cramAction.
  ///
  /// In en, this message translates to:
  /// **'Cram Study'**
  String get cramAction;

  /// No description provided for @deckHierarchyTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use :: to create hierarchy (e.g. English::Unit 01)'**
  String get deckHierarchyTip;

  /// No description provided for @typeAnswerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get typeAnswerPlaceholder;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswerLabel;

  /// No description provided for @yourAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'You typed: '**
  String get yourAnswerLabel;

  /// No description provided for @expectedAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: '**
  String get expectedAnswerLabel;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer: '**
  String get answerLabel;

  /// No description provided for @stabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stabilityLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @lapsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Lapses'**
  String get lapsesLabel;

  /// No description provided for @newCardsPerDay.
  ///
  /// In en, this message translates to:
  /// **'New cards per day'**
  String get newCardsPerDay;

  /// No description provided for @maxReviewsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Maximum reviews per day'**
  String get maxReviewsPerDay;

  /// No description provided for @selectCardToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Select a card on the left to view and edit details'**
  String get selectCardToViewDetails;

  /// No description provided for @unsuspendCard.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspendCard;

  /// No description provided for @fsrsScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'FSRS ALGORITHM & SCHEDULE'**
  String get fsrsScheduleTitle;

  /// No description provided for @intervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalLabel;

  /// No description provided for @repsAndLapsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps / Lapses'**
  String get repsAndLapsesLabel;

  /// No description provided for @dartCoreEngine.
  ///
  /// In en, this message translates to:
  /// **'Dart (Drift SQLite)'**
  String get dartCoreEngine;

  /// No description provided for @submitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitAnswer;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

  /// No description provided for @hideAnswer.
  ///
  /// In en, this message translates to:
  /// **'Hide Answer'**
  String get hideAnswer;

  /// No description provided for @syncMediaOnly.
  ///
  /// In en, this message translates to:
  /// **'Sync Media (Images & Audio)'**
  String get syncMediaOnly;

  /// No description provided for @syncingMedia.
  ///
  /// In en, this message translates to:
  /// **'Syncing media files...'**
  String get syncingMedia;

  /// No description provided for @addCardButton.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardButton;

  /// No description provided for @clozeDeletion.
  ///
  /// In en, this message translates to:
  /// **'Cloze Deletion'**
  String get clozeDeletion;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @syncConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb Sync Conflict'**
  String get syncConflictTitle;

  /// No description provided for @syncConflictDesc.
  ///
  /// In en, this message translates to:
  /// **'Both this device and AnkiWeb have new study progress or card changes since the last sync. The system cannot automatically merge two independent sessions.'**
  String get syncConflictDesc;

  /// No description provided for @previousSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous sync:'**
  String get previousSyncLabel;

  /// No description provided for @ankiWebUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb update:'**
  String get ankiWebUpdateLabel;

  /// No description provided for @selectVersionToKeep.
  ///
  /// In en, this message translates to:
  /// **'Please select which version of data you want to keep:'**
  String get selectVersionToKeep;

  /// No description provided for @mergeCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Merge (Recommended)'**
  String get mergeCollectionsTitle;

  /// No description provided for @mergeCollectionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep all study logs from both devices and retain the most recent progress for each card.'**
  String get mergeCollectionsDesc;

  /// No description provided for @recommendedBadge.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedBadge;

  /// No description provided for @uploadToCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload to AnkiWeb (Overwrite Cloud)'**
  String get uploadToCloudTitle;

  /// No description provided for @uploadToCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep all progress and review history on this device and overwrite AnkiWeb Cloud.'**
  String get uploadToCloudDesc;

  /// No description provided for @downloadFromCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Download from AnkiWeb (Overwrite Device)'**
  String get downloadFromCloudTitle;

  /// No description provided for @downloadFromCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Download all data from AnkiWeb Cloud and replace the local data on this device.'**
  String get downloadFromCloudDesc;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownTime;

  /// No description provided for @preparingUpload.
  ///
  /// In en, this message translates to:
  /// **'Preparing to upload to AnkiWeb...'**
  String get preparingUpload;

  /// No description provided for @connectingToAnkiWeb.
  ///
  /// In en, this message translates to:
  /// **'Connecting to AnkiWeb...'**
  String get connectingToAnkiWeb;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateChangelog.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get updateChangelog;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update installer...'**
  String get downloadingUpdate;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @openDownloadPage.
  ///
  /// In en, this message translates to:
  /// **'Open Download Page'**
  String get openDownloadPage;

  /// No description provided for @restartAndInstall.
  ///
  /// In en, this message translates to:
  /// **'Restart & Update'**
  String get restartAndInstall;

  /// No description provided for @downloadAndInstall.
  ///
  /// In en, this message translates to:
  /// **'Download & Update'**
  String get downloadAndInstall;

  /// Title of update banner toast
  ///
  /// In en, this message translates to:
  /// **'A new update is available (v{version})'**
  String updateBannerTitle(String version);

  /// No description provided for @updateBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click to view details and update'**
  String get updateBannerSubtitle;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checkingForUpdates;

  /// New version badge
  ///
  /// In en, this message translates to:
  /// **'New v{version}'**
  String newVersionBadge(String version);

  /// No description provided for @latestVersionStatus.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get latestVersionStatus;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkForUpdates;

  /// No description provided for @cramDeckDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Cram study deck without affecting primary FSRS schedule.'**
  String get cramDeckDefaultDesc;

  /// No description provided for @importedDeckDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Imported from Anki package .apkg'**
  String get importedDeckDefaultDesc;

  /// No description provided for @authEmailPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email and password cannot be empty.'**
  String get authEmailPasswordEmpty;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect AnkiWeb email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Please try again in a few minutes.'**
  String get authTooManyAttempts;

  /// No description provided for @authServerResponseInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from AnkiWeb server.'**
  String get authServerResponseInvalid;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to AnkiWeb server. Please check your network: {error}'**
  String authNetworkError(String error);

  /// No description provided for @authUnknownError.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb connection error: {error}'**
  String authUnknownError(String error);

  /// No description provided for @syncConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to AnkiWeb...'**
  String get syncConnecting;

  /// No description provided for @syncDownloadingCollection.
  ///
  /// In en, this message translates to:
  /// **'Downloading collection data from AnkiWeb...'**
  String get syncDownloadingCollection;

  /// No description provided for @syncProcessingData.
  ///
  /// In en, this message translates to:
  /// **'Processing cards & saving database...'**
  String get syncProcessingData;

  /// No description provided for @syncCheckingMedia.
  ///
  /// In en, this message translates to:
  /// **'Checking media files (images & audio)...'**
  String get syncCheckingMedia;

  /// No description provided for @syncDownloadingMediaProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading media ({downloaded}/{total})...'**
  String syncDownloadingMediaProgress(int downloaded, int total);

  /// No description provided for @syncCompressingUpload.
  ///
  /// In en, this message translates to:
  /// **'Compressing and preparing upload to AnkiWeb...'**
  String get syncCompressingUpload;

  /// No description provided for @syncUploadingCloud.
  ///
  /// In en, this message translates to:
  /// **'Uploading data to AnkiWeb Cloud...'**
  String get syncUploadingCloud;

  /// No description provided for @syncUploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Upload complete!'**
  String get syncUploadComplete;

  /// No description provided for @syncSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb session expired. Please log in again.'**
  String get syncSessionExpired;

  /// No description provided for @syncNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get syncNoInternet;

  /// No description provided for @syncConflictDetected.
  ///
  /// In en, this message translates to:
  /// **'Conflict detected: Both AnkiWeb and this device have new study data.'**
  String get syncConflictDetected;

  /// No description provided for @trayOpenFlanki.
  ///
  /// In en, this message translates to:
  /// **'Open Flanki'**
  String get trayOpenFlanki;

  /// No description provided for @trayStudyNow.
  ///
  /// In en, this message translates to:
  /// **'Study Now'**
  String get trayStudyNow;

  /// No description provided for @trayExit.
  ///
  /// In en, this message translates to:
  /// **'Quit Flanki'**
  String get trayExit;

  /// No description provided for @notificationDailyChannelName.
  ///
  /// In en, this message translates to:
  /// **'Study Reminder'**
  String get notificationDailyChannelName;

  /// No description provided for @notificationDailyChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily flashcard study reminders'**
  String get notificationDailyChannelDesc;

  /// No description provided for @notificationDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to study with Flanki! 🦉'**
  String get notificationDailyTitle;

  /// No description provided for @notificationDailyBodyDue.
  ///
  /// In en, this message translates to:
  /// **'You have {count} cards waiting for review today. Review now to remember longer!'**
  String notificationDailyBodyDue(int count);

  /// No description provided for @notificationDailyBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Spend 5 minutes a day with Flanki to keep your memory sharp!'**
  String get notificationDailyBodyGeneric;

  /// No description provided for @notificationStreakChannelName.
  ///
  /// In en, this message translates to:
  /// **'Streak Saver'**
  String get notificationStreakChannelName;

  /// No description provided for @notificationStreakChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Urgent reminder before midnight to protect your study streak'**
  String get notificationStreakChannelDesc;

  /// No description provided for @notificationStreakTitleActive.
  ///
  /// In en, this message translates to:
  /// **'Save your {count}-day streak! 🔥'**
  String notificationStreakTitleActive(int count);

  /// No description provided for @notificationStreakTitleInactive.
  ///
  /// In en, this message translates to:
  /// **'You haven\'\'t studied today! ⏳'**
  String get notificationStreakTitleInactive;

  /// No description provided for @notificationStreakBodyActive.
  ///
  /// In en, this message translates to:
  /// **'Only a few hours left before midnight! Study for 3 minutes to keep your streak.'**
  String get notificationStreakBodyActive;

  /// No description provided for @notificationStreakBodyInactive.
  ///
  /// In en, this message translates to:
  /// **'Spend a few minutes before the day ends to start a new streak!'**
  String get notificationStreakBodyInactive;

  /// No description provided for @notificationTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Flanki: Test Notification 🚀'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In en, this message translates to:
  /// **'Notification system is working properly!'**
  String get notificationTestBody;

  /// No description provided for @settingsStudyReminders.
  ///
  /// In en, this message translates to:
  /// **'STUDY REMINDERS'**
  String get settingsStudyReminders;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified on time to build and keep your flashcard study habit'**
  String get settingsDailyReminderSubtitle;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settingsReminderTime;

  /// No description provided for @settingsStreakSaver.
  ///
  /// In en, this message translates to:
  /// **'Streak Saver 🔥'**
  String get settingsStreakSaver;

  /// No description provided for @settingsStreakSaverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent reminder before midnight if not yet studied. Automatically dismissed if studied today.'**
  String get settingsStreakSaverSubtitle;

  /// No description provided for @settingsMinimizeToTray.
  ///
  /// In en, this message translates to:
  /// **'Minimize to System Tray'**
  String get settingsMinimizeToTray;

  /// No description provided for @settingsMinimizeToTraySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Closing the window (X) minimizes Flanki to tray to keep background reminder timers active.'**
  String get settingsMinimizeToTraySubtitle;

  /// No description provided for @settingsLaunchAtStartup.
  ///
  /// In en, this message translates to:
  /// **'Launch at System Startup'**
  String get settingsLaunchAtStartup;

  /// No description provided for @settingsLaunchAtStartupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically start Flanki in background when logging into your computer.'**
  String get settingsLaunchAtStartupSubtitle;

  /// No description provided for @settingsTestNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get settingsTestNotificationSent;

  /// No description provided for @settingsTestNotificationCheck.
  ///
  /// In en, this message translates to:
  /// **'Check your system notification center or desktop toast.'**
  String get settingsTestNotificationCheck;

  /// No description provided for @settingsTestNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Test Notification Now'**
  String get settingsTestNotificationButton;

  /// No description provided for @syncSuccessWithMedia.
  ///
  /// In en, this message translates to:
  /// **'Successfully downloaded {deckCount} decks, {cardCount} cards{media} from AnkiWeb.'**
  String syncSuccessWithMedia(int deckCount, int cardCount, String media);

  /// No description provided for @syncMediaCountPart.
  ///
  /// In en, this message translates to:
  /// **' and {count} media files'**
  String syncMediaCountPart(int count);

  /// No description provided for @syncMediaSyncedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {count} media files from AnkiWeb.'**
  String syncMediaSyncedSuccess(int count);

  /// No description provided for @syncCollectionAndMediaUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Deck collection and media are already in sync with AnkiWeb Cloud.'**
  String get syncCollectionAndMediaUpToDate;

  /// No description provided for @syncFirstTime.
  ///
  /// In en, this message translates to:
  /// **'First-time initial sync.'**
  String get syncFirstTime;

  /// No description provided for @syncLocalChangesToPush.
  ///
  /// In en, this message translates to:
  /// **'This device has new study progress ready to push to AnkiWeb.'**
  String get syncLocalChangesToPush;

  /// No description provided for @syncRemoteChangesToPull.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb has newer study progress from another device ready to pull.'**
  String get syncRemoteChangesToPull;

  /// No description provided for @syncAlreadyFullySynced.
  ///
  /// In en, this message translates to:
  /// **'Data between this device and AnkiWeb is already fully synchronized.'**
  String get syncAlreadyFullySynced;

  /// No description provided for @syncUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully uploaded all collection data & review history to AnkiWeb Cloud.'**
  String get syncUploadSuccess;

  /// No description provided for @syncNoMediaChanges.
  ///
  /// In en, this message translates to:
  /// **'No new media changes.'**
  String get syncNoMediaChanges;

  /// No description provided for @syncAllMediaUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All media files are up to date.'**
  String get syncAllMediaUpToDate;

  /// No description provided for @syncMediaDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully downloaded {count} media files from AnkiWeb.'**
  String syncMediaDownloadedSuccess(int count);

  /// No description provided for @syncServerError.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb server error ({statusCode}): {message}'**
  String syncServerError(int statusCode, String message);

  /// No description provided for @syncCheckStatusServerError.
  ///
  /// In en, this message translates to:
  /// **'Server status check error ({statusCode}).'**
  String syncCheckStatusServerError(int statusCode);

  /// No description provided for @syncCheckError.
  ///
  /// In en, this message translates to:
  /// **'Sync check error: {error}'**
  String syncCheckError(String error);

  /// No description provided for @syncUploadError.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb upload error: {error}'**
  String syncUploadError(String error);

  /// No description provided for @syncMediaError.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb media sync error: {error}'**
  String syncMediaError(String error);

  /// No description provided for @syncMediaBatchError.
  ///
  /// In en, this message translates to:
  /// **'Media batch download error ({range}): {statusCode} {message}'**
  String syncMediaBatchError(String range, int statusCode, String message);

  /// No description provided for @syncCollectionError.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb sync error: {error}'**
  String syncCollectionError(String error);

  /// No description provided for @cramDeckTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'⚡ Cram: {name}'**
  String cramDeckTitlePrefix(String name);

  /// No description provided for @cramDeckTitleWithTag.
  ///
  /// In en, this message translates to:
  /// **'⚡ Cram: {name} (#{tag})'**
  String cramDeckTitleWithTag(String name, String tag);

  /// No description provided for @grammarAcademicTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Grammar'**
  String get grammarAcademicTitle;

  /// No description provided for @grammarAcademicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'36 C1/C2 Units for SAT • GRE • GMAT • Advanced High School'**
  String get grammarAcademicSubtitle;

  /// No description provided for @grammarClearGhostsButton.
  ///
  /// In en, this message translates to:
  /// **'Clear {count} Ghost Errors'**
  String grammarClearGhostsButton(int count);

  /// No description provided for @grammarMetricTotalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total Units'**
  String get grammarMetricTotalUnits;

  /// No description provided for @grammarMetricCompletedExercises.
  ///
  /// In en, this message translates to:
  /// **'Completed Exercises'**
  String get grammarMetricCompletedExercises;

  /// No description provided for @grammarMetricDueGhosts.
  ///
  /// In en, this message translates to:
  /// **'Due / Ghost'**
  String get grammarMetricDueGhosts;

  /// No description provided for @grammarSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search units, tenses, structures...'**
  String get grammarSearchPlaceholder;

  /// No description provided for @grammarFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String grammarFilterAll(int count);

  /// No description provided for @grammarTheoryButton.
  ///
  /// In en, this message translates to:
  /// **'Theory'**
  String get grammarTheoryButton;

  /// No description provided for @grammarPracticeButton.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get grammarPracticeButton;

  /// No description provided for @grammarMasteryPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Mastery'**
  String grammarMasteryPercentage(String percentage);

  /// No description provided for @grammarCompletedProgress.
  ///
  /// In en, this message translates to:
  /// **'Completed: {completed} / {total}'**
  String grammarCompletedProgress(int completed, int total);

  /// No description provided for @grammarErrorLoadCatalog.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grammar catalog: {error}'**
  String grammarErrorLoadCatalog(String error);

  /// No description provided for @grammarTheoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Unit Theory'**
  String get grammarTheoryScreenTitle;

  /// No description provided for @grammarPracticeCountButton.
  ///
  /// In en, this message translates to:
  /// **'Practice ({count} Qs)'**
  String grammarPracticeCountButton(int count);

  /// No description provided for @grammarStartPracticeNowButton.
  ///
  /// In en, this message translates to:
  /// **'Start Practicing {count} Questions Now'**
  String grammarStartPracticeNowButton(int count);

  /// No description provided for @grammarCoreConceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Core Native Mindset'**
  String get grammarCoreConceptTitle;

  /// No description provided for @grammarFormulasTitle.
  ///
  /// In en, this message translates to:
  /// **'Syntax & Formulas'**
  String get grammarFormulasTitle;

  /// No description provided for @grammarCommonTrapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic Exam Traps'**
  String get grammarCommonTrapsTitle;

  /// No description provided for @grammarExtraGuidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Deep Dive Guides'**
  String get grammarExtraGuidesTitle;

  /// No description provided for @grammarUnitNotFound.
  ///
  /// In en, this message translates to:
  /// **'Grammar unit not found.'**
  String get grammarUnitNotFound;

  /// No description provided for @grammarErrorLoadUnit.
  ///
  /// In en, this message translates to:
  /// **'Failed to load unit: {error}'**
  String grammarErrorLoadUnit(String error);

  /// No description provided for @grammarPracticeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Practice'**
  String get grammarPracticeScreenTitle;

  /// No description provided for @grammarGhostReviewScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ghost Review Challenge'**
  String get grammarGhostReviewScreenTitle;

  /// No description provided for @grammarQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String grammarQuestionCounter(int current, int total);

  /// No description provided for @grammarSubmitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check Answer'**
  String get grammarSubmitAnswer;

  /// No description provided for @grammarExitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Practice Session?'**
  String get grammarExitDialogTitle;

  /// No description provided for @grammarExitDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your progress for completed questions has been saved into FSRS. Are you sure you want to exit now?'**
  String get grammarExitDialogContent;

  /// No description provided for @grammarContinueStudying.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing'**
  String get grammarContinueStudying;

  /// No description provided for @grammarExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get grammarExitConfirm;

  /// No description provided for @grammarPracticeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Session Summary'**
  String get grammarPracticeSummaryTitle;

  /// No description provided for @grammarGhostChallengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ghost Challenge Completed!'**
  String get grammarGhostChallengeCompleted;

  /// No description provided for @grammarPerfectScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Brilliant! 100% Perfect!'**
  String get grammarPerfectScoreTitle;

  /// No description provided for @grammarUnitSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lesson Completed!'**
  String get grammarUnitSessionCompleted;

  /// No description provided for @grammarGhostChallengeCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You reviewed all previously failed questions.'**
  String get grammarGhostChallengeCompletedSubtitle;

  /// No description provided for @grammarUnitSessionCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FSRS v4.5 memory intervals have been updated in your brain.'**
  String get grammarUnitSessionCompletedSubtitle;

  /// No description provided for @grammarStatCorrectCount.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get grammarStatCorrectCount;

  /// No description provided for @grammarStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get grammarStatAccuracy;

  /// No description provided for @grammarStatGhostsToFix.
  ///
  /// In en, this message translates to:
  /// **'Ghosts to Fix'**
  String get grammarStatGhostsToFix;

  /// No description provided for @grammarFixGhostsNow.
  ///
  /// In en, this message translates to:
  /// **'Fix Weaknesses Now ({count} ghosts)'**
  String grammarFixGhostsNow(int count);

  /// No description provided for @grammarBackToCatalog.
  ///
  /// In en, this message translates to:
  /// **'Back to Catalog'**
  String get grammarBackToCatalog;

  /// No description provided for @grammarRestartSession.
  ///
  /// In en, this message translates to:
  /// **'Practice Again'**
  String get grammarRestartSession;

  /// No description provided for @grammarAnswerCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct! Great job!'**
  String get grammarAnswerCorrect;

  /// No description provided for @grammarAnswerIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect — Remember this trap!'**
  String get grammarAnswerIncorrect;

  /// No description provided for @grammarSectionTranslation.
  ///
  /// In en, this message translates to:
  /// **'Sentence Translation'**
  String get grammarSectionTranslation;

  /// No description provided for @grammarSectionKeySignal.
  ///
  /// In en, this message translates to:
  /// **'Key Recognition Signal'**
  String get grammarSectionKeySignal;

  /// No description provided for @grammarSectionRule.
  ///
  /// In en, this message translates to:
  /// **'Native Grammar Rule'**
  String get grammarSectionRule;

  /// No description provided for @grammarSectionWhyCorrect.
  ///
  /// In en, this message translates to:
  /// **'Detailed Explanation'**
  String get grammarSectionWhyCorrect;

  /// No description provided for @grammarSectionDistractors.
  ///
  /// In en, this message translates to:
  /// **'Exam Distractor Breakdown'**
  String get grammarSectionDistractors;

  /// No description provided for @grammarNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get grammarNextQuestion;

  /// No description provided for @grammarViewResults.
  ///
  /// In en, this message translates to:
  /// **'View Summary'**
  String get grammarViewResults;

  /// No description provided for @grammarErrorIdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Find 1 grammatical error among [A], [B], [C], [D]'**
  String get grammarErrorIdInstruction;

  /// No description provided for @grammarClozeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Fill in the correct form of the word in the blank'**
  String get grammarClozeInstruction;

  /// No description provided for @grammarClozePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter correct word/phrase...'**
  String get grammarClozePlaceholder;

  /// No description provided for @grammarClozeSubmittedCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get grammarClozeSubmittedCorrect;

  /// No description provided for @grammarClozeSubmittedIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get grammarClozeSubmittedIncorrect;

  /// No description provided for @grammarClozeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: \"{answer}\"'**
  String grammarClozeYourAnswer(String answer);

  /// No description provided for @grammarClozeStandardAnswer.
  ///
  /// In en, this message translates to:
  /// **'Standard answer: '**
  String get grammarClozeStandardAnswer;

  /// No description provided for @grammarClozeBlank.
  ///
  /// In en, this message translates to:
  /// **'(Blank)'**
  String get grammarClozeBlank;

  /// No description provided for @grammarTypeChoice.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLE CHOICE'**
  String get grammarTypeChoice;

  /// No description provided for @grammarTypeErrorId.
  ///
  /// In en, this message translates to:
  /// **'FIND THE ERROR'**
  String get grammarTypeErrorId;

  /// No description provided for @grammarTypeCloze.
  ///
  /// In en, this message translates to:
  /// **'FILL IN THE BLANK'**
  String get grammarTypeCloze;

  /// No description provided for @grammarLevelFoundation.
  ///
  /// In en, this message translates to:
  /// **'Level 1: Foundation'**
  String get grammarLevelFoundation;

  /// No description provided for @grammarLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Level 2: Intermediate'**
  String get grammarLevelIntermediate;

  /// No description provided for @grammarLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Level 3: Advanced C1/C2'**
  String get grammarLevelAdvanced;

  /// No description provided for @privacyPolicyTagline.
  ///
  /// In en, this message translates to:
  /// **'Local-First • Zero Tracking • Open Source'**
  String get privacyPolicyTagline;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Local-First Storage'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'All your decks, flashcards, study schedules, and review history are stored locally on your device via SQLite. Flanki does not transmit your personal flashcard content to any developer servers.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Zero Tracking & No Ads'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'We do not integrate any third-party tracking frameworks, behavioral analytics SDKs (e.g., Google Analytics, Firebase, Sentry), or advertising networks. We do not sell or monetize your personal data.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Optional AnkiWeb Sync'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'If you choose to log in and synchronize with AnkiWeb, your credentials and collection data are transmitted directly between your device and official AnkiWeb servers over encrypted HTTPS. Authentication tokens are saved in platform-native secure vaults (Android Keystore, iOS Keychain, Windows DPAPI). We never store or access your password.'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. App Update Checks'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'Flanki periodically checks the public GitHub Releases API to notify you when a new version is available. No user-identifying information or device fingerprints are sent during update checks.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Local Notifications'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'Daily study reminders and streak notifications are scheduled strictly on your local device. No remote push notification servers are used.'**
  String get privacySection5Content;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Data Control & Deletion'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Content.
  ///
  /// In en, this message translates to:
  /// **'You retain 100% control of your data. You can delete decks, clear app data, or uninstall the app at any time to instantly remove all stored content.'**
  String get privacySection6Content;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Full Policy & Source Code'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Content.
  ///
  /// In en, this message translates to:
  /// **'Flanki is an open-source project. You can inspect our complete source code and read our full legal Privacy Policy at: https://github.com/zoroneo/flanki'**
  String get privacySection7Content;

  /// No description provided for @grammarTableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of Contents'**
  String get grammarTableOfContents;

  /// No description provided for @grammarShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts & Guide'**
  String get grammarShortcutsTitle;

  /// No description provided for @grammarShortcutSelectCheck.
  ///
  /// In en, this message translates to:
  /// **'Select & check option'**
  String get grammarShortcutSelectCheck;

  /// No description provided for @grammarShortcutNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get grammarShortcutNextQuestion;

  /// No description provided for @grammarPracticeTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Tip'**
  String get grammarPracticeTipTitle;

  /// No description provided for @grammarTipChoice.
  ///
  /// In en, this message translates to:
  /// **'Carefully read the sentence and look for keywords or tense markers before picking an option.'**
  String get grammarTipChoice;

  /// No description provided for @grammarTipErrorId.
  ///
  /// In en, this message translates to:
  /// **'Identify the grammatically incorrect segment among underlined parts A, B, C, D.'**
  String get grammarTipErrorId;

  /// No description provided for @grammarTipCloze.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank with the appropriate word to make the sentence grammatically complete.'**
  String get grammarTipCloze;

  /// No description provided for @grammarGhostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Ghost'**
  String grammarGhostsCount(int count);

  /// No description provided for @grammarUnitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Units'**
  String grammarUnitsCount(int count);

  /// No description provided for @grammarBadgeDue.
  ///
  /// In en, this message translates to:
  /// **'{count} Due'**
  String grammarBadgeDue(int count);

  /// No description provided for @grammarOptionBadge.
  ///
  /// In en, this message translates to:
  /// **'Option {letter}'**
  String grammarOptionBadge(String letter);

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download installer'**
  String get updateDownloadFailed;

  /// No description provided for @desktopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Desktop • Zinc'**
  String get desktopSubtitle;

  /// No description provided for @rslibLinked.
  ///
  /// In en, this message translates to:
  /// **'rslib (Linked)'**
  String get rslibLinked;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
