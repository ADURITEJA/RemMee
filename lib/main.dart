import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'home.dart';
import 'ai_word_game.dart'; // Import AI Word Game
import 'notification_service.dart'; // ✅ Import Notification Service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize timezone data
  tz.initializeTimeZones();

  // ✅ Initialize notifications before launching app
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RemMe',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomeScreen(),
    );
  }
}