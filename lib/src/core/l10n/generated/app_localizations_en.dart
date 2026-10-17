// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'repetita';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Search';

  @override
  String get navHome => 'Decks';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get decksTitle => 'repetita Decks';

  @override
  String get noDecksYet => 'No decks yet. Tap + to create one.';

  @override
  String get createFirstDeckPrompt =>
      'Create your first deck to begin spaced repetition studying.';

  @override
  String get createDeck => 'Create Deck';

  @override
  String get newDeck => 'New Deck';

  @override
  String get deckName => 'Deck Name';

  @override
  String get deckDescription => 'Description (optional)';

  @override
  String get study => 'Study';

  @override
  String get cards => 'Cards';

  @override
  String get stats => 'Statistics';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get settings => 'Settings';

  @override
  String totalCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    return '$count due';
  }

  @override
  String get deleteDeckConfirmation =>
      'Are you sure you want to delete this deck? All cards and review history will be lost.';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get addCard => 'Add Card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get cardFront => 'Front (Question / Prompt)';

  @override
  String get cardBack => 'Back (Answer / Explanation)';

  @override
  String get noCardsYet => 'No cards in this deck yet.';

  @override
  String get addCardPrompt =>
      'Add flashcards to start studying with the FSRS spaced repetition engine.';

  @override
  String get deleteCardConfirmation =>
      'Are you sure you want to delete this card?';

  @override
  String get studySessionTitle => 'Study Session';

  @override
  String get showAnswer => 'Show Answer';

  @override
  String get sessionComplete => 'Session Complete!';

  @override
  String get sessionCompleteSubtitle =>
      'All due cards in this deck have been reviewed for today.';

  @override
  String get noDueCardsTitle => 'All Caught Up!';

  @override
  String get noDueCardsSubtitle =>
      'There are no cards due for review in this deck right now.';

  @override
  String get backToDecks => 'Back to Decks';

  @override
  String get ratingAgain => 'Again';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingEasy => 'Easy';

  @override
  String get statsTitle => 'Review Analytics';

  @override
  String get retentionRate => 'Retention Rate';

  @override
  String get totalReviews => 'Total Reviews';

  @override
  String get cardsLearned => 'Cards Learned';

  @override
  String get retentionSubtitle => 'Percentage of successful recall reviews';

  @override
  String get cardStateDistribution => 'Card State Distribution';

  @override
  String get stateNew => 'New';

  @override
  String get stateLearning => 'Learning';

  @override
  String get stateReview => 'Review';

  @override
  String get stateRelearning => 'Relearning';

  @override
  String get backupTitle => 'Backup & Transfer';

  @override
  String get exportBackup => 'Export JSON Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get exportDescription =>
      'Create an offline JSON backup of all your decks, cards, and review histories.';

  @override
  String get importDescription =>
      'Restore or merge flashcards from a JSON backup file.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String appSubtitle(String version) {
    return 'Offline Spaced Repetition Engine • $version';
  }

  @override
  String get settingsAppearanceTitle => 'Appearance & Display';

  @override
  String get settingsAppearanceDesc => 'Theme, display, motion';

  @override
  String get settingsStudyAlgorithmTitle => 'Study & Scheduling';

  @override
  String get settingsStudyAlgorithmDesc => 'FSRS, retention, reminders';

  @override
  String get settingsLanguageDesc => 'Interface language';

  @override
  String get settingsBackupDesc => 'JSON & CSV transfer';

  @override
  String get settingsUpdatesTitle => 'Updates';

  @override
  String get settingsUpdatesDesc => 'Check GitHub releases';

  @override
  String get settingsAboutTitle => 'About & Credits';

  @override
  String get settingsAboutDesc => 'MIT License & credits';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeSubtitle => 'Light, Dark, or AMOLED';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeAmoled => 'AMOLED (Pure Black)';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeAmoledSubtitle => 'Pure black for OLED displays';

  @override
  String get refreshRate => 'Refresh Rate';

  @override
  String get refreshRateSubtitle => 'Display refresh frequency';

  @override
  String get refreshRateAuto => 'System Default (Dynamic)';

  @override
  String get refreshRateAutoDesc =>
      'Adaptive refresh rate managed by Android OS';

  @override
  String get refreshRatePowerSave => 'Battery Saver (60 Hz)';

  @override
  String get refreshRatePowerSaveDesc =>
      'Fixed 60 Hz to minimize GPU power consumption';

  @override
  String get refreshRateHigh => 'Maximum Fluidity (90/120 Hz)';

  @override
  String get refreshRateHighDesc =>
      'Highest supported refresh rate for silky-smooth motion';

  @override
  String get animationIntensity => 'Animation Intensity';

  @override
  String get animationIntensitySubtitle => 'Motion and transitions';

  @override
  String get animationReduced => 'Reduced';

  @override
  String get animationReducedDesc => 'Instant, battery saver';

  @override
  String get animationStandard => 'Standard';

  @override
  String get animationStandardDesc => 'Fluid, balanced motion';

  @override
  String get animationExpressive => 'Expressive';

  @override
  String get animationExpressiveDesc => 'Dynamic spring motion';

  @override
  String get testMotion => 'Test Motion';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Touch vibration response';

  @override
  String get hapticOff => 'Off';

  @override
  String get hapticOffDesc => 'No vibration';

  @override
  String get hapticLight => 'Light';

  @override
  String get hapticLightDesc => 'Subtle clicks';

  @override
  String get hapticMedium => 'Medium';

  @override
  String get hapticMediumDesc => 'Balanced pulse';

  @override
  String get hapticStrong => 'Strong';

  @override
  String get hapticStrongDesc => 'Strong pulse';

  @override
  String get testHaptic => 'Test Haptics';

  @override
  String get sectionLanguage => 'LANGUAGE & LOCALIZATION';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Interface language';

  @override
  String get systemLanguageSubtitle => 'Follow device system language';

  @override
  String get currentLanguage => 'Current active language';

  @override
  String get english => 'English';

  @override
  String get italian => 'Italiano';

  @override
  String get spanish => 'Español';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get active => 'Active';

  @override
  String get sectionStudyAlgorithm => 'STUDY & ALGORITHM';

  @override
  String get fsrsParameters => 'FSRS Scheduling Parameters';

  @override
  String get fsrsParametersSubtitle => 'Retention and intervals';

  @override
  String retentionTarget(int percent) {
    return 'Target retention: $percent%';
  }

  @override
  String get desiredRetention => 'Desired Retention';

  @override
  String get desiredRetentionDesc =>
      'Target recall probability at review time. Higher retention requires more frequent reviews.';

  @override
  String get maxInterval => 'Maximum Interval';

  @override
  String get maxIntervalDesc =>
      'Maximum spacing interval between reviews in days.';

  @override
  String get resetFsrsDefaults => 'Reset to Defaults';

  @override
  String get fsrsWeights => 'FSRS Model Weights';

  @override
  String get studyReminders => 'Study Reminders';

  @override
  String get studyRemindersSubtitle => 'Daily review alerts';

  @override
  String get remindersOff => 'Off';

  @override
  String get enableReminders => 'Daily Study Reminders';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get testNotification => 'Send Test Notification';

  @override
  String get notificationTitle => 'Time to review with repetita!';

  @override
  String get notificationBody =>
      'You have spaced repetition flashcards due for review today.';

  @override
  String get notificationSent => 'Test notification dispatched!';

  @override
  String get reminderDesc =>
      'Receive a gentle reminder each day to keep your review streak active and retain flashcards.';

  @override
  String get desktopNotifications => 'Desktop Notifications';

  @override
  String get desktopNotificationsSubtitle => 'System review alerts';

  @override
  String get desktopNotificationsActive => 'System notifications enabled';

  @override
  String get desktopNotificationsDisabled => 'System notifications disabled';

  @override
  String get desktopNotificationsExplanation =>
      'On Windows and macOS, notifications are active while the application is running. Fixed-time daily alarms cannot trigger when the application is closed.';

  @override
  String get loadSampleDeck => 'Load Sample Deck';

  @override
  String get sampleDeckLoaded => 'Sample deck loaded successfully!';

  @override
  String get sectionDataBackup => 'DATA & BACKUP';

  @override
  String get backupSubtitle => 'JSON and CSV transfer';

  @override
  String get sectionUpdates => 'UPDATES & RELEASES';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkForUpdatesSubtitle => 'Check GitHub releases';

  @override
  String get checkingForUpdates => 'Checking GitHub releases...';

  @override
  String get upToDate => 'Up to Date';

  @override
  String upToDateDesc(String version) {
    return 'repetita is currently running the latest version: $version.';
  }

  @override
  String get updateAvailable => 'Update Available!';

  @override
  String updateAvailableDesc(String version) {
    return 'A new version of repetita ($version) is available.';
  }

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get updateCheckFailed => 'Could not check for updates';

  @override
  String get updateCheckFailedDesc =>
      'Please check your internet connection and try again.';

  @override
  String get sectionAbout => 'ABOUT & PRIVACY';

  @override
  String get licenseAndCredits => 'License & Credits';

  @override
  String get licenseSubtitle => 'MIT License • Credits';

  @override
  String get licenseDialogTitle => 'MIT License';

  @override
  String get licenseCopyright => 'Copyright (c) 2026 repetita';

  @override
  String get viewAllLicenses => 'View All Open Source Licenses';

  @override
  String comingSoonNotice(String feature) {
    return '$feature feature coming in an upcoming release!';
  }

  @override
  String get retry => 'Retry';

  @override
  String get startStudySession => 'Start Study Session';

  @override
  String get newCard => 'New Card';

  @override
  String get frontPromptCannotBeEmpty => 'Front prompt cannot be empty';

  @override
  String get backAnswerCannotBeEmpty => 'Back answer cannot be empty';

  @override
  String get promptHint => 'Enter question or prompt...';

  @override
  String get answerHint => 'Enter answer...';

  @override
  String get reviewForecastTitle => '7-Day Review Forecast';

  @override
  String get noUpcomingReviews => 'No upcoming reviews scheduled.';

  @override
  String get cardStateBreakdown => 'Card State Breakdown';

  @override
  String get recallAccuracy => 'Recall accuracy';

  @override
  String get reviewsCompleted => 'Total completed';

  @override
  String get fullDatabaseBackup => 'Full Database Backup (JSON)';

  @override
  String get flashcardsInterchange => 'Flashcards Interchange (CSV)';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get restoreJson => 'Restore JSON';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get retention => 'Retention';

  @override
  String get reviews => 'Reviews';

  @override
  String get undo => 'Undo';

  @override
  String get undoReview => 'Undo Review';

  @override
  String get cardUndone => 'Review undone';

  @override
  String get suspendCard => 'Suspend Card';

  @override
  String get unsuspendCard => 'Unsuspend Card';

  @override
  String get buryCard => 'Bury Card';

  @override
  String get unburyCard => 'Unbury Card';

  @override
  String get cardSuspended => 'Card suspended';

  @override
  String get cardUnsuspended => 'Card unsuspended';

  @override
  String get cardBuried => 'Card buried until tomorrow';

  @override
  String get suspendedBadge => 'Suspended';

  @override
  String get buriedBadge => 'Buried';

  @override
  String get reviewHeatmap => 'Review Heatmap';

  @override
  String get streak => 'Streak';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsYet => 'No reviews recorded yet';

  @override
  String get deleteDeckConfirmTitle => 'Delete Deck?';

  @override
  String deleteDeckConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? All cards in this deck will be deleted.';
  }

  @override
  String get dueBadge => 'Due';

  @override
  String get totalBadge => 'Total';

  @override
  String get promptBadge => 'PROMPT';

  @override
  String get answerBadge => 'ANSWER';

  @override
  String get tapToFlipHint => 'Tap or press Show Answer to flip';

  @override
  String get saveAndAddAnother => 'Save & Add Another';

  @override
  String get cardSaved => 'Card saved';

  @override
  String get insertCloze => 'Cloze [...]';

  @override
  String get insertClozeTooltip => 'Wrap selection with Cloze deletion';

  @override
  String get cardBackNotes => 'Back (Extra Notes, Optional)';

  @override
  String clozeBadge(int index) {
    return 'Cloze c$index';
  }

  @override
  String get tags => 'Tags';

  @override
  String get addTag => 'Add Tag';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String get newTagHint => 'Enter tag name...';

  @override
  String get filterAll => 'All';

  @override
  String get noTags => 'No tags';

  @override
  String get selectTags => 'Select Tags';

  @override
  String get failedToLoadDecks => 'Failed to load decks';

  @override
  String deckStatsTitle(String deckName) {
    return '$deckName Stats';
  }

  @override
  String get errorLoadingStats => 'Error loading statistics';

  @override
  String get cardOptions => 'Card options';

  @override
  String get errorLoadingStudySession => 'Error loading study session';

  @override
  String get backupRestoredSuccess => 'Backup restored successfully!';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get exportedCsvTitle => 'Exported CSV';

  @override
  String get csvExportedSuccess => 'CSV exported successfully!';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get createDeckFirstNotice =>
      'Please create a deck first before importing cards.';

  @override
  String importCardsSuccess(int importedCount, int skippedCount) {
    return 'Imported $importedCount cards ($skippedCount skipped).';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get csvSectionDescription =>
      'Export or import cards as CSV with Front and Back fields for interchange with spreadsheets and other tools.';

  @override
  String get restoreBackupTitle => 'Restore Backup';

  @override
  String get restoreWarning =>
      'Warning: Restoring a backup will overwrite all existing decks and cards.';

  @override
  String get pasteBackupJsonHint => 'Paste backup JSON here...';

  @override
  String get restore => 'Restore';

  @override
  String get importCsvTitle => 'Import Cards from CSV';

  @override
  String get targetDeck => 'Target Deck';

  @override
  String get import => 'Import';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get customStudy => 'Custom Study';

  @override
  String get customStudyScope => 'Study Scope';

  @override
  String get customStudyAllCards => 'All';

  @override
  String get customStudyAhead => 'Ahead';

  @override
  String get customStudyDaysAhead => 'Days in advance:';

  @override
  String customStudyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get selectTag => 'Select tag:';

  @override
  String get noTagsInDeck => 'No tags found in this deck.';

  @override
  String get cramModeTitle => 'Cram Mode (Free Practice)';

  @override
  String get cramModeDesc =>
      'Practice cards without affecting FSRS intervals or review logs';

  @override
  String get advanceReviewDesc =>
      'Update FSRS intervals and save reviews normally';

  @override
  String get start => 'Start';

  @override
  String get cramSessionTitle => 'Cram Session';

  @override
  String get cramBadge => 'CRAM';

  @override
  String get cramCompletedTitle => 'Cram session completed!';

  @override
  String get cramCompletedDesc => 'You finished your practice run.';

  @override
  String get allCardsReviewedTitle => 'All cards reviewed for today!';

  @override
  String get greatJobUpcomingReviews =>
      'Great job! Check back later for upcoming reviews.';

  @override
  String get backToDeck => 'Back to Deck';

  @override
  String cardProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String cardsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count remaining',
      one: '1 remaining',
    );
    return '$_temp0';
  }

  @override
  String get create => 'Create';

  @override
  String get editDeck => 'Edit Deck';

  @override
  String get deckNameHint => 'e.g., Biology 101';

  @override
  String get deckNameRequired => 'Deck name is required';

  @override
  String get nameTooLong => 'Name must be 100 characters or less';

  @override
  String get deckDescriptionHint => 'Optional description of this deck';

  @override
  String get themeSystemSubtitle => 'Follow device theme settings';

  @override
  String get themeDarkSubtitle => 'Always use dark palette';

  @override
  String get themeLightSubtitle => 'Always use light palette';

  @override
  String cardsDueForReview(int count) {
    return '$count cards due for review';
  }

  @override
  String get heatmapLess => 'Less';

  @override
  String get heatmapMore => 'More';

  @override
  String reviewsInPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews in period',
      one: '1 review in period',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String reminderAtTime(String time) {
    return 'Daily review notification at $time';
  }

  @override
  String rateButtonSemantics(String label, String interval) {
    return 'Rate $label, next review in $interval';
  }

  @override
  String get cramRequeue => 'Re-queue';

  @override
  String get cramPass => 'Pass';

  @override
  String get fullBackupJson => 'Full Backup JSON';

  @override
  String get backupExportedSuccess => 'Backup exported successfully!';

  @override
  String cardPromptSemantics(String content) {
    return 'Card Prompt: $content';
  }

  @override
  String cardAnswerSemantics(String content) {
    return 'Card Answer: $content';
  }

  @override
  String get ankiImportTitle => 'Anki Package (.apkg)';

  @override
  String get ankiImportDescription =>
      'Import decks and flashcards directly from Anki packages, including Basic notes, Cloze deletions, and tags.';

  @override
  String get importAnki => 'Import Anki (.apkg)';

  @override
  String ankiImportSuccess(int cards, int decks, int tags, int skipped) {
    return 'Imported $cards cards across $decks decks ($tags tags created, $skipped skipped).';
  }

  @override
  String get pickFile => 'Select File';

  @override
  String get saveToFile => 'Save to File';

  @override
  String get pasteText => 'Paste Text';

  @override
  String get selectAnkiDestination => 'Anki Import Destination';

  @override
  String get keepAnkiDecks => 'Preserve original deck names';

  @override
  String get chooseTargetDeck => 'Import into an existing deck';

  @override
  String get searchCards => 'Search cards...';

  @override
  String get noCardsMatchingSearch => 'No cards match your search query.';

  @override
  String get fileSavedSuccess => 'File saved successfully!';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get discard => 'Discard';

  @override
  String get clearSearch => 'Clear search';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String systemIntegration(String platform) {
    return 'System integration: $platform';
  }

  @override
  String heatmapReviewTooltip(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews on $date',
      one: '1 review on $date',
    );
    return '$_temp0';
  }

  @override
  String get weekdayMon => 'M';

  @override
  String get weekdayWed => 'W';

  @override
  String get weekdayFri => 'F';

  @override
  String get copyReleaseLink => 'Copy Release Link';

  @override
  String linkCopiedToClipboard(String url) {
    return 'Release URL copied to clipboard: $url';
  }

  @override
  String errorSavingCard(String error) {
    return 'Failed to save card: $error';
  }

  @override
  String get srsAlgorithm => 'SRS Algorithm';

  @override
  String get srsAlgorithmDesc =>
      'Select the spaced repetition scheduler for card reviews.';

  @override
  String get fsrsAlgorithmName => 'FSRS (Default)';

  @override
  String get fsrsAlgorithmDesc => 'Modern stability model';

  @override
  String get sm2AlgorithmName => 'SM-2 (Classic)';

  @override
  String get sm2AlgorithmDesc => 'Classic SuperMemo 2 model';

  @override
  String get examPlan => 'Exam Study Plan';

  @override
  String get examDate => 'Exam Date';

  @override
  String get setExamDate => 'Set Exam Date';

  @override
  String get clearExamDate => 'Clear Exam Date';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining',
      one: '1 day remaining',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String dailyNewTarget(int count) {
    return 'Target: $count new cards/day';
  }

  @override
  String estimatedReviews(int count) {
    return '~$count reviews/day';
  }

  @override
  String get unsustainableWorkload =>
      'Heavy workload! You may want to start earlier or lower retention target.';

  @override
  String get setDueDate => 'Set Due Date';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get resetProgressConfirmation =>
      'Are you sure you want to reset this card\'s SRS progress? It will become a new card, but review logs are kept.';

  @override
  String get duplicateCard => 'Duplicate Card';

  @override
  String get flag => 'Flag';

  @override
  String get flagNone => 'No Flag';

  @override
  String get flagRed => 'Red Flag';

  @override
  String get flagOrange => 'Orange Flag';

  @override
  String get flagGreen => 'Green Flag';

  @override
  String get flagBlue => 'Blue Flag';

  @override
  String get filterLeech => 'Leech';

  @override
  String get filterFlag => 'Flag';

  @override
  String get leechDetectedAlert =>
      'Leech detected! Card lapsed multiple times.';

  @override
  String get leechSuspendedAlert =>
      'Leech detected! Card automatically suspended.';

  @override
  String get autoBackups => 'Automatic Backups';

  @override
  String get noAutoBackupsYet => 'No automatic backups yet.';

  @override
  String get restoreBackup => 'Restore';

  @override
  String get restoreBackupConfirmation =>
      'Are you sure you want to restore this backup? Current data will be replaced.';

  @override
  String get vacationMode => 'Vacation Mode';

  @override
  String get vacationModeActive => 'Active • Review dates paused';

  @override
  String get vacationModeInactive => 'Disabled • Normal scheduling';

  @override
  String get leechCardsSubtitle => 'Lapsed cards';
}
