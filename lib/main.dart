import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:relygo/firebase_options.dart';
import 'package:relygo/widgets/auth_wrapper.dart';
import 'package:relygo/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}
