# Focus — Flutter Focus Extension (Chrome MV3)

A hybrid Chrome extension that combines a Flutter Web UI (New Tab, Settings) with TypeScript/JavaScript logic for social feed cleaning. 
Flutter controls the on/off state and site‑specific behavior; the extension background scripts persist settings and broadcast changes to content scripts running on supported sites.


## 1. Project Structure

focus/
├─ extension/                                # MV3 extension (TS recommended)
│  ├─ manifest.json
│  ├─ src/
│  │  ├─ background/                         # Service worker
│  │  │  ├─ domain/                          # Message contracts, settings entities
│  │  │  ├─ application/                     # Use cases, message routing
│  │  │  └─ infrastructure/                  # chrome.* wrappers (storage/tabs/runtime)
│  │  ├─ content/
│  │  │  ├─ social_cleaner/
│  │  │  │  ├─ domain/                        # Site detection, policies, selectors
│  │  │  │  ├─ application/                   # Eradication logic, observers
│  │  │  │  └─ presentation/                  # CSS, quote banner UI
│  │  │  └─ common/                            # DOM helpers
│  │  ├─ shared/                              # Pure types/utilities
│  │  └─ ui/                                  # Optional popup/options/sidepanel
│  ├─ dist/                                   # Bundled JS/CSS
│  └─ newtab/                                 # Flutter build output (web)
│
├─ lib/                                       # Flutter app
│  ├─ main.dart                               # App entry
│  ├─ service_locator.dart                    # DI container (GetIt)
│  ├─ core/                                   # App‑wide configs & base types
│  │  ├─ configs/
│  │  │  ├─ theme/
│  │  │  │  ├─ app_theme.dart                 # Extracted from buildTheme
│  │  │  │  └─ app_color.dart                 # Theme colors
│  │  │  └─ assets/
│  │  │     ├─ app_images.dart
│  │  │     └─ app_vectors.dart
│  │  ├─ constants/
│  │  │  ├─ storage_keys.dart
│  │  │  └─ unsplash_sources.dart
│  │  ├─ resources/                           # Generated constants
│  │  │  ├─ flat_colors.dart
│  │  │  └─ color_gradients.dart
│  │  ├─ backend/
│  │  │  ├─ backend_service.dart              # Interfaces
│  │  │  └─ rest_backend_service.dart         # Implementations
│  │  ├─ services/
│  │  │  ├─ storage_manager.dart
│  │  │  ├─ weather_service.dart
│  │  │  └─ geocoding_service.dart
│  │  └─ utils/
│  │     ├─ enum_extensions.dart
│  │     ├─ extensions.dart
│  │     ├─ labeled_property.dart
│  │     └─ universal/
│  │        ├─ io.dart
│  │        ├─ web.dart
│  │        └─ universal.dart
│  ├─ common/                                 # Shared helpers & widgets
│  │  ├─ helpers/
│  │  │  └─ is_dark_mode.dart                 # Example helpers
│  │  └─ widgets/
│  │     ├─ appbar/app_bar.dart
│  │     ├─ button/basic_app_button.dart
│  │     ├─ banner/message_banner.dart        # From lib/ui/message_banner
│  │     └─ banner/message_view.dart
│  ├─ data/                                   # Data layer
│  │  ├─ models/                              # From lib/home/model/*
│  │  │  ├─ background_settings.dart
│  │  │  ├─ flat_color.dart
│  │  │  ├─ color_gradient.dart
│  │  │  ├─ export_data.dart
│  │  │  ├─ weather_info.dart
│  │  │  └─ weather_response.dart
│  │  ├─ sources/                             # Remote/local sources
│  │  │  └─ backend/                          # REST, Unsplash, etc.
│  │  └─ repository/                          # Implementations (if extracted)
│  ├─ domain/                                 # Entities, repositories, usecases
│  │  ├─ entities/
│  │  │  ├─ todo_task.dart                    # If extracted from store
│  │  │  └─ widget_settings.dart              # Canonical settings entities
│  │  ├─ repository/                          # Interfaces (e.g., BackgroundRepo)
│  │  └─ usecase/
│  │     └─ background/                       # e.g., UpdateColor, ImportSettings
│  └─ presentation/                           # Feature UI and state (MobX/Bloc)
│     ├─ home/
│     │  ├─ pages/home_page.dart              # From lib/home/home.dart
│     │  ├─ widgets/
│     │  │  ├─ home_background.dart
│     │  │  ├─ home_widget.dart
│     │  │  ├─ bottom_bar.dart
│     │  │  ├─ todo/
│     │  │  │  ├─ todo_widget.dart
│     │  │  │  ├─ todo_row.dart
│     │  │  │  ├─ notes_pane.dart
│     │  │  │  └─ legend_pane.dart
│     │  │  ├─ digital_clock_widget.dart
│     │  │  ├─ analog_clock_widget.dart
│     │  │  ├─ digital_date_widget.dart
│     │  │  ├─ weather_widget.dart
│     │  │  └─ message_widget.dart
│     │  └─ store/
│     │     ├─ background_store.dart
│     │     ├─ home_store.dart
│     │     └─ widget_store.dart
│     ├─ settings/
│     │  ├─ pages/
│     │  │  ├─ background_settings_view.dart
│     │  │  └─ settings_panel.dart
│     │  ├─ dialogs/
│     │  │  ├─ reset_dialog.dart
│     │  │  ├─ new_collection_dialog.dart
│     │  │  ├─ liked_backgrounds_dialog.dart
│     │  │  ├─ changelog_dialog.dart
│     │  │  └─ advanced_settings_dialog.dart
│     │  └─ widget_settings/
│     │     ├─ weather_widget_settings.dart
│     │     ├─ timer_widget_settings.dart
│     │     ├─ message_widget_settings.dart
│     │     ├─ digital_date_widget_settings.dart
│     │     ├─ digital_clock_widget_settings.dart
│     │     └─ analog_clock_widget_settings.dart
│     └─ social_cleaner/
│        ├─ pages/
│        │  └─ social_cleaner_settings.dart   # Flutter side panel
│        └─ store/
│           └─ social_cleaner_store.dart
│
├─ scripts/
├─ assets/
├─ package.json
├─ pubspec.yaml
└─ analysis_options.yaml
```

#### Move Guide (from current → to template style)
- `lib/home/home.dart` → `lib/presentation/home/pages/home_page.dart`
- `lib/home/home_background.dart` → `lib/presentation/home/widgets/home_background.dart`
- `lib/home/home_widget.dart` → `lib/presentation/home/widgets/home_widget.dart`
- `lib/home/bottom_bar.dart` → `lib/presentation/home/widgets/bottom_bar.dart`
- `lib/home/widgets/todo/*` → `lib/presentation/home/widgets/todo/*`
- `lib/home/background_store.dart` → `lib/presentation/home/store/background_store.dart`
- `lib/home/home_store.dart` → `lib/presentation/home/store/home_store.dart`
- `lib/home/widget_store.dart` → `lib/presentation/home/store/widget_store.dart`
- `lib/settings/*` views → `lib/presentation/settings/pages/*`
- `lib/settings/*_dialog.dart` → `lib/presentation/settings/dialogs/*`
- `lib/settings/widget_settings/*` → `lib/presentation/settings/widget_settings/*`
- `lib/resources/*` → split under `lib/core/constants/*`, `lib/core/resources/*`, or `lib/core/configs/*` as listed above
- `lib/ui/*` → `lib/common/widgets/*` (subfolders by component type)
- `lib/utils/*` services → `lib/core/services/*`; helpers → `lib/core/utils/*` or `lib/common/helpers/*`
- `lib/backend/*` → interfaces under `lib/core/backend/*`; impls under `lib/data/sources/backend/*` or stay in `core/backend` if thin wrappers

Use package imports (`package:focus/...`) to simplify moves.

### Flutter‑Clean‑Template: lib Structure (reference)

The following is the actual `lib/` layout from `Flutter-Clean-Template` for consistency:

```
lib/
├─ main.dart
├─ service_locator.dart
├─ core/
│  ├─ configs/
│  │  ├─ theme/
│  │  │  ├─ app_color.dart
│  │  │  └─ app_theme.dart
│  │  └─ assets/
│  │     ├─ app_images.dart
│  │     └─ app_vectors.dart
│  ├─ constants/
│  │  └─ app_urls.dart
│  └─ usecase/
│     └─ usecase.dart
├─ common/
│  ├─ helpers/
│  │  └─ is_dark_mode.dart
│  └─ widgets/
│     ├─ appbar/app_bar.dart
│     └─ button/basic_app_button.dart
├─ domain/
│  ├─ entities/
│  │  └─ auth/user.dart
│  ├─ repository/
│  │  └─ auth/auth.dart
│  └─ usecase/
│     └─ auth/
│        ├─ signup.dart
│        ├─ signin.dart
│        └─ get_user.dart
├─ data/
│  ├─ models/
│  │  └─ auth/
│  │     ├─ user.dart
│  │     ├─ signin_user_req.dart
│  │     └─ create_user_req.dart
│  ├─ sources/
│  │  └─ auth/auth_firebase_service.dart
│  └─ repository/
│     └─ auth/auth_repository_impl.dart
└─ presentation/
   ├─ splash/pages/splash.dart
   ├─ intro/pages/get_started.dart
   ├─ choose_mode/
   │  ├─ pages/choose_mode.dart
   │  └─ bloc/theme_cubit.dart
   └─ auth/pages/
      ├─ signin.dart
      ├─ signup.dart
      └─ signup_or_signin.dart
```

### Focus: Target lib Structure (match Flutter‑Clean‑Template)

Adopt the same folder names and layering. Move your current files to these destinations.

```
lib/
├─ main.dart                                  # existing
├─ service_locator.dart                       # create (GetIt registrations)
├─ core/
│  ├─ configs/
│  │  ├─ theme/
│  │  │  ├─ app_color.dart                    # extract theme colors from current theme
│  │  │  └─ app_theme.dart                    # extract ThemeData from lib/main.dart:1-? 
│  │  └─ assets/
│  │     ├─ app_images.dart                   # optional; reference existing assets
│  │     └─ app_vectors.dart                  # optional
│  ├─ constants/
│  │  ├─ storage_keys.dart                    # from lib/resources/storage_keys.dart
│  │  └─ app_urls.dart                        # optional
│  └─ usecase/
│     └─ usecase.dart                         # optional base usecase
├─ common/
│  ├─ helpers/
│  │  └─ is_dark_mode.dart                    # optional, or reuse existing util
│  └─ widgets/
│     ├─ message_banner/message_banner.dart   # from lib/ui/toast/message_banner.dart
│     └─ message_banner/message_view.dart     # from lib/ui/toast/message_view.dart
├─ domain/
│  ├─ entities/
│  │  ├─ widget_settings.dart                 # extract from current models
│  │  └─ todo_task.dart                       # extract entity from store/model
│  ├─ repository/
│  │  ├─ settings_repo.dart                   # interface for settings
│  │  └─ background_repo.dart                 # interface for background ops
│  └─ usecase/
│     ├─ background/update_color.dart         # example usecases
│     └─ settings/import_export.dart
├─ data/
│  ├─ models/
│  │  ├─ flat_color.dart                      # from lib/home/model/flat_color.dart
│  │  ├─ color_gradient.dart                  # from lib/home/model/color_gradient.dart
│  │  ├─ background_settings.dart             # from lib/home/model/background_settings.dart
│  │  ├─ export_data.dart                     # from lib/home/model/export_data.dart
│  │  ├─ weather_info.dart                    # from lib/home/model/weather_info.dart
│  │  └─ weather_response.dart                # from lib/home/model/weather_response.dart
│  ├─ sources/
│  │  ├─ backend/rest_backend_service.dart    # move from lib/backend/rest_backend_service.dart
│  │  ├─ backend/backend_service.dart         # move from lib/backend/backend_service.dart
│  │  └─ storage/local_storage_manager.dart   # move from lib/utils/storage_manager.dart
│  └─ repository/
│     └─ settings_repository_impl.dart        # optional, implement interfaces
└─ presentation/
   ├─ home/
   │  ├─ pages/home_page.dart                 # from lib/home/home.dart
   │  ├─ widgets/
   │  │  ├─ home_background.dart              # from lib/home/home_background.dart
   │  │  ├─ home_widget.dart                  # from lib/home/home_widget.dart
   │  │  ├─ bottom_bar.dart                   # from lib/home/bottom_bar.dart
   │  │  ├─ todo/
   │  │  │  ├─ todo_widget.dart
   │  │  │  ├─ todo_row.dart
   │  │  │  ├─ notes_pane.dart
   │  │  │  └─ legend_pane.dart               # from lib/home/widgets/todo/*
   │  │  ├─ digital_clock_widget.dart
   │  │  ├─ analog_clock_widget.dart
   │  │  ├─ digital_date_widget.dart
   │  │  ├─ weather_widget.dart
   │  │  └─ message_widget.dart               # from lib/home/widgets/*
   │  └─ store/
   │     ├─ background_store.dart             # from lib/home/store/background_store.dart
   │     ├─ home_store.dart                   # from lib/home/store/home_store.dart
   │     └─ widget_store.dart                 # from lib/home/store/widget_store.dart
   ├─ settings/
   │  ├─ pages/background_settings_view.dart  # from lib/settings/background_settings_view.dart
   │  ├─ pages/settings_panel.dart            # from lib/settings/settings_panel.dart
   │  ├─ dialogs/
   │  │  ├─ reset_dialog.dart
   │  │  ├─ new_collection_dialog.dart
   │  │  ├─ liked_backgrounds_dialog.dart
   │  │  ├─ changelog_dialog.dart
   │  │  └─ advanced_settings_dialog.dart
   │  └─ widget_settings/
   │     ├─ weather_widget_settings.dart
   │     ├─ timer_widget_settings.dart
   │     ├─ message_widget_settings.dart
   │     ├─ digital_date_widget_settings.dart
   │     ├─ digital_clock_widget_settings.dart
   │     └─ analog_clock_widget_settings.dart
   └─ social_cleaner/
      ├─ pages/social_cleaner_settings.dart   # rename/move from lib/home/model/social_cleaner_store.dart (UI)
      └─ store/social_cleaner_store.dart      # from lib/home/model/social_cleaner_store.dart (state)
```

#### Notes
- Folder names match `Flutter-Clean-Template` exactly: `core`, `common`, `domain`, `data`, `presentation`.
- Create `service_locator.dart` and move DI (GetIt) registrations there.
- Extract theme from `lib/main.dart:1-?` into `core/configs/theme/app_theme.dart` to mirror the template.
- Move backend and storage under `data/sources/*` to align with template.
- Keep entities and usecases pure under `domain/*`.

### Directory Purposes
- `extension/`: the unpacked extension you load in Chrome. Contains `manifest.json`, `background.js`, unified content script under `social_cleaner/`, and the Flutter build under `newtab/`.
- `lib/`: Flutter Web UI for New Tab and the Settings dialog. It persists settings and sends updates to the extension background.
- `feed-focus-reference/`: previous modular TS architecture for the cleaner (kept for reference). Current build uses `content_unified.js` instead.
- `scripts/`: Node/Dart helpers used in build and maintenance.
- `.vscode/`: developer convenience tasks and keybindings.
 

### Key Configuration Files
- `extension/manifest.json` — declares content scripts, background service worker, host permissions, and `run_at`.
- `extension/background.js` — MV3 service worker. Persists settings in `chrome.storage.local` and broadcasts updates to all tabs.
- `extension/social_cleaner/content_unified.js` — unified content script: site detection, CSS injection, quote banner, settings listening.
- `lib/home/model/social_cleaner_store.dart` — Flutter store for social cleaner settings; writes settings and notifies background.
- `package.json` — NPM scripts to build TS and copy Flutter web.
- `pubspec.yaml` — Flutter/Dart dependencies and assets configuration.

## 2. Functionality Overview

### Major Features
- New Tab (Flutter Web)
  - Displays the main UI and Settings dialog.
  - Persists Social Cleaner settings (global enable, per‑site enable, quotes options).
- Social Cleaner (Content Script)
  - Detects supported sites (YouTube, Twitter/X, Reddit, Facebook, Instagram, LinkedIn, GitHub).
  - Hides feed content when enabled and injects a theme‑aware quote banner.
  - Reacts to SPA route changes and dynamic content.
- Background Service Worker
  - Loads/saves settings in `chrome.storage.local`.
  - Listens for messages from Flutter and broadcasts updates to content scripts.
- Messaging & Storage
  - Flutter sends `{ action: 'updateSocialCleanerSettings', settings }` to background.
  - Background persists and sends `{ action: 'settingsUpdated', settings }` to tabs.
  - Content script listens to both messages and `chrome.storage.onChanged`.

### Core Functions
- `extension/social_cleaner/content_unified.js:241` — `isEnabledForSite(siteId)` checks global and per‑site flags.
- `extension/social_cleaner/content_unified.js:266` — `eradicate()` applies or removes styles/banner based on settings.
- `extension/social_cleaner/content_unified.js:183` — `createQuoteContainer(quote)` builds a banner with dark/light detection.
- `extension/background.js:86` — `saveSettings(settings)` persists to `chrome.storage.local` and broadcasts updates.
- `lib/utils/social_cleaner_store.dart:189` — `_save()` writes settings and `_notifyBackground(settings)` sends updates.

### External Dependencies
- Node: `fs-extra` for build/copy.
- Flutter/Dart packages: `shared_preferences`, `provider`, `mobx`, `flutter_mobx`, `intl`, etc. See `pubspec.yaml`.
- Chrome APIs: `chrome.scripting`, `chrome.runtime`, `chrome.storage`, `chrome.tabs` (MV3).

## 3. Setup and Execution Instructions

### System Requirements
- Node.js: `>= 18`
- npm: `>= 9`
- Flutter: `>= 3.22` (Dart SDK `^3.7.0`)
- Chrome: latest stable with MV3 support

### Installation
```bash
# In the project root
npm install
flutter pub get
```

### Build (Production)
```bash
# Build Flutter web and copy into extension/newtab
npm run build:ext
# or individually
npm run build:flutter && npm run copy:newtab
```

### Development
```bash
# One-shot Flutter build and copy for local testing
npm run dev

# If you edit Flutter code frequently, run:
flutter build web --release --csp --no-web-resources-cdn
npm run copy:newtab
```

### Load the Extension
```text
1. Open chrome://extensions
2. Enable Developer mode
3. Click “Load unpacked” and select the `extension/` folder
4. Open a supported site; use the New Tab Settings to toggle behavior
```

### Configuration
- No secrets are required.
- Settings are persisted in `chrome.storage.local` under key `socialCleanerSettings`.
- Flutter uses a store that mirrors changes to the background via `chrome.runtime.sendMessage`.
 - Flutter store key name is `social_cleaner_settings`; background converts and persists under `socialCleanerSettings`.

### Testing
- Manual testing:
  - Toggle global enable/disable and per‑site switches in the Settings dialog.
  - Confirm feed hidden/shown and banner visibility.
  - Navigate across SPA pages; verify consistent behavior.
- Static checks:
```bash
# Flutter analyzer
fvm flutter analyze  # or: flutter analyze
```

## 4. Additional Information

### Deployment
- Package by zipping the `extension/` directory contents (excluding any development artifacts) and upload to the Chrome Web Store.
- Ensure `manifest.json` is MV3 compliant and that all scripts are within the extension directory.

### Known Issues / Limitations
- MV3 service workers cannot use `window.localStorage` — use `chrome.storage.local`.
- SPA sites may require periodic re‑evaluation; handled via interval and mutation observer in the content script.
- Per‑site selectors can change as platforms update their DOM; updates may be required.

### Contribution Guidelines
- Fork and create feature branches.
- Follow code style and linting:
```bash
flutter analyze
```
- Do not commit API keys or secrets.
- For larger changes, update this README if structure or workflows change.

---

### Quick Reference
- Load extension: `extension/`
- Background: `extension/background.js`
- Content script: `extension/social_cleaner/content_unified.js`
- Flutter settings store: `lib/utils/social_cleaner_store.dart`
- Build all: `npm run build:ext`