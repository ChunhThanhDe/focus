import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class LinkedInContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('linkedin'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        '.scaffold-layout__main',
        '.feed-container',
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
      this.removeLinkedInSpecificElements();
      this.injectLinkedInCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('LinkedIn-specific processing failed:', error);
    }
  }

  private removeLinkedInSpecificElements(): void {
    const distractingSelectors = [
      // Main feed
      '.feed-container',
      '.scaffold-finite-scroll__content',
      '[data-finite-scroll-hotkey-item]',
      '.feed-shared-update-v2',
      '.occludable-update',
      
      // Sidebar ads
      '.ad-banner-container',
      '[data-module-id*="ad"]',
      
      // News sidebar
      '.news-module',
      
      // People you may know
      '.pymk-list',
      
      // Notifications
      '.notifications-widget'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectLinkedInCSS(): void {
    const css = `
      /* Hide LinkedIn feed */
      .feed-container,
      .scaffold-finite-scroll__content,
      [data-finite-scroll-hotkey-item],
      .feed-shared-update-v2,
      .occludable-update {
        display: none !important;
      }
      
      /* Hide sidebar content */
      .ad-banner-container,
      [data-module-id*="ad"],
      .news-module,
      .pymk-list {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #000000;
        margin: 0 0 20px 0;
        font-weight: 400;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #666666;
        font-weight: 600;
      }
    `;

    injectCSS(css, 'focus-linkedin-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeLinkedInSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('linkedin.com')) {
  new LinkedInContentScript();
  log('LinkedIn content script initialized');
}