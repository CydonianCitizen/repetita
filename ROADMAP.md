# Roadmap Sviluppo Repetita (v0.2.0 -> v1.0.0 & Future)

Documento di pianificazione tecnica basato sulle scelte funzionali definite per Repetita (architettura offline-first, motore matematico FSRS, Drift SQLite, Material 3).

---

## Panoramica Versioni

| Versione | Focus Principale | Funzionalità Chiave | Complessità |
| :--- | :--- | :--- | :--- |
| **v0.2.0** <br>*(Completato)* | Core Study Flow & Visual Analytics | • Undo Review (1-step) [x]<br>• Sospensione & Rinvio (Suspend/Bury) [x]<br>• Heatmap Calendario & Streak [x] | Media |
| **v0.2.1** <br>*(Completato)* | Audit, Polish & Consolidamento | • Ponytail dead code cuts & dep purge [x]<br>• Drift due count fix & Backup consistency [x]<br>• Impeccable i18n & batch card creation UX [x] | Bassa |
| **v0.3.0** <br>*(Completato)* | Formati Carte & Organizzazione | • Cloze Deletion (`{{c1::...}}`) [x]<br>• Sistema Tag & Filtri per Carta [x] | Media |
| **v0.4.0** <br>*(Completato)* | Flessibilità Studio | • Custom Study (Cram Mode / Ripasso Libero) [x] | Media |
| **v0.6.0** <br>*(Completato)* | Ecosistema & File Transfer | • Importazione Anki Package (`.apkg`) [x]<br>• File Picker & Save nativo (.apkg, .json, .csv) [x]<br>• Ricerca Flashcard per Mazzo [x] | Alta |
| **v0.7.0** <br>*(Completato)* | Desktop Edition (Windows & macOS) | • Supporto nativo desktop Windows (x64) & macOS [x]<br>• Layout adattivo Material 3 (`NavigationRail` vs `NavigationBar`) [x]<br>• Scorciatoie da tastiera (Space, 1-4, Ctrl+Z, Ctrl+Enter) [x]<br>• Dimensioni minime finestra e vincoli ergonomici maxWidth [x] | Media |
| **v0.7.5** <br>*(Completato)* | Astrazione Motore SRS & CI/CD Release | • Interfaccia universale `SrsScheduler` & Riverpod provider [x]<br>• Seeder onboarding mazzo iniziale (`SampleDeckSeeder`) [x]<br>• Fix release pipeline CI/CD (macOS Universal, Windows x64, Android split) [x]<br>• Audit Ponytail & Impeccable (deduplicazione coda studio e dead code) [x] | Bassa |
| **v0.8.0** <br>*(Completato)* | Motore Multi-Algoritmo (FSRS & SM-2) | • Architettura Strategy Pattern per scheduler SRS [x]<br>• Motore logico SM-2 puro (Easiness Factor & Intervalli) [x]<br>• Selettore algoritmo nelle Impostazioni [x]<br>• Migrazione schema Drift e gestione transizioni carte [x] | Media |
| **v0.8.7** <br>*(Completato)* | Performance, Display & Settings Modularization | • Tema Pure Black AMOLED & gestione dinamica refresh rate [x]<br>• PRAGMA SQLite ad alte prestazioni (WAL, cache, mmap) [x]<br>• Haptic feedback nativo Android & ripristino vibrazione [x]<br>• Riorganizzazione modulare impostazioni in sotto-schermate [x] | Media |
| **v0.9.0** <br>*(Completato)* | Study Controls, Revision & Exam Mastery | • Set Due Date / Reset / Create Copy [x]<br>• Leech Detection (soglia lapse + auto-tag/suspend) [x]<br>• Flag Colorate (4 colori) [x]<br>• Exam Scheduler (piano per data esame, retention consigliata) [x]<br>• Fuzz factor FSRS & Pause scheduler (vacation mode) [x]<br>• Backup automatico rolling [x] | Bassa |
| **v0.9.1** <br>*(Completato)* | Modello Note, Siblings & Input Attivo | • Carte reverse come note type [x]<br>• Bury siblings automatico [x]<br>• Type-in-the-answer [x]<br>• Supporto RTL languages [x]<br>• Timeboxing & Auto-advance [x] | Media |
| **v0.9.2** <br>*(Completato)* | Interoperabilità & Navigazione | • Subdeck gerarchici (`PARENT::CHILD`) [x]<br>• Card Browser globale & filtri [x]<br>• Export `.apkg` con note e scheduler [x] | Media |
| **v0.9.3** <br>*(Completato)* | Media Pipeline & Image Occlusion | • Tabella Drift Media & deduplica SHA-256 [x]<br>• Visualizzatore immagini con zoom pinch-to-zoom [x]<br>• Inserimento immagini in CardEditorScreen [x]<br>• Image Occlusion Editor interattivo con canvas [x]<br>• Hide-all reveal-one studio rendering [x] | Alta |
| **v0.9.4** <br>*(Completato)* | Advanced Analytics, FSRS Optimizer, Math & Gestures | • Statistiche estese (True retention & istogramma intervalli) [x]<br>• Card Info & curve di stabilità S/D/R [x]<br>• FSRS Optimizer on-device in background Isolate [x]<br>• Rendering Markdown & KaTeX LaTeX offline [x]<br>• Gesture personalizzabili in Studio (swipe & double tap) [x]<br>• Widget Home Screen nativo Android (conteggio dovute/nuove) [x] | Alta |
| **v0.9.5** <br>*(Completato)* | Audio Pipeline, Ephemeral Whiteboard & SRS Hardening | • 100% test coverage motori SRS (FSRS / SM-2) [x]<br>• Registrazione audio da microfono in Card Editor [x]<br>• Playback audio, autoplay & hotkey 'R' in Studio [x]<br>• Import/Export Anki .apkg con pacchettizzazione audio/media [x]<br>• Whiteboard effimera in Studio per richiamo attivo motorio [x] | Media |
| **v0.9.6** <br>*(Completato)* | TTS Offline di Sistema & Audio Polish | • Sintesi vocale offline nativa (Android TTS, Windows SAPI, Apple AVSpeech, Linux speech-dispatcher) [x]<br>• Sanitizzazione automatica testo carte (strip cloze, math LaTeX, markdown, HTML, audio) [x]<br>• Switch auto-TTS e regolazione velocità di lettura nelle impostazioni [x]<br>• Pulsante TTS in sessione di studio e hotkey desktop 'T' [x] | Bassa |
| **v1.0.0** | Consolidamento & Stabilità Finale | • Migrazioni Drift blindate (test suite automatica) [x]<br>• Zero bug, zero warning, packaging store F-Droid e desktop [x] | Bassa |
| **Spike / Future** <br>*(Ricerca)* | Ricerca tecnica zero-cloud | • Sincronizzazione opzionale file-based zero-cloud (cartella condivisa / Syncthing / SMB / USB) [DA STUDIARE] | Variabile |

