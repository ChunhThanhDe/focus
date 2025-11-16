import { SiteConfig, SiteId } from '../types';

export const SITE_CONFIGS: Record<SiteId, SiteConfig> = {
  facebook: {
    id: 'facebook',
    name: 'Facebook',
    domain: 'facebook.com',
    selectors: {
      feedContainer: [
        '[role="feed"]',
        '#stream_pagelet',
        '.feed',
        '[data-pagelet="FeedUnit"]'
      ],
      feedItems: [
        '[data-pagelet="FeedUnit"]',
        '[role="article"]',
        '.userContentWrapper',
        '._5pcr'
      ],
      sidebarAds: [
        '[data-pagelet="RightRail"]',
        '#pagelet_ego_pane',
        '.ego_column'
      ],
      notifications: [
        '[data-testid="notification_jewel"]',
        '.jewel .count'
      ]
    },
    enabled: true
  },

  twitter: {
    id: 'twitter',
    name: 'Twitter/X',
    domain: 'twitter.com',
    selectors: {
      feedContainer: [
        '[data-testid="primaryColumn"]',
        '[aria-label="Timeline: Your Home Timeline"]',
        '[aria-label="Home timeline"]',
        'main[role="main"] section'
      ],
      feedItems: [
        '[data-testid="tweet"]',
        '[data-testid="cellInnerDiv"]',
        'article[role="article"]'
      ],
      sidebarAds: [
        '[data-testid="sidebarColumn"]',
        '[aria-label="Timeline: Trending now"]'
      ]
    },
    enabled: true
  },

  instagram: {
    id: 'instagram',
    name: 'Instagram',
    domain: 'instagram.com',
    selectors: {
      feedContainer: [
        'main[role="main"]',
        'section > div > div',
        '[role="main"] section'
      ],
      feedItems: [
        'article',
        '[role="article"]'
      ],
      sidebarAds: [
        'aside',
        '[role="complementary"]'
      ]
    },
    customCSS: `
      /* Hide Instagram feed */
      main[role="main"] section > div > div > div:first-child {
        display: none !important;
      }
    `,
    enabled: true
  },

  linkedin: {
    id: 'linkedin',
    name: 'LinkedIn',
    domain: 'linkedin.com',
    selectors: {
      feedContainer: [
        '.feed-container',
        '.scaffold-finite-scroll__content',
        '[data-finite-scroll-hotkey-item]'
      ],
      feedItems: [
        '.feed-shared-update-v2',
        '[data-finite-scroll-hotkey-item]',
        '.occludable-update'
      ],
      sidebarAds: [
        '.ad-banner-container',
        '[data-module-id*="ad"]'
      ]
    },
    enabled: true
  },

  reddit: {
    id: 'reddit',
    name: 'Reddit',
    domain: 'reddit.com',
    selectors: {
      feedContainer: [
        '[data-testid="post-container"]',
        '.Post',
        '[data-click-id="body"]'
      ],
      feedItems: [
        '[data-testid="post-container"]',
        '.Post',
        'article'
      ],
      sidebarAds: [
        '[data-testid="subreddit-sidebar"]',
        '.promotedlink'
      ]
    },
    enabled: true
  },

  youtube: {
    id: 'youtube',
    name: 'YouTube',
    domain: 'youtube.com',
    selectors: {
      feedContainer: [
        '#contents.ytd-rich-grid-renderer',
        '#primary #contents',
        'ytd-browse[page-subtype="home"] #contents'
      ],
      feedItems: [
        'ytd-rich-item-renderer',
        'ytd-video-renderer',
        'ytd-grid-video-renderer'
      ],
      sidebarAds: [
        'ytd-display-ad-renderer',
        '.ytd-promoted-sparkles-web-renderer'
      ]
    },
    enabled: true
  },

  github: {
    id: 'github',
    name: 'GitHub',
    domain: 'github.com',
    selectors: {
      feedContainer: [
        '.js-recent-activity-container',
        '[data-hpc] .Box',
        '.dashboard-sidebar'
      ],
      feedItems: [
        '.news .Box-row',
        '[data-hpc] .Box-row'
      ],
      sidebarAds: [
        '.dashboard-sidebar .border'
      ]
    },
    enabled: true
  },

  hackernews: {
    id: 'hackernews',
    name: 'Hacker News',
    domain: 'news.ycombinator.com',
    selectors: {
      feedContainer: [
        '#hnmain table',
        '.itemlist'
      ],
      feedItems: [
        '.athing',
        'tr.athing'
      ]
    },
    enabled: true
  }
};

export function getSiteConfig(siteId: SiteId): SiteConfig {
  return SITE_CONFIGS[siteId];
}

export function getAllSiteConfigs(): SiteConfig[] {
  return Object.values(SITE_CONFIGS);
}

export function getEnabledSiteConfigs(): SiteConfig[] {
  return Object.values(SITE_CONFIGS).filter(config => config.enabled);
}

export function getSiteConfigByDomain(domain: string): SiteConfig | null {
  const normalizedDomain = domain.toLowerCase();
  
  for (const config of Object.values(SITE_CONFIGS)) {
    if (normalizedDomain.includes(config.domain)) {
      return config;
    }
  }
  
  return null;
}