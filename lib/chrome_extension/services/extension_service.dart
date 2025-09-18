import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

import '../models/extension_settings.dart';
import '../models/quote.dart';
import '../models/site_config.dart';

/// Service for communicating with the Chrome extension
class ExtensionService {
  static const String _extensionId = 'your-extension-id-here';
  static const String _messageOrigin = 'chrome-extension://$_extensionId';
  
  // Message types for Chrome extension communication
  static const String _getStorage = 'GET_STORAGE';
  static const String _enableExtension = 'ENABLE_EXTENSION';
  static const String _updateSites = 'UPDATE_SITES';
  static const String _addCustomQuote = 'ADD_CUSTOM_QUOTE';
  static const String _removeCustomQuote = 'REMOVE_CUSTOM_QUOTE';
  static const String _storageUpdated = 'STORAGE_UPDATED';
  
  final StreamController<ExtensionSettings> _settingsController = StreamController<ExtensionSettings>.broadcast();
  final StreamController<List<SiteStats>> _statsController = StreamController<List<SiteStats>>.broadcast();
  final StreamController<Quote> _currentQuoteController = StreamController<Quote>.broadcast();
  
  Stream<ExtensionSettings> get settingsStream => _settingsController.stream;
  Stream<List<SiteStats>> get statsStream => _statsController.stream;
  Stream<Quote> get currentQuoteStream => _currentQuoteController.stream;
  
  bool _isInitialized = false;
  ExtensionSettings? _cachedSettings;
  
