import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationPlugin.initialize(settings: initSettings);
  }

  Future<void> showDueReviewNotification(int count) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'due_review',
        'Due for Review',
        channelDescription: 'Notifications for problems due for review',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await notificationPlugin.show(
      id: 0,
      title: 'Time to review! 🧠',
      body: count == 1
          ? '1 problem is due for review'
          : '$count problems are due for review',
      notificationDetails: details,
    );
  }

  Future<void> scheduleDailyReminder() async {
    await notificationPlugin.cancelAll();

    final now = DateTime.now().toUtc();
    var scheduled = DateTime.utc(now.year, now.month, now.day, 9);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await notificationPlugin.periodicallyShowWithDuration(
      id: 1,
      title: 'Daily Review Reminder 🧠',
      body: 'Check your problems due for review',
      repeatDurationInterval: const Duration(hours: 24),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily reminder to review problems',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    ); 
  }
}
