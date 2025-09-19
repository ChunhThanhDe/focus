# Focus - Flutter Chrome Extension Project Documentation

## Overview

**Focus** is a customizable new tab Chrome extension built with Flutter Web. It provides users with a beautiful, personalized dashboard featuring dynamic backgrounds, widgets (clocks, weather, timers), and a clean interface. The application follows a modern architecture with MobX state management, modular design, and supports both local development and production deployment.

### Key Highlights
- **Flutter Web to Chrome Extension**: Leverages Flutter's web compilation to create a Chrome extension
- **Dynamic Backgrounds**: Integrates with Unsplash API for beautiful background images
- **Customizable Widgets**: Digital/analog clocks, weather, date, timer, and message widgets
- **State Management**: Uses MobX for reactive state management
- **Modular Architecture**: Clean separation of concerns with dedicated stores and services
- **Internationalization**: Supports multiple languages (English, Vietnamese)
- **Local & Cloud Backend**: Flexible backend service supporting both local development and production

## Tech Stack & Dependencies

### Core Framework
- **Flutter SDK**: >=3.22.0 <4.0.0
- **Dart SDK**: ^3.7.0

### State Management & Architecture
- **MobX**: ^2.5.0 - Reactive state management
- **flutter_mobx**: ^2.3.0 - Flutter bindings for MobX
- **Provider**: ^6.1.5 - Dependency injection and state provision
- **GetIt**: ^8.0.3 - Service locator pattern

### UI & Styling
- **Material Design 3**: Built-in Flutter theming
- **Custom Fonts**: Product, Cardo, Jakarta Sans, Renner
- **flutter_multi_formatter**: ^2.13.7 - Input formatting utilities

### Backend & API Integration
- **http**: ^1.4.0 - HTTP client for API calls
- **unsplash_client**: ^3.0.0 - Unsplash API integration
- **shelf**: ^1.4.2 (server) - HTTP server framework
- **shelf_router**: ^1.1.4 (server) - Routing middleware

### Storage & Persistence
- **shared_preferences**: ^2.5.3 - Local key-value storage
- **LocalStorageManager**: Custom abstraction over SharedPreferences

### Utilities & Services
- **easy_localization**: ^3.0.8 - Internationalization
- **intl**: ^0.20.2 - Date/time formatting
- **url_launcher**: ^6.3.1 - External URL handling
- **package_info_plus**: ^8.3.0 - App metadata access
- **file_picker**: ^10.1.9 - File selection
- **universal_html**: ^2.2.4 - Cross-platform HTML support

### Development Tools
- **build_runner**: ^2.4.15 - Code generation
- **json_serializable**: ^6.9.5 - JSON serialization
- **mobx_codegen**: ^2.7.1 - MobX code generation
- **flutter_launcher_icons**: ^0.14.3 - App icon generation

## Folder Structure

