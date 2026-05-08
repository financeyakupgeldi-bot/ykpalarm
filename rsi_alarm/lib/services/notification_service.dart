import 'package:flutter/material.dart';
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
      color: isOversold ? Colors.green : Colors.red,
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      '📊 RSI Alarmı - $assetName',
      message,
      details,
    );
  }
}
