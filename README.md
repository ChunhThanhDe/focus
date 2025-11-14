# Focus — Flutter New Tab + Social Cleaner (Chrome MV3)

A hybrid Chrome extension that combines a Flutter Web UI (New Tab, Settings) with TypeScript/JavaScript logic for social feed cleaning. Flutter controls the on/off state and site‑specific behavior; the extension background scripts persist settings and broadcast changes to content scripts running on supported sites.

## 1. Project Structure

```
focus/
├─ extension/                      # Unpacked Chrome extension folder (load this in chrome://extensions)
│  ├─ manifest.json               # MV3 manifest: content scripts, permissions, background
│  ├─ background.js               # Service worker: settings persistence, message routing
│  ├─ social_cleaner/             # Content script and assets for social feed cleaning
│  │  └─ content_unified.js       # Unified cleaner logic with per‑site selectors & quote banner
│  └─ newtab/                     # Copied Flutter build output (index.html, assets, canvaskit, etc.)
│
├─ lib/                           # Flutter application source
│  ├─ ui/                         # UI widgets/components
│  ├─ utils/                      # Logic + storage
│  │  ├─ social_cleaner_store.dart # Settings store, persistence, and bridge to background
│  │  └─ storage_manager.dart     # Abstraction over SharedPreferences (web uses localStorage)
│  └─ resources/                  # Constants, keys
│     └─ storage_keys.dart        # Keys for persisted settings (e.g., social_cleaner_settings)
│
├─ feed-focus/                    # Legacy News Feed Eradicator TS implementation (reference)
│  ├─ src/                        # Background store, content entry, site logic
│  │  ├─ intercept.ts             # Original content entry (not used by unified content script)
│  │  ├─ background/service-worker.ts # Original MV2/MV3 background store
│  │  └─ sites/*.ts               # Per‑site handlers/selectors
│  └─ rollup.config.js            # Legacy bundling for TS modules
│
├─ scripts/                       # Build, copy, and utility scripts
│  ├─ copy-flutter-web.js         # Copies Flutter build into extension/newtab
│  ├─ copy-social-bundle.js       # Copies TS bundle if using legacy approach
│  └─ generators/*                # Dev helpers (colors, gradients)
│
├─ assets/                        # Flutter assets (fonts, images, translations)
├─ package.json                   # Node build scripts for extension TS+copy flow
├─ rollup.config.js               # Rollup config for TS bundling (legacy modular code)
├─ pubspec.yaml                   # Flutter/Dart dependencies and assets
├─ analysis_options.yaml          # Flutter lints
```

### Directory Purposes
- `extension/`: the unpacked extension you load in Chrome. Contains `manifest.json`, `background.js`, unified content script under `social_cleaner/`, and the Flutter build under `newtab/`.
- `lib/`: Flutter Web UI for New Tab and the Settings dialog. It persists settings and sends updates to the extension background.
- `feed-focus/`: previous modular TS architecture for the cleaner (kept for reference). Current build uses `content_unified.js` instead.
- `scripts/`: Node/Dart helpers used in build and maintenance.
- `.vscode/`: developer convenience tasks and keybindings.
 

### Key Configuration Files
- `extension/manifest.json` — declares content scripts, background service worker, host permissions, and `run_at`.
- `extension/background.js` — MV3 service worker. Persists settings in `chrome.storage.local` and broadcasts updates to all tabs.
- `extension/social_cleaner/content_unified.js` — unified content script: site detection, CSS injection, quote banner, settings listening.
- `lib/utils/social_cleaner_store.dart` — Flutter store for social cleaner settings; writes settings and notifies background.
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
- Node: Rollup, `fs-extra` for build/copy.
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
# Build Flutter web and copy into extension/newtab, then bundle TS
npm run build:ext
# or individually
npm run build:flutter && npm run copy:newtab && npm run build:ts
```

### Development
```bash
# One-shot Flutter build then watch TS bundling
npm run dev

# If you edit Flutter code frequently, run:
flutter build web --release --csp --no-web-resources-cdn
npm run copy:newtab
# then keep TS watcher on:
rollup -c -w  # optional: only needed if working on legacy TS in feed-focus/
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

# TypeScript bundle check
npm run build:ts
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
npm run build:ts
```
- Keep TypeScript strict and avoid `any` in new code.
- Do not commit API keys or secrets.
- For larger changes, update `docs/` and this README if structure or workflows change.

---

### Quick Reference
- Load extension: `extension/`
- Background: `extension/background.js`
- Content script: `extension/social_cleaner/content_unified.js`
- Flutter settings store: `lib/utils/social_cleaner_store.dart`
- Build all: `npm run build:ext`