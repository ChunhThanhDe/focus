import { BaseContentScript } from '../base-content-script';
import { getSiteConfig } from '../../data/sites';
import { waitForElement, injectCSS, log } from '../../utils/helpers';

class YouTubeContentScript extends BaseContentScript {
  constructor() {
    super(getSiteConfig('youtube'));
  }

  protected async findQuoteInjectionTarget(): Promise<Element | null> {
    try {
      const selectors = [
        '#primary',
        '#contents.ytd-rich-grid-renderer',
        'ytd-browse[page-subtype="home"]',
        '#main'
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
      this.removeYouTubeSpecificElements();
      this.injectYouTubeCSS();
      this.handleDynamicContent();
    } catch (error) {
      console.error('YouTube-specific processing failed:', error);
    }
  }

  private removeYouTubeSpecificElements(): void {
    const distractingSelectors = [
      // Home feed videos
      '#contents.ytd-rich-grid-renderer',
      'ytd-rich-item-renderer',
      'ytd-video-renderer',
      'ytd-grid-video-renderer',
      
      // Sidebar recommendations
      '#secondary',
      'ytd-watch-next-secondary-results-renderer',
      
      // Ads
      'ytd-display-ad-renderer',
      '.ytd-promoted-sparkles-web-renderer',
      
      // Shorts shelf
      'ytd-rich-shelf-renderer[is-shorts]',
      'ytd-reel-shelf-renderer',
      
      // Trending/subscriptions on home
      'ytd-browse[page-subtype="home"] #contents'
    ];

    distractingSelectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        (element as HTMLElement).style.display = 'none';
      });
    });
  }

  private injectYouTubeCSS(): void {
    const css = `
      /* Hide YouTube home feed */
      #contents.ytd-rich-grid-renderer,
      ytd-rich-item-renderer,
      ytd-video-renderer,
      ytd-grid-video-renderer {
        display: none !important;
      }
      
      /* Hide sidebar recommendations */
      #secondary,
      ytd-watch-next-secondary-results-renderer {
        display: none !important;
      }
      
      /* Hide ads */
      ytd-display-ad-renderer,
      .ytd-promoted-sparkles-web-renderer {
        display: none !important;
      }
      
      /* Hide shorts */
      ytd-rich-shelf-renderer[is-shorts],
      ytd-reel-shelf-renderer {
        display: none !important;
      }
      
      /* Hide home page content */
      ytd-browse[page-subtype="home"] #contents {
        display: none !important;
      }
      
      .focus-quote-container {
        max-width: 600px;
        margin: 40px auto;
        padding: 40px;
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 12px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        text-align: center;
        font-family: Roboto, Arial, sans-serif;
      }
      
      .focus-quote-text {
        font-size: 24px;
        line-height: 1.4;
        color: #030303;
        margin: 0 0 20px 0;
        font-weight: 400;
        font-style: italic;
      }
      
      .focus-quote-author {
        font-size: 16px;
        color: #606060;
        font-weight: 500;
      }
      
      /* Dark mode support */
      [dark] .focus-quote-container {
        background: #0f0f0f;
        border-color: #303030;
      }
      
      [dark] .focus-quote-text {
        color: #ffffff;
      }
      
      [dark] .focus-quote-author {
        color: #aaaaaa;
      }
      
      /* Ensure primary content area is visible */
      #primary {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    `;

    injectCSS(css, 'focus-youtube-styles');
  }

  private handleDynamicContent(): void {
    const observer = new MutationObserver(() => {
      setTimeout(() => this.removeYouTubeSpecificElements(), 100);
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
}

if (window.location.hostname.includes('youtube.com')) {
  new YouTubeContentScript();
  log('YouTube content script initialized');
}