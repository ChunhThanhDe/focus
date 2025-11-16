// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteSelectors _$SiteSelectorsFromJson(
  Map<String, dynamic> json,
) => SiteSelectors(
  feedContainer:
      (json['feedContainer'] as List<dynamic>).map((e) => e as String).toList(),
  feedItems:
      (json['feedItems'] as List<dynamic>).map((e) => e as String).toList(),
  sidebarAds:
      (json['sidebarAds'] as List<dynamic>?)?.map((e) => e as String).toList(),
  notifications:
      (json['notifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$SiteSelectorsToJson(SiteSelectors instance) =>
    <String, dynamic>{
      'feedContainer': instance.feedContainer,
      'feedItems': instance.feedItems,
      'sidebarAds': instance.sidebarAds,
      'notifications': instance.notifications,
    };

SiteConfig _$SiteConfigFromJson(Map<String, dynamic> json) => SiteConfig(
  id: $enumDecode(_$SiteIdEnumMap, json['id']),
  name: json['name'] as String,
  domain: json['domain'] as String,
  selectors: SiteSelectors.fromJson(json['selectors'] as Map<String, dynamic>),
  enabled: json['enabled'] as bool,
  customCSS: json['customCSS'] as String?,
);

Map<String, dynamic> _$SiteConfigToJson(SiteConfig instance) =>
    <String, dynamic>{
      'id': _$SiteIdEnumMap[instance.id]!,
      'name': instance.name,
      'domain': instance.domain,
      'selectors': instance.selectors,
      'customCSS': instance.customCSS,
      'enabled': instance.enabled,
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

SiteStats _$SiteStatsFromJson(Map<String, dynamic> json) => SiteStats(
  siteId: $enumDecode(_$SiteIdEnumMap, json['siteId']),
  quotesShown: (json['quotesShown'] as num).toInt(),
  feedsBlocked: (json['feedsBlocked'] as num).toInt(),
  lastActive: DateTime.parse(json['lastActive'] as String),
  totalTimeActive: Duration(
    microseconds: (json['totalTimeActive'] as num).toInt(),
  ),
);

Map<String, dynamic> _$SiteStatsToJson(SiteStats instance) => <String, dynamic>{
  'siteId': _$SiteIdEnumMap[instance.siteId]!,
  'quotesShown': instance.quotesShown,
  'feedsBlocked': instance.feedsBlocked,
  'lastActive': instance.lastActive.toIso8601String(),
  'totalTimeActive': instance.totalTimeActive.inMicroseconds,
};
