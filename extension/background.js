// Background script for Focus extension
// Handles communication between Flutter UI and content scripts

console.log('Focus extension background script loaded');

// Default settings
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

// Load settings from LocalStorageManager (same pattern as widgets)
async function loadSettings() {
  try {
    // Try to get settings from localStorage using the same key as Flutter
    const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
    if (tabs.length > 0) {
      try {
        // Ask content script to get settings from LocalStorageManager
        const response = await chrome.tabs.sendMessage(tabs[0].id, {
          action: 'getLocalStorageSettings',
          key: 'socialCleanerSettings'
        });
        
        if (response && response.settings) {
          console.log('Loaded settings from LocalStorageManager:', response.settings);
          return convertFlutterToBackgroundFormat(response.settings);
        }
      } catch (error) {
        console.log('Could not get settings from content script, trying Chrome storage fallback');
      }
    }

    // Fallback: try Chrome storage for backward compatibility
    const result = await chrome.storage.local.get('socialCleanerSettings');
    if (result.socialCleanerSettings) {
      console.log('Loaded settings from Chrome storage (fallback):', result.socialCleanerSettings);
      return result.socialCleanerSettings;
    }

    // If no settings found anywhere, return defaults
    console.log('No settings found, using defaults');
    return defaultSettings;
  } catch (error) {
    console.error('Error loading settings:', error);
    return defaultSettings;
  }
}

// Convert Flutter settings format to background script format
function convertFlutterToBackgroundFormat(flutterSettings) {
  return {
    enabled: flutterSettings.enabled ?? true,
    showQuotes: flutterSettings.showQuotes ?? true,
    builtinQuotesEnabled: flutterSettings.builtinQuotesEnabled ?? true,
    customQuotes: flutterSettings.customQuotes || [],
    sites: flutterSettings.sites || {
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
}

// Save settings to storage (save to both Chrome storage and localStorage for Flutter compatibility)
async function saveSettings(settings) {
  try {
    // Save to Chrome storage
    await chrome.storage.local.set({ socialCleanerSettings: settings });
    console.log('Settings saved to Chrome storage');
    
    // Also save to localStorage for Flutter SharedPreferences compatibility
    try {
      const localStorageKey = 'flutter.social_cleaner_settings';
      localStorage.setItem(localStorageKey, JSON.stringify(settings));
      console.log('Settings also saved to localStorage for Flutter compatibility');
    } catch (localStorageError) {
      console.warn('Could not save to localStorage:', localStorageError);
    }
    
    // Notify all content scripts about settings update
    const tabs = await chrome.tabs.query({});
    for (const tab of tabs) {
      try {
        await chrome.tabs.sendMessage(tab.id, {
          action: 'settingsUpdated',
          settings: settings
        });
      } catch (error) {
        // Tab might not have content script, ignore
      }
    }
  } catch (error) {
    console.error('Error saving settings:', error);
  }
}

// Handle messages from content scripts and Flutter UI
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('Background received message:', request);
  
  switch (request.action) {
    case 'getSocialCleanerSettings':
      loadSettings().then(settings => {
        console.log('Sending settings to content script:', settings);
        sendResponse(settings);
      });
      return true; // Keep message channel open for async response
      
    case 'updateSocialCleanerSettings':
      console.log('Updating settings from Flutter:', request.settings);
      // Convert Flutter format to content script format
      const convertedSettings = {
        enabled: request.settings.enabled,
        showQuotes: request.settings.showQuotes,
        builtinQuotesEnabled: request.settings.builtinQuotesEnabled,
        customQuotes: request.settings.customQuotes || [],
        sites: {}
      };
      
      // Convert site settings from Flutter format to content script format
      if (request.settings.sites) {
        for (const [siteId, siteData] of Object.entries(request.settings.sites)) {
          convertedSettings.sites[siteId] = { enabled: siteData.enabled };
        }
      }
      
      saveSettings(convertedSettings).then(() => {
        console.log('Settings saved successfully');
        sendResponse({ success: true });
      });
      return true; // Keep message channel open for async response
      
    default:
      console.log('Unknown action:', request.action);
      sendResponse({ error: 'Unknown action' });
  }
});

// Initialize extension
chrome.runtime.onInstalled.addListener(() => {
  console.log('Focus extension installed');
  
  // Only set default settings if none exist
  chrome.storage.local.get('socialCleanerSettings').then(result => {
    if (!result.socialCleanerSettings) {
      console.log('No existing settings found, setting defaults');
      saveSettings(defaultSettings);
    } else {
      console.log('Existing settings found, keeping them');
    }
  });
});