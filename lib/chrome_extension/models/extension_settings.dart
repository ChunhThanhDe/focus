import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'quote.dart';
import 'site_config.dart';

part 'extension_settings.g.dart';

/// Quote display settings
@JsonSerializable()
class QuoteDisplaySettings extends Equatable {
  const QuoteDisplaySettings({
    this.showAuthor = true,
    this.fontSize = 18,
    this.fontFamily = 'Inter',
    this.textColor = '#333333',
    this.backgroundColor = '#ffffff',
    this.borderRadius = 8,
    this.padding = 24,
    this.animationDuration = 300,
    this.showQuoteMarks = true,
  });

  final bool showAuthor;
  final int fontSize;
  final String fontFamily;
  final String textColor;
  final String backgroundColor;
  final int borderRadius;
  final int padding;
  final int animationDuration;
  final bool showQuoteMarks;

  factory QuoteDisplaySettings.fromJson(Map<String, dynamic> json) => _$QuoteDisplaySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteDisplaySettingsToJson(this);

  QuoteDisplaySettings copyWith({
    bool? showAuthor,
    int? fontSize,
    String? fontFamily,
    String? textColor,
    String? backgroundColor,
    int? borderRadius,
    int? padding,
    int? animationDuration,
    bool? showQuoteMarks,
  }) {
    return QuoteDisplaySettings(
      showAuthor: showAuthor ?? this.showAuthor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      showQuoteMarks: showQuoteMarks ?? this.showQuoteMarks,
    );
  }

  @override
  List<Object?> get props => [
    showAuthor,
    fontSize,
    fontFamily,
    textColor,
    backgroundColor,
    borderRadius,
    padding,
    animationDuration,
    showQuoteMarks,
  ];
}

/// Quote rotation settings
@JsonSerializable()
class QuoteRotationSettings extends Equatable {
  const QuoteRotationSettings({
    this.enabled = true,
    this.intervalMinutes = 30,
    this.showOnPageLoad = true,
    this.showOnFeedBlock = true,
  });

  final bool enabled;
  final int intervalMinutes;
  final bool showOnPageLoad;
  final bool showOnFeedBlock;

  factory QuoteRotationSettings.fromJson(Map<String, dynamic> json) => _$QuoteRotationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteRotationSettingsToJson(this);

  QuoteRotationSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    bool? showOnPageLoad,
    bool? showOnFeedBlock,
  }) {
    return QuoteRotationSettings(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      showOnPageLoad: showOnPageLoad ?? this.showOnPageLoad,
      showOnFeedBlock: showOnFeedBlock ?? this.showOnFeedBlock,
    );
  }

  @override
  List<Object?> get props => [enabled, intervalMinutes, showOnPageLoad, showOnFeedBlock];
}

/// Feed blocking settings
@JsonSerializable()
class FeedBlockingSettings extends Equatable {
  const FeedBlockingSettings({
    this.enabled = true,
    this.blockMethod = BlockMethod.replace,
    this.showBlockedCount = true,
    this.allowManualUnblock = true,
  });

  final bool enabled;
  final BlockMethod blockMethod;
  final bool showBlockedCount;
  final bool allowManualUnblock;

  factory FeedBlockingSettings.fromJson(Map<String, dynamic> json) => _$FeedBlockingSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$FeedBlockingSettingsToJson(this);

  FeedBlockingSettings copyWith({
    bool? enabled,
    BlockMethod? blockMethod,
    bool? showBlockedCount,
    bool? allowManualUnblock,
  }) {
    return FeedBlockingSettings(
      enabled: enabled ?? this.enabled,
      blockMethod: blockMethod ?? this.blockMethod,
      showBlockedCount: showBlockedCount ?? this.showBlockedCount,
      allowManualUnblock: allowManualUnblock ?? this.allowManualUnblock,
    );
  }

  @override
  List<Object?> get props => [enabled, blockMethod, showBlockedCount, allowManualUnblock];
}

/// Method for blocking feeds
enum BlockMethod {
  hide,
  replace,
  blur;

  String get displayName {
    switch (this) {
      case BlockMethod.hide:
        return 'Hide completely';
      case BlockMethod.replace:
        return 'Replace with quote';
      case BlockMethod.blur:
        return 'Blur content';
    }
  }

  String get description {
    switch (this) {
      case BlockMethod.hide:
        return 'Completely removes feed items from view';
      case BlockMethod.replace:
        return 'Replaces feed items with inspirational quotes';
      case BlockMethod.blur:
        return 'Blurs feed content while keeping layout';
    }
  }
}

/// Main extension settings
@JsonSerializable()
class ExtensionSettings extends Equatable {
  const ExtensionSettings({
    this.enabled = true,
    this.quoteSource = QuoteSource.builtin,
    this.selectedCategories = const [QuoteCategory.motivation, QuoteCategory.productivity],
    this.quoteDisplay = const QuoteDisplaySettings(),
    this.quoteRotation = const QuoteRotationSettings(),
    this.feedBlocking = const FeedBlockingSettings(),
    this.enabledSites = const {
      SiteId.facebook,
      SiteId.twitter,
      SiteId.instagram,
      SiteId.linkedin,
      SiteId.reddit,
    },
    this.customQuotes = const [],
    this.version = '1.0.0',
  });

  final bool enabled;
  final QuoteSource quoteSource;
  final List<QuoteCategory> selectedCategories;
  final QuoteDisplaySettings quoteDisplay;
  final QuoteRotationSettings quoteRotation;
  final FeedBlockingSettings feedBlocking;
  final Set<SiteId> enabledSites;
  final List<CustomQuote> customQuotes;
  final String version;

  factory ExtensionSettings.fromJson(Map<String, dynamic> json) => _$ExtensionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ExtensionSettingsToJson(this);

  ExtensionSettings copyWith({
    bool? enabled,
    QuoteSource? quoteSource,
    List<QuoteCategory>? selectedCategories,
    QuoteDisplaySettings? quoteDisplay,
    QuoteRotationSettings? quoteRotation,
    FeedBlockingSettings? feedBlocking,
    Set<SiteId>? enabledSites,
    List<CustomQuote>? customQuotes,
    String? version,
  }) {
    return ExtensionSettings(
      enabled: enabled ?? this.enabled,
      quoteSource: quoteSource ?? this.quoteSource,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      quoteDisplay: quoteDisplay ?? this.quoteDisplay,
      quoteRotation: quoteRotation ?? this.quoteRotation,
      feedBlocking: feedBlocking ?? this.feedBlocking,
      enabledSites: enabledSites ?? this.enabledSites,
      customQuotes: customQuotes ?? this.customQuotes,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    quoteSource,
    selectedCategories,
    quoteDisplay,
    quoteRotation,
    feedBlocking,
    enabledSites,
    customQuotes,
    version,
  ];
}