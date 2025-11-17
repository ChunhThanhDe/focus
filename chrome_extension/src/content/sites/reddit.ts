import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class RedditContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('reddit'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        '.ListingLayout-outerContainer',
        '[data-testid="subreddit-posts"]',
        'main',
        '#main-content'
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

      return document.body;
    } catch (error) {
      return document.body;
    }
  }

  protected async siteSpecificProcess(): Promise<void> {
    try {
      this.removeRedditSpecificElements();
      this.injectRedditCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('Reddit-specific processing failed:', error);
    }
  }

  private removeRedditSpecificElements(): void {
    const distractingSelectors = [
      // Main feed posts
      '[data-testid="post-container"]',
      '.Post',
      '[data-click-id="body"]',
      'article',
      
      // Sidebar
      '[data-testid="subreddit-sidebar"]',
      '.promotedlink',
      
      // Popular/trending
      '[data-testid="popular-communities"]',
      
      // Ads
      '.promoted',
      '[data-promoted="true"]',
      
      // Chat
      '[data-testid="chat-post"]'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectRedditCSS(): void {
    const css = `
      /* Hide Reddit posts */
      [data-testid="post-container"],
      .Post,
      [data-click-id="body"],
      article {
        display: none !important;
      }
      
      /* Hide sidebar */
      [data-testid="subreddit-sidebar"],
      .promotedlink,
      [data-testid="popular-communities"] {
        display: none !important;
      }
      
      /* Hide ads */
      .promoted,
      [data-promoted="true"] {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #ccc;
        border-radius: 4px;
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #1a1a1b;
        margin: 0 0 20px 0;
        font-weight: 400;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #787c7e;
        font-weight: 500;
      }
      
      /* Dark mode support */
      body.dark .focus-quote-container {
        background: #1a1a1b;
        border-color: #343536;
      }
      
      body.dark .focus-quote-text {
        color: #d7dadc;
      }
      
      body.dark .focus-quote-author {
        color: #818384;
      }
    `;

    injectCSS(css, 'focus-reddit-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeRedditSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('reddit.com')) {
  new RedditContentScript();
  log('Reddit content script initialized');
}