```
focus/
├── lib/                          # Main Flutter application
│   ├── backend/                  # Backend service abstractions
│   │   ├── backend_service.dart  # Abstract backend interface
│   │   └── rest_backend_service.dart # REST API implementation
│   ├── home/                     # Home screen & core functionality
│   │   ├── background_store.dart # Background management (779 lines)
│   │   ├── home_store.dart       # Main app state management
│   │   ├── widget_store.dart     # Widget configuration store
│   │   ├── home.dart             # Home screen wrapper
│   │   ├── home_widget.dart      # Main home widget
│   │   ├── bottom_bar.dart       # Settings button & controls
│   │   └── model/                # Data models & settings
│   ├── settings/                 # Settings panel & configuration
│   │   ├── settings_panel.dart   # Main settings UI
│   │   ├── menu_button.dart      # Settings menu actions
│   │   └── widget_settings/      # Individual widget settings
│   ├── ui/                       # Reusable UI components
│   │   ├── custom_dropdown.dart  # Custom dropdown widget
│   │   ├── analog_clock.dart     # Analog clock widget
│   │   ├── digital_clock.dart    # Digital clock widget
│   │   └── message_banner/       # Message notification system
│   ├── utils/                    # Utility classes & services
│   │   ├── storage_manager.dart  # Local storage abstraction
│   │   ├── weather_service.dart  # Weather API integration
│   │   └── extensions.dart       # Dart extensions
│   ├── resources/                # App resources & constants
│   │   ├── colors.dart           # Color definitions
│   │   ├── fonts.dart            # Font configurations
│   │   └── storage_keys.dart     # Storage key constants
│   └── main.dart                 # Application entry point
├── server/                       # Dart backend server
│   ├── bin/server.dart          # Server entry point
│   ├── lib/unsplash.dart        # Unsplash API integration
│   └── pubspec.yaml             # Server dependencies
├── shared/                       # Shared code between client/server
│   └── lib/shared.dart          # Common models & utilities
├── web/                         # Chrome extension configuration
│   ├── manifest.json            # Extension manifest (MV3)
│   ├── background.js            # Service worker
│   ├── index.html               # Extension entry HTML
│   └── icons/                   # Extension icons
└── assets/                      # Static assets
    ├── fonts/                   # Custom fonts
    ├── images/                  # App images & icons
    └── translations/            # Localization files
```

## Features & Modules

### 1. Background Management (`background_store.dart`)
- **Dynamic Backgrounds**: Unsplash integration with collections, tags, and random images
- **Color & Gradient Modes**: Solid colors and gradient backgrounds
- **Auto-refresh**: Configurable background refresh intervals
- **Image Resolution**: Multiple resolution options for different screen sizes
- **Local Images**: Support for custom local background images

### 2. Widget System (`widget_store.dart`)
- **Digital Clock**: Customizable time display with multiple formats
- **Analog Clock**: Traditional clock face with styling options
- **Weather Widget**: Location-based weather with OpenMeteo API
- **Date Widget**: Configurable date formats and separators
- **Timer Widget**: Countdown/stopwatch functionality
- **Message Widget**: Custom text display with formatting

### 3. Settings Panel (`settings_panel.dart`)
- **Tabbed Interface**: Background, Widget, and About sections
- **Real-time Preview**: Changes apply immediately
- **Import/Export**: Settings backup and restore
- **Reset Functionality**: Factory reset options
- **Responsive Design**: Adapts to different screen sizes

### 4. State Management
- **MobX Stores**: Reactive state management with automatic UI updates
- **Dependency Injection**: GetIt service locator pattern
- **Persistent Storage**: Settings saved to local storage
- **Observer Pattern**: Efficient UI rebuilds with CustomObserver

### 5. Backend Services
- **REST API**: Shelf-based server for Unsplash integration
- **Local Development**: Configurable local server support
- **Production Deployment**: Cloud Run deployment ready
- **CORS Support**: Cross-origin requests for web deployment

## Entry Points & Data Flow

### Application Bootstrap (`main.dart`)
```dart
void main() async {
  // 1. Initialize Flutter binding
  final binding = WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Setup localization
  await EasyLocalization.ensureInitialized();
  
  // 3. Initialize services
  await initialize();
  
  // 4. Launch app with localization wrapper
  runApp(EasyLocalization(...));
}
```

### Service Initialization Flow
1. **Backend Service**: Initialize REST backend (local/production)
2. **Storage Manager**: Setup SharedPreferences wrapper
3. **Weather Service**: Initialize OpenMeteo weather API
4. **Geocoding Service**: Setup location services
5. **GetIt Registration**: Register all services for dependency injection

### State Management Architecture
```
HomeStore (Main App State)
├── BackgroundStore (Background Management)
├── WidgetStore (Widget Configuration)
│   ├── DigitalClockStore
│   ├── AnalogClockStore
│   ├── WeatherStore
│   └── TimerStore
└── MessageBannerController (Notifications)
```

