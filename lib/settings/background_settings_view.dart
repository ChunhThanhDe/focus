/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:shared/shared.dart';

import '../home/background_store.dart';
import '../home/model/background_settings.dart';
import '../home/model/color_gradient.dart';
import '../home/model/flat_color.dart';
import '../ui/custom_dropdown.dart';
import '../ui/custom_slider.dart';
import '../ui/custom_switch.dart';
import '../ui/gesture_detector_with_cursor.dart';
import '../resources/color_gradients.dart';
import '../resources/colors.dart';
import '../resources/flat_colors.dart';
import '../resources/unsplash_sources.dart';
import '../utils/custom_observer.dart';
import '../utils/extensions.dart';
import '../utils/enum_extensions.dart';
import 'new_collection_dialog.dart';

class BackgroundSettingsView extends StatelessWidget {
  const BackgroundSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore store = context.read<BackgroundStore>();
    return CustomObserver(
      name: 'BackgroundSettingsView',
      builder: (context) {
        if (!store.initialized) return const SizedBox(height: 200);
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackgroundModeSelector(),
            const SizedBox(height: 16),
            const _ColorSelector(),
            const _GradientSelector(),
            CustomObserver(
              name: 'ImageSettings',
              builder: (context) {
                if (!store.isImageMode) return const SizedBox.shrink();
                return const ImageSettings();
              },
            ),
            const SizedBox(height: 16),
            if (!store.mode.isTodo)
              LabeledObserver(
                label: 'settings.background.autoRefresh'.tr(),
                builder: (context) {
                  return CustomDropdown<BackgroundRefreshRate>(
                    value: store.backgroundRefreshRate,
                    hint: 'settings.background.selectDuration'.tr(),
                    isExpanded: true,
                    items: BackgroundRefreshRate.values,
                    itemBuilder: (context, item) => Text(item.localizedLabel),
                    onSelected: (value) => store.setImageRefreshRate(value),
                  );
                },
              ),
            if (store.mode.isTodo)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomObserver(
                    name: 'Todo 24h Toggle',
                    builder: (context) {
                      return CustomSwitch(
                        label: 'settings.todo.use24h'.tr(),
                        value: store.use24HourTodo,
                        onChanged: (value) => store.setTodo24hFormat(value),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomObserver(
                    name: 'Todo Dark Mode Toggle',
                    builder: (context) {
                      return CustomSwitch(
                        label: 'settings.todo.darkMode'.tr(),
                        value: store.todoDarkMode,
                        onChanged: (value) => store.setTodoDarkMode(value),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),
            LabeledObserver(
              label: 'settings.background.tint'.tr(),
              builder:
                  (context) => CustomSlider(
                    value: store.tint,
                    min: 0,
                    max: 100,
                    valueLabel: '${store.tint.floor()}%',
                    onChanged: (value) => store.setTint(value),
                  ),
            ),
            const SizedBox(height: 40),
            const _BackgroundOptions(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _BackgroundOptions extends StatelessWidget {
  const _BackgroundOptions();

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomObserver(
          name: 'Texture',
          builder: (context) {
            return GestureDetectorWithCursor(
              onTap: () => store.setTexture(!store.texture),
              tooltip: 'Texture',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.lens_blur_rounded,
                  color: store.texture ? Theme.of(context).colorScheme.primary : AppColors.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            );
          },
        ),
        CustomObserver(
          name: 'Change Background',
          builder: (context) {
            if (store.mode.isImage || store.mode.isTodo) return const SizedBox.shrink();

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                GestureDetectorWithCursor(
                  onTap: !store.isLoadingImage ? store.onChangeBackground : null,
                  tooltip: 'Change Background',
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ImageIcon(
                      AssetImage(
                        store.isLoadingImage ? 'assets/images/ic_hourglass.png' : 'assets/images/ic_fan.png',
                      ),
                      color: store.isLoadingImage ? Colors.grey.withValues(alpha: 0.5) : AppColors.textColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        CustomObserver(
          name: 'Image background options',
          builder: (context) {
            if (!store.mode.isImage) return const SizedBox.shrink();
            return const _ImageBackgroundOptions();
          },
        ),
      ],
    );
  }
}

class _ImageBackgroundOptions extends StatelessWidget {
  const _ImageBackgroundOptions();

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 16),
        CustomObserver(
          name: 'Invert',
          builder: (context) {
            return GestureDetectorWithCursor(
              onTap: () => store.setInvert(!store.invert),
              tooltip: 'Invert',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.brightness_medium_rounded,
                  color: store.invert ? Theme.of(context).colorScheme.primary : AppColors.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        CustomObserver(
          name: 'Change Background',
          builder: (context) {
            return GestureDetectorWithCursor(
              onTap: !store.isLoadingImage ? store.onChangeBackground : null,
              tooltip: 'Change Background',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ImageIcon(
                  AssetImage(
                    store.isLoadingImage ? 'assets/images/ic_hourglass.png' : 'assets/images/ic_fan.png',
                  ),
                  color: store.isLoadingImage ? Colors.grey.withValues(alpha: 0.5) : AppColors.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        CustomObserver(
          name: 'Download Background',
          builder: (context) {
            return GestureDetectorWithCursor(
              onTap: !store.isLoadingImage ? store.onDownload : null,
              tooltip: 'Download Image',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.download_rounded,
                  color: store.isLoadingImage || store.currentImage == null ? Colors.grey.withValues(alpha: 0.5) : AppColors.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        CustomObserver(
          name: 'Open Image',
          builder: (context) {
            return GestureDetectorWithCursor(
              onTap: !store.isLoadingImage ? store.onOpenImage : null,
              tooltip: 'Open Original Image',
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: store.isLoadingImage || store.currentImage == null ? Colors.grey.withValues(alpha: 0.5) : AppColors.textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class BackgroundModeSelector extends StatelessWidget {
  const BackgroundModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('settings.background.mode'.tr()),
        const SizedBox(height: 10),
        CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: Theme.of(context).colorScheme.primary,
            primaryContrastingColor: AppColors.settingsPanelBackgroundColor,
          ),
          child: CustomObserver(
            name: 'BackgroundModeSelector',
            builder:
                (context) => CupertinoSegmentedControl<BackgroundMode>(
                  padding: EdgeInsets.zero,
                  groupValue: store.mode,
                  onValueChanged: (mode) => store.setMode(mode),
                  children: {
                    for (final mode in BackgroundMode.values)
                      mode: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          mode.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: store.mode == mode ? Colors.black.withOpacity(0.9) : AppColors.textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                  },
                ),
          ),
        ),
      ],
    );
  }
}

class ImageSettings extends StatelessWidget {
  const ImageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore store = context.read<BackgroundStore>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ImageSourceSelector(),
        const SizedBox(height: 16),
        CustomObserver(
          name: 'Image Source Settings',
          builder: (context) {
            switch (store.imageSource) {
              case ImageSource.unsplash:
                return const UnsplashSourceSettings();
              case ImageSource.local:
                return const SizedBox.shrink();
              case ImageSource.userLikes:
                return const SizedBox.shrink();
            }
          },
        ),
        CustomObserver(
          name: 'B&W Filter',
          builder: (context) {
            return CustomSwitch(
              label: 'settings.background.blackWhiteFilter'.tr(),
              value: store.greyScale,
              onChanged: (value) {
                store.setGreyScale(value);
              },
            );
          },
        ),
      ],
    );
  }
}

class _ImageSourceSelector extends StatefulWidget {
  const _ImageSourceSelector();

  @override
  State<_ImageSourceSelector> createState() => _ImageSourceSelectorState();
}

class _ImageSourceSelectorState extends State<_ImageSourceSelector> {
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('settings.background.source'.tr()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CustomObserver(
                  name: 'Image Source Header',
                  builder: (context) {
                    if (showError) {
                      return Text(
                        'Please like few backgrounds first! ',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }
                    if (store.imageSource != ImageSource.userLikes) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '${store.likedBackgrounds.length} liked',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CustomObserver(
          name: 'Image Source Selector',
          builder: (context) {
            return CustomDropdown<ImageSource>(
              value: store.imageSource,
              // label: 'Source',
              hint: 'settings.background.selectSource'.tr(),
              isExpanded: true,
              items: ImageSource.values.where((source) => source != ImageSource.local).toList(),
              itemBuilder:
                  (context, item) => Text(
                    item.localizedLabel,
                    style: TextStyle(
                      color: item == ImageSource.userLikes && store.likedBackgrounds.isEmpty ? Colors.grey.shade400 : null,
                    ),
                  ),
              onSelected: (value) {
                if (value == ImageSource.userLikes && store.likedBackgrounds.isEmpty) {
                  triggerError();
                  return;
                }
                store.setImageSource(value);
              },
            );
          },
        ),
      ],
    );
  }

  void triggerError() {
    setState(() => showError = true);
    Future.delayed(const Duration(seconds: 3), () {
      showError = false;
      if (mounted) setState(() {});
    });
  }
}

class UnsplashSourceSettings extends StatelessWidget {
  const UnsplashSourceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundStore store = context.read<BackgroundStore>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('settings.background.collection'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1)),
            const SizedBox(width: 6),
            CustomObserver(
              name: 'Add Collection',
              builder: (context) {
                if (store.imageSource != ImageSource.unsplash) {
                  return const SizedBox.shrink();
                }
                return GestureDetectorWithCursor(
                  onTap: () => onCreateNewCollection(context, store),
                  child: Icon(
                    Icons.add_circle_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomObserver(
          name: 'Background Collection',
          builder: (context) {
            return CustomDropdown<UnsplashSource>(
              value: store.unsplashSource,
              hint: 'settings.background.selectCollection'.tr(),
              isExpanded: true,
              items: [...store.customSources, ...UnsplashSources.sources],
              itemBuilder: (context, item) {
                if (item == UnsplashSources.christmas) {
                  return Text('🎄${item.name}');
                }
                return Row(
                  children: [
                    Expanded(child: Text(item.name)),
                    if (store.customSources.contains(item))
                      Tooltip(
                        message: 'Custom Collection',
                        child: Icon(
                          Icons.explicit,
                          size: 16,
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                  ],
                );
              },
              onSelected: (value) => store.setUnsplashSource(value),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('settings.background.resolution'.tr())),
            ResolutionHelpButton(),
            SizedBox(width: 4),
          ],
        ),
        const SizedBox(height: 10),
        CustomObserver(
          name: 'Resolution Selector',
          builder: (context) {
            return CustomDropdown<ImageResolution>(
              value: store.imageResolution,
              isExpanded: true,
              hint: 'settings.background.selectResolution'.tr(),
              items:
                  ImageResolution.values
                      .where(
                        (resolution) => resolution != ImageResolution.original,
                      )
                      .toList(),
              itemBuilder:
                  (context, item) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: item.label),
                        const WidgetSpan(child: SizedBox(width: 8)),
                        TextSpan(
                          text: '(${item.sizeLabel})',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              selectedItemBuilder: (context, item) => Text(item.label),
              onSelected: (value) => store.setImageResolution(value),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> onCreateNewCollection(
    BuildContext context,
    BackgroundStore store,
  ) async {
    final String? result = await showDialog<String>(
      context: context,
      builder:
          (context) => Theme(
            data: Theme.of(context),
            child: NewCollectionDialog(store: store),
          ),
    );
    if (result != null) {
      store.addNewCollection(
        UnsplashTagsSource(tags: result.trim().capitalized),
        setAsCurrent: true,
      );
    }
  }
}

class ResolutionHelpButton extends StatelessWidget {
  const ResolutionHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      padding: const EdgeInsets.all(14),
      richMessage: TextSpan(
        text: '',
        children: [
          TextSpan(
            text: 'Auto Mode: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: 'Background images will have\nsame resolution as this window.\n',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
          ),
          TextSpan(
            text: '\nNote: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: 'Higher resolution background may\ntake more time to load depending on\nyour connection.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(right: 32),
      triggerMode: TooltipTriggerMode.tap,
      textAlign: TextAlign.start,
      preferBelow: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector();

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return CustomObserver(
      name: 'ColorSelector',
      builder: (context) {
        if (!store.isColorMode && !store.mode.isTodo) return const SizedBox.shrink();
        return CustomDropdown<FlatColor>(
          value: store.color,
          label: 'settings.background.color'.tr(),
          hint: 'settings.background.selectColor'.tr(),
          isExpanded: true,
          itemHeight: 40,
          items: FlatColors.colors.values.toList(),
          itemBuilder: (context, item) => _ColorSelectorItem(key: ValueKey(item), item: item),
          onSelected: (color) => store.setColor(color),
        );
      },
    );
  }
}

class _ColorSelectorItem extends StatelessWidget {
  final FlatColor item;

  const _ColorSelectorItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: item.background,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(item.name)),
      ],
    );
  }
}

class _GradientSelector extends StatelessWidget {
  const _GradientSelector();

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return CustomObserver(
      name: 'ColorGradientSelector',
      builder: (context) {
        if (!store.isGradientMode) return const SizedBox.shrink();
        return CustomDropdown<ColorGradient>(
          value: store.gradient,
          label: 'settings.background.gradient'.tr(),
          hint: 'settings.background.selectGradient'.tr(),
          isExpanded: true,
          itemHeight: 40,
          items: ColorGradients.gradients.values.toList(),
          itemBuilder: (context, item) => _GradientSelectorItem(key: ValueKey(item), item: item),
          onSelected: (gradient) => store.setGradient(gradient),
        );
      },
    );
  }
}

class _GradientSelectorItem extends StatelessWidget {
  final ColorGradient item;

  const _GradientSelectorItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: item.toLinearGradient(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(item.name)),
      ],
    );
  }
}
