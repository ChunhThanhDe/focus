import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';

import '../models/extension_settings.dart';
import '../models/quote.dart';
import '../models/site_config.dart';
import '../services/extension_service.dart';
import '../../utils/storage_manager.dart';
import '../../resources/storage_keys.dart';

part 'extension_store.g.dart';

class ExtensionStore = _ExtensionStore with _$ExtensionStore;

abstract class _ExtensionStore with Store {
  final ExtensionService _extensionService;
  final LocalStorageManager _storageManager;
  
  _ExtensionStore(this._extensionService, this._storageManager);
  
  @observable
  bool initialized = false;
  
  @observable
  bool loading = false;
  
  @observable
  ExtensionSettings? settings;
  
  @observable
  List<SiteStats> stats = [];
  
  @observable
  Quote? currentQuote;
  
  @observable
  String? error;
  
  @computed
  bool get isExtensionEnabled => settings?.enabled ?? false;
  
  @computed
  int get totalQuotesShown => stats.fold(0, (sum, stat) => sum + stat.quotesShown);
  
  @computed
  int get totalFeedsBlocked => stats.fold(0, (sum, stat) => sum + stat.feedsBlocked);
  
  @computed
  Duration get totalTimeActive => stats.fold(
    Duration.zero,
    (sum, stat) => sum + stat.totalTimeActive,
  );
  
  @computed
  List<SiteId> get enabledSites => settings?.enabledSites.toList() ?? [];
  
  @computed
  List<CustomQuote> get customQuotes => settings?.customQuotes ?? [];
  
  @computed
  bool get hasCustomQuotes => customQuotes.isNotEmpty;
  
  /// Initialize the extension store
  @action
  Future<void> initialize() async {
    if (initialized) return;
    
    try {
      loading = true;
      error = null;
      
      // Initialize extension service
      await _extensionService.initialize();
      
      // Load settings from extension or storage
      await _loadSettings();
      
      // Load stats
      await _loadStats();
      
      // Load current quote
      await _loadCurrentQuote();
      
      // Setup listeners
      _setupListeners();
      
      initialized = true;
    } catch (e) {
      error = 'Failed to initialize extension: $e';
      debugPrint('Extension initialization error: $e');
    } finally {
      loading = false;
    }
  }
  
  /// Load extension settings
  @action
  Future<void> _loadSettings() async {
    try {
      // Try to get settings from extension first
      final extensionSettings = await _extensionService.getSettings();
      
      if (extensionSettings != null) {
        settings = extensionSettings;
        // Cache in local storage
        await _storageManager.setJson(
          StorageKeys.extensionSettings,
          extensionSettings.toJson(),
        );
      } else {
        // Fallback to local storage
        final cachedSettings = await _storageManager.getJson(StorageKeys.extensionSettings);
        if (cachedSettings != null) {
          settings = ExtensionSettings.fromJson(cachedSettings);
        } else {
          // Use default settings
          settings = const ExtensionSettings();
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      settings = const ExtensionSettings();
    }
  }
  
  /// Load site statistics
  @action
  Future<void> _loadStats() async {
    try {
      final extensionStats = await _extensionService.getStats();
      stats = extensionStats;
    } catch (e) {
      debugPrint('Error loading stats: $e');
      stats = [];
    }
  }
  
  /// Load current quote
  @action
  Future<void> _loadCurrentQuote() async {
    try {
      currentQuote = await _extensionService.getCurrentQuote();
    } catch (e) {
      debugPrint('Error loading current quote: $e');
    }
  }
  
  /// Setup listeners for extension events
  void _setupListeners() {
    // Listen to settings changes
    _extensionService.settingsStream.listen((newSettings) {
      runInAction(() {
        settings = newSettings;
      });
      
      // Cache in local storage
      _storageManager.setJson(
        StorageKeys.extensionSettings,
        newSettings.toJson(),
      );
    });
    
    // Listen to stats changes
    _extensionService.statsStream.listen((newStats) {
      runInAction(() {
        stats = newStats;
      });
    });
    
    // Listen to quote changes
    _extensionService.currentQuoteStream.listen((newQuote) {
      runInAction(() {
        currentQuote = newQuote;
      });
    });
  }
  
  /// Update extension enabled state
  @action
  Future<bool> updateExtensionEnabled(bool enabled) async {
    try {
      loading = true;
      error = null;
      
      final success = await _extensionService.updateExtensionEnabled(enabled);
      
      if (success) {
         settings = settings?.copyWith(enabled: enabled);
         // Cache in local storage
         if (settings != null) {
           await _storageManager.setJson(
             StorageKeys.extensionSettings,
             settings!.toJson(),
           );
         }
       } else {
         error = 'Failed to update extension state';
       }
      
      return success;
    } catch (e) {
      error = 'Error updating extension state: $e';
      debugPrint('Error updating extension state: $e');
      return false;
    } finally {
      loading = false;
    }
  }

  /// Update selected sites
  @action
  Future<bool> updateSelectedSites(List<SiteId> sites) async {
    try {
      loading = true;
      error = null;
      
      final success = await _extensionService.updateSelectedSites(sites);
      
      if (success) {
         settings = settings?.copyWith(enabledSites: sites.toSet());
         // Cache in local storage
         if (settings != null) {
           await _storageManager.setJson(
             StorageKeys.extensionSettings,
             settings!.toJson(),
           );
         }
       } else {
         error = 'Failed to update selected sites';
       }
      
      return success;
    } catch (e) {
      error = 'Error updating sites: $e';
      debugPrint('Error updating sites: $e');
      return false;
    } finally {
      loading = false;
    }
  }

  /// Update extension settings (legacy method)
  @action
  Future<bool> updateSettings(ExtensionSettings newSettings) async {
    try {
      loading = true;
      error = null;
      
      final success = await _extensionService.updateSettings(newSettings);
      
      if (success) {
        settings = newSettings;
        // Cache in local storage
        await _storageManager.setJson(
          StorageKeys.extensionSettings,
          newSettings.toJson(),
        );
      } else {
        error = 'Failed to update extension settings';
      }
      
      return success;
    } catch (e) {
      error = 'Error updating settings: $e';
      debugPrint('Error updating settings: $e');
      return false;
    } finally {
      loading = false;
    }
  }
  
  /// Toggle extension enabled state
  @action
  Future<bool> toggleExtension() async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(enabled: !settings!.enabled);
    return updateSettings(newSettings);
  }
  
  /// Toggle site enabled state
  @action
  Future<bool> toggleSite(SiteId siteId) async {
    if (settings == null) return false;
    
    final enabledSites = Set<SiteId>.from(settings!.enabledSites);
    
    if (enabledSites.contains(siteId)) {
      enabledSites.remove(siteId);
    } else {
      enabledSites.add(siteId);
    }
    
    final newSettings = settings!.copyWith(enabledSites: enabledSites);
    return updateSettings(newSettings);
  }
  
  /// Update quote source
  @action
  Future<bool> updateQuoteSource(QuoteSource source) async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(quoteSource: source);
    return updateSettings(newSettings);
  }
  
