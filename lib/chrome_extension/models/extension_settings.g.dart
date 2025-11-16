// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteDisplaySettings _$QuoteDisplaySettingsFromJson(
  Map<String, dynamic> json,
) => QuoteDisplaySettings(
  showAuthor: json['showAuthor'] as bool? ?? true,
  fontSize: (json['fontSize'] as num?)?.toInt() ?? 18,
  fontFamily: json['fontFamily'] as String? ?? 'Inter',
  textColor: json['textColor'] as String? ?? '#333333',
  backgroundColor: json['backgroundColor'] as String? ?? '#ffffff',
  borderRadius: (json['borderRadius'] as num?)?.toInt() ?? 8,
  padding: (json['padding'] as num?)?.toInt() ?? 24,
  animationDuration: (json['animationDuration'] as num?)?.toInt() ?? 300,
  showQuoteMarks: json['showQuoteMarks'] as bool? ?? true,
);

Map<String, dynamic> _$QuoteDisplaySettingsToJson(
  QuoteDisplaySettings instance,
) => <String, dynamic>{
  'showAuthor': instance.showAuthor,
  'fontSize': instance.fontSize,
  'fontFamily': instance.fontFamily,
  'textColor': instance.textColor,
  'backgroundColor': instance.backgroundColor,
  'borderRadius': instance.borderRadius,
  'padding': instance.padding,
  'animationDuration': instance.animationDuration,
  'showQuoteMarks': instance.showQuoteMarks,
};

QuoteRotationSettings _$QuoteRotationSettingsFromJson(
  Map<String, dynamic> json,
) => QuoteRotationSettings(
  enabled: json['enabled'] as bool? ?? true,
  intervalMinutes: (json['intervalMinutes'] as num?)?.toInt() ?? 30,
  showOnPageLoad: json['showOnPageLoad'] as bool? ?? true,
  showOnFeedBlock: json['showOnFeedBlock'] as bool? ?? true,
);

Map<String, dynamic> _$QuoteRotationSettingsToJson(
  QuoteRotationSettings instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'intervalMinutes': instance.intervalMinutes,
  'showOnPageLoad': instance.showOnPageLoad,
  'showOnFeedBlock': instance.showOnFeedBlock,
};

FeedBlockingSettings _$FeedBlockingSettingsFromJson(
  Map<String, dynamic> json,
) => FeedBlockingSettings(
  enabled: json['enabled'] as bool? ?? true,
  blockMethod:
      $enumDecodeNullable(_$BlockMethodEnumMap, json['blockMethod']) ??
      BlockMethod.replace,
  showBlockedCount: json['showBlockedCount'] as bool? ?? true,
  allowManualUnblock: json['allowManualUnblock'] as bool? ?? true,
);

Map<String, dynamic> _$FeedBlockingSettingsToJson(
  FeedBlockingSettings instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'blockMethod': _$BlockMethodEnumMap[instance.blockMethod]!,
  'showBlockedCount': instance.showBlockedCount,
  'allowManualUnblock': instance.allowManualUnblock,
};

const _$BlockMethodEnumMap = {
  BlockMethod.hide: 'hide',
  BlockMethod.replace: 'replace',
  BlockMethod.blur: 'blur',
};

ExtensionSettings _$ExtensionSettingsFromJson(Map<String, dynamic> json) =>
    ExtensionSettings(
      enabled: json['enabled'] as bool? ?? true,
      quoteSource:
          $enumDecodeNullable(_$QuoteSourceEnumMap, json['quoteSource']) ??
          QuoteSource.builtin,
      selectedCategories:
          (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$QuoteCategoryEnumMap, e))
              .toList() ??
          const [QuoteCategory.motivation, QuoteCategory.productivity],
      quoteDisplay:
          json['quoteDisplay'] == null
              ? const QuoteDisplaySettings()
              : QuoteDisplaySettings.fromJson(
                json['quoteDisplay'] as Map<String, dynamic>,
              ),
      quoteRotation:
          json['quoteRotation'] == null
              ? const QuoteRotationSettings()
              : QuoteRotationSettings.fromJson(
                json['quoteRotation'] as Map<String, dynamic>,
              ),
      feedBlocking:
          json['feedBlocking'] == null
              ? const FeedBlockingSettings()
              : FeedBlockingSettings.fromJson(
                json['feedBlocking'] as Map<String, dynamic>,
              ),
      enabledSites:
          (json['enabledSites'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$SiteIdEnumMap, e))
              .toSet() ??
          const {
            SiteId.facebook,
            SiteId.twitter,
            SiteId.instagram,
            SiteId.linkedin,
            SiteId.reddit,
          },
      customQuotes:
          (json['customQuotes'] as List<dynamic>?)
              ?.map((e) => CustomQuote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      version: json['version'] as String? ?? '1.0.0',
    );

Map<String, dynamic> _$ExtensionSettingsToJson(ExtensionSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'quoteSource': _$QuoteSourceEnumMap[instance.quoteSource]!,
      'selectedCategories':
          instance.selectedCategories
              .map((e) => _$QuoteCategoryEnumMap[e]!)
              .toList(),
      'quoteDisplay': instance.quoteDisplay,
      'quoteRotation': instance.quoteRotation,
      'feedBlocking': instance.feedBlocking,
      'enabledSites':
          instance.enabledSites.map((e) => _$SiteIdEnumMap[e]!).toList(),
      'customQuotes': instance.customQuotes,
      'version': instance.version,
    };

const _$QuoteSourceEnumMap = {
  QuoteSource.builtin: 'builtin',
  QuoteSource.custom: 'custom',
  QuoteSource.mixed: 'mixed',
};

const _$QuoteCategoryEnumMap = {
  QuoteCategory.motivation: 'motivation',
  QuoteCategory.productivity: 'productivity',
  QuoteCategory.success: 'success',
  QuoteCategory.wisdom: 'wisdom',
  QuoteCategory.inspiration: 'inspiration',
  QuoteCategory.mindfulness: 'mindfulness',
  QuoteCategory.general: 'general',
};

const _$SiteIdEnumMap = {
  SiteId.facebook: 'facebook',
  SiteId.twitter: 'twitter',
  SiteId.instagram: 'instagram',
  SiteId.linkedin: 'linkedin',
  SiteId.reddit: 'reddit',
  SiteId.youtube: 'youtube',
  SiteId.github: 'github',
  SiteId.hackernews: 'hackernews',
};
