import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relygo/firebase_options.dart';
import 'package:relygo/screens/splash.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start background service for ride completion checking
  BackgroundService.startRideCompletionChecker();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const Splashscreen(),
        );
      },
    );
  }
}
