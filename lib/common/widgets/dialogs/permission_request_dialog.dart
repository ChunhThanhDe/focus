import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus/core/constants/colors.dart';

class PermissionRequestDialog extends StatefulWidget {
  const PermissionRequestDialog({super.key});
  @override
  State<PermissionRequestDialog> createState() => _PermissionRequestDialogState();
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
        width: 830,
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
              const SizedBox(height: 8),
              Text(
                'permission.description'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'permission.choose_sites'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else if (_tabIndex == 1) ...[
              Text(
                'permission.title'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'permission.description'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
              Text(
                'permission.choose_sites'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
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
                      return SizedBox(
                        width: itemWidth,
                        child: InkWell(
                          onTap: requesting
                              ? null
                              : () async {
                                  setState(() => _requestingBySite[name] = true);
                                  try {
                                    final chrome = js_util.getProperty(
                                      js_util.globalThis,
                                      'chrome',
                                    );
                                    final runtime = js_util.getProperty(
                                      chrome,
                                      'runtime',
                                    );
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
                                    final ok = confirmed == true || (res is Map && res['granted'] == true);
                                    _grantedBySite[name] = ok;
                                    _enabledBySite[name] = ok;
                                  } catch (_) {
                                    _grantedBySite[name] = false;
                                  }
                                  setState(() => _requestingBySite[name] = false);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? Colors.amber.withValues(alpha: 0.12)
                                  : Theme.of(context).colorScheme.surface,
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
                                  isOn ? 'permission.status.on'.tr() : 'permission.status.off'.tr(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isOn
                                            ? Colors.amber.shade700
                                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
              Text(
                '${'settings.menu.changelog'.tr()} - ${'settings.panel.about'.tr()}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Focus ra đời từ nhu cầu hạn chế sự trì hoãn và thói quen cuộn vô thức. Có lúc bạn nhận ra mình gõ “facebook.com” vào thanh địa chỉ một cách tự động. Với Focus, chúng tôi muốn giảm sức hút gây nghiện của News Feed bằng cách ẩn nó đi và thay bằng những câu trích dẫn tích cực.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Những năm gần đây, News Feed xuất hiện trong đủ loại ứng dụng nhờ khả năng giữ chân người dùng. Đã đến lúc chúng ta – những người dùng – giành lại quyền kiểm soát.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Focus luôn miễn phí, mã nguồn mở và không theo dõi bạn. Quyền truy cập trang chỉ dùng cho thao tác giao diện, không thu thập dữ liệu cá nhân.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Support',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Giới thiệu Focus cho bạn bè',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '• Để lại đánh giá trên ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://chrome.google.com/webstore')),
                        child: Text(
                          'Chrome',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(' hoặc ', style: Theme.of(context).textTheme.bodyMedium),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://addons.mozilla.org')),
                        child: Text(
                          'Firefox',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(' store', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '• Báo lỗi hoặc đóng góp trên ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://github.com/ChunhThanhDe/focus/issues/new/choose'),
                        ),
                        child: Text(
                          'GitHub',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Chia sẻ cho chúng tôi biết Focus đã giúp bạn như thế nào',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://www.buymeacoffee.com/ChunhThanhDe')),
                        child: Text(
                          'Mua tôi một ly cà phê',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
