import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class FacebookContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('facebook'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      // Try to find the main content area
      const selectors = [
        '[role="main"]',
        '#mount_0_0_0V',
        '.fb_content',
        '#globalContainer',
        '#content'
      ];

      for (const selector of selectors) {
        try {
          const element = await waitForElement(selector, 2000);
          if (element) {
            return element;
          }
        } catch {
          // Continue to next selector
        }
      }

      // Fallback to body
      return document.body;
    } catch (error) {
      return document.body;
    }
  }

  protected async siteSpecificProcess(): Promise<void> {
    try {
      // Remove Facebook-specific distracting elements
      this.removeFacebookSpecificElements();
      
      // Inject Facebook-specific CSS
      this.injectFacebookCSS();
      
      // Handle Facebook's dynamic loading
      this.handleDynamicContent();
      
    } catch (error) {
      console.error('Facebook-specific processing failed:', error);
    }
  }

  private removeFacebookSpecificElements(): void {
    const distractingSelectors = [
      // News feed
      '[role="feed"]',
      '#stream_pagelet',
      '.feed',
      '[data-pagelet="FeedUnit"]',
      
      // Stories
      '[data-pagelet="Stories"]',
      '[aria-label="Stories"]',
      
      // Right sidebar
      '[data-pagelet="RightRail"]',
      '#pagelet_ego_pane',
      '.ego_column',
      
      // Sponsored content
      '[data-testid="story-subtitle"] span:contains("Sponsored")',
      '.uiStreamSponsoredLink',
      
      // Notifications
      '[data-testid="notification_jewel"] .count',
      '.jewel .count',
      
      // Chat sidebar
      '[data-pagelet="BuddylistPagelet"]',
      '#pagelet_sidebar',
      
      // Marketplace notifications
      '[data-testid="marketplace_notification_jewel"]',
      
      // Watch notifications
      '[data-testid="watch_notification_jewel"]'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectFacebookCSS(): void {
    const css = `
      /* Hide Facebook news feed and distracting elements */
      [role="feed"],
      #stream_pagelet,
      .feed,
      [data-pagelet="FeedUnit"] {
        display: none !important;
      }
      
      /* Hide stories */
      [data-pagelet="Stories"],
      [aria-label="Stories"] {
        display: none !important;
      }
      
      /* Hide right sidebar */
      [data-pagelet="RightRail"],
      #pagelet_ego_pane,
      .ego_column {
        display: none !important;
      }
      
      /* Hide notification counts */
      .jewel .count,
      [data-testid="notification_jewel"] .count {
        display: none !important;
      }
      
      /* Hide chat sidebar */
      [data-pagelet="BuddylistPagelet"],
      #pagelet_sidebar {
        display: none !important;
      }
      
      /* Style the quote container */
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #f8f9fa;
        border-radius: 12px;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      
      .focus-quote-content {
        display: flex;
        flex-direction: column;
        gap: 20px;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #1c1e21;
        margin: 0;
        font-weight: 300;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #65676b;
        font-weight: 500;
        font-style: normal;
      }
      
      /* Responsive design */
      @media (max-width: 768px) {
        .focus-quote-container {
          margin: 20px;
          padding: 30px 20px;
        }
        
        .focus-quote-text {
          font-size: 20px;
        }
      }
      
      /* Hide Facebook's loading placeholders */
      [data-pagelet="FeedUnit"] .placeholder,
      .uiBoxWhite .placeholder {
        display: none !important;
      }
      
      /* Ensure main content area is visible */
      [role="main"] {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    `;

    injectCSS(css, 'focus-facebook-styles');
  }

  private handleDynamicContent(): void {
    // Facebook heavily uses dynamic content loading
    // Set up additional observers for Facebook-specific patterns
    
    const observer = new MutationObserver((mutations) => {
      let shouldProcess = false;
      
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              const element = node as Element;
              
              // Check if new feed content was added
              if (element.matches('[role="feed"], [data-pagelet="FeedUnit"], .feed') ||
                  element.querySelector('[role="feed"], [data-pagelet="FeedUnit"], .feed')) {
                shouldProcess = true;
              }
            }
          });
        }
      });
      
      if (shouldProcess) {
        setTimeout(() => this.removeFacebookSpecificElements(), 100);
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

// Initialize the Facebook content script
if (window.location.hostname.includes('facebook.com')) {
  new FacebookContentScript();
  log('Facebook content script initialized');
}