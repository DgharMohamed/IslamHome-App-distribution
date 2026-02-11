import 'package:audio_service/audio_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Enhanced notification manager specifically for Quran playback
/// Requirements 1.1, 3.1, 3.2, 5.1: Proper notification display with Arabic text support
class NotificationManager {
  static const String channelId = 'quran_playback';
  static const String channelName = 'تشغيل القرآن';
  static const String channelDescription = 'التحكم في تشغيل القرآن الكريم';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Check if NotificationManager is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize notification channels for Quran playback
  /// Requirements 1.1, 3.1, 3.2: Display notification with proper Arabic support
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🎵 NotificationManager: Already initialized, skipping');
      return;
    }

    debugPrint('🎵 NotificationManager: Initializing...');

    try {
      // Get Android plugin instance
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Create the Quran playback notification channel with proper settings
        // for Arabic text display and media controls
        // Requirements 1.1, 3.1, 3.2: Enhanced channel for Arabic text support
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            playSound: false,
            enableVibration: false,
            showBadge: true,
            enableLights: false,
          ),
        );

        _isInitialized = true;
        debugPrint(
          '🎵 NotificationManager: Quran playback channel created successfully with Arabic support',
        );
      } else {
        debugPrint('🎵 NotificationManager: Android plugin not available');
      }
    } catch (e, stackTrace) {
      debugPrint('🎵 NotificationManager: Initialization error: $e');
      debugPrint('🎵 NotificationManager: Stack trace: $stackTrace');
      // Don't throw - allow app to continue without notifications
    }
  }

  /// Update notification with current media item and playback state
  /// Requirements 1.1, 3.1, 3.2: Display Quran information with proper Arabic formatting
  static Future<void> updateNotification(
    MediaItem item,
    PlaybackState state,
  ) async {
    try {
      debugPrint(
        '🎵 NotificationManager: Updating notification - ${item.title}',
      );

      // This is handled by AudioService automatically when we broadcast
      // the playback state and media item through the AudioHandler
      // The notification content is controlled by the MediaItem properties
      // which are already formatted with proper Arabic text in QuranMediaItem

      debugPrint('🎵 NotificationManager: Notification updated successfully');
    } catch (e) {
      debugPrint('🎵 NotificationManager: Error updating notification: $e');
    }
  }

  /// Format verse information for notification display
  /// Requirements 3.1, 3.2: Proper Arabic text formatting for verse information
  static String formatVerseInfo(String surahName, int verseNumber) {
    // Format: "سورة الفاتحة - آية 1"
    return 'سورة $surahName - آية $verseNumber';
  }

  /// Format notification title with proper Arabic text
  /// Requirements 1.1, 3.1: Display surah name and verse number clearly
  static String formatNotificationTitle(String surahName, int verseNumber) {
    // Format: "الفاتحة - آية 1"
    return '$surahName - آية $verseNumber';
  }

  /// Format notification subtitle/artist with proper Arabic text
  /// Requirements 1.1, 3.1: Display "القرآن الكريم" as artist
  static String formatNotificationArtist() {
    return 'القرآن الكريم';
  }

  /// Format notification album with proper Arabic text
  /// Requirements 1.1, 3.1: Display surah name as album
  static String formatNotificationAlbum(String surahName) {
    return 'سورة $surahName';
  }

  /// Validate that MediaItem has proper Arabic text formatting
  /// Requirements 1.1, 3.1, 3.2: Ensure notification displays correct information
  static bool validateMediaItemFormatting(MediaItem item) {
    // Check that title contains verse number in Arabic format
    if (!item.title.contains('آية')) {
      debugPrint(
        '🎵 NotificationManager: Warning - Title missing Arabic verse marker: ${item.title}',
      );
      return false;
    }

    // Check that artist is set to القرآن الكريم
    if (item.artist != 'القرآن الكريم') {
      debugPrint(
        '🎵 NotificationManager: Warning - Artist not set to القرآن الكريم: ${item.artist}',
      );
      return false;
    }

    // Check that album contains surah prefix
    if (item.album != null && !item.album!.contains('سورة')) {
      debugPrint(
        '🎵 NotificationManager: Warning - Album missing سورة prefix: ${item.album}',
      );
      return false;
    }

    return true;
  }

  /// Hide the playback notification
  static Future<void> hideNotification() async {
    try {
      debugPrint('🎵 NotificationManager: Hiding notification');

      // AudioService handles hiding notifications when playback stops
      // This is called automatically when the AudioHandler broadcasts
      // a stopped state

      debugPrint('🎵 NotificationManager: Notification hidden');
    } catch (e) {
      debugPrint('🎵 NotificationManager: Error hiding notification: $e');
    }
  }

  /// Show error notification for debugging
  static Future<void> showErrorNotification(String message) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'error_channel',
            'خطأ في التشغيل',
            channelDescription: 'إشعارات الأخطاء',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'خطأ',
          );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        998,
        'خطأ في تشغيل القرآن',
        message,
        details,
      );
    } catch (e) {
      debugPrint(
        '🎵 NotificationManager: Error showing error notification: $e',
      );
    }
  }
}
