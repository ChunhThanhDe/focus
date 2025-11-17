import { StorageData, ExtensionMessage, Quote, SiteConfig, ContentScriptAPI } from '../types';
import { removeElements, hideElements, injectCSS, createQuoteContainer, waitForElement, debounce, log, logError, retry } from '../utils/helpers';
import { getSiteConfig } from '../data/sites';

export abstract class BaseContentScript implements ContentScriptAPI {
  protected siteConfig: SiteConfig;
  protected isEnabled: boolean = true;
  protected showQuotes: boolean = true;
  protected currentQuote: Quote | null = null;
  protected quoteContainer: HTMLElement | null = null;
  protected observer: MutationObserver | null = null;
  protected retryCount: number = 0;
  protected maxRetries: number = 10;
  protected retryDelay: number = 1000;

  constructor(siteConfig: SiteConfig) {
    this.siteConfig = siteConfig;
    this.init();
  }

  private async init(): Promise<void> {
    try {
      // Load initial storage data
      await this.loadStorageData();
      
      // Set up message listener
      this.setupMessageListener();
      
      // Wait for DOM to be ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => this.start());
      } else {
        this.start();
      }
    } catch (error) {
      logError('Failed to initialize content script:', error);
    }
  }

  private async loadStorageData(): Promise<void> {
    try {
      const response = await chrome.runtime.sendMessage({ type: 'GET_STORAGE' });
      if (response && !response.error) {
        const storage: StorageData = response;
        this.isEnabled = storage.enabled && storage.selectedSites.includes(this.siteConfig.id);
        this.showQuotes = storage.showQuotes;
      }
    } catch (error) {
      logError('Failed to load storage data:', error);
    }
  }

  private setupMessageListener(): void {
    chrome.runtime.onMessage.addListener((message: ExtensionMessage) => {
      this.handleMessage(message);
    });
  }

  private handleMessage(message: ExtensionMessage): void {
    switch (message.type) {
      case 'STORAGE_UPDATED':
        this.handleStorageUpdate(message.payload);
        break;
    }
  }

  private handleStorageUpdate(updates: Partial<StorageData>): void {
    let shouldRestart = false;

    if (updates.enabled !== undefined || updates.selectedSites !== undefined) {
      const wasEnabled = this.isEnabled;
      this.isEnabled = (updates.enabled ?? this.isEnabled) && 
                      (updates.selectedSites ?? []).includes(this.siteConfig.id);
      
      if (wasEnabled !== this.isEnabled) {
        shouldRestart = true;
      }
    }

    if (updates.showQuotes !== undefined) {
      this.showQuotes = updates.showQuotes;
      if (this.isEnabled) {
        this.updateQuoteDisplay();
      }
    }

    if (shouldRestart) {
      this.restart();
    }
  }

  private async start(): Promise<void> {
    if (!this.isEnabled) {
      log(`Content script disabled for ${this.siteConfig.name}`);
      return;
    }

    log(`Starting content script for ${this.siteConfig.name}`);
    
    try {
      // Inject custom CSS if available
      if (this.siteConfig.customCSS) {
        injectCSS(this.siteConfig.customCSS, `focus-${this.siteConfig.id}-custom`);
      }

      // Start the main process with retry logic
      await retry(() => this.process(), this.maxRetries, this.retryDelay);
      
      // Set up mutation observer for dynamic content
      this.setupMutationObserver();
      
    } catch (error) {
      logError(`Failed to start content script for ${this.siteConfig.name}:`, error);
    }
  }

  private async process(): Promise<void> {
    // Remove news feed
    this.removeFeed();
    
    // Inject quote if enabled
    if (this.showQuotes) {
      await this.loadAndInjectQuote();
    }
    
    // Site-specific processing
    await this.siteSpecificProcess();
  }

  private setupMutationObserver(): void {
    if (this.observer) {
      this.observer.disconnect();
    }

    this.observer = new MutationObserver(
      debounce(() => {
        if (this.isEnabled) {
          this.process().catch(error => {
            logError('Error in mutation observer process:', error);
          });
        }
      }, 500)
    );

    this.observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  public removeFeed(): void {
    try {
      // Remove feed containers
      removeElements(this.siteConfig.selectors.feedContainer);
      
      // Remove individual feed items
      removeElements(this.siteConfig.selectors.feedItems);
      
      // Hide sidebar ads if configured
      if (this.siteConfig.selectors.sidebarAds) {
        hideElements(this.siteConfig.selectors.sidebarAds);
      }
      
      // Remove notifications if configured
      if (this.siteConfig.selectors.notifications) {
        hideElements(this.siteConfig.selectors.notifications);
      }
      
      log(`Removed feed elements for ${this.siteConfig.name}`);
    } catch (error) {
      logError(`Failed to remove feed for ${this.siteConfig.name}:`, error);
    }
  }

  public async injectQuote(quote: Quote): Promise<void> {
    try {
      this.currentQuote = quote;
      
      // Remove existing quote container
      if (this.quoteContainer) {
        this.quoteContainer.remove();
      }
      
      // Create new quote container
      this.quoteContainer = createQuoteContainer(quote.text, quote.author);
      
      // Find the best location to inject the quote
      const targetContainer = await this.findQuoteInjectionTarget();
      if (targetContainer) {
        targetContainer.appendChild(this.quoteContainer);
        log(`Injected quote for ${this.siteConfig.name}`);
      } else {
        logError(`Could not find injection target for ${this.siteConfig.name}`);
      }
    } catch (error) {
      logError(`Failed to inject quote for ${this.siteConfig.name}:`, error);
    }
  }

  private async loadAndInjectQuote(): Promise<void> {
    try {
      const response = await chrome.runtime.sendMessage({ type: 'GET_RANDOM_QUOTE' });
      if (response && !response.error) {
        await this.injectQuote(response);
      }
    } catch (error) {
      logError('Failed to load and inject quote:', error);
    }
  }

  private updateQuoteDisplay(): void {
    if (this.showQuotes && !this.quoteContainer && this.currentQuote) {
      this.injectQuote(this.currentQuote);
    } else if (!this.showQuotes && this.quoteContainer) {
      this.quoteContainer.remove();
      this.quoteContainer = null;
    }
  }

  private restart(): void {
    this.cleanup();
    this.start();
  }

  public cleanup(): void {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    
    if (this.quoteContainer) {
      this.quoteContainer.remove();
      this.quoteContainer = null;
    }
    
    this.currentQuote = null;
  }

  // Abstract methods to be implemented by site-specific scripts
  protected abstract findQuoteInjectionTarget(): Promise<Element | null>;
  protected abstract siteSpecificProcess(): Promise<void>;
}