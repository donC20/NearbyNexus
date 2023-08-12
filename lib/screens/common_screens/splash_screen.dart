// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

// ignore: unused_import
import 'package:NearbyNexus/screens/admin/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic>? initialSession;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getValidationData();
  }

  Future<void> getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var sessionData = sharedPreferences.getString("userSessionData");

    if (sessionData != null) {
      setState(() {
        initialSession = json.decode(sessionData);
      });
      try {
        if (initialSession == null) {
          _navigateToLoginScreen();
        } else {
          String userType = initialSession!["userType"];
          final SharedPreferences setUserUid =
              await SharedPreferences.getInstance();
          setUserUid.setString("uid", initialSession!["uid"]);
          navigateToUserScreen(userType);
        }
      } catch (e) {
        print("Error initializing app: $e");
        // Handle error if necessary
      }
    } else {
      print("No user session data found.");
          _navigateToLoginScreen();

    }
  }

  void _navigateToLoginScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.popAndPushNamed(context,
        "login_screen"); // Navigate using Get package (replace with your navigation code)
  }

  void navigateToUserScreen(String userType) {
    if (userType == "admin") {
      Navigator.popAndPushNamed(context,
          "admin_screen"); // Navigate using Get package (replace with your navigation code)
    } else if (userType == "vendor") {
      Navigator.popAndPushNamed(context,
          "vendor_home"); // Navigate using Get package (replace with your navigation code)
    } else if (userType == "general_user") {
      Navigator.popAndPushNamed(context,
          "user_home"); // Navigate using Get package (replace with your navigation code)
    } else {
      print("Unknown user type");
      // Handle unknown user type if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/nearbynexus(BL).png'),
      ),
    );
  }
}
