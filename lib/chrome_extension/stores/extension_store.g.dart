// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExtensionStore on _ExtensionStore, Store {
  Computed<bool>? _$isExtensionEnabledComputed;

  @override
  bool get isExtensionEnabled =>
      (_$isExtensionEnabledComputed ??= Computed<bool>(
            () => super.isExtensionEnabled,
            name: '_ExtensionStore.isExtensionEnabled',
          ))
          .value;
  Computed<int>? _$totalQuotesShownComputed;

  @override
  int get totalQuotesShown =>
      (_$totalQuotesShownComputed ??= Computed<int>(
            () => super.totalQuotesShown,
            name: '_ExtensionStore.totalQuotesShown',
          ))
          .value;
  Computed<int>? _$totalFeedsBlockedComputed;

  @override
  int get totalFeedsBlocked =>
      (_$totalFeedsBlockedComputed ??= Computed<int>(
            () => super.totalFeedsBlocked,
            name: '_ExtensionStore.totalFeedsBlocked',
          ))
          .value;
  Computed<Duration>? _$totalTimeActiveComputed;

  @override
  Duration get totalTimeActive =>
      (_$totalTimeActiveComputed ??= Computed<Duration>(
            () => super.totalTimeActive,
            name: '_ExtensionStore.totalTimeActive',
          ))
          .value;
  Computed<List<SiteId>>? _$enabledSitesComputed;

  @override
  List<SiteId> get enabledSites =>
      (_$enabledSitesComputed ??= Computed<List<SiteId>>(
            () => super.enabledSites,
            name: '_ExtensionStore.enabledSites',
          ))
          .value;
  Computed<List<CustomQuote>>? _$customQuotesComputed;

  @override
  List<CustomQuote> get customQuotes =>
      (_$customQuotesComputed ??= Computed<List<CustomQuote>>(
            () => super.customQuotes,
            name: '_ExtensionStore.customQuotes',
          ))
          .value;
  Computed<bool>? _$hasCustomQuotesComputed;

  @override
  bool get hasCustomQuotes =>
      (_$hasCustomQuotesComputed ??= Computed<bool>(
            () => super.hasCustomQuotes,
            name: '_ExtensionStore.hasCustomQuotes',
          ))
          .value;

  late final _$initializedAtom = Atom(
    name: '_ExtensionStore.initialized',
    context: context,
  );

  @override
  bool get initialized {
    _$initializedAtom.reportRead();
    return super.initialized;
  }

  @override
  set initialized(bool value) {
    _$initializedAtom.reportWrite(value, super.initialized, () {
      super.initialized = value;
    });
  }

  late final _$loadingAtom = Atom(
    name: '_ExtensionStore.loading',
    context: context,
  );

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$settingsAtom = Atom(
    name: '_ExtensionStore.settings',
    context: context,
  );

  @override
  ExtensionSettings? get settings {
    _$settingsAtom.reportRead();
    return super.settings;
  }

  @override
  set settings(ExtensionSettings? value) {
    _$settingsAtom.reportWrite(value, super.settings, () {
      super.settings = value;
    });
  }

  late final _$statsAtom = Atom(
    name: '_ExtensionStore.stats',
    context: context,
  );

  @override
  List<SiteStats> get stats {
    _$statsAtom.reportRead();
    return super.stats;
  }

  @override
  set stats(List<SiteStats> value) {
    _$statsAtom.reportWrite(value, super.stats, () {
      super.stats = value;
    });
  }

  late final _$currentQuoteAtom = Atom(
    name: '_ExtensionStore.currentQuote',
    context: context,
  );

  @override
  Quote? get currentQuote {
    _$currentQuoteAtom.reportRead();
    return super.currentQuote;
  }

  @override
  set currentQuote(Quote? value) {
    _$currentQuoteAtom.reportWrite(value, super.currentQuote, () {
      super.currentQuote = value;
    });
  }

  late final _$errorAtom = Atom(
    name: '_ExtensionStore.error',
    context: context,
  );

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$initializeAsyncAction = AsyncAction(
    '_ExtensionStore.initialize',
    context: context,
  );

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$_loadSettingsAsyncAction = AsyncAction(
    '_ExtensionStore._loadSettings',
    context: context,
  );

  @override
  Future<void> _loadSettings() {
    return _$_loadSettingsAsyncAction.run(() => super._loadSettings());
  }

  late final _$_loadStatsAsyncAction = AsyncAction(
    '_ExtensionStore._loadStats',
    context: context,
  );

  @override
  Future<void> _loadStats() {
    return _$_loadStatsAsyncAction.run(() => super._loadStats());
  }

  late final _$_loadCurrentQuoteAsyncAction = AsyncAction(
    '_ExtensionStore._loadCurrentQuote',
    context: context,
  );

  @override
  Future<void> _loadCurrentQuote() {
    return _$_loadCurrentQuoteAsyncAction.run(() => super._loadCurrentQuote());
  }

  late final _$updateExtensionEnabledAsyncAction = AsyncAction(
    '_ExtensionStore.updateExtensionEnabled',
    context: context,
  );

  @override
  Future<bool> updateExtensionEnabled(bool enabled) {
    return _$updateExtensionEnabledAsyncAction.run(
      () => super.updateExtensionEnabled(enabled),
    );
  }

  late final _$updateSelectedSitesAsyncAction = AsyncAction(
    '_ExtensionStore.updateSelectedSites',
    context: context,
  );

  @override
  Future<bool> updateSelectedSites(List<SiteId> sites) {
    return _$updateSelectedSitesAsyncAction.run(
      () => super.updateSelectedSites(sites),
    );
  }

  late final _$updateSettingsAsyncAction = AsyncAction(
    '_ExtensionStore.updateSettings',
    context: context,
  );

  @override
  Future<bool> updateSettings(ExtensionSettings newSettings) {
    return _$updateSettingsAsyncAction.run(
      () => super.updateSettings(newSettings),
    );
  }

  late final _$toggleExtensionAsyncAction = AsyncAction(
    '_ExtensionStore.toggleExtension',
    context: context,
  );

  @override
  Future<bool> toggleExtension() {
    return _$toggleExtensionAsyncAction.run(() => super.toggleExtension());
  }

  late final _$toggleSiteAsyncAction = AsyncAction(
    '_ExtensionStore.toggleSite',
    context: context,
  );

  @override
  Future<bool> toggleSite(SiteId siteId) {
    return _$toggleSiteAsyncAction.run(() => super.toggleSite(siteId));
  }

  late final _$updateQuoteSourceAsyncAction = AsyncAction(
    '_ExtensionStore.updateQuoteSource',
    context: context,
  );

  @override
  Future<bool> updateQuoteSource(QuoteSource source) {
    return _$updateQuoteSourceAsyncAction.run(
      () => super.updateQuoteSource(source),
    );
  }

  late final _$updateQuoteCategoriesAsyncAction = AsyncAction(
    '_ExtensionStore.updateQuoteCategories',
    context: context,
  );

  @override
  Future<bool> updateQuoteCategories(List<QuoteCategory> categories) {
    return _$updateQuoteCategoriesAsyncAction.run(
      () => super.updateQuoteCategories(categories),
    );
  }

  late final _$updateQuoteDisplayAsyncAction = AsyncAction(
    '_ExtensionStore.updateQuoteDisplay',
    context: context,
  );

  @override
  Future<bool> updateQuoteDisplay(QuoteDisplaySettings displaySettings) {
    return _$updateQuoteDisplayAsyncAction.run(
      () => super.updateQuoteDisplay(displaySettings),
    );
  }

  late final _$updateQuoteRotationAsyncAction = AsyncAction(
    '_ExtensionStore.updateQuoteRotation',
    context: context,
  );

  @override
  Future<bool> updateQuoteRotation(QuoteRotationSettings rotationSettings) {
    return _$updateQuoteRotationAsyncAction.run(
      () => super.updateQuoteRotation(rotationSettings),
    );
  }

  late final _$updateFeedBlockingAsyncAction = AsyncAction(
    '_ExtensionStore.updateFeedBlocking',
    context: context,
  );

  @override
  Future<bool> updateFeedBlocking(FeedBlockingSettings blockingSettings) {
    return _$updateFeedBlockingAsyncAction.run(
      () => super.updateFeedBlocking(blockingSettings),
    );
  }

  late final _$addCustomQuoteAsyncAction = AsyncAction(
    '_ExtensionStore.addCustomQuote',
    context: context,
  );

  @override
  Future<bool> addCustomQuote(String text, String author) {
    return _$addCustomQuoteAsyncAction.run(
      () => super.addCustomQuote(text, author),
    );
  }

  late final _$deleteCustomQuoteAsyncAction = AsyncAction(
    '_ExtensionStore.deleteCustomQuote',
    context: context,
  );

  @override
  Future<bool> deleteCustomQuote(String quoteId) {
    return _$deleteCustomQuoteAsyncAction.run(
      () => super.deleteCustomQuote(quoteId),
    );
  }

  late final _$rotateQuoteAsyncAction = AsyncAction(
    '_ExtensionStore.rotateQuote',
    context: context,
  );

  @override
  Future<bool> rotateQuote() {
    return _$rotateQuoteAsyncAction.run(() => super.rotateQuote());
  }

  late final _$refreshAsyncAction = AsyncAction(
    '_ExtensionStore.refresh',
    context: context,
  );

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$_ExtensionStoreActionController = ActionController(
    name: '_ExtensionStore',
    context: context,
  );

  @override
  void clearError() {
    final _$actionInfo = _$_ExtensionStoreActionController.startAction(
      name: '_ExtensionStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_ExtensionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
initialized: ${initialized},
loading: ${loading},
settings: ${settings},
stats: ${stats},
currentQuote: ${currentQuote},
error: ${error},
isExtensionEnabled: ${isExtensionEnabled},
totalQuotesShown: ${totalQuotesShown},
totalFeedsBlocked: ${totalFeedsBlocked},
totalTimeActive: ${totalTimeActive},
enabledSites: ${enabledSites},
customQuotes: ${customQuotes},
hasCustomQuotes: ${hasCustomQuotes}
    ''';
  }
}
