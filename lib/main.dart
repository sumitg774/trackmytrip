import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:provider/provider.dart';
import 'package:trip_tracker_app/PageComponents/LiveLocationTracking.dart';
import 'package:trip_tracker_app/Pages/Splash.dart';
import 'package:trip_tracker_app/Pages/QuickLocations.dart';
import 'package:trip_tracker_app/Utils/StorageService.dart';
import 'package:trip_tracker_app/ViewModels/HistoryViewModel.dart';
import 'package:trip_tracker_app/ViewModels/LoginViewModel.dart';
import 'package:trip_tracker_app/ViewModels/SignupViewModel.dart';

import 'PageComponents/BottomNavBar.dart';
import 'Pages/LoginPage.dart';
import 'Pages/SignupPage.dart';
import 'Utils/BackgroundService.dart';
import 'ViewModels/HomeViewModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await Firebase.initializeApp();
  await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel())
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  service.invoke('setAsForeground'); // ✅ Keep alive
  BackgroundService(service); // ✅ Call your BackgroundService
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (_) async => true,
    ),
  );
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
        '/splash': (context) => const SplashScreen(),
        '/quick_locations': (context) => OngoingTripMapScreen(),
      },
    );
  }
}
