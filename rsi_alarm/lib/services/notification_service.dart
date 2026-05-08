import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(initSettings);
  }

  static Future<void> sendRSIAlert({
    required String assetName,
    required String message,
    required bool isOversold,
  }) async {
    if (_plugin == null) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'rsi_alerts',
      'RSI Alarmları',
      channelDescription: 'RSI seviye bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      color: isOversold
          ? const Color(0xFF4CAF50) // Yeşil - aşırı satım (alım fırsatı)
          : const Color(0xFFEF5350), // Kırmızı - aşırı alım (satış sinyali)
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin!.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '📊 RSI Alarmı - $assetName',
      message,
      details,
    );
  }
}

// Dart:ui Color sınıfı yerine basit renk tutucusu
class Color {
  final int value;
  const Color(this.value);
}
