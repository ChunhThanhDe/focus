/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:09:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:developer';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
  String builtinQuotesLang = 'en';

  @observable
  ObservableList<String> builtinQuotesEn = ObservableList<String>();

  @observable
  ObservableList<String> builtinQuotesVi = ObservableList<String>();

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
        await _ensureBuiltinQuotesFromAssets();
        log('Social Cleaner settings loaded from storage');
      } else {
        // Set default settings and save them
        _setDefaultValues();
        await _ensureBuiltinQuotesFromAssets();
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
  void updateBuiltinQuotesLang(String lang) {
    if (lang == 'en' || lang == 'vi') {
      update(() => builtinQuotesLang = lang);
    }
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
  void addBuiltinQuote(String quote) {
    final q = quote.trim();
    if (q.isEmpty) return;
    if (builtinQuotesLang == 'vi') {
      if (!builtinQuotesVi.contains(q)) update(() => builtinQuotesVi.add(q));
    } else {
      if (!builtinQuotesEn.contains(q)) update(() => builtinQuotesEn.add(q));
    }
  }

  @action
  void removeCustomQuote(int index) {
    if (index >= 0 && index < customQuotes.length) {
      update(() => customQuotes.removeAt(index));
    }
  }

  @action
  void removeBuiltinQuote(int index) {
    if (builtinQuotesLang == 'vi') {
      if (index >= 0 && index < builtinQuotesVi.length) {
        update(() => builtinQuotesVi.removeAt(index));
      }
    } else {
      if (index >= 0 && index < builtinQuotesEn.length) {
        update(() => builtinQuotesEn.removeAt(index));
      }
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
      _setDefaultValues();
    });
  }

  void _setDefaultValues() {
    enabled = true;
    showQuotes = true;
    builtinQuotesEnabled = true;
    builtinQuotesLang = 'en';
    customQuotes.clear();
    builtinQuotesEn.clear();
    builtinQuotesVi.clear();
    siteSettings.clear();
    siteSettings.addAll(_defaultSiteSettings);
  }

  Future<void> _ensureBuiltinQuotesFromAssets() async {
    try {
      final needEn = builtinQuotesEn.isEmpty;
      final needVi = builtinQuotesVi.isEmpty;
      if (!needEn && !needVi) return;
      String? enStr;
      String? viStr;
      if (needEn) {
        enStr = await rootBundle.loadString('assets/translations/en.json');
      }
      if (needVi) {
        viStr = await rootBundle.loadString('assets/translations/vi.json');
      }
      if (enStr != null && enStr.isNotEmpty) {
        final Map<String, dynamic> enJson = json.decode(enStr);
        final List<dynamic>? arr = (enJson['quotes'] is Map) ? (enJson['quotes']['builtin'] as List?) : null;
        if (arr != null && arr.isNotEmpty) {
          builtinQuotesEn.clear();
          builtinQuotesEn.addAll(arr.cast<String>());
        }
      }
      if (viStr != null && viStr.isNotEmpty) {
        final Map<String, dynamic> viJson = json.decode(viStr);
        final List<dynamic>? arr = (viJson['quotes'] is Map) ? (viJson['quotes']['builtin'] as List?) : null;
        if (arr != null && arr.isNotEmpty) {
          builtinQuotesVi.clear();
          builtinQuotesVi.addAll(arr.cast<String>());
        }
      }
    } catch (_) {}
  }

  void _updateFromJson(Map<String, dynamic> json) {
    enabled = json['enabled'] ?? true;
    showQuotes = json['showQuotes'] ?? true;
    builtinQuotesEnabled = json['builtinQuotesEnabled'] ?? true;
    builtinQuotesLang = json['builtinQuotesLang'] ?? 'en';

    customQuotes.clear();
    if (json['customQuotes'] is List) {
      customQuotes.addAll((json['customQuotes'] as List).cast<String>());
    }

    builtinQuotesEn.clear();
    if (json['builtinQuotesEn'] is List) {
      builtinQuotesEn.addAll((json['builtinQuotesEn'] as List).cast<String>());
    }
    builtinQuotesVi.clear();
    if (json['builtinQuotesVi'] is List) {
      builtinQuotesVi.addAll((json['builtinQuotesVi'] as List).cast<String>());
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
      'builtinQuotesLang': builtinQuotesLang,
      'builtinQuotesEn': builtinQuotesEn.toList(),
      'builtinQuotesVi': builtinQuotesVi.toList(),
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
