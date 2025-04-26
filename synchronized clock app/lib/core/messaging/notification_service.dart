import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initializationSettings);
    tz.initializeTimeZones();

    // إنشاء قناة foreground service notification
    const foregroundChannel = AndroidNotificationChannel(
      'my_foreground', // لازم يتطابق مع channelId في background service
      'Foreground Service',
      description: 'This channel is used for foreground service notifications.',
      importance: Importance.low,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    // إنشاء قناة للإشعارات العادية
    const normalChannel = AndroidNotificationChannel(
      'calibration_channel',
      'Calibration Reminders',
      description: 'Reminders to calibrate slave clocks.',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(normalChannel);

    var status = await Permission.notification.status;
    print("🔔 Notification permission status: $status");
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'calibration_channel',
      'Calibration Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showForegroundNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'my_foreground',
      'Foreground Service',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      888, // ثابت علشان نقدر نحدثه أو نلغيه بعدين
      title,
      body,
      notificationDetails,
    );
  }
}
