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
  /// **'System Default'**
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
  /// **'System'**
  String get themeSystem;

  /// No description provided for @spacedRepetitionAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'SPACED REPETITION (SRS)'**
  String get spacedRepetitionAlgorithm;

  /// No description provided for @enableFsrs.
  ///
  /// In en, this message translates to:
  /// **'Enable FSRS v4.5'**
  String get enableFsrs;

  /// No description provided for @fsrsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Modern spaced repetition algorithm superior to Anki\'\'s classic SM-2.'**
  String get fsrsSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutSection;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @cardBrowserTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Browser'**
  String get cardBrowserTitle;

  /// No description provided for @searchCardsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by keyword, tag...'**
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

  /// Pluralized cards count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 cards} =1{1 card} other{{count} cards}}'**
  String cardsCount(num count);

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

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
  /// **'Congratulations! You have finished studying for now.'**
  String get studySessionComplete;

  /// No description provided for @backToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to Decks'**
  String get backToDecks;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb Login'**
  String get authTitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'AnkiWeb Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginButton;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get authLoggingIn;

  /// No description provided for @authSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get authSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get authFailed;
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
