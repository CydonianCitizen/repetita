// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'repetita';

  @override
  String get close => 'Chiudi';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Cerca';

  @override
  String get navHome => 'Mazzi';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get decksTitle => 'Mazzi repetita';

  @override
  String get noDecksYet => 'Nessun mazzo presente. Tocca + per crearne uno.';

  @override
  String get createFirstDeckPrompt =>
      'Crea il tuo primo mazzo per iniziare a studiare con la ripetizione spaziata.';

  @override
  String get createDeck => 'Crea mazzo';

  @override
  String get newDeck => 'Nuovo mazzo';

  @override
  String get deckName => 'Nome mazzo';

  @override
  String get deckDescription => 'Descrizione (opzionale)';

  @override
  String get study => 'Studia';

  @override
  String get cards => 'Carte';

  @override
  String get stats => 'Statistiche';

  @override
  String get backup => 'Backup e ripristino';

  @override
  String get settings => 'Impostazioni';

  @override
  String totalCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    return '$count da ripassare';
  }

  @override
  String get deleteDeckConfirmation =>
      'Sei sicuro di voler eliminare questo mazzo? Tutte le carte e la cronologia delle ripetizioni andranno perse.';

  @override
  String get cardsTitle => 'Carte';

  @override
  String get addCard => 'Aggiungi carta';

  @override
  String get editCard => 'Modifica carta';

  @override
  String get cardFront => 'Fronte (Domanda / Prompt)';

  @override
  String get cardBack => 'Retro (Risposta / Spiegazione)';

  @override
  String get noCardsYet => 'Nessuna carta in questo mazzo.';

  @override
  String get addCardPrompt =>
      'Aggiungi flashcard per iniziare a studiare con il motore a ripetizione spaziata FSRS.';

  @override
  String get deleteCardConfirmation =>
      'Sei sicuro di voler eliminare questa carta?';

  @override
  String get studySessionTitle => 'Sessione di studio';

  @override
  String get showAnswer => 'Mostra risposta';

  @override
  String get sessionComplete => 'Sessione completata!';

  @override
  String get sessionCompleteSubtitle =>
      'Tutte le carte in scadenza per oggi in questo mazzo sono state ripassate.';

  @override
  String get noDueCardsTitle => 'Tutto in pari!';

  @override
  String get noDueCardsSubtitle =>
      'Non ci sono carte da ripassare in questo mazzo in questo momento.';

  @override
  String get backToDecks => 'Torna ai mazzi';

  @override
  String get ratingAgain => 'Ripeti';

  @override
  String get ratingHard => 'Difficile';

  @override
  String get ratingGood => 'Buono';

  @override
  String get ratingEasy => 'Facile';

  @override
  String get statsTitle => 'Analisi ripassi';

  @override
  String get retentionRate => 'Tasso di ritenzione';

  @override
  String get totalReviews => 'Revisioni totali';

  @override
  String get cardsLearned => 'Carte apprese';

  @override
  String get retentionSubtitle => 'Percentuale di risposte corrette';

  @override
  String get cardStateDistribution => 'Distribuzione stati carte';

  @override
  String get stateNew => 'Nuova';

  @override
  String get stateLearning => 'Apprendimento';

  @override
  String get stateReview => 'Ripasso';

  @override
  String get stateRelearning => 'Riapprendimento';

  @override
  String get backupTitle => 'Backup e trasferimento';

  @override
  String get exportBackup => 'Esporta backup JSON';

  @override
  String get importBackup => 'Importa backup';

  @override
  String get exportDescription =>
      'Crea un backup JSON offline di tutti i tuoi mazzi, carte e cronologia.';

  @override
  String get importDescription =>
      'Ripristina o unisci flashcard da un file di backup JSON.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String appSubtitle(String version) {
    return 'Motore a ripetizione spaziata offline • $version';
  }

  @override
  String get settingsAppearanceTitle => 'Aspetto e Schermo';

  @override
  String get settingsAppearanceDesc => 'Tema, schermo, movimento';

  @override
  String get settingsStudyAlgorithmTitle => 'Studio e Ripasso';

  @override
  String get settingsStudyAlgorithmDesc => 'FSRS, ritenzione, promemoria';

  @override
  String get settingsLanguageDesc => 'Lingua interfaccia';

  @override
  String get settingsBackupDesc => 'Backup JSON e CSV';

  @override
  String get settingsUpdatesTitle => 'Aggiornamenti';

  @override
  String get settingsUpdatesDesc => 'Verifica release GitHub';

  @override
  String get settingsAboutTitle => 'Info e Crediti';

  @override
  String get settingsAboutDesc => 'Licenza MIT e crediti';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeModeSubtitle => 'Chiaro, Scuro o AMOLED';

  @override
  String get themeSystem => 'Predefinito di sistema';

  @override
  String get themeDark => 'Tema Scuro';

  @override
  String get themeAmoled => 'AMOLED (Nero assoluto)';

  @override
  String get themeLight => 'Tema Chiaro';

  @override
  String get themeAmoledSubtitle => 'Nero puro per display OLED';

  @override
  String get refreshRate => 'Frequenza di aggiornamento';

  @override
  String get refreshRateSubtitle => 'Frequenza schermo';

  @override
  String get refreshRateAuto => 'Predefinito di sistema (Dinamico)';

  @override
  String get refreshRateAutoDesc =>
      'Frequenza adattiva gestita dal sistema operativo Android';

  @override
  String get refreshRatePowerSave => 'Risparmio batteria (60 Hz)';

  @override
  String get refreshRatePowerSaveDesc =>
      'Blocca a 60 Hz per minimizzare il consumo della GPU';

  @override
  String get refreshRateHigh => 'Massima fluidità (90/120 Hz)';

  @override
  String get refreshRateHighDesc =>
      'Massima frequenza supportata per transizioni ultra-fluide';

  @override
  String get animationIntensity => 'Intensità animazioni';

  @override
  String get animationIntensitySubtitle => 'Transizioni e animazioni';

  @override
  String get animationReduced => 'Ridotte';

  @override
  String get animationReducedDesc => 'Istantanee, risparmio batteria';

  @override
  String get animationStandard => 'Standard';

  @override
  String get animationStandardDesc => 'Fluide e bilanciate';

  @override
  String get animationExpressive => 'Espressive';

  @override
  String get animationExpressiveDesc => 'Fisica elastica dinamica';

  @override
  String get testMotion => 'Prova movimento';

  @override
  String get hapticFeedback => 'Feedback aptico';

  @override
  String get hapticFeedbackSubtitle => 'Vibrazione al tocco';

  @override
  String get hapticOff => 'Disattivato';

  @override
  String get hapticOffDesc => 'Nessuna vibrazione';

  @override
  String get hapticLight => 'Leggero';

  @override
  String get hapticLightDesc => 'Click leggeri';

  @override
  String get hapticMedium => 'Medio';

  @override
  String get hapticMediumDesc => 'Impulso bilanciato';

  @override
  String get hapticStrong => 'Forte';

  @override
  String get hapticStrongDesc => 'Feedback deciso';

  @override
  String get testHaptic => 'Prova vibrazione';

  @override
  String get sectionLanguage => 'Lingua e localizzazione';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get language => 'Lingua';

  @override
  String get languageSubtitle => 'Lingua interfaccia';

  @override
  String get systemLanguageSubtitle => 'Segui la lingua del dispositivo';

  @override
  String get currentLanguage => 'Lingua attualmente attiva';

  @override
  String get english => 'English';

  @override
  String get italian => 'Italiano';

  @override
  String get spanish => 'Español';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get active => 'Attiva';

  @override
  String get sectionStudyAlgorithm => 'Studio e ripasso';

  @override
  String get fsrsParameters => 'Parametri algoritmo FSRS';

  @override
  String get fsrsParametersSubtitle => 'Ritenzione e intervalli';

  @override
  String retentionTarget(int percent) {
    return 'Target memorizzazione: $percent%';
  }

  @override
  String get desiredRetention => 'Ritenzione desiderata';

  @override
  String get desiredRetentionDesc =>
      'Probabilità di ricordo stimata al ripasso. Una ritenzione più alta richiede ripassi più frequenti.';

  @override
  String get maxInterval => 'Intervallo massimo';

  @override
  String get maxIntervalDesc =>
      'Intervallo massimo di ripasso espresso in giorni.';

  @override
  String get resetFsrsDefaults => 'Ripristina predefiniti';

  @override
  String get fsrsWeights => 'Pesi del modello FSRS';

  @override
  String get studyReminders => 'Promemoria di studio';

  @override
  String get studyRemindersSubtitle => 'Avvisi giornalieri';

  @override
  String get remindersOff => 'Disattivate';

  @override
  String get enableReminders => 'Promemoria giornaliero di studio';

  @override
  String get reminderTime => 'Orario promemoria';

  @override
  String get testNotification => 'Invia notifica di prova';

  @override
  String get notificationTitle => 'È ora di ripassare con repetita!';

  @override
  String get notificationBody =>
      'Hai delle flashcard in scadenza da ripassare oggi.';

  @override
  String get notificationSent => 'Notifica di prova inviata!';

  @override
  String get reminderDesc =>
      'Ricevi un promemoria ogni giorno all\'orario stabilito per mantenere costante la tua memoria.';

  @override
  String get desktopNotifications => 'Notifiche desktop';

  @override
  String get desktopNotificationsSubtitle => 'Avvisi di sistema';

  @override
  String get desktopNotificationsActive => 'Notifiche di sistema attive';

  @override
  String get desktopNotificationsDisabled => 'Notifiche di sistema disattivate';

  @override
  String get desktopNotificationsExplanation =>
      'Su Windows e macOS, le notifiche sono attive durante l\'esecuzione dell\'applicazione. I promemoria giornalieri ad orario fisso non possono attivarsi se il programma è chiuso.';

  @override
  String get loadSampleDeck => 'Carica mazzo di esempio';

  @override
  String get sampleDeckLoaded => 'Mazzo di esempio caricato con successo!';

  @override
  String get sectionDataBackup => 'Dati e backup';

  @override
  String get backupSubtitle => 'Backup JSON e CSV';

  @override
  String get sectionUpdates => 'Aggiornamenti e release';

  @override
  String get checkForUpdates => 'Verifica aggiornamenti';

  @override
  String get checkForUpdatesSubtitle => 'Verifica release GitHub';

  @override
  String get checkingForUpdates => 'Verifica release su GitHub in corso...';

  @override
  String get upToDate => 'Aggiornato';

  @override
  String upToDateDesc(String version) {
    return 'repetita è attualmente aggiornata all\'ultima versione: $version.';
  }

  @override
  String get updateAvailable => 'Nuovo aggiornamento disponibile!';

  @override
  String updateAvailableDesc(String version) {
    return 'Una nuova versione di repetita ($version) è disponibile su GitHub.';
  }

  @override
  String get viewOnGitHub => 'Vedi su GitHub';

  @override
  String get updateCheckFailed => 'Impossibile verificare gli aggiornamenti';

  @override
  String get updateCheckFailedDesc =>
      'Verifica la tua connessione internet e riprova.';

  @override
  String get sectionAbout => 'Info e crediti';

  @override
  String get licenseAndCredits => 'Licenza e riconoscimenti';

  @override
  String get licenseSubtitle => 'Licenza MIT • Crediti';

  @override
  String get licenseDialogTitle => 'Licenza MIT';

  @override
  String get licenseCopyright => 'Copyright (c) 2026 repetita';

  @override
  String get viewAllLicenses => 'Tutte le licenze open source';

  @override
  String comingSoonNotice(String feature) {
    return 'Funzionalità $feature disponibile in un prossimo aggiornamento!';
  }

  @override
  String get retry => 'Riprova';

  @override
  String get startStudySession => 'Inizia sessione di studio';

  @override
  String get newCard => 'Nuova carta';

  @override
  String get frontPromptCannotBeEmpty => 'La domanda non può essere vuota';

  @override
  String get backAnswerCannotBeEmpty => 'La risposta non può essere vuota';

  @override
  String get promptHint => 'Inserisci domanda o prompt...';

  @override
  String get answerHint => 'Inserisci risposta...';

  @override
  String get reviewForecastTitle => 'Previsione ripassi a 7 giorni';

  @override
  String get noUpcomingReviews => 'Nessun ripasso programmato.';

  @override
  String get cardStateBreakdown => 'Distribuzione stati carte';

  @override
  String get recallAccuracy => 'Precisione di rievocazione';

  @override
  String get reviewsCompleted => 'Totale completate';

  @override
  String get fullDatabaseBackup => 'Backup completo database (JSON)';

  @override
  String get flashcardsInterchange => 'Interscambio flashcard (CSV)';

  @override
  String get exportJson => 'Esporta JSON';

  @override
  String get restoreJson => 'Ripristina JSON';

  @override
  String get exportCsv => 'Esporta CSV';

  @override
  String get importCsv => 'Importa CSV';

  @override
  String get copyToClipboard => 'Copia negli appunti';

  @override
  String get retention => 'Ritenzione';

  @override
  String get reviews => 'Ripassi';

  @override
  String get undo => 'Annulla';

  @override
  String get undoReview => 'Annulla ripasso';

  @override
  String get cardUndone => 'Ripasso annullato';

  @override
  String get suspendCard => 'Sospendi carta';

  @override
  String get unsuspendCard => 'Riattiva carta';

  @override
  String get buryCard => 'Rinvia carta';

  @override
  String get unburyCard => 'Annulla rinvio';

  @override
  String get cardSuspended => 'Carta sospesa';

  @override
  String get cardUnsuspended => 'Carta riattivata';

  @override
  String get cardBuried => 'Carta rinviata a domani';

  @override
  String get suspendedBadge => 'Sospesa';

  @override
  String get buriedBadge => 'Rinviata';

  @override
  String get reviewHeatmap => 'Mappa delle revisioni';

  @override
  String get streak => 'Serie';

  @override
  String get currentStreak => 'Serie attuale';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsYet => 'Nessuna revisione registrata';

  @override
  String get deleteDeckConfirmTitle => 'Eliminare il mazzo?';

  @override
  String deleteDeckConfirmMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"? Tutte le carte in questo mazzo verranno eliminate.';
  }

  @override
  String get dueBadge => 'Da ripassare';

  @override
  String get totalBadge => 'Totale';

  @override
  String get promptBadge => 'DOMANDA';

  @override
  String get answerBadge => 'RISPOSTA';

  @override
  String get tapToFlipHint => 'Tocca o premi Mostra risposta per girare';

  @override
  String get saveAndAddAnother => 'Salva e aggiungi un\'altra';

  @override
  String get cardSaved => 'Carta salvata';

  @override
  String get insertCloze => 'Cloze [...]';

  @override
  String get insertClozeTooltip =>
      'Racchiudi selezione in testo a scomparsa Cloze';

  @override
  String get cardBackNotes => 'Retro (Note aggiuntive, opzionale)';

  @override
  String clozeBadge(int index) {
    return 'Cloze c$index';
  }

  @override
  String get tags => 'Tag';

  @override
  String get addTag => 'Aggiungi tag';

  @override
  String get manageTags => 'Gestisci Tag';

  @override
  String get newTagHint => 'Inserisci nome tag...';

  @override
  String get filterAll => 'Tutte';

  @override
  String get noTags => 'Nessun tag';

  @override
  String get selectTags => 'Seleziona Tag';

  @override
  String get failedToLoadDecks => 'Impossibile caricare i mazzi';

  @override
  String deckStatsTitle(String deckName) {
    return 'Statistiche di $deckName';
  }

  @override
  String get errorLoadingStats =>
      'Errore durante il caricamento delle statistiche';

  @override
  String get cardOptions => 'Opzioni carta';

  @override
  String get errorLoadingStudySession =>
      'Errore durante il caricamento della sessione di studio';

  @override
  String get backupRestoredSuccess => 'Backup ripristinato con successo!';

  @override
  String get restoreFailed => 'Ripristino fallito';

  @override
  String get exportedCsvTitle => 'CSV Esportato';

  @override
  String get csvExportedSuccess => 'CSV esportato con successo!';

  @override
  String get exportFailed => 'Esportazione fallita';

  @override
  String get createDeckFirstNotice =>
      'Crea prima un mazzo prima di importare le carte.';

  @override
  String importCardsSuccess(int importedCount, int skippedCount) {
    return 'Importate $importedCount carte ($skippedCount ignorate).';
  }

  @override
  String get importFailed => 'Importazione fallita';

  @override
  String get csvSectionDescription =>
      'Esporta o importa carte in formato CSV con campi Fronte e Retro per l\'interscambio con fogli di calcolo e altri strumenti.';

  @override
  String get restoreBackupTitle => 'Ripristina Backup';

  @override
  String get restoreWarning =>
      'Attenzione: Il ripristino di un backup sovrascriverà tutti i mazzi e le carte esistenti.';

  @override
  String get pasteBackupJsonHint => 'Incolla il JSON di backup qui...';

  @override
  String get restore => 'Ripristina';

  @override
  String get importCsvTitle => 'Importa Carte da CSV';

  @override
  String get targetDeck => 'Mazzo di destinazione';

  @override
  String get import => 'Importa';

  @override
  String get copiedToClipboard => 'Copiato negli appunti!';

  @override
  String get customStudy => 'Studio Personalizzato';

  @override
  String get customStudyScope => 'Ambito di Studio';

  @override
  String get customStudyAllCards => 'Tutte';

  @override
  String get customStudyAhead => 'In Anticipo';

  @override
  String get customStudyDaysAhead => 'Giorni in anticipo:';

  @override
  String customStudyDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get selectTag => 'Seleziona tag:';

  @override
  String get noTagsInDeck => 'Nessun tag trovato in questo mazzo.';

  @override
  String get cramModeTitle => 'Modalità Cram (Ripasso Libero)';

  @override
  String get cramModeDesc =>
      'Esercitati sulle carte senza modificare gli intervalli FSRS o la cronologia';

  @override
  String get advanceReviewDesc =>
      'Aggiorna gli intervalli FSRS e registra le recensioni normalmente';

  @override
  String get start => 'Inizia';

  @override
  String get cramSessionTitle => 'Sessione Cram';

  @override
  String get cramBadge => 'CRAM';

  @override
  String get cramCompletedTitle => 'Sessione di ripasso completata!';

  @override
  String get cramCompletedDesc => 'Hai terminato la sessione di ripasso.';

  @override
  String get allCardsReviewedTitle => 'Tutte le carte completate per oggi!';

  @override
  String get greatJobUpcomingReviews =>
      'Ottimo lavoro! Torna più tardi per i prossimi ripassi.';

  @override
  String get backToDeck => 'Torna al mazzo';

  @override
  String cardProgress(int current, int total) {
    return 'Carta $current di $total';
  }

  @override
  String cardsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rimanenti',
      one: '1 rimanente',
    );
    return '$_temp0';
  }

  @override
  String get create => 'Crea';

  @override
  String get editDeck => 'Modifica Mazzo';

  @override
  String get deckNameHint => 'es., Biologia 101';

  @override
  String get deckNameRequired => 'Il nome del mazzo è obbligatorio';

  @override
  String get nameTooLong => 'Il nome deve contenere al massimo 100 caratteri';

  @override
  String get deckDescriptionHint => 'Descrizione opzionale di questo mazzo';

  @override
  String get themeSystemSubtitle => 'Segui le impostazioni del dispositivo';

  @override
  String get themeDarkSubtitle => 'Usa sempre il tema scuro';

  @override
  String get themeLightSubtitle => 'Usa sempre il tema chiaro';

  @override
  String cardsDueForReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte da ripassare',
      one: '1 carta da ripassare',
    );
    return '$_temp0';
  }

  @override
  String get heatmapLess => 'Meno';

  @override
  String get heatmapMore => 'Più';

  @override
  String reviewsInPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ripassi nel periodo',
      one: '1 ripasso nel periodo',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String reminderAtTime(String time) {
    return 'Notifica di ripasso giornaliera alle $time';
  }

  @override
  String rateButtonSemantics(String label, String interval) {
    return 'Valuta $label, prossimo ripasso tra $interval';
  }

  @override
  String get cramRequeue => 'Ripeti';

  @override
  String get cramPass => 'Passa';

  @override
  String get fullBackupJson => 'Backup JSON Completo';

  @override
  String get backupExportedSuccess => 'Backup esportato con successo!';

  @override
  String cardPromptSemantics(String content) {
    return 'Domanda della carta: $content';
  }

  @override
  String cardAnswerSemantics(String content) {
    return 'Risposta della carta: $content';
  }

  @override
  String get ankiImportTitle => 'Pacchetto Anki (.apkg)';

  @override
  String get ankiImportDescription =>
      'Importa mazzi e carte direttamente da pacchetti Anki (.apkg), inclusi modelli Base, Cloze e tag.';

  @override
  String get importAnki => 'Importa Anki (.apkg)';

  @override
  String ankiImportSuccess(int cards, int decks, int tags, int skipped) {
    return 'Importate $cards carte in $decks mazzi ($tags tag creati, $skipped ignorate).';
  }

  @override
  String get pickFile => 'Seleziona File';

  @override
  String get saveToFile => 'Salva su File';

  @override
  String get pasteText => 'Incolla Testo';

  @override
  String get selectAnkiDestination => 'Destinazione Importazione Anki';

  @override
  String get keepAnkiDecks => 'Mantieni i nomi originali dei mazzi';

  @override
  String get chooseTargetDeck => 'Importa in un mazzo esistente';

  @override
  String get searchCards => 'Cerca carte...';

  @override
  String get noCardsMatchingSearch => 'Nessuna carta corrisponde alla ricerca.';

  @override
  String get fileSavedSuccess => 'File salvato con successo!';

  @override
  String get discardChangesTitle => 'Scartare le modifiche?';

  @override
  String get discardChangesMessage =>
      'Ci sono modifiche non salvate. Sei sicuro di volerle scartare?';

  @override
  String get discard => 'Scarta';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String totalCount(int count) {
    return '$count totale';
  }

  @override
  String systemIntegration(String platform) {
    return 'Integrazione di sistema: $platform';
  }

  @override
  String heatmapReviewTooltip(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ripassi il $date',
      one: '1 ripasso il $date',
    );
    return '$_temp0';
  }

  @override
  String get weekdayMon => 'L';

  @override
  String get weekdayWed => 'M';

  @override
  String get weekdayFri => 'V';

  @override
  String get copyReleaseLink => 'Copia link release';

  @override
  String linkCopiedToClipboard(String url) {
    return 'URL della release copiato negli appunti: $url';
  }

  @override
  String errorSavingCard(String error) {
    return 'Errore durante il salvataggio della carta: $error';
  }

  @override
  String get srsAlgorithm => 'Algoritmo SRS';

  @override
  String get srsAlgorithmDesc =>
      'Seleziona l\'algoritmo di ripetizione spaziata per lo studio.';

  @override
  String get fsrsAlgorithmName => 'FSRS (Predefinito)';

  @override
  String get fsrsAlgorithmDesc => 'Modello basato su stabilità';

  @override
  String get sm2AlgorithmName => 'SM-2 (Classico)';

  @override
  String get sm2AlgorithmDesc => 'Classico SuperMemo 2 (standard Anki)';

  @override
  String get examPlan => 'Piano di Studio Esame';

  @override
  String get examDate => 'Data Esame';

  @override
  String get setExamDate => 'Imposta Data Esame';

  @override
  String get clearExamDate => 'Rimuovi Data Esame';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni rimasti',
      one: '1 giorno rimasto',
      zero: 'Oggi',
    );
    return '$_temp0';
  }

  @override
  String dailyNewTarget(int count) {
    return 'Obiettivo: $count nuove carte/giorno';
  }

  @override
  String estimatedReviews(int count) {
    return '~$count ripassi/giorno';
  }

  @override
  String get unsustainableWorkload =>
      'Carico elevato! Valuta di iniziare prima o ridurre il target di memorizzazione.';

  @override
  String get setDueDate => 'Imposta Data di Scadenza';

  @override
  String get resetProgress => 'Azzera Progressi';

  @override
  String get resetProgressConfirmation =>
      'Sei sicuro di voler azzerare i progressi di questa carta? Tornerà ad essere una carta nuova, ma la cronologia dei ripassi sarà preservata.';

  @override
  String get duplicateCard => 'Crea Copia';

  @override
  String get flag => 'Contrassegno';

  @override
  String get flagNone => 'Nessun Contrassegno';

  @override
  String get flagRed => 'Rosso';

  @override
  String get flagOrange => 'Arancione';

  @override
  String get flagGreen => 'Verde';

  @override
  String get flagBlue => 'Blu';

  @override
  String get filterLeech => 'Sanguisuga';

  @override
  String get filterFlag => 'Contrassegno';

  @override
  String get leechDetectedAlert =>
      'Sanguisuga rilevata! Carta fallita ripetutamente.';

  @override
  String get leechSuspendedAlert =>
      'Sanguisuga rilevata! Carta sospesa automaticamente.';

  @override
  String get autoBackups => 'Backup Automatici';

  @override
  String get noAutoBackupsYet => 'Nessun backup automatico ancora presente.';

  @override
  String get restoreBackup => 'Ripristina';

  @override
  String get restoreBackupConfirmation =>
      'Sei sicuro di voler ripristinare questo backup? I dati correnti verranno sostituiti.';

  @override
  String get vacationMode => 'Modalità Vacanza';

  @override
  String get vacationModeActive => 'Attiva • Scadenze congelate';

  @override
  String get vacationModeInactive => 'Disattivata • Studio regolare';

  @override
  String get leechCardsSubtitle => 'Carte fallite spesso';
}
