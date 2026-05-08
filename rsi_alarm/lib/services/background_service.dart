import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'market_data_service.dart';
import 'rsi_calculator.dart';
import 'notification_service.dart';
import '../models/asset_model.dart';

class BackgroundService {
  static Future<void> checkRSIAlerts() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await NotificationService.initialize(plugin);

    final prefs = await SharedPreferences.getInstance();
    final assets = AssetModel.defaultAssets();

    for (final asset in assets) {
      // Kullanıcı bu varlığı devre dışı bıraktı mı?
      final isEnabled = prefs.getBool('asset_enabled_${asset.symbol}') ?? true;
      if (!isEnabled) continue;

      try {
        final data = await MarketDataService.fetchAssetData(asset.yahooSymbol);
        if (data == null) continue;

        final prices = List<double>.from(data['prices']);
        final rsi = RSICalculator.calculate(prices);
        if (rsi == null) continue;

        final alarmLevel = RSICalculator.checkAlarmLevel(rsi);
        if (alarmLevel == null) continue;

        // Son bildirimi kontrol et - aynı seviye için 4 saatte bir bildirim gönder
        final lastAlertKey = 'last_alert_${asset.symbol}_$alarmLevel';
        final lastAlert = prefs.getInt(lastAlertKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final fourHours = 4 * 60 * 60 * 1000;

        if (now - lastAlert < fourHours) continue;

        final message = RSICalculator.alarmLevelMessage(
          alarmLevel,
          asset.name,
          rsi,
        );

        final isOversold = alarmLevel.startsWith('OVERSOLD');

        await NotificationService.sendRSIAlert(
          assetName: asset.name,
          message: message,
          isOversold: isOversold,
        );

        await prefs.setInt(lastAlertKey, now);
      } catch (e) {
        // Hata durumunda devam et
        continue;
      }
    }
  }
}
