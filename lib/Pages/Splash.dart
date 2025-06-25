import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../PageComponents/BottomNavBar.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/StorageKeys.dart';
import '../Utils/StorageService.dart';
import 'LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String loginStatusText = "Checking login status...";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    navigateAfterDelay();
  }

  Future<void> checkLoginStatus() async {
    String? token = await StorageService.instance.getString(StorageKeys.userUid);

    setState(() {
      loginStatusText =
      token != null ? "✅ You are logged in" : "❌ You are not logged in yet";
    });
  }

  Future<void> navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2)); // 2-second delay
    String? token = await StorageService.instance.getString(StorageKeys.userUid);

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customBgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/app_logo.png',
            //   width: 150,
            //   height: 150,
            // ),
            const SizedBox(height: 20),
            Text(
              loginStatusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
