import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> scheduleDateReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    await init();
    final when = tz.TZDateTime.from(dueDate, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) {
      await _plugin.show(id, title, body, _notificationDetails());
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> notifyMileageDue({required int id, required String title, required String body}) async {
    await init();
    await _plugin.show(id, title, body, _notificationDetails());
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      'maintenance_channel',
      'Maintenance reminders',
      channelDescription: 'Reminders for upcoming and overdue car service',
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(android: android);
  }
}
