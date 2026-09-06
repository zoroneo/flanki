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

  /// No description provided for @targetSuffix.
  ///
  /// In en, this message translates to:
  /// **'/ 85% target'**
  String get targetSuffix;

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
  /// **'Tap screen to flip card'**
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

  /// No description provided for @targetRetentionBadge.
  ///
  /// In en, this message translates to:
  /// **'Target 85% retention'**
  String get targetRetentionBadge;

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
