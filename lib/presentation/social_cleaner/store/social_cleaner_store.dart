/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:09:32
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

import 'package:focus/core/constants/storage_keys.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';

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
    'threads': true,
    'reddit': true,
    'linkedin': true,
    'youtube': false,
    'github': false,
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
    if (enabled) {
      _ensureSitePermission(site);
    }
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

  Future<bool> _hasOptionalPermissions() async {
    try {
      if (!kIsWeb) return true;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final permissions = js_util.getProperty(chrome, 'permissions');
      final origins = _optionalOrigins();
      final granted = await js_util.promiseToFuture(
        js_util.callMethod(permissions, 'contains', [js_util.jsify({'origins': origins})]),
      );
      return granted == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _requestOptionalPermissions() async {
    try {
      if (!kIsWeb) return true;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final permissions = js_util.getProperty(chrome, 'permissions');
      final origins = _optionalOrigins();
      final granted = await js_util.promiseToFuture(
        js_util.callMethod(permissions, 'request', [js_util.jsify({'origins': origins})]),
      );
      return granted == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensureOptionalPermissions() async {
    final ok = await _hasOptionalPermissions();
    if (!ok) {
      await _requestOptionalPermissions();
    }
  }

  Future<void> _ensureSitePermission(String siteId) async {
    try {
      if (!kIsWeb) return;
      final origins = _originsForSite(siteId);
      if (origins.isEmpty) return;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final runtime = js_util.getProperty(chrome, 'runtime');
      await js_util.promiseToFuture(
        js_util.callMethod(runtime, 'sendMessage', [js_util.jsify({'action': 'requestOptionalPermissions', 'origins': origins})]),
      );
    } catch (_) {}
  }

  @action
  Future<bool> hasSitePermission(String siteId) async {
    try {
      if (!kIsWeb) return true;
      final origins = _originsForSite(siteId);
      if (origins.isEmpty) return true;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final permissions = js_util.getProperty(chrome, 'permissions');
      final granted = await js_util.promiseToFuture(
        js_util.callMethod(permissions, 'contains', [js_util.jsify({'origins': origins})]),
      );
      return granted == true;
    } catch (_) {
      return false;
    }
  }

  @action
  Future<bool> requestSitePermission(String siteId) async {
    try {
      if (!kIsWeb) return true;
      final origins = _originsForSite(siteId);
      if (origins.isEmpty) return true;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final runtime = js_util.getProperty(chrome, 'runtime');
      final res = await js_util.promiseToFuture(
        js_util.callMethod(runtime, 'sendMessage', [js_util.jsify({'action': 'requestOptionalPermissions', 'origins': origins})]),
      );
      return res is Map && res['granted'] == true;
    } catch (_) {
      return false;
    }
  }

  List<String> _originsForSite(String siteId) {
    switch (siteId) {
      case 'facebook':
        return const ['https://www.facebook.com/*', 'http://www.facebook.com/*', 'https://web.facebook.com/*', 'http://web.facebook.com/*'];
      case 'instagram':
        return const ['https://www.instagram.com/*', 'http://www.instagram.com/*'];
      case 'tiktok':
        return const ['https://www.tiktok.com/*'];
      case 'threads':
        return const ['https://www.threads.net/*', 'https://www.threads.com/*'];
      case 'twitter':
        return const ['https://twitter.com/*', 'http://twitter.com/*', 'https://x.com/*', 'http://x.com/*'];
      case 'reddit':
        return const ['https://www.reddit.com/*', 'http://www.reddit.com/*', 'https://old.reddit.com/*', 'http://old.reddit.com/*'];
      case 'linkedin':
        return const ['https://www.linkedin.com/*', 'http://www.linkedin.com/*'];
      case 'youtube':
        return const ['https://www.youtube.com/*'];
      case 'github':
        return const ['https://github.com/*', 'https://www.github.com/*'];
      case 'shopee':
        return const ['https://shopee.vn/*', 'https://shopee.com/*'];
      default:
        return const [];
    }
  }

  List<String> _optionalOrigins() {
    return const [
      'https://www.facebook.com/*',
      'https://web.facebook.com/*',
      'https://www.instagram.com/*',
      'https://www.threads.net/*',
      'https://www.threads.com/*',
      'https://www.tiktok.com/*',
      'https://twitter.com/*',
      'https://x.com/*',
      'https://www.reddit.com/*',
      'https://old.reddit.com/*',
      'https://www.linkedin.com/*',
      'https://www.youtube.com/*',
      'https://github.com/*',
      'https://shopee.vn/*',
      'https://shopee.com/*',
    ];
  }

  Map<String, dynamic> getCurrentSettings() {
    return _toJson();
  }
}
