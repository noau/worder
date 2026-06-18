> This project contains code and documentation generated using LLM.

# Worder

> A word collector app for writers.

A vocabulary collection and review app built for writers. It uses the FSRS spaced-repetition algorithm to drive memory retention, supports AI-enhanced definitions, and connects to any OpenAI-compatible endpoint (including local Ollama models). All data is stored locally — the app works fully offline.

## Features

- 📝 **Add words**: capture word, pinyin, meaning, and notes in one form
- 🔄 **FSRS spaced repetition**: smart scheduling powered by the `fsrs` library; due cards surface automatically
- 📖 **Learn mode**: progressive introduction of new words, scheduled alongside reviews
- 📚 **Library**: unified list view with detail pages and note editing
- 🤖 **AI-enhanced definitions**: plug in any OpenAI-compatible endpoint, including local Ollama
- 🌙 **Dark mode + multi-language**: zh-Hans-CN / zh-Hant-TW / zh-Hant-HK / en

## Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | API 21+ |
| Windows | ✅ Supported | x64 |

> ⚠️ iOS / macOS / Linux / Web are **not** currently supported.

## Tech Stack

| Category | Choice |
|----------|--------|
| Framework | Flutter (Dart ^3.10.4) |
| Local storage | Drift (SQLite) |
| Scheduling | fsrs |
| LLM client | openai_dart (OpenAI-compatible) |
| Routing | auto_route |
| Dependency injection | provider |
| Theming | adaptive_theme |
| Toast | bot_toast |
| Responsive layout | responsive_framework |
| Localization | flutter gen-l10n |

## Build & Run

Requirements: Flutter SDK ≥ 3.10.4 with a matching Dart SDK.

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Code generation (auto_route / drift / json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. Run
flutter run                # default device
flutter run -d windows     # Windows desktop

# 4. Build release artifacts
flutter build windows      # Windows x64
flutter build apk          # Android APK
```

Common dev commands:

```bash
flutter analyze            # Static analysis (flutter_lints)
flutter format .           # Format
flutter test               # Unit tests (no test/ directory yet)
```

> See [CLAUDE.md](./CLAUDE.md) for the full command reference.

## Localization

The project uses Flutter's standard `flutter gen-l10n`. String source files live under `lib/l10n/`.

| Locale | Description | ARB file |
|--------|-------------|----------|
| `en` | English (template / fallback) | `intl_en.arb` |
| `zh-Hans-CN` | Simplified Chinese (Mainland China) | `intl_zh_Hans_CN.arb` |
| `zh-Hant-TW` | Traditional Chinese (Taiwan) | `intl_zh_Hant_TW.arb` |
| `zh-Hant-HK` | Traditional Chinese (Hong Kong) | `intl_zh_Hant_HK.arb` |

`intl_zh.arb` acts as a generic Chinese fallback that currently only overrides `appTitle`; when no region-specific variant matches, the more specific ARB wins, and any missing key falls back to English.

**To add a new language:**

1. Drop an `intl_<locale>.arb` under `lib/l10n/` (clone from `intl_en.arb`, translate the `value` side only).
2. Append the matching `Locale(...)` entry to `supportedLocales` in `lib/main.dart`.
3. If `intl.DateFormat` does not ship native data for the language, call `initializeDateFormatting(...)` in `main()`.
4. Run `flutter gen-l10n` (or `flutter pub get`, which triggers it).
5. For a localized Android launcher label, add a `strings.xml` under `android/app/src/main/res/values-<lang>/`.

## AI Configuration

The app talks to a configurable LLM endpoint. Open **Settings** and fill in the following three fields:

| Field | Description | Example |
|-------|-------------|---------|
| Base URL | OpenAI-compatible service URL | `https://api.openai.com/v1`, `http://localhost:11434/v1` (Ollama) |
| API Key | Service key | `sk-...` |
| Model Name | Model identifier | `gpt-4o-mini`, `qwen2.5:7b` |

- Edits take effect immediately; debounced 300 ms before persisting to `SharedPreferences["LLM_CONFIG"]`.
- The **Test Connection** button fires a minimal request to validate the config.
- The service layer re-reads the latest config on every call (no static cache).

## Downloads & Releases

- **Windows**: maintainer-publishes x64 builds.
- **Android**: maintainer-publishes APKs; per-architecture support (arm64-v8a / armeabi-v7a / x86_64) is documented in each version's Release Notes.
- For other platforms or architectures, follow the **Build & Run** steps above to build from source.

## Project Structure

```
lib/
├── main.dart              # Entry point + MultiProvider + Locale wiring
├── config.dart            # Debug flags / timeouts / debounce constants
├── database.dart          # Drift AppDatabase (WordRows table)
├── routing.dart           # auto_route route table
├── theme.dart             # Light / dark / multi-contrast themes
├── repository.dart        # PreferencesRepository / SchedulerRepository
├── constant/              # Constants (e.g. AI prompts)
├── entity/                # Domain models (WordModel / LLMConfig)
├── l10n/                  # gen-l10n resources
├── manager/               # Business orchestration (AIEnhancer / LearningSessionManager, ...)
├── page/                  # Screens (Splash / Home / Dashboard / Library / Settings / AddWord / LearnReview, ...)
├── service/               # Service layer (AIService)
├── util/                  # Utilities (date / l10n / error localization)
└── widget/                # Reusable UI components
```

## License

Released under the MIT License.

<!-- TODO: link to the LICENSE file once it is added -->