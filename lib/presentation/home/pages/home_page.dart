/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:09:32
  * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus/common/widgets/dialogs/permission_request_dialog.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/store/home_store.dart';
import 'package:focus/presentation/home/store/widget_store.dart';
import 'package:focus/presentation/home/widgets/home_background.dart';
import 'package:focus/presentation/home/widgets/home_widget.dart';
import 'package:focus/presentation/home/widgets/bottom_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import 'package:focus/main.dart';
import 'package:focus/core/constants/storage_keys.dart';

import 'package:focus/presentation/settings/pages/settings_panel.dart';
import 'package:focus/common/widgets/toast/message_banner.dart';
import 'package:focus/common/widgets/toast/message_view.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';
import 'package:focus/core/utils/universal/io.dart';
import 'package:focus/core/utils/utils.dart';
import 'package:focus/data/models/background_settings.dart';

const bool isDevMode = String.fromEnvironment('MODE') == 'debug';
const bool useLocalServer = String.fromEnvironment('SERVER') == 'local';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HomeStore>(
          create: (context) => HomeStore(),
          dispose: (context, store) => store.dispose(),
        ),
        Provider<BackgroundStore>(
          create: (context) => BackgroundStore(),
          dispose: (context, store) => store.dispose(),
        ),
        Provider<WidgetStore>(create: (context) => WidgetStore()),
      ],
      child: const Home(key: ValueKey('Home')),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final BackgroundStore backgroundStore = context.read<BackgroundStore>();
  late final HomeStore store = context.read<HomeStore>();

  late final LocalStorageManager storageManager = GetIt.instance.get<LocalStorageManager>();

  ReactionDisposer? _disposer;

  Timer? _timer;

  final GlobalKey homeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    backgroundStore.initializationFuture.then((_) {
      listenToEvents();
      // Start the timer for auto background refresh only if required.
      if (!backgroundStore.backgroundRefreshRate.requiresTimer) return;
      startTimer();
    });
    _shouldShowChangelog();
    _checkAndShowPermissionDialog();
  }

  void listenToEvents() {
    _disposer = reaction(
      (react) => backgroundStore.backgroundRefreshRate,
      onRefreshRateChanged,
    );
  }

  /// Start and stop timer based on the current [BackgroundRefreshRate] when
  /// changed from settings panel. Doing this allows us to avoid unnecessary
  /// timer updates.
  void onRefreshRateChanged(BackgroundRefreshRate refreshRate) {
    if (refreshRate.requiresTimer) {
      startTimer();
    } else if (!refreshRate.requiresTimer) {
      stopTimer();
    }
  }

  /// Start the timer for auto background refresh.
  void startTimer() {
    if (_timer != null) return;
    log('Starting timer for background refresh');
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => backgroundStore.onTimerCallback(),
    );
  }

  /// Stop the timer for auto background refresh.
  void stopTimer() {
    if (_timer == null) return;
    log('Stopping timer for background refresh');
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // App
            RepaintBoundary(
              key: homeKey,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(
                    child: RepaintBoundary(child: HomeBackground()),
                  ),
                  const Positioned.fill(
                    child: RepaintBoundary(child: HomeWidget()),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: BottomBar(),
                  ),
                  const RepaintBoundary(child: SettingsPanel()),
                  Positioned(
                    bottom: 48,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: MessageBanner(
                        controller: store.messageBannerController,
                        maxLines: 1,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        bannerStyle: MessageBannerStyle.solid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isDevMode) ...[
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: onScreenshot,
                      iconSize: 20,
                      tooltip: 'Screenshot',
                      icon: const Icon(Icons.photo_size_select_actual_outlined),
                    ),
                    const SizedBox(width: 8),
                    CustomObserver(
                      name: 'Image Index',
                      builder: (context) {
                        return Text(
                          backgroundStore.imageIndex.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: CustomObserver(
                  name: 'Image Time',
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0: ${DateFormat('dd/MM/yyyy hh:mm a').format(backgroundStore.image1Time)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1: ${DateFormat('dd/MM/yyyy hh:mm a').format(backgroundStore.image2Time)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> onScreenshot() async {
    // take a screenshot with homeKey and save.
    final Uint8List imageBytes = await takeScreenshot(homeKey);
    final fileName = 'background_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.jpg';

    if (kIsWeb) {
      return downloadImage(imageBytes, fileName);
    }

    /// Show native save file dialog on desktop.
    final String? path = await FilePicker.platform.saveFile(
      type: FileType.image,
      dialogTitle: 'common.saveImage'.tr(),
      fileName: fileName,
    );
    if (path == null) return;

    downloadImage(imageBytes, path);
  }

  Future<void> _shouldShowChangelog() async {
    final String? storedVersion = await storageManager.getString(
      StorageKeys.version,
    );
    if (storedVersion == null || storedVersion != packageInfo.version) {
      log('Updating stored version');
      await storageManager.setString(StorageKeys.version, packageInfo.version);
      // Removed: No longer show permission dialog on first load
      // Permission dialog will be shown by _checkAndShowPermissionDialog() if needed
    }
  }

  Future<void> _checkAndShowPermissionDialog() async {
    // Wait a bit to ensure UI is ready and changelog dialog check is done
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Check if any permissions are granted
    final hasAnyPermissions = await PermissionRequestDialog.hasAnyPermissions();
    if (!hasAnyPermissions) {
      // Check if there's already a dialog showing by checking if Navigator can pop
      // If changelog dialog was shown, it should have been dismissed or permission dialog shown
      // So we check again after a delay
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      log('No permissions granted, showing permission dialog');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => const Material(
              type: MaterialType.transparency,
              child: PermissionRequestDialog(),
            ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposer?.reaction.dispose();
    super.dispose();
  }
}
