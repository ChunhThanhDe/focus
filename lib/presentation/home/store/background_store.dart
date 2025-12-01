/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
* @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:shared/shared.dart';
import 'package:unsplash_client/unsplash_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus/data/sources/backend/backend_service.dart';
import 'package:focus/core/constants/color_gradients.dart';
import 'package:focus/core/constants/flat_colors.dart';
import 'package:focus/core/constants/storage_keys.dart';
import 'package:focus/core/constants/unsplash_sources.dart';
import 'package:focus/core/utils/extensions.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';
import 'package:focus/core/utils/universal/io.dart';
import 'package:focus/core/utils/utils.dart';
import 'package:focus/data/models/background_settings.dart';
import 'package:focus/data/models/color_gradient.dart';
import 'package:focus/data/models/flat_color.dart';
import 'package:focus/domain/entities/todo_item.dart';

part 'background_store.g.dart';

/// Version of the settings. This is exported with settings and used to
/// determine if the settings are compatible with the current version of the
/// app.
const int settingsVersion = 1;

/// Most important model of all. This model is responsible for the background
/// of the home screen. It is responsible for loading the background image
/// from the internet, cache it, manage it, and for storing the settings of
/// the background.
// ignore: library_private_types_in_public_api
class BackgroundStore = _BackgroundStore with _$BackgroundStore;

abstract class _BackgroundStore with Store, LazyInitializationMixin {
  late final LocalStorageManager storage =
      GetIt.instance.get<LocalStorageManager>();

  // Defines the size of the window. This is used to fetch images of the
  /// correct size.
  Size windowSize = const Size(1920, 1080);

  @readonly
  bool _isLoadingImage = false;

  @readonly
  bool _showLoadingBackground = false;

  @readonly
  bool _initialized = false;

  /// In memory copy of the cached images.
  @readonly
  Background? _image1;

  @readonly
  Background? _image2;

  @readonly
  ObservableMap<String, LikedBackground> _likedBackgrounds = ObservableMap.of(
    {},
  );

  late Future initializationFuture;

  @readonly
  BackgroundMode _mode = BackgroundMode.todo;

  @readonly
  FlatColor _color = FlatColors.minimal;

  @readonly
  ColorGradient _gradient = ColorGradients.youtube;

  @readonly
  double _tint = 0.0;

  @readonly
  bool _texture = false;

  @readonly
  bool _invert = false;

  @readonly
  bool _greyScale = false;

  @readonly
  ImageSource _imageSource = ImageSource.unsplash;

  @readonly
  UnsplashSource _unsplashSource = UnsplashSources.curated;

  @readonly
  BackgroundRefreshRate _backgroundRefreshRate = BackgroundRefreshRate.newTab;

  @readonly
  int _imageIndex = 0;

  @readonly
  DateTime _image1Time = DateTime.now();

  @readonly
  DateTime _image2Time = DateTime.now();

  @readonly
  ImageResolution _imageResolution = ImageResolution.auto;

  @readonly
  ObservableList<UnsplashSource> _customSources = ObservableList.of([]);

  final BackendService backendService = GetIt.instance.get<BackendService>();

  @computed
  bool get isLiked {
    return currentImage != null &&
        _likedBackgrounds.containsKey(
          StorageKeys.likedBackground(currentImage!.id),
        );
  }

  @computed
  bool get isColorMode => _mode.isColor;

  @computed
  bool get isGradientMode => _mode.isGradient;

  @computed
  bool get isImageMode => _mode.isImage;

  @computed
  bool get isTodoMode => _mode.isTodo;

  /// Latest background change time.
  late DateTime backgroundLastUpdated;

  late final DeBouncer _debouncer = DeBouncer(const Duration(seconds: 1));

  _BackgroundStore() {
    initializationFuture = init();
  }

