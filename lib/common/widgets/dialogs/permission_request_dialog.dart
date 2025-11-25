import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:focus/core/constants/colors.dart';

class PermissionRequestDialog extends StatefulWidget {
  const PermissionRequestDialog({super.key});
  @override
  State<PermissionRequestDialog> createState() => _PermissionRequestDialogState();
}

class _PermissionRequestDialogState extends State<PermissionRequestDialog> {
  bool requesting = false;
  bool? granted;
  final Map<String, List<String>> siteOrigins = const {
    'Facebook': [
      'https://www.facebook.com/*',
      'http://www.facebook.com/*',
      'https://web.facebook.com/*',
      'http://web.facebook.com/*',
    ],
    'Instagram': [
      'https://www.instagram.com/*',
      'http://www.instagram.com/*',
    ],
    'TikTok': [
      'https://www.tiktok.com/*',
    ],
    'Threads': [
      'https://www.threads.net/*',
      'https://www.threads.com/*',
    ],
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
    'LinkedIn': [
      'https://www.linkedin.com/*',
      'http://www.linkedin.com/*',
    ],
    'YouTube': [
      'https://www.youtube.com/*',
    ],
    'GitHub': [
      'https://github.com/*',
      'https://www.github.com/*',
    ],
    'Hacker News': [
      'https://news.ycombinator.com/*',
    ],
    'Shopee': [
      'https://shopee.vn/*',
      'https://shopee.com/*',
    ],
  };
  final Map<String, bool> _requestingBySite = {};
  final Map<String, bool?> _grantedBySite = {};
  final Map<String, bool> _enabledBySite = {};

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
          js_util.callMethod(permissions, 'contains', [js_util.jsify({'origins': entry.value})]),
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
        width: 760,
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
                  child: Text(
                    'permission.title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 16,
                    iconSize: 18,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('permission.description'.tr(), style: Theme.of(context).textTheme.bodyMedium),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            Text('permission.choose_sites'.tr(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 12;
                final double itemWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: siteOrigins.entries.map((entry) {
                    final name = entry.key;
                    final origins = entry.value;
                    final bool isOn = _enabledBySite[name] == true;
                    final bool requesting = _requestingBySite[name] == true;
                    final bool? granted = _grantedBySite[name];
                    return SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: requesting
                            ? null
                            : () async {
                                setState(() => _requestingBySite[name] = true);
                                try {
                                  final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
                                  final runtime = js_util.getProperty(chrome, 'runtime');
                                  final res = await js_util.promiseToFuture(
                                    js_util.callMethod(runtime, 'sendMessage', [js_util.jsify({ 'action': 'requestOptionalPermissions', 'origins': origins })]),
                                  );
                                  // Re-check actual permission state to ensure UI updates correctly
                                  final permissions = js_util.getProperty(chrome, 'permissions');
                                  final confirmed = await js_util.promiseToFuture(
                                    js_util.callMethod(permissions, 'contains', [js_util.jsify({'origins': origins})]),
                                  );
                                  final ok = confirmed == true || (res is Map && res['granted'] == true);
                                  _grantedBySite[name] = ok;
                                  _enabledBySite[name] = ok;
                                } catch (_) {
                                  _grantedBySite[name] = false;
                                }
                                setState(() => _requestingBySite[name] = false);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isOn ? Colors.amber.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isOn
                                  ? Colors.amber.shade600
                                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              width: isOn ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isOn ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isOn ? Colors.amber.shade600 : Theme.of(context).colorScheme.outline,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isOn ? 'permission.status.on'.tr() : 'permission.status.off'.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isOn ? Colors.amber.shade700 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
          ],
        ),
      ),
    );
  }
}