// Unified content script for Focus extension
// Removes social media feeds and injects quotes based on settings from Flutter UI

(function() {
  'use strict';

  // Settings management
  let currentSettings = {
    enabled: true,
    showQuotes: true,
    builtinQuotesEnabled: true,
    customQuotes: [],
    sites: {}
  };

  // Built-in quotes (subset for performance)
  const builtinQuotes = [
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Your limitation—it's only your imagination.",
    "Push yourself, because no one else is going to do it for you.",
    "Great things never come from comfort zones.",
    "Dream it. Wish it. Do it.",
    "Success doesn't just find you. You have to go out and get it.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Dream bigger. Do bigger.",
    "Don't stop when you're tired. Stop when you're done.",
    "Wake up with determination. Go to bed with satisfaction.",
    "Do something today that your future self will thank you for.",
    "Little things make big days.",
    "It's going to be hard, but hard does not mean impossible.",
    "Don't wait for opportunity. Create it.",
    "Sometimes we're tested not to show our weaknesses, but to discover our strengths.",
    "The key to success is to focus on goals, not obstacles.",
    "Dream it. Believe it. Build it."
  ];

  // Site configurations
  const sites = {
    facebook: {
      name: 'Facebook',
      selectors: [
        'div[role="feed"]',
        '#ssrb_feed_start + div',
        '[data-pagelet=MainFeed]',
        'div[aria-label=Gaming][role=main]',
        'div.x1hc1fzr.x1unhpq9.x6o7n8i'
      ],
      css: `
        html[data-nfe-enabled='true'] [data-pagelet="MainFeed"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] #ssrb_feed_start + div > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div[role="feed"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div.x1hc1fzr.x1unhpq9.x6o7n8i > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] [data-pagelet="Reels"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div[aria-label="Reels"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div[role="main"] > :not(#nfe-container) {
          display: none !important;
        }
      `
    },
    instagram: {
      name: 'Instagram',
      selectors: ['main'],
      css: `
        html:not([data-nfe-enabled='false']) main > :not(#nfe-container) {
          display: none !important;
        }
        html:not([data-nfe-enabled='false']) main > #nfe-container {
          width: 100% !important;
          font-size: 24px !important;
          padding: 128px !important;
        }
        html[data-nfe-enabled='true'] section > :not(#nfe-container) {
          display: none !important;
        }
      `
    },
    twitter: {
      name: 'Twitter/X',
      selectors: [
        'div[data-testid="primaryColumn"]',
        'div[aria-label*="Timeline"]'
      ],
      css: `
        html:not([data-nfe-enabled='false']) div[aria-label*="Timeline"] > :not(#nfe-container) {
          display: none !important;
        }
        html:not([data-nfe-enabled='false']) div[data-testid="primaryColumn"] > div:last-child > div:nth-child(4) > :not(#nfe-container) {
          display: none !important;
        }
        html:not([data-nfe-enabled='false']) div[data-testid="primaryColumn"] > div:last-child > div:last-child {
          opacity: 0 !important;
          pointer-events: none !important;
        }
        [data-testid='sidebarColumn'] [role='region'] {
          opacity: 0 !important;
          pointer-events: none !important;
          height: 0 !important;
        }
      `
    },
    reddit: {
      name: 'Reddit',
      selectors: [
        'div[data-testid="subreddit-posts"]',
        '.Post',
        'div[data-click-id="body"]'
      ],
      css: `
        html[data-nfe-enabled='true'] div[data-testid="subreddit-posts"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] .ListingLayout-outerContainer .Post {
          display: none !important;
        }
        html[data-nfe-enabled='true'] [data-testid="post-container"] {
          display: none !important;
        }
      `
    },
    linkedin: {
      name: 'LinkedIn',
      selectors: ['.scaffold-finite-scroll'],
      css: `
        html:not([data-nfe-enabled='false']) .scaffold-finite-scroll > div:not(#nfe-container) {
          opacity: 0 !important;
          pointer-events: none !important;
          height: 0 !important;
        }
        aside.scaffold-layout__aside > div:nth-child(2) {
          opacity: 0 !important;
          pointer-events: none !important;
          height: 0 !important;
        }
      `
    },
    youtube: {
      name: 'YouTube',
      selectors: ['#contents.ytd-rich-grid-renderer'],
      css: `
        html:not([data-nfe-enabled='false']) #contents.ytd-rich-grid-renderer > :not(#nfe-container) {
          display: none !important;
        }
      `
    },
    github: {
      name: 'GitHub',
      selectors: [
        'aside[aria-label="Account"] + div',
        '.js-recent-activity-container'
      ],
      css: `
        html[data-nfe-enabled='true'] .js-recent-activity-container > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div div[role='contentinfo'],
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div aside[aria-label='Explore'] {
          opacity: 0 !important;
          pointer-events: none !important;
          height: 0 !important;
          overflow-y: hidden !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div #dashboard-feed-frame {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div #dashboard-feed {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div [data-target="dashboard.feedContainer"] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div [data-repository-hovercards-enabled] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div [data-hpc] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div aside[aria-label='Explore'] {
          width: 0 !important;
        }
        html[data-nfe-enabled='true'] aside[aria-label='Account'] + div > [class*='d-'][class*='-flex'] > :first-child {
          width: 100% !important;
        }
      `
    },
    tiktok: {
      name: 'TikTok',
      selectors: [
        'div[data-e2e="recommend-list"]',
        'div[data-e2e="video-feed"]',
        'div[data-e2e="scroll-list"]',
        'main'
      ],
      css: `
        html[data-nfe-enabled='true'] div[data-e2e="recommend-list"] > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] div[data-e2e="video-feed"] > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] div[data-e2e="scroll-list"] > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] main > :not(#nfe-container) { display: none !important; }
      `
    },
    shopee: {
      name: 'Shopee',
      selectors: [
        'main',
        '.home-page',
        '.shopee-page-wrapper',
        '.shopee-search-item-result__items'
      ],
      css: `
        html[data-nfe-enabled='true'] main > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] .home-page > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] .shopee-page-wrapper > :not(#nfe-container) { display: none !important; }
        html[data-nfe-enabled='true'] .shopee-search-item-result__items > * { display: none !important; }
      `
    }
  };

  // Get current site
  function getCurrentSite() {
    const hostname = window.location.hostname;
    const path = window.location.pathname || '';
    if (hostname.includes('facebook.com')) {
      return 'facebook';
    }
    if (hostname.includes('instagram.com')) {
      return 'instagram';
    }
    if (hostname.includes('twitter.com') || hostname.includes('x.com')) return 'twitter';
    if (hostname.includes('reddit.com')) return 'reddit';
    if (hostname.includes('linkedin.com')) return 'linkedin';
    if (hostname.includes('youtube.com')) return 'youtube';
    if (hostname.includes('tiktok.com')) return 'tiktok';
    if (hostname.includes('github.com')) return 'github';
    if (hostname.includes('shopee.vn') || hostname.includes('shopee.com')) return 'shopee';
    if (hostname.includes('news.ycombinator.com')) return 'hackernews';
    return null;
  }

  // Check if extension is enabled for current site
  function isEnabledForSite(siteId) {
    if (!currentSettings.enabled) return false;
    if (!currentSettings.sites || !currentSettings.sites[siteId]) return true;
    return currentSettings.sites[siteId].enabled !== false;
  }

  // Get random quote
  function getRandomQuote() {
    const allQuotes = [];
    
    if (currentSettings.builtinQuotesEnabled) {
      allQuotes.push(...builtinQuotes);
    }
    
    if (currentSettings.customQuotes && currentSettings.customQuotes.length > 0) {
      allQuotes.push(...currentSettings.customQuotes);
    }
    
    if (allQuotes.length === 0) {
      return "Focus on what matters.";
    }
    
    return allQuotes[Math.floor(Math.random() * allQuotes.length)];
  }

  // Inject CSS for site
  function injectCSS(siteId) {
    const site = sites[siteId];
    if (!site || !site.css) return;
    
    const existingStyle = document.getElementById('nfe-styles');
    if (existingStyle) return;
    
    const style = document.createElement('style');
    style.id = 'nfe-styles';
    style.textContent = site.css;
    document.head.appendChild(style);
  }

  // Create quote container
  function createQuoteContainer(quote) {
    const isDark = (() => {
      try {
        const mql = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)');
        if (mql && typeof mql.matches === 'boolean') return mql.matches;
        const bg = getComputedStyle(document.body || document.documentElement).backgroundColor;
        const m = bg && bg.match(/rgba?\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
        if (m) {
          const r = parseInt(m[1], 10), g = parseInt(m[2], 10), b = parseInt(m[3], 10);
          const luminance = (0.2126*r + 0.7152*g + 0.0722*b)/255;
          return luminance < 0.5;
        }
      } catch (_) {}
      return false;
    })();

    const textColor = isDark ? '#e5e5e5' : '#1a1a1a';
    const subTextColor = isDark ? '#a1a1a1' : '#666';
    const container = document.createElement('div');
    container.id = 'nfe-container';
    container.style.cssText = `
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 64px 32px;
      text-align: center;
      width: 100%;
      min-height: 60vh;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    `;
    
    const quoteElement = document.createElement('div');
    quoteElement.style.cssText = `
      font-size: 24px;
      line-height: 1.4;
      color: ${textColor};
      max-width: 600px;
      margin-bottom: 16px;
      font-weight: 300;
    `;
    quoteElement.textContent = `“${quote}”`;
    
    const attribution = document.createElement('div');
    attribution.style.cssText = `
      font-size: 14px;
      color: ${subTextColor};
      font-style: italic;
    `;
    attribution.textContent = '— Focus Extension';
    
    container.appendChild(quoteElement);
    container.appendChild(attribution);
    
    return container;
  }

  // Remove existing quote container
  function removeQuoteContainer() {
    const existing = document.getElementById('nfe-container');
    if (existing) {
      existing.remove();
    }
  }

  // Inject quote into feed
  function injectQuote(targetElement) {
    if (!currentSettings.showQuotes) return;
    
    removeQuoteContainer();
    
    const quote = getRandomQuote();
    const container = createQuoteContainer(quote);
    
    // Insert as first child
    if (targetElement.firstChild) {
      targetElement.insertBefore(container, targetElement.firstChild);
    } else {
      targetElement.appendChild(container);
    }
  }

  // Main eradication function
  function eradicate() {
    const siteId = getCurrentSite();
    if (!siteId || !isEnabledForSite(siteId)) {
      // Remove any existing modifications
      removeQuoteContainer();
      const style = document.getElementById('nfe-styles');
      if (style) style.remove();
      document.documentElement.setAttribute('data-nfe-enabled', 'false');
      return;
    }
    
    const site = sites[siteId];
    if (!site) return;
    
    // Mark as enabled
    document.documentElement.setAttribute('data-nfe-enabled', 'true');
    
    // Inject CSS
    injectCSS(siteId);
    
    // Find target element
    let targetElement = null;
    for (const selector of site.selectors) {
      targetElement = document.querySelector(selector);
      if (targetElement) break;
    }
    
    if (targetElement && !document.getElementById('nfe-container')) {
      injectQuote(targetElement);
    }
  }

  // Load settings from storage
  function loadSettings() {
    chrome.runtime.sendMessage({ action: 'getSocialCleanerSettings' }, (response) => {
      if (response) {
        currentSettings = { ...currentSettings, ...response };
        eradicate();
      }
    });
  }

  // Listen for settings updates and localStorage requests
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'settingsUpdated') {
      currentSettings = { ...currentSettings, ...request.settings };
      eradicate();
      sendResponse({ success: true });
    } else if (request.action === 'getLocalStorageSettings') {
      // Get settings from localStorage using the same key as Flutter LocalStorageManager
      try {
        const key = request.key;
        const data = localStorage.getItem(`flutter.${key}`);
        if (data) {
          const settings = JSON.parse(data);
          sendResponse({ settings: settings });
        } else {
          sendResponse({ settings: null });
        }
      } catch (error) {
        console.error('Error reading from localStorage:', error);
        sendResponse({ settings: null });
      }
    }
    return true; // Keep message channel open for async response
  });

  // Initialize
  function initialize() {
    loadSettings();
    
    // Re-run eradication periodically to handle dynamic content
    setInterval(eradicate, 1000);
    
    // Handle navigation changes (for SPAs)
    let lastUrl = location.href;
    new MutationObserver(() => {
      const url = location.href;
      if (url !== lastUrl) {
        lastUrl = url;
        setTimeout(eradicate, 500);
      }
    }).observe(document, { subtree: true, childList: true });
  }

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }

})();