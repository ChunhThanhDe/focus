import { SiteId, SiteConfig } from '../types';

/**
 * Generate a unique ID for quotes, storage keys, etc.
 */
export function generateId(): string {
  return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Debounce function to limit the rate of function calls
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(null, args), wait);
  };
}

/**
 * Throttle function to limit the rate of function calls
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func.apply(null, args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

/**
 * Wait for an element to appear in the DOM
 */
export function waitForElement(
  selector: string,
  timeout: number = 10000
): Promise<Element> {
  return new Promise((resolve, reject) => {
    const element = document.querySelector(selector);
    if (element) {
      resolve(element);
      return;
    }

    const observer = new MutationObserver((mutations, obs) => {
      const element = document.querySelector(selector);
      if (element) {
        obs.disconnect();
        resolve(element);
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });

    setTimeout(() => {
      observer.disconnect();
      reject(new Error(`Element ${selector} not found within ${timeout}ms`));
    }, timeout);
  });
}

/**
 * Wait for multiple elements to appear in the DOM
 */
export function waitForElements(
  selectors: string[],
  timeout: number = 10000
): Promise<Element[]> {
  return Promise.all(
    selectors.map(selector => waitForElement(selector, timeout))
  );
}

/**
 * Remove elements from the DOM safely
 */
export function removeElements(selectors: string[]): void {
  selectors.forEach(selector => {
    const elements = document.querySelectorAll(selector);
    elements.forEach(element => {
      try {
        element.remove();
      } catch (error) {
        console.warn(`Failed to remove element ${selector}:`, error);
      }
    });
  });
}

/**
 * Hide elements using CSS display: none
 */
export function hideElements(selectors: string[]): void {
  selectors.forEach(selector => {
    const elements = document.querySelectorAll(selector);
    elements.forEach(element => {
      (element as HTMLElement).style.display = 'none';
    });
  });
}

/**
 * Inject CSS into the page
 */
export function injectCSS(css: string, id?: string): void {
  const styleId = id || `focus-extension-style-${generateId()}`;
  
  // Remove existing style if it exists
  const existingStyle = document.getElementById(styleId);
  if (existingStyle) {
    existingStyle.remove();
  }

  const style = document.createElement('style');
  style.id = styleId;
  style.textContent = css;
  document.head.appendChild(style);
}

/**
 * Get the current site ID based on the URL
 */
export function getCurrentSiteId(): SiteId | null {
  const hostname = window.location.hostname.toLowerCase();
  
  if (hostname.includes('facebook.com')) return 'facebook';
  if (hostname.includes('twitter.com') || hostname.includes('x.com')) return 'twitter';
  if (hostname.includes('instagram.com')) return 'instagram';
  if (hostname.includes('linkedin.com')) return 'linkedin';
  if (hostname.includes('reddit.com')) return 'reddit';
  if (hostname.includes('youtube.com')) return 'youtube';
  if (hostname.includes('github.com')) return 'github';
  if (hostname.includes('news.ycombinator.com')) return 'hackernews';
  
  return null;
}

/**
 * Check if the current page is a supported site
 */
export function isSupportedSite(): boolean {
  return getCurrentSiteId() !== null;
}

/**
 * Create a quote container element
 */
export function createQuoteContainer(text: string, author: string): HTMLElement {
  const container = document.createElement('div');
  container.className = 'focus-quote-container';
  container.innerHTML = `
    <div class="focus-quote-content">
      <blockquote class="focus-quote-text">${text}</blockquote>
      <cite class="focus-quote-author">— ${author}</cite>
    </div>
  `;
  
  return container;
}

/**
 * Log messages with extension prefix
 */
export function log(message: string, ...args: any[]): void {
  console.log(`[Focus Extension] ${message}`, ...args);
}

export function logError(message: string, error?: any): void {
  console.error(`[Focus Extension] ${message}`, error);
}

export function logWarn(message: string, ...args: any[]): void {
  console.warn(`[Focus Extension] ${message}`, ...args);
}

/**
 * Retry a function with exponential backoff
 */
export async function retry<T>(
  fn: () => Promise<T>,
  maxAttempts: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  let lastError: Error;
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      
      if (attempt === maxAttempts) {
        throw lastError;
      }
      
      const delay = baseDelay * Math.pow(2, attempt - 1);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  throw lastError!;
}