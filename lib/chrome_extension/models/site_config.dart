import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'site_config.g.dart';

/// Supported social media sites
enum SiteId {
  facebook,
  twitter,
  instagram,
  linkedin,
  reddit,
  youtube,
  github,
  hackernews;

  String get displayName {
    switch (this) {
      case SiteId.facebook:
        return 'Facebook';
      case SiteId.twitter:
        return 'Twitter/X';
      case SiteId.instagram:
        return 'Instagram';
      case SiteId.linkedin:
        return 'LinkedIn';
      case SiteId.reddit:
        return 'Reddit';
      case SiteId.youtube:
        return 'YouTube';
      case SiteId.github:
        return 'GitHub';
      case SiteId.hackernews:
        return 'Hacker News';
    }
  }

  String get domain {
    switch (this) {
      case SiteId.facebook:
        return 'facebook.com';
      case SiteId.twitter:
        return 'twitter.com / x.com';
      case SiteId.instagram:
        return 'instagram.com';
      case SiteId.linkedin:
        return 'linkedin.com';
      case SiteId.reddit:
        return 'reddit.com';
      case SiteId.youtube:
        return 'youtube.com';
      case SiteId.github:
        return 'github.com';
      case SiteId.hackernews:
        return 'news.ycombinator.com';
    }
  }

  String get iconPath {
    switch (this) {
      case SiteId.facebook:
        return 'assets/icons/facebook.svg';
      case SiteId.twitter:
        return 'assets/icons/twitter.svg';
      case SiteId.instagram:
        return 'assets/icons/instagram.svg';
      case SiteId.linkedin:
        return 'assets/icons/linkedin.svg';
      case SiteId.reddit:
        return 'assets/icons/reddit.svg';
      case SiteId.youtube:
        return 'assets/icons/youtube.svg';
      case SiteId.github:
        return 'assets/icons/github.svg';
      case SiteId.hackernews:
        return 'assets/icons/hackernews.svg';
    }
  }
}

/// Site-specific selectors for DOM manipulation
@JsonSerializable()
class SiteSelectors extends Equatable {
  const SiteSelectors({
    required this.feedContainer,
    required this.feedItems,
    this.sidebarAds,
    this.notifications,
  });

  final List<String> feedContainer;
  final List<String> feedItems;
  final List<String>? sidebarAds;
  final List<String>? notifications;

  factory SiteSelectors.fromJson(Map<String, dynamic> json) => _$SiteSelectorsFromJson(json);
  Map<String, dynamic> toJson() => _$SiteSelectorsToJson(this);

  @override
  List<Object?> get props => [feedContainer, feedItems, sidebarAds, notifications];
}

/// Configuration for a specific social media site
@JsonSerializable()
class SiteConfig extends Equatable {
  const SiteConfig({
    required this.id,
    required this.name,
    required this.domain,
    required this.selectors,
    required this.enabled,
    this.customCSS,
  });

  final SiteId id;
  final String name;
  final String domain;
  final SiteSelectors selectors;
  final String? customCSS;
  final bool enabled;

  factory SiteConfig.fromJson(Map<String, dynamic> json) => _$SiteConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SiteConfigToJson(this);

  SiteConfig copyWith({
    SiteId? id,
    String? name,
    String? domain,
    SiteSelectors? selectors,
    String? customCSS,
    bool? enabled,
  }) {
    return SiteConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      selectors: selectors ?? this.selectors,
      customCSS: customCSS ?? this.customCSS,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [id, name, domain, selectors, customCSS, enabled];
}

/// Site statistics for usage tracking
@JsonSerializable()
class SiteStats extends Equatable {
  const SiteStats({
    required this.siteId,
    required this.quotesShown,
    required this.feedsBlocked,
    required this.lastActive,
    required this.totalTimeActive,
  });

  final SiteId siteId;
  final int quotesShown;
  final int feedsBlocked;
  final DateTime lastActive;
  final Duration totalTimeActive;

  factory SiteStats.fromJson(Map<String, dynamic> json) => _$SiteStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SiteStatsToJson(this);

  SiteStats copyWith({
    SiteId? siteId,
    int? quotesShown,
    int? feedsBlocked,
    DateTime? lastActive,
    Duration? totalTimeActive,
  }) {
    return SiteStats(
      siteId: siteId ?? this.siteId,
      quotesShown: quotesShown ?? this.quotesShown,
      feedsBlocked: feedsBlocked ?? this.feedsBlocked,
      lastActive: lastActive ?? this.lastActive,
      totalTimeActive: totalTimeActive ?? this.totalTimeActive,
    );
  }

  @override
  List<Object?> get props => [siteId, quotesShown, feedsBlocked, lastActive, totalTimeActive];
}