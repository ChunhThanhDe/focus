import 'dart:math';

import 'package:flutter/material.dart';
import '../resources/storage_keys.dart';
import '../home/background_store.dart';
import '../home/home_store.dart';
import '../home/model/background_settings.dart';
import '../home/model/export_data.dart';
import '../home/widget_store.dart';
import '../resources/colors.dart';
import 'about.dart';
import 'adavanced_settings_dialog.dart';
import 'background_settings_view.dart';
import 'changelog_dialog.dart';
import 'liked_backgrounds_dialog.dart';
import 'widget_settings.dart';
import '../utils/custom_observer.dart';
import '../utils/dropdown_button3.dart';
import '../utils/storage_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<HomeStore>();
    return CustomObserver(
      name: 'SettingsPanel',
      builder: (context) {
        if (!store.initialized || !store.isPanelVisible) {
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

class SettingsPanelContent extends StatefulWidget {
  const SettingsPanelContent({super.key});

  @override
  State<SettingsPanelContent> createState() => _SettingsPanelContentState();
}

class _SettingsPanelContentState extends State<SettingsPanelContent>
    with SingleTickerProviderStateMixin {
  late final HomeStore store = context.read<HomeStore>();

  @override
  void initState() {
    super.initState();
    store.tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: store.currentTabIndex,
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
            width: 360,
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
                        child: Text('Settings', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const MenuButton(),
                      Material(
                        type: MaterialType.transparency,
                        child: IconButton(
                          onPressed: () => store.hidePanel(),
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
                      width: 360,
                      child: TabBar(
                        controller: store.tabController,
                        // unselectedLabelColor: Colors.black,
                        labelColor: Theme.of(context).colorScheme.primary,
                        isScrollable: true,
                        unselectedLabelColor: AppColors.textColor,
                        tabAlignment: TabAlignment.start,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w300),
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
                        tabs: const [
                          Tab(text: 'Background'),
                          Tab(text: 'Widget'),
                          Tab(text: 'About'),
                        ],
                        onTap: (index) => store.setTabIndex(index),
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
                            switch (store.currentTabIndex) {
                              case 0:
                                return const BackgroundSettingsView();
                              case 1:
                                return const WidgetSettings();
                              case 2:
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

class _BackgroundDismissible extends StatelessWidget {
  const _BackgroundDismissible();

  @override
  Widget build(BuildContext context) {
    final store = context.read<HomeStore>();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => store.hidePanel(),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  static const Map<String, String> options = {
    'liked_backgrounds': 'View liked photos',
    'import': 'Import Settings',
    'export': 'Export Settings',
    'advanced': 'Advanced Settings',
    'changelog': "See what's new",
    'donate': 'Donate',
    'sponsor': 'Become a sponsor',
    'report': 'Report an issue',
    'reset': 'Reset to default',
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(hoverColor: Theme.of(context).colorScheme.primary),
      child: Material(
        type: MaterialType.transparency,
        child: CustomDropdownButton<MapEntry<String, String>>(
          items: options.entries.toList(),
          underline: const SizedBox.shrink(),
          dropdownWidth: 200,
          dropdownDirection: DropdownDirection.left,
          dropdownOverButton: false,
          scrollbarThickness: 4,
          focusColor: Theme.of(context).colorScheme.primary,
          dropdownElevation: 2,
          // dropdownPadding: EdgeInsets.zero,
          itemHeight: 32,
          onChanged: (value) {
            if (value == null) return;
            onSelected(context, value.key);
          },
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.dropdownOverlayColor,
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400, height: 1),
          itemBuilder:
              (context, item) => CustomDropdownMenuItem<MapEntry<String, String>>(
                value: item,
                hoverBackgroundColor: item.key == 'reset' ? Colors.red : null,
                hoverTextColor: item.key == 'reset' ? Colors.white : null,
                textColor: item.key == 'reset' ? Colors.red : null,
                child: Text(item.value),
              ),
          childBuilder:
              (ctx, item, onTap) => Theme(
                data: Theme.of(context),
                child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.more_vert_rounded),
                  iconSize: 18,
                  splashRadius: 16,
                ),
              ),
        ),
      ),
    );
  }

  void onSelected(BuildContext context, String value) {
    switch (value) {
      case 'changelog':
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const ChangelogDialog(),
        );
      case 'liked_backgrounds':
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => LikedBackgroundsDialog(store: context.read<BackgroundStore>()),
        );
      case 'advanced':
        final backgroundStore = context.read<BackgroundStore>();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => Provider<BackgroundStore>.value(
                value: backgroundStore,
                child: const AdvancedSettingsDialog(),
              ),
        );
      case 'reset':
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => ResetDialog(onReset: () => onReset(context)),
        );
      case 'import':
        onImportSettings(context);
      case 'export':
        onExportSettings(context);
      case 'report':
        launchUrl(Uri.parse('https://github.com/ChunhThanhDe/focus/issues/new/choose'));
      case 'donate':
        launchUrl(Uri.parse('https://www.buymeacoffee.com/ChunhThanhDe'));
      case 'sponsor':
        launchUrl(Uri.parse('https://github.com/sponsors/ChunhThanhDe'));
    }
  }

  void onReset(BuildContext context) async {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final HomeStore homeStore = context.read<HomeStore>();
    final WidgetStore widgetStore = context.read<WidgetStore>();
    await GetIt.instance.get<LocalStorageManager>().clear(except: [StorageKeys.version]);
    homeStore.reset();
    backgroundStore.reset();
    widgetStore.reset();
  }

  Future<void> onExportSettings(BuildContext context) async {
    final HomeStore homeStore = context.read<HomeStore>();
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final WidgetStore widgetStore = context.read<WidgetStore>();

    final BackgroundSettings settings = backgroundStore.getCurrentSettings();
    final createdAt = DateTime.now();
    final ExportData exportData = ExportData(
      settings: settings,
      likedBackgrounds: {...backgroundStore.likedBackgrounds},
      version: settingsVersion,
      createdAt: createdAt,
      image1: backgroundStore.image1,
      image2: backgroundStore.image2,
      image1Time: backgroundStore.image1Time,
      image2Time: backgroundStore.image2Time,
      imageIndex: backgroundStore.imageIndex,
      widgetSettings: WidgetsExportData(
        type: widgetStore.type,
        analogClock: widgetStore.analogueClockSettings.getCurrentSettings(),
        digitalClock: widgetStore.digitalClockSettings.getCurrentSettings(),
        message: widgetStore.messageSettings.getCurrentSettings(),
        timer: widgetStore.timerSettings.getCurrentSettings(),
        weather: widgetStore.weatherSettings.getCurrentSettings(),
        digitalDate: widgetStore.digitalDateSettings.getCurrentSettings(),
      ),
    );

    await homeStore.onExportSettings(exportData);
  }

  Future<void> onImportSettings(BuildContext context) async {
    final BackgroundStore backgroundStore = context.read<BackgroundStore>();
    final HomeStore homeStore = context.read<HomeStore>();
    final WidgetStore widgetStore = context.read<WidgetStore>();

    final bool? imported = await homeStore.onImportSettings();

    if (imported == true) {
      homeStore.reset();
      backgroundStore.reset(clear: false);
      widgetStore.reload();
    }
  }
}

class ResetDialog extends StatelessWidget {
  final VoidCallback onReset;

  const ResetDialog({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: min(500, MediaQuery.of(context).size.width * 0.9),
        // height: min(500, MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        decoration: BoxDecoration(
          color: AppColors.settingsPanelBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restore_rounded, size: 72, color: Colors.grey.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset to default settings?',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Are you sure you want to reset all settings to default? This cannot be reversed.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.red.withValues(alpha: 0.1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Note that this will also clear your liked photos!',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onReset();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: const Text('Yes, Reset!'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
