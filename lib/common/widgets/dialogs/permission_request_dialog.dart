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
  late Map<String, bool> selected = {
    for (final key in siteOrigins.keys) key: true,
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
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
            Text('permission.choose_sites'.tr(), style: Theme.of(context).textTheme.bodySmall),
            SizedBox(
              height: 260,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: siteOrigins.entries.map((entry) {
                    final name = entry.key;
                    final origins = entry.value;
                    final checked = selected[name] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: checked,
                              onChanged: (v) => setState(() => selected[name] = v == true),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                Text(
                                  origins.map((o) => o.replaceAll('/*', '')).join(', '),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: requesting
                    ? null
                    : () async {
                        setState(() => requesting = true);
                        try {
                          final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
                          final runtime = js_util.getProperty(chrome, 'runtime');
                          final chosenOrigins = <String>[];
                          selected.forEach((k, v) {
                            if (v == true) {
                              chosenOrigins.addAll(siteOrigins[k]!);
                            }
                          });
                          final res = await js_util.promiseToFuture(
                            js_util.callMethod(runtime, 'sendMessage', [js_util.jsify({ 'action': 'requestOptionalPermissions', 'origins': chosenOrigins })]),
                          );
                          granted = res is Map && res['granted'] == true;
                        } catch (_) {
                          granted = false;
                        }
                        setState(() => requesting = false);
                      },
                child: Text(requesting ? 'permission.button.requesting'.tr() : 'permission.button.grant_selected'.tr()),
              ),
            ),
            const SizedBox(height: 8),
            if (granted != null)
              Text(
                granted == true ? 'permission.result.granted'.tr() : 'permission.result.denied'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: granted == true ? Colors.green : Colors.red,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}