### Data Flow Pattern
1. **User Interaction** → UI Component
2. **UI Component** → MobX Store Action
3. **Store Action** → Backend Service (if needed)
4. **Backend Service** → External API
5. **API Response** → Store State Update
6. **State Update** → UI Re-render (via Observer)

## Build Guide (Flutter Web)

### Prerequisites
```bash
# Install FVM (Flutter Version Management)
dart pub global activate fvm

# Install Flutter dependencies
fvm flutter pub get

# Generate code (MobX, JSON serialization)
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Development Build
```bash
# Local development with debug mode
fvm flutter run -d chrome --dart-define="SERVER=local" --dart-define="MODE=debug"

# Build for development
fvm flutter build web --csp --no-web-resources-cdn --dart-define="MODE=debug"
```

### Production Build
```bash
# Clean build
fvm flutter clean
fvm flutter pub get

# Production web build
fvm flutter build web --csp --no-web-resources-cdn --release

# Using scripts (recommended)
fvm flutter pub run scripts:build  # Development build
fvm flutter pub run scripts:pack   # Production package
```

### Build Configuration
- **CSP**: Content Security Policy compliance
- **No CDN**: Self-contained build without external dependencies
- **Environment Variables**: `SERVER=local|production`, `MODE=debug|release`

**Note**: The `--web-renderer` option has been deprecated in Flutter 3.8+. The default renderer is now used automatically.

## Extension Packaging (MV3)

### Manifest Configuration (`web/manifest.json`)
```json
{
  "manifest_version": 3,
  "name": "focus",
  "version": "0.7.0",
  "chrome_url_overrides": {
    "newtab": "index.html"
  },
  "background": {
    "service_worker": "background.js"
  },
  "content_security_policy": {
    "extension_pages": "script-src 'self' 'wasm-unsafe-eval'; object-src 'self';"
  }
}
```

### Extension Folder Structure
```
build/web/ (or build/extension/)
├── index.html              # Main extension page
├── main.dart.js            # Compiled Flutter app
├── manifest.json           # Extension manifest
├── background.js           # Service worker
├── icons/                  # Extension icons
│   ├── Icon-192.png
│   └── Icon-512.png
├── assets/                 # Flutter assets
└── canvaskit/              # CanvasKit renderer files
```

### Packaging Steps
1. **Build Flutter Web**: `fvm flutter build web --csp --no-web-resources-cdn --release`
2. **Copy Manifest**: Ensure `manifest.json` is in build output
3. **Verify Structure**: Check all required files are present
4. **Test Locally**: Load unpacked extension for testing
5. **Package for Store**: Create ZIP file for Chrome Web Store

### Build Script Integration
```bash
# Automated packaging (updated for Flutter 3.8+)
fvm flutter pub run scripts:build  # Creates build/extension/
fvm flutter pub run scripts:pack   # Creates focus.zip

