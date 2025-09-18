import { StorageData, ExtensionMessage, CustomQuote, Quote, SiteId } from '../types';
import { getBuiltinQuotes } from '../data/quotes';
import { generateId } from '../utils/helpers';

// Default storage data
const DEFAULT_STORAGE: StorageData = {
  enabled: true,
  customQuotes: [],
  selectedSites: ['facebook', 'twitter', 'instagram', 'linkedin', 'reddit'],
  showQuotes: true,
  quoteSource: 'builtin'
};

class BackgroundService {
  private storageCache: StorageData | null = null;

  constructor() {
    this.initializeStorage();
    this.setupMessageListener();
    this.setupActionListener();
  }

  private async initializeStorage(): Promise<void> {
    try {
      const result = await chrome.storage.sync.get(null);
      
      if (Object.keys(result).length === 0) {
        // First time installation
        await chrome.storage.sync.set(DEFAULT_STORAGE);
        this.storageCache = DEFAULT_STORAGE;
      } else {
        // Merge with defaults for any missing keys
        const mergedData = { ...DEFAULT_STORAGE, ...result };
        await chrome.storage.sync.set(mergedData);
        this.storageCache = mergedData;
      }
    } catch (error) {
      console.error('Failed to initialize storage:', error);
      this.storageCache = DEFAULT_STORAGE;
    }
  }

  private setupMessageListener(): void {
    chrome.runtime.onMessage.addListener(
      (message: ExtensionMessage, sender, sendResponse) => {
        this.handleMessage(message, sender)
          .then(sendResponse)
          .catch(error => {
            console.error('Message handling error:', error);
            sendResponse({ error: error.message });
          });
        
        return true; // Keep message channel open for async response
      }
    );
  }

  private setupActionListener(): void {
    chrome.action.onClicked.addListener(async (tab) => {
      try {
        // Open Flutter app settings page
        await chrome.tabs.create({
          url: chrome.runtime.getURL('index.html#/settings')
        });
      } catch (error) {
        console.error('Failed to open settings:', error);
      }
    });
  }

  private async handleMessage(message: ExtensionMessage, sender: chrome.runtime.MessageSender): Promise<any> {
    switch (message.type) {
      case 'GET_STORAGE':
        return await this.getStorage();

      case 'ENABLE_EXTENSION':
        return await this.updateStorage({ enabled: message.payload.enabled });

      case 'UPDATE_SITES':
        return await this.updateStorage({ selectedSites: message.payload.sites });

      case 'ADD_CUSTOM_QUOTE':
        return await this.addCustomQuote(message.payload.quote);

      case 'REMOVE_CUSTOM_QUOTE':
        return await this.removeCustomQuote(message.payload.quoteId);

      default:
        throw new Error(`Unknown message type: ${message.type}`);
    }
  }

  private async getStorage(): Promise<StorageData> {
    if (!this.storageCache) {
      await this.initializeStorage();
    }
    return this.storageCache!;
  }

  private async updateStorage(updates: Partial<StorageData>): Promise<StorageData> {
    try {
      const currentData = await this.getStorage();
      const updatedData = { ...currentData, ...updates };
      
      await chrome.storage.sync.set(updatedData);
      this.storageCache = updatedData;
      
      // Notify content scripts of storage changes
      this.broadcastStorageUpdate(updates);
      
      return updatedData;
    } catch (error) {
      console.error('Failed to update storage:', error);
      throw error;
    }
  }

  private async addCustomQuote(quoteData: Omit<CustomQuote, 'id' | 'createdAt' | 'updatedAt'>): Promise<CustomQuote> {
    const currentData = await this.getStorage();
    const newQuote: CustomQuote = {
      ...quoteData,
      id: generateId(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const updatedQuotes = [...currentData.customQuotes, newQuote];
    await this.updateStorage({ customQuotes: updatedQuotes });
    
    return newQuote;
  }

  private async removeCustomQuote(quoteId: string): Promise<void> {
    const currentData = await this.getStorage();
    const updatedQuotes = currentData.customQuotes.filter(quote => quote.id !== quoteId);
    await this.updateStorage({ customQuotes: updatedQuotes });
  }

  private async broadcastStorageUpdate(updates: Partial<StorageData>): Promise<void> {
    try {
      const tabs = await chrome.tabs.query({});
      const message: ExtensionMessage = {
        type: 'STORAGE_UPDATED',
        payload: updates
      };
      
      for (const tab of tabs) {
        if (tab.id) {
          chrome.tabs.sendMessage(tab.id, message).catch(() => {
            // Ignore errors for tabs without content scripts
          });
        }
      }
    } catch (error) {
      console.error('Failed to broadcast storage update:', error);
    }
  }

  public async getRandomQuote(): Promise<Quote> {
    const storage = await this.getStorage();
    const builtinQuotes = getBuiltinQuotes();
    
    let availableQuotes: Quote[] = [];
    
    switch (storage.quoteSource) {
      case 'builtin':
        availableQuotes = builtinQuotes;
        break;
      case 'custom':
        availableQuotes = storage.customQuotes;
        break;
      case 'mixed':
        availableQuotes = [...builtinQuotes, ...storage.customQuotes];
        break;
    }
    
    if (availableQuotes.length === 0) {
      // Fallback to builtin quotes if no quotes available
      availableQuotes = builtinQuotes;
    }
    
    const randomIndex = Math.floor(Math.random() * availableQuotes.length);
    return availableQuotes[randomIndex];
  }
}

// Initialize the background service
const backgroundService = new BackgroundService();

// Export for testing purposes
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { BackgroundService };
}