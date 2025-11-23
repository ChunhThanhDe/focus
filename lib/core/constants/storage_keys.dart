/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:09:32
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

class StorageKeys {
  StorageKeys._();

  static const String backgroundSettings = 'background_settings';
  static const String widgetSettings = 'widget_settings';
  static const String digitalClockSettings = 'digital_clock_settings';
  static const String digitalDateSettings = 'digital_date_settings';
  static const String analogueClockSettings = 'analogue_clock_settings';
  static const String messageSettings = 'message_settings';
  static const String timerSettings = 'timer_settings';
  static const String weatherSettings = 'weather_settings';
  static const String weatherInfo = 'weather_info';
  static const String widgetType = 'widget_type';
  static const String backgroundLastUpdated = 'background_last_updated';
  static const String weatherLastUpdated = 'weather_last_updated';
  static const String image1 = 'image1';
  static const String image2 = 'image2';
  static const String liked = 'liked';
  static const String version = 'version';
  static const String imageIndex = 'image_index';
  static const String imageDownloadQuality = 'image_download_quality';
  static const String socialCleanerSettings = 'social_cleaner_settings';
  static const String todoSettings = 'todo_settings';
  static const String todoNotes = 'todo_notes';

  static String likedBackground(String id) => 'liked:$id';
}