# Manual packaging (Windows PowerShell)
fvm flutter build web --csp --no-web-resources-cdn --release
Compress-Archive -Path build/web/* -DestinationPath focus.zip -Force
```

## Chrome Load Guide

### Method 1: Using Existing Extension Folder (Recommended)
1. **Open Chrome Extensions**:
   - Navigate to `chrome://extensions/`
   - Enable "Developer mode" (top-right toggle)

2. **Load Extension**:
   - Click "Load unpacked"
   - Select the `d:\vscode\focus\extension` folder
   - Extension should appear in the list with "Focus - News Feed Eradicator" name

### Method 2: Using Fresh Build
1. **Build the Extension**:
   ```bash
   fvm flutter build web --csp --no-web-resources-cdn --release
   ```

2. **Prepare Extension Folder**:
   - Copy `manifest.json` from `extension/` to `build/web/`
   - Copy `icons/` folder from `extension/` to `build/web/`
   - Copy any additional extension files as needed

3. **Load Extension**:
   - Navigate to `chrome://extensions/`
   - Enable "Developer mode"
   - Click "Load unpacked"
   - Select the `build/web/` folder

### Method 3: Using ZIP Package
1. **Create Package**:
   ```bash
   # Build and package
   fvm flutter build web --csp --no-web-resources-cdn --release
   Compress-Archive -Path build/web/* -DestinationPath focus.zip -Force
   ```

2. **Install from ZIP**:
   - Extract `focus.zip` to a folder
   - Copy extension files (manifest.json, icons) to extracted folder
   - Load unpacked extension from the combined folder

### Verification Steps
1. **Test New Tab**:
   - Open a new tab
   - Focus extension should load as the new tab page
   - Verify all widgets and settings work correctly

2. **Check Extension Status**:
   - Extension should show as "Enabled" in chrome://extensions/
   - No error messages should appear
   - Extension icon should be visible

3. **Debug Issues**:
   - Open Developer Tools (F12) on new tab
   - Check Console for JavaScript errors
   - Verify network requests to backend services

### Extension Permissions
The extension requires minimal permissions:
- **New Tab Override**: Replace default new tab page
- **Storage**: Save user settings locally
- **Network Access**: Fetch background images and weather data
- **Host Permissions**: Access to social media sites for content cleaning

### Development Workflow
1. **Make Code Changes**: Edit Flutter source files
2. **Rebuild**: Run `fvm flutter build web --csp --no-web-resources-cdn`
3. **Reload Extension**: Click reload button in chrome://extensions/
4. **Test**: Open new tab to verify changes

**Note**: For development, use Method 1 with the existing extension folder for fastest iteration.

## Troubleshooting / TODO

### Common Issues

#### 1. Build Failures
**Problem**: Flutter build fails with dependency errors
**Solution**:
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Extension Not Loading
**Problem**: Chrome extension fails to load
**Solutions**:
- Verify `manifest.json` is valid JSON
- Check file paths in manifest match build output
- Ensure all required files are present in build folder
- Check Chrome Developer Console for errors

#### 3. Backend Connection Issues
**Problem**: Cannot fetch backgrounds or weather data
**Solutions**:
- Verify server is running (for local development)
- Check CORS configuration in server
- Validate API keys (Unsplash, weather services)
- Check network connectivity and firewall settings

#### 4. State Management Issues
**Problem**: UI not updating when data changes
**Solutions**:
- Ensure MobX observers are properly wrapped
- Check store actions are marked with `@action`
- Verify computed values use `@computed`
- Run code generation: `build_runner build`

### Performance Optimizations
- **Lazy Loading**: Widgets load only when needed
- **Image Caching**: Background images cached locally
- **Debounced Updates**: Settings changes debounced to prevent excessive saves
- **Memory Management**: Proper disposal of controllers and streams

### Future Improvements (TODO)
1. **Enhanced Widgets**:
   - Calendar widget with events
   - News feed integration
   - Bookmark quick access
   - Search widget with multiple providers

2. **Customization**:
   - Theme system with multiple color schemes
   - Layout customization (drag & drop widgets)
   - Custom CSS injection support
   - Widget size and position controls

3. **Performance**:
   - Service worker optimization
   - Background image preloading
   - Offline mode support
   - Reduced bundle size

4. **Features**:
   - Sync settings across devices
   - Widget marketplace
   - Advanced weather forecasts
   - Integration with productivity tools

5. **Developer Experience**:
   - Hot reload for extension development
   - Better error handling and logging
   - Automated testing setup
   - CI/CD pipeline for releases

### Development Notes
- **FVM Usage**: Always use `fvm` prefix for Flutter/Dart commands
- **Code Generation**: Run `build_runner` after modifying MobX stores or JSON models
- **Localization**: Add new translations to `assets/translations/`
- **Testing**: Run `fvm flutter analyze` before committing changes
- **Version Management**: Update version in `pubspec.yaml` and `web/manifest.json`

---

*This documentation covers the Focus Flutter Chrome Extension project structure, build process, and deployment workflow. For specific implementation details, refer to the source code and inline documentation.*