---

## Dettaglio Funzionalità Scelte

### 1. v0.2.0: Core Study Flow & Visual Analytics [COMPLETATO]

#### 1.1 Undo Review (Limitato a 1 step) [COMPLETATO]
* **Obiettivo**: Permettere di correggere un tap errato sulla barra delle valutazioni senza complicare lo stato.
* **Specifiche**:
  * Limitato esclusivamente all'**ultima carta valutata** nella sessione di studio corrente (buffer di cronologia a dimensione 1).
  * Ripristina in memoria e a database lo stato FSRS precedente della carta (`state`, `stability`, `difficulty`, `due`, `last_review`, `reps`, `lapses`).
  * Elimina l'ultimo record `ReviewLog` generato per quella carta.
  * Pulsante azione "Annulla" visibile nell'AppBar di `StudyScreen` con icona undo e tooltip.
* **Architettura**:
  * Metodo dedicato in `StudySessionDao.undoReview(...)` eseguito in transazione SQLite atomica.
  * Invocazione da `StudySessionController.undoReview()`.

#### 1.2 Sospensione & Rinvio Carte (Suspend / Bury) [COMPLETATO]
* **Obiettivo**: Dare all'utente pieno controllo sulle carte problematiche o già note per la giornata.
* **Specifiche**:
  * **Sospendi (Suspend)**: Disattiva la carta indefinitamente fino a riattivazione manuale. Esclusa da tutte le code di studio.
  * **Rinvia (Bury)**: Rimanda la carta al giorno successivo senza considerarla un fallimento (`Again`).
* **Persistenza (Drift)**:
  * Aggiunta campi alla tabella `Cards`: `isSuspended` (bool, default `false`) e `buriedUntil` (DateTime nullable), schemaVersion 2 con migrazione `onUpgrade`.
  * Aggiornamento query di selezione carte dovute (`getDueCards`) per filtrare `isSuspended == false` e `buriedUntil <= now`.
* **UI**:
  * Badge visuali "Sospesa" e "Rinviata" in `_CardTile`.
  * Voci nel menu popup di `_CardTile` (Sospendi/Riattiva, Rinvia/Annulla rinvio).
  * Voci nel menu popup dell'AppBar di `StudyScreen` (Rinvia carta, Sospendi carta).

#### 1.3 Heatmap Calendario (Attività & Streak) [COMPLETATO]
* **Obiettivo**: Visualizzare la costanza quotidiana e motivare la retention dello studio.
* **Specifiche**:
  * Widget `ReviewHeatmapWidget` (matrice 15 settimane x 7 giorni) integrata in `StatsScreen`.
  * Conteggio recensioni giornaliere aggregato da `ReviewLogs` via `StatsDao.getDailyReviewCounts`.
  * Calcolo dello streak corrente (giorni consecutivi di studio) tramite funzione pura deterministica `calculateStreak`.
  * Badge streak con icona fiamma e gradiente tonale Material 3 proporzionale al volume di studio.
* **Vincoli**:
  * Zero dipendenze esterne: rendering puro Material 3 con tooltip interattivi e legenda.

---

### 2. v0.3.0: Formati Carte & Organizzazione [COMPLETATO]

#### 2.1 Cloze Deletion (Testo a Scomparsa / Riempimento) [COMPLETATO]
* **Obiettivo**: Supportare flashcard con parti di frase nascoste, standard per lingue, definizioni e formule.
* **Specifiche**:
  * Sintassi standard: `{{c1::risposta}}` e con suggerimento opzionale: `{{c1::risposta::suggerimento}}`.
  * Parser puro in Dart (`lib/src/core/algorithms/cloze/`) con zero dipendenze da Flutter o DB.
  * Fronte carta: mostra `[...]` o `[suggerimento]`.
  * Retro carta: mostra la risposta evidenziata nel colore primario del tema M3.
  * Supporto per cloze multipli (`c1`, `c2`) che generano carte indipendenti o mostrano contesti unificati.

#### 2.2 Sistema Tag / Etichette [COMPLETATO]
* **Obiettivo**: Organizzazione trasversale delle carte, indipendente dalla gerarchia dei mazzi.
* **Specifiche**:
  * Tabelle Drift: `Tags` (id, name, color) e tabella ponte `CardTags` (cardId, tagId) con cascading delete.
  * Chip input rapido in `CardEditorScreen`.
  * Badge tag visibili nelle card preview.
  * Filtro rapido per tag nell'elenco carte di un mazzo.

