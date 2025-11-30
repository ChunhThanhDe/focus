/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-29 16:37:51
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus/core/constants/colors.dart';
import 'package:focus/main.dart';
import 'package:focus/presentation/settings/pages/settings_view_about.dart';
import 'package:focus/common/widgets/input/gesture_detector_with_cursor.dart';

class PermissionRequestDialog extends StatefulWidget {
  const PermissionRequestDialog({super.key});
  @override
  State<PermissionRequestDialog> createState() => _PermissionRequestDialogState();

  /// Check if any permissions are granted
  static Future<bool> hasAnyPermissions() async {
    try {
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      if (chrome == null) return false;
      final permissions = js_util.getProperty(chrome, 'permissions');
      if (permissions == null) return false;

      const siteOrigins = {
        'Facebook': [
          'https://www.facebook.com/*',
          'http://www.facebook.com/*',
          'https://web.facebook.com/*',
          'http://web.facebook.com/*',
        ],
        'Instagram': ['https://www.instagram.com/*', 'http://www.instagram.com/*'],
        'TikTok': ['https://www.tiktok.com/*'],
        'Threads': ['https://www.threads.net/*', 'https://www.threads.com/*'],
        'Twitter/X': [
          'https://twitter.com/*',
          'http://twitter.com/*',
          'https://x.com/*',
          'http://x.com/*',
        ],
        'Reddit': [
          'https://www.reddit.com/*',
          'http://www.reddit.com/*',
          'https://old.reddit.com/*',
          'http://old.reddit.com/*',
        ],
        'LinkedIn': ['https://www.linkedin.com/*', 'http://www.linkedin.com/*'],
        'YouTube': ['https://www.youtube.com/*'],
        'GitHub': ['https://github.com/*', 'https://www.github.com/*'],
        'Shopee': ['https://shopee.vn/*', 'https://shopee.com/*'],
      };

      for (final entry in siteOrigins.entries) {
        final granted = await js_util.promiseToFuture(
          js_util.callMethod(permissions, 'contains', [
            js_util.jsify({'origins': entry.value}),
          ]),
        );
        if (granted == true) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class _PermissionRequestDialogState extends State<PermissionRequestDialog> {
  bool requesting = false;
  bool? granted;
  int _tabIndex = 1;
  final Map<String, List<String>> siteOrigins = const {
    'Facebook': [
      'https://www.facebook.com/*',
      'http://www.facebook.com/*',
      'https://web.facebook.com/*',
      'http://web.facebook.com/*',
    ],
    'Instagram': ['https://www.instagram.com/*', 'http://www.instagram.com/*'],
    'TikTok': ['https://www.tiktok.com/*'],
    'Threads': ['https://www.threads.net/*', 'https://www.threads.com/*'],
    'Twitter/X': [
      'https://twitter.com/*',
      'http://twitter.com/*',
      'https://x.com/*',
      'http://x.com/*',
    ],
    'Reddit': [
      'https://www.reddit.com/*',
      'http://www.reddit.com/*',
      'https://old.reddit.com/*',
      'http://old.reddit.com/*',
    ],
    'LinkedIn': ['https://www.linkedin.com/*', 'http://www.linkedin.com/*'],
    'YouTube': ['https://www.youtube.com/*'],
    'GitHub': ['https://github.com/*', 'https://www.github.com/*'],
    'Shopee': ['https://shopee.vn/*', 'https://shopee.com/*'],
  };
  final Map<String, bool> _requestingBySite = {};
  final Map<String, bool?> _grantedBySite = {};
  final Map<String, bool> _enabledBySite = {};
  String _assetForName(String name) {
    final key = name.toLowerCase();
    if (key.contains('facebook')) return 'assets/images/facebook.png';
    if (key.contains('instagram')) return 'assets/images/instagram.png';
    if (key.contains('tiktok')) return 'assets/images/tiktok.png';
    if (key.contains('threads')) return 'assets/images/threads.png';
    if (key.contains('twitter')) return 'assets/images/twitter.png';
    if (key.contains('reddit')) return 'assets/images/reddit.png';
    if (key.contains('linkedin')) return 'assets/images/linkedin.png';
    if (key.contains('youtube')) return 'assets/images/youtube.png';
    if (key.contains('github')) return 'assets/images/github.png';
    if (key.contains('shopee')) return 'assets/images/shopee.png';
    return 'assets/images/ic_globe.png';
  }

  @override
  void initState() {
    super.initState();
    _initGrantedState();
  }

  Future<void> _initGrantedState() async {
    try {
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      final permissions = js_util.getProperty(chrome, 'permissions');
      for (final entry in siteOrigins.entries) {
        final granted = await js_util.promiseToFuture(
          js_util.callMethod(permissions, 'contains', [
            js_util.jsify({'origins': entry.value}),
          ]),
        );
        _grantedBySite[entry.key] = granted == true;
        _enabledBySite[entry.key] = granted == true;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.settingsPanelBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _tabIndex == 0
                                ? Colors.amber.withValues(alpha: 0.12)
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _tabIndex == 0
                                  ? Colors.amber.shade600
                                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: _tabIndex == 0 ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        'todo.guide'.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _tabIndex == 1
                                ? Colors.amber.withValues(alpha: 0.12)
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _tabIndex == 1
                                  ? Colors.amber.shade600
                                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: _tabIndex == 1 ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        'permission.title'.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tabIndex = 2),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _tabIndex == 2
                                ? Colors.amber.withValues(alpha: 0.12)
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _tabIndex == 2
                                  ? Colors.amber.shade600
                                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: _tabIndex == 2 ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '${'settings.menu.changelog'.tr()} - ${'settings.panel.about'.tr()}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tabIndex == 0) ...[
              Text(
                'todo.guide'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text('todo.guideDescription'.tr(), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              // YouTube video embed
              _YouTubeVideoEmbed(
                videoId: 'G0HHiE3VcU8', // TODO: Replace with actual YouTube video ID
              ),
              const SizedBox(height: 16),

              Text('todo.guideInstruction'.tr(), style: Theme.of(context).textTheme.bodyLarge),
            ] else if (_tabIndex == 1) ...[
              Text(
                'permission.title'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('permission.description'.tr(), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              if ((_enabledBySite.values.where((e) => e == true).isEmpty))
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade600, width: 1.5),
                  ),
                  child: Text(
                    'permission.warning.no_site_enabled'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.amber.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Text('permission.choose_sites'.tr(), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  const double spacing = 12;
                  final double itemWidth = (constraints.maxWidth - spacing) / 2;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children:
                        siteOrigins.entries.map((entry) {
                          final name = entry.key;
                          final origins = entry.value;
                          final bool isOn = _enabledBySite[name] == true;
                          final bool requesting = _requestingBySite[name] == true;
                          return SizedBox(
                            width: itemWidth,
                            child: InkWell(
                              onTap:
                                  (requesting || isOn)
                                      ? null
                                      : () async {
                                        // Set requesting state
                                        _requestingBySite[name] = true;
                                        if (mounted) setState(() {});

                                        bool ok = false;
                                        try {
                                          final chrome = js_util.getProperty(
                                            js_util.globalThis,
                                            'chrome',
                                          );
                                          final runtime = js_util.getProperty(chrome, 'runtime');
                                          final res = await js_util.promiseToFuture(
                                            js_util.callMethod(runtime, 'sendMessage', [
                                              js_util.jsify({
                                                'action': 'requestOptionalPermissions',
                                                'origins': origins,
                                              }),
                                            ]),
                                          );
                                          final permissions = js_util.getProperty(
                                            chrome,
                                            'permissions',
                                          );
                                          final confirmed = await js_util.promiseToFuture(
                                            js_util.callMethod(permissions, 'contains', [
                                              js_util.jsify({'origins': origins}),
                                            ]),
                                          );
                                          ok =
                                              confirmed == true ||
                                              (res is Map && res['granted'] == true);
                                        } catch (_) {
                                          ok = false;
                                        }

                                        // Update all states at once to avoid multiple rebuilds
                                        if (mounted) {
                                          setState(() {
                                            _requestingBySite[name] = false;
                                            _grantedBySite[name] = ok;
                                            _enabledBySite[name] = ok;
                                          });
                                        }
                                      },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isOn
                                          ? Colors.amber.withValues(alpha: 0.12)
                                          : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        isOn
                                            ? Colors.amber.shade600
                                            : Theme.of(
                                              context,
                                            ).colorScheme.outline.withValues(alpha: 0.2),
                                    width: isOn ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.asset(
                                        _assetForName(name),
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isOn
                                          ? 'permission.status.on'.tr()
                                          : 'permission.status.off'.tr(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color:
                                            isOn
                                                ? Colors.amber.shade700
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ] else ...[
              // Top row: App info (left) + Support & Discord (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: App icon, name, version
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const FocusLogo(size: 120, animate: false),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Focus Your Target'.toUpperCase(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  Text(
                                    'v${packageInfo.version}'.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side: Support & Discord button
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetectorWithCursor(
                          onTap: () => launchUrl(Uri.parse('https://discord.gg/kMrAKAZA2X')),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5865F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'aboutDialog.joinDiscord'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '${'settings.menu.changelog'.tr()} - ${'settings.panel.about'.tr()}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'aboutDialog.p1'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'aboutDialog.p2'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'aboutDialog.p3'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Text(
                'aboutDialog.support'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${'aboutDialog.tellFriends'.tr()}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '• ${'aboutDialog.leaveReviewOn'.tr()} ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      InkWell(
                        onTap:
                            () => launchUrl(
                              Uri.parse(
                                'https://chromewebstore.google.com/detail/focus-to-your-target/jgifoecdnnjidgepcankbpcmhefeehpm',
                              ),
                            ),
                        child: Text(
                          'aboutDialog.chrome'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(' ${'common.or'.tr()} ', style: Theme.of(context).textTheme.bodyLarge),
                      InkWell(
                        onTap:
                            () => launchUrl(
                              Uri.parse(
                                'https://microsoftedge.microsoft.com/addons/detail/focus-to-your-target/bcgniccgbgfnaibdlmjnbgaimdanbpai',
                              ),
                            ),
                        child: Text(
                          'aboutDialog.edge'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        ' ${'aboutDialog.store'.tr()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '• ${'aboutDialog.reportOn'.tr()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      InkWell(
                        onTap:
                            () => launchUrl(
                              Uri.parse('https://github.com/ChunhThanhDe/focus/issues/new/choose'),
                            ),
                        child: Text(
                          'aboutDialog.github'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${'aboutDialog.shareHowHelped'.tr()}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('• ', style: Theme.of(context).textTheme.bodyLarge),
                      InkWell(
                        onTap:
                            () => launchUrl(Uri.parse('https://www.buymeacoffee.com/ChunhThanhDe')),
                        child: Text(
                          'aboutDialog.buyCoffee'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Widget to display YouTube video thumbnail with play button
/// Clicking will open the video on YouTube
class _YouTubeVideoEmbed extends StatelessWidget {
  final String videoId;

  const _YouTubeVideoEmbed({required this.videoId});

  @override
  Widget build(BuildContext context) {
    // If no valid video ID, show placeholder
    if (videoId.isEmpty || videoId == 'YOUR_VIDEO_ID_HERE') {
      return Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Video hướng dẫn sẽ được hiển thị tại đây',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 500,
        minHeight: 300,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: GestureDetectorWithCursor(
          onTap:
              () => launchUrl(
                Uri.parse('https://www.youtube.com/watch?v=$videoId'),
                mode: LaunchMode.externalApplication,
              ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.shade600,
                width: 2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // YouTube thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black.withValues(alpha: 0.3),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Play button overlay
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
