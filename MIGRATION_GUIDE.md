# Migration Guide: Unifying Chrome Extensions

This guide explains how to migrate from separate Flutter and TS/JS Chrome extensions to a unified extension where Flutter provides the UI and TS/JS handles the background logic.

## Overview

**Before**: Two separate extensions
- Flutter extension: New Tab UI with settings
- TS/JS extension: Social feed cleaner with its own popup/options UI

**After**: One unified extension
- Flutter UI: Single interface for all features including social cleaner settings
- TS/JS logic: Background/content scripts without UI components

## Files to Remove from TS/JS Extension

### 1. UI-Related Files (DELETE THESE)

```
social_cleaner/
├── popup.html          ❌ DELETE - UI handled by Flutter
├── popup.js            ❌ DELETE - UI logic moved to Flutter
├── popup.css           ❌ DELETE - Styling handled by Flutter
├── options.html        ❌ DELETE - Settings UI moved to Flutter
├── options.js          ❌ DELETE - Settings logic moved to Flutter
├── options.css         ❌ DELETE - Styling handled by Flutter
├── ui/                 ❌ DELETE - Entire UI directory
│   ├── components/     ❌ DELETE
│   ├── styles/         ❌ DELETE
│   └── templates/      ❌ DELETE
└── assets/             ❌ DELETE - UI assets moved to Flutter
    ├── icons/          ❌ DELETE (unless used by content script)
    └── images/         ❌ DELETE
```

### 2. Manifest Entries to Remove

```json
// OLD manifest.json entries to REMOVE:
{
  "action": {
    "default_popup": "popup.html"  // ❌ REMOVE
  },
  "options_page": "options.html",  // ❌ REMOVE
  "options_ui": {                  // ❌ REMOVE
    "page": "options.html",
    "open_in_tab": false
  }
}
```

### 3. Background Script UI Code to Remove

```javascript
// In background.js - REMOVE these UI-related sections:

// ❌ REMOVE: Popup/options page message handlers
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  switch (request.action) {
    case 'openOptionsPage':     // ❌ REMOVE
    case 'showPopup':          // ❌ REMOVE  
    case 'hidePopup':          // ❌ REMOVE
    case 'UI_OPTIONS_SHOW':    // ❌ REMOVE
    // ... other UI-related cases
  }
});

// ❌ REMOVE: UI state management
let popupState = { ... };
let optionsPageState = { ... };

// ❌ REMOVE: UI-related storage keys
const UI_STORAGE_KEYS = ['popupSettings', 'uiState', ...];
```

## Files to Keep and Modify

### 1. Keep Core Logic Files (MODIFY THESE)

```
social_cleaner/
├── content.js          ✅ KEEP → Refactor to content_unified.js
├── background.js       ✅ KEEP → Update for Flutter communication
├── manifest.json       ✅ KEEP → Update for unified extension
└── quotes.js           ✅ KEEP → Core functionality
```

### 2. Content Script Refactoring

**Before** (`content.js`):
```javascript
// ❌ REMOVE: UI creation and management
function createUI() { ... }
function showOptionsDialog() { ... }
function updateUIState() { ... }

// ❌ REMOVE: UI event listeners
document.addEventListener('click', handleUIClick);
chrome.runtime.onMessage.addListener((request) => {
  if (request.action === 'UI_OPTIONS_SHOW') { ... }
});
```

**After** (`content_unified.js`):
```javascript
// ✅ KEEP: Core functionality only
function eradicate() { ... }
function injectQuote() { ... }
function detectSite() { ... }

// ✅ KEEP: Settings-driven logic
chrome.runtime.onMessage.addListener((request) => {
  if (request.action === 'settingsUpdated') {
    currentSettings = request.settings;
    eradicate(); // Re-apply with new settings
  }
});
```

### 3. Background Script Updates

**Remove UI handlers**:
```javascript
// ❌ REMOVE: UI-specific message handlers
case 'UI_OPTIONS_SHOW':
case 'openPopup':
case 'closePopup':
```

**Add Flutter communication**:
```javascript
// ✅ ADD: Flutter UI communication
case 'updateSocialCleanerSettings':
  chrome.storage.local.set({ socialCleanerSettings: request.settings });
  // Notify all content scripts
  chrome.tabs.query({}, (tabs) => {
    tabs.forEach(tab => {
      chrome.tabs.sendMessage(tab.id, {
        action: 'settingsUpdated',
        settings: request.settings
      });
    });
  });
  break;
```

## Flutter UI Integration

### 1. Add Social Cleaner Settings

**New Files to Create**:
```
lib/
├── settings/
│   └── social_cleaner_settings.dart    ✅ NEW - Settings UI
└── utils/
    └── social_cleaner_store.dart        ✅ NEW - Settings store
```