---

### 3. v0.4.0: Flessibilità Studio [COMPLETATO]

#### 3.1 Custom Study (Cram Mode / Ripasso Libero) [COMPLETATO]
* **Obiettivo**: Consentire sessioni di studio straordinario prima di un esame, anche quando il conteggio "due" è zero.
* **Specifiche**:
  * Opzioni avvio: "Ripassa tutte le carte", "Ripassa solo carte con Tag X", "Ripassa in anticipo di N giorni".
  * Modalità non distruttiva: possibilità di studiare senza registrare penalità FSRS, oppure registrare anticipi secondo la corretta equazione FSRS per intervalli anticipati.

---

### 4. v0.6.0: Ecosistema & File Transfer [COMPLETATO]

#### 4.1 Importazione Anki Package (`.apkg`) [COMPLETATO]
* **Obiettivo**: Permettere l'importazione diretta di mazzi dalla vasta libreria della community Anki.
* **Specifiche**:
  * Formato `.apkg`: archivio zip decompresso offline tramite package standard `archive`.
  * Estrazione SQLite `collection.anki2` con package `sqlite3`.
  * Sanitizzazione HTML e conversione markdown con parsing Cloze (`{{c1::...}}`), formattazione e liste pulite.
  * Mappatura modelli Basic, Cloze e Reverse con gestione tag e opzioni di destinazione (nuovo mazzo o mazzo esistente).
  * Inserimento transazionale batch e report statistico (`AnkiImportResult`).

#### 4.2 File Picker & Saver Nativo [COMPLETATO]
* **Obiettivo**: Importazione ed esportazione file direttamente da filesystem/storage senza dipendere unicamente da copia/incolla negli appunti.
* **Specifiche**:
  * Integrazione con `file_picker` incapsulata in `FilePickerService`.
  * Supporto selezione ed esportazione per file `.apkg`, `.json` e `.csv`.

#### 4.3 Ricerca Flashcard per Mazzo [COMPLETATO]
* **Obiettivo**: Trovare rapidamente flashcard per testo (fronte o retro) all'interno di un mazzo.
* **Specifiche**:
  * Barra di ricerca integrata nell'AppBar di `DeckDetailScreen`.
  * Filtraggio combinato dinamico con tag selezionati tramite `filteredDeckCardsProvider`.

---

### 5. v0.7.0: Desktop Edition (Windows & macOS) [COMPLETATO]

#### 5.1 Runner Nativi & Toolchain Multipiattaforma [COMPLETATO]
* **Obiettivo**: Esecuzione e compilazione deterministica offline su Windows (Win32/x64) e macOS (Apple Silicon / Intel).
* **Specifiche**:
  * Scaffolding completo `windows/` e `macos/` generato ed integrato in `analysis_options.yaml`.
  * Generazione asset icone desktop (.ico per Windows, asset catalog per macOS) da `repetita-circle-icon-1024.png`.
  * Introduzione `atl_shim` (`windows/atl_shim/atlbase.h`) per abilitare compilazione C++ MSVC istantanea senza dipendere dal componente opzionale ATL nei Build Tools di Visual Studio.
  * Persistenza database SQLite e archiviazione locale su directory documenti di sistema (`path_provider`).

#### 5.2 Layout Adattivo Material 3 [COMPLETATO]
* **Obiettivo**: Esperienza visiva di primo livello adatta alle proporzioni di monitor widescreen (FHD, QHD, 4K).
* **Specifiche**:
  * `NavigationRail` laterale attivo automaticamente quando la larghezza della finestra è >= 640px.
  * `NavigationBar` inferiore preservata per viewport compatti e schermi verticali.
  * Contenitori con vincoli `BoxConstraints(maxWidth: 800)` e centratura automatica in `StudyScreen` e `CardEditorScreen`.
  * Dimensioni minime della finestra fissate nativamente a 640x500px (`WM_GETMINMAXINFO` su Windows, `NSWindow.minSize` su macOS) per impedire clipping dell'interfaccia.

#### 5.3 Ergonomia Desktop & Scorciatoie da Tastiera [COMPLETATO]
* **Obiettivo**: Velocità di revisione e inserimento rapido paragonabile alle migliori desktop app per ripetizione spaziata (Anki).
* **Specifiche**:
  * **Sessione di Studio**:
    * `Spazio` o `Invio`: Mostra risposta (gira la flashcard).
    * `1`, `2`, `3`, `4`: Seleziona rispettivamente `Again`, `Hard`, `Good`, `Easy`.
    * `Ctrl+Z` / `Cmd+Z`: Annulla l'ultima revisione.
    * Badge visivi con scorciatoia (`1`, `2`, `3`, `4` e `[Space]`) renderizzati sui pulsanti quando in ambiente desktop.
  * **Editor Carte**:
    * `Ctrl+Invio` / `Cmd+Invio` e `Ctrl+S` / `Cmd+S`: Salvataggio immediato della flashcard.

---

### 5.4 v0.7.5: Astrazione Motore SRS & CI/CD Release [COMPLETATO]

#### 5.4.1 Interfaccia SrsScheduler & Decoupling Motore [COMPLETATO]
* **Obiettivo**: Generalizzare il motore di scheduling per preparare l'integrazione di SM-2 senza rompere i contratti esistenti.
* **Specifiche**:
  * Creazione interfaccia pura `SrsScheduler` (`lib/src/core/algorithms/srs/srs_scheduler.dart`).
  * Implementazione di `SrsScheduler` da parte di `FsrsEngine`.
  * Introduzione del provider Riverpod `srsSchedulerProvider` e refactoring di `StudySessionController`.

