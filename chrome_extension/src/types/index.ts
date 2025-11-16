// Chrome Extension Types
export interface ChromeMessage {
  type: string;
  payload?: any;
}

export interface StorageData {
  enabled: boolean;
  customQuotes: CustomQuote[];
  selectedSites: SiteId[];
  showQuotes: boolean;
  quoteSource: 'builtin' | 'custom' | 'mixed';
}

// Site Configuration
export type SiteId = 
  | 'facebook'
  | 'twitter'
  | 'instagram'
  | 'linkedin'
  | 'reddit'
  | 'youtube'
  | 'github'
  | 'hackernews';

export interface SiteConfig {
  id: SiteId;
  name: string;
  domain: string;
  selectors: {
    feedContainer: string[];
    feedItems: string[];
    sidebarAds?: string[];
    notifications?: string[];
  };
  customCSS?: string;
  enabled: boolean;
}

// Quote System
export interface BaseQuote {
  text: string;
  author: string;
}

export interface BuiltinQuote extends BaseQuote {
  id: string;
  category?: string;
}

export interface CustomQuote extends BaseQuote {
  id: string;
  createdAt: number;
  updatedAt: number;
}

export type Quote = BuiltinQuote | CustomQuote;

// Message Types
export interface EnableExtensionMessage extends ChromeMessage {
  type: 'ENABLE_EXTENSION';
  payload: { enabled: boolean };
}

export interface UpdateSitesMessage extends ChromeMessage {
  type: 'UPDATE_SITES';
  payload: { sites: SiteId[] };
}

export interface AddCustomQuoteMessage extends ChromeMessage {
  type: 'ADD_CUSTOM_QUOTE';
  payload: { quote: Omit<CustomQuote, 'id' | 'createdAt' | 'updatedAt'> };
}

export interface RemoveCustomQuoteMessage extends ChromeMessage {
  type: 'REMOVE_CUSTOM_QUOTE';
  payload: { quoteId: string };
}

export interface GetStorageMessage extends ChromeMessage {
  type: 'GET_STORAGE';
}

export interface StorageUpdatedMessage extends ChromeMessage {
  type: 'STORAGE_UPDATED';
  payload: Partial<StorageData>;
}

export type ExtensionMessage = 
  | EnableExtensionMessage
  | UpdateSitesMessage
  | AddCustomQuoteMessage
  | RemoveCustomQuoteMessage
  | GetStorageMessage
  | StorageUpdatedMessage;

// Content Script Interface
export interface ContentScriptAPI {
  removeFeed(): void;
  injectQuote(quote: Quote): void;
  cleanup(): void;
}

// Background Script Interface
export interface BackgroundAPI {
  getStorage(): Promise<StorageData>;
  updateStorage(data: Partial<StorageData>): Promise<void>;
  getRandomQuote(): Promise<Quote>;
  addCustomQuote(quote: Omit<CustomQuote, 'id' | 'createdAt' | 'updatedAt'>): Promise<CustomQuote>;
  removeCustomQuote(quoteId: string): Promise<void>;
}