### 2. Update Existing Flutter Files

**Modify**:
```
lib/
├── settings/
│   └── settings_panel.dart              ✅ MODIFY - Add new tab
└── home/
    └── home_store.dart                  ✅ MODIFY - Update tab count
```

## Migration Steps

### Step 1: Backup Current Extensions
```bash
# Create backup of both extensions
cp -r flutter_extension flutter_extension_backup
cp -r social_cleaner_extension social_cleaner_backup
```

### Step 2: Update Manifest
```json
{
  "manifest_version": 3,
  "name": "Focus - Unified Extension",
  "version": "2.0.0",
  
  // ✅ Flutter UI as main interface
  "chrome_url_overrides": {
    "newtab": "index.html"
  },
  
  // ✅ TS/JS logic only (no UI)
  "content_scripts": [{
    "matches": ["*://*.facebook.com/*", "*://*.instagram.com/*"],
    "js": ["social_cleaner/content_unified.js"]
  }],
  
  "background": {
    "service_worker": "background.js"
  },
  
  // ❌ REMOVE: No popup or options page
  // "action": { "default_popup": "popup.html" },
  // "options_page": "options.html"
}
```

### Step 3: Refactor TS/JS Code
1. Create `content_unified.js` with only core logic
2. Update `background.js` for Flutter communication
3. Remove all UI-related files and code

### Step 4: Extend Flutter UI
1. Add `SocialCleanerSettings` widget
2. Add `SocialCleanerStore` for state management
3. Update `SettingsPanel` to include new tab
4. Implement Chrome API communication

### Step 5: Test Integration
```bash
# Build Flutter web
cd flutter_extension
flutter build web

# Load extension in Chrome
# 1. Open chrome://extensions/
# 2. Enable Developer mode
# 3. Click "Load unpacked"
# 4. Select the unified extension directory
```

## Verification Checklist

### ✅ UI Verification
- [ ] New tab opens with Flutter UI
- [ ] Social cleaner settings tab appears in settings panel
- [ ] All social cleaner options are configurable
- [ ] No TS/JS popup or options page appears

### ✅ Functionality Verification
- [ ] Social feeds are removed when enabled
- [ ] Quotes appear when enabled
- [ ] Site-specific toggles work correctly
- [ ] Settings persist across browser restarts
- [ ] Settings sync across all open tabs

### ✅ Communication Verification
- [ ] Flutter UI changes immediately affect content scripts
- [ ] Settings are saved to Chrome storage
- [ ] Background script receives Flutter messages
- [ ] Content scripts receive settings updates

## Troubleshooting

### Common Issues

**1. Chrome APIs not available in Flutter**
```dart
// Solution: Check extension context
bool _isChromeExtension() {
  try {
    return html.window.hasProperty('chrome') && 
           html.window.hasProperty('chrome.storage');
  } catch (e) {
    return false;
  }
}
```

**2. Settings not persisting**
```javascript
// Solution: Ensure proper storage key usage
const STORAGE_KEY = 'socialCleanerSettings';
chrome.storage.local.set({ [STORAGE_KEY]: settings });
```

**3. Content script not receiving updates**
```javascript
// Solution: Check tab permissions and error handling
chrome.tabs.sendMessage(tab.id, message).catch(() => {
  // Ignore errors for tabs without content scripts
});
```

**4. MobX store not updating UI**
```bash
# Solution: Regenerate MobX files
dart run build_runner build --delete-conflicting-outputs
```

## Performance Considerations

### Before Migration
- Two separate extensions consuming resources
- Duplicate settings storage
- Multiple UI contexts

### After Migration
- Single extension with unified storage
- Shared background script
- Single UI context (Flutter)
- Reduced memory footprint

## Security Considerations

### Removed Attack Vectors
- No TS/JS popup UI (reduces XSS risk)
- No options page (reduces injection points)
- Centralized settings validation in Flutter

### Maintained Security
- Content Security Policy still applies
- Chrome storage API permissions unchanged
- Message passing validation required

## Rollback Plan

If issues occur, you can rollback by:

1. **Restore original extensions**:
   ```bash
   cp -r flutter_extension_backup flutter_extension
   cp -r social_cleaner_backup social_cleaner_extension
   ```

2. **Load original manifests** in Chrome extensions page

3. **Disable unified extension** and re-enable separate ones

## Support

For issues during migration:

1. Check browser console for JavaScript errors
2. Verify Chrome extension permissions
3. Test in incognito mode to rule out conflicts
4. Use Chrome DevTools to debug message passing
5. Check `chrome://extensions/` for error messages

## Next Steps

After successful migration:

1. **Test thoroughly** across different websites
2. **Update documentation** for the unified extension
3. **Consider additional features** now possible with unified architecture
4. **Plan for future updates** using the new structure