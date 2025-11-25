// Background script for Focus extension
// Handles communication between Flutter UI and content scripts

console.log('Focus extension background script loaded');

const OPTIONAL_ORIGINS = [
  'https://www.facebook.com/*',
  'https://web.facebook.com/*',
  'https://www.instagram.com/*',
  'https://www.threads.net/*',
  'https://www.threads.com/*',
  'https://www.tiktok.com/*',
  'https://twitter.com/*',
  'https://x.com/*',
  'https://www.reddit.com/*',
  'https://old.reddit.com/*',
  'https://www.linkedin.com/*',
  'https://www.youtube.com/*',
  'https://github.com/*',
  'https://shopee.vn/*',
  'https://shopee.com/*',
];

function originsFromRequest(req) {
  const arr = Array.isArray(req?.origins) ? req.origins : OPTIONAL_ORIGINS;
  return arr;
}

function urlMatchesAnyOrigin(url, origins) {
  if (!url) return false;
  try {
    const u = new URL(url);
    const originStr = `${u.protocol}//${u.host}`;
    return origins.some((o) => {
      const base = o.replace('/*', '');
      return originStr.startsWith(base);
    });
  } catch (_) {
    return false;
  }
}

async function registerSocialCleanerContentScript() {
  try {
    await chrome.scripting.unregisterContentScripts({ ids: ['focus-social-cleaner'] }).catch(() => {});
    await chrome.scripting.registerContentScripts([
      {
        id: 'focus-social-cleaner',
        js: ['social_cleaner/content_unified.js'],
        matches: OPTIONAL_ORIGINS,
        runAt: 'document_start',
        allFrames: false,
      },
    ]);
    console.log('Registered social cleaner content script');
  } catch (e) {
    console.warn('Failed to register content script', e);
  }
}

// Default settings
const defaultSettings = {
  enabled: true,
  showQuotes: true,
  builtinQuotesEnabled: true,
  customQuotes: [],
  sites: {
    facebook: { enabled: true },
    instagram: { enabled: true },
    tiktok: { enabled: true },
    twitter: { enabled: true },
    threads: { enabled: true },
    reddit: { enabled: true },
    linkedin: { enabled: true },
    youtube: { enabled: false },
    github: { enabled: false },
    shopee: { enabled: true }
  }
};

// Load settings from chrome.storage.local (canonical store)
async function loadSettings() {
  try {
    const result = await chrome.storage.local.get('socialCleanerSettings');
    if (result && result.socialCleanerSettings) {
      return result.socialCleanerSettings;
    }
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
      tiktok: { enabled: true },
      twitter: { enabled: true },
      threads: { enabled: true },
      reddit: { enabled: true },
      linkedin: { enabled: true },
      youtube: { enabled: false },
      github: { enabled: false },
      shopee: { enabled: true }
    }
  };
}

// Save settings to storage (save to both Chrome storage and localStorage for Flutter compatibility)
async function saveSettings(settings) {
  try {
    // Save to Chrome storage
    await chrome.storage.local.set({ socialCleanerSettings: settings });
    console.log('Settings saved to Chrome storage');
    
    // Do not use window.localStorage in MV3 service workers
    
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
        builtinQuotesLang: request.settings.builtinQuotesLang || 'en',
        builtinQuotesEn: request.settings.builtinQuotesEn || [],
        builtinQuotesVi: request.settings.builtinQuotesVi || [],
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
    
    case 'scheduleSiteLock': {
      const siteId = request.siteId;
      const minutes = Number(request.minutes || 0);
      loadSettings().then((settings) => {
        settings.sites = settings.sites || {};
        settings.sites[siteId] = { enabled: false };
        saveSettings(settings).then(() => {
          if (minutes > 0) {
            chrome.alarms.create(`lock:${siteId}`, { delayInMinutes: Math.max(0.1, minutes) });
          }
          sendResponse({ success: true });
        });
      });
      return true; // Keep message channel open for async response
    }
    case 'todoScheduleReminder': {
      const minutes = Number(request.minutes || 0);
      const title = String(request.title || 'Todo Reminder');
      chrome.storage.local.set({ todoReminderTitle: title }).then(() => {
        chrome.alarms.create('todo:reminder', { delayInMinutes: Math.max(0.1, minutes) });
        sendResponse({ success: true });
      });
      return true;
    }
    case 'checkOptionalPermissions': {
      const origins = originsFromRequest(request);
      chrome.permissions.contains({ origins }).then((granted) => {
        sendResponse({ granted: Boolean(granted) });
      });
      return true;
    }
    case 'requestOptionalPermissions': {
      const origins = originsFromRequest(request);
      chrome.permissions.request({ origins }).then((granted) => {
        sendResponse({ granted: Boolean(granted) });
        if (granted) {
          registerSocialCleanerContentScript();
          chrome.tabs.query({}).then((tabs) => {
            tabs.forEach((tab) => {
              if (urlMatchesAnyOrigin(tab.url, origins)) {
                try {
                  chrome.scripting.executeScript({
                    target: { tabId: tab.id },
                    files: ['social_cleaner/content_unified.js'],
                  });
                } catch (_) {}
              }
            });
          });
        }
      });
      return true;
    }
      
    default:
      console.log('Unknown action:', request.action);
      sendResponse({ error: 'Unknown action' });
  }
});

// Re-lock site when alarm fires
chrome.alarms.onAlarm.addListener((alarm) => {
  if (!alarm || !alarm.name || !alarm.name.startsWith('lock:')) return;
  const siteId = alarm.name.replace('lock:', '');
  loadSettings().then((settings) => {
    settings.sites = settings.sites || {};
    const site = settings.sites[siteId] || { enabled: true };
    site.enabled = true;
    settings.sites[siteId] = site;
    saveSettings(settings);
  });
});

chrome.alarms.onAlarm.addListener((alarm) => {
  if (!alarm || !alarm.name || alarm.name !== 'todo:reminder') return;
  chrome.storage.local.get('todoReminderTitle').then((result) => {
    const title = result.todoReminderTitle || 'Todo Reminder';
    try {
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/128.png',
        title: title,
        message: 'It\'s time to do your task.'
      });
    } catch (error) {
      console.error('Failed to create notification', error);
    }
  });
});


chrome.permissions.onAdded.addListener((perms) => {
  const origins = perms?.origins || [];
  if (!origins || origins.length === 0) return;
  registerSocialCleanerContentScript();
  chrome.tabs.query({}).then((tabs) => {
    tabs.forEach((tab) => {
      if (urlMatchesAnyOrigin(tab.url, origins)) {
        try {
          chrome.scripting.executeScript({
            target: { tabId: tab.id },
            files: ['social_cleaner/content_unified.js'],
          });
        } catch (_) {}
      }
    });
  });
});



// Initialize extension
chrome.runtime.onInstalled.addListener(() => {
  console.log('Focus extension installed');
  registerSocialCleanerContentScript();
  
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

chrome.runtime.onStartup.addListener(() => {
  registerSocialCleanerContentScript();
});