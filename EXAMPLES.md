# Flutter-TS Communication Examples

This document provides examples of how the Flutter UI communicates with the TypeScript/JavaScript extension logic in the unified Focus extension.

## 1. Flutter UI Reading Settings from Chrome Storage

```dart
// In social_cleaner_store.dart
Future<Map<String, dynamic>?> _getChromeStorageLocal(String key) async {
  try {
    final completer = Completer<Map<String, dynamic>?>();
    
    html.window.callMethod('chrome.storage.local.get', [
      [key].toJS,
      ((JSObject result) {
        try {
          final Map<String, dynamic> data = dartify(result) as Map<String, dynamic>;
          completer.complete(data[key] as Map<String, dynamic>?);
        } catch (e) {
          completer.complete(null);
        }
      }).toJS,
    ]);
    
    return await completer.future;
  } catch (e) {
    log('Error getting Chrome storage: $e');
    return null;
  }
}

// Usage in Flutter
@action
Future<void> loadSettings() async {
  try {
    if (kIsWeb && _isChromeExtension()) {
      final result = await _getChromeStorageLocal('socialCleanerSettings');
      if (result != null) {
        _updateFromJson(result);
      }
    }
  } catch (e) {
    log('Error loading settings: $e');
  }
}
```

## 2. Flutter UI Writing Settings to Chrome Storage

```dart
// In social_cleaner_store.dart
Future<void> _setChromeStorageLocal(String key, Map<String, dynamic> value) async {
  try {
    final completer = Completer<void>();
    
    html.window.callMethod('chrome.storage.local.set', [
      {key: value}.jsify(),
      (() {
        completer.complete();
      }).toJS,
    ]);
    
    await completer.future;
  } catch (e) {
    log('Error setting Chrome storage: $e');
  }
}

// Usage when settings change
@action
void setEnabled(bool value) {
  enabled = value;
  _saveSettings(); // This calls _setChromeStorageLocal internally
}
```

## 3. Flutter UI Sending Messages to Background Script

```dart
// In social_cleaner_store.dart
void _sendChromeMessage(Map<String, dynamic> message) {
  try {
    html.window.callMethod('chrome.runtime.sendMessage', [
      message.jsify(),
      ((JSObject? response) {
        // Handle response if needed
        if (response != null) {
          final responseData = dartify(response);
          log('Background script response: $responseData');
        }
      }).toJS,
    ]);
  } catch (e) {
    log('Error sending Chrome message: $e');
  }
}

// Example usage
Future<void> _saveSettings() async {
  final settings = _toJson();
  await _setChromeStorageLocal('socialCleanerSettings', settings);
  
  // Notify background script of changes
  _sendChromeMessage({
    'action': 'updateSocialCleanerSettings',
    'settings': settings,
  });
}
```

## 4. Background Script Handling Messages from Flutter

```javascript
// In background.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  switch (request.action) {
    case 'updateSocialCleanerSettings':
      chrome.storage.local.set({ socialCleanerSettings: request.settings }, () => {
        // Notify all content scripts about settings update
        chrome.tabs.query({}, (tabs) => {
          tabs.forEach(tab => {
            chrome.tabs.sendMessage(tab.id, {
              action: 'settingsUpdated',
              settings: request.settings
            }).catch(() => {
              // Ignore errors for tabs that don't have content scripts
            });
          });
        });
        sendResponse({ success: true });
      });
      return true;
      
    case 'getSocialCleanerSettings':
      chrome.storage.local.get(['socialCleanerSettings'], (result) => {
        sendResponse(result.socialCleanerSettings || defaultSettings);
      });
      return true;
  }
});
```

## 5. Content Script Reading Settings from Storage

```javascript
// In content_unified.js
let currentSettings = {
  enabled: true,
  showQuotes: true,
  builtinQuotesEnabled: true,
  customQuotes: [],
  sites: {}
};

// Load settings from background script
function loadSettings() {
  chrome.runtime.sendMessage({ action: 'getSocialCleanerSettings' }, (response) => {
    if (response) {
      currentSettings = { ...currentSettings, ...response };
      eradicate(); // Apply settings
    }
  });
}

// Listen for settings updates from Flutter UI
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'settingsUpdated') {
    currentSettings = { ...currentSettings, ...request.settings };
    eradicate(); // Re-apply with new settings
    sendResponse({ success: true });
  }
});
```

## 6. Settings Data Structure

```javascript
// Default settings structure used across all components
const defaultSettings = {
  enabled: true,
  showQuotes: true,
  builtinQuotesEnabled: true,
  customQuotes: [],
  sites: {
    facebook: { enabled: true },
    instagram: { enabled: true },
    twitter: { enabled: true },
    reddit: { enabled: true },
    linkedin: { enabled: true },
    youtube: { enabled: true },
    github: { enabled: true },
    hackernews: { enabled: true }
  }
};
```

## 7. Flutter Widget Example

```dart
// Example of using the social cleaner store in a Flutter widget
class SocialCleanerToggle extends StatelessWidget {
  const SocialCleanerToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SocialCleanerStore();
    
    return CustomObserver(
      name: 'SocialCleanerToggle',
      builder: (context) {
        return CustomSwitch(
          value: store.enabled,
          onChanged: (value) {
            // This will automatically save to Chrome storage
            // and notify the background script
            store.setEnabled(value);
          },
          label: 'Enable Social Feed Cleaner',
        );
      },
    );
  }
}
```

## 8. Error Handling

```dart
// Robust error handling for Chrome API calls
bool _isChromeExtension() {
  try {
    return html.window.hasProperty('chrome') && 
           html.window.hasProperty('chrome.storage') &&
           html.window.hasProperty('chrome.runtime');
  } catch (e) {
    return false;
  }
}

// Fallback for non-extension environments
@action
Future<void> loadSettings() async {
  try {
    if (kIsWeb && _isChromeExtension()) {
      // Load from Chrome storage
      final result = await _getChromeStorageLocal('socialCleanerSettings');
      if (result != null) {
        _updateFromJson(result);
      } else {
        await _setDefaultSettings();
      }
    } else {
      // Fallback for development/testing
      _setDefaultValues();
    }
  } catch (e) {
    log('Error loading social cleaner settings: $e');
    _setDefaultValues();
  }
}
```

## 9. Testing Communication

```dart
// Test function to verify Chrome API communication
Future<void> testChromeAPIs() async {
  if (!_isChromeExtension()) {
    log('Not running in Chrome extension context');
    return;
  }
  
  // Test storage
  await _setChromeStorageLocal('test', {'value': 'hello'});
  final result = await _getChromeStorageLocal('test');
  log('Storage test result: $result');
  
  // Test messaging
  _sendChromeMessage({
    'action': 'test',
    'data': 'Hello from Flutter!'
  });
}
```

## Key Points

1. **Asynchronous Communication**: All Chrome API calls are asynchronous and use Futures/Completers in Dart.

2. **Type Safety**: Use `dartify()` and `jsify()` helpers to convert between Dart and JavaScript objects safely.

3. **Error Handling**: Always wrap Chrome API calls in try-catch blocks and provide fallbacks.

4. **Real-time Updates**: Changes in Flutter UI immediately propagate to content scripts via the background script.

5. **Storage Persistence**: Settings are automatically persisted in Chrome's local storage and survive browser restarts.

6. **Cross-tab Synchronization**: Settings changes are automatically synchronized across all open tabs with the extension.