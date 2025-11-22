import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relygo/firebase_options.dart';
import 'package:relygo/screens/landing_page.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/background_service.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:relygo/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start background service for ride completion checking (only on mobile)
  if (PlatformUtils.isBackgroundServiceEnabled) {
    BackgroundService.startRideCompletionChecker();
  }

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
          // Show landing page on web, AuthWrapper on mobile (which handles persistent login)
          home: PlatformUtils.isWeb ? const LandingPage() : const AuthWrapper(),
        );
      },
    );
  }
}
