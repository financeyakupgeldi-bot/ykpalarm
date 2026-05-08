import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await BackgroundService.checkRSIAlerts();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize(flutterLocalNotificationsPlugin);

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Her 15 dakikada bir RSI kontrolü
  await Workmanager().registerPeriodicTask(
    'rsi-check',
    'rsiBackgroundCheck',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(const RSIAlarmApp());
}

class RSIAlarmApp extends StatelessWidget {
  const RSIAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSI Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        cardColor: const Color(0xFF131929),
      ),
      home: const HomeScreen(),
    );
  }
}
