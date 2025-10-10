import 'package:flutter/material.dart';
import 'package:relygo/screens/splash.dart';
import 'package:relygo/screens/user_dashboard_screen.dart';
import 'package:relygo/screens/driver_dashboard_screen.dart';
import 'package:relygo/screens/admin_dashboard_screen.dart';
import 'package:relygo/constants.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Splashscreen(),
      routes: {
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/driver-dashboard': (context) => const DriverDashboardScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
