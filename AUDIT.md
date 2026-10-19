# Audit codebase — Repetita

> [!NOTE]
> **Stato (v0.9.1):** Documento di audit storico relativo a v0.3.0 (2026-10-12). I punti ancora aperti in questo testo (query LIMIT, modularizzazione di `settings_screen.dart`, pre-rendering e ottimizzazioni flip card) sono stati risolti nelle versioni v0.7.0 -> v0.9.1. Consultare [ROADMAP.md](file:///c:/Users/thoma/Documents/Projects/repetita/ROADMAP.md) per lo stato attuale.

Data: 2026-10-12 (aggiornato con seconda passata: audit codice morto/over-engineering + audit reattività UI). Scope: `lib/`, `pubspec.yaml`, `integration_test/`, repo root. Metodo: `flutter analyze` (pulito, 0 issue) + revisione manuale incrociata agenti (backend/architettura + UI/UX/performance). Ogni "codice morto" verificato con grep sui call site.

Verdetto generale: codice disciplinato (l10n quasi ovunque, `select()` nei watch, `ListView.builder`, transazioni su `recordReview`, niente superficie di path-injection). I problemi veri: versione hardcoded che rompe l'update-check, assenza totale di indici DB, query senza LIMIT, impostazioni utente non persistite, ~400 righe duplicate in settings, gestione SafeArea quasi assente.

---

## 1. Critico / Alta priorità

### 1.1 ~~Versione hardcoded e disallineata — `settings_screen.dart:27`~~ ✅ RISOLTO (2026-10-12)
Rimossa la costante `SettingsScreen.appVersion = 'v0.3.0'`. Ora la versione arriva da `package_info_plus` tramite `appVersionProvider` (`controllers/app_version_controller.dart`), unica fonte di verità = `pubspec.yaml`. Aggiornati tutti i call site: settings header, badge, tile update check, `UpdateCheckDialog.show` (legge `appVersionProvider.future`) e `license_dialog.dart`. Test aggiornati con `PackageInfo.setMockInitialValues`.

### 1.2 ~~Nessun indice secondario nel DB — `tables.dart`~~ ✅ RISOLTO (2026-10-12)
`@TableIndex` su `Cards(deckId)`, `Cards(due)`, `ReviewLogs(cardId)`, `ReviewLogs(reviewedAt)`, `CardTags(tagId)` + `schemaVersion` 4→5 con migration `CREATE INDEX IF NOT EXISTS` (installazioni esistenti) e indici generati da drift (installazioni nuove).

### 1.3 Query senza LIMIT — PARZIALE ✅ (2026-10-12)
~~`fetchDueCards`/`fetchCustomStudyCards`~~ ora con `limit = 200` default su tutte le 4 query. Resta aperto: `watchCardsByDeck` stream intero mazzo (filtro tag ora memoized in provider, ma la paginazione SQL vera resta da fare).

### 1.4 ~~Statistiche calcolate in Dart invece che in SQL — `stats_dao.dart`~~ ✅ RISOLTO (2026-10-12)
- `:51` `getRetentionRate`: sostituito conteggio in-memory con query aggregata SQL `count()` filtrando `rating >= 2`.
- `:89` `getDueForecast`: filtrato in SQL `due < forecastEnd` invece di caricare l'intera tabella carte in memoria.

### 1.5 ~~Impostazioni non persistite~~ ✅ RISOLTO (2026-10-12)
`theme_mode_controller.dart`, `locale_controller.dart`, `haptic_controller.dart`, `animation_level_controller.dart`: integrato caricamento/salvataggio asincrono con fallback tramite tabella `appSettings` Drift.

### 1.6 ~~Race FSRS all'avvio a freddo~~ ✅ RISOLTO (2026-10-12)
Aggiunto metodo `ensureLoaded()` in `fsrs_parameters_controller.dart` e chiamata awaited in `build()` di `study_session_controller.dart`.

### 1.7 Rebuild eccessivi lato UI — RISOLTO ✅ (2026-10-19)
- ~~`deck_detail_screen.dart:41–48` listener di ricerca~~ ✅: rimosso `_searchController.addListener(_onSearchChanged)` che forzava `setState()` a ogni battuta; l'aggiornamento è ora delegato al watch puntuale di `deckCardSearchQueryProvider` in `_DeckCardsSection`.
- ~~`deck_detail_screen.dart:71–105` aggregazione tag in build~~ ✅: rimosso folding/sorting inline su ogni frame di build in favore del provider memoizzato `distinctDeckTagsProvider(deckId)` con test di unità dedicati.
- ~~`deck_detail_screen.dart` allocazione `cardIndexMap`~~ ✅: resa pigra (`cardIndexMap ??= ...`) dentro `findChildIndexCallback`, eliminando le allocazioni di mappe hash a ogni frame di scroll e rebuild.
- ~~`deck_detail_screen.dart:560–568`: filtro in memoria in `build`~~ ✅ (2026-10-12) nuovo `filteredDeckCardsProvider(deckId)` memoized: ricomputa solo su cambio carte/tag/filtro.
- `study_screen.dart`: ~~Consumer radice~~ ✅ AppBar con `select` (Gemini); il `body` resta un unico `Consumer` sull'intero stato sessione.

### 1.8 Animazione flip — PARZIALE ✅ (2026-10-12)
~~`ClozeParser` chiamato 4–6 volte per build~~ ✅ parsing cachato in `State` (`_promptSegments`, `_answerText`, ecc.) con recompute in `didUpdateWidget`; `RepaintBoundary` su entrambi i volti (Gemini). Restante: `TweenAnimationBuilder` implicito (nessun `AnimationController` esplicito) — flicker mitigato ma non eliminato alla radice.

### 1.8bis ~~Race condition sul rating — `study_session_controller.dart`~~ ✅ RISOLTO (2026-10-12)
Guard flag `_isSubmitting` su `submitRating`: doppio tap ignorato durante `await recordReview`, reset in `finally`.

### 1.9 ~~Safe-area quasi assente~~ ✅ RISOLTO (2026-10-12)
Aggiunto `SafeArea` e gestione corretta degli insets (`viewInsetsOf`) a `deck_list_screen`, `deck_detail_screen`, `backup_screen`, `stats_screen`, `settings_screen` e `card_editor_screen`.

### 1.10 ~~Salvataggio multi-cloze seriale — `card_editor_screen.dart:257–278`~~ ✅ RISOLTO (2026-10-12)
Implementato metodo `createClozeCards()` atomico con transazione singola in `card_list_controller.dart` e aggiornato `card_editor_screen.dart`.

---

## 2. Media priorità

| # | File:linea | Problema | Fix |
|---|---|---|---|
| 2.1 | ~~`backup_service.dart:138`~~ ✅ | Merge mode: idempotenza su payload id/contenuto, ref mazzi ignoti rifiutati | Risolto: match righe esistenti, skip duplicati su re-import, reject orphan cards, test doppia importazione |
| 2.2 | ~~`backup_service.dart` JSON/CSV su main isolate~~ ✅ | Risolto: offload su isolate via `compute()` solo sopra soglia (256KB testo / 2000 righe); sotto soglia sync (costo spawn > guadagno, e mantiene i widget test in fake-time sincroni). Resta aperto: niente cap dimensione su payload incollato | Bound input |
| 2.3 | ~~`backup_service.dart:122–215,298–302`~~ ✅ | Import riga per riga in loop | Risolto: `db.batch((b) => b.insertAll(...))` per json (tutte le tabelle) e csv |
| 2.4 | ~~`notification_service.dart:44,77,116,152,160`~~ ✅ | Catch silenziosi con solo `debugPrint` | Risolto: return tipizzati `bool` + rethrow in `reminder_controller.dart` su fallimento + check persistenza |
| 2.5 | ~~`deck_list_screen.dart:136–149`, `deck_detail_screen.dart:730–750`~~ ✅ | Mutazioni async fire-and-forget senza feedback | Risolto: await + SnackBar errore in deck list (edit, delete, create), deck detail e study screen |
| 2.6 | ~~`backup_screen.dart:290–297,304`~~ ✅ | Restore distruttivo senza dialog di conferma; `replaceExisting` default `true` | Risolto: default `false` + dialog di conferma esplicita |
| 2.7 | ~~slider duplicati~~ ✅ | Blocchi slider animazione/aptica unificati in `_LevelSlider` (2026-10-12). Resta: settings_screen.dart ancora ~900 righe (monolite) | |
| 2.8 | ~~`deck_detail_screen.dart:700–708`~~ ✅ | `findChildIndexCallback` fa `indexWhere` O(n) per key → O(n²) scroll | Risolto: mappa `cardIndexMap` [id→indice] precomputata O(1) |
| 2.9 | ~~`fsrs_parameters_controller.dart:45,57,66–67`~~ ✅ | `db.setSetting(...)` unawaited | Risolto: `await` con try/catch e log |
| 2.10 | ~~`deck_detail_screen.dart:84–85,259,312,741`~~ ✅ | `DateTime.now().toUtc()` nei builder: ricalcolo per tile | Risolto: calcolato una sola volta nel builder radice e iniettato ai tile figli |
| 2.11 | ~~Animazioni incoerenti~~ ✅ | Shimmer che ignora `animationLevelControllerProvider` | Risolto: gating uniforme con `animationLevelControllerProvider` |
| 2.12 | ~~Error view copiata 3×~~ ✅ | `core/widgets/error_view.dart` condiviso; usato in deck_list, deck_detail, stats, study (2026-10-12) | |
| 2.13 | ~~Touch target < 48dp~~ ✅ | `rating_bar.dart:84` (40dp in compact), bottoni settings ~34px | Risolto: minimo 48dp garantito |
| 2.14 | ~~Contrasto~~ ✅ | `colorScheme.outline` usato come colore testo | Risolto: sostituito con `onSurfaceVariant` (settings, study, review heatmap) |
| 2.15 | ~~`study_session_controller.dart:204-206,250-252,285-287,320-322`~~ ✅ | `catch` → `state = AsyncError`: schermata studio diventa errore irreversibile | Risolto: conservato `state = AsyncData(current)` + SnackBar nella UI |
| 2.16 | ~~`flip_card_view.dart` & `study_screen.dart`~~ ✅ | Flip 3D + shadow e shimmer senza `RepaintBoundary` | Risolto: `RepaintBoundary` su volti card e container animazione |
| 2.17 | ~~`forecast_list_tile.dart:23-24`~~ ✅ | `DateFormat('E, MMM d', locale)` istanziato a ogni frame | Risolto: cache `static final` formattatori per locale |
| 2.18 | ~~`stats_controller.dart:11-32`~~ ✅ | Statistiche non invalidate dopo sessione studio | Risolto: `ref.invalidate(statsControllerProvider)` in `submitRating` e `undoReview` |
| 2.19 | `settings_screen.dart` (~960 righe) | Monolite UI: logica di 6 controller in un solo build | Spezzare in widget per sezione |

---

## 3. Codice morto confermato (verificato su tutti i call site)

| Simbolo | Posizione | Nota |
|---|---|---|
| ~~`CardsDao.getCardsByDeckPaged`~~ ✅ | `cards_dao.dart:59` | Risolto: rimosso metodo morto non utilizzato |
| `CardsDao.getCardsByDeck` | `cards_dao.dart:46` | Mantenuto: impiegato nelle suite di test e helper di verifica |
| ~~`AppDatabase.watchSetting`~~ ✅ | `app_database.dart:65` | Risolto: rimosso metodo morto non utilizzato |
| ~~`TagsDao.deleteTag` + `TagsController.deleteTag`~~ ✅ | `tags_dao.dart:38`, `tags_controller.dart:24` | Risolto: collegato alla UI dei filtri tag con dialog di conferma e SnackBar |
| ~~`StudySessionController.getIntervalPreviews()`~~ ✅ | `study_session_controller.dart:324` | Risolto: rimosso metodo morto |
| ~~`CardsDao.buryCard` (pubblico)~~ ✅ | `cards_dao.dart:115` | Risolto: reso privato `_buryCard`, esposta API safe `buryCardUntilTomorrow` |
| ~~`coverage/lcov.info`~~ ✅ | root | Risolto: cancellato dal tracking git e presente in `.gitignore` |

Concurrency sicura: nessun file `.g.dart` duplicato; generati drift coerenti.

### 3bis. Over-engineering / da eliminare (NUOVO)

| Tag | Simbolo | Posizione | Azione |
|---|---|---|---|
| delete | ~~`LanguageSelectorDialog` (120 righe)~~ ✅ | `settings/presentation/dialogs/language_selector_dialog.dart` | Risolto (2026-10-19): rimosso file orfano dopo sostituzione con `LanguageSettingsScreen` |
| delete | `LicenseDialog` (90 righe) | `settings/presentation/dialogs/license_dialog.dart:7-90` | Wrapper custom attorno a `showLicensePage`: allineato con `appVersionProvider` |
| delete | ~~`integration_test/app_test.dart`~~ ✅ | intero file | Risolto: rimosso stub TODO, E2E testato in `test/widget/app_e2e_flow_test.dart` |
| yagni | 5 provider DAO keepAlive | `core/database/database_provider.dart:24-41` | Pure deleghe a `databaseProvider`. Usare `ref.watch(databaseProvider).cardsDao` diretto: −5 provider codegen |
| yagni | provider `updateService` | `settings/.../controllers/update_controller.dart:8-11` | Classe senza stato né dipendenze: istanziare `UpdateService()` diretto |
| shrink | 4 controller enum settings quasi identici | `theme_mode_controller`, `locale_controller`, `haptic_controller`, `animation_level_controller` | Un `EnumSettingController<T>` generico elimina 4 file + 4 `.g.dart` |
| stdlib | ~~Date formattate a mano~~ ✅ | `update_check_dialog.dart:110`, `review_heatmap_widget.dart:172` | Risolto: usato `DateFormat('yyyy-MM-dd')` con `intl` |
| yagni | ~~Asset SVG dichiarati~~ ✅ | `pubspec.yaml:80-81` | Risolto: rimossi `repetita-icon.svg` e `repetita-circle-icon.svg` da asset dichiarati |
| native | `clockProvider` manuale | `core/utils/clock_provider.dart:5` | Unico provider non-codegen del progetto: convertire a `@riverpod` o parametro |
| shrink | Equality manuali | `card_entity.dart:72-90`, `tag_entity.dart:14-30` | `==`/`hashCode` su 14/4 campi, usate solo nei test: valutare row Drift (equality già generata) o record |
| stdlib | `pub_semver` | `settings/domain/update_info.dart:24-25` | Unico uso del pacchetto: se versioni sempre semver semplici, confronto a componenti toglie la dipendenza (borderline) |

Stima netto: **−400/−500 righe, −4 file codegen, −2 asset, −1 dipendenza (opzionale)**.

---

## 4. Bassa priorità

- **i18n leak** (~10 stringhe inglesi hardcoded): `deck_detail_screen.dart:394,615,647,682,47`; `backup_screen.dart:282,290–297,395`; `fsrs_settings_dialog.dart:165`; `update_check_dialog.dart:101,117`; plurali hardcoded in `review_heatmap_widget.dart:107`. Fix: chiavi arb.
- **God-object**: settings (993 LOC), deck_detail (758 LOC), card_editor (483 LOC). `_insertCloze` (`card_editor_screen.dart:79–87`) è logica di dominio nel widget → spostare in `ClozeParser` con test.
- **Validazione**: front/back senza cap di lunghezza né validazione sintassi cloze; CSV importer senza limiti righe/dimensione.
- ~~**`buryCardUntilTomorrow`** (`cards_dao.dart:67`)~~ ✅: Risolto, normalizzazione sia per orari locali che UTC con calcolo accurato mezzanotte locale successiva in `computeTomorrowMidnight`.
- **`study_session_controller.dart:235`**: aritmetica indici coda fragile dopo requeue (sicura ora, a un refactor dal RangeError); modalità cram può far crescere la coda senza bound.
- **Dimensioni fisse non adattive**: `flip_card_view.dart:34` (maxWidth 600, minHeight 280), celle heatmap 14px, row tag 38px; landscape non gestito (la colonna studio schiaccia la card). Fix: `LayoutBuilder` con layout side-by-side in landscape.
- **`card_editor_screen.dart:376–435`**: `ValueListenableBuilder` annidati ricostruiscono l'intero campo back a ogni keystroke.
- **`_showAddTagDialog`** (`card_editor_screen.dart:90–236`): Consumer + StatefulBuilder + doppio setState annidati — fragile, estrarre in StatefulWidget.
- ~~**Backup UX solo clipboard**~~ ✅: Risolto, integrato `FilePickerService` nativo con supporto a importazione ed esportazione file `.apkg`, `.json` e `.csv`, mantenendo al contempo il supporto clipboard per flessibilità.
- **Feedback incoerente**: delete carta e delete mazzo senza SnackBar di conferma/undo (altrove presenti).
- **`IndexedStack`** (`main_navigation_screen.dart:47`): l'`AnimationController` di Settings registra vsync mentre nascosto — trascurabile ma noto.

---

## 5. Cosa è fatto bene (da preservare)

- `recordReview`/`undoReview` in transazione con coupling del review log; create/update carta+tag transazionali.
- `study_screen.dart` usa `provider.select` per slice dell'AppBar; `RepaintBoundary` sulla heatmap.
- Conferma di cancellazione ben fatta in `deck_list_tile.dart:21–50` (modello da replicare nel restore backup).
- Niente superficie di path injection; update service solo HTTPS con timeout, solo metadata GitHub, niente download.
- `dart analyze` pulito; FK pragma attivi.

## 6. Quick wins ordinati per impatto/sforzo

1. ~~Versione da `package_info_plus`~~ ✅ fatto.
2. Persistenza tema/lingua/aptica/animazioni via `AppSettings` (bug funzionale percepito, piccolo).
3. Default `replaceExisting=false` + conferma restore (rischio dati, piccolo).
4. Indici DB in migration (fondamenta, piccolo).
5. SQL aggregate per retention/forecast (perf crescente, piccolo).
6. Estrazione `_LevelSliderSetting` in settings (−400 righe duplicate).
7. `SafeArea` ovunque + padding FAB (piccolo).
8. Fix race `submitRating` (flag `_isSubmitting` + debounce bottoni) (§1.8bis).
9. Cache segmenti cloze + split flip card (jank percepito in studio).
10. `compute()`/isolate per encode/decode backup (§2.2).
11. Pulizia codice morto §3 + §3bis (`LicenseDialog`, app_test stub, 5 provider DAO, `updateService`, asset SVG) + cancellazione `coverage/` + gitignore.
12. `EnumSettingController<T>` generico al posto di 4 controller identici (−8 file).
13. `RepaintBoundary` su flip card e shimmer (§2.16).
14. LIMIT study queue + paginazione lista (riusare l'API paginata già esistente).

---

## 7. Audit v0.7.5 — Ponytail & Impeccable (Decoupling SRS, Ottimizzazione & CI/CD)

Data: 2026-10-13. Scope: `StudySessionController`, algoritmi SRS, configurazioni build Android/macOS, workflow di rilascio.

### 7.1 Astrazione Motore SRS (Strategy Pattern) ✅
- **Problema:** `StudySessionController` istanziava direttamente `FsrsEngine`, impedendo l'introduzione di motori alternativi (SM-2) senza refactoring invasivo dello stato della sessione.
- **Fix:** Introdotta interfaccia pura `SrsScheduler` (`lib/src/core/algorithms/srs/srs_scheduler.dart`) implementata da `FsrsEngine`. Creata dipendenza reattiva `srsSchedulerProvider` in Riverpod. `StudySessionController` consuma lo scheduler astratto via dependency injection.

### 7.2 Ponytail Code Cut: Deduplicazione Coda di Studio ✅
- **Problema:** `suspendCurrentCard` e `buryCurrentCard` duplicavano circa 25 righe di logica per l'avanzamento della coda di studio, la gestione del flag `_isFlipped` e la notifica di completamento.
- **Fix:** Estratto helper privato unificato `_advanceQueueWithoutCurrentCard()`, riducendo boilerplate e allineando la transizione di stato. Puliti gli import non utilizzati.

### 7.3 Risoluzione Conflitti Build Android & macOS CI/CD ✅
- **Problema:** La pipeline GitHub Actions falliva su Android per conflitto Gradle (`ndk.abiFilters` incompatibile con `splits` di `--split-per-abi`) e su macOS per firma Xcode automatica senza credenziali e percorso relativo in `defaults read`.
- **Fix:** Rimossi filtri NDK conflittuali in `build.gradle.kts`. Impostata firma ad-hoc (`CODE_SIGN_STYLE = Manual`, `CODE_SIGN_IDENTITY = -`) per i target macOS di Release e reso assoluto il percorso `$PWD` nello script di packaging della release.

