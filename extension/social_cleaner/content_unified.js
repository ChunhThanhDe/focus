/**
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-18 18:21:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

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
    sites: {},
    builtinQuotesLang: 'en',
    builtinQuotesEn: [],
    builtinQuotesVi: []
  };

  const builtinQuotes = [];

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
      selectors: ['main', 'section'],
      css: `
        html:not([data-nfe-enabled='false']) main > :not(#nfe-container) {
          display: none !important;
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
    threads: {
      name: 'Threads',
      selectors: [
        'div[role="feed"]',
        'div[role="main"]',
        '#__next',
        'div[id^="mount_"]',
        'main',
        'body'
      ],
      css: `
        html[data-nfe-enabled='true'] div[role='feed'] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div[role='main'] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] #__next > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] div[id^='mount_'] > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] main > :not(#nfe-container) {
          display: none !important;
        }
        html[data-nfe-enabled='true'] body > :not(#nfe-container) {
          display: none !important;
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
    if (hostname.includes('threads.net') || hostname.includes('threads.com')) return 'threads';
    if (hostname.includes('twitter.com') || hostname.includes('x.com')) return 'twitter';
    if (hostname.includes('reddit.com')) return 'reddit';
    if (hostname.includes('linkedin.com')) return 'linkedin';
    if (hostname.includes('youtube.com')) return 'youtube';
    if (hostname.includes('tiktok.com')) return 'tiktok';
    if (hostname.includes('github.com')) return 'github';
    if (hostname.includes('shopee.vn') || hostname.includes('shopee.com')) return 'shopee';
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
      const lang = currentSettings.builtinQuotesLang === 'vi' ? 'vi' : 'en';
      const list = lang === 'vi' ? currentSettings.builtinQuotesVi : currentSettings.builtinQuotesEn;
      if (Array.isArray(list) && list.length > 0) {
        allQuotes.push(...list);
      } else {
        allQuotes.push(...builtinQuotes);
      }
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
  function createQuoteContainer(quote, asOverlay) {
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
    const cardBg = isDark ? '#111827' : '#ffffff';
    const cardBorder = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.08)';
    const shadow = isDark ? '0 10px 30px rgba(0,0,0,0.45)' : '0 10px 30px rgba(0,0,0,0.12)';
    const accent = isDark ? '#60a5fa' : '#2563eb';

    const container = document.createElement('div');
    container.id = 'nfe-container';
    container.style.cssText = `
      display: block;
      margin: 32px auto;
      width: min(92%, 760px);
      padding: 20px 24px;
      border-radius: 12px;
      background: ${cardBg};
      border: 1px solid ${cardBorder};
      box-shadow: ${shadow};
      color: ${textColor};
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    `;
    if (asOverlay) {
      container.style.position = 'fixed';
      container.style.top = '50%';
      container.style.left = '50%';
      container.style.transform = 'translate(-50%, -50%)';
      container.style.zIndex = '2147483647';
      container.style.pointerEvents = 'auto';
      container.style.margin = '0';
      container.style.width = 'min(88%, 720px)';
    }
    
    const parts = (() => {
      const raw = String(quote || '').trim();
      const seps = [' — ', ' – ', ' - ', ' | '];
      for (const s of seps) {
        const idx = raw.indexOf(s);
        if (idx > 0) {
          return { text: raw.slice(0, idx).trim(), author: raw.slice(idx + s.length).trim() };
        }
      }
      return { text: raw, author: '' };
    })();

    const quoteRow = document.createElement('div');
    quoteRow.style.cssText = `
      display: block;
      font-size: 20px;
      line-height: 1.6;
      font-weight: 400;
      color: ${textColor};
    `;

    const open = document.createElement('span');
    open.style.cssText = `color: ${accent}; font-size: 22px; margin-right: 4px;`;
    open.textContent = '“';

    const body = document.createElement('span');
    body.textContent = parts.text;

    const close = document.createElement('span');
    close.style.cssText = `color: ${accent}; font-size: 22px; margin-left: 4px;`;
    close.textContent = '”';

    quoteRow.appendChild(open);
    quoteRow.appendChild(body);
    quoteRow.appendChild(close);

    const attribution = document.createElement('div');
    attribution.style.cssText = `
      display: block;
      text-align: right;
      margin-top: 12px;
      font-size: 14px;
      color: ${subTextColor};
      font-style: italic;
    `;
    if (parts.author) {
      const a = document.createElement('a');
      a.href = `https://www.google.com/search?q=${encodeURIComponent(parts.author + ' quote')}`;
      a.target = '_blank';
      a.rel = 'noopener noreferrer';
      a.style.cssText = `color: ${accent}; text-decoration: none;`;
      a.textContent = parts.author;
      attribution.textContent = '— ';
      attribution.appendChild(a);
    } else {
      attribution.textContent = '— Focus to Your Target';
    }

    container.appendChild(quoteRow);
    container.appendChild(attribution);

    // Subtle quick unlock link
    const quick = document.createElement('div');
    quick.style.cssText = `
      margin-top: 8px;
      font-size: 11px;
      color: ${subTextColor};
      opacity: 0.35;
    `;
    const link = document.createElement('a');
    link.href = '#';
    link.textContent = 'Allow briefly (5 min)';
    link.style.cssText = `color: ${accent}; text-decoration: none; cursor: pointer; opacity: 0.55;`;
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const siteId = getCurrentSite();
      if (!siteId) return;
      try {
        chrome.runtime.sendMessage({ action: 'scheduleSiteLock', siteId: siteId, minutes: 5 });
      } catch (_) {}
      // Immediate local disable
      try {
        currentSettings.sites = currentSettings.sites || {};
        currentSettings.sites[siteId] = { enabled: false };
      } catch (_) {}
      removeQuoteContainer();
      const styleEl = document.getElementById('nfe-styles');
      if (styleEl) styleEl.remove();
      document.documentElement.setAttribute('data-nfe-enabled', 'false');
    });
    quick.appendChild(link);
    container.appendChild(quick);

    // Hover reveal
    container.addEventListener('mouseenter', () => { quick.style.opacity = '0.65'; });
    container.addEventListener('mouseleave', () => { quick.style.opacity = '0.35'; });

    return container;
  }

  // Remove existing quote container
  function removeQuoteContainer() {
    const existing = document.getElementById('nfe-container');
    if (existing) {
      existing.remove();
    }
  }

  function isElementVisible(el) {
    if (!el) return false;
    const style = window.getComputedStyle(el);
    if (style.display === 'none' || style.visibility === 'hidden' || parseFloat(style.opacity) === 0) return false;
    const rect = el.getBoundingClientRect();
    return rect.width > 0 && rect.height > 0;
  }

  // Inject quote into feed
  function injectQuote(targetElement) {
    if (!currentSettings.showQuotes) return;
    
    removeQuoteContainer();
    
    const quote = getRandomQuote();
    const container = createQuoteContainer(quote, false);
    if (targetElement.firstChild) {
      targetElement.insertBefore(container, targetElement.firstChild);
    } else {
      targetElement.appendChild(container);
    }
    if (!isElementVisible(container)) {
      removeQuoteContainer();
      const overlay = createQuoteContainer(quote, true);
      document.body.appendChild(overlay);
    }
  }

  function injectOverlayQuote() {
    if (!currentSettings.showQuotes) return;
    removeQuoteContainer();
    const quote = getRandomQuote();
    const overlay = createQuoteContainer(quote, true);
    document.body.appendChild(overlay);
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
    } else if (!targetElement && !document.getElementById('nfe-container')) {
      injectOverlayQuote();
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