#### 5.4.2 Mazzo Dimostrativo Onboarding (`SampleDeckSeeder`) [COMPLETATO]
* **Obiettivo**: Fornire mazzo e carte di benvenuto (Basic e Cloze) al primo avvio offline dell'applicazione.
* **Specifiche**:
  * Modulo `SampleDeckSeeder` idempotente attivato se il database non contiene mazzi.
  * Mazzo "Benvenuto su Repetita" con 3 carte didattiche esplicative di FSRS e Cloze Deletion.

#### 5.4.3 Stabilizzazione CI/CD & GitHub Actions Release [COMPLETATO]
* **Obiettivo**: Pipeline di compilazione e rilascio automatica per Android (split APKs), macOS (Universal arm64 + x86_64) e Windows (x64).
* **Specifiche**:
  * Risoluzione conflitto NDK ABI filters in Gradle (`android/app/build.gradle.kts`) per abilitare `--split-per-abi`.
  * Configurazione firma ad-hoc in `Release.xcconfig` e `project.pbxproj` per consentire a Xcode di compilare su GitHub Actions senza account Apple Developer a pagamento.
  * Verifica e packaging via percorso assoluto `$PWD` e `lipo -info` nel workflow di rilascio.

---

### 5.5 v0.8.0: Motore Multi-Algoritmo (FSRS & SM-2) [COMPLETATO]
* **Obiettivo**: Rendere Repetita un benchmark harness agnostico rispetto all'algoritmo SRS, supportando sia il moderno FSRS sia il classico SuperMemo SM-2 con selettore utente.
* **Specifiche**:
  * **Modulo SM-2 Puro** (`lib/src/core/algorithms/sm2/`):
    * Modello matematico a zero dipendenze per calcolo di $EF$ (Easiness Factor), intervalli $I(n)$, e gestione lapse con rating 1..4 (Again, Hard, Good, Easy).
    * Test unitari con 100% di copertura.
  * **SrsScheduler Strategy Pattern**: [COMPLETATO in v0.7.5]
    * Astrazione comune che disaccoppia `StudySessionController` e `StudySessionDao` dal tipo concreto di motore.
  * **Impostazioni & Selezione**:
    * Opzione di selezione motore in `SettingsScreen` (FSRS vs SM-2) salvata in `AppSettings`.
  * **Gestione Transizione & Persistenza**:
    * Migrazione Drift per accogliere i metadati SM-2 senza perdita di coerenza per le carte preesistenti.
    * Miglioramento dell'import Anki (`.apkg`) per preservare il fattore $EF$ originario.

---

### 5.6 v0.8.7: Performance, Display & Settings Modularization [COMPLETATO]
* **Obiettivo**: Minimizzare i consumi energetici su display OLED/AMOLED, massimizzare il throughput I/O del database locale, ripristinare il feedback aptico nativo e razionalizzare la UI delle impostazioni.
* **Specifiche**:
  * **Tema AMOLED Pure Black**:
    * Palette scura a contrasto assoluto (`#000000`) per azzerare l'assorbimento dei pixel su display OLED.
    * Integrato in `AppThemeMode.amoled` con toggle dedicato e persistenza Riverpod.
  * **Ottimizzazione I/O SQLite (`AppDatabase`)**:
    * Configurazione PRAGMA: `journal_mode = WAL`, `synchronous = NORMAL`, `cache_size = -64000` (64MB), `temp_store = MEMORY`, `mmap_size = 268435456` (256MB).
  * **Gestione Dinamica Refresh Rate**:
    * `DisplayRefreshRateService` con platform channel Android (`setPreferredDisplayMode`) per limitare il frame rate (60Hz / Standard / Massimo) durante lo studio e risparmiare batteria.
  * **Feedback Aptico Nativo**:
    * Platform channel nativo Android (`repetita/haptics`) con fallback su `HapticFeedback` di Flutter e permesso `android.permission.VIBRATE` per garantire il funzionamento su tutti i dispositivi.
  * **Modularizzazione Impostazioni**:
    * Scomposizione della schermata Impostazioni in sotto-schermate tematiche: *Aspetto*, *Algoritmo di studio*, *Lingua*, *Aggiornamenti*, *Informazioni*.
    * Rimozione del word wrapping disomogeneo e pulizia dei badge testuali ridondanti nella navigazione principale.

---

### 6. Architettura dei Rilasci Futuri (v0.9.0 -> v2.0.0)

Il piano evolutivo nasce da un'analisi di benchmark sulle feature dei competitor (Anki Desktop, AnkiDroid, AnkiMobile, RemNote, Mochi, ecosistema FSRS) e assegna a ciascuna funzionalità una versione precisa:
* **v0.9.0**: Study Controls, Revision Utilities & Exam Mastery (Set Due/Reset/Copy §7.3, Leech Detection §7.4, Flag colorate §7.2, Fuzz §8.1, Vacation mode §8.2, Rolling Backup §7.1, Exam Scheduler §12.1) [COMPLETATO].
* **v0.9.1**: Modello Note, Siblings & Input Attivo (Carte Reverse §10.1, Bury Siblings §10.2, Type-in-the-answer §10.3, RTL languages §13.3, Timeboxing §10.5, Auto-advance §10.6) [COMPLETATO].
* **v0.9.2**: Interoperabilità & Navigazione (Export .apkg bidirezionale §11.1, Subdeck gerarchici `Parent::Child` §11.2, Card Browser multi-criterio §11.3) [COMPLETATO].
* **v1.0.0**: Consolidamento, Migrazioni Drift blindate & Test Coverage completa.
* **v1.2.0**: Media Pipeline & Image Occlusion (§9.1-9.3, §10.4).
* **v1.4.0**: Audio & Ergonomia Mobile (Audio §9.4, Widget §13.1, Gestures §13.2, Whiteboard §15.1).
* **v1.5.0**: Visual Analytics Avanzate (Grafici e curve di ritenzione §14.4).
* **Spike / v2.0.0**: Sincronizzazione opzionale file-based (§14.5), FSRS Optimizer (§14.1), TTS offline (§14.2), Markdown avanzato + MathJax (§14.3).

