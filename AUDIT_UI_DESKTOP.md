# Audit UI desktop — Repetita

> [!NOTE]
> **Stato (v0.9.1):** Documento di audit storico relativo a v0.7.5. I principali rilievi prioritari P1 (D01: runner Linux assente; D02: entitlement macOS mancanti in sandbox; D04: overflow schermata di completamento con text scaling a 200%) sono stati risolti nelle versioni v0.8.0 -> v0.9.1. Consultare [ROADMAP.md](file:///c:/Users/thoma/Documents/Projects/repetita/ROADMAP.md) per lo stato corrente delle piattaforme desktop.

**Data:** 14 ottobre 2026 · **Revisione esaminata:** `870872a` · **Versione:** `0.7.5+0`.

Documento unico ricavato da `AUDIT_UI_DESKTOP_2026-10-14.md` e dai risultati delle prove `desktop_confirmation_test.dart` e `desktop_audit_probe_test.dart`. I due file Dart erano strumenti diagnostici temporanei, non audit separati; sono stati rimossi dopo le verifiche. Questo consolidamento modifica soltanto la documentazione.

## Esito e priorità

La UI Material 3 è coerente e dispone già di navigazione adattiva e scorciatoie. Il supporto uniforme **Windows, macOS e Linux rimane incompleto**: i problemi principali riguardano integrazione con il sistema, accessibilità e conservazione del lavoro nell’editor. Non emerge la necessità di una riscrittura grafica.

**14 rilievi: 6 P1 e 8 P2.** Nessun P0 rilevato nel perimetro verificato; ciò non certifica l’assenza di altri difetti.

- **P1 — prioritari:** operazioni bloccate, perdita di lavoro, feedback ingannevole o accessibilità compromessa. Da affrontare prima di dichiarare completo il perimetro desktop richiesto.
- **P2 — circoscritti:** comportamento incoerente o percorso alternativo disponibile. Da correggere nella passata successiva.
- **Da validare:** rischi e limiti di verifica, separati dai difetti riprodotti.
- **Facoltativi:** miglioramenti senza un difetto funzionale dimostrato.

## 1. Informazioni essenziali: problemi prioritari

### D01 · P1 · Linux: runner assente

**Prova statica:** mancano `linux/` e il relativo target nella configurazione e nel workflow release. I rami `TargetPlatform.linux` nella UI non producono un eseguibile.

**Impatto:** impossibile distribuire o collaudare l’app Linux nello stato attuale. È un gap rispetto al perimetro richiesto, non una regressione: le indicazioni di progetto dichiarano Windows e macOS come target desktop.

**Intervento minimo:** aggiungere il runner e verificare i plugin esistenti su Linux; poi provare mazzi, editor, studio e operazioni file. Riferimenti: [.metadata](.metadata), [release.yml](.github/workflows/release.yml).

### D02 · P1 · macOS: entitlement file e rete mancanti

**Prova statica:** sandbox attiva, senza `com.apple.security.files.user-selected.read-write` e `com.apple.security.network.client`. Il plugin risolto `file_picker_darwin 2.3.0` controlla le autorizzazioni prima di aprire i pannelli. `network.server` nel debug non abilita connessioni in uscita.

**Impatto:** importazione Anki e salvataggio su file bloccati; controllo aggiornamenti senza accesso alla rete. Per alcuni formati resta disponibile copia/incolla.

**Intervento minimo:** completare gli entitlement usati dall’app in [DebugProfile.entitlements](macos/Runner/DebugProfile.entitlements) e [Release.entitlements](macos/Runner/Release.entitlements); verificare i flussi in release su Mac. Fonti: [setup file picker](https://pub.dev/packages/file_picker_darwin#macos-setup), [sandbox Flutter macOS](https://docs.flutter.dev/platform-integration/macos/building#entitlements-and-the-app-sandbox).

### D03 · P1 · Notifiche desktop: successo dichiarato senza configurazione valida

**Confermato nel ramo Dart Windows:** mancano `WindowsInitializationSettings`; il plugin genera `Windows settings must be set when targeting Windows platform.`, ma il servizio intercetta `Error` e restituisce `true`.

**Prova statica macOS:** richiesta automatica dei permessi disabilitata; `requestPermissions()` gestisce solo Android/iOS; assenti i dettagli `macOS` in `NotificationDetails`.

**Impatto:** switch e messaggi possono indicare successo senza una configurazione funzionante. La consegna delle notifiche native non è stata verificata.

**Intervento minimo:** completare i rami delle piattaforme e propagare i fallimenti reali alla UI. Riferimenti: [notification_service.dart](lib/src/features/settings/data/notification_service.dart), [reminder_dialog.dart](lib/src/features/settings/presentation/dialogs/reminder_dialog.dart), [documentazione del plugin](https://pub.dev/packages/flutter_local_notifications).

### D04 · P1 · Schermata finale tagliata con testo al 200%

**Riprodotto:** superficie logica **640×500**, locale italiano, `TextScaler.linear(2)`, mazzo vuoto. Errore: **`A RenderFlex overflowed by 64 pixels on the bottom.`** La `Column` finale non scorre; il pulsante per tornare al mazzo viene spinto sotto il bordo.

**Impatto:** perdita di contenuto e accesso all’azione principale per chi ingrandisce il testo.

**Intervento minimo:** rendere il completamento scorrevole o adattarlo all’altezza disponibile. Riferimento: [study_screen.dart](lib/src/features/study_session/presentation/study_screen.dart), ramo `isCompleted`.

### D05 · P1 · Contrasto insufficiente per testo piccolo nel tema chiaro

**Misurato:** `outline` (`#7c7767`) su `surfaceContainerLow` (`#f4f3fa`) produce **4,0599:1**, sotto **4,5:1** per testo normale. Coinvolti sottotitoli delle metriche e suggerimento di ribaltamento. La stessa coppia nel tema scuro raggiunge **5,3963:1**.

**Impatto:** leggibilità ridotta per utenti ipovedenti; criterio tecnico pertinente: WCAG 1.4.3. Il dato non costituisce una valutazione normativa complessiva.

**Intervento minimo:** usare un ruolo testuale adeguato, per esempio `onSurfaceVariant`, e ricontrollare le coppie. Riferimenti: [metric_summary_card.dart](lib/src/features/stats/presentation/widgets/metric_summary_card.dart), [flip_card_view.dart](lib/src/features/study_session/presentation/widgets/flip_card_view.dart), [material_theme.dart](lib/src/core/theme/material_theme.dart).

### D06 · P1 · Editor: Indietro elimina le modifiche senza conferma

**Riprodotto:** compilazione di fronte e retro, clic su Indietro, uscita senza dialogo; database in memoria senza la nuova carta. Non esiste un controllo delle modifiche non salvate. Non è stata provata la chiusura della finestra nativa.

**Impatto:** perdita involontaria del testo inserito.

**Intervento minimo:** proteggere l’uscita quando testo o tag differiscono dai valori iniziali. Basta una conferma locale; non è necessario introdurre autosalvataggio. Riferimento: [card_editor_screen.dart](lib/src/features/cards/presentation/card_editor_screen.dart).

## 2. Da correggere successivamente

| ID | Problema ed evidenza | Impatto e intervento minimo | Riferimento |
| --- | --- | --- | --- |
| **D07 · P2** | Salvataggio editor con `try/finally` ma senza `catch`; controller e callback propagano gli errori. Verifica statica. | In caso di errore database il pulsante si riabilita senza spiegazione. Gestire il fallimento in `_save()`, conservando i campi e consentendo un nuovo tentativo. | [card_editor_screen.dart](lib/src/features/cards/presentation/card_editor_screen.dart), `_save()` |
| **D08 · P2** | Il livello `reduced` non disabilita il flip 3D di 250 ms. Riprodotto: a 60 ms la matrice conserva una rotazione, coseno **0,968089**. Anche alcune animazioni finali non leggono il livello. | La preferenza dell’utente è applicata solo in parte. Usare una transizione senza rotazione nel livello ridotto; verificare separatamente le preferenze native. | [flip_card_view.dart](lib/src/features/study_session/presentation/widgets/flip_card_view.dart), [study_screen.dart](lib/src/features/study_session/presentation/study_screen.dart) |
| **D09 · P2** | `WM_GETMINMAXINFO` assegna 640×500 senza scaling DPI, mentre la creazione della finestra applica lo scaling. Verifica statica. | A DPI elevati il minimo non protegge lo spazio logico necessario alla UI. Scalare il limite e distinguere finestra esterna da area client; confermare con monitor reali. | [win32_window.cpp](windows/runner/win32_window.cpp), `WM_GETMINMAXINFO`; [Microsoft MINMAXINFO](https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-minmaxinfo) |
| **D10 · P2** | Dopo l’ultima carta il ramo finale esclude `CallbackShortcuts`. Riprodotto: `Ctrl+Z` non annulla, il pulsante Undo sì. `Cmd+Z` è nello stesso ramo escluso, ma non è stato provato su Mac. | Undo incoerente fra tastiera e mouse. Mettere il binding nell’antenato comune agli stati e riusare la gestione errori della toolbar. | [study_screen.dart](lib/src/features/study_session/presentation/study_screen.dart), completamento e binding undo |
| **D11 · P2** | “Preferences…” macOS / `Cmd+,` senza azione nel menu e senza collegamento alternativo nel runner. Verifica statica. | Percorso standard alle impostazioni inutilizzabile; rimane la rail. Collegare il comando alle impostazioni esistenti e verificarne l’abilitazione su Mac. | [MainMenu.xib](macos/Runner/Base.lproj/MainMenu.xib), voce `Preferences…` |
| **D12 · P2** | “Visualizza su GitHub” chiude il dialogo e mostra solo `Release URL: ...` in uno SnackBar non selezionabile. Verifica statica. | L’azione non porta alla release promessa. Aprire l’URL oppure offrire esplicitamente la copia. | [update_check_dialog.dart](lib/src/features/settings/presentation/dialogs/update_check_dialog.dart), ramo aggiornamento disponibile |
| **D13 · P2** | `clear_search_button` e `confirm_add_tag_button` non hanno tooltip o etichetta semantica esplicita. Verifica statica. | Azioni poco identificabili con screen reader e al passaggio del mouse. Aggiungere nomi localizzati e verificarne la lettura senza duplicazioni. | [deck_detail_screen.dart](lib/src/features/cards/presentation/deck_detail_screen.dart), [card_editor_screen.dart](lib/src/features/cards/presentation/card_editor_screen.dart) |
| **D14 · P2** | Heatmap con `M/W/F` e tooltip inglesi, conteggio `$total total`, badge desktop italiano anche in inglese; il ramo Linux ricade sul badge macOS. Verifica statica. | Lingue mescolate e possibile piattaforma errata. Completare gli ARB esistenti e usare il target corretto. | [review_heatmap_widget.dart](lib/src/features/stats/presentation/widgets/review_heatmap_widget.dart), [state_distribution_bar.dart](lib/src/features/stats/presentation/widgets/state_distribution_bar.dart), [reminder_dialog.dart](lib/src/features/settings/presentation/dialogs/reminder_dialog.dart) |

## 3. Prove e limiti da mantenere

Ambiente dell’audit: **Windows, Flutter 3.47.7, Dart 3.13.5**. Le prove UI usano rendering del framework, SQLite in memoria e font locali. Non sono sessioni interattive dei runner nativi. Questa revisione documentale non ha rieseguito i test: riporta gli esiti registrati durante l’audit del 14 ottobre.

| Verifica | Esito registrato | Cosa dimostra |
| --- | --- | --- |
| `flutter analyze --no-pub --fatal-infos --fatal-warnings` | Nessun problema, exit code 0 | Analisi statica pulita nel perimetro del comando. |
| `flutter test --no-pub test/widget test/unit/theme --reporter expanded` | **55 test superati**, exit code 0 | Suite esistente UI/tema, non tutti i test del progetto né collaudo nativo delle tre piattaforme. |
| `desktop_confirmation_test.dart`, temporaneo | **5 verifiche completate**, exit code 0 | Riproduzione di D04, D06, D08, D10 e del falso successo Windows di D03; calcolo di D05. Le asserzioni confermano i difetti, non li risolvono. |
| `desktop_audit_probe_test.dart`, temporaneo | Matrice esplorativa di 17 scenari; esecuzione terminata con errore di ripristino di una variabile del test | Indagine preliminare, non suite superata. I difetti mantenuti come riprodotti sono quelli confermati successivamente. |

La matrice esplorativa copriva larghezze logiche 639, 640, 839, 840, 1280 e 1920, con testo al 100%/200% nei casi pertinenti. Non dimostra che tutti i dialoghi, i contenuti fuori schermo o i passaggi fra monitor funzionino. L’overflow laterale di 4,8 px osservato nella prima prova non è stato riprodotto nella conferma e **non viene mantenuto come difetto accertato**.

**Copertura nativa:** Windows verificato tramite sorgenti e widget test; macOS tramite sorgenti e configurazione; Linux senza runner. Non sono stati provati Narrator/VoiceOver/Orca, consegna notifiche, pannelli file nativi, focus completo nei dialoghi, scrolling mouse/trackpad, alto contrasto o cambio monitor/DPI. Nessuna misura di frame, avvio o memoria: non attribuire regressioni prestazionali senza profilazione.

Gli avvisi Drift e i log di plugin non inizializzati nei test esistenti non dimostrano, da soli, corruzione dei dati o gli stessi problemi in produzione. I sorgenti diagnostici rimossi non sono test di regressione disponibili nella repo; gli esiti essenziali sono riportati qui.

## 4. Da validare e miglioramenti facoltativi

| Classe | Elemento | Decisione |
| --- | --- | --- |
| **Da profilare** | Import Anki: decompressione ZIP e letture SQLite nello stesso isolate del chiamante. | Verificare con pacchetti grandi prima di prescrivere isolate o riscritture; nessun blocco UI misurato. |
| **Facoltativo** | Home e impostazioni a tutta larghezza; studio, editor e statistiche hanno già limiti di larghezza. | Valutare densità e leggibilità su schermi ampi; nessuna necessità dimostrata di un nuovo layout master/detail. |
| **Facoltativo** | Testo delle carte non selezionabile direttamente. | Aggiungere selezione solo se utile al flusso di copia durante lo studio; oggi si può usare l’editor. |

**Da preservare:** rail da 640 unità logiche; statistiche a due colonne da 840; larghezze contenute per studio/editor; temi e font offline; liste lazy e `RepaintBoundary`; offload JSON/CSV oltre soglia; conferme per operazioni distruttive; retry degli errori; scorciatoie studio e salvataggio. Material 3 su macOS non è, da solo, un difetto.

## 5. Cosa è stato sintetizzato o escluso

| Mantenuto perché necessario | Ridotto o escluso perché non operativo |
| --- | --- |
| Tutti i 14 rilievi, priorità, piattaforme, impatto, riferimento e intervento minimo. | Spiegazioni ripetute dello stesso problema e ripetizione delle raccomandazioni per ogni skill. |
| Dati riproducibili: viewport, locale, scaling, errori, contrasto, differenze fra input. | Stack trace completi, coordinate di controlli non difettosi, intestazioni e log del runner. |
| Distinzione fra prove runtime, lettura del codice e verifiche mancanti. | Punteggio orientativo 10/20: giudizio sintetico non necessario per scegliere gli interventi. |
| Esiti e limiti dei test, incluso l’errore del primo strumento diagnostico. | Dichiarazioni generiche di “test superati” applicate alla matrice esplorativa o alle piattaforme non eseguite. |
| Pratiche corrette da conservare e miglioramenti realmente facoltativi. | Dettagli della sessione, percorsi personali, ricerca plugin e screenshot senza valore aggiuntivo per la decisione. |

**Ordine di lavoro suggerito:** D02/D03/D06 per affidabilità e dati; D04/D05 per accessibilità; completare D01 prima di dichiarare supporto Linux; poi D07–D14. Dopo eventuali correzioni, riprovare i casi interessati e i flussi nativi. Nessuna correzione applicata da questo documento.