  /// Initialize the extension service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      _setupMessageListener();
      await _requestInitialData();
    }
    
    _isInitialized = true;
  }
  
  /// Check if running in Chrome extension context
  bool get isExtensionContext {
    if (!kIsWeb) return false;
    
    try {
      return html.window.location.protocol == 'chrome-extension:';
    } catch (e) {
      return false;
    }
  }
  
  /// Get current extension storage data
  Future<ExtensionSettings?> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings;
    }
    
    if (!isExtensionContext) {
      // Return default settings for development
      return const ExtensionSettings();
    }
    
    final completer = Completer<ExtensionSettings?>();
    
    _sendMessage({
      'type': _getStorage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      if (response != null) {
        // Convert Chrome extension StorageData to ExtensionSettings
        final settings = _convertStorageToSettings(response);
        _cachedSettings = settings;
        completer.complete(settings);
      } else {
        completer.complete(null);
      }
    });
    
    return completer.future;
  }
  
  /// Update extension enabled state
  Future<bool> updateExtensionEnabled(bool enabled) async {
    if (!isExtensionContext) {
      // For development, just update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(enabled: enabled);
        _settingsController.add(_cachedSettings!);
      }
      return true;
    }
    
    final completer = Completer<bool>();
    
    _sendMessage({
      'type': _enableExtension,
      'enabled': enabled,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      final success = response != null;
      if (success && _cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(enabled: enabled);
        _settingsController.add(_cachedSettings!);
      }
      completer.complete(success);
    });
    
    return completer.future;
  }
  
  /// Update selected sites
  Future<bool> updateSelectedSites(List<SiteId> sites) async {
    if (!isExtensionContext) {
      // For development, just update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(enabledSites: sites.toSet());
        _settingsController.add(_cachedSettings!);
      }
      return true;
    }
    
    final completer = Completer<bool>();
    
    final siteStrings = sites.map((s) => s.toString().split('.').last).toList();
    _sendMessage({
      'type': _updateSites,
      'sites': siteStrings,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      final success = response != null;
      if (success && _cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(enabledSites: sites.toSet());
        _settingsController.add(_cachedSettings!);
      }
      completer.complete(success);
    });
    
    return completer.future;
  }
  
  /// Update extension settings (legacy method for compatibility)
  Future<bool> updateSettings(ExtensionSettings settings) async {
    // For now, just update enabled state and sites
    final enabledResult = await updateExtensionEnabled(settings.enabled);
    final sitesResult = await updateSelectedSites(settings.enabledSites.toList());
    return enabledResult && sitesResult;
  }
  
  /// Get site statistics (mock implementation)
  Future<List<SiteStats>> getStats() async {
    // Chrome extension doesn't currently track stats
    // Return mock data for now
    return _getMockStats();
  }
  
  /// Get current quote (not directly available from extension)
  Future<Quote?> getCurrentQuote() async {
    // Chrome extension doesn't expose current quote directly
    // We'll need to get a random quote from builtin quotes
    return const BuiltinQuote(
      id: 'mock-1',
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      category: 'motivation',
    );
  }
  
  /// Add a custom quote
  Future<bool> addCustomQuote(String text, String author) async {
    final quote = CustomQuote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: author,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (!isExtensionContext) {
      // For development, just add to cached settings
      if (_cachedSettings != null) {
        final updatedSettings = _cachedSettings!.copyWith(
          customQuotes: [..._cachedSettings!.customQuotes, quote],
        );
        _cachedSettings = updatedSettings;
        _settingsController.add(updatedSettings);
      }
      return true;
    }
    
    final completer = Completer<bool>();
    
    _sendMessage({
      'type': _addCustomQuote,
      'quote': {
        'text': text,
        'author': author,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      completer.complete(response != null);
    });
    
    return completer.future;
  }
  
  /// Delete a custom quote
  Future<bool> deleteCustomQuote(String quoteId) async {
    if (!isExtensionContext) {
      // For development, remove from cached settings
      if (_cachedSettings != null) {
        final updatedQuotes = _cachedSettings!.customQuotes
            .where((q) => q.id != quoteId)
            .toList();
        final updatedSettings = _cachedSettings!.copyWith(
          customQuotes: updatedQuotes,
        );
        _cachedSettings = updatedSettings;
        _settingsController.add(updatedSettings);
      }
      return true;
    }
    
    final completer = Completer<bool>();
    
    _sendMessage({
      'type': _removeCustomQuote,
      'quoteId': quoteId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      completer.complete(response != null);
    });
    
    return completer.future;
  }
  
  /// Trigger a new quote rotation
  Future<bool> rotateQuote() async {
    if (!isExtensionContext) {
      return true;
    }
    
    final completer = Completer<bool>();
    
    _sendMessage({
      'type': 'ROTATE_QUOTE',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, (response) {
      completer.complete(response?['success'] == true);
    });
    
    return completer.future;
  }
  
  /// Setup message listener for extension communication
  void _setupMessageListener() {
    html.window.addEventListener('message', (html.Event event) {
      final messageEvent = event as html.MessageEvent;
      
      if (messageEvent.origin != _messageOrigin) return;
      
      try {
        final data = json.decode(messageEvent.data as String);
        _handleMessage(data);
      } catch (e) {
        debugPrint('Error parsing extension message: $e');
      }
    });
  }
  
  /// Handle incoming messages from extension
  void _handleMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'SETTINGS_UPDATED':
        if (data['settings'] != null) {
          final settings = ExtensionSettings.fromJson(data['settings']);
          _cachedSettings = settings;
          _settingsController.add(settings);
        }
        break;
        
      case 'STATS_UPDATED':
        if (data['stats'] != null) {
          final statsList = (data['stats'] as List)
              .map((json) => SiteStats.fromJson(json))
              .toList();
          _statsController.add(statsList);
        }
        break;
        
      case 'QUOTE_CHANGED':
        if (data['quote'] != null) {
          final quoteData = data['quote'];
          Quote quote;
          
          if (quoteData['type'] == 'custom') {
            quote = CustomQuote.fromJson(quoteData);
          } else {
            quote = BuiltinQuote.fromJson(quoteData);
          }
          
          _currentQuoteController.add(quote);
        }
        break;
    }
  }
  
  /// Send message to extension
  void _sendMessage(Map<String, dynamic> message, Function(Map<String, dynamic>?) callback) {
    if (!kIsWeb) {
      callback(null);
      return;
    }
    
    try {
      // Use Chrome extension messaging API
      js.context.callMethod('chrome.runtime.sendMessage', [
        _extensionId,
        js.JsObject.jsify(message),
        js.allowInterop((response) {
          if (response != null) {
            callback(Map<String, dynamic>.from(response));
          } else {
            callback(null);
          }
        })
      ]);
    } catch (e) {
      debugPrint('Error sending message to extension: $e');
      callback(null);
    }
  }
  
  /// Request initial data from extension
  Future<void> _requestInitialData() async {
    await getSettings();
    
    // Request stats update (using mock data for now)
    _statsController.add(_getMockStats());
  }
  
  /// Generate mock stats for development
  List<SiteStats> _getMockStats() {
    return [
      SiteStats(
        siteId: SiteId.facebook,
        quotesShown: 15,
        feedsBlocked: 42,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        totalTimeActive: const Duration(hours: 3, minutes: 25),
      ),
      SiteStats(
        siteId: SiteId.twitter,
        quotesShown: 8,
        feedsBlocked: 23,
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
        totalTimeActive: const Duration(hours: 1, minutes: 45),
      ),
      SiteStats(
        siteId: SiteId.instagram,
        quotesShown: 12,
        feedsBlocked: 35,
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
        totalTimeActive: const Duration(hours: 2, minutes: 15),
      ),
    ];
  }
  
  /// Get a mock quote for development
  Quote _getMockQuote() {
    return const BuiltinQuote(
      id: 'mock-1',
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      category: 'motivation',
    );
  }

  /// Convert Chrome extension storage data to ExtensionSettings
  ExtensionSettings _convertStorageToSettings(Map<String, dynamic> storageData) {
    final enabledSites = <SiteId>[];
    if (storageData['sites'] != null) {
      final siteStrings = List<String>.from(storageData['sites']);
      for (final siteString in siteStrings) {
        switch (siteString) {
          case 'facebook':
            enabledSites.add(SiteId.facebook);
            break;
          case 'twitter':
            enabledSites.add(SiteId.twitter);
            break;
          case 'instagram':
            enabledSites.add(SiteId.instagram);
            break;
          case 'linkedin':
            enabledSites.add(SiteId.linkedin);
            break;
          case 'reddit':
            enabledSites.add(SiteId.reddit);
            break;
        }
      }
    }
    
    final customQuotes = <CustomQuote>[];
    if (storageData['customQuotes'] != null) {
      final quotesData = List<Map<String, dynamic>>.from(storageData['customQuotes']);
      for (final quoteData in quotesData) {
        customQuotes.add(CustomQuote(
          id: quoteData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          text: quoteData['text'] ?? '',
          author: quoteData['author'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }
    
    return ExtensionSettings(
      enabled: storageData['enabled'] ?? true,
      enabledSites: enabledSites.toSet(),
      customQuotes: customQuotes,
    );
  }
  
  /// Dispose resources
  void dispose() {
    _settingsController.close();
    _statsController.close();
    _currentQuoteController.close();
  }
}