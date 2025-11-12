# Focus Hybrid Chrome Extension — Development & Release Guide

This project delivers a production‑ready Chrome extension that combines:
- Flutter Web UI for the new tab experience and settings
- TypeScript logic for social feed cleaning (content script) and integration

It follows Chrome Manifest V3 policies and a clean, scalable architecture.

## Prerequisites
- Node.js 16+ and npm
- Flutter SDK (for web builds)
- A Chromium browser (Chrome/Edge/Brave) for testing
- Optional: Dart SDK for the Unsplash demo server

## Install
- At project root: `npm install`

## Develop
- Quick start: `npm run dev`
  - Builds Flutter Web (`build/web`), copies into `extension/newtab`, then starts Rollup in watch mode to bundle the social cleaner into `extension/social_cleaner/content.js`.

- Fine‑grained steps:
  - Flutter build: `npm run build:flutter`
  - Copy new tab assets: `npm run copy:newtab`
  - TypeScript watcher: `npm run dev:ts`

## Build (Release)
- Clean previous output: `npm run clean:ext`
- Full extension build: `npm run build:ext`
  - Runs Flutter web build → copies assets → bundles TypeScript with Rollup into `extension/social_cleaner/content.js`.

## Load in Chrome
- Open `chrome://extensions` → enable Developer mode → Load unpacked
- Select either:
  - `extension/` if you have a root `manifest.json` configured
  - or `extension/newtab/` when using the Flutter‑generated `manifest.json`

## Verify TypeScript Bundling
- Build once: `npm run build:ts`
- Watch mode: `npm run dev:ts`
- Output is written to `extension/social_cleaner/content.js`.

## Unsplash Demo Server (Optional)
- Start locally: `dart run server/bin/server.dart`
- Docker: `docker build . -t dart-unsplash-server && docker run -it -p 8000:8000 dart-unsplash-server`

## Notes
- Manifest V3 requires CSP‑safe builds. If you encounter CSP issues, rebuild Flutter Web with CSP flags and recopy:
  - `flutter build web --release --csp --no-web-resources-cdn`
  - `npm run copy:newtab`
- If MobX codegen is missing (e.g., `social_cleaner_store.g.dart`), run:
  - `flutter pub run build_runner build --delete-conflicting-outputs`

## Scripts (package.json)
- `build:flutter` → Flutter web release build
- `copy:newtab` → Copy `build/web` to `extension/newtab`
- `build:ts` → Rollup bundle of feed cleaner TypeScript
- `build:ext` → Full extension build (Flutter + copy + TS)
- `clean:ext` → Clear `extension/newtab/*` and `extension/social_cleaner/*`
- `dev:ts` → Rollup watch
- `dev` → Flutter build + copy + Rollup watch