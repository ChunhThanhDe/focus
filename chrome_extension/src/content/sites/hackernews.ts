import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class HackerNewsContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('hackernews'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        '#hnmain',
        'table',
        'body'
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
      this.removeHackerNewsSpecificElements();
      this.injectHackerNewsCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('Hacker News-specific processing failed:', error);
    }
  }

  private removeHackerNewsSpecificElements(): void {
    const distractingSelectors = [
      // Story list
      '.athing',
      'tr.athing',
      '.itemlist',
      
      // Story rows
      '.storylink',
      '.subtext',
      
      // Comments
      '.comment',
      '.comtr'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectHackerNewsCSS(): void {
    const css = `
      /* Hide Hacker News stories */
      .athing,
      tr.athing,
      .itemlist,
      .storylink,
      .subtext {
        display: none !important;
      }
      
      /* Hide comments */
      .comment,
      .comtr {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #f6f6ef;
        border: 1px solid #ff6600;
        border-radius: 4px;
        text-align: center;
        font-family: Verdana, Geneva, sans-serif;
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
        color: #828282;
        font-weight: 500;
      }
      
      /* Ensure main content area is visible */
      #hnmain {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    `;

    injectCSS(css, 'focus-hackernews-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeHackerNewsSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('news.ycombinator.com')) {
  new HackerNewsContentScript();
  log('Hacker News content script initialized');
}