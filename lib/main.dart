import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mqtt_service.dart';
import 'schedule_store.dart';
import 'screens/connect_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final mqtt = MqttService();
  final schedules = ScheduleStore(mqtt);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: mqtt),
        ChangeNotifierProvider.value(value: schedules),
      ],
      child: const PetApp(),
    ),
  );
}

class PetApp extends StatelessWidget {
  const PetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chăm sóc Boss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF18B99A),
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F6FA),
          foregroundColor: Color(0xFF17233B),
          elevation: 0,
        ),
      ),
      home: const ConnectScreen(),
    );
  }
}
