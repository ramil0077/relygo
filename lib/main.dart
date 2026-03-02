import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relygo/firebase_options.dart';
<<<<<<< HEAD
import 'package:relygo/screens/landing_page.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/background_service.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:relygo/widgets/auth_wrapper.dart';
=======
import 'package:relygo/constants.dart';
import 'package:relygo/services/background_service.dart';
import 'package:relygo/widgets/auth_wrapper.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:relygo/screens/admin_landing_page.dart';
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Improve error visibility in release builds: route Flutter framework errors
  // into the current zone so they are caught by runZonedGuarded and logged.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  // Show a friendly error widget for build-time errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'App error:\n$message',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  await runZonedGuarded<Future<void>>(
    () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e, st) {
        // If Firebase fails to initialize, show an error app so user sees the problem
        runApp(ErrorApp('Firebase init error: $e'));
        // Also log to console for adb logcat
        print('Firebase init error: $e\n$st');
        return;
      }

      // Start background service for ride completion checking (only on mobile)
      if (PlatformUtils.isBackgroundServiceEnabled) {
        BackgroundService.startRideCompletionChecker();
      }

      runApp(const MyApp());
    },
    (error, stack) {
      // Log uncaught errors so they show up in adb logcat
      print('Uncaught error: $error\n$stack');
    },
  );
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
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
          title: 'RelyGo – Ride & Delivery',
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
<<<<<<< HEAD
          home: PlatformUtils.isWeb ? const LandingPage() : const AuthWrapper(),
=======
          home: kIsWeb ? const AdminLandingPage() : const AuthWrapper(),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
        );
      },
    );
  }
}
