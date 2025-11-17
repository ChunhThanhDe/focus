/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:09:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:developer';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

import '../resources/storage_keys.dart';
import 'storage_manager.dart';

part 'social_cleaner_store.g.dart';

// ignore: library_private_types_in_public_api
class SocialCleanerStore = _SocialCleanerStore with _$SocialCleanerStore;

abstract class _SocialCleanerStore with Store {
  late final LocalStorageManager storage = GetIt.instance.get<LocalStorageManager>();

  @observable
  bool enabled = true;

  @observable
  bool showQuotes = true;

  @observable
  bool builtinQuotesEnabled = true;

  @observable
  ObservableList<String> customQuotes = ObservableList<String>();

  @observable
  ObservableMap<String, bool> siteSettings = ObservableMap<String, bool>();

  // Default site settings
  final Map<String, bool> _defaultSiteSettings = {
    'facebook': true,
    'instagram': true,
    'tiktok': true,
    'twitter': true,
    'reddit': true,
    'linkedin': true,
    'youtube': true,
    'github': true,
    'hackernews': true,
    'shopee': true,
  };

  @action
  Future<void> loadSettings() async {
    try {
      // Load from LocalStorageManager using the same pattern as widget stores
      final data = await storage.getSerializableObject<Map<String, dynamic>>(
        StorageKeys.socialCleanerSettings,
        (json) => json,
      );

      if (data != null) {
        _updateFromJson(data);
        log('Social Cleaner settings loaded from storage');
      } else {
        // Set default settings and save them
        _setDefaultValues();
        await _save();
        log('Social Cleaner default settings applied and saved');
      }
    } catch (e) {
      log('Error loading social cleaner settings: $e');
      _setDefaultValues();
    }
  }

  @action
  void updateEnabled(bool value) {
    update(() => enabled = value);
  }

  @action
  void updateShowQuotes(bool value) {
    update(() => showQuotes = value);
  }

  @action
  void updateBuiltinQuotesEnabled(bool value) {
    update(() => builtinQuotesEnabled = value);
  }

  @action
  void updateCustomQuotes(List<String> quotes) {
    update(() {
      customQuotes.clear();
      customQuotes.addAll(quotes);
    });
  }

  @action
  void updateSiteEnabled(String site, bool enabled) {
    update(() => siteSettings[site] = enabled);
  }

  @action
  void addCustomQuote(String quote) {
    if (quote.trim().isNotEmpty && !customQuotes.contains(quote.trim())) {
      update(() => customQuotes.add(quote.trim()));
    }
  }

  @action
  void removeCustomQuote(int index) {
    if (index >= 0 && index < customQuotes.length) {
      update(() => customQuotes.removeAt(index));
    }
  }

  @action
  void update(VoidCallback callback, {bool save = true}) {
    callback();
    if (save) {
      _save();
    }
  }

  bool isSiteEnabled(String siteId) {
    return siteSettings[siteId] ?? _defaultSiteSettings[siteId] ?? true;
  }

  @action
  Future<void> resetSettings() async {
    update(() {
      enabled = true;
      showQuotes = true;
      builtinQuotesEnabled = true;
      customQuotes.clear();
      siteSettings.clear();
      siteSettings.addAll(_defaultSiteSettings);
    });
  }

  void _setDefaultValues() {
    enabled = true;
    showQuotes = true;
    builtinQuotesEnabled = true;
    customQuotes.clear();
    siteSettings.clear();
    siteSettings.addAll(_defaultSiteSettings);
  }

  void _updateFromJson(Map<String, dynamic> json) {
    enabled = json['enabled'] ?? true;
    showQuotes = json['showQuotes'] ?? true;
    builtinQuotesEnabled = json['builtinQuotesEnabled'] ?? true;

    customQuotes.clear();
    if (json['customQuotes'] is List) {
      customQuotes.addAll((json['customQuotes'] as List).cast<String>());
    }

    siteSettings.clear();
    if (json['sites'] is Map) {
      final sites = json['sites'] as Map<String, dynamic>;
      for (final entry in sites.entries) {
        if (entry.value is Map && entry.value['enabled'] is bool) {
          siteSettings[entry.key] = entry.value['enabled'];
        }
      }
    }

    // Ensure all default sites are present
    for (final entry in _defaultSiteSettings.entries) {
      if (!siteSettings.containsKey(entry.key)) {
        siteSettings[entry.key] = entry.value;
      }
    }
  }

  Map<String, dynamic> _toJson() {
    return {
      'enabled': enabled,
      'showQuotes': showQuotes,
      'builtinQuotesEnabled': builtinQuotesEnabled,
      'customQuotes': customQuotes.toList(),
      'sites': Map.fromEntries(
        siteSettings.entries.map(
          (entry) => MapEntry(entry.key, {'enabled': entry.value}),
        ),
      ),
    };
  }

  /// Saves the current settings to storage using LocalStorageManager (same pattern as widget stores)
  Future<void> _save() async {
    try {
      final settings = _toJson();
      await storage.setJson(StorageKeys.socialCleanerSettings, settings);
      log('Social Cleaner settings saved to storage');
      _notifyBackground(settings);
    } catch (e) {
      log('Error saving social cleaner settings: $e');
    }
  }

  void _notifyBackground(Map<String, dynamic> settings) {
    try {
      if (!kIsWeb) return;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      if (chrome == null) return;
      final runtime = js_util.getProperty(chrome, 'runtime');
      final message = {
        'action': 'updateSocialCleanerSettings',
        'settings': settings,
      };
      js_util.callMethod(runtime, 'sendMessage', [js_util.jsify(message)]);
    } catch (_) {}
  }

  Map<String, dynamic> getCurrentSettings() {
    return _toJson();
  }
}
