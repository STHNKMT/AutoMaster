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

  Future<void> showSoonServiceNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'service_soon_channel',
          'Скорое ТО',
          channelDescription: 'Напоминания о скором техническом обслуживании',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