---

### 7. Dati & Utilità di Revisione [v0.9.0]

#### 7.1 Backup Automatico Rolling
* **Obiettivo**: Proteggere l'utente dalla perdita di dati anche quando non esporta mai manualmente (il backup JSON/CSV esiste ma è un'azione onerosa e facilmente dimenticata).
* **Specifiche**:
  * Snapshot automatico del database all'avvio se sono trascorse più di N ore dall'ultimo backup (riferimento AnkiDroid: 5 ore, retention 8 copie).
  * Formato: riutilizzo del payload JSON di `BackupService` oppure copia fisica SQLite via `VACUUM INTO` (atomicità garantita dal WAL attivo).
  * Retention configurabile in Impostazioni → Backup (default: ultime 8 copie), eliminazione FIFO delle più vecchie.
  * UI: lista backup con data e ripristino con conferma esplicita (pattern anti-restore distruttivo dell'audit §2.6).
  * Esecuzione differita a app idle, mai durante la sessione di studio.

#### 7.2 Flag Colorate (4 colori) + Mark
* **Obiettivo**: Marcatura rapida di carte problematiche durante la sessione senza uscire dal flusso di studio.
* **Specifiche**:
  * Schema: campo `flag` in `Cards` (int, 0=nessuna, 1=rossa, 2=arancione, 3=verde, 4=blu) + flag booleano "marked" a livello nota.
  * Toggle dal menu azioni di `StudyScreen`; bandierina visibile nell'angolo della carta durante la revisione.
  * Badge e filtri per flag in `DeckDetailScreen`, combinabili con i filtri tag esistenti (`filteredDeckCardsProvider`).
  * Sintassi di ricerca compatibile Anki (`flag:1`) in ottica Card Browser globale (§11.3).

#### 7.3 Set Due Date / Reset / Create Copy [NUOVA]
* **Obiettivo**: Controllo manuale fine sullo scheduling e sul contenuto, senza passare dalle valutazioni SRS.
* **Specifiche**:
  * **Set Due Date**: forza la scadenza di una carta a una data scelta, dal menu azioni di `StudyScreen` e di `DeckDetailScreen` (differire a domani, pianificare ripassi pre-esame).
  * **Reset Progress**: riporta la carta in coda come nuova azzerando `state`, `stability`, `difficulty`, `easinessFactor` ma conservando lo storico `ReviewLogs` (ripartenze pulite senza perdita di storia).
  * **Create Copy**: duplica la nota nell'editor con campi precompilati per creare varianti senza ri-digitare.
  * Costo contenuto: tre metodi DAO in transazione atomica + voci di menu.

#### 7.4 Leech Detection [NUOVA]
* **Obiettivo**: Rilevare automaticamente le carte "sanguisughe" che falliscono ripetutamente — quasi sempre sintomo di carta scritta male (ambigua o troppo densa) — e guidare l'utente alla correzione invece che lasciarle succhiare tempo ogni sessione.
* **Specifiche**:
  * Soglia lapse configurabile (riferimento Anki: 8 lapse) sul campo `Cards.lapses` già esistente.
  * Al superamento della soglia: tag automatico "leech" + notifica in sessione con azioni rapide (modifica carta, sospendi, ignora).
  * Filtro "leech" in `DeckDetailScreen` e nel Card Browser (§11.3); contatore dedicato in `StatsScreen`.
  * Due modalità come Anki: "solo tagga" oppure "tagga e sospendi" (scelta in Impostazioni → Studio).

---

### 8. Scheduling Avanzato [v0.9.0]

#### 8.1 Fuzz Factor FSRS
* **Obiettivo**: Evitare il clustering: carte introdotte e valutate identicamente non devono scadere tutte lo stesso giorno (fenomeno tipico dei mazzi importati con scadenze uniformi).
* **Specifiche**:
  * Offset pseudo-casuale proporzionale all'intervallo, con range calibrati sull'implementazione di riferimento FSRS/Anki; disattivo sulle carte in learning e sugli intervalli < 2 giorni.
  * Applicato in `SrsScheduler` solo alla schedulazione reale; l'anteprima sugli intervalli dei pulsanti di rating resta deterministica.
  * RNG iniettabile e seedabile per test deterministici, coerente con il pattern `clock_provider`.
  * Opzione avanzata disattivabile nel dialog parametri FSRS.

#### 8.2 Pause Scheduler (Vacation Mode)
* **Obiettivo**: Congelare lo scheduling durante pause e ferie senza generare backlog insostenibile né falsi lapse.
* **Specifiche**:
  * Impostazione con intervallo date (o toggle on/off con data fine) in Impostazioni → Studio.
  * Durante la pausa: coda studio nascosta, reminder giornalieri sospesi automaticamente.
  * Alla riattivazione: shift unico di massa `due += giorni di pausa` sulle carte review/learning. FSRS gestisce nativamente le review in ritardo, ma lo shift evita il picco di workload del primo giorno di rientro.
  * Le nuove carte restano congelate (posizione in coda invariata).

---

### 9. Media [v1.2.0 & v1.4.0]

#### 9.1 Pipeline Media
* **Obiettivo**: Fondazione tecnica per le immagini (prerequisito diretto di Image Occlusion §10.4 e base per l'Audio §9.4). Prima tappa del piano media: immagini prima, audio dopo.
* **Specifiche**:
  * Tabella Drift `Media` (id, fileName, checksum SHA-256, sizeBytes, createdAt) + directory media privata dell'app (`path_provider` già in bundle).
  * Deduplica per checksum; comando "Verifica media" per la pulizia degli orfani (stile Anki "Check media").
  * Compressione/resize automatico all'inserimento (target: lato lungo ≤ 1600px, dimensione contenuta).
  * Inserimento: `file_picker` (già dipendenza), incolla da clipboard, drag & drop su desktop.

#### 9.2 Editor & Rendering Studio
* **Obiettivo**: Immagini di prima classe nell'editor e nella sessione di studio.
* **Specifiche**:
  * Embed nel testo delle carte con risoluzione dei riferimenti (`media://id`), mantenendo la compatibilità con `<img src="...">` proveniente dall'import Anki.
  * Rendering in `FlipCardView` con tap-to-zoom e adattamento al tema (opzionale filtro invert in dark/AMOLED per immagini a linee).
  * Preview live nell'editor dual-pane desktop (`card_editor_screen.dart`).

#### 9.3 Import / Export
* **Obiettivo**: Chiudere il loop con i deck Anki esistenti: l'import `.apkg` estrae già i media oggi, ma non possono essere visualizzati né conservati.
* **Specifiche**:
  * Import `.apkg`: persistenza dei media estratti nella tabella `Media` e rewriting dei riferimenti nelle carte.
  * Backup JSON: payload esteso con i media (archivio con riferimenti o base64 inline).
  * CSV: invariato (formato testuale).

#### 9.4 Audio nelle Carte
* **Obiettivo**: Supporto audio per lingue e pronuncia. Seconda e ultima tappa del piano media, dopo le immagini.
* **Specifiche**:
  * Registrazione da microfono nell'editor con riascolto pre-salvataggio; import file audio da `file_picker`.
  * Playback automatico fronte/retro in sessione + replay manuale (tasto `R` su desktop); solo plugin audio open-source compatibili F-Droid.
  * Audio inclusi in export `.apkg` (§11.1) e backup JSON.

---

### 10. Tipi di Carta & Studio [v0.9.1 & v1.2.0]
 
#### 10.1 Carte Reverse come Note Type [COMPLETATO in v0.9.1]
* **Obiettivo**: Generazione bidirezionale Fronte→Retro e Retro→Fronte dalla stessa nota (vocabolari, definizioni bidirezionali). L'import `.apkg` già riconosce il modello "Basic (and reversed)" ma l'editor non può crearlo.
* **Specifiche**:
  * Introduzione del concetto di **nota** con N carte generate: campo `noteId` in `Cards` (+ eventuale tabella `Notes` per i contenuti condivisi) e tipo di nota sul modello.
  * **Meccanismo di generazione**: pura sostituzione/scambio di campi definita dal tipo di nota (template) — operazione meccanica e deterministica, nessun LLM né generazione di contenuti. Il tipo "Basic (and reversed)" produce 2 carte scambiando fronte/retro; il tipo "Cloze" produce 1 carta per numero di cloze (meccanismo già implementato dal `ClozeParser` e dal batching atomico, oggi però senza legame `noteId` tra le carte generate).
  * Ogni carta generata mantiene **stato SRS indipendente** (`stability`, `difficulty`, `easinessFactor`, `due`, `lapses`): il motore logico schedula ogni sorella separatamente, come memorie distinte. Il `noteId` serve solo come legame di provenienza per bury siblings (§10.2), modifica sincronizzata ed eliminazione a cascata.
  * Editor: opzione "genera anche la carta inversa" con preview delle carte che verranno create.
  * Creazione/modifica/eliminazione sincronizzata delle carte sorelle in transazione atomica.
  * Dipendenze strutturali: Bury Siblings (§10.2) e Image Occlusion multi-maschera (§10.4) si agganciano allo stesso concetto di nota.

#### 10.2 Bury Siblings Automatico [COMPLETATO in v0.9.1]
* **Obiettivo**: Evitare l'autoinganno: vedere carte sorelle della stessa nota nella stessa sessione fa "ricordare" per contagio, non per richiamo attivo.
* **Specifiche**:
  * La relazione sibling è **derivata automaticamente** dal `noteId` (§10.1): le carte generate dalla stessa nota sono sorelle per costruzione — nessuna segnalazione manuale dell'utente è richiesta. Due carte create indipendentemente, anche se simili per contenuto, non sono sorelle.
  * Al rating di una carta, le sorelle in stato new/review vengono seppellite fino al giorno dopo (comportamento Anki); le carte in learning restano visibili (il tempo è critico).
  * Opzione attivabile/disattivabile (default: attiva) + azione "Unbury" dalla schermata del mazzo.
  * Dipendenza: richiede il concetto di nota (§10.1).

#### 10.3 Type-in-the-Answer [COMPLETATO in v0.9.1]
* **Obiettivo**: Verifica oggettiva del richiamo per spelling, numeri e formule, contro l'autovalutazione indulgente.
* **Specifiche**:
  * Campo di input nel fronte della carta (marcatore `{{type:...}}` sul campo o flag per tipo di nota).
  * Confronto carattere-per-carattere al flip: verde (corretto), rosso (errato), grigio (mancante) — classi `typeGood`/`typeBad`/`typeMissed` come Anki/AnkiDroid.
  * La digitazione non forza il rating: l'utente sceglie comunque Again/Hard/Good/Easy.
  * Compatibilità IME per lingue, collegata al supporto RTL (§13.3).

#### 10.4 Image Occlusion
* **Dipendenza**: Media — Immagini (§9.1).
* **Obiettivo**: Generare carte "indovina la parte nascosta" da un'immagine (anatomia, mappe, diagrammi, schemi) — la feature train di Anki/RemNote per contenuti visivi.
* **Specifiche**:
  * Editor dedicato: caricamento immagine → disegno di rettangoli/ellissi di mascheratura → generazione N carte (una per maschera, con raggruppamento a livello nota).
  * Modalità "hide all, reveal one" (default stile Anki).
  * Rendering: maschere riempite col colore superficie del tema, reveal al flip della carta.
  * Non distruttivo: definizione delle maschere in JSON referenziato dalla carta, modificabile in seguito.

#### 10.5 Timeboxing [COMPLETATO in v0.9.1]
* **Obiettivo**: Sessioni a tempo con riepilogo periodico per mantenere la concentrazione (tecnica Pomodoro-like).
* **Specifiche**:
  * Impostazione limite minuti (0 = disattivato) in Impostazioni → Studio.
  * Alla scadenza: riepilogo carte studiate e tempo trascorso con scelta "continua"/"termina" (comportamento AnkiDroid).

#### 10.6 Auto-advance [COMPLETATO in v0.9.1]
* **Obiettivo**: Flusso hands-free per revisioni passive.
* **Specifiche**:
  * Mostra la risposta automaticamente dopo N secondi configurabili; opzione di passaggio alla carta successiva con rating automatico "Again" dopo M secondi (comportamento AnkiDroid).
  * Transizioni coerenti con `animation_level` dell'app.

---

### 11. Interoperabilità & Organizzazione [v0.9.2 - COMPLETATO]

#### 11.1 Export .apkg (Deck Package) [COMPLETATO in v0.9.2]
* **Obiettivo**: Interoperabilità bidirezionale con l'ecosistema Anki. Oggi Repetita importa ma non esporta: senza export la data ownership è incompleta (lock-in in entrata).
* **Specifiche**:
  * Generazione archivio `.apkg` (ZIP): `collection.anki2` con schema SQLite di Anki (notes, cards, revlog, media mapping) via package `sqlite3` già in bundle — zero nuove dipendenze.
  * Mappatura modelli: Basic, Basic (and reversed), Cloze nativi `{{c1::}}`; preservazione del fattore EF per SM-2 e dello storico `ReviewLogs`.
  * Opzioni export: "includi storico revisioni" (con flag toggle) per condivisione pulita come Anki.
  * Implementato con `AnkiExportService`, unit test round-trip con re-import Anki e trigger UI da `DeckDetailScreen` e `BackupScreen`.

#### 11.2 Subdeck Gerarchici (`PARENT::CHILD`) [COMPLETATO in v0.9.2]
* **Obiettivo**: Organizzazione a albero stile Anki per corsi, libri e lingue.
* **Specifiche**:
  * Convenzione `::` retrocompatibile (`Parent::Child`), parsing e albero gerarchico ricorsivo (`DeckHierarchyHelper`, `DeckNode`).
  * UI: albero espandibile con chevron animato e indentazione in `DeckListScreen`, conteggi aggregati (somma ricorsiva figli) per i nodi padre.
  * Studio ricorsivo supportato a livello database (`StudySessionDao.fetchDueCardsForDecks`).
  * Badge sottodeck reattivo e supporto a nodi virtuali intermedi.

#### 11.3 Ricerca Globale Flashcard (Card Browser) [COMPLETATO in v0.9.2]
* **Obiettivo**: Cercare e filtrare istantaneamente tra migliaia di carte di tutti i mazzi contemporaneamente.
* **Specifiche**:
  * Metodo `searchCardsGlobal` in `CardsDao` e stream reattivo globale in `CardBrowserController`.
  * UI `CardBrowserScreen` Material 3: SearchBar con clear rapido, FilterChips orizzontali (Mazzo, Flag colorata 1..4, Sospese, In scadenza oggi).
  * Preview delle schede con badge mazzo, stato FSRS/SM-2, stato sospesa, flag colorata, fronte e retro con tap-to-edit in `CardEditorScreen`.
  * Accesso rapido da icona di ricerca nell'AppBar di `DeckListScreen` (`card_browser_button`).

---

### 12. Esami [v0.9.0]

#### 12.1 Exam Scheduler: Piano di Studio per Data Esame
* **Obiettivo**: Data l'esame, Repetita pianifica il lavoro quotidiano (stile RemNote, ma completamente offline sui dati locali).
* **Specifiche**:
  * Configurazione: data esame per mazzo (o gruppo di mazzi), ore di studio giornaliere disponibili.
  * Calcolo: combinazione del forecast esistente (`StatsDao.getDueForecast`) con stima del workload delle nuove carte → distribuzione del carico sui giorni rimanenti e alert su backlog insostenibile.
  * Suggerimento "retention boost" temporaneo (es. 0.90 → 0.95 pre-esame) con preview dell'impatto sul workload giornaliero.
  * Schermata piano giornaliero: "Oggi: 40 review + 12 nuove" con tracking del completamento.

---

### 13. Piattaforma & i18n [v1.1.0 & v1.4.0]

#### 13.1 Widget Home Screen + Quick Study [v1.4.0]
* **Obiettivo**: Studiare senza aprire l'app: il conteggio delle dovute sempre visibile sulla home.
* **Specifiche**:
  * Widget ridimensionabile (2x1 / 4x2) con conteggio carte dovute per mazzo, aggiornato via `WorkManager` (nessun push FCM, compatibilità F-Droid preservata).
  * Deep link `repetita://study?deck=<id>` per apertura diretta della sessione studio.

#### 13.2 Gesture Personalizzabili [v1.4.0]
* **Obiettivo**: Velocità estrema di revisione su mobile senza toccare i pulsanti di rating.
* **Specifiche**:
  * Mappatura configurabile: swipe (su/giù/sinistra/destra), double-tap, tap zone → azioni (rating 1-4, flip, undo, flag, bury, suspend).
  * Perimetro limitato a `StudyScreen`; persistenza in `appSettings`.

#### 13.3 Supporto RTL Languages [v0.9.1 - COMPLETATO]
* **Obiettivo**: Editing e visualizzazione corretti per lingue destra→sinistra (arabo, ebraico, farsi, urdu) — oggi punteggiatura e numeri risultano disallineati nei testi misti.
* **Specifiche**:
  * Rilevamento automatico della direzione per paragrafo (algoritmo Unicode Bidi sul primo carattere forte) oppure flag esplicito per campo/nota.
  * Allineamento a destra e flusso corretto in `FlipCardView`, `card_editor_screen.dart` e nei card tile.
  * Cura specifica per il cloze in RTL: il markup `{{c1::...}}` contiene caratteri neutri/LTR (lesson AnkiDroid: dedicare un tipo di nota per cloze RTL).

---

### 14. Spike di Ricerca Tecnica [Spike / v2.0.0]

Output atteso per ciascuno spike: documento tecnico, PoC prototipale e decisione GO/NO-GO.

#### 14.1 FSRS Optimizer On-Device [COMPLETATO in v0.9.4]
* Fattibilità di un ottimizzatore dei parametri FSRS in Dart puro (gradient descent) addestrato sui `ReviewLogs` locali, senza pytorch né servizi esterni.
* Domande aperte: soglia minima di review per un'ottimizzazione utile; qualità dell'ottimo rispetto all'optimizer di riferimento (benchmark su dataset FSRS-Anki-20k); architettura preset per-mazzo compatibile con lo Strategy Pattern `SrsScheduler`.

#### 14.2 TTS Offline di Sistema [COMPLETATO in v0.9.6]
* Integrazione text-to-speech con i motori di sistema (Android TTS engine, Windows SAPI, macOS `say`) via platform channel, zero servizi cloud.
* Domande aperte: comportamento su motori AOSP senza Google Services (target F-Droid); selezione lingua per campo/mazzo; fallback desktop.

#### 14.3 Markdown Avanzato + MathJax [COMPLETATO in v0.9.4]
* Rendering di tabelle, blocchi codice con syntax highlighting e formule (LaTeX) in `FlipCardView` e nell'editor.
* Domande aperte: pacchetti Dart disponibili vs renderer custom (coerenza col principio zero-dependency dell'`ReviewHeatmapWidget`); performance dentro il flip animato (lesson audit §1.8); impatto sull'import/export.

#### 14.4 Grafici Avanzati [COMPLETATO in v0.9.4]
* Estensione di `StatsScreen`: true retention per bucket di intervallo, distribuzione degli intervalli, breakdown dei pulsanti risposta, curva S/D/R per singola carta (Card Info).
* Domande aperte: libreria esterna (`fl_chart`) vs custom painting (pattern dell'heatmap esistente); query di aggregazione SQL senza degradare l'I/O (lesson audit §1.4).

#### 14.5 Sincronizzazione Opzionale File-Based [NUOVA — versione TBD, da studiare]
* Studio di fattibilità della replica del database tra dispositivi tramite cartella condivisa replicata dall'utente con strumenti a sua scelta (Syncthing, SMB, WebDAV, chiavetta USB) — in coerenza con la filosofia offline-first e zero-cloud.
* Domande aperte: strategia di merge (i `ReviewLogs` sono append-only e si fondono naturalmente; i conflitti reali riguardano solo mazzi/carte modificati); last-write-wins vs log di sincronizzazione vs CRDT; la replica a caldo di un file SQLite in WAL non è sicura → valutare snapshot, esportazioni incrementali o protocollo custom; UI di risoluzione conflitti.

---

### 15. Funzionalità Candidate (in valutazione — decisione pendente) [DA DECIDERE]

#### 15.1 Whiteboard in Studio [COMPLETATO in v0.9.5]
* Canvas trasparente sovrapposto alla carta durante la sessione per scrittura a mano (dito/stylus). Il tratto è **effimero**: cancellato alla carta successiva, mai persistito.
* Caso d'uso primario (comportamento AnkiDroid): **recall attivo motorio** — scrivere l'ideogramma, etichettare l'anatomia, abbozzare la formula *prima* del flip. Non è una funzione di note-taking: nulla viene salvato sulla carta.
* Domanda aperta (2026-10-17): la destinazione d'uso è la scrittura della risposta come esercizio (recall attivo) oppure l'appunto di lavoro temporaneo? Per appunti persistenti servirebbe una feature distinta (annotazioni per carta), da valutare separatamente.

---

### 16. Funzionalità Scartate

* **Profili Multipli** (stile Anki): scartato il 2026-10-17. Il caso d'uso (più utenti sullo stesso dispositivo o separazione di contesti di studio) è considerato non rilevante per il target single-user di Repetita; la separazione per mazzi e tag è ritenuta sufficiente e non giustifica i costi di isolamento DB/impostazioni.
