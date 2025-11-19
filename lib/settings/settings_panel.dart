/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:09:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../home/home_store.dart';
import '../resources/colors.dart';
import '../utils/custom_observer.dart';
import 'about.dart';
import 'background_settings_view.dart';
import 'menu_button.dart';
import 'social_cleaner_settings.dart';
import 'widget_settings.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final homeStore = context.read<HomeStore>();
    return CustomObserver(
      name: 'SettingsPanel',
      builder: (context) {
        if (!homeStore.initialized || !homeStore.isPanelVisible) {
          return const SizedBox.shrink();
        }
        return const Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundDismissible(),
            Positioned(top: 32, right: 32, bottom: 32, child: SettingsPanelContent()),
          ],
        );
      },
    );
  }
}

class _BackgroundDismissible extends StatelessWidget {
  const _BackgroundDismissible();

  @override
  Widget build(BuildContext context) {
    final homeStore = context.read<HomeStore>();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => homeStore.hidePanel(),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class SettingsPanelContent extends StatefulWidget {
  const SettingsPanelContent({super.key});

  @override
  State<SettingsPanelContent> createState() => _SettingsPanelContentState();
}

class _SettingsPanelContentState extends State<SettingsPanelContent> with SingleTickerProviderStateMixin {
  late final HomeStore homeStore = context.read<HomeStore>();

  @override
  void initState() {
    super.initState();
    homeStore.tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: homeStore.currentTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            width: 400,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.settingsPanelBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 8, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'common.settings'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            Text(
                              'EN',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Switch.adaptive(
                              value: context.locale.languageCode == 'vi',
                              onChanged: (isVi) async {
                                await context.setLocale(isVi ? const Locale('vi') : const Locale('en'));
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              'VI',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const MenuButton(),
                      Material(
                        type: MaterialType.transparency,
                        child: IconButton(
                          onPressed: () => homeStore.hidePanel(),
                          splashRadius: 16,
                          iconSize: 18,
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0.5,
                      child: Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TabBar(
                        controller: homeStore.tabController,
                        // unselectedLabelColor: Colors.black,
                        labelColor: Theme.of(context).colorScheme.primary,
                        isScrollable: true,
                        unselectedLabelColor: AppColors.textColor,
                        tabAlignment: TabAlignment.start,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 0.5,
                            ),
                            left: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 0.5,
                            ),
                            right: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 0.5,
                            ),
                            bottom: const BorderSide(
                              color: AppColors.settingsPanelBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                        tabs: [
                          Tab(text: 'settings.panel.background'.tr()),
                          Tab(text: 'settings.panel.widget'.tr()),
                          Tab(text: 'settings.panel.socialCleaner'.tr()),
                          Tab(text: 'settings.panel.about'.tr()),
                        ],
                        onTap: (index) => homeStore.setTabIndex(index),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      physics: const BouncingScrollPhysics(),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        alignment: Alignment.topCenter,
                        child: CustomObserver(
                          name: 'SettingsPanelContent',
                          builder: (context) {
                            switch (homeStore.currentTabIndex) {
                              case 0:
                                return const BackgroundSettingsView();
                              case 1:
                                return const WidgetSettings();
                              case 2:
                                return const SocialCleanerSettings();
                              case 3:
                                return const About();
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
