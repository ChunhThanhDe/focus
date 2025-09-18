import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class GitHubContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('github'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        '.dashboard-main-content',
        '.js-recent-activity-container',
        'main',
        '#dashboard'
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
      this.removeGitHubSpecificElements();
      this.injectGitHubCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('GitHub-specific processing failed:', error);
    }
  }

  private removeGitHubSpecificElements(): void {
    const distractingSelectors = [
      // Activity feed
      '.js-recent-activity-container',
      '[data-hpc] .Box',
      '.news .Box-row',
      '[data-hpc] .Box-row',
      
      // Dashboard sidebar
      '.dashboard-sidebar .border',
      '.dashboard-sidebar',
      
      // Explore/trending
      '.explore-content',
      
      // Notifications
      '.js-notification-indicator'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectGitHubCSS(): void {
    const css = `
      /* Hide GitHub activity feed */
      .js-recent-activity-container,
      [data-hpc] .Box,
      .news .Box-row,
      [data-hpc] .Box-row {
        display: none !important;
      }
      
      /* Hide dashboard sidebar */
      .dashboard-sidebar .border,
      .dashboard-sidebar {
        display: none !important;
      }
      
      /* Hide explore content */
      .explore-content {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #d1d9e0;
        border-radius: 6px;
        text-align: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #24292f;
        margin: 0 0 20px 0;
        font-weight: 400;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #656d76;
        font-weight: 500;
      }
      
      /* Dark mode support */
      [data-color-mode="dark"] .focus-quote-container {
        background: #0d1117;
        border-color: #30363d;
      }
      
      [data-color-mode="dark"] .focus-quote-text {
        color: #f0f6fc;
      }
      
      [data-color-mode="dark"] .focus-quote-author {
        color: #8b949e;
      }
    `;

    injectCSS(css, 'focus-github-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeGitHubSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('github.com')) {
  new GitHubContentScript();
  log('GitHub content script initialized');
}