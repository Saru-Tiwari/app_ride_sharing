import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing_app/splash_screen.dart'; // Ensure this file exists

// Main entry point
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

// MyApp widget - Main app setup
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Sharing App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Directly set SplashScreen as home
    );
  }
}