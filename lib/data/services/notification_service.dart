import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Explicitly create notification channels for Android
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'athan_channel',
          'Athan Notifications',
          description: 'Notifications for prayer times',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('athan'),
        ),
      );

      // Create Audio Service notification channel (for media playback)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'com.batman.islamiclibrary.audio',
          'تشغيل القرآن',
          description: 'التحكم بتشغيل التلاوات',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
          showBadge: true,
        ),
      );

      // Create new Quran playback notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'quran_playback',
          'تشغيل القرآن الكريم',
          description: 'التحكم في تشغيل القرآن الكريم',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
          showBadge: true,
          enableLights: false,
        ),
      );

      // Create Download notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'downloads_channel',
          'التحميلات',
          description: 'إشعارات تقدم التحميل',
          importance: Importance
              .low, // Low importance allows progress bars without sound/vibration spam
          playSound: false,
          enableVibration: false,
          showBadge: false,
        ),
      );
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'athan_channel',
          'Test Notification',
          channelDescription: 'Testing notification system',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999,
      'Test Alert',
      'If you see this, notifications are working correctly!',
      details,
    );
  }

  Future<void> scheduleAthan({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    // If scheduled date is in the past, don't schedule
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'athan_channel',
          'Athan Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(
            'athan',
          ), // Expecting 'athan.mp3' in res/raw
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'athan.aiff', // iOS expects sound file in app bundle
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'downloads_channel',
          'التحميلات',
          channelDescription: 'إشعارات تقدم التحميل',
          importance: Importance.low,
          priority: Priority.low,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          ongoing: true, // Prevents dismissal while downloading
          autoCancel: false,
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
      ), // iOS doesn't support progress bars directly in same way
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  Future<void> showDownloadCompleteNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'downloads_channel',
          'التحميلات',
          channelDescription: 'إشعارات تقدم التحميل',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: false,
          showProgress: false,
          ongoing: false,
          autoCancel: true,
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
