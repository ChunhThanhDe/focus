import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../home/background_store.dart';
import '../home/home_store.dart';
import '../home/model/background_settings.dart';
import '../home/model/export_data.dart';
import '../home/widget_store.dart';
import '../resources/colors.dart';
import '../resources/storage_keys.dart';
import '../utils/dropdown_button3.dart';
import '../utils/storage_manager.dart';
import 'advanced_settings_dialog.dart';
import 'changelog_dialog.dart';
import 'liked_backgrounds_dialog.dart';
import 'reset_dialog.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  static Map<String, String> get options => {
    'liked_backgrounds': 'settings.menu.likedBackgrounds'.tr(),
    'import': 'settings.menu.import'.tr(),
    'export': 'settings.menu.export'.tr(),
    'advanced': 'settings.menu.advanced'.tr(),
    'changelog': 'settings.menu.changelog'.tr(),
    'donate': 'settings.menu.donate'.tr(),
    'sponsor': 'settings.menu.sponsor'.tr(),
    'report': 'settings.menu.report'.tr(),
    'reset': 'settings.menu.reset'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(hoverColor: Theme.of(context).colorScheme.primary),
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
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w400,
            height: 1,
          ),
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
          builder:
              (_) => LikedBackgroundsDialog(
                store: context.read<BackgroundStore>(),
              ),
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
        launchUrl(
          Uri.parse('https://github.com/ChunhThanhDe/focus/issues/new/choose'),
        );
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
    await GetIt.instance.get<LocalStorageManager>().clear(
      except: [StorageKeys.version],
    );
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
