import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<void> showMaintenanceSoon(String carName, String text) async {
    await init();
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '$carName: скоро ТО',
      text,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance_channel',
          'Напоминания ТО',
          channelDescription: 'Уведомления о скором техническом обслуживании',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