  /// Update selected quote categories
  @action
  Future<bool> updateQuoteCategories(List<QuoteCategory> categories) async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(selectedCategories: categories);
    return updateSettings(newSettings);
  }
  
  /// Update quote display settings
  @action
  Future<bool> updateQuoteDisplay(QuoteDisplaySettings displaySettings) async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(quoteDisplay: displaySettings);
    return updateSettings(newSettings);
  }
  
  /// Update quote rotation settings
  @action
  Future<bool> updateQuoteRotation(QuoteRotationSettings rotationSettings) async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(quoteRotation: rotationSettings);
    return updateSettings(newSettings);
  }
  
  /// Update feed blocking settings
  @action
  Future<bool> updateFeedBlocking(FeedBlockingSettings blockingSettings) async {
    if (settings == null) return false;
    
    final newSettings = settings!.copyWith(feedBlocking: blockingSettings);
    return updateSettings(newSettings);
  }
  
  /// Add a custom quote
  @action
  Future<bool> addCustomQuote(String text, String author) async {
    try {
      loading = true;
      error = null;
      
      final success = await _extensionService.addCustomQuote(text, author);
      
      if (success) {
        // Reload settings to get updated custom quotes
        await _loadSettings();
      } else {
        error = 'Failed to add custom quote';
      }
      
      return success;
    } catch (e) {
      error = 'Error adding custom quote: $e';
      debugPrint('Error adding custom quote: $e');
      return false;
    } finally {
      loading = false;
    }
  }
  
  /// Delete a custom quote
  @action
  Future<bool> deleteCustomQuote(String quoteId) async {
    try {
      loading = true;
      error = null;
      
      final success = await _extensionService.deleteCustomQuote(quoteId);
      
      if (success) {
        // Reload settings to get updated custom quotes
        await _loadSettings();
      } else {
        error = 'Failed to delete custom quote';
      }
      
      return success;
    } catch (e) {
      error = 'Error deleting custom quote: $e';
      debugPrint('Error deleting custom quote: $e');
      return false;
    } finally {
      loading = false;
    }
  }
  
  /// Rotate to next quote
  @action
  Future<bool> rotateQuote() async {
    try {
      final success = await _extensionService.rotateQuote();
      
      if (success) {
        // Reload current quote
        await _loadCurrentQuote();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error rotating quote: $e');
      return false;
    }
  }
  
  /// Refresh all data
  @action
  Future<void> refresh() async {
    try {
      loading = true;
      error = null;
      
      await Future.wait([
        _loadSettings(),
        _loadStats(),
        _loadCurrentQuote(),
      ]);
    } catch (e) {
      error = 'Failed to refresh data: $e';
      debugPrint('Error refreshing data: $e');
    } finally {
      loading = false;
    }
  }
  
  /// Clear error state
  @action
  void clearError() {
    error = null;
  }
  
  /// Get stats for a specific site
  SiteStats? getStatsForSite(SiteId siteId) {
    try {
      return stats.firstWhere((stat) => stat.siteId == siteId);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a site is enabled
  bool isSiteEnabled(SiteId siteId) {
    return settings?.enabledSites.contains(siteId) ?? false;
  }
  
  /// Get formatted time active string
  String getFormattedTimeActive() {
    final duration = totalTimeActive;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}