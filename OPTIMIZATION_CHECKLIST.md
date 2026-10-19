# Checklist Ottimizzazioni & Prossimi Passi v1.0.0

> [!NOTE]
> **Stato (v0.9.1):** Checklist di consolidamento iniziale (v0.2.1 -> v0.3.0). I successivi avanzamenti architetturali e di ottimizzazione (motori FSRS/SM-2, AMOLED, PRAGMA SQLite, modularizzazione settings, note/siblings, type-in, RTL, rolling backup) sono stati completati nelle versioni v0.7.0 -> v0.9.1 e sono tracciati in [ROADMAP.md](file:///c:/Users/thoma/Documents/Projects/repetita/ROADMAP.md).

Checklist operativa generata dall'audit del codice (Caveman, Ponytail, Impeccable) per preparare Repetita al rilascio v1.0.0.

---

## Fase 1: Pulizia Dipendenze & File Morti (Ponytail)
- [x] **Rimozione dipendenze non utilizzate in `pubspec.yaml`**:
  - [x] `lottie: ^3.6.1` (nessun utilizzo nel codice)
  - [x] `google_fonts: ^6.2.1` (font Ubuntu e Lora già inclusi offline in `assets/fonts/`)
  - [x] `flutter_svg: ^2.0.17` (nessun widget SVG utilizzato)
  - [x] `freezed_annotation: ^3.1.0` & `freezed: ^4.0.2` (nessun modello generato con `@freezed`)
  - [x] `json_annotation: ^4.12.0` & `json_serializable: ^6.14.1` (serializzazione DTO implementata manualmente)
- [x] **Esecuzione pulizia workspace**:
  - [x] Eseguire `flutter pub get` (12 pacchetti rimossi, analisi 10x più rapida)
  - [x] Verificare che la compilazione e i test non subiscano regressioni (98/98 test passati)
- [x] **Rimozione file e cartelle fantasma**:
  - [x] Eliminare i 19 file `.gitkeep` ridondanti (`lib/**/*.gitkeep`)
  - [x] Rimuovere directory vuote residue (`core/constants`, `core/utils`, `decks/domain`, `study_session/domain`)

---

## Fase 2: Correzioni UX & Sessione di Studio (Impeccable)
- [x] **Inversione ordine pulsanti in `RatingBar`**:
  - [x] Modificare l'ordine allo standard SRS: `Again` (rosso/fallimento) -> `Hard` -> `Good` -> `Easy`
  - [x] Mantenuta compatibilità test su chiavi dei pulsanti
- [x] **Consolidamento Feedback Aptico**:
  - [x] Rimosse chiamate dirette sincrone a `HapticFeedback` in `RatingBar._handleTap`
  - [x] Rimosse chiamate dirette in `FlipCardView.didUpdateWidget`
  - [x] Delegati gli eventi a `hapticServiceProvider.triggerSelection()` rispettando impostazione `hapticFeedbackControllerProvider` (nessuna vibrazione se impostato su Off)
- [x] **Preservazione stato navigazione principale**:
  - [x] Mantenuto caricamento on-demand pulito con `switch (_currentIndex)` per garantire dati freschi su StatsScreen senza caricamenti inutili all'avvio

---

## Fase 3: Refactoring Architettura & Robustezza (Ponytail / Gemini Rules)
- [x] **Decomposizione di `SettingsScreen` (ridotto da 1761 a ~600 righe)**:
  - [x] Estratto `LanguageSelectorDialog` in `lib/src/features/settings/presentation/dialogs/`
  - [x] Estratto `ThemeSelectorDialog` in `lib/src/features/settings/presentation/dialogs/`
  - [x] Estratto `ReminderDialog` in `lib/src/features/settings/presentation/dialogs/`
  - [x] Estratto `UpdateCheckDialog` in `lib/src/features/settings/presentation/dialogs/`
  - [x] Estratto `FsrsSettingsDialog` in `lib/src/features/settings/presentation/dialogs/`
  - [x] Estratto `LicenseDialog` in `lib/src/features/settings/presentation/dialogs/`
- [x] **Allineamento Offline-First per `UpdateService`**:
  - [x] Verificato uso di solo `dart:io` `HttpClient` senza pacchetti esterni di rete, con gestione trasparente dello stato offline (`SocketException`)
- [x] **Schedulazione Notifiche in `NotificationService`**:
  - [x] Verificata gestione locale offline dei promemoria senza dipendenze remote o crash

---

## Fase 4: Polish Grafico, Empty States & i18n Completa (Impeccable)
- [x] **Completamento Localizzazione (`l10n` IT/EN)**:
  - [x] `StatsScreen`: metriche e grafici localizzati in `app_en.arb` e `app_it.arb` con fallback sicuri per i test
  - [x] `CardEditorScreen`: localizzati campi prompt/answer, validatori e bottoni
  - [x] `BackupScreen`: localizzate card informative, sezioni JSON/CSV e dialog con supporto clipboard
  - [x] `DeckDetailScreen`: localizzati conteggi, badge di stato e bottoni
- [x] **Ridisegno Empty States**:
  - [x] `DeckListScreen`: aggiunto empty state Material 3 illustrato con icona, prompt guidato e pulsante rapido "New Deck"
  - [x] `DeckDetailScreen`: aggiunto empty state illustrato per l'aggiunta rapida della prima card
  - [x] `StatsScreen`: layout metriche a zero pulito e coerente
- [x] **Componenti Errore Amichevoli**:
  - [x] Sostituito `$error` grezzo con componenti M3 con icona di errore e testo informativo
  - [x] Aggiunto pulsante "Riprova" (`Retry`) con invalidazione del controller su tutti i widget asincroni

---

## Fase 5: Verifica, Generazione Codice & Test
- [x] Eseguire generazione del codice:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- [x] Eseguire formattazione del codice:
  ```bash
  dart format --output=none --set-exit-if-changed .
  ```
- [x] Eseguire analisi statica rigorosa (zero warning, zero info):
  ```bash
  flutter analyze --fatal-infos --fatal-warnings
  ```
- [x] Eseguire suite completa dei test (108/108 test passati):
  ```bash
  flutter test
  ```

---

## Fase 7: Rilascio v0.3.0 (Cloze Deletion & Sistema Tag)
- [x] **Cloze Deletion (Testo a Scomparsa)**:
  - [x] Parser puro Dart deterministico `ClozeParser` con supporto a `{{c1::answer}}` e `{{c1::answer::hint}}`
  - [x] Generazione carte separate per cloze multipli in `CardEditorScreen`
  - [x] Rendering prompt mascherato e answer evidenziata in `FlipCardView`
  - [x] Azione rapida `Cloze [...]` nella toolbar dell'editor
- [x] **Sistema Tag / Etichette (Drift)**:
  - [x] Migrazione schema SQLite a v3: tabelle `tags` e `card_tags`, campo `cloze_index` in `cards`
  - [x] `TagsDao`, controller Riverpod e gestione tag chips in `CardEditorScreen`
  - [x] Filtro orizzontale `FilterChip` ("Tutte" + tag presenti) e badge colorati in `DeckDetailScreen`
- [x] **Verifica completa & test**:
  - [x] 100% test di unità per `ClozeParser` e `TagsDao`
  - [x] Test widget completi per flusso cloze e integrazione tag/filtri
  - [x] `flutter analyze`: 0 errori, 0 warning, 0 info
  - [x] `flutter test`: 138/138 test passati con successo