  @override
  Future<void> init() async {
    final data = await storage.getJson(StorageKeys.backgroundSettings);
    final settings =
        data != null ? BackgroundSettings.fromJson(data) : BackgroundSettings();

    _mode = settings.mode;
    _color = settings.color;
    _gradient = settings.gradient;
    _tint = settings.tint;
    _texture = settings.texture;
    _invert = settings.invert;
    _greyScale = settings.greyScale;
    _imageSource = settings.source;
    _unsplashSource = settings.unsplashSource;
    _backgroundRefreshRate = settings.imageRefreshRate;
    _imageResolution = settings.imageResolution;
    _customSources = ObservableList.of(settings.customSources);

    final todoData = await storage.getJson(StorageKeys.todoSettings);
    if (todoData != null) {
      final List<dynamic> items = (todoData['tasks'] as List?) ?? [];
      _todoTasks = ObservableList.of(
        items
            .map((e) => TodoItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
      final int? ts = todoData['reminderAt'] as int?;
      _todoReminderAt =
          ts != null && ts > 0 ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
      _use24HourTodo = (todoData['use24HourTodo'] as bool?) ?? true;
      _todoDarkMode = (todoData['todoDarkMode'] as bool?) ?? false;
    }

    // load image last updated time
    _imageIndex = await storage.getInt(StorageKeys.imageIndex) ?? 0;

    _image1Time = await storage
        .getInt('image1Time')
        .then((value) => DateTime.fromMillisecondsSinceEpoch(value ?? 0));

    _image2Time = await storage
        .getInt('image2Time')
        .then((value) => DateTime.fromMillisecondsSinceEpoch(value ?? 0));

    backgroundLastUpdated = await storage
        .getInt(StorageKeys.backgroundLastUpdated)
        .then((value) {
          if (value == null) return DateTime.now();
          return DateTime.fromMillisecondsSinceEpoch(value);
        });

    _initialized = true;

    // Initialize image data
    await initializeImages();

    if (_backgroundRefreshRate == BackgroundRefreshRate.newTab) {
      updateBackground();
    }

    _logNextBackgroundChange();
  }

  @action
  void updateBackground() {
    switch (_mode) {
      case BackgroundMode.color:
        final int index = Random().nextInt(FlatColors.colors.length);
        _color = FlatColors.colors.values.elementAt(index);
        _save();
        break;
      case BackgroundMode.gradient:
        final int index = Random().nextInt(ColorGradients.gradients.length);
        _gradient = ColorGradients.gradients.values.elementAt(index);
        _save();
        break;
      case BackgroundMode.image:
        // If the refresh rate is set to new tab, then we update the image index
        // and schedule a new image fetch for the next time so we already have
        // an image cached when the user opens a new tab again.
        // Fetch new images
        log('fetch new images for new tab type');
        _refetchAndCacheOtherImage();
        // toggle the index and save it.

        _imageIndex = _imageIndex == 0 ? 1 : 0;
        storage.setInt(StorageKeys.imageIndex, _imageIndex);
        if (_imageIndex == 0) {
          _image1Time = DateTime.now();
          storage.setInt('image1Time', _image1Time.millisecondsSinceEpoch);
        } else {
          _image2Time = DateTime.now();
          storage.setInt('image2Time', _image2Time.millisecondsSinceEpoch);
        }
        break;
      case BackgroundMode.todo:
        break;
    }
  }

  /// Initializes images based on the current settings.
  /// We maintain 2 cached images at any time so that the user don't have to
  /// wait for it to load when they open new tab(Only applies if refresh rate is
  /// set to new tab).
  @action
  Future<void> initializeImages() async {
    if (_imageSource == ImageSource.unsplash ||
        _imageSource == ImageSource.userLikes) {
      if (!await storage.containsKey(StorageKeys.image1)) {
        // If no images are cached, fetch new ones now and cache them.
        _loadImageFromSource().then((result) {
          if (result == null) return;
          _image1 = result;
          storage.setJson(StorageKeys.image1, result.toJson());
          _image1Time = DateTime.now();
          storage.setInt('image1Time', _image1Time.millisecondsSinceEpoch);
        });
      } else {
        // If images are cached, load them.
        _image1 = await storage.getSerializableObject(
          StorageKeys.image1,
          Background.fromJson,
        );
      }
      if (!await storage.containsKey(StorageKeys.image2)) {
        // If no images are cached, fetch new ones now and cache them.
        _loadImageFromSource().then((result) {
          if (result == null) return;
          _image2 = result;
          storage.setJson(StorageKeys.image2, result.toJson());
          _image2Time = DateTime.now();
          storage.setInt('image2Time', _image2Time.millisecondsSinceEpoch);
        });
      } else {
        // If images are cached, load them.
        _image2 = await storage.getSerializableObject(
          StorageKeys.image2,
          Background.fromJson,
        );
      }
      final future = _loadLikedBackgrounds();
      if (_imageSource == ImageSource.userLikes) {
        // If the user likes are the source, we need to wait for the liked
        // backgrounds to load before we can load the image.
        log('Waiting for liked backgrounds to load');
        await future;
      }
    } else if (_imageSource == ImageSource.local) {
      // TODO: support local images | load local images
    }
  }

  /// Loads the liked backgrounds from the storage.
  Future<void> _loadLikedBackgrounds() async {
    final Set<String> keys = await storage.getKeys();
    final likedBackgrounds = <String, LikedBackground>{};
    for (final key in keys) {
      if (!key.startsWith(StorageKeys.liked)) continue;
      final background = await storage.getSerializableObject(
        key,
        LikedBackground.fromJson,
      );
      if (background == null) continue;
      likedBackgrounds[key] = background;
    }
    log('Found ${likedBackgrounds.length} liked backgrounds');
    _likedBackgrounds = ObservableMap.of(likedBackgrounds);
  }

  /// Responsible for fetching and caching the image other than the current
  /// image.
  @action
  Future<void> _refetchAndCacheOtherImage() async {
    log('refetchAndCacheOtherImage');
    _loadImageFromSource().then((result) {
      if (result == null) return;
      // We only update the image that is not currently being used so it can
      // be used next time when the user opens a new tab.
      if (_imageIndex == 0) {
        _image2 = result;
        storage.setJson(StorageKeys.image2, result.toJson());
        _image2Time = DateTime.now();
        storage.setInt('image2Time', _image2Time.millisecondsSinceEpoch);
      } else {
        _image1 = result;
        storage.setJson(StorageKeys.image1, result.toJson());
        _image1Time = DateTime.now();
        storage.setInt('image1Time', _image1Time.millisecondsSinceEpoch);
      }
    });
  }

  /// Logs the next background change time.
  void _logNextBackgroundChange() {
    if (!_backgroundRefreshRate.requiresTimer) return;

    final DateTime? nextUpdateTime = _backgroundRefreshRate.nextUpdateTime(
      backgroundLastUpdated,
    );
    if (nextUpdateTime == null) return;

    // ignore: avoid_print
    log(
      'Next Background change at ${DateFormat('dd/MM/yyyy hh:mm:ss a').format(nextUpdateTime)}',
    );
  }

  /// Fetches a new image from unsplash and sets it as the current image.
  /// If [updateAll] is set then it will also update the other cached image.
  /// This is helpful when the user changes the source of the image.
  @action
  Future<void> onChangeBackground({bool updateAll = false}) async {
    if (_isLoadingImage) return;

    switch (_mode) {
      case BackgroundMode.color:
        final index = Random().nextInt(FlatColors.colors.length);
        _color = FlatColors.colors.values.elementAt(index);
        _save();
        break;
      case BackgroundMode.gradient:
        final index = Random().nextInt(ColorGradients.gradients.length);
        _gradient = ColorGradients.gradients.values.elementAt(index);
        _save();
        break;
      case BackgroundMode.image:
        await _loadImageFromSource(showLoadingBackground: true).then((result) {
          if (result == null) return;

          // Update last updated time to current time.
          backgroundLastUpdated = DateTime.now();
          // save updated time to storage
          storage.setInt(
            StorageKeys.backgroundLastUpdated,
            backgroundLastUpdated.millisecondsSinceEpoch,
          );

          // Log next background change time.
          _logNextBackgroundChange();

          // Update the current image and cache it.
          if (_imageIndex == 0) {
            _image1 = result;
            storage.setJson(StorageKeys.image1, result.toJson());
            _image1Time = DateTime.now();
            storage.setInt('image1Time', _image1Time.millisecondsSinceEpoch);
          } else {
            _image2 = result;
            storage.setJson(StorageKeys.image2, result.toJson());
            _image2Time = DateTime.now();
            storage.setInt('image2Time', _image2Time.millisecondsSinceEpoch);
          }
        });
        if (updateAll) {
          // Most probably the image source changed, so we need to update the other
          // cached image as well.
          await _loadImageFromSource().then((result) {
            if (result == null) return;
            // Update the other image(not current one) and cache it.
            if (_imageIndex == 0) {
              _image2 = result;
              storage.setJson(StorageKeys.image2, result.toJson());
              _image2Time = DateTime.now();
              storage.setInt('image2Time', _image2Time.millisecondsSinceEpoch);
            } else {
              _image1 = result;
              storage.setJson(StorageKeys.image1, result.toJson());
              _image1Time = DateTime.now();
              storage.setInt('image1Time', _image1Time.millisecondsSinceEpoch);
            }
          });
        }
        break;
      case BackgroundMode.todo:
        break;
    }
  }

  /// Saves the current settings to storage.
  Future<bool> _save([BackgroundSettings? settings]) {
    settings ??= getCurrentSettings();
    return storage.setJson(StorageKeys.backgroundSettings, settings.toJson());
  }

  /// Constructs [BackgroundSettings] from the current settings.
  BackgroundSettings getCurrentSettings() {
    return BackgroundSettings(
      mode: _mode,
      color: _color,
      gradient: _gradient,
      source: _imageSource,
      tint: _tint,
      texture: _texture,
      invert: _invert,
      greyScale: _greyScale,
      imageRefreshRate: _backgroundRefreshRate,
      imageResolution: _imageResolution,
      unsplashSource: _unsplashSource,
      customSources: _customSources,
    );
  }

  @action
  void setMode(BackgroundMode mode) {
    // Auto set some tint when image mode is selected.
    _mode = mode;
    _tint = mode.isImage ? 17 : 0;
    _save();
  }

  @action
  void setColor(FlatColor color) {
    _color = color;
    _save();
  }

  @action
  void setGradient(ColorGradient gradient) {
    _gradient = gradient;
    _save();
  }

  @action
  void setTint(double tint) {
    _tint = tint;
    _save();
  }

  @action
  void setTexture(bool texture) {
    _texture = texture;
    _save();
  }

  /// This would invert the current tint color and the foreground color.
  @action
  void setInvert(bool invert) {
    _invert = invert;
    _save();
  }

  @action
  void setImageSource(ImageSource source) {
    _imageSource = source;
    _save();
    // Update the current image to the new source.
    onChangeBackground(updateAll: true);
  }

  @action
  void setUnsplashSource(UnsplashSource source) {
    _unsplashSource = source;
    _save();
    // Update the current image to the new source.
    onChangeBackground(updateAll: true);
  }

  @action
  void setImageRefreshRate(BackgroundRefreshRate rate) {
    _backgroundRefreshRate = rate;
    _save();
  }

  @action
  void setImageResolution(ImageResolution resolution) {
    _imageResolution = resolution;
    _save();
    onChangeBackground(updateAll: true);
  }

  @action
  void setGreyScale(bool greyScale) {
    _greyScale = greyScale;
    _save();
  }

  /// Retrieves the foreground color based on the current settings.
  @computed
  Color get foregroundColor {
    if (_mode.isTodo && _todoDarkMode) return Colors.white;
    if (_mode.isColor || _mode.isTodo) return _color.foreground;
    if (_mode.isGradient) return _gradient.foreground;
    // Return black(inverted) foreground color for image mode when
    // invert is true.
    if (_invert) return Colors.black;
    // This is the default foreground color for images.
    return Colors.white;
  }

  /// Retrieves the current image bytes based on the current settings.
  @computed
  Background? get currentImage {
    if (!_mode.isImage) return null;
    final image = _imageIndex == 0 ? _image1 : _image2;
    return image;
  }

  @readonly
  ObservableList<TodoItem> _todoTasks = ObservableList.of([]);

  @readonly
  DateTime? _todoReminderAt;

  @readonly
  bool _use24HourTodo = true;

  @readonly
  bool _todoDarkMode = true;

  @action
  void addTodo(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: t,
    );
    _todoTasks.insert(0, item);
    _saveTodo();
  }

  @action
  void addTodos(List<String> texts) {
    final items =
        texts
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map(
              (t) => TodoItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: t,
              ),
            )
            .toList();
    for (final item in items.reversed) {
      _todoTasks.insert(0, item);
    }
    _saveTodo();
  }

