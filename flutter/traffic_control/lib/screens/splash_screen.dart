import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'home_screen.dart'; // Import your next screen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to HomeScreen after 3 seconds
    Timer(const Duration(seconds: 2), () {
      Get.off(() => HomeScreen());
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/icon/splash_icon.png'),
            const Text(
              'ATR ELECTRONIC',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
