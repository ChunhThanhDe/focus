import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class InstagramContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('instagram'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        'main[role="main"]',
        'section',
        '#react-root',
        'div[id^="mount"]'
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
      this.removeInstagramSpecificElements();
      this.injectInstagramCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('Instagram-specific processing failed:', error);
    }
  }

  private removeInstagramSpecificElements(): void {
    const distractingSelectors = [
      // Main feed
      'main[role="main"] section > div > div > div:first-child',
      'article',
      '[role="article"]',
      
      // Stories
      '[role="menubar"]',
      
      // Sidebar suggestions
      'aside',
      '[role="complementary"]',
      
      // Explore content
      '[data-testid="explore-grid"]'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectInstagramCSS(): void {
    const css = `
      /* Hide Instagram feed */
      main[role="main"] section > div > div > div:first-child,
      article,
      [role="article"] {
        display: none !important;
      }
      
      /* Hide stories */
      [role="menubar"] {
        display: none !important;
      }
      
      /* Hide sidebar */
      aside,
      [role="complementary"] {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #dbdbdb;
        border-radius: 12px;
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #262626;
        margin: 0 0 20px 0;
        font-weight: 300;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #8e8e8e;
        font-weight: 500;
      }
    `;

    injectCSS(css, 'focus-instagram-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeInstagramSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('instagram.com')) {
  new InstagramContentScript();
  log('Instagram content script initialized');
}