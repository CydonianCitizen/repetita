# Repetita 🧠⚡

[![CI](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml/badge.svg)](https://github.com/CydonianCitizen/Repetita/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/version-0.9.6-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An offline-first, local-only spaced repetition flashcard application built with Flutter and Dart, powered by the state-of-the-art **Free Spaced Repetition Scheduler (FSRS)** and **SuperMemo SM-2** algorithms with an extensible multi-engine architecture.

Repetita is crafted for privacy, mathematical precision, and high performance. It operates completely disconnected from remote servers and cloud backends—your study data, retention history, and decks remain 100% on your device.

---

## 🌟 Key Features

* **Offline Text-to-Speech (TTS) & Ergonomic Polish (v0.9.6):**
  * **Device-Native Offline TTS Engine**: Zero-cloud speech synthesis powered directly by operating system speech engines (Android TextToSpeech, Windows SAPI/OneCore, Apple AVSpeechSynthesizer, Linux speech-dispatcher) with F-Droid compatibility.
  * **Intelligent Card Text Sanitization**: Automated pre-speech text cleanup stripping cloze deletion tags, audio markers (`[sound:...]`), markdown images/links, LaTeX math delimiters, and raw HTML before vocalization.
  * **Study Session Vocalization & Hotkey 'T'**: Dedicated TTS speaker action in study session AppBar, auto-TTS on card presentation/flip when cards lack recorded audio, and instantaneous speech replay via keyboard hotkey `T`.
  * **Configurable Speech Settings**: Speech rate slider and language override options integrated cleanly into the Algorithm & Study settings screen.
* **Audio Pipeline, Ephemeral Whiteboard & SRS Hardening (v0.9.5):**
  * **100% Line Coverage on SRS Engines**: Exhaustive test suites reaching 100% test coverage across FSRS parameter encoders, stability curve calculators, Adam optimizer models, and SM-2 scheduling algorithms.
  * **In-App Microphone Audio Recording**: One-tap recording dialog in `CardEditorScreen` with waveform animation, live playback preview, and automated tagging (`[sound:filename.m4a]`) for card front and back.
  * **Card Audio Playback & Replay Shortcuts**: Integrated audio chips (`AudioPlayerChip`) in card reviews, customizable autoplay upon flip, and instantaneous replay via hotkey `R`.
  * **Full Anki Audio Packaging & Interoperability**: Bidirectional `.apkg` audio support packaging sound files and media maps on export, and extracting audio into the local media library on import.
  * **Ephemeral Motor Recall Whiteboard**: In-session drawing canvas overlay for handwriting answers, ideograms, and diagrams before revealing answers, with multi-color palette, undo, and auto-clearing upon card advancement.
* **Advanced Analytics, FSRS Optimizer, Math & Ergonomics (v0.9.4):**
  * **Extended Visual Analytics & True Retention**: Measured true retention card ($\% \text{ remembered}$ on mature cards $\ge 21\text{d}$), review interval histogram with logarithmic grouping, and 4-tier rating distribution chips.
  * **Card Info Dialog & S/D/R Stability Curves**: Dedicated dialog inspecting card stability, difficulty, retrievability, reps, lapses, review history, and an interactive retrievability decay curve plotted over time ($R(t) = (1 + F \cdot t / S)^{-w}$).
  * **On-Device FSRS Optimizer**: Pure Dart optimization engine running asynchronously in a dedicated background `Isolate`. Employs Adam gradient descent with BCE loss directly on local review logs ($\ge 500$ reviews), tuning all 19 FSRS parameters to the user's personal memory characteristics with instant scheduler hot-reloading.
  * **Offline Markdown & LaTeX/KaTeX Math Rendering**: Full support for inline LaTeX math (`$...$` and `\(...\)`), display formulas (`$$...$$` and `\[...\]`), and rich Markdown formatting on front and back prompts with zero network requests and live editor preview.
  * **Customizable Study Gestures**: Full ergonomic mobile gestures during reviews: directional swipes (Left, Right, Up, Down) mapped to rating actions (Again, Hard, Good, Easy) with tactile haptic confirmations and double-tap to flip or undo.
  * **Native Android Home Screen Widget**: At-a-glance due cards count and new card badge directly on your Android launcher with tap-to-study launch intent.
* **Media Pipeline & Image Occlusion (v0.9.3):**
  * **Media Storage & Deduplication**: Dedicated Drift `Media` table with indexed SHA-256 checksums, local file storage in application documents, and automatic deduplication of identical images.
  * **Interactive Media Viewer**: Pinch-to-zoom, double-tap, and pan modal viewer (`ImageViewerDialog`) for detailed examination of anatomical diagrams, maps, and technical schematics.
  * **Direct Image Insertion & Thumbnails**: Insert images in card front and back prompts via native file picker (`![alt](media://filename)`), with live thumbnail previews and remove actions in `CardEditorScreen`.
  * **Interactive Image Occlusion Editor**: Drag-to-draw rectangular masks on any image, add per-mask answer labels/hints, and atomically batch-generate $N$ sibling cards with shared `noteId`.
  * **Hide-All Reveal-One Study Session**: Reviewing Image Occlusion cards conceals all sibling masks with the active target highlighted; flipping the card reveals the target answer while keeping other masks occluded.
* **Interoperability, Hierarchy & Global Navigation (v0.9.2):**
  * Full bidirectional **Anki `.apkg` package export**: generates valid Anki SQLite schemas (`collection.anki2` with notes, cards, revlogs, and media mapping) for individual decks or all decks simultaneously via pure Dart.
  * **Hierarchical Subdecks (`Parent::Child` notation)**: recursive tree hierarchy in `DeckListScreen` with expandable/collapsible nodes, indentation levels, and recursive aggregation of due and total cards.
  * **Global Card Browser (`CardBrowserScreen`)**: instantaneous multi-criteria search across all decks, real-time query filtering, and filter chips for Deck, Color Flag (1..4), Suspended status, and Due today. Tap-to-edit with immediate reactive refresh.
* **Multi-Algorithm SRS Scheduling (FSRS & SM-2):**
  * Pluggable `SrsScheduler` strategy architecture isolating domain mathematics from UI controllers.
  * Pure Dart zero-dependency implementation of **FSRS** (Free Spaced Repetition Scheduler v4/v5) calculating stability ($S$), difficulty ($D$), and retrievability ($R$) with pure mathematical determinism.
  * Pure Dart implementation of **SuperMemo SM-2** calculating Easiness Factor ($EF$) and repetition intervals, selectable via Settings.
  * Real-time preview interval calculations on rating buttons (`Again`, `Hard`, `Good`, `Easy`) before confirming.
  * Anti-clustering interval fuzz factor and Vacation Mode (scheduler pause with non-destructive due date shifting).
* **Multi-Platform Desktop & Mobile Edition:**
  * Multi-platform native performance on Android, iOS, Windows (Win32 runner with MSVC ATL shim), macOS (Universal 2 binary for both Apple Silicon and Intel), and Linux.
  * Ergonomic keyboard shortcuts: `Space`/`Enter` to flip card, `1`–`4` for rating submission, `Ctrl+Z`/`Cmd+Z` for 1-step undo, `Ctrl+Enter`/`Cmd+Enter` to save cards.
  * Responsive Material 3 layout: auto-adapting between `NavigationRail` (>= 640px) and bottom `NavigationBar`.
* **Note Model, Card Types & Active Recall:**
  * Note model with automatic **Reverse Card** creation and linked sibling cards (`noteId`).
  * Automatic sibling burying during study sessions to prevent short-term recall interference, with deck unbury action.
  * **Type-in-the-Answer** mode with character-by-character real-time diffing (`match`, `wrong`, `missing`, `extra`).
  * Dynamic bidirectional text and native RTL script support (Arabic, Hebrew, Persian).
  * Session pacing: Timeboxing duration limits and auto-advance card flip timers.
  * Cloze deletions (`{{c1::answer}}` and `{{c1::answer::hint}}`) with atomic card batching.
  * Custom Study (Cram Mode / Free Review) for exam prep and non-destructive reviews.
  * Fine-grained card actions: 1-step Undo Review, Suspend, Bury, Set Due Date, Reset progress, Duplicate card.
  * Automated **Leech Detection** (configurable lapse threshold with auto-tagging or auto-suspension).
  * 4-color card flags (Red, Orange, Green, Blue) with deck-level filtering.
  * **Exam Scheduler**: target exam date study planner calculating required daily retention and review capacity.
* **Comprehensive Ecosystem & Data Sovereignty:**
  * Automatic rolling backups (configurable FIFO retention of up to 8 snapshots).
  * Full database backup and restore via standard JSON payloads with integrity checks.
  * Native Anki package (`.apkg`) import with media extraction, HTML-to-markdown sanitation, and model mapping.
  * CSV export and import support for quick card sharing and tabular migration.
  * Native file picker and system saver integration across all desktop and mobile platforms.
  * Onboarding deck seeder (`SampleDeckSeeder`) providing beginner cards on first run without external network assets.
  * 100% Offline-First: zero analytics, telemetry, crash reporting SDKs, cloud databases (no Firebase, no Supabase), or user accounts.
* **Display, Performance & Accessibility:**
  * AMOLED Pure Black theme (`#000000`) for zero-power display pixels on OLED screens, alongside adaptive M3 light and dark themes.
  * Native Android haptic feedback channel (`repetita/haptics`) with vibration fallbacks.
  * High-throughput SQLite tuning via optimized PRAGMAs (WAL journal, 64MB cache, memory temp store, 256MB mmap).
  * Pre-rendered flip card architecture for 60/120 FPS transitions and Android 13+ predictive back gesture support.
  * Semantic screen-reader annotations and accessible touch targets (>= 48×48 dp).
* **Retention Metrics & Visual Analytics:**
  * 15-week activity heatmap and study streak tracking.
  * Real-time retention accuracy percentage and maturity distribution (New, Learning, Review, Relearning).
  * 7-day workload forecast chart.

---

## 🏗️ Architecture & Technology Stack

Repetita follows a strict **Feature-First Layered Architecture**:

```text
lib/
├── main.dart
└── src/
    ├── app.dart                          # Root MaterialApp, AppTheme & routing
    ├── core/                             # Cross-cutting foundational modules
    │   ├── algorithms/
    │   │   ├── srs/                      # Pure Dart SrsScheduler interface & strategy
    │   │   ├── fsrs/                     # Pure Dart FSRS model, formulas, and math engine
    │   │   ├── sm2/                      # Pure Dart SM-2 algorithm & Easiness Factor math
    │   │   ├── type_in/                  # Pure Dart type-in differ and character comparison
    │   │   └── cloze/                    # Pure Dart cloze deletion text parser
    │   ├── database/                     # Drift central database definition, DAOs & migrations
    │   ├── theme/                        # Material 3 light, dark & AMOLED pure black themes
    │   └── utils/                        # RTL detection, text direction & platform helpers
    └── features/
        ├── decks/                        # Deck management, exam planner & sample seeder
        ├── cards/                        # Cards DAO, reverse cards, sibling linking & editor
        ├── study_session/                # Review loop, flip card, active recall UI & timers
        ├── stats/                        # Aggregated analytics, retention rate & forecast
        ├── settings/                     # Modular settings screens, reminders & algorithm selection
        ├── tags/                         # Tag CRUD, filters & card tagging
        └── backup_transfer/              # Rolling backup, Anki (.apkg), JSON/CSV export/import
```

### Core Technologies

| Component | Choice | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter & Dart 3.x** | Multi-platform UI (Android, iOS, Windows, macOS, Linux) |
| **State Management** | **Riverpod 3.x** | Reactive dependency injection & code generation (`@riverpod`) |
| **Persistence** | **Drift (SQLite)** | High-performance, reactive local SQL with migrations |
| **Spaced Repetition** | **SrsScheduler Strategy** | Extensible pure Dart scheduling engines (FSRS v4/v5 & SuperMemo SM-2) |
| **Design System** | **Material 3** | Adaptive dynamic theming, AMOLED Pure Black, NavigationRail (desktop) & accessible contrast |
| **Serialization** | **Immutable Value Classes** | Hand-written `final`-field classes with manual `toJson`/`fromJson` |

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.x+)
* **Android:** Android Studio / Android SDK (API 30+)
* **Windows:** Visual Studio 2022 with C++ desktop workload
* **macOS:** Xcode 15+ (macOS 12.0+ deployment target)
* **Linux:** Clang, CMake, GTK development libraries
* **iOS:** Xcode (simulator / sideloading)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CydonianCitizen/Repetita.git
   cd Repetita
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift & Riverpod):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run on connected device or desktop:**
   ```bash
   # Run on default connected device / emulator
   flutter run

   # Run on desktop target
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

---

## 🧪 Testing & Verification

Repetita maintains a comprehensive test suite including 100% unit test coverage for the FSRS and SM-2 math engines, Drift DAO database tests, widget tests, and full end-to-end user journeys:

```bash
# Run all tests (unit, widget, integration)
flutter test

# Format validation
dart format --output=none --set-exit-if-changed .

# Static analysis (zero warnings allowed)
flutter analyze --fatal-infos --fatal-warnings

# Build local target binaries
flutter build apk --release --split-per-abi  # Android split APKs
flutter build windows --release              # Windows x64 executable
flutter build macos --release                # macOS Universal 2 app
flutter build linux --release                # Linux desktop executable
```

---

## 🤖 F-Droid Readiness & Open Source Compliance

Repetita is fully compatible with F-Droid and free/open-source distribution standards:

* **Zero Proprietary Blobs:** Contains no Google Mobile Services (GMS), Firebase, crash reporting libraries, proprietary advertising, or tracking SDKs.
* **Local Notifications:** Daily reminders are implemented using Android's native `AlarmManager` and `NotificationManager` via `flutter_local_notifications`. No push notification services or external daemons are used.
* **Core Library Desugaring:** The Android build configuration (`android/app/build.gradle.kts`) enables Java 8+ API desugaring (`isCoreLibraryDesugaringEnabled = true`) using the open-source `com.android.tools:desugar_jdk_libs:2.1.4`.
* **Reproducible Local Build:**
  ```bash
  flutter build apk --release --split-per-abi
  ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
