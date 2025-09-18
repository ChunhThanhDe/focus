import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class TwitterContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('twitter'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      // Try to find the main content area
      const selectors = [
        '[data-testid="primaryColumn"]',
        'main[role="main"]',
        '#react-root',
        '.css-1dbjc4n.r-kemksi.r-1kqtdi0.r-1ljd8xs.r-13l2t4g.r-1phboty.r-16y2uox.r-1jgb5lz.r-11wrixw.r-61z16t.r-1ye8kvj.r-13qz1uu.r-184en5c'
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
      // Remove Twitter-specific distracting elements
      this.removeTwitterSpecificElements();
      
      // Inject Twitter-specific CSS
      this.injectTwitterCSS();
      
      // Handle Twitter's dynamic loading
      this.handleDynamicContent();
      
    } catch (error) {
      console.error('Twitter-specific processing failed:', error);
    }
  }

  private removeTwitterSpecificElements(): void {
    const distractingSelectors = [
      // Main timeline
      '[data-testid="primaryColumn"] section',
      '[aria-label="Timeline: Your Home Timeline"]',
      '[aria-label="Home timeline"]',
      '[data-testid="cellInnerDiv"]',
      
      // Individual tweets
      '[data-testid="tweet"]',
      'article[role="article"]',
      
      // Trending sidebar
      '[data-testid="sidebarColumn"]',
      '[aria-label="Timeline: Trending now"]',
      '[data-testid="trend"]',
      
      // Who to follow
      '[aria-label="Who to follow"]',
      '[data-testid="UserCell"]',
      
      // Promoted content
      '[data-testid="placementTracking"]',
      '[data-testid="promotedIndicator"]',
      
      // Notifications
      '[data-testid="notification"]',
      
      // Spaces
      '[data-testid="audioSpaceCard"]',
      
      // Fleets/Stories (if they return)
      '[data-testid="fleetline"]'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectTwitterCSS(): void {
    const css = `
      /* Hide Twitter timeline and distracting elements */
      [data-testid="primaryColumn"] section,
      [aria-label="Timeline: Your Home Timeline"],
      [aria-label="Home timeline"],
      [data-testid="cellInnerDiv"],
      [data-testid="tweet"],
      article[role="article"] {
        display: none !important;
      }
      
      /* Hide sidebar content */
      [data-testid="sidebarColumn"],
      [aria-label="Timeline: Trending now"],
      [data-testid="trend"],
      [aria-label="Who to follow"],
      [data-testid="UserCell"] {
        display: none !important;
      }
      
      /* Hide promoted content */
      [data-testid="placementTracking"],
      [data-testid="promotedIndicator"] {
        display: none !important;
      }
      
      /* Style the quote container */
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #e1e8ed;
        border-radius: 16px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      }
      
      .focus-quote-content {
        display: flex;
        flex-direction: column;
        gap: 20px;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #14171a;
        margin: 0;
        font-weight: 400;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #657786;
        font-weight: 500;
        font-style: normal;
      }
      
      /* Dark mode support */
      [data-theme="dark"] .focus-quote-container {
        background: #15202b;
        border-color: #38444d;
        color: #ffffff;
      }
      
      [data-theme="dark"] .focus-quote-text {
        color: #ffffff;
      }
      
      [data-theme="dark"] .focus-quote-author {
        color: #8899a6;
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
      
      /* Ensure main content area is visible */
      [data-testid="primaryColumn"] {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      /* Hide Twitter's loading states */
      [data-testid="cellInnerDiv"] [role="progressbar"],
      [data-testid="primaryColumn"] [role="progressbar"] {
        display: none !important;
      }
      
      /* Hide compose tweet area on home page */
      [data-testid="tweetTextarea_0"],
      [data-testid="toolBar"] {
        display: none !important;
      }
      
      /* Keep navigation visible */
      [data-testid="sidebarColumn"] nav,
      [data-testid="sidebarColumn"] [role="navigation"] {
        display: block !important;
      }
    `;

    injectCSS(css, 'focus-twitter-styles');
  }

  private handleDynamicContent(): void {
    // Twitter/X heavily uses dynamic content loading
    // Set up additional observers for Twitter-specific patterns
    
    const observer = new MutationObserver((mutations) => {
      let shouldProcess = false;
      
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              const element = node as Element;
              
              // Check if new timeline content was added
              if (element.matches('[data-testid="tweet"], [data-testid="cellInnerDiv"], article[role="article"]') ||
                  element.querySelector('[data-testid="tweet"], [data-testid="cellInnerDiv"], article[role="article"]')) {
                shouldProcess = true;
              }
            }
          });
        }
      });
      
      if (shouldProcess) {
        setTimeout(() => this.removeTwitterSpecificElements(), 100);
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

// Initialize the Twitter content script
if (window.location.hostname.includes('twitter.com') || window.location.hostname.includes('x.com')) {
  new TwitterContentScript();
  log('Twitter/X content script initialized');
}