import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('it'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'repetita'**
  String get appTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navHome;

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

  /// No description provided for @noDecksYet.
  ///
  /// In en, this message translates to:
  /// **'No decks yet. Tap + to create one.'**
  String get noDecksYet;

  /// No description provided for @createFirstDeckPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck to begin spaced repetition studying.'**
  String get createFirstDeckPrompt;

  /// No description provided for @createDeck.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeck;

  /// No description provided for @newDeck.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get newDeck;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Deck Name'**
  String get deckName;

  /// No description provided for @deckDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get deckDescription;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String dueCount(int count);

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @cardFront.
  ///
  /// In en, this message translates to:
  /// **'Front (Question / Prompt)'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In en, this message translates to:
  /// **'Back (Answer / Explanation)'**
  String get cardBack;

  /// No description provided for @deleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card?'**
  String get deleteCardConfirmation;

  /// No description provided for @studySessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Session'**
  String get studySessionTitle;

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

  /// No description provided for @retentionRate.
  ///
  /// In en, this message translates to:
  /// **'Retention Rate'**
  String get retentionRate;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// No description provided for @stateNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get stateNew;

  /// No description provided for @stateLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get stateLearning;

  /// No description provided for @stateReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stateReview;

  /// No description provided for @stateRelearning.
  ///
  /// In en, this message translates to:
  /// **'Relearning'**
  String get stateRelearning;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Transfer'**
  String get backupTitle;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export JSON Backup'**
  String get exportBackup;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an offline JSON backup of all your decks, cards, and review histories.'**
  String get exportDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Spaced Repetition Engine • {version}'**
  String appSubtitle(String version);

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Display'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, display, motion'**
  String get settingsAppearanceDesc;

  /// No description provided for @settingsStudyAlgorithmTitle.
  ///
  /// In en, this message translates to:
  /// **'Study & Scheduling'**
  String get settingsStudyAlgorithmTitle;

  /// No description provided for @settingsStudyAlgorithmDesc.
  ///
  /// In en, this message translates to:
  /// **'FSRS, retention, reminders'**
  String get settingsStudyAlgorithmDesc;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'JSON & CSV transfer'**
  String get settingsBackupDesc;

  /// No description provided for @settingsUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdatesTitle;

  /// No description provided for @settingsUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Check GitHub releases'**
  String get settingsUpdatesDesc;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About & Credits'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'MIT License & credits'**
  String get settingsAboutDesc;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or AMOLED'**
  String get themeModeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED (Pure Black)'**
  String get themeAmoled;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// No description provided for @themeAmoledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pure black for OLED displays'**
  String get themeAmoledSubtitle;

  /// No description provided for @refreshRate.
  ///
  /// In en, this message translates to:
  /// **'Refresh Rate'**
  String get refreshRate;

  /// No description provided for @refreshRateAuto.
  ///
  /// In en, this message translates to:
  /// **'System Default (Dynamic)'**
  String get refreshRateAuto;

  /// No description provided for @refreshRateAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Adaptive refresh rate managed by Android OS'**
  String get refreshRateAutoDesc;

  /// No description provided for @refreshRatePowerSave.
  ///
  /// In en, this message translates to:
  /// **'Battery Saver (60 Hz)'**
  String get refreshRatePowerSave;

  /// No description provided for @refreshRatePowerSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Fixed 60 Hz to minimize GPU power consumption'**
  String get refreshRatePowerSaveDesc;

  /// No description provided for @refreshRateHigh.
  ///
  /// In en, this message translates to:
  /// **'Maximum Fluidity (90/120 Hz)'**
  String get refreshRateHigh;

  /// No description provided for @refreshRateHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest supported refresh rate for silky-smooth motion'**
  String get refreshRateHighDesc;

  /// No description provided for @animationIntensity.
  ///
  /// In en, this message translates to:
  /// **'Animation Intensity'**
  String get animationIntensity;

  /// No description provided for @animationIntensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Motion and transitions'**
  String get animationIntensitySubtitle;

  /// No description provided for @animationReduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get animationReduced;

  /// No description provided for @animationReducedDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant, battery saver'**
  String get animationReducedDesc;

  /// No description provided for @animationStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get animationStandard;

  /// No description provided for @animationStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Fluid, balanced motion'**
  String get animationStandardDesc;

  /// No description provided for @animationExpressive.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get animationExpressive;

  /// No description provided for @animationExpressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic spring motion'**
  String get animationExpressiveDesc;

  /// No description provided for @testMotion.
  ///
  /// In en, this message translates to:
  /// **'Test Motion'**
  String get testMotion;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Touch vibration response'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @hapticOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hapticOff;

  /// No description provided for @hapticOffDesc.
  ///
  /// In en, this message translates to:
  /// **'No vibration'**
  String get hapticOffDesc;

  /// No description provided for @hapticLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get hapticLight;

  /// No description provided for @hapticLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Subtle clicks'**
  String get hapticLightDesc;

  /// No description provided for @hapticMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hapticMedium;

  /// No description provided for @hapticMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced pulse'**
  String get hapticMediumDesc;

  /// No description provided for @hapticStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get hapticStrong;

  /// No description provided for @hapticStrongDesc.
  ///
  /// In en, this message translates to:
  /// **'Strong pulse'**
  String get hapticStrongDesc;

  /// No description provided for @testHaptic.
  ///
  /// In en, this message translates to:
  /// **'Test Haptics'**
  String get testHaptic;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language & Localization'**
  String get sectionLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device system language'**
  String get systemLanguageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sectionStudyAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Study & Algorithm'**
  String get sectionStudyAlgorithm;

  /// No description provided for @fsrsParameters.
  ///
  /// In en, this message translates to:
  /// **'FSRS Scheduling Parameters'**
  String get fsrsParameters;

  /// No description provided for @retentionTarget.
  ///
  /// In en, this message translates to:
  /// **'Target retention: {percent}%'**
  String retentionTarget(int percent);

  /// No description provided for @desiredRetention.
  ///
  /// In en, this message translates to:
  /// **'Desired Retention'**
  String get desiredRetention;

  /// No description provided for @desiredRetentionDesc.
  ///
  /// In en, this message translates to:
  /// **'Target recall probability at review time. Higher retention requires more frequent reviews.'**
  String get desiredRetentionDesc;

  /// No description provided for @maxInterval.
  ///
  /// In en, this message translates to:
  /// **'Maximum Interval'**
  String get maxInterval;

  /// No description provided for @maxIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum spacing interval between reviews in days.'**
  String get maxIntervalDesc;

  /// No description provided for @resetFsrsDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetFsrsDefaults;

  /// No description provided for @fsrsWeights.
  ///
  /// In en, this message translates to:
  /// **'FSRS Model Weights'**
  String get fsrsWeights;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study Reminders'**
  String get studyReminders;

  /// No description provided for @studyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily review alerts'**
  String get studyRemindersSubtitle;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Reminders'**
  String get enableReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get testNotification;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to review with repetita!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have spaced repetition flashcards due for review today.'**
  String get notificationBody;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification dispatched!'**
  String get notificationSent;

  /// No description provided for @reminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive a gentle reminder each day to keep your review streak active and retain flashcards.'**
  String get reminderDesc;

  /// No description provided for @desktopNotifications.
  ///
  /// In en, this message translates to:
  /// **'Desktop Notifications'**
  String get desktopNotifications;

  /// No description provided for @desktopNotificationsActive.
  ///
  /// In en, this message translates to:
  /// **'System notifications enabled'**
  String get desktopNotificationsActive;

  /// No description provided for @desktopNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'System notifications disabled'**
  String get desktopNotificationsDisabled;

  /// No description provided for @desktopNotificationsExplanation.
  ///
  /// In en, this message translates to:
  /// **'On Windows and macOS, notifications are active while the application is running. Fixed-time daily alarms cannot trigger when the application is closed.'**
  String get desktopNotificationsExplanation;

  /// No description provided for @loadSampleDeck.
  ///
  /// In en, this message translates to:
  /// **'Load Sample Deck'**
  String get loadSampleDeck;

  /// No description provided for @sampleDeckLoaded.
  ///
  /// In en, this message translates to:
  /// **'Sample deck loaded successfully!'**
  String get sampleDeckLoaded;

  /// No description provided for @sectionDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get sectionDataBackup;

  /// No description provided for @sectionUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates & Releases'**
  String get sectionUpdates;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check GitHub releases'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking GitHub releases...'**
  String get checkingForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get upToDate;

  /// No description provided for @upToDateDesc.
  ///
  /// In en, this message translates to:
  /// **'repetita is currently running the latest version: {version}.'**
  String upToDateDesc(String version);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available!'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'A new version of repetita ({version}) is available.'**
  String updateAvailableDesc(String version);

  /// No description provided for @viewOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get updateCheckFailed;

  /// No description provided for @updateCheckFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get updateCheckFailedDesc;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About & Privacy'**
  String get sectionAbout;

  /// No description provided for @licenseAndCredits.
  ///
  /// In en, this message translates to:
  /// **'License & Credits'**
  String get licenseAndCredits;

  /// No description provided for @licenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MIT License • Credits'**
  String get licenseSubtitle;

  /// No description provided for @licenseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'MIT License'**
  String get licenseDialogTitle;

  /// No description provided for @licenseCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright (c) 2026 repetita'**
  String get licenseCopyright;

  /// No description provided for @viewAllLicenses.
  ///
  /// In en, this message translates to:
  /// **'View All Open Source Licenses'**
  String get viewAllLicenses;

  /// No description provided for @comingSoonNotice.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming in an upcoming release!'**
  String comingSoonNotice(String feature);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @startStudySession.
  ///
  /// In en, this message translates to:
  /// **'Start Study Session'**
  String get startStudySession;

  /// No description provided for @newCard.
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get newCard;

  /// No description provided for @frontPromptCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Front prompt cannot be empty'**
  String get frontPromptCannotBeEmpty;

  /// No description provided for @backAnswerCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Back answer cannot be empty'**
  String get backAnswerCannotBeEmpty;

  /// No description provided for @promptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter question or prompt...'**
  String get promptHint;

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter answer...'**
  String get answerHint;

  /// No description provided for @reviewForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Review Forecast'**
  String get reviewForecastTitle;

  /// No description provided for @noUpcomingReviews.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reviews scheduled.'**
  String get noUpcomingReviews;

  /// No description provided for @cardStateBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Card State Breakdown'**
  String get cardStateBreakdown;

  /// No description provided for @recallAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Recall accuracy'**
  String get recallAccuracy;

  /// No description provided for @reviewsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total completed'**
  String get reviewsCompleted;

  /// No description provided for @fullDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Full Database Backup (JSON)'**
  String get fullDatabaseBackup;

  /// No description provided for @flashcardsInterchange.
  ///
  /// In en, this message translates to:
  /// **'Flashcards Interchange (CSV)'**
  String get flashcardsInterchange;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @restoreJson.
  ///
  /// In en, this message translates to:
  /// **'Restore JSON'**
  String get restoreJson;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @retention.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get retention;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @undoReview.
  ///
  /// In en, this message translates to:
  /// **'Undo Review'**
  String get undoReview;

  /// No description provided for @suspendCard.
  ///
  /// In en, this message translates to:
  /// **'Suspend Card'**
  String get suspendCard;

  /// No description provided for @unsuspendCard.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend Card'**
  String get unsuspendCard;

  /// No description provided for @buryCard.
  ///
  /// In en, this message translates to:
  /// **'Bury Card'**
  String get buryCard;

  /// No description provided for @unburyCard.
  ///
  /// In en, this message translates to:
  /// **'Unbury Card'**
  String get unburyCard;

  /// No description provided for @cardSuspended.
  ///
  /// In en, this message translates to:
  /// **'Card suspended'**
  String get cardSuspended;

  /// No description provided for @cardBuried.
  ///
  /// In en, this message translates to:
  /// **'Card buried until tomorrow'**
  String get cardBuried;

  /// No description provided for @suspendedBadge.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedBadge;

  /// No description provided for @buriedBadge.
  ///
  /// In en, this message translates to:
  /// **'Buried'**
  String get buriedBadge;

  /// No description provided for @reviewHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Review Heatmap'**
  String get reviewHeatmap;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysStreak(int count);

  /// No description provided for @deleteDeckConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck?'**
  String get deleteDeckConfirmTitle;

  /// No description provided for @deleteDeckConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? All cards in this deck will be deleted.'**
  String deleteDeckConfirmMessage(String name);

  /// No description provided for @dueBadge.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueBadge;

  /// No description provided for @totalBadge.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalBadge;

  /// No description provided for @promptBadge.
  ///
  /// In en, this message translates to:
  /// **'PROMPT'**
  String get promptBadge;

  /// No description provided for @answerBadge.
  ///
  /// In en, this message translates to:
  /// **'ANSWER'**
  String get answerBadge;

  /// No description provided for @tapToFlipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap or press Show Answer to flip'**
  String get tapToFlipHint;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Another'**
  String get saveAndAddAnother;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardSaved;

  /// No description provided for @insertCloze.
  ///
  /// In en, this message translates to:
  /// **'Cloze [...]'**
  String get insertCloze;

  /// No description provided for @insertClozeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Wrap selection with Cloze deletion'**
  String get insertClozeTooltip;

  /// No description provided for @cardBackNotes.
  ///
  /// In en, this message translates to:
  /// **'Back (Extra Notes, Optional)'**
  String get cardBackNotes;

  /// No description provided for @clozeBadge.
  ///
  /// In en, this message translates to:
  /// **'Cloze c{index}'**
  String clozeBadge(int index);

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @newTagHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tag name...'**
  String get newTagHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get noTags;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @failedToLoadDecks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load decks'**
  String get failedToLoadDecks;

  /// No description provided for @deckStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'{deckName} Stats'**
  String deckStatsTitle(String deckName);

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStats;

  /// No description provided for @cardOptions.
  ///
  /// In en, this message translates to:
  /// **'Card options'**
  String get cardOptions;

  /// No description provided for @errorLoadingStudySession.
  ///
  /// In en, this message translates to:
  /// **'Error loading study session'**
  String get errorLoadingStudySession;

  /// No description provided for @backupRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully!'**
  String get backupRestoredSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @exportedCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Exported CSV'**
  String get exportedCsvTitle;

  /// No description provided for @csvExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'CSV exported successfully!'**
  String get csvExportedSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @createDeckFirstNotice.
  ///
  /// In en, this message translates to:
  /// **'Please create a deck first before importing cards.'**
  String get createDeckFirstNotice;

  /// No description provided for @importCardsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {importedCount} cards ({skippedCount} skipped).'**
  String importCardsSuccess(int importedCount, int skippedCount);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @csvSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or import cards as CSV with Front and Back fields for interchange with spreadsheets and other tools.'**
  String get csvSectionDescription;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackupTitle;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Restoring a backup will overwrite all existing decks and cards.'**
  String get restoreWarning;

  /// No description provided for @pasteBackupJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Paste backup JSON here...'**
  String get pasteBackupJsonHint;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @importCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Cards from CSV'**
  String get importCsvTitle;

  /// No description provided for @targetDeck.
  ///
  /// In en, this message translates to:
  /// **'Target Deck'**
  String get targetDeck;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @customStudy.
  ///
  /// In en, this message translates to:
  /// **'Custom Study'**
  String get customStudy;

  /// No description provided for @customStudyScope.
  ///
  /// In en, this message translates to:
  /// **'Study Scope'**
  String get customStudyScope;

  /// No description provided for @customStudyAllCards.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get customStudyAllCards;

  /// No description provided for @customStudyAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get customStudyAhead;

  /// No description provided for @customStudyDaysAhead.
  ///
  /// In en, this message translates to:
  /// **'Days in advance:'**
  String get customStudyDaysAhead;

  /// No description provided for @customStudyDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String customStudyDays(int count);

  /// No description provided for @selectTag.
  ///
  /// In en, this message translates to:
  /// **'Select tag:'**
  String get selectTag;

  /// No description provided for @noTagsInDeck.
  ///
  /// In en, this message translates to:
  /// **'No tags found in this deck.'**
  String get noTagsInDeck;

  /// No description provided for @cramModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cram Mode (Free Practice)'**
  String get cramModeTitle;

  /// No description provided for @cramModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Practice cards without affecting FSRS intervals or review logs'**
  String get cramModeDesc;

  /// No description provided for @advanceReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Update FSRS intervals and save reviews normally'**
  String get advanceReviewDesc;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @cramSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cram Session'**
  String get cramSessionTitle;

  /// No description provided for @cramBadge.
  ///
  /// In en, this message translates to:
  /// **'CRAM'**
  String get cramBadge;

  /// No description provided for @cramCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cram session completed!'**
  String get cramCompletedTitle;

  /// No description provided for @cramCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'You finished your practice run.'**
  String get cramCompletedDesc;

  /// No description provided for @allCardsReviewedTitle.
  ///
  /// In en, this message translates to:
  /// **'All cards reviewed for today!'**
  String get allCardsReviewedTitle;

  /// No description provided for @greatJobUpcomingReviews.
  ///
  /// In en, this message translates to:
  /// **'Great job! Check back later for upcoming reviews.'**
  String get greatJobUpcomingReviews;

  /// No description provided for @backToDeck.
  ///
  /// In en, this message translates to:
  /// **'Back to Deck'**
  String get backToDeck;

  /// No description provided for @cardProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String cardProgress(int current, int total);

  /// No description provided for @cardsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 remaining} other{{count} remaining}}'**
  String cardsRemaining(int count);

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editDeck.
  ///
  /// In en, this message translates to:
  /// **'Edit Deck'**
  String get editDeck;

  /// No description provided for @deckNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Biology 101'**
  String get deckNameHint;

  /// No description provided for @deckNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Deck name is required'**
  String get deckNameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 100 characters or less'**
  String get nameTooLong;

  /// No description provided for @deckDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional description of this deck'**
  String get deckDescriptionHint;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use dark palette'**
  String get themeDarkSubtitle;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use light palette'**
  String get themeLightSubtitle;

  /// No description provided for @cardsDueForReview.
  ///
  /// In en, this message translates to:
  /// **'{count} cards due for review'**
  String cardsDueForReview(int count);

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @reviewsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review in period} other{{count} reviews in period}}'**
  String reviewsInPeriod(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @reminderAtTime.
  ///
  /// In en, this message translates to:
  /// **'Daily review notification at {time}'**
  String reminderAtTime(String time);

  /// No description provided for @rateButtonSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rate {label}, next review in {interval}'**
  String rateButtonSemantics(String label, String interval);

  /// No description provided for @cramRequeue.
  ///
  /// In en, this message translates to:
  /// **'Re-queue'**
  String get cramRequeue;

  /// No description provided for @cramPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get cramPass;

  /// No description provided for @fullBackupJson.
  ///
  /// In en, this message translates to:
  /// **'Full Backup JSON'**
  String get fullBackupJson;

  /// No description provided for @backupExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully!'**
  String get backupExportedSuccess;

  /// No description provided for @cardPromptSemantics.
  ///
  /// In en, this message translates to:
  /// **'Card Prompt: {content}'**
  String cardPromptSemantics(String content);

  /// No description provided for @cardAnswerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Card Answer: {content}'**
  String cardAnswerSemantics(String content);

  /// No description provided for @ankiImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Anki Package (.apkg)'**
  String get ankiImportTitle;

  /// No description provided for @ankiImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import decks and flashcards directly from Anki packages, including Basic notes, Cloze deletions, and tags.'**
  String get ankiImportDescription;

  /// No description provided for @importAnki.
  ///
  /// In en, this message translates to:
  /// **'Import Anki (.apkg)'**
  String get importAnki;

  /// No description provided for @ankiImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {cards} cards across {decks} decks ({tags} tags created, {skipped} skipped).'**
  String ankiImportSuccess(int cards, int decks, int tags, int skipped);

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get pickFile;

  /// No description provided for @saveToFile.
  ///
  /// In en, this message translates to:
  /// **'Save to File'**
  String get saveToFile;

  /// No description provided for @selectAnkiDestination.
  ///
  /// In en, this message translates to:
  /// **'Anki Import Destination'**
  String get selectAnkiDestination;

  /// No description provided for @keepAnkiDecks.
  ///
  /// In en, this message translates to:
  /// **'Preserve original deck names'**
  String get keepAnkiDecks;

  /// No description provided for @chooseTargetDeck.
  ///
  /// In en, this message translates to:
  /// **'Import into an existing deck'**
  String get chooseTargetDeck;

  /// No description provided for @searchCards.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchCards;

  /// No description provided for @noCardsMatchingSearch.
  ///
  /// In en, this message translates to:
  /// **'No cards match your search query.'**
  String get noCardsMatchingSearch;

  /// No description provided for @fileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully!'**
  String get fileSavedSuccess;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @systemIntegration.
  ///
  /// In en, this message translates to:
  /// **'System integration: {platform}'**
  String systemIntegration(String platform);

  /// No description provided for @heatmapReviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review on {date}} other{{count} reviews on {date}}}'**
  String heatmapReviewTooltip(int count, String date);

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMon;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWed;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFri;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Release URL copied to clipboard: {url}'**
  String linkCopiedToClipboard(String url);

  /// No description provided for @errorSavingCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to save card: {error}'**
  String errorSavingCard(String error);

  /// No description provided for @srsAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'SRS Algorithm'**
  String get srsAlgorithm;

  /// No description provided for @srsAlgorithmDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the spaced repetition scheduler for card reviews.'**
  String get srsAlgorithmDesc;

  /// No description provided for @fsrsAlgorithmName.
  ///
  /// In en, this message translates to:
  /// **'FSRS (Default)'**
  String get fsrsAlgorithmName;

  /// No description provided for @fsrsAlgorithmDesc.
  ///
  /// In en, this message translates to:
  /// **'Modern stability model'**
  String get fsrsAlgorithmDesc;

  /// No description provided for @sm2AlgorithmName.
  ///
  /// In en, this message translates to:
  /// **'SM-2 (Classic)'**
  String get sm2AlgorithmName;

  /// No description provided for @sm2AlgorithmDesc.
  ///
  /// In en, this message translates to:
  /// **'Classic SuperMemo 2 model'**
  String get sm2AlgorithmDesc;

  /// No description provided for @examPlan.
  ///
  /// In en, this message translates to:
  /// **'Exam Study Plan'**
  String get examPlan;

  /// No description provided for @examDate.
  ///
  /// In en, this message translates to:
  /// **'Exam Date'**
  String get examDate;

  /// No description provided for @setExamDate.
  ///
  /// In en, this message translates to:
  /// **'Set Exam Date'**
  String get setExamDate;

  /// No description provided for @clearExamDate.
  ///
  /// In en, this message translates to:
  /// **'Clear Exam Date'**
  String get clearExamDate;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{1 day remaining} other{{count} days remaining}}'**
  String daysRemaining(int count);

  /// No description provided for @dailyNewTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {count} new cards/day'**
  String dailyNewTarget(int count);

  /// No description provided for @estimatedReviews.
  ///
  /// In en, this message translates to:
  /// **'~{count} reviews/day'**
  String estimatedReviews(int count);

  /// No description provided for @unsustainableWorkload.
  ///
  /// In en, this message translates to:
  /// **'Heavy workload! You may want to start earlier or lower retention target.'**
  String get unsustainableWorkload;

  /// No description provided for @setDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set Due Date'**
  String get setDueDate;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset this card\'s SRS progress? It will become a new card, but review logs are kept.'**
  String get resetProgressConfirmation;

  /// No description provided for @duplicateCard.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Card'**
  String get duplicateCard;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @flagNone.
  ///
  /// In en, this message translates to:
  /// **'No Flag'**
  String get flagNone;

  /// No description provided for @flagRed.
  ///
  /// In en, this message translates to:
  /// **'Red Flag'**
  String get flagRed;

  /// No description provided for @flagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Flag'**
  String get flagOrange;

  /// No description provided for @flagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Flag'**
  String get flagGreen;

  /// No description provided for @flagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Flag'**
  String get flagBlue;

  /// No description provided for @filterLeech.
  ///
  /// In en, this message translates to:
  /// **'Leech'**
  String get filterLeech;

  /// No description provided for @filterFlag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get filterFlag;

  /// No description provided for @leechDetectedAlert.
  ///
  /// In en, this message translates to:
  /// **'Leech detected! Card lapsed multiple times.'**
  String get leechDetectedAlert;

  /// No description provided for @autoBackups.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backups'**
  String get autoBackups;

  /// No description provided for @noAutoBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'No automatic backups yet.'**
  String get noAutoBackupsYet;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreBackup;

  /// No description provided for @restoreBackupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore this backup? Current data will be replaced.'**
  String get restoreBackupConfirmation;

  /// No description provided for @vacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get vacationMode;

  /// No description provided for @vacationModeActive.
  ///
  /// In en, this message translates to:
  /// **'Active • Review dates paused'**
  String get vacationModeActive;

  /// No description provided for @vacationModeInactive.
  ///
  /// In en, this message translates to:
  /// **'Disabled • Normal scheduling'**
  String get vacationModeInactive;

  /// No description provided for @leechCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lapsed cards'**
  String get leechCardsSubtitle;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
