/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: Ã°Å¸Å½Â¯ Happy coding and Have a nice day! Ã°Å¸Å’Â¤Ã¯Â¸Â
 */

import 'package:flutter/material.dart';
import 'package:focus/common/widgets/dialogs/advanced_settings_dialog.dart';
import 'package:focus/common/widgets/dialogs/changelog_dialog.dart';
import 'package:focus/common/widgets/dialogs/liked_backgrounds_dialog.dart';
import 'package:focus/common/widgets/dialogs/reset_dialog.dart';

import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/home_store.dart';
import 'package:focus/data/models/background_settings.dart';
import 'package:focus/data/models/export_data.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/core/constants/colors.dart';
import 'package:focus/core/constants/storage_keys.dart';
import 'package:focus/common/widgets/button/dropdown_button3.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isVi = context.locale.languageCode == 'vi';
    final Map<String, String> itemsMap = {
      'liked_backgrounds': 'settings.menu.likedBackgrounds'.tr(),
      'import': 'settings.menu.import'.tr(),
      'export': 'settings.menu.export'.tr(),
      'language_toggle': isVi ? 'common.english'.tr() : 'common.vietnamese'.tr(),
      'advanced': 'settings.menu.advanced'.tr(),
      'changelog': 'settings.menu.changelog'.tr(),
      'donate': 'settings.menu.donate'.tr(),
      'sponsor': 'settings.menu.sponsor'.tr(),
      'report': 'settings.menu.report'.tr(),
      'reset': 'settings.menu.reset'.tr(),
    };
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
      child: Material(
        type: MaterialType.transparency,
        child: CustomDropdownButton<MapEntry<String, String>>(
          items: itemsMap.entries.toList(),
          underline: const SizedBox.shrink(),
          dropdownWidth: 260,
          dropdownDirection: DropdownDirection.left,
          dropdownOverButton: false,
          scrollbarThickness: 6,
          focusColor: Theme.of(context).colorScheme.primary,
          dropdownElevation: 8,
          dropdownPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          itemHeight: 42,
          onChanged: (value) {
            if (value == null) return;
            onSelected(context, value.key);
          },
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.dropdownOverlayColor,
            border: Border.all(
              color: AppColors.borderColor.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: AppColors.textColor,
          ),
          itemBuilder:
              (context, item) => CustomDropdownMenuItem<MapEntry<String, String>>(
                value: item,
                hoverBackgroundColor: item.key == 'reset' ? Colors.red.withOpacity(0.15) : Theme.of(context).colorScheme.primary.withOpacity(0.10),
                hoverTextColor: item.key == 'reset' ? Colors.red.shade300 : AppColors.textColor,
                textColor: item.key == 'reset' ? Colors.red.shade400 : AppColors.textColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForMenuItem(item.key),
                        size: 18,
                        color: item.key == 'reset' ? Colors.red.shade400 : Theme.of(context).colorScheme.primary.withOpacity(0.85),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.value,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

  IconData _getIconForMenuItem(String key) {
    switch (key) {
      case 'changelog':
        return Icons.article_outlined;
      case 'liked_backgrounds':
        return Icons.favorite_outline;
      case 'reset':
        return Icons.refresh_outlined;
      case 'import':
        return Icons.file_download_outlined;
      case 'export':
        return Icons.file_upload_outlined;
      case 'language_toggle':
        return Icons.translate;
      case 'report':
        return Icons.bug_report_outlined;
      case 'donate':
        return Icons.favorite;
      case 'sponsor':
        return Icons.star_outline;
      case 'advanced':
        return Icons.tune_outlined;
      default:
        return Icons.settings_outlined;
    }
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
      case 'language_toggle':
        final isVi = context.locale.languageCode == 'vi';
        context.setLocale(isVi ? const Locale('en') : const Locale('vi'));
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
    backgroundStore.setTodo24hFormat(true);
    backgroundStore.setTodoDarkMode(false);
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