  @action
  void addTodoBelow(String afterId, {String text = ''}) {
    final int index = _todoTasks.indexWhere((e) => e.id == afterId);
    if (index < 0) return;
    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
    );
    _todoTasks.insert(index + 1, item);
    _saveTodo();
  }

  @action
  void reorderTodo(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _todoTasks.length) return;
    if (newIndex < 0 || newIndex > _todoTasks.length) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, item);
    _saveTodo();
  }

  @action
  void toggleTodo(String id, bool completed) {
    final int index = _todoTasks.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _todoTasks[index] = _todoTasks[index].copyWith(completed: completed);
    _saveTodo();
  }

  @action
  void removeTodo(String id) {
    _todoTasks.removeWhere((e) => e.id == id);
    _saveTodo();
  }

  @action
  void clearCompletedTodos() {
    _todoTasks.removeWhere((e) => e.completed);
    _saveTodo();
  }

  @action
  void clearAllTodos() {
    _todoTasks.clear();
    _saveTodo();
  }

  @action
  void scheduleTodoReminderMinutes(int minutes) {
    final int m = minutes < 1 ? 1 : minutes;
    _todoReminderAt = DateTime.now().add(Duration(minutes: m));
    _saveTodo();
    _notifyScheduleTodoReminder(m);
  }

  @action
  void setTodoRemindTime(String id, String time, {String? date}) {
    final int index = _todoTasks.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Nếu không có date được truyền vào, tự động tính dựa trên thời gian
    String remindDate;
    if (date != null) {
      remindDate = date;
    } else {
      // Parse thời gian để kiểm tra
      final parts = time.split(':');
      if (parts.length == 2) {
        final int? h = int.tryParse(parts[0]);
        final int? m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          final todayTime = DateTime(now.year, now.month, now.day, h, m);
          if (todayTime.isAfter(now)) {
            // Thời gian trong ngày chưa tới -> chọn ngày hôm nay
            remindDate = todayStr;
          } else {
            // Thời gian trong ngày đã qua -> chọn ngày mai
            final tomorrow = now.add(const Duration(days: 1));
            remindDate =
                '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
          }
        } else {
          remindDate = todayStr;
        }
      } else {
        remindDate = todayStr;
      }
    }

    _todoTasks[index] = _todoTasks[index].copyWith(
      remindTime: time,
      remindDate: remindDate,
    );
    _saveTodo();
  }

  @action
  void setTodoRemindDate(String id, String date) {
    final int index = _todoTasks.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _todoTasks[index] = _todoTasks[index].copyWith(remindDate: date);
    _saveTodo();
  }

  int _minutesUntilDateTime(String hhmm, String yyyyMMdd) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final int? h = int.tryParse(parts[0]);
    final int? m = int.tryParse(parts[1]);
    if (h == null || m == null) return 0;

    final dateParts = yyyyMMdd.split('-');
    if (dateParts.length != 3) return 0;
    final int? year = int.tryParse(dateParts[0]);
    final int? month = int.tryParse(dateParts[1]);
    final int? day = int.tryParse(dateParts[2]);
    if (year == null || month == null || day == null) return 0;

    final target = DateTime(year, month, day, h, m);
    final now = DateTime.now();

    // Nếu thời gian đã qua, trả về số phút âm (sẽ được xử lý ở trên)
    return target.difference(now).inMinutes;
  }

  @action
  void scheduleTaskReminderFromTime(String id) {
    final task = _todoTasks.firstWhereOrNull((e) => e.id == id);
    if (task == null) return;
    final String? time = task.remindTime;
    if (time == null || time.isEmpty) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String remindDate = task.remindDate ?? todayStr;

    // Nếu thời gian hôm nay đã qua, mặc định đặt ngày mai
    final parts = time.split(':');
    if (parts.length == 2) {
      final int? h = int.tryParse(parts[0]);
      final int? m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        final todayTime = DateTime(now.year, now.month, now.day, h, m);
        if (remindDate == todayStr && !todayTime.isAfter(now)) {
          // Thời gian hôm nay đã qua, đặt ngày mai
          final tomorrow = now.add(const Duration(days: 1));
          remindDate =
              '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
          final int index = _todoTasks.indexWhere((e) => e.id == id);
          if (index >= 0) {
            _todoTasks[index] = _todoTasks[index].copyWith(
              remindDate: remindDate,
            );
            _saveTodo();
          }
        }
      }
    }

    final minutes = _minutesUntilDateTime(time, remindDate);
    if (minutes < 0) {
      // Thời gian đã qua, không tạo thông báo
      return;
    }
    final int m = minutes < 1 ? 1 : minutes;
    _notifyScheduleTaskReminder(id, task.text, m);
  }

  @action
  void updateTodoText(String id, String text) {
    final int index = _todoTasks.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final t = text.trim();
    if (t.isEmpty) {
      _todoTasks.removeAt(index);
    } else {
      _todoTasks[index] = _todoTasks[index].copyWith(text: t);
    }
    _saveTodo();
  }

  void _notifyScheduleTodoReminder(int minutes) {
    try {
      if (!kIsWeb) return;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      if (chrome == null) return;
      final runtime = js_util.getProperty(chrome, 'runtime');
      final task = _todoTasks.firstWhereOrNull((e) => !e.completed);
      if (task == null)
        return; // Không có task nào chưa hoàn thành, không tạo reminder
      final String title = task.text;
      final String taskId = task.id;
      final message = {
        'action': 'todoScheduleReminder',
        'taskId': taskId,
        'minutes': minutes,
        'title': title,
      };
      js_util.callMethod(runtime, 'sendMessage', [js_util.jsify(message)]);
    } catch (_) {}
  }

  void _notifyScheduleTaskReminder(String taskId, String title, int minutes) {
    try {
      if (!kIsWeb) return;
      final chrome = js_util.getProperty(js_util.globalThis, 'chrome');
      if (chrome == null) return;
      final runtime = js_util.getProperty(chrome, 'runtime');
      final message = {
        'action': 'todoScheduleReminder',
        'taskId': taskId,
        'minutes': minutes,
        'title': title,
      };
      js_util.callMethod(runtime, 'sendMessage', [js_util.jsify(message)]);
    } catch (_) {}
  }

  Future<void> _saveTodo() async {
    final Map<String, dynamic> data = {
      'tasks': _todoTasks.map((e) => e.toJson()).toList(),
      'reminderAt': _todoReminderAt?.millisecondsSinceEpoch,
      'use24HourTodo': _use24HourTodo,
      'todoDarkMode': _todoDarkMode,
    };
    await storage.setJson(StorageKeys.todoSettings, data);
  }

  @action
  void setTodo24hFormat(bool value) {
    _use24HourTodo = value;
    _saveTodo();
  }

  @action
  void setTodoDarkMode(bool value) {
    _todoDarkMode = value;
    _saveTodo();
  }

  /// This retrieves the original url for unsplash image as Unsplash source API
  /// redirects to the original image url.
  Future<String?> retrieveRedirectionUrl(String url) async {
    return getRedirectionUrl(url);
  }

  /// Responsible for fetching a new image from unsplash.
  /// [showLoadingBackground] param is used to show a loading
  /// background (grey scale) while the image is being fetched when true.
  /// Setting [_isLoadingImage] to true will only show a loading indicator in
  /// the bottom of the page.
  ///
  /// Returns a [MapEntry] where key is the original image URL and the value
  /// is the image bytes. The key will be an empty string if the original image
  /// URL could not be retrieved.
  ///
  /// Returns null if the image could not be fetched.
  @action
  Future<Background?> _loadImageFromSource({
    bool showLoadingBackground = false,
  }) async {
    log('loadImageFromSource');
    _isLoadingImage = true;
    // This means that only show loading image background(grey scale) when
    // explicitly told to.
    _showLoadingBackground = showLoadingBackground;

    try {
      // Fetch the image from unsplash.
      final Background background = await _getImageUrlFromSource();
      return background;
    } catch (error, stacktrace) {
      log(error.toString());
      log(stacktrace.toString());
      // Some error occurred. Set loading to false.
      _isLoadingImage = false;
      _showLoadingBackground = false;
      return null;
    }
  }

  /// Refreshes the background image on timer callback.
  @action
  Future<void> onTimerCallback() async {
    if (!_backgroundRefreshRate.requiresTimer) return;

    // log('Auto Background refresh has been triggered');
    // Exit if it is not time to change the background based on the user
    // settings.
    if (_backgroundRefreshRate
            .nextUpdateTime(backgroundLastUpdated)!
            .isAfter(DateTime.now()) ||
        _isLoadingImage) {
      // Enable this to see the remaining time in console.

      final remainingTime = backgroundLastUpdated
          .add(_backgroundRefreshRate.duration)
          .difference(DateTime.now());
      log(
        '[DEBUG] Next background update in ${remainingTime.inSeconds} seconds',
      );
      return;
    }

    backgroundLastUpdated = DateTime.now();

    // Update the background image.
    await storage.setInt(
      StorageKeys.backgroundLastUpdated,
      backgroundLastUpdated.millisecondsSinceEpoch,
    );

    updateBackground();

    // Log next background change time.
    _logNextBackgroundChange();
  }

  Future<void> onDownload() async {
    final Background? image = currentImage;
    if (image == null) return;

    final fileName =
        'background_${DateTime.now().millisecondsSinceEpoch ~/ 1000}.jpg';

    final resolution = await storage.getEnum(
      StorageKeys.imageDownloadQuality,
      ImageResolution.values,
    );

    Uri uri = applyResolutionOnUrl(image.url, resolution);

    final response = await http.get(uri);
    final imageBytes =
        response.statusCode == 200 ? response.bodyBytes : image.bytes;

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

  Future<void> onOpenImage([BackgroundBase? image]) async {
    if (!_mode.isImage) return;
    image ??= _imageIndex == 0 ? _image1 : _image2;
    if (image == null) {
      // ignore: avoid_print
      log('No image url found');
      return;
    }

    final resolution = await storage.getEnum(
      StorageKeys.imageDownloadQuality,
      ImageResolution.values,
    );

    Uri uri = applyResolutionOnUrl(image.url, resolution);

    await launchUrl(uri);
  }

  Future<Background> _getImageUrlFromSource() async {
    final Size size = _imageResolution.toSize() ?? windowSize;
    switch (_imageSource) {
      case ImageSource.unsplash:
        final Photo? photo = await backendService.randomUnsplashImage(
          source: _unsplashSource,
          orientation: UnsplashPhotoOrientation.fromAspectRatio(
            size.aspectRatio,
          ),
        );
        if (photo == null) {
          throw Exception('Failed to fetch image from unsplash');
        }

        final url = photo.urls.rawWith(size: size);
        final bytes = await getImageBytesFromUrl(url);
        return UnsplashPhotoBackground(
          id: photo.urls.raw.pathSegments.last,
          photo: photo,
          bytes: bytes,
        );
      case ImageSource.userLikes:
        assert(_likedBackgrounds.isNotEmpty, 'No liked backgrounds found');
        final LikedBackground background = _likedBackgrounds.values.elementAt(
          Random().nextInt(_likedBackgrounds.length),
        );
        log('liked background url: ${background.url}');
        final url =
            background is UnsplashLikedBackground
                ? background.photo.urls.rawWith(size: size)
                : background.url;
        final bytes = await getImageBytesFromUrl(url);
        if (background is UnsplashLikedBackground) {
          return UnsplashPhotoBackground(
            id: background.photo.urls.raw.pathSegments.last,
            photo: background.photo,
            bytes: bytes,
          );
        }
        return Background(
          url: url,
          id: Uri.parse(url).pathSegments.last,
          bytes: bytes,
        );

      case ImageSource.local:
        // TODO: Handle this case.
        throw UnsupportedError('Unsupported background source');
    }
  }

  Future<Uint8List> getImageBytesFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    _isLoadingImage = false;
    _showLoadingBackground = false;
    if (response.statusCode == 200) {
      log('loadUnsplashImage success');
      // Return the image bytes.
      // try {
      //   log('pre-caching downloaded image');
      //   if(context != null) {
      //     precacheImage(Image.memory(response.bodyBytes).image, context!);
      //   }
      // }catch(e){
      //   return response.bodyBytes;
      // }
      return response.bodyBytes;
    }
    log('loadUnsplashImage failed ${response.statusCode}');
    // Received some error.
    log('Error: ${response.body}');
    throw Exception(response.body);
  }

  @action
  Future<void> onToggleLike(bool liked) async {
    final likedBackground = currentImage!.toLikedBackground();
    final String storageKey = StorageKeys.likedBackground(likedBackground.id);
    if (liked) {
      _likedBackgrounds[storageKey] = likedBackground;
    } else {
      _likedBackgrounds.remove(storageKey);
    }
    if (_imageSource == ImageSource.userLikes && !liked) {
      await storage.clearKey(storageKey);
      await onChangeBackground();
    } else {
      _debouncer.run(() async {
        log('Saving liked background $liked');
        if (liked) {
          // save
          await storage.setJson(storageKey, likedBackground.toJson());
        } else {
          // remove
          await storage.clearKey(storageKey);
        }
      });
    }
  }

  /// Adds a custom unsplash collection to the list of collections.
  @action
  void addNewCollection(UnsplashSource source, {bool setAsCurrent = false}) {
    _customSources.add(source);
    if (setAsCurrent) {
      // This internally saves the changes to storage.
      setUnsplashSource(source);
    } else {
      // Explicitly save the changes to storage.
      _save();
    }
  }

  /// Adds a custom unsplash collection to the list of collections.
  @action
  void removeCustomCollection(UnsplashSource source) {
    _customSources.remove(source);
    // Explicitly save the changes to storage.
    _save();
  }

  @action
  Future<void> reset({bool clear = true}) async {
    if (clear) {
      _likedBackgrounds.clear();
      _image1 = null;
      _image2 = null;
    }
    _todoTasks = ObservableList.of([]);
    _todoReminderAt = null;
    _use24HourTodo = true;
    _todoDarkMode = false;
    await _saveTodo();
    _initialized = false;
    initializationFuture = init();
    await initializationFuture;
  }

  @action
  Future<void> removeLikedPhoto(String key) async {
    _likedBackgrounds.remove(key);
    await storage.clearKey(key);
  }

  void dispose() {
    _debouncer.cancel();
  }
}
