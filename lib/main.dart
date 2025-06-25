import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_tracker_app/Pages/Splash.dart';
import 'package:trip_tracker_app/Pages/QuickLocations.dart';
import 'package:trip_tracker_app/Utils/StorageService.dart';

import 'PageComponents/BottomNavBar.dart';
import 'Pages/LoginPage.dart';
import 'Pages/SignupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
       initialRoute: '/splash',
      routes: {
        '/home': (context) => const BottomNavBar(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/splash':(context) => const SplashScreen(),
        '/quick_locations': (context) => QuickLocations()
      },
    );
  }
}
